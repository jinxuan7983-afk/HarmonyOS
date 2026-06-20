import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';

/**
 * 【搜索结果页】
 * - 从路由参数获取搜索关键词
 * - 在前端模拟数据中搜索（公告、课程、美食等混合数据）
 * - 支持实时搜索（TextInput onChange 触发）
 * - 点击结果项跳转到对应详情页
 */
interface RouterParams {
  keyword: string;
}

interface SearchResultItem {
  title: string;
  source: string;
  time: string;
  summary: string;
  type: string;
  category: string;
}

@Entry
@Component
struct SearchResult {
  pageTransition() {
    PageTransitionEnter({ duration: 250, curve: Curve.EaseInOut })
      .opacity(0)
    PageTransitionExit({ duration: 250, curve: Curve.EaseInOut })
      .opacity(0)
  }

  @State keyword: string = '';
  @State results: SearchResultItem[] = [];

  private allData: SearchResultItem[] = [
    { title: '关于期末考试安排的通知', source: '校园公告', time: '06-09 09:30', summary: '公共课考试周安排已发布，请同学们及时查看考场分配和考试时间，提前做好复习准备。', type: 'news', category: '校园公告' },
    { title: '图书馆端午假期开放时间', source: '校园公告', time: '06-08 18:00', summary: '假期开放时间调整为 8:30-21:30，请同学们合理安排自习时间。', type: 'news', category: '校园公告' },
    { title: '人工智能通识讲座报名开启', source: '学术讲座', time: '06-07 14:20', summary: '面向全校学生开放，地点为图书馆报告厅，名额有限请尽早报名。', type: 'info', category: '学术讲座' },
    { title: '校园运动会报名通知', source: '校园公告', time: '06-05 10:00', summary: '秋季运动会将于下周举行，请各班级组织报名，项目包括田径、球类等。', type: 'news', category: '校园公告' },
    { title: '宿舍网络升级维护公告', source: '校园公告', time: '06-03 15:00', summary: '本周末进行宿舍网络设备升级，届时部分楼栋暂断网，请提前做好准备。', type: 'news', category: '校园公告' },
    { title: '移动开发技术', source: '课程', time: '周一 08:20-10:00', summary: '信工楼 A306，讲授 HarmonyOS 应用开发核心技术，包含实验环节。', type: 'info', category: '课程' },
    { title: '软件工程', source: '课程', time: '周一 10:20-12:00', summary: '教学楼 B204，学习软件开发生命周期、需求分析与项目管理方法。', type: 'info', category: '课程' },
    { title: '数据结构与算法', source: '课程', time: '周二 14:00-15:40', summary: '信工楼 A201，讲解常用数据结构及其算法设计与分析方法。', type: 'info', category: '课程' },
    { title: '数据库原理', source: '课程', time: '周三 08:20-10:00', summary: '教学楼 C103，学习关系数据库设计、SQL语言与事务管理。', type: 'info', category: '课程' },
    { title: '红烧牛肉面', source: '第一食堂', time: '全天供应', summary: '经典红烧牛肉面，汤浓面筋道，牛肉大块实惠，深受同学喜爱。', type: 'info', category: '美食' },
    { title: '麻辣香锅', source: '第二食堂', time: '午/晚餐', summary: '自选食材现炒，麻辣鲜香，可根据个人口味调整辣度和配料。', type: 'info', category: '美食' },
    { title: '黄焖鸡米饭', source: '第三食堂', time: '午/晚餐', summary: '鲜嫩鸡肉搭配秘制酱料，米饭管饱，性价比超高的校园美食。', type: 'info', category: '美食' },
    { title: '社团招新活动汇总', source: '社团活动', time: '06-10 08:00', summary: '本学期社团招新已全面启动，涵盖文艺、体育、科技等30余个社团。', type: 'info', category: '社团活动' },
    { title: '校园歌手大赛决赛', source: '社团活动', time: '06-12 19:00', summary: '一年一度的校园歌手大赛决赛即将在大礼堂举行，欢迎前来观赛。', type: 'info', category: '社团活动' },
    { title: '毕业季跳蚤市场', source: '校园公告', time: '06-15 09:00', summary: '毕业季跳蚤市场在操场开放，涵盖书籍、电子产品、生活用品等。', type: 'news', category: '校园公告' },
  ];

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams;
    if (params && params.keyword) {
      this.keyword = params.keyword;
      this.doSearch(this.keyword);
    }
  }

  private doSearch(key: string): void {
    const trimmed = key.trim().toLowerCase();
    if (trimmed.length === 0) {
      this.results = [];
      return;
    }
    this.results = this.allData.filter((item: SearchResultItem) => {
      return item.title.toLowerCase().includes(trimmed)
        || item.summary.toLowerCase().includes(trimmed)
        || item.source.toLowerCase().includes(trimmed)
        || item.category.toLowerCase().includes(trimmed);
    });
  }

  private navigateToDetail(item: SearchResultItem): void {
    if (item.type === 'news') {
      router.pushUrl({
        url: 'pages/info/NewsDetail',
        params: {
          title: item.title,
          category: item.category,
          time: item.time,
          summary: item.summary
        }
      });
    } else {
      router.pushUrl({
        url: 'pages/info/InfoDetail',
        params: {
          title: item.title,
          category: item.category,
          time: item.time,
          summary: item.summary
        }
      });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(AppColors.PRIMARY)
          .onClick(() => router.back())
        Text('搜索结果')
          .fontSize(28)
          .fontWeight(600)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(AppColors.BG_CARD)

      // 搜索输入框
      Row() {
        TextInput({ text: this.keyword, placeholder: '搜索校园信息/课程/美食' })
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.keyword = value;
            this.doSearch(value);
          })
      }
      .height(48)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor(AppColors.BG_CARD)
      .borderRadius(24)
      .border({ width: 1, color: AppColors.BORDER })

      // 搜索结果列表
      if (this.results.length === 0) {
        Column() {
          Text('未找到相关内容')
            .fontSize(26)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.results, (item: SearchResultItem) => {
              Column({ space: 8 }) {
                // 标题
                Text(item.title)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                // 时间/来源
                Row({ space: 12 }) {
                  Text(item.source)
                    .fontSize(24)
                    .fontColor(AppColors.PRIMARY)
                  Text(item.time)
                    .fontSize(24)
                    .fontColor(AppColors.TEXT_SECONDARY)
                }

                // 摘要
                Text(item.summary)
                  .fontSize(24)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(AppColors.BG_CARD)
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                this.navigateToDetail(item);
              })
            }, (item: SearchResultItem) => item.title + item.time)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .padding({ left: 20, right: 20 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
