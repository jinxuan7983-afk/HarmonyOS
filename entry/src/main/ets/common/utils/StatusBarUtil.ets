import { window } from '@kit.ArkUI';

/**
 * 状态栏高度工具
 * 消除各页面重复的 getStatusBarHeight() 方法
 */
export class StatusBarUtil {
  static async getStatusBarHeight(context: Context | undefined): Promise<number> {
    try {
      if (!context) {
        return 8;
      }
      const win = await window.getLastWindow(context);
      const area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      if (area && area.topRect && area.topRect.height > 0) {
        return area.topRect.height / 4;
      }
      return 8;
    } catch (_) {
      return 8;
    }
  }
}
