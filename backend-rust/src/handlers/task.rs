use axum::{
    extract::{Path, Query, State},
    Json,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::sync::Arc;

use crate::dto::{TaskDTO, TaskRequest};
use crate::error::AppError;
use crate::services::TaskService;

#[derive(Clone)]
pub struct TaskState {
    pub task_service: Arc<TaskService>,
}

#[derive(Debug, Deserialize)]
pub struct BreakdownQuery {
    pub title: String,
    pub description: Option<String>,
}

pub async fn create_task(
    State(state): State<TaskState>,
    Json(request): Json<TaskRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Creating task: {}", request.title);

    let task = state.task_service.create_task(request).await?;

    Ok(Json(json!({
        "success": true,
        "message": "任务创建成功",
        "task": task
    })))
}

pub async fn get_all_tasks(State(state): State<TaskState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting all tasks");

    let tasks = state.task_service.get_all_tasks().await?;

    Ok(Json(json!({
        "success": true,
        "tasks": tasks,
        "count": tasks.len()
    })))
}

pub async fn get_tasks_by_date(
    State(state): State<TaskState>,
    Path(date): Path<String>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting tasks for date: {}", date);

    let tasks = state.task_service.get_tasks_by_date(&date).await?;

    Ok(Json(json!({
        "success": true,
        "date": date,
        "tasks": tasks,
        "count": tasks.len()
    })))
}

pub async fn get_pending_tasks(State(state): State<TaskState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting pending tasks");

    let tasks = state.task_service.get_pending_tasks().await?;

    Ok(Json(json!({
        "success": true,
        "tasks": tasks,
        "count": tasks.len()
    })))
}

pub async fn get_completed_tasks(State(state): State<TaskState>) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting completed tasks");

    let tasks = state.task_service.get_completed_tasks().await?;

    Ok(Json(json!({
        "success": true,
        "tasks": tasks,
        "count": tasks.len()
    })))
}

pub async fn get_task_by_id(
    State(state): State<TaskState>,
    Path(id): Path<i64>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::debug!("Getting task by id: {}", id);

    match state.task_service.get_task_by_id(id).await? {
        Some(task) => Ok(Json(json!({
            "success": true,
            "task": task
        }))),
        None => Ok(Json(json!({
            "success": false,
            "error": "任务不存在"
        }))),
    }
}

pub async fn update_task(
    State(state): State<TaskState>,
    Path(id): Path<i64>,
    Json(request): Json<TaskRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Updating task: {}", id);

    match state.task_service.update_task(id, request).await? {
        Some(task) => Ok(Json(json!({
            "success": true,
            "message": "任务更新成功",
            "task": task
        }))),
        None => Ok(Json(json!({
            "success": false,
            "error": "任务不存在"
        }))),
    }
}

pub async fn complete_task(
    State(state): State<TaskState>,
    Path(id): Path<i64>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Completing task: {}", id);

    let success = state.task_service.complete_task(id).await?;

    if success {
        Ok(Json(json!({
            "success": true,
            "message": "任务已完成"
        })))
    } else {
        Ok(Json(json!({
            "success": false,
            "error": "任务不存在或无法完成"
        })))
    }
}

pub async fn cancel_task(
    State(state): State<TaskState>,
    Path(id): Path<i64>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Cancelling task: {}", id);

    let success = state.task_service.cancel_task(id).await?;

    if success {
        Ok(Json(json!({
            "success": true,
            "message": "任务已取消"
        })))
    } else {
        Ok(Json(json!({
            "success": false,
            "error": "任务不存在或无法取消"
        })))
    }
}

pub async fn delete_task(
    State(state): State<TaskState>,
    Path(id): Path<i64>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Deleting task: {}", id);

    let success = state.task_service.delete_task(id).await?;

    if success {
        Ok(Json(json!({
            "success": true,
            "message": "任务已删除"
        })))
    } else {
        Ok(Json(json!({
            "success": false,
            "error": "任务不存在"
        })))
    }
}

pub async fn breakdown_task(
    State(state): State<TaskState>,
    Query(query): Query<BreakdownQuery>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Breaking down task: {}", query.title);

    let sub_tasks = state
        .task_service
        .breakdown_task(&query.title, query.description.as_deref())
        .await?;

    Ok(Json(json!({
        "success": true,
        "message": "任务拆解成功",
        "subTasks": sub_tasks,
        "count": sub_tasks.len()
    })))
}
