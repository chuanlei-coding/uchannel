use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use crate::models::Message;

/// Chat request matching Java ChatRequest
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatRequest {
    pub message: String,
    pub conversation_id: Option<String>,
}

/// Chat response matching Java ChatResponse
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatResponse {
    pub success: bool,
    pub message: String,
    #[serde(default)]
    pub data: HashMap<String, serde_json::Value>,
}

impl ChatResponse {
    pub fn new(success: bool, message: impl Into<String>) -> Self {
        Self {
            success,
            message: message.into(),
            data: HashMap::new(),
        }
    }

    pub fn with_data(mut self, key: impl Into<String>, value: serde_json::Value) -> Self {
        self.data.insert(key.into(), value);
        self
    }
}

/// Helper for serializing DateTime as ISO 8601 string
mod datetime_format {
    use chrono::{DateTime, Utc};
    use serde::{self, Deserialize, Deserializer, Serializer};

    pub fn serialize<S>(date: &DateTime<Utc>, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&date.to_rfc3339())
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<DateTime<Utc>, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        DateTime::parse_from_rfc3339(&s)
            .map(|dt| dt.with_timezone(&Utc))
            .map_err(serde::de::Error::custom)
    }
}

/// Message DTO matching Java MessageDTO
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessageDTO {
    pub id: i64,
    pub content: String,
    pub sender: String,
    pub conversation_id: String,
    #[serde(with = "datetime_format")]
    pub timestamp: DateTime<Utc>,
}

impl From<Message> for MessageDTO {
    fn from(msg: Message) -> Self {
        Self {
            id: msg.id,
            content: msg.content,
            sender: msg.sender,
            conversation_id: msg.conversation_id,
            timestamp: msg.timestamp,
        }
    }
}
