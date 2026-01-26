import axios from 'axios';
import {Message} from '../models/Message';

const API_BASE_URL = 'http://localhost:8080'; // 根据实际情况修改

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const chatApi = {
  sendMessage: async (message: string, conversationId?: string) => {
    const response = await api.post('/api/chat/send', {
      message,
      conversationId,
    });
    return response.data;
  },

  getHistory: async (conversationId: string) => {
    const response = await api.get(`/api/chat/history/${conversationId}`);
    return response.data;
  },
};

export default api;
