package com.uchannel.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.uchannel.fragment.ChatFragment
import com.uchannel.fragment.ScheduleFragment

/**
 * 主界面ViewPager适配器
 */
class MainPagerAdapter(fragmentActivity: FragmentActivity) : FragmentStateAdapter(fragmentActivity) {

    override fun getItemCount(): Int = 2

    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> ChatFragment()
            1 -> ScheduleFragment()
            else -> throw IllegalArgumentException("Invalid position: $position")
        }
    }
}
