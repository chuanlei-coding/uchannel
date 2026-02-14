import apiClient from './client';
import { Task, taskFromJson, taskToCreateRequest, taskToUpdateRequest } from '../../models/Task';

/**
 * 任务 API 服务
 */
class TaskApiService {
  /**
   * 创建任务
   */
  async createTask(task: Task): Promise<Task | null> {
    try {
      const response = await apiClient.post('/tasks', taskToCreateRequest(task));

      if (response.status === 200 && response.data.success) {
        return taskFromJson(response.data.task);
      }
    } catch (error) {
      console.error('Failed to create task:', error);
    }
    return null;
  }

  /**
   * 获取所有任务
   */
  async getAllTasks(): Promise<Task[]> {
    try {
      const response = await apiClient.get('/tasks');

      if (response.status === 200 && response.data.success) {
        const tasks = response.data.tasks as Array<Record<string, any>>;
        return tasks.map(taskFromJson);
      }
    } catch (error) {
      console.error('Failed to get all tasks:', error);
    }
    return [];
  }

  /**
   * 获取指定日期的任务
   */
  async getTasksByDate(date: string): Promise<Task[]> {
    try {
      // 使用 /api/tasks 然后在前端过滤日期
      const response = await apiClient.get('/tasks');

      if (response.status === 200 && response.data.success) {
        const allTasks = response.data.tasks as Array<Record<string, any>>;
        // 在前端过滤指定日期的任务
        const filteredTasks = allTasks.filter((t) => t.task_date === date);
        return filteredTasks.map(taskFromJson);
      }
    } catch (error) {
      console.error('Failed to get tasks by date:', error);
    }
    return [];
  }

  /**
   * 获取待处理任务
   */
  async getPendingTasks(): Promise<Task[]> {
    try {
      const response = await apiClient.get('/tasks/pending');

      if (response.status === 200 && response.data.success) {
        const tasks = response.data.tasks as Array<Record<string, any>>;
        return tasks.map(taskFromJson);
      }
    } catch (error) {
      console.error('Failed to get pending tasks:', error);
    }
    return [];
  }

  /**
   * 获取已完成任务
   */
  async getCompletedTasks(): Promise<Task[]> {
    try {
      const response = await apiClient.get('/tasks/completed');

      if (response.status === 200 && response.data.success) {
        const tasks = response.data.tasks as Array<Record<string, any>>;
        return tasks.map(taskFromJson);
      }
    } catch (error) {
      console.error('Failed to get completed tasks:', error);
    }
    return [];
  }

  /**
   * 根据ID获取任务
   */
  async getTaskById(id: number): Promise<Task | null> {
    try {
      const response = await apiClient.get(`/tasks/${id}`);

      if (response.status === 200 && response.data.success) {
        return taskFromJson(response.data.task);
      }
    } catch (error) {
      console.error('Failed to get task by id:', error);
    }
    return null;
  }

  /**
   * 更新任务
   */
  async updateTask(id: number, task: Task): Promise<Task | null> {
    try {
      const response = await apiClient.put(`/tasks/${id}`, taskToUpdateRequest(task));

      if (response.status === 200 && response.data.success) {
        return taskFromJson(response.data.task);
      }
    } catch (error) {
      console.error('Failed to update task:', error);
    }
    return null;
  }

  /**
   * 完成任务
   */
  async completeTask(id: number): Promise<boolean> {
    try {
      const response = await apiClient.post(`/tasks/${id}/complete`);
      return response.status === 200 && response.data.success;
    } catch (error) {
      console.error('Failed to complete task:', error);
      return false;
    }
  }

  /**
   * 取消任务
   */
  async cancelTask(id: number): Promise<boolean> {
    try {
      const response = await apiClient.post(`/tasks/${id}/cancel`);
      return response.status === 200 && response.data.success;
    } catch (error) {
      console.error('Failed to cancel task:', error);
      return false;
    }
  }

  /**
   * 删除任务
   */
  async deleteTask(id: number): Promise<boolean> {
    try {
      const response = await apiClient.delete(`/tasks/${id}`);
      return response.status === 200 && response.data.success;
    } catch (error) {
      console.error('Failed to delete task:', error);
      return false;
    }
  }

  /**
   * AI智能拆解任务
   */
  async breakdownTask(title: string, description?: string): Promise<Task[]> {
    try {
      const response = await apiClient.post('/tasks/breakdown', {
        title,
        ...(description ? { description } : {}),
      });

      if (response.status === 200 && response.data.success) {
        const subTasks = response.data.subTasks as Array<Record<string, any>>;
        return subTasks.map(taskFromJson);
      }
    } catch (error) {
      console.error('Failed to breakdown task:', error);
    }
    return [];
  }
}

export default new TaskApiService();
