use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::models::Task;

/// Task DTO matching Java TaskDTO exactly
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskDTO {
    pub id: i64,
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
    pub created_at: DateTime<Utc>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub completed_at: Option<DateTime<Utc>>,
}

impl From<Task> for TaskDTO {
    fn from(task: Task) -> Self {
        Self {
            id: task.id,
            category: task.category,
            title: task.title,
            description: task.description,
            start_time: task.start_time,
            end_time: task.end_time,
            task_date: task.task_date,
            priority: task.priority,
            status: task.status,
            icon_name: task.icon_name,
            category_color: task.category_color,
            tag: task.tag,
            ai_breakdown_enabled: task.ai_breakdown_enabled,
            created_at: task.created_at,
            completed_at: task.completed_at,
        }
    }
}

impl TaskDTO {
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

/// Task request matching Java TaskRequest exactly
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskRequest {
    pub title: String,
    pub description: Option<String>,
    pub category: String,
    #[serde(alias = "categoryColor")]
    pub category_color: Option<String>,
    #[serde(alias = "startTime")]
    pub start_time: String,
    #[serde(alias = "endTime")]
    pub end_time: String,
    #[serde(alias = "taskDate")]
    pub task_date: String,
    #[serde(default = "default_priority")]
    pub priority: String,
    pub tag: Option<String>,
    #[serde(default, alias = "aiBreakdownEnabled")]
    pub ai_breakdown_enabled: bool,
    #[serde(alias = "iconName")]
    pub icon_name: Option<String>,
    #[serde(alias = "userId")]
    pub user_id: Option<String>,
}

fn default_priority() -> String {
    "普通".to_string()
}

impl TaskRequest {
    // Default category colors matching Java
    const COLOR_MEDITATION: &'static str = "#9DC695";
    const COLOR_WORK: &'static str = "#5A8A83";
    const COLOR_SOCIAL: &'static str = "#BFC9C2";
    const COLOR_REVIEW: &'static str = "#D48C70";
    const COLOR_HIGH_PRIORITY: &'static str = "#D6A5A5";

    // Default icon names matching Java
    const ICON_MEDITATION: &'static str = "meditation";
    const ICON_WORK: &'static str = "auto_awesome";
    const ICON_SOCIAL: &'static str = "silverware-fork-knife";
    const ICON_REVIEW: &'static str = "note-edit-outline";
    const ICON_HIGH_PRIORITY: &'static str = "priority_high";

    pub fn get_category_color(&self) -> String {
        self.category_color
            .clone()
            .filter(|c| !c.is_empty())
            .unwrap_or_else(|| Self::default_color_for_category(&self.category))
    }

    pub fn get_icon_name(&self) -> String {
        self.icon_name
            .clone()
            .filter(|i| !i.is_empty())
            .unwrap_or_else(|| Self::default_icon_for_category(&self.category))
    }

    fn default_color_for_category(category: &str) -> String {
        match category {
            "深度工作" => Self::COLOR_WORK.to_string(),
            "社交" => Self::COLOR_SOCIAL.to_string(),
            "晚间回顾" => Self::COLOR_REVIEW.to_string(),
            "高优先级" => Self::COLOR_HIGH_PRIORITY.to_string(),
            _ => Self::COLOR_MEDITATION.to_string(),
        }
    }

    fn default_icon_for_category(category: &str) -> String {
        match category {
            "晨间冥想" => Self::ICON_MEDITATION.to_string(),
            "深度工作" => Self::ICON_WORK.to_string(),
            "社交" => Self::ICON_SOCIAL.to_string(),
            "晚间回顾" => Self::ICON_REVIEW.to_string(),
            _ => Self::ICON_MEDITATION.to_string(),
        }
    }
}
