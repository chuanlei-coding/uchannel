use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::Row;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Message {
    pub id: i64,
    pub content: String,
    pub sender: String,
    pub conversation_id: String,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NewMessage {
    pub content: String,
    pub sender: String,
    pub conversation_id: String,
}

impl NewMessage {
    pub fn into_message(self) -> Message {
        Message {
            id: 0,
            content: self.content,
            sender: self.sender,
            conversation_id: self.conversation_id,
            timestamp: Utc::now(),
        }
    }
}

// Custom FromRow implementation to handle DateTime parsing from SQLite strings
impl<'r> sqlx::FromRow<'r, sqlx::sqlite::SqliteRow> for Message {
    fn from_row(row: &'r sqlx::sqlite::SqliteRow) -> Result<Self, sqlx::Error> {
        let timestamp_str: String = row.try_get("timestamp")?;

        let timestamp = DateTime::parse_from_rfc3339(&timestamp_str)
            .map(|dt| dt.with_timezone(&Utc))
            .map_err(|e| {
                sqlx::Error::Decode(Box::new(std::io::Error::new(
                    std::io::ErrorKind::InvalidData,
                    format!("Invalid timestamp datetime: {}", e),
                )))
            })?;

        Ok(Message {
            id: row.try_get("id")?,
            content: row.try_get("content")?,
            sender: row.try_get("sender")?,
            conversation_id: row.try_get("conversation_id")?,
            timestamp,
        })
    }
}
