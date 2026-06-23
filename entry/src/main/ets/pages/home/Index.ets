import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import { AppColors } from '../../common/constants/AppColors';

/**
 * 【3.1.1 启动页】沉浸式启动界面
 * - 展示APP名称、logo，实现Stage模型窗口沉浸式能力
 * - 首次启动跳转引导页，非首次跳过引导
 * - 已登录用户直接进入首页
 */
@Entry
@Component
struct Index {
  @State fadeOpacity: number = 0;
  private launchChecked: boolean = false;
  private redirectTarget: string = 'pages/auth/Guide';
  private redirectTimer: number = 0;

  aboutToAppear() {
    // 淡入动画
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.fadeOpacity = 1;
    });

    // 检查首次启动状态和登录状态
    this.checkLaunchState();
  }

  aboutToDisappear(): void {
    if (this.redirectTimer !== 0) {
      clearTimeout(this.redirectTimer);
      this.redirectTimer = 0;
    }
  }

  /**
   * 检查启动状态 → 决定目标页面
   * - 首次启动 → Guide引导页
   * - 非首次 + 未登录 → Login登录页
   * - 非首次 + 已登录 → Home首页
   */
  private async checkLaunchState(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_info');
      const isLoggedIn = await prefs.get('loggedIn', false);
      const hasLaunched = await prefs.get('hasLaunched', false);

      if (isLoggedIn) {
        // 已登录 → 直接进首页
        this.redirectTarget = 'pages/home/Home';
        console.info('Index: 用户已登录，跳过引导直接进入首页');
      } else if (hasLaunched) {
        // 非首次但未登录 → 去登录页
        this.redirectTarget = 'pages/auth/Login';
        console.info('Index: 非首次启动，跳转登录页');
      } else {
        // 首次启动 → 去引导页
        this.redirectTarget = 'pages/auth/Guide';
        console.info('Index: 首次启动，跳转引导页');
        // 标记已启动过
        await prefs.put('hasLaunched', true);
        await prefs.flush();
      }

      this.launchChecked = true;
      // 最短停留1.8秒后跳转，保证启动页动画完成
      this.scheduleRedirect();
    } catch (_err) {
      // Preferences失败，默认去Guide
      this.redirectTarget = 'pages/auth/Guide';
      this.launchChecked = true;
      this.scheduleRedirect();
    }
  }

  private scheduleRedirect(): void {
    this.redirectTimer = setTimeout(() => {
      if (this.redirectTarget) {
        router.replaceUrl({
          url: this.redirectTarget
        });
      }
    }, 3000);
  }

  build() {
    Column() {
      // 顶部留白
      Blank()
        .height('18%')

      // 中心内容区
      Column({ space: 20 }) {
        Image($r('app.media.startIcon'))
          .width(120)
          .height(120)
          .borderRadius(8)
          .opacity(this.fadeOpacity)
          .scale({ x: this.fadeOpacity, y: this.fadeOpacity })
          .shadow({
            radius: 30,
            color: AppColors.PRIMARY_DARK,
            offsetX: 0,
            offsetY: 8
          })

        Column({ space: 8 }) {
          Text('高校校园助手')
            .fontSize(36)
            .fontWeight(700)
            .fontColor(AppColors.BG_CARD)
            .opacity(this.fadeOpacity)
            .textShadow({
              radius: 8,
              color: '#0A3050',
              offsetX: 0,
              offsetY: 2
            })

          Text('HarmonyOS NEXT 版')
            .fontSize(24)
            .fontWeight(400)
            .fontColor(AppColors.PRIMARY_LIGHT)
            .opacity(this.fadeOpacity)
            .letterSpacing(2)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .alignItems(HorizontalAlign.Center)

      Blank()
        .layoutWeight(1)

      // 底部加载指示器 + 跳过按钮
      Column({ space: 12 }) {
        // 白色环形进度条
        LoadingProgress()
          .width(36)
          .height(36)
          .color(AppColors.BG_CARD)

        Text('高校校园助手 APP 开发团队')
          .fontSize(22)
          .fontColor(AppColors.PRIMARY_LIGHT)
          .opacity(this.fadeOpacity)

        // 跳过按钮（点击直接跳转）
        Text('跳过启动页 ›')
          .fontSize(24)
          .fontColor(AppColors.BG_CARD)
          .opacity(0.7)
          .margin({ top: 8 })
          .padding({ top: 8, bottom: 8, left: 16, right: 16 })
          .onClick(() => {
            this.doRedirect();
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      angle: 160,
      colors: [
        [AppColors.PRIMARY, 0],
        ['#4096FF', 1]
      ]
    })
    .onClick(() => {
      this.doRedirect();
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private doRedirect(): void {
    if (this.redirectTimer !== 0) {
      clearTimeout(this.redirectTimer);
      this.redirectTimer = 0;
    }
    if (this.redirectTarget) {
      router.replaceUrl({ url: this.redirectTarget });
    }
  }
}
