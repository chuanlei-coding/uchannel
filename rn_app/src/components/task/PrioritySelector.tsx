import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { TaskPriority, TaskPriorityText } from '../../models/Task';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';

interface PrioritySelectorProps {
  value: TaskPriority;
  onChange: (priority: TaskPriority) => void;
  layout?: 'horizontal' | 'vertical';
}

/**
 * 优先级选择器组件
 */
const PrioritySelector: React.FC<PrioritySelectorProps> = ({
  value,
  onChange,
  layout = 'horizontal',
}) => {
  const priorities = [
    { key: TaskPriority.urgent, label: TaskPriorityText[TaskPriority.urgent], color: Colors.terracotta },
    { key: TaskPriority.important, label: TaskPriorityText[TaskPriority.important], color: Colors.softGold },
    { key: TaskPriority.normal, label: TaskPriorityText[TaskPriority.normal], color: Colors.brandSage },
  ];

  const containerStyle = layout === 'vertical' ? styles.containerVertical : styles.containerHorizontal;

  return (
    <View style={containerStyle}>
      {priorities.map((priority) => {
        const isSelected = value === priority.key;

        return (
          <TouchableOpacity
            key={priority.key}
            style={[
              styles.option,
              layout === 'vertical' && styles.optionVertical,
              isSelected && { backgroundColor: priority.color },
            ]}
            onPress={() => onChange(priority.key)}
            activeOpacity={0.7}
          >
            <View
              style={[
                styles.indicator,
                { backgroundColor: priority.color },
                isSelected && { backgroundColor: Colors.white },
              ]}
            />
            <Text
              style={[
                styles.label,
                isSelected && { color: Colors.white },
              ]}
            >
              {priority.label}
            </Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  containerHorizontal: {
    flexDirection: 'row',
    gap: Spacing.sm,
  },
  containerVertical: {
    flexDirection: 'column',
    gap: Spacing.sm,
  },
  option: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    borderRadius: BorderRadius.full,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    backgroundColor: Colors.white,
  },
  optionVertical: {
    flex: 0,
  },
  indicator: {
    width: 8,
    height: 8,
    borderRadius: BorderRadius.full,
    marginRight: Spacing.sm,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
});

export default PrioritySelector;
