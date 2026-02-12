use serde::{Deserialize, Serialize};

/// Task statistics matching Java TaskStatsDTO
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskStatsDTO {
    pub total_tasks: i32,
    pub completed_tasks: i32,
    pub pending_tasks: i32,
    pub urgent_tasks: i32,
    pub important_tasks: i32,
    pub normal_tasks: i32,
    pub meditation_tasks: i32,
    pub work_tasks: i32,
    pub social_tasks: i32,
    pub review_tasks: i32,
    pub weekly_total: i32,
    pub weekly_completed: i32,
    pub completion_rate: f64,
}

impl Default for TaskStatsDTO {
    fn default() -> Self {
        Self {
            total_tasks: 0,
            completed_tasks: 0,
            pending_tasks: 0,
            urgent_tasks: 0,
            important_tasks: 0,
            normal_tasks: 0,
            meditation_tasks: 0,
            work_tasks: 0,
            social_tasks: 0,
            review_tasks: 0,
            weekly_total: 0,
            weekly_completed: 0,
            completion_rate: 0.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CategoryData {
    pub name: String,
    pub count: i32,
    pub color: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PriorityData {
    pub name: String,
    pub count: i32,
    pub color: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HeatmapDayData {
    pub date: String,
    pub day_of_week: String,
    pub task_count: i32,
    pub completed_count: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FocusTimeData {
    pub total_hours: f64,
    pub trend: String,
    pub daily_average: f64,
}
