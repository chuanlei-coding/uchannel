mod config;
mod dto;
mod error;
mod external;
mod handlers;
mod models;
mod services;

use std::str::FromStr;

use axum::{
    routing::{get, post},
    Router,
};
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use crate::config::Config;
use crate::external::QwenService;
use crate::handlers::{ChatState, StatsState, TaskState};
use crate::services::{ChatService, StatsService, TaskService};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize logging
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "uchannel_backend=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Load configuration
    let config = Config::from_env();
    tracing::info!("Starting UChannel backend on {}:{}", config.server_host, config.server_port);

    // Ensure data directory exists
    let data_dir = std::path::Path::new(&config.database_url)
        .parent()
        .unwrap_or(std::path::Path::new("./data"));
    std::fs::create_dir_all(data_dir).ok();

    // Connect to database with create-if-not-exists
    let pool = sqlx::sqlite::SqlitePoolOptions::new()
        .max_connections(5)
        .connect_with(
            sqlx::sqlite::SqliteConnectOptions::from_str(&config.database_url)?
                .create_if_missing(true)
        )
        .await?;

    // Initialize database schema
    init_database(&pool).await?;

    // Initialize services
    let qwen_service = QwenService::new(config.qwen_api_key.clone(), config.qwen_api_url.clone());
    let task_service = Arc::new(TaskService::new(pool.clone()));
    let chat_service = Arc::new(ChatService::new(pool.clone(), Some(qwen_service)));
    let stats_service = Arc::new(StatsService::new(task_service.clone()));

    // Build router
    let app = Router::new()
        // Chat routes
        .route("/api/chat/send", post(handlers::send_message))
        .route("/api/chat/history/{id}", get(handlers::get_history))
        .route("/api/chat/health", get(handlers::health))
        .with_state(ChatState {
            chat_service: chat_service.clone(),
        })
        // Task routes
        .route("/api/tasks", post(handlers::create_task).get(handlers::get_all_tasks))
        .route("/api/tasks/date/{date}", get(handlers::get_tasks_by_date))
        .route("/api/tasks/pending", get(handlers::get_pending_tasks))
        .route("/api/tasks/completed", get(handlers::get_completed_tasks))
        .route("/api/tasks/breakdown", post(handlers::breakdown_task))
        .route("/api/tasks/{id}", get(handlers::get_task_by_id).put(handlers::update_task).delete(handlers::delete_task))
        .route("/api/tasks/{id}/complete", post(handlers::complete_task))
        .route("/api/tasks/{id}/cancel", post(handlers::cancel_task))
        .with_state(TaskState {
            task_service: task_service.clone(),
        })
        // Stats routes
        .route("/api/stats/overview", get(handlers::get_overview))
        .route("/api/stats/weekly", get(handlers::get_weekly_stats))
        .route("/api/stats/category", get(handlers::get_category_stats))
        .route("/api/stats/priority", get(handlers::get_priority_stats))
        .route("/api/stats/heatmap", get(handlers::get_heatmap_data))
        .route("/api/stats/focus-time", get(handlers::get_focus_time_stats))
        .with_state(StatsState {
            stats_service,
        })
        // CORS
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        );

    // Start server
    let addr = format!("{}:{}", config.server_host, config.server_port);
    let listener = tokio::net::TcpListener::bind(&addr).await?;
    tracing::info!("Server listening on {}", addr);

    axum::serve(listener, app).await?;

    Ok(())
}

async fn init_database(pool: &sqlx::SqlitePool) -> Result<(), sqlx::Error> {
    tracing::info!("Initializing database schema");

    // Create tasks table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            category TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            task_date TEXT NOT NULL,
            priority TEXT,
            status TEXT NOT NULL DEFAULT 'pending',
            icon_name TEXT,
            category_color TEXT,
            tag TEXT,
            ai_breakdown_enabled INTEGER NOT NULL DEFAULT 0,
            sub_task_ids TEXT,
            created_at TEXT NOT NULL,
            completed_at TEXT,
            cancelled_at TEXT
        )
        "#,
    )
    .execute(pool)
    .await?;

    // Create messages table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            sender TEXT NOT NULL,
            conversation_id TEXT NOT NULL,
            timestamp TEXT NOT NULL
        )
        "#,
    )
    .execute(pool)
    .await?;

    // Create indexes
    sqlx::query("CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id)")
        .execute(pool)
        .await?;

    sqlx::query("CREATE INDEX IF NOT EXISTS idx_tasks_task_date ON tasks(task_date)")
        .execute(pool)
        .await?;

    sqlx::query("CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status)")
        .execute(pool)
        .await?;

    sqlx::query("CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id)")
        .execute(pool)
        .await?;

    tracing::info!("Database schema initialized");
    Ok(())
}
