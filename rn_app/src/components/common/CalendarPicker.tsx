/**
 * 日历选择器组件
 * 与应用设计风格一致的日历弹窗
 */

import React, { useState, useMemo, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const CELL_SIZE = (SCREEN_WIDTH - Spacing.lg * 2 - Spacing.sm * 14) / 7;

interface CalendarPickerProps {
  visible: boolean;
  selectedDate: string; // YYYY-MM-DD format
  onDateSelect: (date: string) => void;
  onClose: () => void;
}

const WEEKDAYS = ['日', '一', '二', '三', '四', '五', '六'];
const MONTHS = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];

const CalendarPicker: React.FC<CalendarPickerProps> = ({
  visible,
  selectedDate,
  onDateSelect,
  onClose,
}) => {
  const [currentMonth, setCurrentMonth] = useState(() => {
    const date = selectedDate ? new Date(selectedDate) : new Date();
    if (isNaN(date.getTime())) {
      return new Date();
    }
    return new Date(date.getFullYear(), date.getMonth(), 1);
  });

  // 当 selectedDate 变化时，同步更新 currentMonth
  useEffect(() => {
    if (selectedDate) {
      const date = new Date(selectedDate);
      if (!isNaN(date.getTime())) {
        setCurrentMonth(new Date(date.getFullYear(), date.getMonth(), 1));
      }
    }
  }, [selectedDate]);

  const today = useMemo(() => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }, []);

  const goToPrevMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1));
  };

  const goToNextMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1));
  };

  const goToToday = () => {
    const todayDate = new Date();
    setCurrentMonth(new Date(todayDate.getFullYear(), todayDate.getMonth(), 1));
    onDateSelect(today);
  };

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startDayOfWeek = firstDay.getDay();

    const days: { date: string; day: number; isCurrentMonth: boolean }[] = [];

    // 上个月的日期
    const prevMonth = new Date(year, month, 0);
    const prevMonthDays = prevMonth.getDate();
    for (let i = startDayOfWeek - 1; i >= 0; i--) {
      const day = prevMonthDays - i;
      const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
      days.push({ date: dateStr, day, isCurrentMonth: false });
    }

    // 当前月的日期
    for (let i = 1; i <= daysInMonth; i++) {
      const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
      days.push({ date: dateStr, day: i, isCurrentMonth: true });
    }

    // 下个月的日期（填充到42天，6行）
    const remainingDays = 42 - days.length;
    for (let i = 1; i <= remainingDays; i++) {
      const dateStr = `${year}-${String(month + 2).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
      days.push({ date: dateStr, day: i, isCurrentMonth: false });
    }

    return days;
  };

  const days = useMemo(() => getDaysInMonth(currentMonth), [currentMonth]);

  const handleDayPress = (date: string) => {
    onDateSelect(date);
    onClose();
  };

  const year = currentMonth.getFullYear();
  const monthIndex = currentMonth.getMonth();

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <TouchableOpacity
        style={styles.overlay}
        activeOpacity={1}
        onPress={onClose}
      >
        <View style={styles.container}>
          {/* 头部 */}
          <View style={styles.header}>
            <TouchableOpacity onPress={goToPrevMonth} style={styles.navButton}>
              <Icon name="chevron-left" size={24} color={Colors.darkGrey} />
            </TouchableOpacity>

            <Text style={styles.monthTitle}>
              {year}年 {MONTHS[monthIndex]}
            </Text>

            <TouchableOpacity onPress={goToNextMonth} style={styles.navButton}>
              <Icon name="chevron-right" size={24} color={Colors.darkGrey} />
            </TouchableOpacity>
          </View>

          {/* 今天按钮 */}
          <TouchableOpacity style={styles.todayButton} onPress={goToToday}>
            <Text style={styles.todayButtonText}>回到今天</Text>
          </TouchableOpacity>

          {/* 星期标题 */}
          <View style={styles.weekdaysRow}>
            {WEEKDAYS.map((day, index) => (
              <Text
                key={index}
                style={[
                  styles.weekdayText,
                  (index === 0 || index === 6) && styles.weekendText,
                ]}
              >
                {day}
              </Text>
            ))}
          </View>

          {/* 日期网格 */}
          <View style={styles.daysGrid}>
            {days.map((item, index) => {
              const isSelected = item.date === selectedDate;
              const isToday = item.date === today;

              return (
                <TouchableOpacity
                  key={index}
                  style={[
                    styles.dayCell,
                    isSelected && styles.dayCellSelected,
                    !item.isCurrentMonth && styles.dayCellOtherMonth,
                  ]}
                  onPress={() => item.isCurrentMonth && handleDayPress(item.date)}
                  disabled={!item.isCurrentMonth}
                >
                  <Text
                    style={[
                      styles.dayText,
                      !item.isCurrentMonth && styles.dayTextOtherMonth,
                      isToday && !isSelected && styles.dayTextToday,
                      isSelected && styles.dayTextSelected,
                    ]}
                  >
                    {item.day}
                  </Text>
                  {isToday && !isSelected && <View style={styles.todayDot} />}
                </TouchableOpacity>
              );
            })}
          </View>

          {/* 取消按钮 */}
          <TouchableOpacity style={styles.cancelButton} onPress={onClose}>
            <Text style={styles.cancelButtonText}>取消</Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  container: {
    width: SCREEN_WIDTH - Spacing.lg * 2,
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.lg,
    shadowColor: Colors.darkGrey,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.15,
    shadowRadius: 24,
    elevation: 12,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  navButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.softSage + '40',
    alignItems: 'center',
    justifyContent: 'center',
  },
  monthTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  todayButton: {
    alignSelf: 'center',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.xs,
    backgroundColor: Colors.brandSage + '15',
    borderRadius: BorderRadius.full,
    marginBottom: Spacing.md,
  },
  todayButtonText: {
    fontSize: 13,
    color: Colors.brandSage,
    fontWeight: '500',
  },
  weekdaysRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: Spacing.sm,
    paddingHorizontal: Spacing.xs,
  },
  weekdayText: {
    width: CELL_SIZE,
    textAlign: 'center',
    fontSize: 12,
    fontWeight: '500',
    color: Colors.softGrey,
  },
  weekendText: {
    color: Colors.terracotta + '99',
  },
  daysGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  dayCell: {
    width: CELL_SIZE,
    height: CELL_SIZE,
    alignItems: 'center',
    justifyContent: 'center',
    margin: Spacing.xs / 2,
    borderRadius: BorderRadius.sm,
  },
  dayCellSelected: {
    backgroundColor: Colors.brandSage,
  },
  dayCellOtherMonth: {
    opacity: 0.4,
  },
  dayText: {
    fontSize: 15,
    color: Colors.darkGrey,
    fontWeight: '400',
  },
  dayTextOtherMonth: {
    color: Colors.softGrey,
  },
  dayTextToday: {
    color: Colors.brandSage,
    fontWeight: '600',
  },
  dayTextSelected: {
    color: Colors.white,
    fontWeight: '600',
  },
  todayDot: {
    position: 'absolute',
    bottom: 4,
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: Colors.brandSage,
  },
  cancelButton: {
    marginTop: Spacing.md,
    paddingVertical: Spacing.sm,
    alignItems: 'center',
  },
  cancelButtonText: {
    fontSize: 15,
    color: Colors.softGrey,
  },
});

export default CalendarPicker;
