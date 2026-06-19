/**
 * 应用颜色常量
 * 遵循界面设计规范，统一管理颜色值
 */
export class AppColors {
  // 主题色
  static readonly PRIMARY: string = '#1677FF';
  static readonly PRIMARY_DARK: string = '#0A3D8C';
  static readonly PRIMARY_LIGHT: string = '#E8F3FF';
  static readonly PRIMARY_BG: string = '#C6E2FF';

  // 功能色
  static readonly SUCCESS: string = '#00B42A';
  static readonly SUCCESS_LIGHT: string = '#E8FFEC';
  static readonly WARNING: string = '#FF7D00';
  static readonly WARNING_LIGHT: string = '#FFF3E6';
  static readonly DANGER: string = '#F5222D';
  static readonly DANGER_LIGHT: string = '#FFF0F0';
  static readonly INFO: string = '#13C2C2';
  static readonly INFO_LIGHT: string = '#E6FFFA';
  static readonly PURPLE: string = '#722ED1';
  static readonly PURPLE_LIGHT: string = '#F5EDFF';
  static readonly PINK: string = '#FF4081';
  static readonly PINK_LIGHT: string = '#FFE8F0';

  // 文字色
  static readonly TEXT_PRIMARY: string = '#1D2129';
  static readonly TEXT_SECONDARY: string = '#86909C';
  static readonly TEXT_TERTIARY: string = '#4E5969';
  static readonly TEXT_PLACEHOLDER: string = '#C9CDD4';

  // 深色模式文字色
  static readonly DARK_TEXT_PRIMARY: string = '#FFFFFF';
  static readonly DARK_TEXT_SECONDARY: string = '#CBD5E1';

  // 背景色
  static readonly BG_PAGE: string = '#F5F7FA';
  static readonly BG_CARD: string = '#FFFFFF';
  static readonly BG_DARK_PAGE: string = '#111827';
  static readonly BG_DARK_CARD: string = '#1F2937';
  static readonly BG_DARK_DIVIDER: string = '#374151';

  // 边框/分割线
  static readonly DIVIDER: string = '#F0F0F0';
  static readonly BORDER: string = '#E5E6EB';

  // 透明
  static readonly TRANSPARENT: string = '#00000000';

  // 行高倍数（设计规范：大标题1.2、中标题1.3、正文1.5、辅助文字1.4）
  static readonly LINE_HEIGHT_TITLE_L: number = 1.2;
  static readonly LINE_HEIGHT_TITLE_M: number = 1.3;
  static readonly LINE_HEIGHT_BODY: number = 1.5;
  static readonly LINE_HEIGHT_AUX: number = 1.4;
}
