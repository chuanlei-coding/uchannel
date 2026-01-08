package com.uchannel.dialog

import android.app.DatePickerDialog
import android.app.Dialog
import android.app.TimePickerDialog
import android.os.Bundle
import android.text.TextUtils
import android.widget.Button
import android.widget.EditText
import android.widget.Spinner
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.DialogFragment
import com.uchannel.R
import com.uchannel.model.Schedule
import com.uchannel.model.ScheduleStatus
import java.text.SimpleDateFormat
import java.util.*

/**
 * 编辑日程对话框
 */
class EditScheduleDialog : DialogFragment() {

    private var schedule: Schedule? = null
    private var onSaveListener: ((Schedule) -> Unit)? = null

    private lateinit var editTitle: EditText
    private lateinit var editDescription: EditText
    private lateinit var editDate: EditText
    private lateinit var editTime: EditText
    private lateinit var editLocation: EditText
    private lateinit var spinnerStatus: Spinner
    private lateinit var buttonSave: Button
    private lateinit var buttonCancel: Button

    private val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    private val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
    private var selectedDate: Date? = null
    private var selectedTime: String? = null

    companion object {
        fun newInstance(schedule: Schedule? = null): EditScheduleDialog {
            val dialog = EditScheduleDialog()
            dialog.schedule = schedule
            return dialog
        }
    }

    fun setOnSaveListener(listener: (Schedule) -> Unit) {
        onSaveListener = listener
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val view = requireActivity().layoutInflater.inflate(R.layout.dialog_edit_schedule, null)
        
        initViews(view)
        setupViews()
        loadScheduleData()

        val builder = AlertDialog.Builder(requireContext())
            .setView(view)

        return builder.create()
    }

    private fun initViews(view: android.view.View) {
        editTitle = view.findViewById(R.id.editTitle)
        editDescription = view.findViewById(R.id.editDescription)
        editDate = view.findViewById(R.id.editDate)
        editTime = view.findViewById(R.id.editTime)
        editLocation = view.findViewById(R.id.editLocation)
        spinnerStatus = view.findViewById(R.id.spinnerStatus)
        buttonSave = view.findViewById(R.id.buttonSave)
        buttonCancel = view.findViewById(R.id.buttonCancel)
    }

    private fun setupViews() {
        // 日期选择
        editDate.setOnClickListener {
            val calendar = Calendar.getInstance()
            selectedDate?.let { calendar.time = it }
            
            DatePickerDialog(
                requireContext(),
                { _, year, month, dayOfMonth ->
                    calendar.set(year, month, dayOfMonth)
                    selectedDate = calendar.time
                    editDate.setText(dateFormat.format(selectedDate!!))
                },
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH)
            ).show()
        }

        // 时间选择
        editTime.setOnClickListener {
            val calendar = Calendar.getInstance()
            selectedTime?.let {
                val parts = it.split(":")
                if (parts.size == 2) {
                    calendar.set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                    calendar.set(Calendar.MINUTE, parts[1].toInt())
                }
            }
            
            TimePickerDialog(
                requireContext(),
                { _, hourOfDay, minute ->
                    selectedTime = String.format("%02d:%02d", hourOfDay, minute)
                    editTime.setText(selectedTime)
                },
                calendar.get(Calendar.HOUR_OF_DAY),
                calendar.get(Calendar.MINUTE),
                true
            ).show()
        }

        // 状态选择器
        val statusAdapter = android.widget.ArrayAdapter.createFromResource(
            requireContext(),
            R.array.schedule_statuses,
            android.R.layout.simple_spinner_item
        ).also {
            it.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        }
        spinnerStatus.adapter = statusAdapter

        // 保存按钮
        buttonSave.setOnClickListener {
            if (validateAndSave()) {
                dismiss()
            }
        }

        // 取消按钮
        buttonCancel.setOnClickListener {
            dismiss()
        }
    }

    private fun loadScheduleData() {
        schedule?.let { s ->
            editTitle.setText(s.title)
            editDescription.setText(s.description)
            selectedDate = s.date
            editDate.setText(dateFormat.format(s.date))
            selectedTime = s.time
            editTime.setText(s.time ?: "")
            editLocation.setText(s.location ?: "")
            
            // 设置状态
            val statusIndex = when (s.status) {
                ScheduleStatus.PENDING -> 0
                ScheduleStatus.CONFIRMED -> 1
                ScheduleStatus.COMPLETED -> 2
                ScheduleStatus.CANCELLED -> 3
            }
            spinnerStatus.setSelection(statusIndex)
        } ?: run {
            // 新建日程，设置默认日期为今天
            selectedDate = Date()
            editDate.setText(dateFormat.format(selectedDate!!))
        }
    }

    private fun validateAndSave(): Boolean {
        val title = editTitle.text.toString().trim()
        if (TextUtils.isEmpty(title)) {
            Toast.makeText(requireContext(), "请输入日程标题", Toast.LENGTH_SHORT).show()
            return false
        }

        if (selectedDate == null) {
            Toast.makeText(requireContext(), "请选择日期", Toast.LENGTH_SHORT).show()
            return false
        }

        val description = editDescription.text.toString().trim()
        val location = editLocation.text.toString().trim()
        val time = selectedTime?.trim()?.takeIf { it.isNotEmpty() }
        
        val status = when (spinnerStatus.selectedItemPosition) {
            0 -> ScheduleStatus.PENDING
            1 -> ScheduleStatus.CONFIRMED
            2 -> ScheduleStatus.COMPLETED
            3 -> ScheduleStatus.CANCELLED
            else -> ScheduleStatus.PENDING
        }

        val updatedSchedule = schedule?.copy(
            title = title,
            description = description,
            date = selectedDate!!,
            time = time,
            location = location.ifEmpty { null },
            status = status
        ) ?: Schedule(
            id = UUID.randomUUID().toString(),
            title = title,
            description = description,
            date = selectedDate!!,
            time = time,
            location = location.ifEmpty { null },
            status = status
        )

        onSaveListener?.invoke(updatedSchedule)
        return true
    }
}
