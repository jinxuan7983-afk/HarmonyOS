import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { TodoItemFull, CollectionItem } from '../../common/constants/DataModels';
import { DataManager, UserInfoData } from '../../utils/DataManager';

/**
 * 我的Tab内容组件
 * 从独立页面改为组件内嵌，由Home主容器通过Tabs切换
 * darkMode和fontScale使用@Link双向绑定，因为本组件会修改这些值
 */

@Component
export struct ProfileContent {
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @StorageLink('profileUpdated') @Watch('onProfileUpdated') profileUpdated: number = 0;
  onSwitchTab?: (index: number) => void;
  @State nickname: string = '校园助手用户';
  @State studentId: string = '20260001';
  @State college: string = '信息工程学院';
  @State major: string = '软件工程';
  @State avatarUri: string = '';

  @State showCollections: boolean = false;
  @State collectionFilter: string = '全部';
  @State collections: CollectionItem[] = [
    { title: '关于期末考试安排的通知', category: '公告', time: '06-09', detail: '考试周安排已发布' },
    { title: '人工智能通识讲座报名开启', category: '资讯', time: '06-07', detail: '面向全校学生开放' },
    { title: 'HarmonyOS 应用开发实战', category: '图书', time: '06-05', detail: '开放原子教材组' },
    { title: '香辣鸡腿饭', category: '美食', time: '06-03', detail: '一食堂二楼 · ★5' }
  ];
  private collectionCategories: string[] = ['全部', '公告', '资讯', '图书', '美食'];

  @State refreshing: boolean = false;
  @State batchMode: boolean = false;
  @State selectedIds: Set<number> = new Set();
  @State todoInput: string = '';
  @State todoCategory: string = '学习';
  @State todoRemindTime: string = '';
  @State todoIdCounter: number = 100;
  @State todoCount: number = 5;
  @State todoVersion: number = 0;
  @State todos: TodoItemFull[] = [
    { id: 1, title: '完成移动开发实验报告', category: '学习', done: false, remindTime: '18:00' },
    { id: 2, title: '18:30 去图书馆还书', category: '生活', done: false, remindTime: '18:00' },
    { id: 3, title: '整理课程表演示数据', category: '学习', done: true, remindTime: '14:00' },
    { id: 4, title: '准备软件工程期末复习', category: '学习', done: false, remindTime: '20:00' },
    { id: 5, title: '参加社团活动策划会', category: '其他', done: false, remindTime: '16:30' }
  ];
  private todoCategories: string[] = ['学习', '生活', '其他'];

  @State selectedFont: string = 'normal';
  @State courseNotice: boolean = true;
  @State announcementNotice: boolean = true;
  @State todoNotice: boolean = true;
  @State cacheSize: string = '64.2MB';
  @State showCacheDialog: boolean = false;

  async aboutToAppear(): Promise<void> {
    const userInfo: UserInfoData = await DataManager.loadUserInfo();
    this.nickname = userInfo.nickname;
    this.studentId = userInfo.account;
    this.college = userInfo.college;
    this.major = userInfo.major;
    this.selectedFont = await DataManager.loadSettingString('fontSize', 'normal');
    this.courseNotice = await DataManager.loadSettingBoolean('courseNotice', true);
    this.announcementNotice = await DataManager.loadSettingBoolean('announcementNotice', true);
    this.todoNotice = await DataManager.loadSettingBoolean('todoNotice', true);
    const savedTodos = await DataManager.loadTodosFull();
    if (savedTodos.length > 0) {
      this.todos = savedTodos as TodoItemFull[];
      if (this.todos.length > 0) {
        this.todoIdCounter = Math.max(...this.todos.map((t: TodoItemFull) => t.id));
      }
    }
    const savedCollections = await DataManager.loadCollections();
    if (savedCollections.length > 0) {
      this.collections = savedCollections as CollectionItem[];
    }
    this.avatarUri = await DataManager.loadAvatarUri();
  }

  onProfileUpdated(): void {
    if (this.profileUpdated <= 0) return;
    DataManager.loadUserInfo().then((userInfo: UserInfoData) => {
      this.nickname = userInfo.nickname;
      this.studentId = userInfo.account;
      this.college = userInfo.college;
      this.major = userInfo.major;
    });
    DataManager.loadAvatarUri().then((uri: string) => {
      this.avatarUri = uri;
    });
  }

  async aboutToDisappear(): Promise<void> {
    await DataManager.saveTodosFull(this.todos);
    await DataManager.saveCollections(this.collections);
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.refreshing }) {
        Scroll() {
          Column({ space: 24 }) {
            // 导航栏标题（右侧设置图标）
            Row() {
              Text('我的')
                .fontSize(28).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
                .lineHeight(28 * AppColors.LINE_HEIGHT_TITLE_L)
                .layoutWeight(1)
              Text('⚙')
                .fontSize(26)
                .fontColor(AppColors.PRIMARY)
                .width(40).height(40).textAlign(TextAlign.Center)
                .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(20)
                .onClick(() => router.pushUrl({ url: 'pages/profile/Settings' }))
            }
            .width('100%')

            // 个人信息卡片
            this.ProfileCard()

            // 我的收藏
            this.FunctionItem('⭐', '我的收藏', () => { this.showCollections = !this.showCollections; })
            if (this.showCollections) { this.CollectionsPanel() }

            // 我的待办
            this.FunctionItem('✅', '我的待办', () => { this.batchMode = !this.batchMode; })
            this.TodoInput()
            if (this.batchMode) { this.BatchActions() }
            this.TodoList()

            // 功能列表
            Column({ space: 0 }) {
              this.FunctionItem('📅', '我的课程', () => { if (this.onSwitchTab) this.onSwitchTab(2); })
              Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
              this.FunctionItem('📊', '我的成绩', () => { if (this.onSwitchTab) this.onSwitchTab(2); })
              Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
              this.FunctionItem('📋', '失物发布', () => router.pushUrl({ url: 'pages/life/LostPublish' }))
              Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
              this.FunctionItem('❓', '帮助中心', () => this.getUIContext()?.getPromptAction()?.showToast({ message: '帮助中心建设中' }))
              Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
              this.FunctionItem('💬', '意见反馈', () => this.getUIContext()?.getPromptAction()?.showToast({ message: '感谢反馈！' }))
            }
            .width('100%').padding({ top: 8, bottom: 8 })
            .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

            // 设置模块
            Text('应用设置').fontSize(28 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode)).alignSelf(ItemAlign.Start)
            this.SettingsPanel()

            // 退出登录
            this.LogoutButton()

            // 底部信息
            this.FooterInfo()
          }
          .width('100%').padding({ left: 20, right: 20, top: 18, bottom: 24 })
        }
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        this.refreshing = true;
        setTimeout(() => { this.refreshing = false; try { this.getUIContext()?.getPromptAction()?.showToast({ message: '刷新完成' }); } catch (e) {} }, 1500);
      })
      .refreshOffset(64).layoutWeight(1)

      // 缓存清理确认弹窗
      if (this.showCacheDialog) {
        this.CacheDialog()
      }
    }
    .width('100%').height('100%')
  }

  // ===== 个人信息卡片 =====
  @Builder ProfileCard() {
    Row({ space: 16 }) {
      // 头像 80px圆形 - 点击跳转编辑页
      Stack() {
        Image(this.avatarUri || $r('app.media.logo'))
          .width(80).height(80).borderRadius(40).border({ width: 3, color: AppColors.PRIMARY })
        Text('📷').fontSize(24 * this.fontScale)
          .width(80).height(80).borderRadius(40).backgroundColor('#33000000')
          .textAlign(TextAlign.Center)
      }
      .onClick(() => this.gotoProfileEdit())

      Column({ space: 4 }) {
        Text(this.nickname).fontSize(28 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode))
        Text(`${this.studentId} · ${this.college}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
        Text(this.major).fontSize(24 * this.fontScale).fontColor(AppColors.PRIMARY)
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)

      Button('编辑')
        .height(36).fontSize(24 * this.fontScale)
        .fontColor(AppColors.PRIMARY).backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(8)
        .onClick(() => this.gotoProfileEdit())
    }
    .width('95%').padding(20).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
    .shadow({ radius: 6, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }

  private gotoProfileEdit(): void {
    router.pushUrl({
      url: 'pages/profile/ProfileEdit',
      params: {
        nickname: this.nickname,
        studentId: this.studentId,
        college: this.college,
        major: this.major,
        avatarUri: this.avatarUri
      }
    });
  }

  // ===== 功能项（48px高，左侧图标24px+文字26sp+右箭头） =====
  @Builder FunctionItem(icon: string, label: string, action: () => void) {
    Row() {
      Text(icon).fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
      Text(label).fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode)).layoutWeight(1).margin({ left: 10 })
      Text('›').fontSize(26 * this.fontScale).fontColor(AppColors.PRIMARY)
    }
    .width('100%').height(48).padding({ left: 12, right: 12 })
    .borderRadius(8)
    .onClick(() => action())
  }

  // ===== 收藏面板 =====
  @Builder CollectionsPanel() {
    Column({ space: 10 }) {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.collectionCategories, (cat: string) => {
            Text(cat).fontSize(24 * this.fontScale)
              .fontColor(cat === this.collectionFilter ? AppColors.BG_CARD : ThemeUtil.subColor(this.darkMode))
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .backgroundColor(cat === this.collectionFilter ? AppColors.PRIMARY : (this.darkMode ? AppColors.BG_DARK_DIVIDER : AppColors.DIVIDER))
              .borderRadius(16)
              .onClick(() => this.collectionFilter = cat)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      if (this.getFilteredCollections().length === 0) {
        Text('暂无收藏').fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode)).padding(16)
      }

      ForEach(this.getFilteredCollections(), (item: CollectionItem, idx: number) => {
        Row() {
          Text(this.getCollectionIcon(item.category)).fontSize(26 * this.fontScale)
          Column({ space: 4 }) {
            Text(item.title).fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode)).maxLines(1).lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
            Text(item.detail).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
          }
          .alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 10 })
          Text(item.time).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
          Text('✕').fontSize(24 * this.fontScale).fontColor(AppColors.WARNING).margin({ left: 10 })
            .onClick(() => { this.collections.splice(idx, 1); this.getUIContext()?.getPromptAction()?.showToast({ message: '已取消收藏' }); })
        }
        .padding(14).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          .margin({ bottom: 8 })
         }, (item: CollectionItem) => item.title + item.time)
    }
    .padding(14).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  private getFilteredCollections(): CollectionItem[] {
    if (this.collectionFilter === '全部') return this.collections;
    return this.collections.filter((c: CollectionItem) => c.category === this.collectionFilter);
  }

  private getCollectionIcon(cat: string): string {
    const map: Record<string, string> = { '公告': '📋', '资讯': '📰', '图书': '📚', '美食': '🍽' };
    return map[cat] || '📌';
  }

  // ===== 待办输入 =====
  @Builder TodoInput() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        TextInput({ text: this.todoInput, placeholder: '输入待办内容...' })
          .height(48).fontSize(26 * this.fontScale).backgroundColor(AppColors.BG_CARD).borderRadius(8).layoutWeight(1)
          .onChange((v: string) => this.todoInput = v)
      }

      Row({ space: 8 }) {
        ForEach(this.todoCategories, (cat: string) => {
          Text(cat).fontSize(24 * this.fontScale)
            .fontColor(cat === this.todoCategory ? AppColors.BG_CARD : ThemeUtil.subColor(this.darkMode))
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(cat === this.todoCategory ? AppColors.PRIMARY : (this.darkMode ? AppColors.BG_DARK_DIVIDER : AppColors.DIVIDER))
            .borderRadius(16)
            .onClick(() => this.todoCategory = cat)
        })
        TextInput({ text: this.todoRemindTime, placeholder: '提醒时间' })
          .height(36).fontSize(24 * this.fontScale).width(90).backgroundColor(AppColors.BG_CARD).borderRadius(8).padding({ left: 8, right: 8 })
          .onChange((v: string) => this.todoRemindTime = v)
        Button('添加').height(36).fontSize(24 * this.fontScale).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.PRIMARY).borderRadius(8)
          .onClick(() => {
            if (!this.todoInput.trim()) { this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入待办内容' }); return; }
            this.todoIdCounter += 1;
            this.todos.unshift({
              id: this.todoIdCounter,
              title: this.todoInput.trim(),
              category: this.todoCategory, done: false,
              remindTime: this.todoRemindTime || '—'
            });
            this.todoVersion += 1;
            this.todoInput = ''; this.todoRemindTime = '';
              this.todoVersion += 1;
          })
      }
    }
    .padding(14).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  @Builder BatchActions() {
    Row({ space: 8 }) {
      Button('全选').height(36).fontSize(24 * this.fontScale).fontColor(AppColors.PRIMARY).backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(8)
        .onClick(() => { this.todos.forEach((t: TodoItemFull) => this.selectedIds.add(t.id));
          this.selectedIds = new Set(this.selectedIds); })
      Button('取消全选').height(36).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
        .backgroundColor(this.darkMode ? AppColors.BG_DARK_DIVIDER : AppColors.DIVIDER).borderRadius(8)
        .onClick(() => { this.selectedIds.clear(); this.selectedIds = new Set(); })
      Blank()
      Button('标记完成').height(36).fontSize(24 * this.fontScale).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.SUCCESS).borderRadius(8)
        .onClick(() => {
          this.todos.forEach((t: TodoItemFull) => { if (this.selectedIds.has(t.id)) t.done = true; });
          this.todoVersion += 1;
          this.selectedIds.clear(); this.getUIContext()?.getPromptAction()?.showToast({ message: '已批量标记完成' });
        })
      Button('删除').height(36).fontSize(24 * this.fontScale).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.DANGER).borderRadius(8)
        .onClick(() => {
          this.todos = this.todos.filter((t: TodoItemFull) => !this.selectedIds.has(t.id));
          this.todoVersion += 1;
          this.selectedIds.clear(); this.getUIContext()?.getPromptAction()?.showToast({ message: '已批量删除' });
        })
    }
  }

  @Builder TodoList() {
    if (this.todos.length === 0) {
      Text('暂无待办').fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode)).padding(16)
        .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8).width('100%')
    } else {
      List() {
        ForEach(this.todos.slice(0, this.todoCount), (todo: TodoItemFull, idx: number) => {
          ListItem() {
            Row() {
              if (this.batchMode) {
                Checkbox().select(this.selectedIds.has(todo.id)).selectedColor(AppColors.PRIMARY)
                  .onChange((c: boolean) => {
                    if (c) this.selectedIds.add(todo.id); else this.selectedIds.delete(todo.id);
                    this.selectedIds = new Set(this.selectedIds);
                  }).margin({ right: 8 })
              }
              Checkbox().select(todo.done).selectedColor(AppColors.SUCCESS)
                 .onChange((c: boolean) => { todo.done = c; this.todoVersion += 1; })
              Column({ space: 4 }) {
                Text(todo.title)
                  .fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                  .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
                  .decoration({ type: todo.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                Row({ space: 8 }) {
                  Text(todo.category).fontSize(24 * this.fontScale).fontColor(AppColors.BG_CARD)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .backgroundColor(todo.category === '学习' ? AppColors.PRIMARY : (todo.category === '生活' ? AppColors.SUCCESS : AppColors.WARNING))
                    .borderRadius(4)
                  Text(`⏰ ${todo.remindTime}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                }
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 8 })
              if (!this.batchMode) {
                Text('删').fontSize(24 * this.fontScale).fontColor(AppColors.WARNING).backgroundColor(AppColors.WARNING_LIGHT).borderRadius(8)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .onClick(() => {
                    const realIdx = this.todos.indexOf(todo);
                    if (realIdx >= 0) { this.todos.splice(realIdx, 1); this.todoVersion += 1; }
                  })
              }
            }
            .padding(14).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          }
          .margin({ bottom: 8 })
        })

        if (this.todoCount < this.todos.length) {
          ListItem() {
            Text('加载更多...').fontSize(24 * this.fontScale).fontColor(AppColors.PRIMARY)
              .width('100%').height(48).textAlign(TextAlign.Center)
              .onClick(() => { this.todoCount = Math.min(this.todoCount + 5, this.todos.length); })
          }
        }
      }
      .width('100%').height(260).scrollBar(BarState.Off)
    }
  }

  // ===== 设置面板（入口按钮，跳转独立设置页） =====
  @Builder SettingsPanel() {
    Column({ space: 0 }) {
      Row() {
        Text('⚙').fontSize(24).fontColor(AppColors.PRIMARY).width(28).textAlign(TextAlign.Center)
        Text('打开设置').fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode)).layoutWeight(1).margin({ left: 10 })
        Text('›').fontSize(26 * this.fontScale).fontColor(AppColors.PRIMARY)
      }
      .width('100%').height(56).padding({ left: 16, right: 16 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/profile/Settings' });
      })
    }
    .width('100%').backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  // ===== 缓存清理确认弹窗 =====
  @Builder
  CacheDialog() {
    Column() {
      Column({ space: 18 }) {
        Text('🗑 清理缓存').fontSize(28).fontWeight(700).fontColor(AppColors.TEXT_PRIMARY)
        Text('确定要清理本地缓存吗？\n将清除图片、音频及数据文件。').fontSize(24).fontColor(AppColors.TEXT_TERTIARY).lineHeight(36).textAlign(TextAlign.Center)
        Text(`当前缓存：${this.cacheSize}`).fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
        Row({ space: 12 }) {
          Button('取消').layoutWeight(1).height(48).fontSize(26).fontColor(AppColors.TEXT_SECONDARY).backgroundColor(AppColors.DIVIDER).borderRadius(8)
            .onClick(() => { this.showCacheDialog = false; })
          Button('确认清理').layoutWeight(1).height(48).fontSize(26).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.WARNING).borderRadius(8)
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

  // ===== 退出登录 =====
  @Builder
  LogoutButton() {
    Button('退出登录')
      .width('100%')
      .height(48)
      .fontSize(26 * this.fontScale)
      .fontColor(AppColors.DANGER)
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))
      .border({ width: 1, color: AppColors.DANGER })
      .borderRadius(8)
      .margin({ top: 8 })
      .onClick(() => this.handleLogout())
  }

  private async handleLogout(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(this), 'user_info');
      await prefs.put('loggedIn', false);
      await prefs.flush();
    } catch (_err) {
      // 忽略
    }
    this.getUIContext()?.getPromptAction()?.showToast({ message: '已退出登录' });
    router.replaceUrl({
      url: 'pages/auth/Login',
      params: { fromLogout: true }
    });
  }

  // ===== 底部信息 =====
  @Builder FooterInfo() {
    Column({ space: 8 }) {
      Text('版本号 V1.0.0（HarmonyOS NEXT）')
        .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
      Text('信息工程学院 软件工程 开发团队')
        .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
      Text('©2026 高校校园助手 保留所有权利')
        .fontSize(20 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
    }
    .width('100%').alignItems(HorizontalAlign.Center).padding({ top: 10, bottom: 10 })
  }
}
