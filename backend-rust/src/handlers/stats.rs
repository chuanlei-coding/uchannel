use axum::{
    extract::{Query, State},
    Json,
};
use serde::Deserialize;
use serde_json::json;
use std::sync::Arc;

use crate::error::AppError;
use crate::services::StatsService;

#[derive(Clone)]
pub struct StatsState {
    pub stats_service: Arc<StatsService>,
}

#[derive(Debug, Deserialize)]
pub struct DaysQuery {
    #[serde(default = "default_days")]
    pub days: i32,
}

fn default_days() -> i32 {
    7
}

#[derive(Debug, Deserialize)]
pub struct HeatmapQuery {
    #[serde(default = "default_heatmap_days")]
    pub days: i32,
}

fn default_heatmap_days() -> i32 {
    28
}

pub async fn get_overview(State(state): State<StatsState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting stats overview");

    let stats = state.stats_service.get_overview().await?;

    Ok(Json(json!({
        "success": true,
        "stats": stats,
        "lastUpdated": chrono::Utc::now().to_rfc3339()
    })))
}

pub async fn get_weekly_stats(State(state): State<StatsState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting weekly stats");

    let weekly = state.stats_service.get_weekly_stats().await?;

    Ok(Json(json!({
        "success": true,
        "weeklyTotal": weekly.weekly_total,
        "weeklyCompleted": weekly.weekly_completed,
        "weeklyData": weekly.weekly_data,
        "completionRate": weekly.completion_rate
    })))
}

pub async fn get_category_stats(State(state): State<StatsState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting category stats");

    let categories = state.stats_service.get_category_stats().await?;

    Ok(Json(json!({
        "success": true,
        "categories": categories
    })))
}

pub async fn get_priority_stats(State(state): State<StatsState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting priority stats");

    let priorities = state.stats_service.get_priority_stats().await?;

    Ok(Json(json!({
        "success": true,
        "priorities": priorities
    })))
}

pub async fn get_heatmap_data(
    State(state): State<StatsState>,
    Query(query): Query<HeatmapQuery>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting heatmap data for {} days", query.days);

    let data = state.stats_service.get_heatmap_data(query.days).await?;

    Ok(Json(json!({
        "success": true,
        "data": data,
        "days": query.days
    })))
}

pub async fn get_focus_time_stats(
    State(state): State<StatsState>,
    Query(query): Query<DaysQuery>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting focus time stats for {} days", query.days);

    let focus_time = state.stats_service.get_focus_time_stats(query.days).await?;

    Ok(Json(json!({
        "success": true,
        "focusTime": focus_time,
        "days": query.days
    })))
}
