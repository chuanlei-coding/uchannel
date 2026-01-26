import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity} from 'react-native';
import {Task} from '../models/Task';
import {Colors} from '../utils/colors';

interface TaskItemProps {
  task: Task;
  onToggle: () => void;
}

const TaskItem: React.FC<TaskItemProps> = ({task, onToggle}) => {
  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={onToggle} style={styles.checkboxContainer}>
        <View
          style={[
            styles.checkbox,
            task.isCompleted && styles.checkboxChecked,
          ]}>
          {task.isCompleted && <Text style={styles.checkmark}>✓</Text>}
        </View>
      </TouchableOpacity>
      <View style={styles.content}>
        <Text
          style={[
            styles.title,
            task.isCompleted && styles.titleCompleted,
          ]}>
          {task.title}
        </Text>
        {task.description && (
          <Text
            style={[
              styles.description,
              task.isCompleted && styles.descriptionCompleted,
            ]}>
            {task.description}
          </Text>
        )}
        {task.tags.length > 0 && (
          <View style={styles.tagsContainer}>
            {task.tags.map((tag, index) => (
              <View key={index} style={styles.tag}>
                <Text style={styles.tagText}>{tag}</Text>
              </View>
            ))}
          </View>
        )}
      </View>
      <Text
        style={[
          styles.time,
          task.isCompleted && styles.timeCompleted,
        ]}>
        {task.time}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.darkSage,
    marginHorizontal: 16,
    marginVertical: 8,
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  checkboxContainer: {
    marginRight: 12,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 4,
    borderWidth: 2,
    borderColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxChecked: {
    backgroundColor: Colors.brandSage,
  },
  checkmark: {
    color: Colors.charcoal,
    fontSize: 16,
    fontWeight: 'bold',
  },
  content: {
    flex: 1,
    marginRight: 12,
  },
  title: {
    fontSize: 15,
    color: Colors.textPrimary,
    fontWeight: 'bold',
  },
  titleCompleted: {
    opacity: 0.6,
  },
  description: {
    fontSize: 13,
    color: Colors.textWhite60,
    marginTop: 4,
  },
  descriptionCompleted: {
    opacity: 0.5,
  },
  tagsContainer: {
    flexDirection: 'row',
    marginTop: 8,
  },
  tag: {
    backgroundColor: Colors.inputBarDarkGreen,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    marginRight: 8,
  },
  tagText: {
    fontSize: 11,
    color: Colors.brandSage,
  },
  time: {
    fontSize: 13,
    color: Colors.brandSage,
    fontWeight: 'bold',
  },
  timeCompleted: {
    opacity: 0.6,
  },
});

export default TaskItem;
