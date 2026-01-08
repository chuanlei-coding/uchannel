package com.uchannel.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.uchannel.R
import com.uchannel.model.Schedule
import com.uchannel.model.ScheduleStatus
import java.text.SimpleDateFormat
import java.util.*

/**
 * 日程列表适配器
 */
class ScheduleAdapter(
    private val schedules: MutableList<Schedule>,
    private val onItemClick: (Schedule) -> Unit = {}
) : RecyclerView.Adapter<ScheduleAdapter.ScheduleViewHolder>() {

    private val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    private val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
    private val dateTimeFormat = SimpleDateFormat("MM月dd日 HH:mm", Locale.getDefault())

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ScheduleViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_schedule, parent, false)
        return ScheduleViewHolder(view)
    }

    override fun onBindViewHolder(holder: ScheduleViewHolder, position: Int) {
        val schedule = schedules[position]
        holder.bind(schedule)
        holder.itemView.setOnClickListener {
            onItemClick(schedule)
        }
    }

    override fun getItemCount(): Int = schedules.size

    fun addSchedule(schedule: Schedule) {
        schedules.add(schedule)
        notifyItemInserted(schedules.size - 1)
    }

    fun updateSchedule(schedule: Schedule) {
        val index = schedules.indexOfFirst { it.id == schedule.id }
        if (index != -1) {
            schedules[index] = schedule
            notifyItemChanged(index)
        }
    }

    fun removeSchedule(scheduleId: String) {
        val index = schedules.indexOfFirst { it.id == scheduleId }
        if (index != -1) {
            schedules.removeAt(index)
            notifyItemRemoved(index)
        }
    }

    fun setSchedules(newSchedules: List<Schedule>) {
        schedules.clear()
        schedules.addAll(newSchedules)
        notifyDataSetChanged()
    }

    inner class ScheduleViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val titleText: TextView = itemView.findViewById(R.id.scheduleTitle)
        private val descriptionText: TextView = itemView.findViewById(R.id.scheduleDescription)
        private val dateText: TextView = itemView.findViewById(R.id.scheduleDate)
        private val timeText: TextView = itemView.findViewById(R.id.scheduleTime)
        private val statusText: TextView = itemView.findViewById(R.id.scheduleStatus)

        fun bind(schedule: Schedule) {
            titleText.text = schedule.title
            descriptionText.text = schedule.description
            
            // 格式化日期
            val dateStr = dateFormat.format(schedule.date)
            dateText.text = dateStr
            
            // 显示时间
            if (schedule.time != null) {
                timeText.text = schedule.time
                timeText.visibility = View.VISIBLE
            } else {
                timeText.visibility = View.GONE
            }
            
            // 显示状态
            statusText.text = when (schedule.status) {
                ScheduleStatus.PENDING -> "待处理"
                ScheduleStatus.CONFIRMED -> "已确认"
                ScheduleStatus.COMPLETED -> "已完成"
                ScheduleStatus.CANCELLED -> "已取消"
            }
            
            // 根据状态设置颜色
            statusText.setTextColor(
                itemView.context.getColor(
                    when (schedule.status) {
                        ScheduleStatus.PENDING -> android.R.color.holo_orange_dark
                        ScheduleStatus.CONFIRMED -> android.R.color.holo_blue_dark
                        ScheduleStatus.COMPLETED -> android.R.color.holo_green_dark
                        ScheduleStatus.CANCELLED -> android.R.color.darker_gray
                    }
                )
            )
        }
    }
}
