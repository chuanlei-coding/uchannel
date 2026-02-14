import apiClient from './client';

/**
 * 统计数据接口
 */
export interface OverviewStats {
  totalTasks: number;
  completedTasks: number;
  pendingTasks: number;
  completionRate: number;
}

export interface WeeklyStats {
  weeklyTotal: number;
  weeklyCompleted: number;
  completionRate: number;
  weeklyData: Array<{
    date: string;
    total: number;
    completed: number;
  }>;
}

export interface CategoryStats {
  category: string;
  count: number;
  color: string;
}

export interface PriorityStats {
  priority: string;
  count: number;
  color: string;
}

export interface HeatmapData {
  date: string;
  count: number;
  level: number;
}

export interface FocusTimeStats {
  totalMinutes: number;
  averageMinutes: number;
  dailyData: Array<{
    date: string;
    minutes: number;
  }>;
}

/**
 * 统计 API 服务
 */
class StatsApiService {
  /**
   * 统计数据概览
   */
  async getOverviewStats(): Promise<OverviewStats | null> {
    try {
      const response = await apiClient.get('/stats/overview');

      if (response.status === 200 && response.data.success) {
        return response.data.stats as OverviewStats;
      }
    } catch (error) {
      console.error('Failed to get overview stats:', error);
    }
    return null;
  }

  /**
   * 本周统计数据
   */
  async getWeeklyStats(): Promise<WeeklyStats | null> {
    try {
      const response = await apiClient.get('/stats/weekly');

      if (response.status === 200 && response.data.success) {
        return {
          weeklyTotal: response.data.weeklyTotal,
          weeklyCompleted: response.data.weeklyCompleted,
          completionRate: response.data.completionRate,
          weeklyData: response.data.weeklyData,
        };
      }
    } catch (error) {
      console.error('Failed to get weekly stats:', error);
    }
    return null;
  }

  /**
   * 分类统计数据
   */
  async getCategoryStats(): Promise<CategoryStats[]> {
    try {
      const response = await apiClient.get('/stats/category');

      if (response.status === 200 && response.data.success) {
        return response.data.categories as CategoryStats[];
      }
    } catch (error) {
      console.error('Failed to get category stats:', error);
    }
    return [];
  }

  /**
   * 优先级统计数据
   */
  async getPriorityStats(): Promise<PriorityStats[]> {
    try {
      const response = await apiClient.get('/stats/priority');

      if (response.status === 200 && response.data.success) {
        return response.data.priorities as PriorityStats[];
      }
    } catch (error) {
      console.error('Failed to get priority stats:', error);
    }
    return [];
  }

  /**
   * 热力图数据
   */
  async getHeatmapData(days: number = 28): Promise<HeatmapData[]> {
    try {
      const response = await apiClient.get('/stats/heatmap', {
        params: { days },
      });

      if (response.status === 200 && response.data.success) {
        return response.data.data as HeatmapData[];
      }
    } catch (error) {
      console.error('Failed to get heatmap data:', error);
    }
    return [];
  }

  /**
   * 专注时长统计
   */
  async getFocusTimeStats(days: number = 7): Promise<FocusTimeStats | null> {
    try {
      const response = await apiClient.get('/stats/focus-time', {
        params: { days },
      });

      if (response.status === 200 && response.data.success) {
        return response.data.focusTime as FocusTimeStats;
      }
    } catch (error) {
      console.error('Failed to get focus time stats:', error);
    }
    return null;
  }
}

export default new StatsApiService();
