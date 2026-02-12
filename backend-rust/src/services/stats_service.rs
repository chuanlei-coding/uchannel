use chrono::{Datelike, Duration, Local, Weekday};
use std::sync::Arc;
use tracing::debug;

use crate::dto::{CategoryData, FocusTimeData, HeatmapDayData, PriorityData, TaskStatsDTO};
use crate::error::AppError;
use crate::services::TaskService;

#[derive(Clone)]
pub struct StatsService {
    task_service: Arc<TaskService>,
}

impl StatsService {
    pub fn new(task_service: Arc<TaskService>) -> Self {
        Self { task_service }
    }

    pub async fn get_overview(&self) -> Result<TaskStatsDTO, AppError> {
        debug!("Getting stats overview");
        self.task_service.get_task_stats().await
    }

    pub async fn get_weekly_stats(&self) -> Result<WeeklyStatsResponse, AppError> {
        debug!("Getting weekly stats");

        let task_stats = self.task_service.get_task_stats().await?;
        let today = Local::now().date_naive();
        let week_start = today - Duration::days(today.weekday().num_days_from_monday() as i64);

        let mut weekly_data = Vec::new();
        for i in 0..7 {
            let date = week_start + Duration::days(i);
            let day_name = Self::get_day_name(date.weekday());

            weekly_data.push(WeeklyDayData {
                date: date.format("%Y-%m-%d").to_string(),
                day_of_week: date.weekday().to_string(),
                day_name,
                tasks_completed: if i < 3 { (i + 1) as i32 } else { (rand::random::<f32>() * 5.0) as i32 },
            });
        }

        Ok(WeeklyStatsResponse {
            weekly_total: task_stats.weekly_total,
            weekly_completed: task_stats.weekly_completed,
            weekly_data,
            completion_rate: task_stats.completion_rate,
        })
    }

    pub async fn get_category_stats(&self) -> Result<Vec<CategoryData>, AppError> {
        debug!("Getting category stats");

        let task_stats = self.task_service.get_task_stats().await?;

        Ok(vec![
            CategoryData {
                name: "晨间冥想".to_string(),
                count: task_stats.meditation_tasks,
                color: "#9DC695".to_string(),
            },
            CategoryData {
                name: "深度工作".to_string(),
                count: task_stats.work_tasks,
                color: "#5A8A83".to_string(),
            },
            CategoryData {
                name: "社交".to_string(),
                count: task_stats.social_tasks,
                color: "#BFC9C2".to_string(),
            },
            CategoryData {
                name: "晚间回顾".to_string(),
                count: task_stats.review_tasks,
                color: "#D48C70".to_string(),
            },
        ])
    }

    pub async fn get_priority_stats(&self) -> Result<Vec<PriorityData>, AppError> {
        debug!("Getting priority stats");

        let task_stats = self.task_service.get_task_stats().await?;

        Ok(vec![
            PriorityData {
                name: "紧急".to_string(),
                count: task_stats.urgent_tasks,
                color: "#D6A5A5".to_string(),
            },
            PriorityData {
                name: "重要".to_string(),
                count: task_stats.important_tasks,
                color: "#D48C70".to_string(),
            },
            PriorityData {
                name: "普通".to_string(),
                count: task_stats.normal_tasks,
                color: "#9DC695".to_string(),
            },
        ])
    }

    pub async fn get_heatmap_data(&self, days: i32) -> Result<Vec<HeatmapDayData>, AppError> {
        debug!("Getting heatmap data for {} days", days);

        let today = Local::now().date_naive();
        let mut data = Vec::new();

        for i in (0..days).rev() {
            let date = today - Duration::days(i as i64);
            data.push(HeatmapDayData {
                date: date.format("%Y-%m-%d").to_string(),
                day_of_week: date.weekday().to_string(),
                task_count: (rand::random::<f32>() * 10.0) as i32,
                completed_count: (rand::random::<f32>() * 8.0) as i32,
            });
        }

        Ok(data)
    }

    pub async fn get_focus_time_stats(&self, _days: i32) -> Result<FocusTimeData, AppError> {
        debug!("Getting focus time stats");

        // TODO: Implement actual focus time tracking
        Ok(FocusTimeData {
            total_hours: 24.5,
            trend: "+12%".to_string(),
            daily_average: 3.5,
        })
    }

    fn get_day_name(day: Weekday) -> String {
        match day {
            Weekday::Mon => "周一".to_string(),
            Weekday::Tue => "周二".to_string(),
            Weekday::Wed => "周三".to_string(),
            Weekday::Thu => "周四".to_string(),
            Weekday::Fri => "周五".to_string(),
            Weekday::Sat => "周六".to_string(),
            Weekday::Sun => "周日".to_string(),
        }
    }
}

#[derive(serde::Serialize)]
pub struct WeeklyStatsResponse {
    pub weekly_total: i32,
    pub weekly_completed: i32,
    pub weekly_data: Vec<WeeklyDayData>,
    pub completion_rate: f64,
}

#[derive(serde::Serialize)]
pub struct WeeklyDayData {
    pub date: String,
    pub day_of_week: String,
    pub day_name: String,
    pub tasks_completed: i32,
}
