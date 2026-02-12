use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::Row;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Task {
    pub id: i64,
    pub user_id: String,
    pub category: String,
    pub title: String,
    pub description: Option<String>,
    pub start_time: String,
    pub end_time: String,
    pub task_date: String,
    pub priority: Option<String>,
    pub status: String,
    pub icon_name: Option<String>,
    pub category_color: Option<String>,
    pub tag: Option<String>,
    pub ai_breakdown_enabled: bool,
    pub sub_task_ids: Option<String>,
    pub created_at: DateTime<Utc>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub completed_at: Option<DateTime<Utc>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cancelled_at: Option<DateTime<Utc>>,
}

impl Task {
    pub fn is_pending(&self) -> bool {
        self.status == "pending"
    }

    pub fn is_completed(&self) -> bool {
        self.status == "completed"
    }

    pub fn is_cancelled(&self) -> bool {
        self.status == "cancelled"
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NewTask {
    pub user_id: String,
    pub category: String,
    pub title: String,
    pub description: Option<String>,
    pub start_time: String,
    pub end_time: String,
    pub task_date: String,
    pub priority: Option<String>,
    pub status: Option<String>,
    pub icon_name: Option<String>,
    pub category_color: Option<String>,
    pub tag: Option<String>,
    pub ai_breakdown_enabled: Option<bool>,
}

impl NewTask {
    pub fn into_task(self) -> Task {
        Task {
            id: 0, // Will be set by database
            user_id: self.user_id,
            category: self.category,
            title: self.title,
            description: self.description,
            start_time: self.start_time,
            end_time: self.end_time,
            task_date: self.task_date,
            priority: self.priority,
            status: self.status.unwrap_or_else(|| "pending".to_string()),
            icon_name: self.icon_name,
            category_color: self.category_color,
            tag: self.tag,
            ai_breakdown_enabled: self.ai_breakdown_enabled.unwrap_or(false),
            sub_task_ids: None,
            created_at: Utc::now(),
            completed_at: None,
            cancelled_at: None,
        }
    }
}

// Custom FromRow implementation to handle DateTime parsing from SQLite strings
impl<'r> sqlx::FromRow<'r, sqlx::sqlite::SqliteRow> for Task {
    fn from_row(row: &'r sqlx::sqlite::SqliteRow) -> Result<Self, sqlx::Error> {
        let created_at_str: String = row.try_get("created_at")?;
        let completed_at_str: Option<String> = row.try_get("completed_at")?;
        let cancelled_at_str: Option<String> = row.try_get("cancelled_at")?;

        let created_at = chrono::DateTime::parse_from_rfc3339(&created_at_str)
            .map(|dt| dt.with_timezone(&Utc))
            .map_err(|e| sqlx::Error::Decode(Box::new(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("Invalid created_at datetime: {}", e),
            ))))?;

        let completed_at = completed_at_str
            .map(|s| {
                chrono::DateTime::parse_from_rfc3339(&s)
                    .map(|dt| dt.with_timezone(&Utc))
                    .map_err(|e| {
                        sqlx::Error::Decode(Box::new(std::io::Error::new(
                            std::io::ErrorKind::InvalidData,
                            format!("Invalid completed_at datetime: {}", e),
                        )))
                    })
            })
            .transpose()?;

        let cancelled_at = cancelled_at_str
            .map(|s| {
                chrono::DateTime::parse_from_rfc3339(&s)
                    .map(|dt| dt.with_timezone(&Utc))
                    .map_err(|e| {
                        sqlx::Error::Decode(Box::new(std::io::Error::new(
                            std::io::ErrorKind::InvalidData,
                            format!("Invalid cancelled_at datetime: {}", e),
                        )))
                    })
            })
            .transpose()?;

        let ai_breakdown_int: i32 = row.try_get("ai_breakdown_enabled")?;

        Ok(Task {
            id: row.try_get("id")?,
            user_id: row.try_get("user_id")?,
            category: row.try_get("category")?,
            title: row.try_get("title")?,
            description: row.try_get("description")?,
            start_time: row.try_get("start_time")?,
            end_time: row.try_get("end_time")?,
            task_date: row.try_get("task_date")?,
            priority: row.try_get("priority")?,
            status: row.try_get("status")?,
            icon_name: row.try_get("icon_name")?,
            category_color: row.try_get("category_color")?,
            tag: row.try_get("tag")?,
            ai_breakdown_enabled: ai_breakdown_int != 0,
            sub_task_ids: row.try_get("sub_task_ids")?,
            created_at,
            completed_at,
            cancelled_at,
        })
    }
}
