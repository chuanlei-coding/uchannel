use chrono::{Duration, Local, NaiveDate, Utc};
use sqlx::SqlitePool;
use tracing::{debug, info, warn};

use crate::dto::{TaskDTO, TaskRequest, TaskStatsDTO};
use crate::error::AppError;
use crate::models::{NewTask, Task};

#[derive(Clone)]
pub struct TaskService {
    pool: SqlitePool,
}

impl TaskService {
    const DEFAULT_USER_ID: &'static str = "default-user";

    pub fn new(pool: SqlitePool) -> Self {
        Self { pool }
    }

    pub async fn create_task(&self, request: TaskRequest) -> Result<TaskDTO, AppError> {
        info!("Creating task: {} for user: {}", request.title, Self::DEFAULT_USER_ID);

        let category_color = request.get_category_color();
        let icon_name = request.get_icon_name();
        let tag = self.determine_tag(&request);

        let now = Utc::now();
        let result = sqlx::query(
            r#"
            INSERT INTO tasks (
                user_id, category, title, description, start_time, end_time,
                task_date, priority, status, icon_name, category_color, tag,
                ai_breakdown_enabled, sub_task_ids, created_at, completed_at, cancelled_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL)
            "#
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(&request.category)
        .bind(&request.title)
        .bind(&request.description)
        .bind(&request.start_time)
        .bind(&request.end_time)
        .bind(&request.task_date)
        .bind(&request.priority)
        .bind("pending")
        .bind(&icon_name)
        .bind(&category_color)
        .bind(&tag)
        .bind(request.ai_breakdown_enabled)
        .bind(None::<String>)
        .bind(now.to_rfc3339())
        .execute(&self.pool)
        .await?;

        let id = result.last_insert_rowid();
        info!("Task created successfully: {}", id);

        // Fetch the created task
        self.get_task_by_id(id).await?.ok_or_else(|| {
            AppError::InternalError("Failed to fetch created task".to_string())
        })
    }

    pub async fn get_all_tasks(&self) -> Result<Vec<TaskDTO>, AppError> {
        debug!("Getting all tasks for user: {}", Self::DEFAULT_USER_ID);

        let tasks = sqlx::query_as::<_, Task>(
            r#"
            SELECT id, user_id, category, title, description, start_time, end_time,
                   task_date, priority, status, icon_name, category_color, tag,
                   ai_breakdown_enabled, sub_task_ids, created_at, completed_at, cancelled_at
            FROM tasks
            WHERE user_id = ?
            ORDER BY task_date ASC, start_time ASC
            "#
        )
        .bind(Self::DEFAULT_USER_ID)
        .fetch_all(&self.pool)
        .await?;

        Ok(tasks.into_iter().map(TaskDTO::from).collect())
    }

    pub async fn get_tasks_by_date(&self, date: &str) -> Result<Vec<TaskDTO>, AppError> {
        debug!("Getting tasks for date: {}", date);

        let tasks = sqlx::query_as::<_, Task>(
            r#"
            SELECT id, user_id, category, title, description, start_time, end_time,
                   task_date, priority, status, icon_name, category_color, tag,
                   ai_breakdown_enabled, sub_task_ids, created_at, completed_at, cancelled_at
            FROM tasks
            WHERE user_id = ? AND task_date = ?
            ORDER BY start_time ASC
            "#
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(date)
        .fetch_all(&self.pool)
        .await?;

        Ok(tasks.into_iter().map(TaskDTO::from).collect())
    }

    pub async fn get_pending_tasks(&self) -> Result<Vec<TaskDTO>, AppError> {
        debug!("Getting pending tasks");

        let tasks = sqlx::query_as::<_, Task>(
            r#"
            SELECT id, user_id, category, title, description, start_time, end_time,
                   task_date, priority, status, icon_name, category_color, tag,
                   ai_breakdown_enabled, sub_task_ids, created_at, completed_at, cancelled_at
            FROM tasks
            WHERE user_id = ? AND status = ?
            ORDER BY task_date ASC, start_time ASC
            "#
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind("pending")
        .fetch_all(&self.pool)
        .await?;

        Ok(tasks.into_iter().map(TaskDTO::from).collect())
    }

    pub async fn get_completed_tasks(&self) -> Result<Vec<TaskDTO>, AppError> {
        debug!("Getting completed tasks");

        let tasks = sqlx::query_as::<_, Task>(
            r#"
            SELECT id, user_id, category, title, description, start_time, end_time,
                   task_date, priority, status, icon_name, category_color, tag,
                   ai_breakdown_enabled, sub_task_ids, created_at, completed_at, cancelled_at
            FROM tasks
            WHERE user_id = ? AND status = ?
            ORDER BY task_date ASC, start_time ASC
            "#
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind("completed")
        .fetch_all(&self.pool)
        .await?;

        Ok(tasks.into_iter().map(TaskDTO::from).collect())
    }

    pub async fn get_task_by_id(&self, id: i64) -> Result<Option<TaskDTO>, AppError> {
        debug!("Getting task by id: {}", id);

        let task = sqlx::query_as::<_, Task>(
            r#"
            SELECT id, user_id, category, title, description, start_time, end_time,
                   task_date, priority, status, icon_name, category_color, tag,
                   ai_breakdown_enabled, sub_task_ids, created_at, completed_at, cancelled_at
            FROM tasks
            WHERE id = ?
            "#
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(task.map(TaskDTO::from))
    }

    pub async fn update_task(&self, id: i64, request: TaskRequest) -> Result<Option<TaskDTO>, AppError> {
        info!("Updating task: {}", id);

        // Check if task exists
        if self.get_task_by_id(id).await?.is_none() {
            warn!("Task not found: {}", id);
            return Ok(None);
        }

        let tag = self.determine_tag(&request);
        let category_color = request.get_category_color();
        let icon_name = request.get_icon_name();

        sqlx::query(
            r#"
            UPDATE tasks SET
                title = ?, description = ?, category = ?, category_color = ?,
                icon_name = ?, start_time = ?, end_time = ?, task_date = ?,
                priority = ?, ai_breakdown_enabled = ?, tag = ?
            WHERE id = ?
            "#
        )
        .bind(&request.title)
        .bind(&request.description)
        .bind(&request.category)
        .bind(&category_color)
        .bind(&icon_name)
        .bind(&request.start_time)
        .bind(&request.end_time)
        .bind(&request.task_date)
        .bind(&request.priority)
        .bind(request.ai_breakdown_enabled)
        .bind(&tag)
        .bind(id)
        .execute(&self.pool)
        .await?;

        info!("Task updated successfully: {}", id);
        self.get_task_by_id(id).await
    }

    pub async fn complete_task(&self, id: i64) -> Result<bool, AppError> {
        info!("Completing task: {}", id);

        let task = self.get_task_by_id(id).await?;
        if let Some(t) = task {
            if !t.is_pending() {
                warn!("Task is not pending, cannot complete: {}", id);
                return Ok(false);
            }

            let now = Utc::now();
            sqlx::query(
                "UPDATE tasks SET status = ?, completed_at = ? WHERE id = ?"
            )
            .bind("completed")
            .bind(now.to_rfc3339())
            .bind(id)
            .execute(&self.pool)
            .await?;

            info!("Task completed: {}", id);
            return Ok(true);
        }

        warn!("Task not found: {}", id);
        Ok(false)
    }

    pub async fn cancel_task(&self, id: i64) -> Result<bool, AppError> {
        info!("Cancelling task: {}", id);

        let task = self.get_task_by_id(id).await?;
        if let Some(t) = task {
            if !t.is_pending() {
                warn!("Task is not pending, cannot cancel: {}", id);
                return Ok(false);
            }

            let now = Utc::now();
            sqlx::query(
                "UPDATE tasks SET status = ?, cancelled_at = ? WHERE id = ?"
            )
            .bind("cancelled")
            .bind(now.to_rfc3339())
            .bind(id)
            .execute(&self.pool)
            .await?;

            info!("Task cancelled: {}", id);
            return Ok(true);
        }

        warn!("Task not found: {}", id);
        Ok(false)
    }

    pub async fn delete_task(&self, id: i64) -> Result<bool, AppError> {
        info!("Deleting task: {}", id);

        let result = sqlx::query("DELETE FROM tasks WHERE id = ?")
            .bind(id)
            .execute(&self.pool)
            .await?;

        let deleted = result.rows_affected() > 0;
        if deleted {
            info!("Task deleted: {}", id);
        } else {
            warn!("Task not found for deletion: {}", id);
        }

        Ok(deleted)
    }

    pub async fn breakdown_task(&self, title: &str, description: Option<&str>) -> Result<Vec<TaskDTO>, AppError> {
        info!("Breaking down task: {}", title);

        let sub_task_count = if description.map(|d| d.len()).unwrap_or(0) > 50 {
            3
        } else {
            2
        };

        let mut created_tasks = Vec::new();
        let today = Local::now().format("%Y-%m-%d").to_string();

        for i in 1..=sub_task_count {
            let request = TaskRequest {
                title: format!("{} - 第{}步", title, i),
                description: None,
                category: "深度工作".to_string(),
                category_color: None,
                start_time: "09:00".to_string(),
                end_time: "10:00".to_string(),
                task_date: today.clone(),
                priority: "重要".to_string(),
                tag: Some("work".to_string()),
                ai_breakdown_enabled: false,
                icon_name: Some("auto_awesome".to_string()),
                user_id: None,
            };

            let task = self.create_task(request).await?;
            created_tasks.push(task);
        }

        info!("Task breakdown complete, created {} sub-tasks", created_tasks.len());
        Ok(created_tasks)
    }

    pub async fn get_task_stats(&self) -> Result<TaskStatsDTO, AppError> {
        debug!("Getting task statistics");

        let today = Local::now().format("%Y-%m-%d").to_string();
        let week_ago = (Local::now() - Duration::days(7)).format("%Y-%m-%d").to_string();

        let mut stats = TaskStatsDTO::default();

        // Total tasks for today
        stats.total_tasks = self.count_by_date_range(&today, &today).await?;
        stats.completed_tasks = self.count_by_status_and_date_range("completed", &today, &today).await?;

        // Weekly stats
        stats.weekly_total = self.count_by_date_range(&week_ago, &today).await?;
        stats.weekly_completed = self.count_by_status_and_date_range("completed", &week_ago, &today).await?;

        // Pending tasks
        stats.pending_tasks = self.count_by_status("pending").await?;

        // Priority stats
        stats.urgent_tasks = self.count_by_priority("紧急").await?;
        stats.important_tasks = self.count_by_priority("重要").await?;
        stats.normal_tasks = self.count_by_priority("普通").await?;

        // Category stats
        stats.meditation_tasks = self.count_by_category("晨间冥想").await?;
        stats.work_tasks = self.count_by_category("深度工作").await?;
        stats.social_tasks = self.count_by_category("社交").await?;
        stats.review_tasks = self.count_by_category("晚间回顾").await?;

        // Completion rate
        if stats.total_tasks > 0 {
            stats.completion_rate = (stats.completed_tasks as f64 / stats.total_tasks as f64) * 100.0;
        }

        debug!("Task stats: {:?}", stats);
        Ok(stats)
    }

    async fn count_by_date_range(&self, start: &str, end: &str) -> Result<i32, AppError> {
        let count: (i32,) = sqlx::query_as(
            "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND task_date >= ? AND task_date <= ?"
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(start)
        .bind(end)
        .fetch_one(&self.pool)
        .await?;

        Ok(count.0)
    }

    async fn count_by_status_and_date_range(&self, status: &str, start: &str, end: &str) -> Result<i32, AppError> {
        let count: (i32,) = sqlx::query_as(
            "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND status = ? AND task_date >= ? AND task_date <= ?"
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(status)
        .bind(start)
        .bind(end)
        .fetch_one(&self.pool)
        .await?;

        Ok(count.0)
    }

    async fn count_by_status(&self, status: &str) -> Result<i32, AppError> {
        let count: (i32,) = sqlx::query_as(
            "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND status = ?"
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(status)
        .fetch_one(&self.pool)
        .await?;

        Ok(count.0)
    }

    async fn count_by_priority(&self, priority: &str) -> Result<i32, AppError> {
        let count: (i32,) = sqlx::query_as(
            "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND priority = ?"
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(priority)
        .fetch_one(&self.pool)
        .await?;

        Ok(count.0)
    }

    async fn count_by_category(&self, category: &str) -> Result<i32, AppError> {
        let count: (i32,) = sqlx::query_as(
            "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND category = ?"
        )
        .bind(Self::DEFAULT_USER_ID)
        .bind(category)
        .fetch_one(&self.pool)
        .await?;

        Ok(count.0)
    }

    fn determine_tag(&self, request: &TaskRequest) -> Option<String> {
        if let Some(ref tag) = request.tag {
            if !tag.is_empty() {
                return Some(tag.clone());
            }
        }

        // Auto-determine tag based on priority and category
        if request.priority == "紧急" || request.priority == "重要" {
            return Some("highPriority".to_string());
        }

        if request.category.contains("冥想") || request.category.contains("晨间") {
            return Some("meditation".to_string());
        }

        if request.category.contains("工作") || request.category.contains("深度") {
            return Some("work".to_string());
        }

        if request.category.contains("社交") {
            return Some("social".to_string());
        }

        if request.category.contains("回顾") || request.category.contains("晚间") {
            return Some("review".to_string());
        }

        request.tag.clone()
    }
}
