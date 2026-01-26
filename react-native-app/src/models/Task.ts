export interface Task {
  id: string;
  title: string;
  description?: string;
  time: string;
  tags: string[];
  isCompleted: boolean;
}
