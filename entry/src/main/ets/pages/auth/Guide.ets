import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { GuideItem } from '../../common/constants/DataModels';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';

/**
 * 【2.2 引导页】首次打开APP时显示
 * 设计规范：
 * - 背景 #F5F7FA，上半部分60%引导图，下半部分40%文字说明
 * - 标题 32sp 鸿蒙蓝 #1677FF weight 700
 * - 说明 26sp 文字主色 #1D2129 行高1.5倍居中
 * - 页码指示器：3个圆形，当前鸿蒙蓝填充，其余淡灰描边
 * - 第三页「立即进入」按钮 48px高 8px圆角 80%宽 鸿蒙蓝背景 白色文字26sp
 * - 支持触摸滑动 + 点击指示器跳转
 */
@Entry
@Component
struct Guide {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .opacity(0)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .opacity(0)
  }
  @State currentIndex: number = 0;
  @State statusBarHeight: number = 0;
  private swiperController: SwiperController = new SwiperController();

  private guides: GuideItem[] = [
    {
      title: '校园信息，实时掌握',
      desc: '校园公告、资讯、地图，一手了解校园动态',
      icon: '📢',
      bgColor: AppColors.PRIMARY_LIGHT
    },
    {
      title: '学习助手，高效备考',
      desc: '课程表、成绩查询、图书馆检索，助力学业提升',
      icon: '📚',
      bgColor: AppColors.SUCCESS_LIGHT
    },
    {
      title: '生活服务，贴心相伴',
      desc: '失物招领、校园美食、音乐播放，丰富校园生活',
      icon: '❤️',
      bgColor: AppColors.WARNING_LIGHT
    }
  ];

  async aboutToAppear(): Promise<void> {
    console.info('Guide页面 aboutToAppear - 引导页即将显示');
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
  }

  aboutToDisappear(): void {
    console.info('Guide页面 aboutToDisappear - 引导页即将销毁');
  }

  build() {
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(this.statusBarHeight)
        .backgroundColor(AppColors.BG_PAGE)
      // 顶部跳过按钮
      Row() {
        Blank()
        Text('跳过引导')
          .fontSize(24)
          .fontColor(AppColors.TEXT_SECONDARY)
          .padding({ top: 12, bottom: 12, left: 16, right: 16 })
          .onClick(() => {
            this.navigateToLogin();
          })
      }
      .width('100%')
      .padding({ right: 8, top: 8 })

      // 滑动区域
      Swiper(this.swiperController) {
        ForEach(this.guides, (item: GuideItem) => {
          Column({ space: 0 }) {
            // 上半部分60%：引导图
            Column() {
              Text(item.icon)
                .fontSize(32)
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
                .backgroundColor(item.bgColor)
                .borderRadius(8)
            }
            .width('78%')
            .height('60%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 16 })

            // 下半部分40%：文字
            Column({ space: 16 }) {
              Text(item.title)
                .fontSize(32)
                .fontWeight(700)
                .fontColor(AppColors.PRIMARY)
                .textAlign(TextAlign.Center)

              Text(item.desc)
                .fontSize(26)
                .lineHeight(39)
                .fontColor(AppColors.TEXT_PRIMARY)
                .textAlign(TextAlign.Center)
                .padding({ left: 40, right: 40 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('100%')
        })
      }
      .index(this.currentIndex)
      .loop(false)
      .indicator(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .layoutWeight(1)

      // 底部控制区
      Column({ space: 24 }) {
        // 页码指示器 - 3个圆形
        Row({ space: 14 }) {
          ForEach([0, 1, 2], (index: number) => {
            Circle()
              .width(12)
              .height(12)
              .fill(this.currentIndex === index ? AppColors.PRIMARY : Color.Transparent)
              .stroke(this.currentIndex === index ? Color.Transparent : '#E5E6EB')
              .strokeWidth(2)
              .animation({ duration: 300, curve: Curve.EaseInOut })
              .onClick(() => {
                this.currentIndex = index;
                this.swiperController.changeIndex(index);
              })
          })
        }

        // 按钮区域
        if (this.currentIndex === 2) {
          Button('立即进入')
            .width('80%')
            .height(48)
            .fontSize(26)
            .fontColor(AppColors.BG_CARD)
            .backgroundColor(AppColors.PRIMARY)
            .borderRadius(8)
            .shadow({ radius: 12, color: AppColors.PRIMARY_DARK, offsetX: 0, offsetY: 4 })
            .onClick(() => {
              this.navigateToLogin();
            })
        } else {
          Button('下一步')
            .width('70%')
            .height(48)
            .fontSize(26)
            .fontColor(AppColors.PRIMARY)
            .backgroundColor(AppColors.PRIMARY_LIGHT)
            .borderRadius(8)
            .onClick(() => {
              this.currentIndex += 1;
              this.swiperController.changeIndex(this.currentIndex);
            })
        }

        Blank().height(8)
      }
      .width('100%')
      .padding({ bottom: 36 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private navigateToLogin(): void {
    router.replaceUrl({
      url: 'pages/auth/Login',
      params: { fromGuide: true }
    });
  }
}
