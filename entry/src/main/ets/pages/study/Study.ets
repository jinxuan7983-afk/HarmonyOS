import router from '@ohos.router';
import { notificationManager } from '@kit.NotificationKit';
import { wantAgent } from '@kit.AbilityKit';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { CourseItem, GradeItem, BookItem, MaterialItem } from '../../common/constants/DataModels';
import { DataManager } from '../../utils/DataManager';

/**
 * 学习助手Tab内容组件
 * 从独立页面改为组件内嵌，由Home主容器通过Tabs切换
 */

@Component
export struct StudyContent {
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State tab: string = '课程表';
  @State weekIndex: number = 15;
  @State searchText: string = '';
  @State refreshing: boolean = false;

  // 成绩查询 - 自动从用户数据加载学号
  @State studentId: string = '';
  @State gradePassword: string = '';
  @State gradeLoggedIn: boolean = false;
  @State showGradePassword: boolean = false;
  @State gradeSortBy: string = 'score';
  @State gradeSortDesc: boolean = true;

  // 图书筛选
  @State bookFilter: string = '全部';

  // 课程编辑返回结果
  @StorageLink('courseEditResult') @Watch('onCourseEditResult') courseEditResult: Record<string, Object> | null = null;

  onCourseEditResult(): void {
    if (!this.courseEditResult) return;
    const result = this.courseEditResult as Record<string, Object>;
    const action = result.action as string;
    if (action === 'delete') {
      const index = result.index as number;
      if (index >= 0 && index < this.courses.length) {
        this.courses.splice(index, 1);
      }
    } else if (action === 'edit') {
      const index = result.index as number;
      const course = result.course as CourseItem;
      if (index >= 0 && index < this.courses.length) {
        this.courses[index] = course;
      }
    } else if (action === 'add') {
      const course = result.course as CourseItem;
      this.courses.push(course);
    }
    this.courseEditResult = null;
  }

  async aboutToAppear(): Promise<void> {
    console.info('StudyContent aboutToAppear');
    const userInfo = await DataManager.loadUserInfo();
    this.studentId = userInfo.account;
    const savedCourses = await DataManager.loadCourses();
    if (savedCourses && (savedCourses as CourseItem[]).length > 0) {
      this.courses = savedCourses as CourseItem[];
    }
    const savedGrades = await DataManager.loadGrades();
    if (savedGrades && (savedGrades as GradeItem[]).length > 0) {
      this.grades = savedGrades as GradeItem[];
    }
  }

  async aboutToDisappear(): Promise<void> {
    console.info('StudyContent aboutToDisappear');
    await DataManager.saveJsonFile('courses.json', this.courses);
    await DataManager.saveGrades(this.grades);
  }

  private tabs: string[] = ['课程表', '成绩查询', '图书馆检索', '学习资料'];
  private days: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @State courses: CourseItem[] = [
    { name: '移动开发技术', teacher: '姜忠海', day: '周一', time: '08:20-10:00', place: '信工楼 A306', credits: '3', color: AppColors.PRIMARY, remindOn: true },
    { name: '高等数学', teacher: '张教授', day: '周一', time: '10:20-12:00', place: '教学楼 A101', credits: '4', color: AppColors.PINK, remindOn: true },
    { name: '大学物理', teacher: '刘老师', day: '周一', time: '14:00-15:40', place: '实验楼 201', credits: '3', color: AppColors.INFO, remindOn: false },
    { name: '软件工程', teacher: '李老师', day: '周二', time: '08:20-10:00', place: '教学楼 B204', credits: '3', color: AppColors.SUCCESS, remindOn: true },
    { name: '数据结构', teacher: '赵老师', day: '周二', time: '10:20-12:00', place: '信工楼 B302', credits: '3.5', color: AppColors.WARNING, remindOn: true },
    { name: '大学英语', teacher: '陈老师', day: '周二', time: '14:00-15:40', place: '教学楼 C101', credits: '2', color: AppColors.PURPLE, remindOn: false },
    { name: '数据库原理', teacher: '王老师', day: '周三', time: '08:20-10:00', place: '实验楼 502', credits: '2.5', color: AppColors.WARNING, remindOn: true },
    { name: '计算机网络', teacher: '周老师', day: '周三', time: '10:20-12:00', place: '信工楼 A208', credits: '3', color: AppColors.SUCCESS, remindOn: true },
    { name: '思政课', teacher: '马老师', day: '周三', time: '14:00-15:40', place: '教学楼 D301', credits: '2', color: AppColors.DANGER, remindOn: false },
    { name: '操作系统', teacher: '杨老师', day: '周四', time: '08:20-10:00', place: '信工楼 B108', credits: '3', color: AppColors.PRIMARY, remindOn: true },
    { name: '软件测试', teacher: '孙老师', day: '周四', time: '10:20-12:00', place: '实验楼 305', credits: '2.5', color: AppColors.SUCCESS, remindOn: false },
    { name: '体育', teacher: '吴教练', day: '周四', time: '14:00-15:40', place: '操场', credits: '1', color: AppColors.WARNING, remindOn: false },
    { name: '就业指导', teacher: '徐老师', day: '周五', time: '10:20-12:00', place: '教学楼 E102', credits: '1', color: AppColors.PURPLE, remindOn: false },
    { name: '形势与政策', teacher: '黄老师', day: '周五', time: '14:00-15:40', place: '教学楼 D201', credits: '1', color: AppColors.WARNING, remindOn: false }
  ];

  @State grades: GradeItem[] = [
    { name: '移动开发技术', score: '92', point: '4.2', examTime: '2026-06-24' },
    { name: '软件工程', score: '88', point: '3.8', examTime: '2026-06-20' },
    { name: '数据库原理', score: '90', point: '4.0', examTime: '2026-06-18' },
    { name: '数据结构', score: '86', point: '3.6', examTime: '2026-06-22' },
    { name: '计算机网络', score: '91', point: '4.1', examTime: '2026-06-16' },
    { name: '操作系统', score: '83', point: '3.3', examTime: '2026-06-19' },
    { name: '高等数学', score: '78', point: '3.0', examTime: '2026-06-10' },
    { name: '大学英语', score: '85', point: '3.5', examTime: '2026-06-15' }
  ];

  private books: BookItem[] = [
    { name: 'HarmonyOS开发实战', author: '开放原子教材组', isbn: '978-7-121', location: '三楼 T-12', count: 6, status: 'saved' },
    { name: '移动应用UI设计', author: '周明', isbn: '978-7-302', location: '二楼 H-08', count: 3, status: 'borrowed' },
    { name: '软件工程导论', author: '张海藩', isbn: '978-7-302', location: '四楼 S-21', count: 8, status: 'none' },
    { name: '数据库系统概念', author: 'A.Silberschatz', isbn: '978-7-111', location: '四楼 S-08', count: 4, status: 'want' },
    { name: '人工智能基础', author: '李航', isbn: '978-7-302', location: '三楼 T-18', count: 5, status: 'none' }
  ];

  private bookFilters: string[] = ['全部', '已收藏', '想读', '已借'];
  private materials: MaterialItem[] = [
    { name: '课件资料', icon: '📄' }, { name: '历年真题', icon: '📝' },
    { name: '实验报告', icon: '📋' }, { name: '参考论文', icon: '📚' }
  ];

  build() {
    Column() {
      // 导航栏（无返回箭头，白色背景）
      Row() {
        Text('学习助手').fontSize(28).lineHeight(28 * AppColors.LINE_HEIGHT_TITLE_L).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
      }
      .width('100%').padding({ left: 20, right: 20, top: 14, bottom: 10 }).backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Refresh({ refreshing: $$this.refreshing }) {
        Scroll() {
          Column({ space: 16 }) {
            this.CategoryTabs()
            if (this.tab === '课程表') { this.CourseSchedule() }
            else if (this.tab === '成绩查询') { this.GradeList() }
            else if (this.tab === '图书馆检索') { this.LibrarySearch() }
            else { this.Materials() }
          }
          .width('100%').padding({ left: 20, right: 20, top: 12, bottom: 18 })
        }
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        this.refreshing = true;
        setTimeout(() => { this.refreshing = false;
          try { this.getUIContext()?.getPromptAction()?.showToast({ message: '刷新完成' }); } catch (e) {} }, 1500);
      })
      .refreshOffset(64).layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  // ===== 标签栏（设计规范：4标签平分宽度+2px下划线） =====
  @Builder CategoryTabs() {
    Row() {
      ForEach(this.tabs, (item: string) => {
        Column({ space: 8 }) {
          Text(item)
            .fontSize(26 * this.fontScale)
            .fontWeight(this.tab === item ? 600 : 400)
            .fontColor(this.tab === item ? AppColors.PRIMARY : ThemeUtil.subColor(this.darkMode))
          if (this.tab === item) {
            Divider().width(36).height(2).color(AppColors.PRIMARY)
          }
        }
        .layoutWeight(1).height(48).justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => this.tab = item)
       })
     }
    .width('100%').backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  // ===== 课程表 =====
  @Builder CourseSchedule() {
    Column({ space: 14 }) {
      // 周次选择
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24).fontColor([AppColors.PRIMARY]).padding(8)
          .onClick(() => { if (this.weekIndex > 1) this.weekIndex -= 1; })
        Blank()
        Text(`2026年 第 ${this.weekIndex} 周`)
          .fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode))
        Blank()
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24).fontColor([AppColors.PRIMARY]).padding(8)
          .onClick(() => { if (this.weekIndex < 20) this.weekIndex += 1; })
      }

      // 周视图 周一~周日
      List() {
        ForEach(this.days, (day: string) => {
          ListItem() {
            Column({ space: 6 }) {
              Row() {
                Text(day).fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode))
                Blank()
                Text(`${this.courses.filter((c: CourseItem) => c.day === day).length}节课`)
                  .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
              }

              if (this.courses.filter((c: CourseItem) => c.day === day).length === 0) {
                Text('暂无课程').fontSize(24 * this.fontScale).fontColor(AppColors.TEXT_PLACEHOLDER).padding({ top: 6, bottom: 6 })
              }

              ForEach(this.courses.filter((c: CourseItem) => c.day === day), (course: CourseItem, courseIdx: number) => {
                Row({ space: 12 }) {
                  Text('').width(5).height(44).backgroundColor(course.color).borderRadius(4)
                  Column({ space: 4 }) {
                    Row({ space: 6 }) {
                      Text(course.name).fontSize(26 * this.fontScale).lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY).fontColor(ThemeUtil.titleColor(this.darkMode))
                      if (course.remindOn !== false) {
                        SymbolGlyph($r('sys.symbol.bell'))
                          .fontSize(24)
                          .fontColor([AppColors.PRIMARY])
                          .onClick(() => this.publishCourseNotification(course))
                      }
                    }
                    Text(`${course.time} · ${course.place}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                  }
                  .alignItems(HorizontalAlign.Start).layoutWeight(1)
                }
                .width('100%').padding({ top: 6, bottom: 6 })
                .onClick(() => {
                  const globalIdx = this.courses.indexOf(course);
                  router.pushUrl({
                    url: 'pages/study/CourseEdit',
                    params: { mode: 'edit', course: course, courseIndex: globalIdx }
                  });
                })
              }, (course: CourseItem) => course.name + course.time)
            }
            .width('100%').padding({ top: 10, bottom: 10 })
            .border({ width: { bottom: 1 }, color: this.darkMode ? AppColors.BG_DARK_DIVIDER : AppColors.DIVIDER })
          }
        })
      }
      .width('100%').height(400).scrollBar(BarState.Off)

      // 编辑按钮
      Button('编辑课程表')
        .width('100%').height(48).fontSize(26 * this.fontScale).fontColor(AppColors.BG_CARD)
        .backgroundColor(AppColors.PRIMARY).borderRadius(8)
        .onClick(() => router.pushUrl({ url: 'pages/study/CourseEdit', params: { mode: 'add' } }))
    }
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal, distance: 30 })
        .onActionEnd((event: GestureEvent) => {
          if (event.offsetX < -30 && this.weekIndex < 20) {
            this.weekIndex += 1;
          } else if (event.offsetX > 30 && this.weekIndex > 1) {
            this.weekIndex -= 1;
          }
        })
    )
  }

  // ===== 成绩查询 =====
  @Builder GradeList() {
    Column({ space: 14 }) {
      if (!this.gradeLoggedIn) {
        // 模拟登录界面
        Column({ space: 16 }) {
          Text('成绩查询')
            .fontSize(28)
            .fontWeight(600)
            .fontColor(ThemeUtil.titleColor(this.darkMode))
            .textAlign(TextAlign.Center)
            .width('100%')

          Text('请输入学号和密码查询成绩')
            .fontSize(24)
            .fontColor(ThemeUtil.subColor(this.darkMode))
            .textAlign(TextAlign.Center)
            .width('100%')

          // 学号输入框
          Row({ space: 10 }) {
            Text('🎓').fontSize(24)
            TextInput({ text: this.studentId, placeholder: '请输入学号' })
              .fontSize(24)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onChange((v: string) => this.studentId = v)
          }
          .height(48)
          .padding({ left: 16, right: 16 })
          .backgroundColor(ThemeUtil.cardBg(this.darkMode))
          .borderRadius(8)

          // 密码输入框
          Row({ space: 10 }) {
            Text('🔒').fontSize(24)
            TextInput({ text: this.gradePassword, placeholder: '请输入密码' })
              .fontSize(24)
              .type(this.showGradePassword ? InputType.Normal : InputType.Password)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onChange((v: string) => this.gradePassword = v)
            Text(this.showGradePassword ? '🙈' : '👁')
              .fontSize(24)
              .onClick(() => { this.showGradePassword = !this.showGradePassword; })
          }
          .height(48)
          .padding({ left: 16, right: 16 })
          .backgroundColor(ThemeUtil.cardBg(this.darkMode))
          .borderRadius(8)

          // 查询按钮
          Button('查询成绩')
            .width('100%')
            .height(48)
            .fontSize(26)
            .fontColor(Color.White)
            .backgroundColor(AppColors.PRIMARY)
            .borderRadius(8)
            .onClick(() => {
              if (this.studentId.trim().length === 0) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入学号' });
                return;
              }
              if (this.gradePassword.trim().length === 0) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入密码' });
                return;
              }
              this.gradeLoggedIn = true;
              this.getUIContext()?.getPromptAction()?.showToast({ message: '查询成功' });
            })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(ThemeUtil.cardBg(this.darkMode))
        .borderRadius(8)
      } else {
        // 已登录 - 成绩列表
        Row() {
          Text(`学号：${this.studentId}`).fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
          Blank()
          Button('刷新成绩').height(36).fontSize(24).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.PRIMARY).borderRadius(8)
            .onClick(() => this.getUIContext()?.getPromptAction()?.showToast({ message: '成绩已刷新' }))
          Button('退出登录').height(36).fontSize(24).fontColor(AppColors.WARNING)
            .backgroundColor(AppColors.WARNING_LIGHT).borderRadius(8).margin({ left: 8 })
            .onClick(() => {
              this.gradeLoggedIn = false;
              this.gradePassword = '';
            })
        }
        .width('100%')

        // 排序
        Row({ space: 8 }) {
          Text('排序：').fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
          ForEach(['成绩', '绩点'], (sort: string) => {
            Text(sort).fontSize(24 * this.fontScale)
              .fontColor(this.gradeSortBy === (sort === '成绩' ? 'score' : 'point') ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor(this.gradeSortBy === (sort === '成绩' ? 'score' : 'point') ? AppColors.PRIMARY : AppColors.DIVIDER)
              .borderRadius(16)
              .onClick(() => {
                if (this.gradeSortBy === (sort === '成绩' ? 'score' : 'point')) {
                  this.gradeSortDesc = !this.gradeSortDesc;
                } else {
                  this.gradeSortBy = (sort === '成绩' ? 'score' : 'point');
                  this.gradeSortDesc = true;
                }
              })
          })
        }

        List() {
          ForEach(this.sortedGrades(), (grade: GradeItem) => {
            ListItem() {
              Row() {
                Column({ space: 6 }) {
                  Text(grade.name).fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                  Text(grade.examTime).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)
                Column({ space: 2 }) {
                  Text(grade.score).fontSize(32 * this.fontScale).fontWeight(FontWeight.Bold)
                    .fontColor(parseInt(grade.score) >= 90 ? AppColors.SUCCESS : parseInt(grade.score) >= 80 ? AppColors.PRIMARY : AppColors.WARNING)
                  Text(`绩点 ${grade.point}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                }
                .alignItems(HorizontalAlign.End)
              }
               .width('100%').padding(16).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
             }
             .margin({ bottom: 10 })
           }, (grade: GradeItem) => grade.name + grade.examTime)
         }
         .width('100%').height(360).scrollBar(BarState.Off)
      }
    }
  }

  private sortedGrades(): GradeItem[] {
    const sorted = [...this.grades];
    sorted.sort((a: GradeItem, b: GradeItem) => {
      const va = this.gradeSortBy === 'score' ? parseInt(a.score) : parseFloat(a.point);
      const vb = this.gradeSortBy === 'score' ? parseInt(b.score) : parseFloat(b.point);
      return this.gradeSortDesc ? vb - va : va - vb;
    });
    return sorted;
  }

  // ===== 图书馆检索 =====
  @Builder LibrarySearch() {
    Column({ space: 14 }) {
      Row({ space: 10 }) {
        Text('🔍').fontSize(24).fontColor(AppColors.PRIMARY)
        TextInput({ text: this.searchText, placeholder: '搜索图书名称/作者/ISBN' })
          .fontSize(24).backgroundColor(Color.Transparent).layoutWeight(1)
          .onChange((v: string) => this.searchText = v)
      }
      .height(48).padding({ left: 16, right: 16 }).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(24)

      // 筛选
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.bookFilters, (f: string) => {
            Text(f).fontSize(24 * this.fontScale)
              .fontColor(f === this.bookFilter ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor(f === this.bookFilter ? AppColors.PRIMARY : AppColors.DIVIDER)
              .borderRadius(16)
              .onClick(() => this.bookFilter = f)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 搜索结果
      List() {
        ForEach(this.filteredBooks(), (book: BookItem) => {
          ListItem() {
            Row({ space: 14 }) {
              // 封面占位
              Column() {
                Text('书').fontSize(28).fontColor(AppColors.PRIMARY).width(60).height(60)
                  .textAlign(TextAlign.Center).backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(8)
              }

              Column({ space: 6 }) {
                Text(book.name).fontSize(26 * this.fontScale).lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY).fontColor(ThemeUtil.titleColor(this.darkMode)).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${book.author} | ${book.isbn}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                Text(`${book.location} · 剩余${book.count}册`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)

              // 收藏按钮
              Text(this.getBookStatusIcon(book.status))
                .fontSize(28)
                .fontColor(book.status === 'saved' ? AppColors.WARNING : ThemeUtil.subColor(this.darkMode))
                .onClick(() => {
                  if (book.status === 'none') {
                    book.status = 'saved';
                    this.getUIContext()?.getPromptAction()?.showToast({ message: '已收藏' });
                  } else if (book.status === 'saved') {
                    book.status = 'want';
                    this.getUIContext()?.getPromptAction()?.showToast({ message: '标记想看' });
                  } else if (book.status === 'want') {
                    book.status = 'borrowed';
                    this.getUIContext()?.getPromptAction()?.showToast({ message: '标记已借' });
                  } else {
                    book.status = 'none';
                    this.getUIContext()?.getPromptAction()?.showToast({ message: '取消标记' });
                  }
                })
            }
            .width('100%').padding(16).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          }
           .margin({ bottom: 10 })
         }, (book: BookItem) => book.name + book.isbn)
       }
       .width('100%').height(380).scrollBar(BarState.Off)
    }
  }

  private getBookStatusIcon(status: string): string {
    switch (status) {
      case 'saved': return '♥';
      case 'borrowed': return '📖';
      case 'want': return '⭐';
      default: return '♡';
    }
  }

  private filteredBooks(): BookItem[] {
    let result = this.books;
    if (this.searchText.trim().length > 0) {
      const kw = this.searchText.trim().toLowerCase();
      result = result.filter((b: BookItem) =>
        b.name.toLowerCase().includes(kw) || b.author.toLowerCase().includes(kw) || b.isbn.includes(kw)
      );
    }
    if (this.bookFilter === '已收藏') result = result.filter((b: BookItem) => b.status === 'saved');
    else if (this.bookFilter === '想读') result = result.filter((b: BookItem) => b.status === 'want');
    else if (this.bookFilter === '已借') result = result.filter((b: BookItem) => b.status === 'borrowed');
    return result;
  }

  // ===== 学习资料 =====
  @Builder Materials() {
    Column({ space: 14 }) {
      Grid() {
        ForEach(this.materials, (m: MaterialItem) => {
          GridItem() {
            Column({ space: 10 }) {
              Text(m.icon).fontSize(40)
              Text(m.name).fontSize(24 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
            }
            .width('100%').height(100).justifyContent(FlexAlign.Center)
            .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
            .onClick(() => this.getUIContext()?.getPromptAction()?.showToast({ message: `${m.name}：查看详情` }))
          }
         }, (m: MaterialItem) => m.name)
       }
       .columnsTemplate('1fr 1fr')
      .rowsGap(12).columnsGap(12)

      Button('上传本地资料').width('100%').height(48).fontSize(26 * this.fontScale)
        .fontColor(AppColors.BG_CARD).backgroundColor(AppColors.PRIMARY).borderRadius(8)
        .onClick(() => this.getUIContext()?.getPromptAction()?.showToast({ message: '本地文件选择功能开发中' }))
    }
  }

  // 发布课程提醒通知
  private async publishCourseNotification(course: CourseItem): Promise<void> {
    try {
      // 请求通知权限
      const enabled = await notificationManager.isNotificationEnabled();
      if (!enabled) {
        await notificationManager.requestEnableNotification();
      }
      // 创建通知请求
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '课程提醒',
            text: `${course.name} 即将开始`,
            additionalText: `${course.time} · ${course.place}`
          }
        }
      };
      await notificationManager.publish(notificationRequest);
      this.getUIContext()?.getPromptAction()?.showToast({ message: `已设置${course.name}提醒` });
    } catch (e) {
      console.error('publishCourseNotification error: ' + JSON.stringify(e));
      this.getUIContext()?.getPromptAction()?.showToast({ message: '通知权限未开启，请在设置中开启' });
    }
  }
}
