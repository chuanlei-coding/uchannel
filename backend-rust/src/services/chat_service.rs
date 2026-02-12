use chrono::Utc;
use sqlx::SqlitePool;
use std::collections::HashMap;
use tracing::{debug, info, warn};
use uuid::Uuid;

use crate::dto::{ChatRequest, ChatResponse, MessageDTO};
use crate::external::QwenService;
use crate::models::{Message, NewMessage};

pub struct ChatService {
    pool: SqlitePool,
    qwen_service: Option<QwenService>,
}

impl ChatService {
    const DEFAULT_USER_ID: &'static str = "default-user";

    pub fn new(pool: SqlitePool, qwen_service: Option<QwenService>) -> Self {
        Self {
            pool,
            qwen_service,
        }
    }

    pub async fn process_message(&self, request: ChatRequest) -> Result<ChatResponse, String> {
        info!(
            "Processing message: {} (conversation_id: {:?})",
            request.message, request.conversation_id
        );

        // Create or use existing conversation ID
        let conversation_id = request
            .conversation_id
            .filter(|id| !id.trim().is_empty())
            .unwrap_or_else(|| {
                let id = Uuid::new_v4().to_string();
                info!("Created new conversation: {}", id);
                id
            });

        // Save user message
        let user_msg = NewMessage {
            content: request.message.clone(),
            sender: "USER".to_string(),
            conversation_id: conversation_id.clone(),
        };
        self.save_message(user_msg).await?;

        // Get AI response
        let response = if let Some(ref qwen) = self.qwen_service {
            match qwen.chat(&request.message).await {
                Some(resp) => resp,
                None => {
                    warn!("Qwen service failed, using fallback");
                    self.analyze_schedule_message(&request.message)
                }
            }
        } else {
            warn!("Qwen service not configured, using fallback");
            self.analyze_schedule_message(&request.message)
        };

        // Save assistant response
        let assistant_msg = NewMessage {
            content: response.clone(),
            sender: "ASSISTANT".to_string(),
            conversation_id: conversation_id.clone(),
        };
        self.save_message(assistant_msg).await?;

        // Build response
        let mut chat_response = ChatResponse::new(true, response);
        chat_response = chat_response.with_data("conversationId", conversation_id.into());

        // Extract schedule info
        let schedule_info = self.extract_schedule_info(&request.message, &chat_response.message);
        if !schedule_info.is_null() && schedule_info.as_object().map_or(false, |obj| !obj.is_empty()) {
            chat_response = chat_response.with_data("schedule", schedule_info);
        }

        Ok(chat_response)
    }

    pub async fn get_history_messages(&self, conversation_id: &str) -> Result<Vec<MessageDTO>, String> {
        if conversation_id.trim().is_empty() {
            return Ok(vec![]);
        }

        let messages = sqlx::query_as::<_, Message>(
            "SELECT id, content, sender, conversation_id, timestamp FROM messages WHERE conversation_id = ? ORDER BY timestamp ASC"
        )
        .bind(conversation_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| format!("Database error: {}", e))?;

        Ok(messages.into_iter().map(MessageDTO::from).collect())
    }

    async fn save_message(&self, msg: NewMessage) -> Result<(), String> {
        let now = Utc::now();
        sqlx::query(
            "INSERT INTO messages (content, sender, conversation_id, timestamp) VALUES (?, ?, ?, ?)"
        )
        .bind(&msg.content)
        .bind(&msg.sender)
        .bind(&msg.conversation_id)
        .bind(now.to_rfc3339())
        .execute(&self.pool)
        .await
        .map_err(|e| format!("Failed to save message: {}", e))?;

        debug!("Saved message for conversation: {}", msg.conversation_id);
        Ok(())
    }

    fn analyze_schedule_message(&self, message: &str) -> String {
        let lower_message = message.to_lowercase();

        if self.contains_schedule_keywords(&lower_message) {
            let time_info = self.extract_time_info(message);
            if let Some(time) = time_info {
                return format!(
                    "已记录您的日程安排：{}。时间：{}。我会在适当的时候提醒您。",
                    message, time
                );
            }
            return format!("已记录您的日程安排：{}。我会在适当的时候提醒您。", message);
        }

        if self.contains_greeting(&lower_message) {
            return "你好！我是日程安排助手。请告诉我你的日程安排，例如：明天下午3点开会、下周一上午10点面试等。".to_string();
        }

        format!("已收到您的消息：{}。我会帮您处理日程安排相关的事务。", message)
    }

    fn contains_schedule_keywords(&self, message: &str) -> bool {
        let keywords = [
            "会议", "开会", "面试", "约会", "提醒", "日程", "安排", "明天", "后天",
            "下周", "下周一", "下周二", "下周三", "下周四", "下周五", "上午", "下午",
            "晚上", "点", "时",
        ];
        keywords.iter().any(|k| message.contains(k))
    }

    fn contains_greeting(&self, message: &str) -> bool {
        let greetings = [
            "你好", "您好", "hello", "hi", "在吗", "在", "help", "帮助",
        ];
        greetings.iter().any(|g| message.contains(g))
    }

    fn extract_time_info(&self, text: &str) -> Option<String> {
        // Simple time extraction - match patterns like "8点", "8:00", "8点30"
        let re = regex::Regex::new(r"(\d{1,2})[点:]?(\d{0,2})").ok()?;
        if let Some(caps) = re.captures(text) {
            let hour = caps.get(1)?.as_str();
            let minute = caps.get(2).map(|m| m.as_str()).unwrap_or("");
            if minute.is_empty() {
                return Some(format!("{}:00", hour));
            }
            return Some(format!(
                "{}:{}",
                hour,
                if minute.len() == 1 {
                    format!("0{}", minute)
                } else {
                    minute.to_string()
                }
            ));
        }
        None
    }

    fn extract_schedule_info(
        &self,
        user_message: &str,
        assistant_response: &str,
    ) -> serde_json::Value {
        let mut info = HashMap::new();
        let combined = format!("{} {}", user_message, assistant_response).to_lowercase();

        // Check if schedule is confirmed
        let is_confirmed = assistant_response.contains("安排")
            || assistant_response.contains("记录")
            || assistant_response.contains("提醒")
            || assistant_response.contains("设置")
            || assistant_response.contains("确认");

        if !is_confirmed {
            return serde_json::json!({});
        }

        // Extract time
        if let Some(time) = self.extract_time_info(&combined) {
            info.insert("time", time);
        }

        // Extract date
        let date_info = self.extract_date_info(&combined);
        if let Some(date) = date_info {
            info.insert("date", date);
        }

        // Extract title
        let title = self.extract_title(user_message);
        if !title.is_empty() {
            info.insert("title", title);
        }

        if !info.is_empty() {
            info.insert("valid", "true".to_string());
        }

        serde_json::to_value(info).unwrap_or(serde_json::json!({}))
    }

    fn extract_date_info(&self, text: &str) -> Option<String> {
        if text.contains("明天") {
            return Some("明天".to_string());
        }
        if text.contains("后天") {
            return Some("后天".to_string());
        }
        if text.contains("今天") {
            return Some("今天".to_string());
        }
        if text.contains("下周") {
            return Some("下周".to_string());
        }
        None
    }

    fn extract_title(&self, message: &str) -> String {
        let keywords = [
            "开会", "会议", "meeting", "面试", "interview", "谈话", "talk",
            "约会", "appointment", "课程", "class", "考试", "exam",
        ];

        for keyword in keywords {
            if message.to_lowercase().contains(keyword) {
                return keyword.to_string();
            }
        }

        if message.len() >= 3 {
            return message.chars().take(50).collect();
        }

        "日程安排".to_string()
    }
}
