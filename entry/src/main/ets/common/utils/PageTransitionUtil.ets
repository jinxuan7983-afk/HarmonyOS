/**
 * 页面过渡动画工具
 * 消除各页面重复的 pageTransition() 定义
 */
export class PageTransitionUtil {
  /**
   * 淡入淡出过渡（适用于同级页面切换）
   */
  static fadeTransition() {
    return {
      enter: PageTransitionEnter({ duration: 250, curve: Curve.EaseInOut }).opacity(0),
      exit: PageTransitionExit({ duration: 250, curve: Curve.EaseInOut }).opacity(0)
    };
  }

  /**
   * 右滑进入过渡（适用于子页面进入）
   */
  static slideTransition() {
    return {
      enter: PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut }).slide(SlideEffect.Right),
      exit: PageTransitionExit({ duration: 300, curve: Curve.EaseInOut }).slide(SlideEffect.Left)
    };
  }
}
