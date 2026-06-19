/**
 * 统一数据模型接口定义
 * 消除各页面重复定义的 interface
 */

// ===== 校园信息 =====
export interface NewsItem {
  title: string;
  category: string;
  subCategory?: string;
  time: string;
  summary: string;
}

// ===== 课程 =====
export interface CourseItem {
  name: string;
  teacher: string;
  day: string;
  time: string;
  place: string;
  credits: string;
  color: string;
  remindOn: boolean;
}

// ===== 成绩 =====
export interface GradeItem {
  name: string;
  score: string;
  point: string;
  examTime: string;
}

// ===== 图书 =====
export interface BookItem {
  name: string;
  author: string;
  isbn: string;
  location: string;
  count: number;
  status: string;
}

// ===== 失物招领 =====
export interface LostItem {
  title: string;
  type: string;
  category: string;
  place: string;
  time: string;
  desc: string;
  phone: string;
  imageUri: string;
}

// ===== 美食 =====
export interface FoodItem {
  name: string;
  place: string;
  feature: string;
  score: number;
  collected: boolean;
  imageUri: string;
}

// ===== 音乐 =====
export interface SongItem {
  name: string;
  singer: string;
  duration: number;
  uri: string;
}

// ===== 待办（首页简化版） =====
export interface TodoItem {
  title: string;
  done: boolean;
}

// ===== 待办（个人中心增强版） =====
export interface TodoItemFull {
  id: number;
  title: string;
  category: string;
  done: boolean;
  remindTime: string;
}

// ===== 收藏 =====
export interface CollectionItem {
  title: string;
  category: string;
  time: string;
  detail: string;
}

// ===== 校园建筑 =====
export interface Building {
  name: string;
  icon: string;
  desc: string;
  position: string;
  x: number;
  y: number;
}

// ===== 消息 =====
export interface MessageItem {
  title: string;
  content: string;
  time: string;
  type: string;
  read: boolean;
}

// ===== 学习资料 =====
export interface MaterialItem {
  name: string;
  icon: string;
}

// ===== 快捷入口 =====
export interface QuickAction {
  title: string;
  icon: Resource;
  iconColor: string;
  bgColor: string;
  url: string;
}

// ===== 引导页 =====
export interface GuideItem {
  title: string;
  desc: string;
  icon: string;
  bgColor: string;
}

// ===== Tab配置 =====
export interface TabConfig {
  icon: string;
  label: string;
  url: string;
}
