import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';
import { DataManager } from '../../utils/DataManager';

/**
 * 设置页
 * - 深色模式、字体大小、通知设置、清理缓存、关于我们
 * - 使用 DataManager 持久化设置
 * - 使用 AppStorage 实现全局深色模式/字体缩放
 */
@Entry
@Component
struct Settings {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State selectedFont: string = 'normal';
  @State courseNotice: boolean = true;
  @State announcementNotice: boolean = true;
  @State todoNotice: boolean = true;
  @State showNoticeExpand: boolean = false;
  @State cacheSize: string = '64.2MB';
  @State showCacheDialog: boolean = false;
  @State showAboutDialog: boolean = false;
  @State statusBarHeight: number = 0;

  async aboutToAppear(): Promise<void> {
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
    this.darkMode = await DataManager.loadSettingBoolean('darkMode', false);
    this.selectedFont = await DataManager.loadSettingString('fontSize', 'normal');
    const fontScaleMap: Record<string, number> = { 'small': 0.85, 'normal': 1.0, 'large': 1.2 };
    this.fontScale = fontScaleMap[this.selectedFont] || 1.0;
    this.courseNotice = await DataManager.loadSettingBoolean('courseNotice', true);
    this.announcementNotice = await DataManager.loadSettingBoolean('announcementNotice', true);
    this.todoNotice = await DataManager.loadSettingBoolean('todoNotice', true);
  }

  build() {
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(this.statusBarHeight)
        .backgroundColor(ThemeUtil.cardBg(this.darkMode))
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor(AppColors.PRIMARY)
          .onClick(() => router.back())
        Text('设置')
          .fontSize(30 * this.fontScale).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
          .margin({ left: 8 }).layoutWeight(1)
      }
      .width('100%').height(52).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Scroll() {
        Column({ space: 20 }) {
          // 设置项卡片
          Column({ space: 0 }) {
            // 深色模式
            Row() {
              Text('🌙').fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
              Text('深色模式').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                .layoutWeight(1).margin({ left: 10 })
              Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
                .selectedColor(AppColors.PRIMARY)
                .onChange((v: boolean) => {
                  this.darkMode = v;
                  DataManager.saveSettingBoolean('darkMode', v);
                })
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')

            // 字体大小
            Row() {
              Text('🔤').fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
              Text('字体大小').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                .layoutWeight(1).margin({ left: 10 })
              Row({ space: 16 }) {
                ForEach(['小', '中', '大'], (label: string, index: number) => {
                  Row({ space: 4 }) {
                    Radio({ value: `radio_${index}`, group: 'fontGroup' })
                      .checked(this.selectedFont === ['small', 'normal', 'large'][index])
                      .radioStyle({ checkedBackgroundColor: AppColors.PRIMARY })
                      .width(22).height(22)
                    Text(label).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                  }
                  .onClick(() => {
                    const vals = ['small', 'normal', 'large'];
                    const scales = [0.85, 1.0, 1.2];
                    this.selectedFont = vals[index];
                    this.fontScale = scales[index];
                    DataManager.saveSettingString('fontSize', vals[index]);
                  })
                })
              }
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')

            // 通知设置
            Row() {
              Text('🔔').fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
              Text('通知设置').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                .layoutWeight(1).margin({ left: 10 })
              Text(this.showNoticeExpand ? '▲' : '▼')
                .fontSize(22).fontColor(AppColors.PRIMARY)
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            .onClick(() => { this.showNoticeExpand = !this.showNoticeExpand; })

            // 通知子项
            if (this.showNoticeExpand) {
              // 课程提醒
              Row() {
                Text('课程提醒').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                  .layoutWeight(1).margin({ left: 38 })
                Toggle({ type: ToggleType.Switch, isOn: this.courseNotice })
                  .selectedColor(AppColors.PRIMARY)
                  .onChange((v: boolean) => {
                    this.courseNotice = v;
                    DataManager.saveSettingBoolean('courseNotice', v);
                  })
              }
              .width('100%').height(48).padding({ left: 16, right: 16 })
              Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')

              // 公告提醒
              Row() {
                Text('公告提醒').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                  .layoutWeight(1).margin({ left: 38 })
                Toggle({ type: ToggleType.Switch, isOn: this.announcementNotice })
                  .selectedColor(AppColors.PRIMARY)
                  .onChange((v: boolean) => {
                    this.announcementNotice = v;
                    DataManager.saveSettingBoolean('announcementNotice', v);
                  })
              }
              .width('100%').height(48).padding({ left: 16, right: 16 })
              Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')

              // 待办提醒
              Row() {
                Text('待办提醒').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                  .layoutWeight(1).margin({ left: 38 })
                Toggle({ type: ToggleType.Switch, isOn: this.todoNotice })
                  .selectedColor(AppColors.PRIMARY)
                  .onChange((v: boolean) => {
                    this.todoNotice = v;
                    DataManager.saveSettingBoolean('todoNotice', v);
                  })
              }
              .width('100%').height(48).padding({ left: 16, right: 16 })
            }
            Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')

            // 清理缓存
            Row() {
              Text('🗑').fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
              Text('清理缓存').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                .layoutWeight(1).margin({ left: 10 })
              Text(this.cacheSize).fontSize(24 * this.fontScale).fontColor(AppColors.TEXT_SECONDARY)
              Text('清理').fontSize(24 * this.fontScale).fontColor(AppColors.BG_CARD)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .backgroundColor(AppColors.WARNING).borderRadius(8)
                .margin({ left: 10 })
                .onClick(() => { this.showCacheDialog = true; })
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')

            // 关于我们
            Row() {
              Text('ℹ').fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
              Text('关于我们').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                .layoutWeight(1).margin({ left: 10 })
              Text('›').fontSize(26 * this.fontScale).fontColor(AppColors.PRIMARY)
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            .onClick(() => { this.showAboutDialog = true; })
          }
          .width('100%').backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          .padding({ top: 6, bottom: 6 })

          // 底部版本号
          Text('V1.0.0（HarmonyOS NEXT）')
            .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
            .width('100%').textAlign(TextAlign.Center).margin({ top: 16 })
        }
        .width('100%').padding({ left: 20, right: 20, top: 16, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      // 缓存清理确认弹窗
      if (this.showCacheDialog) {
        this.CacheDialog()
      }

      // 关于我们弹窗
      if (this.showAboutDialog) {
        this.AboutDialog()
      }
    }
    .width('100%').height('100%').backgroundColor(ThemeUtil.pageBg(this.darkMode))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // ===== 缓存清理确认弹窗 =====
  @Builder
  CacheDialog() {
    Column() {
      Column({ space: 18 }) {
        Text('🗑 清理缓存').fontSize(28).fontWeight(700).fontColor(AppColors.TEXT_PRIMARY)
        Text('确定要清理本地缓存吗？\n将清除图片、音频及数据文件。').fontSize(24).fontColor(AppColors.TEXT_TERTIARY)
          .lineHeight(36).textAlign(TextAlign.Center)
        Text(`当前缓存：${this.cacheSize}`).fontSize(22).fontColor(AppColors.TEXT_SECONDARY)
        Row({ space: 12 }) {
          Button('取消').layoutWeight(1).height(48).fontSize(26).fontColor(AppColors.TEXT_SECONDARY)
            .backgroundColor(AppColors.DIVIDER).borderRadius(8)
            .onClick(() => { this.showCacheDialog = false; })
          Button('确认清理').layoutWeight(1).height(48).fontSize(26).fontColor(AppColors.BG_CARD)
            .backgroundColor(AppColors.WARNING).borderRadius(8)
            .onClick(() => {
              this.cacheSize = '0MB';
              this.showCacheDialog = false;
              DataManager.clearAllCache();
              this.getUIContext()?.getPromptAction()?.showToast({ message: '缓存已清理完成' });
            })
        }
        .width('100%')
      }
      .width('80%').padding(24).backgroundColor(AppColors.BG_CARD).borderRadius(12)
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('#66000000')
    .onClick(() => { this.showCacheDialog = false; })
  }

  // ===== 关于我们弹窗 =====
  @Builder
  AboutDialog() {
    Column() {
      Column({ space: 18 }) {
        Text('ℹ 关于我们').fontSize(28).fontWeight(700).fontColor(AppColors.TEXT_PRIMARY)
        Text('高校校园助手').fontSize(26).fontWeight(FontWeight.Bold).fontColor(AppColors.TEXT_PRIMARY)
        Text('版本号：V1.0.0').fontSize(24).fontColor(AppColors.TEXT_TERTIARY)
        Text('开发团队：信息工程学院 软件工程').fontSize(24).fontColor(AppColors.TEXT_TERTIARY)
          .lineHeight(36).textAlign(TextAlign.Center)
        Text('基于 HarmonyOS NEXT 开发的校园综合服务应用，致力于为师生提供便捷的校园信息服务。')
          .fontSize(22).fontColor(AppColors.TEXT_SECONDARY).lineHeight(34).textAlign(TextAlign.Center)
        Button('确定').width('100%').height(48).fontSize(26).fontColor(AppColors.BG_CARD)
          .backgroundColor(AppColors.PRIMARY).borderRadius(8)
          .onClick(() => { this.showAboutDialog = false; })
      }
      .width('80%').padding(24).backgroundColor(AppColors.BG_CARD).borderRadius(12)
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('#66000000')
    .onClick(() => { this.showAboutDialog = false; })
  }
}
