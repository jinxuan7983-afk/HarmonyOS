import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { NewsItem, Building } from '../../common/constants/DataModels';

/**
 * 校园信息Tab内容组件
 * 从独立页面改为组件内嵌，由Home主容器通过Tabs切换
 */

@Component
export struct InfoContent {
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State category: string = '校园公告';
  @State searchText: string = '';
  @State refreshing: boolean = false;
  @State loadingMore: boolean = false;
  @State infoCount: number = 3;
  @State noticeFilter: string = '全部';
  @State selectedBuilding: Building | null = null;
  @State mapSearchText: string = '';
  @State mapScale: number = 1;
  @State mapOffsetX: number = 0;
  @State mapOffsetY: number = 0;
  private mapLastOffsetX: number = 0;
  private mapLastOffsetY: number = 0;

  aboutToAppear(): void {
    console.info('InfoContent aboutToAppear');
  }
  aboutToDisappear(): void {
    console.info('InfoContent aboutToDisappear');
  }

  private mainCategories: string[] = ['校园公告', '校园资讯', '社团活动', '学术讲座', '校园地图'];
  private noticeFilters: string[] = ['全部', '学校通知', '学院通知', '社团通知'];

  private allNews: NewsItem[] = [
    { title: '关于期末考试安排的通知', category: '校园公告', subCategory: '学校通知', time: '06-09 09:30', summary: '公共课考试周安排已发布，请同学们及时查看考场。' },
    { title: '图书馆端午假期开放时间', category: '校园公告', subCategory: '学校通知', time: '06-08 18:00', summary: '假期开放时间调整为 8:30-21:30。' },
    { title: '信息工程学院期末答辩安排', category: '校园公告', subCategory: '学院通知', time: '06-07 10:00', summary: '答辩时间定于6月20日，请提前提交材料。' },
    { title: '羽毛球社团换届选举通知', category: '校园公告', subCategory: '社团通知', time: '06-06 14:00', summary: '新一届干事选举将于下周三举行。' },
    { title: '校园新食堂试运营体验日', category: '校园资讯', subCategory: '学校通知', time: '06-05 12:00', summary: '新窗口上线轻食、面点、地方菜系列。' },
    { title: '摄影社夏日影像征集', category: '社团活动', subCategory: '社团通知', time: '06-06 16:40', summary: '欢迎提交校园生活主题作品。' },
    { title: '人工智能通识讲座报名开启', category: '学术讲座', subCategory: '学校通知', time: '06-07 14:20', summary: '面向全校学生开放，地点为图书馆报告厅。' },
    { title: '春季社团招新活动', category: '社团活动', subCategory: '社团通知', time: '06-02 09:00', summary: '各大社团将在操场举办联合招新。' },
    { title: '计算机科学前沿论坛', category: '学术讲座', subCategory: '学院通知', time: '06-01 10:30', summary: '邀请国内知名学者分享AI领域最新进展。' },
    { title: '校园运动会报名通知', category: '校园公告', subCategory: '学校通知', time: '05-28 08:00', summary: '秋季运动会报名截止至6月15日。' }
  ];

  private buildings: Building[] = [
    { name: '教学楼A', icon: '🏫', desc: '主教学楼共6层，设有阶梯教室和普通教室。', position: '校园中心', x: 45, y: 30 },
    { name: '图书馆', icon: '📚', desc: '共4层，藏书50余万册，开放时间8:00-22:00。', position: '校园北区', x: 65, y: 18 },
    { name: '一食堂', icon: '🍽', desc: '共2层，大众餐+特色美食，营业6:30-21:00。', position: '校园西区', x: 20, y: 45 },
    { name: '学生宿舍', icon: '🏠', desc: '共8栋楼，标准4人间，独立卫浴，门禁23:00。', position: '校园南区', x: 50, y: 72 },
    { name: '操场', icon: '🏟', desc: '标准400米跑道，开放时间6:00-22:00。', position: '校园东区', x: 78, y: 55 },
    { name: '实验楼', icon: '🔬', desc: '共5层，配备物理/化学/计算机等实验室。', position: '校园东北', x: 72, y: 28 },
    { name: '信工楼', icon: '💻', desc: '信息工程学院大楼，HarmonyOS开发实验室在3楼A306。', position: '校园北区', x: 55, y: 15 },
    { name: '综合楼', icon: '🏢', desc: '行政综合楼，一楼设有学生服务中心。', position: '校园中心', x: 38, y: 38 }
  ];

  build() {
    Column() {
      // 导航栏（无返回箭头，白色背景）
      Row() {
        Text('校园信息')
          .fontSize(30)
          .lineHeight(30 * AppColors.LINE_HEIGHT_TITLE_L)
          .fontWeight(600)
          .fontColor(ThemeUtil.titleColor(this.darkMode))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 14, bottom: 10 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Refresh({ refreshing: $$this.refreshing }) {
        Scroll() {
          Column({ space: 16 }) {
            // 分类标签
            this.MainCategoryTabs()

            if (this.category === '校园地图') {
              this.MapPanel()
            } else {
              if (this.category === '校园公告') {
                this.NoticeSubFilter()
              }
              // 搜索栏
              Row({ space: 12 }) {
                SymbolGlyph($r('sys.symbol.magnifyingglass'))
                  .fontSize(24)
                  .fontColor([AppColors.PRIMARY])
                TextInput({ text: this.searchText, placeholder: `搜索${this.category}...` })
                  .fontSize(24).backgroundColor(Color.Transparent).layoutWeight(1)
                  .onChange((v: string) => this.searchText = v)
              }
              .width('95%')
              .height(48).padding({ left: 14, right: 14 })
              .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(22)
              this.InfoList()
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 18 })
        }
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        this.refreshing = true;
        setTimeout(() => {
          this.refreshing = false;
          try {
            this.getUIContext()?.getPromptAction()?.showToast({ message: '刷新完成' });
          } catch (e) {
            console.warn('InfoContent: showToast failed');
          }
        }, 1500);
      })
      .refreshOffset(64)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // ===== 主分类标签（设计规范：36px高圆角按钮） =====
  @Builder
  MainCategoryTabs() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.mainCategories, (item: string) => {
          Text(item)
            .fontSize(24 * this.fontScale)
            .fontColor(item === this.category ? AppColors.BG_CARD : ThemeUtil.titleColor(this.darkMode))
            .height(36)
            .padding({ left: 16, right: 16 })
            .backgroundColor(item === this.category ? AppColors.PRIMARY : AppColors.DIVIDER)
            .borderRadius(8)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.category = item;
              this.infoCount = 3;
              this.noticeFilter = '全部';
            })
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  // ===== 公告子分类 =====
  @Builder
  NoticeSubFilter() {
    Row({ space: 8 }) {
      ForEach(this.noticeFilters, (item: string) => {
        Text(item)
          .fontSize(24 * this.fontScale)
          .fontColor(item === this.noticeFilter ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .backgroundColor(item === this.noticeFilter ? AppColors.PRIMARY : AppColors.DIVIDER)
          .borderRadius(8)
          .onClick(() => {
            this.noticeFilter = item;
            this.infoCount = 3;
          })
      })
    }
    .width('100%')
  }

  // ===== 信息列表（设计规范：间距12px，内边距16px，卡片圆角8px，左侧80x80缩略图） =====
  @Builder
  InfoList() {
    List() {
      ForEach(this.getFilteredData().slice(0, this.infoCount), (item: NewsItem) => {
        ListItem() {
          Row({ space: 14 }) {
            // 左侧缩略图 80x80 - 按分类显示图标
            Column() {
              Text(this.getCategoryIcon(item.category))
                .fontSize(32)
                .width(80).height(80)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.getCategoryBg(item.category))
                .borderRadius(8)
            }

            // 右侧内容 70%
            Column({ space: 8 }) {
              // 标题 26sp
              Text(item.title)
                .fontSize(26 * this.fontScale)
                .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
                .fontColor(ThemeUtil.titleColor(this.darkMode))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              // 内容 24sp 两行省略
              Text(item.summary)
                .fontSize(24 * this.fontScale)
                .lineHeight(24 * this.fontScale * AppColors.LINE_HEIGHT_AUX)
                .fontColor(ThemeUtil.subColor(this.darkMode))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              // 来源 + 时间 22sp
              Row({ space: 8 }) {
                Text(item.subCategory)
                  .fontSize(24 * this.fontScale)
                  .fontColor(AppColors.PRIMARY)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .backgroundColor(AppColors.PRIMARY_LIGHT)
                  .borderRadius(4)
                Text(item.time)
                  .fontSize(22)
                  .fontColor(ThemeUtil.subColor(this.darkMode))
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode))
          .borderRadius(8)
          .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
          .onClick(() => {
            const target = this.category === '校园公告' ? 'pages/info/NewsDetail' : 'pages/info/InfoDetail';
            router.pushUrl({
              url: target,
              params: {
                title: item.title,
                category: item.category,
                time: item.time,
                summary: item.summary
              }
            });
          })
        }
        .margin({ bottom: 12 })
       }, (item: NewsItem) => item.title + item.time)
    }
    .width('100%')
    .onReachEnd(() => this.loadMore())
  }

  private getCategoryIcon(category: string): string {
    switch (category) {
      case '校园公告': return '📢';
      case '校园资讯': return '📰';
      case '社团活动': return '🎉';
      case '学术讲座': return '🎓';
      default: return '📋';
    }
  }

  private getCategoryBg(category: string): string {
    switch (category) {
      case '校园公告': return AppColors.PRIMARY_LIGHT;
      case '校园资讯': return AppColors.SUCCESS_LIGHT;
      case '社团活动': return AppColors.WARNING_LIGHT;
      case '学术讲座': return AppColors.PURPLE_LIGHT;
      default: return AppColors.BG_PAGE;
    }
  }

  private getFilteredData(): NewsItem[] {
    let result = this.allNews.filter((item: NewsItem) => item.category === this.category);
    if (this.category === '校园公告' && this.noticeFilter !== '全部') {
      result = result.filter((item: NewsItem) => item.subCategory === this.noticeFilter);
    }
    if (this.searchText.trim().length > 0) {
      const keyword = this.searchText.trim().toLowerCase();
      result = result.filter((item: NewsItem) =>
        item.title.toLowerCase().includes(keyword) ||
        item.summary.toLowerCase().includes(keyword)
      );
    }
    return result;
  }

  private loadMore(): void {
    if (this.loadingMore) return;
    this.loadingMore = true;
    setTimeout(() => {
      this.infoCount = Math.min(this.infoCount + 2, this.getFilteredData().length);
      this.loadingMore = false;
    }, 800);
  }

  // ===== 校园地图 =====
  @Builder
  MapPanel() {
    Column({ space: 14 }) {
      // 核心建筑快捷入口 - 横向滚动
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.buildings, (b: Building) => {
            Text(b.icon + ' ' + b.name)
              .fontSize(24 * this.fontScale)
              .fontColor(ThemeUtil.titleColor(this.darkMode))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(ThemeUtil.cardBg(this.darkMode))
              .borderRadius(8)
              .border({ width: 1, color: AppColors.BORDER })
               .onClick(() => {
                 this.selectedBuilding = b;
                 this.getUIContext()?.getPromptAction()?.showToast({ message: `${b.name}: ${b.desc.substring(0, 20)}...` });
               })
           }, (b: Building) => b.name)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      // 地图区域 200px
      Column({ space: 0 }) {
        Text('校园平面地图')
          .fontSize(26 * this.fontScale)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.BG_CARD)
          .width('100%').height(40).textAlign(TextAlign.Center)
          .backgroundColor(AppColors.PRIMARY)
          .borderRadius({ topLeft: 8, topRight: 8 })

        Stack() {
          Image($r('app.media.background'))
            .width('100%').aspectRatio(2)
            .objectFit(ImageFit.Cover).opacity(0.3)
            .scale({ x: this.mapScale, y: this.mapScale })
            .offset({ x: this.mapOffsetX, y: this.mapOffsetY })

          ForEach(this.getFilteredBuildings(), (building: Building) => {
            Column({ space: 2 }) {
              Text(building.icon)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.BG_CARD)
                .width(32).height(32).textAlign(TextAlign.Center)
                .backgroundColor(AppColors.PRIMARY).borderRadius(16)
              Text(building.name)
                .fontSize(24)
                .fontColor(ThemeUtil.titleColor(this.darkMode))
                .padding({ left: 4, right: 4 })
                .backgroundColor('#FFFFFFCC').borderRadius(4)
            }
            .position({ x: `${building.x}%`, y: `${building.y}%` })
            .translate({ x: '-50%', y: '-50%' })
             .onClick(() => { this.selectedBuilding = building; })
           }, (building: Building) => building.name)
        }
        .width('100%').aspectRatio(2)
        .backgroundColor(AppColors.BG_PAGE)
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
        // 双指缩放 + 单指拖动
        .gesture(
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event: GestureEvent) => {
              const newScale = this.mapScale * (event.scale ?? 1);
              if (newScale > 0.6 && newScale < 3) {
                this.mapScale = newScale;
              }
            })
        )
        .gesture(
          PanGesture({ fingers: 1, distance: 5 })
            .onActionStart(() => {
              this.mapLastOffsetX = this.mapOffsetX;
              this.mapLastOffsetY = this.mapOffsetY;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.mapOffsetX = this.mapLastOffsetX + event.offsetX;
              this.mapOffsetY = this.mapLastOffsetY + event.offsetY;
            })
        )
      }

      // 搜索框
      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(24)
          .fontColor([AppColors.PRIMARY])
        TextInput({ text: this.mapSearchText, placeholder: '搜索教学楼/图书馆/食堂...' })
          .fontSize(24).backgroundColor(Color.Transparent).layoutWeight(1)
          .onChange((value: string) => this.mapSearchText = value)
      }
      .height(48).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(24)

      // 建筑弹窗
      if (this.selectedBuilding !== null) {
        Column({ space: 10 }) {
          Row() {
            Text(this.selectedBuilding.icon)
              .fontSize(24).fontColor(AppColors.BG_CARD)
              .width(40).height(40).textAlign(TextAlign.Center)
              .backgroundColor(AppColors.PRIMARY).borderRadius(20)
            Column({ space: 4 }) {
              Text(this.selectedBuilding.name)
                .fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode))
              Text(`位置：${this.selectedBuilding.position}`)
                .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
            }
            .alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
            Text('✕')
              .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
              .onClick(() => { this.selectedBuilding = null; })
          }
          .width('100%')

          Text(this.selectedBuilding.desc)
            .fontSize(24 * this.fontScale).fontColor(AppColors.TEXT_TERTIARY).lineHeight(24 * this.fontScale * AppColors.LINE_HEIGHT_AUX).width('100%')

          Row({ space: 12 }) {
            Button('导航到此')
              .fontSize(24).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.PRIMARY)
              .layoutWeight(1).borderRadius(8).height(40)
              .onClick(() => { this.getUIContext()?.getPromptAction()?.showToast({ message: `模拟导航到${this.selectedBuilding?.name}` }); })
            Button('查看详情')
              .fontSize(24).fontColor(AppColors.PRIMARY).backgroundColor(AppColors.PRIMARY_LIGHT)
              .layoutWeight(1).borderRadius(8).height(40)
              .onClick(() => {
                if (this.selectedBuilding) {
                  router.pushUrl({
                    url: 'pages/info/MapDetail',
                    params: {
                      name: this.selectedBuilding.name,
                      icon: this.selectedBuilding.icon,
                      desc: this.selectedBuilding.desc,
                      position: this.selectedBuilding.position,
                      x: this.selectedBuilding.x,
                      y: this.selectedBuilding.y
                    }
                  });
                }
              })
          }
        }
        .padding(16).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
      }
    }
  }

  private getFilteredBuildings(): Building[] {
    if (this.mapSearchText.trim().length === 0) return this.buildings;
    const keyword = this.mapSearchText.trim().toLowerCase();
    return this.buildings.filter((b: Building) =>
      b.name.toLowerCase().includes(keyword) ||
      b.position.toLowerCase().includes(keyword)
    );
  }
}
