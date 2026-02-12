use axum::{
    extract::{Path, State},
    Json,
};
use serde_json::json;
use std::sync::Arc;

use crate::dto::{ChatRequest, ChatResponse};
use crate::error::AppError;
use crate::services::ChatService;

#[derive(Clone)]
pub struct ChatState {
    pub chat_service: Arc<ChatService>,
}

pub async fn send_message(
    State(state): State<ChatState>,
    Json(request): Json<ChatRequest>,
) -> Result<Json<ChatResponse>, AppError> {
    tracing::info!(
        "Received chat request: {} (conversation_id: {:?})",
        request.message,
        request.conversation_id
    );

    let response = state
        .chat_service
        .process_message(request)
        .await
        .map_err(|e| AppError::InternalError(e))?;

    Ok(Json(response))
}

pub async fn get_history(
    State(state): State<ChatState>,
    Path(conversation_id): Path<String>,
) -> Result<Json<serde_json::Value>, AppError> {
    tracing::info!("Getting history for conversation: {}", conversation_id);

    let messages = state
        .chat_service
        .get_history_messages(&conversation_id)
        .await
        .map_err(|e| AppError::InternalError(e))?;

    Ok(Json(json!({
        "success": true,
        "conversationId": conversation_id,
        "messages": messages,
        "count": messages.len()
    })))
}

pub async fn health() -> Result<Json<ChatResponse>, AppError> {
    Ok(Json(ChatResponse::new(true, "聊天服务运行正常")))
}
