import { AppColors } from '../constants/AppColors';

/**
 * 主题工具
 * 提供深色/浅色模式下的颜色获取方法
 * 消除各页面重复的 titleColor()/subColor()/cardBg() 方法
 */
export class ThemeUtil {
  static titleColor(darkMode: boolean): string {
    return darkMode ? AppColors.DARK_TEXT_PRIMARY : AppColors.TEXT_PRIMARY;
  }

  static subColor(darkMode: boolean): string {
    return darkMode ? AppColors.DARK_TEXT_SECONDARY : AppColors.TEXT_SECONDARY;
  }

  static cardBg(darkMode: boolean): string {
    return darkMode ? AppColors.BG_DARK_CARD : AppColors.BG_CARD;
  }

  static pageBg(darkMode: boolean): string {
    return darkMode ? AppColors.BG_DARK_PAGE : AppColors.BG_PAGE;
  }

  static dividerColor(darkMode: boolean): string {
    return darkMode ? AppColors.BG_DARK_DIVIDER : AppColors.DIVIDER;
  }
}
