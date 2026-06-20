import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

/**
 * 【3.1.1 应用入口】EntryAbility - Stage模型主入口
 * 负责：沉浸式窗口、主窗口属性设置、窗口大小自适应、
 * 悬浮窗管理、应用前后台生命周期管理
 */
const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private windowStage?: window.WindowStage;
  private mainWindow?: window.Window;
  private floatWindow?: window.Window;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, '=== Ability onCreate ===');
    try {
      // 设置颜色模式为跟随系统（浅色/深色自动切换）
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '=== Ability onDestroy === 释放所有资源');
    // 释放悬浮窗资源
    this.mainWindow = undefined;
    this.windowStage = undefined;
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, '=== Ability onWindowStageCreate ===');
    this.windowStage = windowStage;

    // 获取主窗口并设置沉浸式效果
    windowStage.getMainWindow().then((mainWindow: window.Window) => {
      this.mainWindow = mainWindow;

      // 【3.1.1 沉浸式窗口】设置窗口全屏布局，实现启动页沉浸式体验
      mainWindow.setWindowLayoutFullScreen(true).then(() => {
        hilog.info(DOMAIN, TAG, '沉浸式全屏模式已启用');
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, 'setWindowLayoutFullScreen failed: %{public}s', JSON.stringify(err));
      });

      // 【3.1.1 主窗口设置】设置窗口属性，适配移动端不同屏幕尺寸
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',        // 透明状态栏
        navigationBarColor: '#00000000',    // 透明导航栏
        isStatusBarLightIcon: false,        // 启动页白色图标
        isNavigationBarLightIcon: false
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, 'setWindowSystemBarProperties failed: %{public}s', JSON.stringify(err));
      });

      // 【3.1.1 窗口自适应】监听窗口大小变化，适配不同屏幕尺寸
      mainWindow.on('windowSizeChange', (size: window.Size) => {
        hilog.info(DOMAIN, TAG, '窗口大小变化: width=%{public}d, height=%{public}d',
          size.width, size.height);
        // 根据窗口大小动态调整UI布局方向
        this.adjustLayoutForSize(size);
      });

    }).catch((err: Error) => {
      // 错误码1300002在预览器/模拟器中常见，不影响实际运行
      hilog.warn(DOMAIN, TAG, 'getMainWindow failed (may be previewer): %{public}s', JSON.stringify(err));
    });

    // 加载启动页
    windowStage.loadContent('pages/home/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, '启动页加载成功');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, '=== Ability onWindowStageDestroy === 释放窗口资源');
    // 窗口资源由系统自动回收，无需手动 off 事件监听
    this.mainWindow = undefined;
  }

  // 【3.1.1 生命周期管理】应用进入前台
  onForeground(): void {
    hilog.info(DOMAIN, TAG, '=== Ability onForeground === 应用回到前台');
    // 前台时可以关闭悬浮窗，恢复主窗口显示
    this.hideFloatingWindow();
    // 恢复沉浸式状态栏设置
    if (this.mainWindow) {
      this.mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        isStatusBarLightIcon: false,
        isNavigationBarLightIcon: false
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, 'restore status bar failed: %{public}s', JSON.stringify(err));
      });
    }
  }

  // 【3.1.1 生命周期管理】应用进入后台
  onBackground(): void {
    hilog.info(DOMAIN, TAG, '=== Ability onBackground === 应用进入后台');
    // 后台时展示悬浮窗，显示核心待办信息
    this.showFloatingWindow();
  }

  /**
   * 【3.1.1 悬浮窗功能】在应用后台时显示校园待办悬浮窗
   */
  private async showFloatingWindow(): Promise<void> {
    try {
      if (!this.mainWindow) {
        hilog.warn(DOMAIN, TAG, 'mainWindow未初始化，无法创建悬浮窗');
        return;
      }
      // 如果已有悬浮窗，先销毁
      if (this.floatWindow) {
        await this.floatWindow.destroyWindow();
        this.floatWindow = undefined;
      }
      // 使用主窗口上下文创建悬浮子窗口
      this.floatWindow = await window.createWindow({
        name: 'campus_todo_float',
        windowType: window.WindowType.TYPE_FLOAT,
        ctx: this.context
      });
      // 加载悬浮窗UI内容 - 显示待办信息
      await this.floatWindow.setUIContent('pages/life/TodoFloat');
      await this.floatWindow.showWindow();

      hilog.info(DOMAIN, TAG, '校园待办悬浮窗已显示');
    } catch (err) {
      hilog.error(DOMAIN, TAG, '悬浮窗创建失败: %{public}s', JSON.stringify(err));
    }
  }

  private async hideFloatingWindow(): Promise<void> {
    try {
      if (this.floatWindow) {
        await this.floatWindow.destroyWindow();
        this.floatWindow = undefined;
        hilog.info(DOMAIN, TAG, '校园待办悬浮窗已销毁');
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, '关闭悬浮窗异常: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 【3.1.1 窗口自适应】根据屏幕尺寸调整布局参数
   */
  private adjustLayoutForSize(size: window.Size): void {
    // 判断是否为小屏设备（宽度 < 360vp）
    const isSmallScreen = size.width < 360;
    const isLargeScreen = size.width > 600;

    // 写入 AppStorage 供全局页面响应
    AppStorage.setOrCreate('isSmallScreen', isSmallScreen);
    AppStorage.setOrCreate('isLargeScreen', isLargeScreen);
    AppStorage.setOrCreate('windowWidth', size.width);
    AppStorage.setOrCreate('windowHeight', size.height);

    if (isSmallScreen) {
      hilog.info(DOMAIN, TAG, '检测到小屏设备，启用紧凑布局');
    } else if (isLargeScreen) {
      hilog.info(DOMAIN, TAG, '检测到大屏设备，启用宽屏布局');
    }
    // 实际布局调整由各页面通过获取窗口宽度来实现自适应
  }
}
