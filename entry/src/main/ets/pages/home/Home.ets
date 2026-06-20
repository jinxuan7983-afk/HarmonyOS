import router from '@ohos.router';
import { DataManager } from '../../utils/DataManager';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';
import { NewsItem, QuickAction, TodoItem, TodoItemFull, CourseItem } from '../../common/constants/DataModels';
import { InfoContent } from '../info/Info';
import { StudyContent } from '../study/Study';
import { LifeContent } from '../life/Life';
import { ProfileContent } from '../profile/Profile';

/**
 * 【2.4 首页】核心主页面 - Tabs主容器
 * 设计规范：
 * - 底部Tab切换为"组件内切换，无页面跳转"
 * - TabBar使用SymbolGlyph系统图标
 * - 选中：鸿蒙蓝；未选中：文字辅色
 * - Tab内容：首页、校园信息、学习助手、生活服务、我的
 */

@Entry
@Component
struct Home {
  pageTransition() {
    PageTransitionEnter({ duration: 250, curve: Curve.EaseInOut })
      .opacity(0)
    PageTransitionExit({ duration: 250, curve: Curve.EaseInOut })
      .opacity(0)
  }
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State currentTab: number = 0;
  @State statusBarHeight: number = 0;

  // 首页Tab状态
  @State searchText: string = '';
  @State refreshing: boolean = false;
  @State newsCount: number = 3;
  @State todoInput: string = '';
  @State scrollOffset: number = 0;
  @State iconScale: number = 1;

  @State todos: TodoItem[] = [
    { title: '完成移动开发实验报告', done: false },
    { title: '18:30 去图书馆还书', done: false },
    { title: '整理课程表演示数据', done: true }
  ];
  @State todoVersion: number = 0;

  private syncFloatTodos(): void {
    AppStorage.setOrCreate('floatTodos', this.todos.filter((t: TodoItem) => !t.done));
  }

  async aboutToAppear(): Promise<void> {
    console.info('Home页面 aboutToAppear');
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
    // 从DataManager加载持久化的待办
    const savedTodos = await DataManager.loadTodosFull();
    if (savedTodos.length > 0) {
      this.todos = savedTodos as TodoItem[];
    }
    AppStorage.setOrCreate('floatTodos', this.todos.filter((t: TodoItem) => !t.done));
  }

  aboutToDisappear(): void {
    console.info('Home页面 aboutToDisappear');
    DataManager.saveTodosFull(this.todos);
  }

  @State actions: QuickAction[] = [
    { title: '校园公告', icon: $r('sys.symbol.bell'), iconColor: AppColors.PRIMARY, bgColor: AppColors.PRIMARY_LIGHT, url: 'pages/info/Info' },
    { title: '课程表', icon: $r('sys.symbol.calendar'), iconColor: AppColors.SUCCESS, bgColor: AppColors.SUCCESS_LIGHT, url: 'pages/study/Study' },
    { title: '成绩查询', icon: $r('sys.symbol.list_bullet'), iconColor: AppColors.WARNING, bgColor: AppColors.WARNING_LIGHT, url: 'pages/study/Study' },
    { title: '失物招领', icon: $r('sys.symbol.magnifyingglass'), iconColor: AppColors.PURPLE, bgColor: AppColors.PURPLE_LIGHT, url: 'pages/life/Life' },
    { title: '校园地图', icon: $r('sys.symbol.map'), iconColor: AppColors.PINK, bgColor: AppColors.PINK_LIGHT, url: 'pages/info/Info' },
    { title: '图书馆', icon: $r('sys.symbol.book'), iconColor: AppColors.INFO, bgColor: AppColors.INFO_LIGHT, url: 'pages/study/Study' },
    { title: '校园美食', icon: $r('sys.symbol.fork_knife'), iconColor: AppColors.DANGER, bgColor: AppColors.DANGER_LIGHT, url: 'pages/life/Life' },
    { title: '音乐播放', icon: $r('sys.symbol.headphones'), iconColor: AppColors.SUCCESS, bgColor: AppColors.SUCCESS_LIGHT, url: 'pages/life/Life' },
    { title: '待办提醒', icon: $r('sys.symbol.checkmark_circle'), iconColor: AppColors.WARNING, bgColor: AppColors.WARNING_LIGHT, url: 'pages/profile/Profile' },
    { title: '更多功能', icon: $r('sys.symbol.ellipsis_circle'), iconColor: AppColors.TEXT_SECONDARY, bgColor: AppColors.DIVIDER, url: 'pages/profile/Profile' }
  ];

  private allNews: NewsItem[] = [
    { title: '关于期末考试安排的通知', category: '校园公告', time: '06-09 09:30', summary: '公共课考试周安排已发布，请同学们及时查看考场。' },
    { title: '图书馆端午假期开放时间', category: '校园公告', time: '06-08 18:00', summary: '假期开放时间调整为 8:30-21:30。' },
    { title: '人工智能通识讲座报名开启', category: '学术讲座', time: '06-07 14:20', summary: '面向全校学生开放，地点为图书馆报告厅。' },
    { title: '校园运动会报名通知', category: '校园公告', time: '06-05 10:00', summary: '秋季运动会将于下周举行，请各班级组织报名。' },
    { title: '宿舍网络升级维护公告', category: '校园公告', time: '06-03 15:00', summary: '本周末进行宿舍网络设备升级，届时部分楼栋暂断网。' }
  ];

  private todayCourses: CourseItem[] = [
    { name: '移动开发技术', teacher: '', day: '', time: '08:20-10:00', place: '信工楼 A306', credits: '', color: AppColors.PRIMARY, remindOn: false },
    { name: '软件工程', teacher: '', day: '', time: '10:20-12:00', place: '教学楼 B204', credits: '', color: AppColors.SUCCESS, remindOn: false }
  ];

  // Tab页URL到Tab索引的映射，用于首页快捷入口跳转
  private tabUrlMap: Record<string, number> = {
    'pages/info/Info': 1,
    'pages/study/Study': 2,
    'pages/life/Life': 3,
    'pages/profile/Profile': 4
  };

  private switchToTabByUrl(url: string): void {
    const tabIndex = this.tabUrlMap[url];
    if (tabIndex !== undefined) {
      this.currentTab = tabIndex;
    }
  }

  build() {
    Column() {
      // 状态栏占位 - 根据当前Tab切换背景色
      Row()
        .width('100%')
        .height(this.statusBarHeight)
        .backgroundColor(this.currentTab === 0 ? AppColors.BG_PAGE : ThemeUtil.cardBg(this.darkMode))

      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          this.HomeContent()
        }
        .tabBar(this.TabBuilder(0, '首页', $r('sys.symbol.house')))

        TabContent() {
          InfoContent()
        }
        .tabBar(this.TabBuilder(1, '校园信息', $r('sys.symbol.doc')))

        TabContent() {
          StudyContent()
        }
        .tabBar(this.TabBuilder(2, '学习助手', $r('sys.symbol.book')))

        TabContent() {
          LifeContent()
        }
        .tabBar(this.TabBuilder(3, '生活服务', $r('sys.symbol.gearshape')))

        TabContent() {
          ProfileContent({ onSwitchTab: (index: number) => { this.currentTab = index; } })
        }
        .tabBar(this.TabBuilder(4, '我的', $r('sys.symbol.person')))
      }
      .scrollable(false)
      .onChange((index: number) => {
        this.currentTab = index;
      })
      .barBackgroundColor(AppColors.BG_CARD)
      .borderWidth({ top: 1 })
      .borderColor(AppColors.BORDER)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeUtil.pageBg(this.darkMode))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // ===== 自定义TabBar项（SymbolGlyph图标 + 文字） =====
  @Builder TabBuilder(index: number, label: string, icon: Resource) {
    Column({ space: 2 }) {
      SymbolGlyph(icon)
        .fontSize(28)
        .fontColor([index === this.currentTab ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY])
      Text(label)
        .fontSize(24)
        .fontColor(index === this.currentTab ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY)
        .fontWeight(index === this.currentTab ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // ===== 首页Tab内容 =====
  @Builder HomeContent() {
    Refresh({ refreshing: $$this.refreshing }) {
      Scroll() {
        Column({ space: 24 }) {
          // 沉浸式导航栏 + 搜索栏
          this.TopBar()
          this.SearchBar()

          // 功能快捷入口 - 九宫格 3行×4列
          this.QuickGrid()

          // 校园公告卡片
          this.NewsCard()

          // 今日课程卡片
          this.CourseCard()

          // 待办模块
          this.TodoSection()

          // 天气卡片
          this.WeatherCard()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 24 })
      }
      .scrollBar(BarState.Off)
      .onScroll((xOffset: number, yOffset: number) => {
        this.scrollOffset = yOffset;
        if (yOffset > 400 && this.newsCount < this.allNews.length) {
          this.newsCount = Math.min(this.newsCount + 2, this.allNews.length);
        }
      })
    }
    .onRefreshing(() => {
      this.refreshing = true;
      setTimeout(() => {
        this.refreshing = false;
        try { this.getUIContext()?.getPromptAction()?.showToast({ message: '刷新完成' }); } catch (e) {}
      }, 1500);
    })
    .refreshOffset(64)
  }

  // ===== 沉浸式导航栏（渐变效果） =====
  @Builder
  TopBar() {
    Row() {
      Text('校园助手')
        .fontSize(28)
        .lineHeight(28 * AppColors.LINE_HEIGHT_TITLE_L)
        .fontWeight(600)
        .fontColor(this.scrollOffset > 50 ? AppColors.TEXT_PRIMARY : AppColors.PRIMARY)

      Blank()

      // 消息铃铛
      Stack() {
        SymbolGlyph($r('sys.symbol.bell'))
          .fontSize(24)
          .fontColor([AppColors.PRIMARY])
          .width(44)
          .height(44)
          .backgroundColor(AppColors.PRIMARY_LIGHT)
          .borderRadius(22)
        // 暖橙小圆点
        Circle()
          .width(10)
          .height(10)
          .fill(AppColors.WARNING)
          .offset({ x: 13, y: -13 })
      }
      .onClick(() => router.pushUrl({ url: 'pages/info/MessageCenter' }))
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 4, right: 4 })
    .backgroundColor(this.scrollOffset > 50 ? ThemeUtil.cardBg(this.darkMode) : Color.Transparent)
  }

  // ===== 搜索栏 =====
  @Builder
  SearchBar() {
    Row({ space: 12 }) {
      Text('🔍')
        .fontSize(24)
        .fontColor(AppColors.PRIMARY)
      TextInput({ text: this.searchText, placeholder: '搜索校园信息 / 课程 / 美食' })
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .onChange((value: string) => this.searchText = value)
        .onSubmit(() => {
          if (this.searchText.trim().length > 0) {
            router.pushUrl({ url: 'pages/info/SearchResult', params: { keyword: this.searchText } });
          }
        })
      Text('🎤')
        .fontSize(24)
        .fontColor(AppColors.PRIMARY)
    }
    .height(48)
    .width('95%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(ThemeUtil.cardBg(this.darkMode))
    .borderRadius(24)
    .onClick(() => {
      router.pushUrl({ url: 'pages/info/SearchResult', params: { keyword: this.searchText } });
    })
  }

  // ===== 九宫格功能入口（3行4列） =====
  @Builder
  QuickGrid() {
    Column({ space: 0 }) {
      Grid() {
        ForEach(this.actions, (item: QuickAction) => {
          GridItem() {
            Column({ space: 6 }) {
              Stack() {
                SymbolGlyph(item.icon)
                  .fontSize(32 * this.fontScale)
                  .fontColor([item.iconColor])
              }
              .width(64)
              .height(64)
              .backgroundColor(item.bgColor)
              .borderRadius(32)
              .alignContent(Alignment.Center)
                .scale({ x: this.iconScale, y: this.iconScale })
                .animation({ duration: 150, curve: Curve.EaseOut })
              Text(item.title)
                .fontSize(24)
                .fontColor(ThemeUtil.titleColor(this.darkMode))
                .maxLines(1)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              // 点击放大微动画
              this.iconScale = 0.85;
              setTimeout(() => { this.iconScale = 1; }, 150);

              if (item.title === '更多功能') {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '更多功能开发中' });
              } else {
                // 切换到对应Tab而非页面跳转
                this.switchToTabByUrl(item.url);
              }
            })
          }
         }, (item: QuickAction) => item.title)
       }
       .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(16)
      .columnsGap(8)
    }
    .width('100%')
    .padding({ top: 16, bottom: 16, left: 12, right: 12 })
    .backgroundColor(ThemeUtil.cardBg(this.darkMode))
    .borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }

  // ===== 校园公告卡片 =====
  @Builder
  NewsCard() {
    Column({ space: 12 }) {
      // 卡片标题行
      Row() {
        Text('校园公告')
          .fontSize(28 * this.fontScale)
          .fontWeight(600)
          .fontColor(AppColors.PRIMARY)
        Blank()
        Text('更多')
          .fontSize(24)
          .fontColor(AppColors.PRIMARY)
          .onClick(() => { this.currentTab = 1; })
      }
      .width('100%')

      // 公告列表
        ForEach(this.allNews.slice(0, this.newsCount), (item: NewsItem, index: number) => {
        Column({ space: 6 }) {
          Text(item.title)
            .fontSize(26 * this.fontScale)
            .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
            .fontColor(ThemeUtil.titleColor(this.darkMode))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(item.time)
            .fontSize(24)
            .fontColor(ThemeUtil.subColor(this.darkMode))
          Text(item.summary)
            .fontSize(24)
            .lineHeight(24 * this.fontScale * AppColors.LINE_HEIGHT_AUX)
            .fontColor(ThemeUtil.subColor(this.darkMode))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/info/NewsDetail',
            params: {
              title: item.title,
              category: item.category,
              time: item.time,
              summary: item.summary
            }
          });
        })

        if (index < this.newsCount - 1) {
          Divider().color(AppColors.DIVIDER).strokeWidth(1)
         }
       }, (item: NewsItem) => item.title + item.time)

      // 自动加载提示
      if (this.newsCount < this.allNews.length) {
        Text('加载中...')
          .fontSize(24)
          .fontColor(AppColors.TEXT_SECONDARY)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode))
    .borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }

  // ===== 今日课程卡片 =====
  @Builder
  CourseCard() {
    Column({ space: 12 }) {
      Row() {
        Text('今日课程')
          .fontSize(28 * this.fontScale)
          .fontWeight(600)
          .fontColor(AppColors.PRIMARY)
        Blank()
        Text('课程表')
          .fontSize(24)
          .fontColor(AppColors.PRIMARY)
          .onClick(() => { this.currentTab = 2; })
      }
      .width('100%')

      if (this.todayCourses.length === 0) {
        Text('今日无课程，好好休息吧～')
          .fontSize(26 * this.fontScale)
          .fontColor(ThemeUtil.subColor(this.darkMode))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 12 })
      } else {
        ForEach(this.todayCourses, (course: CourseItem) => {
          Row({ space: 12 }) {
            // 左侧颜色条
            Text('')
              .width(6)
              .height(52)
              .backgroundColor(course.color)
              .borderRadius(4)

            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(course.name)
                  .fontSize(26 * this.fontScale)
                  .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
                  .fontColor(ThemeUtil.titleColor(this.darkMode))
                // 暖橙标签标识当前课程
                Text('进行中')
                  .fontSize(24)
                  .fontColor(AppColors.BG_CARD)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .backgroundColor(AppColors.WARNING)
                  .borderRadius(4)
              }
              Text(`${course.time} · ${course.place}`)
                .fontSize(24)
                .fontColor(ThemeUtil.subColor(this.darkMode))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 4, bottom: 4 })
         }, (course: CourseItem) => course.name + course.time)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode))
    .borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }

  // ===== 待办模块 =====
  @Builder
  TodoSection() {
    Column({ space: 12 }) {
      // 待办输入
      Row({ space: 8 }) {
        TextInput({ text: this.todoInput, placeholder: '输入新的待办事项...' })
          .fontSize(24)
          .height(48)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode))
          .borderRadius(8)
          .layoutWeight(1)
          .onChange((value: string) => this.todoInput = value)
        Button('添加')
          .height(48)
          .fontSize(24)
          .fontColor(AppColors.BG_CARD)
          .backgroundColor(AppColors.PRIMARY)
          .borderRadius(8)
          .onClick(() => {
            if (this.todoInput.trim().length === 0) {
              this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入待办内容' });
              return;
            }
            this.todos.unshift({ title: this.todoInput.trim(), done: false });
            this.todoInput = '';
            this.syncFloatTodos();
            this.getUIContext()?.getPromptAction()?.showToast({ message: '已添加待办' });
          })
      }
      .width('100%')

      // 待办列表
      ForEach(this.getVisibleTodos(), (todo: TodoItem, index: number) => {
        Row() {
          Checkbox()
            .select(todo.done)
            .selectedColor(AppColors.SUCCESS)
            .onChange((checked: boolean) => {
              todo.done = checked;
              this.todoVersion += 1;
              this.syncFloatTodos();
            })
          Text(todo.title)
            .fontSize(26 * this.fontScale)
            .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
            .fontColor(todo.done ? ThemeUtil.subColor(this.darkMode) : ThemeUtil.titleColor(this.darkMode))
            .decoration({ type: todo.done ? TextDecorationType.LineThrough : TextDecorationType.None })
            .layoutWeight(1)
            .maxLines(1)
          Text('删除')
            .fontSize(24)
            .fontColor(AppColors.WARNING)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(AppColors.WARNING_LIGHT)
            .borderRadius(8)
            .onClick(() => {
              const realIdx = this.todos.indexOf(todo);
              if (realIdx >= 0) { this.todos.splice(realIdx, 1); this.todoVersion += 1; this.syncFloatTodos(); }
            })
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .border({ width: { bottom: 1 }, color: AppColors.DIVIDER })
      })

      // 进度条
      if (this.todos.length > 0 && this.todoVersion >= 0) {
        Row({ space: 8 }) {
          Progress({
            value: this.todos.filter((t: TodoItem) => t.done).length,
            total: this.todos.length,
            type: ProgressType.Linear
          })
            .color(AppColors.SUCCESS)
            .backgroundColor(AppColors.PRIMARY_LIGHT)
            .layoutWeight(1)
          Text(`${this.todos.filter((t: TodoItem) => t.done).length}/${this.todos.length}`)
            .fontSize(24)
            .fontColor(ThemeUtil.subColor(this.darkMode))
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode))
    .borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }

  private getVisibleTodos(): TodoItem[] {
    const undone = this.todos.filter((t: TodoItem) => !t.done);
    const done = this.todos.filter((t: TodoItem) => t.done);
    return [...undone, ...done].slice(0, 5);
  }

  // ===== 天气卡片 =====
  @Builder
  WeatherCard() {
    Column({ space: 14 }) {
      // 当前天气主信息
      Row({ space: 16 }) {
        // 左侧天气图标 48px
        Text('☀')
          .fontSize(32)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)

        // 温度 32sp
        Text('25℃')
          .fontSize(32 * this.fontScale)
          .lineHeight(32 * this.fontScale * AppColors.LINE_HEIGHT_TITLE_L)
          .fontColor(ThemeUtil.titleColor(this.darkMode))

        Blank()

        // 右侧天气状况
        Column({ space: 4 }) {
          Text('晴 微风')
            .fontSize(26 * this.fontScale)
            .fontColor(ThemeUtil.subColor(this.darkMode))
          Text('校园所在地区')
            .fontSize(24)
            .fontColor(ThemeUtil.subColor(this.darkMode))
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // 天气指标
      Grid() {
        GridItem() { this.WeatherItem('湿度', '58%', AppColors.PRIMARY, AppColors.PRIMARY_LIGHT) }
        GridItem() { this.WeatherItem('风力', '2级', AppColors.SUCCESS, AppColors.SUCCESS_LIGHT) }
        GridItem() { this.WeatherItem('AQI', '42 优', AppColors.INFO, AppColors.INFO_LIGHT) }
        GridItem() { this.WeatherItem('紫外线', '中等', AppColors.WARNING, AppColors.WARNING_LIGHT) }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(8)

      // 未来三天
      Divider().color(AppColors.DIVIDER).strokeWidth(1)

      Row() {
        this.ForecastItem('明天', '☀', '27°', '18°')
        this.ForecastItem('后天', '⛅', '26°', '19°')
        this.ForecastItem('周六', '🌧', '24°', '17°')
        this.ForecastItem('周日', '☀', '28°', '20°')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode))
    .borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/info/WeatherDetail' });
    })
  }

  @Builder
  WeatherItem(label: string, value: string, color: string, bgColor: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(24)
        .fontColor(ThemeUtil.subColor(this.darkMode))
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bgColor)
    .borderRadius(8)
  }

  @Builder
  ForecastItem(day: string, icon: string, high: string, low: string) {
    Column({ space: 6 }) {
      Text(day)
        .fontSize(24)
        .fontColor(ThemeUtil.subColor(this.darkMode))
      Text(icon)
        .fontSize(26 * this.fontScale)
      Text(high)
        .fontSize(26 * this.fontScale)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeUtil.titleColor(this.darkMode))
      Text(low)
        .fontSize(24)
        .fontColor(ThemeUtil.subColor(this.darkMode))
    }
    .alignItems(HorizontalAlign.Center)
  }
}
