import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';

/**
 * 天气详情页
 * - 当前天气大卡片（城市、温度、天气描述、指标网格）
 * - 未来3天天气预报
 * - 生活指数（穿衣、运动、洗车）
 * - 静态模拟数据
 */
interface WeatherMetric {
  label: string;
  value: string;
  color: string;
  bgColor: string;
}

interface ForecastDay {
  date: string;
  icon: string;
  weather: string;
  high: string;
  low: string;
}

interface LifeIndex {
  icon: string;
  title: string;
  level: string;
  desc: string;
  color: string;
  bgColor: string;
}

@Entry
@Component
struct WeatherDetail {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State statusBarHeight: number = 0;

  // 静态模拟数据
  private city: string = '校园所在地区';
  private temperature: string = '25';
  private weatherIcon: string = '☀';
  private weatherDesc: string = '晴 微风';

  private weatherMetrics: WeatherMetric[] = [
    { label: '湿度', value: '58%', color: AppColors.PRIMARY, bgColor: AppColors.PRIMARY_LIGHT },
    { label: '风力', value: '2级', color: AppColors.SUCCESS, bgColor: AppColors.SUCCESS_LIGHT },
    { label: 'AQI', value: '42 优', color: AppColors.INFO, bgColor: AppColors.INFO_LIGHT },
    { label: '紫外线', value: '中等', color: AppColors.WARNING, bgColor: AppColors.WARNING_LIGHT }
  ];

  private forecasts: ForecastDay[] = [
    { date: '明天', icon: '☀', weather: '晴', high: '27°', low: '18°' },
    { date: '后天', icon: '⛅', weather: '多云', high: '26°', low: '19°' },
    { date: '周六', icon: '🌧', weather: '小雨', high: '24°', low: '17°' }
  ];

  private lifeIndices: LifeIndex[] = [
    { icon: '👔', title: '穿衣指数', level: '舒适', desc: '建议穿薄型T恤短裤', color: AppColors.PRIMARY, bgColor: AppColors.PRIMARY_LIGHT },
    { icon: '🏃', title: '运动指数', level: '适宜', desc: '天气较好，适合运动', color: AppColors.SUCCESS, bgColor: AppColors.SUCCESS_LIGHT },
    { icon: '🚗', title: '洗车指数', level: '较适宜', desc: '未来一天无雨，适合洗车', color: AppColors.WARNING, bgColor: AppColors.WARNING_LIGHT }
  ];

  async aboutToAppear(): Promise<void> {
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
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
        Text('天气详情')
          .fontSize(30).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
          .margin({ left: 8 }).layoutWeight(1)
      }
      .width('100%').height(52).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Scroll() {
        Column({ space: 20 }) {
          // 当前天气大卡片
          this.CurrentWeatherCard()

          // 未来3天天气预报
          this.ForecastCard()

          // 生活指数
          this.LifeIndexCard()
        }
        .width('100%').padding({ left: 20, right: 20, top: 16, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(ThemeUtil.pageBg(this.darkMode))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // ===== 当前天气大卡片 =====
  @Builder
  CurrentWeatherCard() {
    Column({ space: 16 }) {
      // 城市名称
      Text(this.city)
        .fontSize(28 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
        .width('100%').textAlign(TextAlign.Center)

      // 大温度数字
      Row() {
        Text(this.temperature)
          .fontSize(32 * this.fontScale).fontWeight(700).fontColor(ThemeUtil.titleColor(this.darkMode))
        Text('℃')
          .fontSize(32 * this.fontScale).fontWeight(400).fontColor(ThemeUtil.subColor(this.darkMode))
          .margin({ left: 4, bottom: 12 })
      }
      .justifyContent(FlexAlign.Center)

      // 天气图标+描述
      Row({ space: 8 }) {
        Text(this.weatherIcon).fontSize(32 * this.fontScale)
        Text(this.weatherDesc).fontSize(32 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
      }
      .justifyContent(FlexAlign.Center)

      // 天气指标网格（4列）
      Grid() {
        ForEach(this.weatherMetrics, (item: WeatherMetric) => {
          GridItem() {
            Column({ space: 4 }) {
              Text(item.value)
                .fontSize(24 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(item.color)
              Text(item.label)
                .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
            }
            .width('100%').height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(item.bgColor).borderRadius(8)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(8)
    }
    .width('100%').padding(20)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }

  // ===== 未来3天天气预报 =====
  @Builder
  ForecastCard() {
    Column({ space: 0 }) {
      // 标题
      Text('未来天气预报')
        .fontSize(28 * this.fontScale).fontWeight(600).fontColor(AppColors.PRIMARY)
        .width('100%').padding({ bottom: 12 })

      ForEach(this.forecasts, (day: ForecastDay, index: number) => {
        Row() {
          Text(day.date)
            .fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
            .width(60)
          Text(day.icon)
            .fontSize(28 * this.fontScale).width(40).textAlign(TextAlign.Center)
          Text(day.weather)
            .fontSize(26 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
            .layoutWeight(1).margin({ left: 8 })
          Text(day.high)
            .fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode))
          Text('/')
            .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode)).margin({ left: 4, right: 4 })
          Text(day.low)
            .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
        }
        .width('100%').height(52).padding({ left: 12, right: 12 })

        if (index < this.forecasts.length - 1) {
          Divider().color(ThemeUtil.dividerColor(this.darkMode)).strokeWidth(1).width('94%')
        }
      })
    }
    .width('100%').padding(16)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
    .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
  }

  // ===== 生活指数 =====
  @Builder
  LifeIndexCard() {
    Column({ space: 12 }) {
      Text('生活指数')
        .fontSize(28 * this.fontScale).fontWeight(600).fontColor(AppColors.PRIMARY)
        .width('100%')

      Grid() {
        ForEach(this.lifeIndices, (item: LifeIndex) => {
          GridItem() {
            Column({ space: 8 }) {
              Text(item.icon).fontSize(32 * this.fontScale)
              Text(item.title).fontSize(24 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
              Text(item.level)
                .fontSize(24 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(item.color)
              Text(item.desc)
                .fontSize(24).fontColor(ThemeUtil.subColor(this.darkMode))
                .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%').padding(12)
            .backgroundColor(item.bgColor).borderRadius(8)
            .alignItems(HorizontalAlign.Center)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(10)
    }
    .width('100%').padding(16)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
    .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
  }
}
