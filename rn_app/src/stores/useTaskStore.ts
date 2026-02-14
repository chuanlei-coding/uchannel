import { create } from 'zustand';
import { Task, TaskStatus, taskFromJson, createDefaultTask } from '../models/Task';
import taskApi from '../services/api/taskApi';
import storage, { StorageKeys } from '../services/storage/AsyncStorage';

interface TaskState {
  tasks: Task[];
  pendingTasks: Task[];
  completedTasks: Task[];
  isLoading: boolean;
  error: string | null;
  selectedDate: string;

  // Actions
  loadTasks: () => Promise<void>;
  loadTasksByDate: (date: string) => Promise<void>;
  loadPendingTasks: () => Promise<void>;
  loadCompletedTasks: () => Promise<void>;
  createTask: (task: Task) => Promise<Task | null>;
  updateTask: (id: number, task: Task) => Promise<Task | null>;
  completeTask: (id: number) => Promise<boolean>;
  cancelTask: (id: number) => Promise<boolean>;
  deleteTask: (id: number) => Promise<boolean>;
  breakdownTask: (title: string, description?: string) => Promise<Task[]>;
  setSelectedDate: (date: string) => void;
  loadPersistedTasks: () => Promise<void>;
}

// 获取今天的日期字符串
const getTodayString = (): string => {
  const today = new Date();
  return today.toISOString().split('T')[0];
};

const useTaskStore = create<TaskState>((set, get) => ({
  tasks: [],
  pendingTasks: [],
  completedTasks: [],
  isLoading: false,
  error: null,
  selectedDate: getTodayString(),

  loadTasks: async () => {
    set({ isLoading: true, error: null });

    try {
      const tasks = await taskApi.getAllTasks();
      set({ tasks, isLoading: false });
    } catch (error) {
      set({ isLoading: false, error: '加载任务失败' });
    }
  },

  loadTasksByDate: async (date: string) => {
    set({ isLoading: true, error: null, selectedDate: date });

    try {
      const tasks = await taskApi.getTasksByDate(date);
      set({ tasks, isLoading: false });
    } catch (error) {
      set({ isLoading: false, error: '加载任务失败' });
    }
  },

  loadPendingTasks: async () => {
    set({ isLoading: true });

    try {
      const pendingTasks = await taskApi.getPendingTasks();
      set({ pendingTasks, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
    }
  },

  loadCompletedTasks: async () => {
    set({ isLoading: true });

    try {
      const completedTasks = await taskApi.getCompletedTasks();
      set({ completedTasks, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
    }
  },

  createTask: async (task: Task) => {
    set({ isLoading: true, error: null });

    try {
      const newTask = await taskApi.createTask(task);

      if (newTask) {
        set((state) => {
          const updatedTasks = [...state.tasks, newTask];
          storage.setItem(StorageKeys.TASKS_CACHE, updatedTasks);
          return { tasks: updatedTasks, isLoading: false };
        });
        return newTask;
      } else {
        set({ isLoading: false, error: '创建任务失败' });
        return null;
      }
    } catch (error) {
      set({ isLoading: false, error: '网络错误' });
      return null;
    }
  },

  updateTask: async (id: number, task: Task) => {
    set({ isLoading: true });

    try {
      const updatedTask = await taskApi.updateTask(id, task);

      if (updatedTask) {
        set((state) => {
          const updatedTasks = state.tasks.map((t) =>
            t.id === id ? updatedTask : t
          );
          storage.setItem(StorageKeys.TASKS_CACHE, updatedTasks);
          return { tasks: updatedTasks, isLoading: false };
        });
        return updatedTask;
      } else {
        set({ isLoading: false, error: '更新任务失败' });
        return null;
      }
    } catch (error) {
      set({ isLoading: false, error: '网络错误' });
      return null;
    }
  },

  completeTask: async (id: number) => {
    try {
      const success = await taskApi.completeTask(id);

      if (success) {
        set((state) => {
          const updatedTasks = state.tasks.map((t) =>
            t.id === id ? { ...t, status: TaskStatus.completed } : t
          );
          storage.setItem(StorageKeys.TASKS_CACHE, updatedTasks);
          return { tasks: updatedTasks };
        });
      }
      return success;
    } catch (error) {
      return false;
    }
  },

  cancelTask: async (id: number) => {
    try {
      const success = await taskApi.cancelTask(id);

      if (success) {
        set((state) => {
          const updatedTasks = state.tasks.map((t) =>
            t.id === id ? { ...t, status: TaskStatus.cancelled } : t
          );
          storage.setItem(StorageKeys.TASKS_CACHE, updatedTasks);
          return { tasks: updatedTasks };
        });
      }
      return success;
    } catch (error) {
      return false;
    }
  },

  deleteTask: async (id: number) => {
    try {
      const success = await taskApi.deleteTask(id);

      if (success) {
        set((state) => {
          const updatedTasks = state.tasks.filter((t) => t.id !== id);
          storage.setItem(StorageKeys.TASKS_CACHE, updatedTasks);
          return { tasks: updatedTasks };
        });
      }
      return success;
    } catch (error) {
      return false;
    }
  },

  breakdownTask: async (title: string, description?: string) => {
    set({ isLoading: true });

    try {
      const subTasks = await taskApi.breakdownTask(title, description);
      set({ isLoading: false });
      return subTasks;
    } catch (error) {
      set({ isLoading: false });
      return [];
    }
  },

  setSelectedDate: (date: string) => {
    set({ selectedDate: date });
  },

  loadPersistedTasks: async () => {
    const persisted = await storage.getItem<Task[]>(StorageKeys.TASKS_CACHE);
    if (persisted && persisted.length > 0) {
      set({ tasks: persisted });
    }
  },
}));

export default useTaskStore;
