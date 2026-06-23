import preferences from '@ohos.data.preferences';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

/**
 * 数据管理工具
 * - Preferences 轻量存储：用户信息、设置项、待办事项
 * - JSON 文件存储：课程表、成绩、收藏、失物招领等结构化数据
 * 遵循需求说明书 6.1节 数据存储方式要求
 */

const USER_PREFS = 'user_info';
const APP_PREFS = 'app_settings';
const TODO_PREFS = 'todo_data';
const TODO_FULL_PREFS = 'todo_full_data';

// JSON 文件名
const FILE_COURSES = 'courses.json';
const FILE_GRADES = 'grades.json';
const FILE_COLLECTIONS = 'collections.json';
const FILE_LOST_ITEMS = 'lost_items.json';
const FILE_FOODS = 'foods.json';
const FILE_SONGS = 'songs.json';

export interface UserInfoData {
  nickname: string;
  account: string;
  college: string;
  major: string;
}

export class DataManager {
  /**
   * ========== Preferences 存储 ==========
   */

  // 保存字符串
  static async saveString(prefsName: string, key: string, value: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), prefsName);
      await prefs.put(key, value);
      await prefs.flush();
    } catch (_err) {
      // 静默失败，不影响主流程
    }
  }

  // 读取字符串
  static async loadString(prefsName: string, key: string, defaultValue: string = ''): Promise<string> {
    try {
      const prefs = await preferences.getPreferences(getContext(), prefsName);
      return await prefs.get(key, defaultValue) as string;
    } catch (_err) {
      return defaultValue;
    }
  }

  // 保存布尔值
  static async saveBoolean(prefsName: string, key: string, value: boolean): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), prefsName);
      await prefs.put(key, value);
      await prefs.flush();
    } catch (_err) {
      // 静默失败
    }
  }

  // 读取布尔值
  static async loadBoolean(prefsName: string, key: string, defaultValue: boolean = false): Promise<boolean> {
    try {
      const prefs = await preferences.getPreferences(getContext(), prefsName);
      return await prefs.get(key, defaultValue) as boolean;
    } catch (_err) {
      return defaultValue;
    }
  }

  // ===== 用户信息 =====
  static async saveUserInfo(nickname: string, account: string, college: string, major: string): Promise<void> {
    await DataManager.saveString(USER_PREFS, 'nickname', nickname);
    await DataManager.saveString(USER_PREFS, 'account', account);
    await DataManager.saveString(USER_PREFS, 'college', college);
    await DataManager.saveString(USER_PREFS, 'major', major);
  }

  static async loadUserInfo(): Promise<UserInfoData> {
    const result: UserInfoData = {
      nickname: await DataManager.loadString(USER_PREFS, 'nickname', '校园助手用户'),
      account: await DataManager.loadString(USER_PREFS, 'account', '20260001'),
      college: await DataManager.loadString(USER_PREFS, 'college', '信息工程学院'),
      major: await DataManager.loadString(USER_PREFS, 'major', '软件工程')
    };
    return result;
  }

  // ===== 应用设置 =====
  static async saveSettingString(key: string, value: string): Promise<void> {
    await DataManager.saveString(APP_PREFS, key, value);
  }

  static async saveSettingBoolean(key: string, value: boolean): Promise<void> {
    await DataManager.saveBoolean(APP_PREFS, key, value);
  }

  static async loadSettingString(key: string, defaultVal: string): Promise<string> {
    return await DataManager.loadString(APP_PREFS, key, defaultVal);
  }

  static async loadSettingBoolean(key: string, defaultVal: boolean): Promise<boolean> {
    return await DataManager.loadBoolean(APP_PREFS, key, defaultVal);
  }

  // ===== 待办事项（Preferences JSON） =====
  static async saveTodos(todos: object[]): Promise<void> {
    await DataManager.saveString(TODO_PREFS, 'todos_json', JSON.stringify(todos));
  }

  static async loadTodos(): Promise<object[]> {
    const jsonStr: string = await DataManager.loadString(TODO_PREFS, 'todos_json', '[]');
    try {
      return JSON.parse(jsonStr);
    } catch (_err) {
      return [];
    }
  }

  static async saveTodosFull(todos: object[]): Promise<void> {
    await DataManager.saveString(TODO_FULL_PREFS, 'todos_json', JSON.stringify(todos));
  }

  static async loadTodosFull(): Promise<object[]> {
    const jsonStr: string = await DataManager.loadString(TODO_FULL_PREFS, 'todos_json', '[]');
    try {
      return JSON.parse(jsonStr);
    } catch (_err) {
      return [];
    }
  }

  static async saveAvatarUri(uri: string): Promise<void> {
    await DataManager.saveString(USER_PREFS, 'avatarUri', uri);
  }

  static async loadAvatarUri(): Promise<string> {
    return await DataManager.loadString(USER_PREFS, 'avatarUri', '');
  }

  /**
   * ========== JSON 文件存储 ==========
   */
  private static getFilePath(fileName: string): string {
    return getContext().filesDir + '/' + fileName;
  }

  static async saveJsonFile(fileName: string, data: object): Promise<void> {
    try {
      const filePath: string = DataManager.getFilePath(fileName);
      const content: string = JSON.stringify(data, null, 2);
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, content);
      fileIo.closeSync(file);
    } catch (err) {
      console.error('DataManager: 保存文件失败');
    }
  }

  static async loadJsonFile(fileName: string): Promise<object | null> {
    try {
      const filePath: string = DataManager.getFilePath(fileName);
      if (!fileIo.accessSync(filePath)) {
        return null;
      }
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(filePath);
      const buffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);

      // 使用 UTF-8 TextDecoder 正确解码中文
      const textDecoder = util.TextDecoder.create('utf-8');
      const content: string = textDecoder.decodeWithStream(new Uint8Array(buffer));
      return JSON.parse(content);
    } catch (err) {
      console.info('DataManager: 文件不存在或读取失败（首次运行正常现象）');
      return null;
    }
  }

  // ===== 便捷方法 =====
  static async saveCourses(courses: object[]): Promise<void> {
    await DataManager.saveJsonFile(FILE_COURSES, courses);
  }

  static async loadCourses(): Promise<object[]> {
    const result = await DataManager.loadJsonFile(FILE_COURSES);
    return result ? (result as object[]) : [];
  }

  static async saveGrades(grades: object[]): Promise<void> {
    await DataManager.saveJsonFile(FILE_GRADES, grades);
  }

  static async loadGrades(): Promise<object[]> {
    const result = await DataManager.loadJsonFile(FILE_GRADES);
    return result ? (result as object[]) : [];
  }

  static async saveCollections(collections: object[]): Promise<void> {
    await DataManager.saveJsonFile(FILE_COLLECTIONS, collections);
  }

  static async loadCollections(): Promise<object[]> {
    const result = await DataManager.loadJsonFile(FILE_COLLECTIONS);
    return result ? (result as object[]) : [];
  }

  static async saveLostItems(items: object[]): Promise<void> {
    await DataManager.saveJsonFile(FILE_LOST_ITEMS, items);
  }

  static async loadLostItems(): Promise<object[]> {
    const result = await DataManager.loadJsonFile(FILE_LOST_ITEMS);
    return result ? (result as object[]) : [];
  }

  static async saveFoods(foods: object[]): Promise<void> {
    await DataManager.saveJsonFile(FILE_FOODS, foods);
  }

  static async loadFoods(): Promise<object[]> {
    const result = await DataManager.loadJsonFile(FILE_FOODS);
    return result ? (result as object[]) : [];
  }

  // ===== 音乐播放器 =====
  static async saveSongs(songs: object[]): Promise<void> {
    await DataManager.saveJsonFile(FILE_SONGS, songs);
  }

  static async loadSongs(): Promise<object[]> {
    const result = await DataManager.loadJsonFile(FILE_SONGS);
    return result ? (result as object[]) : [];
  }

  // ===== 九宫格排序 =====
  static async saveGridOrder(titles: string[]): Promise<void> {
    await DataManager.saveString(APP_PREFS, 'grid_order', JSON.stringify(titles));
  }

  static async loadGridOrder(): Promise<string[]> {
    const jsonStr: string = await DataManager.loadString(APP_PREFS, 'grid_order', '[]');
    try {
      return JSON.parse(jsonStr);
    } catch (_err) {
      return [];
    }
  }

  /**
   * 清理所有缓存数据
   */
  static async clearAllCache(): Promise<void> {
    try {
      const context = getContext();
      const files: string[] = [FILE_COURSES, FILE_GRADES, FILE_COLLECTIONS, FILE_LOST_ITEMS, FILE_FOODS, FILE_SONGS];
      for (let i = 0; i < files.length; i++) {
        const filePath: string = context.filesDir + '/' + files[i];
        if (fileIo.accessSync(filePath)) {
          fileIo.unlinkSync(filePath);
        }
      }
      const todoPrefs = await preferences.getPreferences(getContext(), TODO_PREFS);
      await todoPrefs.clear();
      await todoPrefs.flush();

      const appPrefs = await preferences.getPreferences(getContext(), APP_PREFS);
      await appPrefs.clear();
      await appPrefs.flush();

      const todoFullPrefs = await preferences.getPreferences(getContext(), TODO_FULL_PREFS);
      await todoFullPrefs.clear();
      await todoFullPrefs.flush();
    } catch (err) {
      console.error('DataManager: 清理缓存失败');
    }
  }
}
