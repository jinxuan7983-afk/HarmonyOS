import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';

/**
 * 【校园地图 · 建筑详情页】
 * 设计规范：导航栏30sp、中标题28sp、正文26sp、辅助文字24sp
 * 展示校园建筑完整信息：地图预览 + 建筑名称/位置/描述 + 设施信息 + 导航按钮
 */
interface BuildingDetailParams {
  name: string;
  icon: string;
  desc: string;
  position: string;
  x: number;
  y: number;
}

interface FacilityItem {
  icon: string;
  label: string;
  value: string;
}

@Entry
@Component
struct MapDetail {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }

  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State statusBarHeight: number = 0;
  @State name: string = '';
  @State icon: string = '';
  @State desc: string = '';
  @State buildingPosition: string = '';
  @State x: number = 0;
  @State y: number = 0;

  async aboutToAppear(): Promise<void> {
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
    const params = router.getParams() as BuildingDetailParams;
    if (params) {
      this.name = params.name || '未命名建筑';
      this.icon = params.icon || '🏫';
      this.desc = params.desc || '';
      this.buildingPosition = params.position || '';
      this.x = params.x ?? 0;
      this.y = params.y ?? 0;
    }
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
        Text('建筑详情')
          .fontSize(30).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
          .margin({ left: 8 }).layoutWeight(1)
      }
      .width('100%').height(52).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Scroll() {
        Column({ space: 16 }) {
          // 地图预览区
          Stack() {
            Image($r('app.media.background'))
              .width('100%').height(220)
              .objectFit(ImageFit.Cover).borderRadius(8)
              .opacity(0.4)

            // 建筑标记
            Column({ space: 6 }) {
              Text(this.icon).fontSize(40)
              Text(this.name)
                .fontSize(26 * this.fontScale).fontWeight(600)
                .fontColor(AppColors.BG_CARD)
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor('#66000000').borderRadius(8)
            }
            .width('100%').height('100%')
            .justifyContent(FlexAlign.Center)

            // 位置标签
            Row() {
              SymbolGlyph($r('sys.symbol.map'))
                .fontSize(18).fontColor([AppColors.BG_CARD])
              Text(this.buildingPosition)
                .fontSize(22 * this.fontScale).fontColor(AppColors.BG_CARD)
                .margin({ left: 4 })
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#66000000').borderRadius(16)
            .position({ x: 12, y: 12 })
          }
          .width('100%').height(220).borderRadius(8)

          // 建筑信息卡片
          Column({ space: 16 }) {
            Row({ space: 12 }) {
              Text(this.icon)
                .fontSize(28)
                .width(48).height(48).textAlign(TextAlign.Center)
                .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(24)
              Column({ space: 4 }) {
                Text(this.name)
                  .fontSize(28 * this.fontScale).fontWeight(600)
                  .fontColor(ThemeUtil.titleColor(this.darkMode))
                  .lineHeight(28 * this.fontScale * AppColors.LINE_HEIGHT_TITLE_M)
                Text(`${this.buildingPosition} · 坐标(${this.x}%, ${this.y}%)`)
                  .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)
            }
            .width('100%')

            Divider().color(AppColors.DIVIDER).strokeWidth(1).width('100%')

            Text('建筑简介')
              .fontSize(26 * this.fontScale).fontWeight(600)
              .fontColor(ThemeUtil.titleColor(this.darkMode))
              .width('100%')

            Text(this.desc)
              .fontSize(26 * this.fontScale)
              .fontColor(ThemeUtil.subColor(this.darkMode))
              .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
              .width('100%')
          }
          .width('100%').padding(16)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

          // 设施信息
          Column({ space: 12 }) {
            Text('设施信息')
              .fontSize(26 * this.fontScale).fontWeight(600)
              .fontColor(ThemeUtil.titleColor(this.darkMode))
              .width('100%')

            ForEach(this.getFacilities(), (item: FacilityItem) => {
              Row() {
                Text(item.icon).fontSize(22).width(28).textAlign(TextAlign.Center)
                Text(item.label)
                  .fontSize(26 * this.fontScale)
                  .fontColor(ThemeUtil.titleColor(this.darkMode))
                  .layoutWeight(1).margin({ left: 8 })
                Text(item.value)
                  .fontSize(24 * this.fontScale)
                  .fontColor(ThemeUtil.subColor(this.darkMode))
              }
              .width('100%').height(48)
            })
          }
          .width('100%').padding(16)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

          // 操作按钮
          Row({ space: 16 }) {
            Button('导航到此')
              .fontSize(26 * this.fontScale).fontColor(AppColors.BG_CARD)
              .backgroundColor(AppColors.PRIMARY)
              .layoutWeight(1).height(48).borderRadius(8)
              .onClick(() => {
                this.getUIContext()?.getPromptAction()?.showToast({
                  message: `正在为您导航到${this.name}...`
                });
              })
            Button('分享位置')
              .fontSize(26 * this.fontScale).fontColor(AppColors.PRIMARY)
              .backgroundColor(AppColors.PRIMARY_LIGHT)
              .layoutWeight(1).height(48).borderRadius(8)
              .onClick(() => {
                this.getUIContext()?.getPromptAction()?.showToast({
                  message: '已生成位置分享链接（模拟）'
                });
              })
          }
          .width('100%')
        }
        .width('100%').padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor(ThemeUtil.pageBg(this.darkMode))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private getFacilities(): FacilityItem[] {
    const facilitiesMap: Record<string, FacilityItem[]> = {
      '教学楼A': [
        { icon: '🏢', label: '楼层', value: '共6层' },
        { icon: '📚', label: '教室数量', value: '120间' },
        { icon: '📶', label: 'WiFi覆盖', value: '全楼覆盖' },
        { icon: '🕐', label: '开放时间', value: '07:00 - 22:00' }
      ],
      '图书馆': [
        { icon: '🏢', label: '楼层', value: '共4层' },
        { icon: '📚', label: '藏书量', value: '50余万册' },
        { icon: '💺', label: '自习座位', value: '800个' },
        { icon: '🕐', label: '开放时间', value: '08:00 - 22:30' }
      ],
      '一食堂': [
        { icon: '🏢', label: '楼层', value: '共2层' },
        { icon: '🍜', label: '档口数量', value: '30+' },
        { icon: '💺', label: '座位数', value: '500个' },
        { icon: '🕐', label: '营业时间', value: '06:30 - 21:00' }
      ],
      '学生宿舍': [
        { icon: '🏢', label: '楼栋', value: 'A/B/C/D四栋' },
        { icon: '🛏', label: '户型', value: '四人间' },
        { icon: '📶', label: '网络', value: '校园网+宽带' },
        { icon: '🕐', label: '门禁时间', value: '23:00' }
      ],
      '操场': [
        { icon: '🏃', label: '跑道', value: '400米标准跑道' },
        { icon: '⚽', label: '球场', value: '足球场+篮球场' },
        { icon: '💡', label: '照明', value: '夜间灯光开放' },
        { icon: '🕐', label: '开放时间', value: '06:00 - 22:00' }
      ],
      '实验楼': [
        { icon: '🏢', label: '楼层', value: '共5层' },
        { icon: '🔬', label: '实验室', value: '40间' },
        { icon: '📶', label: 'WiFi覆盖', value: '全楼覆盖' },
        { icon: '🕐', label: '开放时间', value: '08:00 - 21:00' }
      ],
      '信工楼': [
        { icon: '🏢', label: '楼层', value: '共4层' },
        { icon: '💻', label: '特色实验室', value: 'HarmonyOS开发实验室(3F A306)' },
        { icon: '📶', label: 'WiFi覆盖', value: '全楼覆盖' },
        { icon: '🕐', label: '开放时间', value: '08:00 - 22:00' }
      ],
      '综合楼': [
        { icon: '🏢', label: '楼层', value: '共8层' },
        { icon: '🏛', label: '功能', value: '行政办公+报告厅' },
        { icon: '📶', label: 'WiFi覆盖', value: '部分区域' },
        { icon: '🕐', label: '办公时间', value: '08:30 - 17:30' }
      ]
    };
    return facilitiesMap[this.name] || [
      { icon: '🏢', label: '建筑类型', value: '校园建筑' },
      { icon: '📍', label: '位置', value: this.buildingPosition },
      { icon: '🕐', label: '开放时间', value: '08:00 - 22:00' }
    ];
  }
}
