package com.uchannel.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.uchannel.R
import com.uchannel.adapter.ScheduleAdapter
import com.uchannel.model.Schedule
import com.uchannel.model.ScheduleStatus
import java.text.SimpleDateFormat
import java.util.*

/**
 * 日程列表Fragment
 */
class ScheduleFragment : Fragment() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var emptyTextView: TextView
    private lateinit var fabAddSchedule: FloatingActionButton
    private lateinit var scheduleAdapter: ScheduleAdapter
    private val schedules = mutableListOf<Schedule>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_schedule, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        recyclerView = view.findViewById(R.id.recyclerViewSchedules)
        emptyTextView = view.findViewById(R.id.textEmpty)
        fabAddSchedule = view.findViewById(R.id.fabAddSchedule)

        setupRecyclerView()
        setupFab()
        loadSchedules()
    }

    private fun setupFab() {
        fabAddSchedule.setOnClickListener {
            showNewScheduleDialog()
        }
    }

    private fun setupRecyclerView() {
        scheduleAdapter = ScheduleAdapter(schedules) { schedule ->
            // 点击日程项，打开编辑对话框
            showEditScheduleDialog(schedule)
        }

        recyclerView.layoutManager = LinearLayoutManager(requireContext())
        recyclerView.adapter = scheduleAdapter
    }

    private fun showEditScheduleDialog(schedule: Schedule) {
        val dialog = com.uchannel.dialog.EditScheduleDialog.newInstance(schedule)
        dialog.setOnSaveListener { updatedSchedule ->
            // 更新日程
            val index = schedules.indexOfFirst { it.id == updatedSchedule.id }
            if (index != -1) {
                schedules[index] = updatedSchedule
                scheduleAdapter.notifyItemChanged(index)
            } else {
                // 如果是新日程，添加到列表
                schedules.add(updatedSchedule)
                scheduleAdapter.notifyItemInserted(schedules.size - 1)
            }
            updateEmptyState()
            
            // TODO: 保存到本地存储或后端
        }
        dialog.show(parentFragmentManager, "EditScheduleDialog")
    }

    private fun loadSchedules() {
        // TODO: 从本地存储或后端加载日程
        // 初始为空，等待用户添加日程或从聊天中提取
        schedules.clear()
        scheduleAdapter.notifyDataSetChanged()
        updateEmptyState()
    }

    private fun updateEmptyState() {
        if (schedules.isEmpty()) {
            emptyTextView.visibility = View.VISIBLE
            recyclerView.visibility = View.GONE
        } else {
            emptyTextView.visibility = View.GONE
            recyclerView.visibility = View.VISIBLE
        }
    }

    /**
     * 添加新日程（可以从聊天消息中提取）
     */
    fun addSchedule(schedule: Schedule) {
        schedules.add(schedule)
        scheduleAdapter.notifyItemInserted(schedules.size - 1)
        updateEmptyState()
    }

    /**
     * 显示新建日程对话框
     */
    fun showNewScheduleDialog() {
        val dialog = com.uchannel.dialog.EditScheduleDialog.newInstance(null)
        dialog.setOnSaveListener { newSchedule ->
            schedules.add(newSchedule)
            scheduleAdapter.notifyItemInserted(schedules.size - 1)
            updateEmptyState()
            
            // TODO: 保存到本地存储或后端
        }
        dialog.show(parentFragmentManager, "EditScheduleDialog")
    }

    /**
     * 刷新日程列表
     */
    fun refreshSchedules() {
        loadSchedules()
    }
}
