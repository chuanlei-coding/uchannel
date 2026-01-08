package com.uchannel.model

import java.util.Date

/**
 * 日程数据模型
 */
data class Schedule(
    val id: String,
    val title: String,
    val description: String,
    val date: Date,
    val time: String? = null,
    val location: String? = null,
    val status: ScheduleStatus = ScheduleStatus.PENDING,
    val createdAt: Date = Date()
)

enum class ScheduleStatus {
    PENDING,    // 待处理
    CONFIRMED,  // 已确认
    COMPLETED,  // 已完成
    CANCELLED   // 已取消
}
