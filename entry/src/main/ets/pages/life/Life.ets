import router from '@ohos.router';
import { picker } from '@kit.CoreFileKit';
import { window } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { resourceManager } from '@kit.LocalizationKit';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { LostItem, FoodItem, SongItem } from '../../common/constants/DataModels';
import { DataManager } from '../../utils/DataManager';

// 快递物流信息
interface ExpressInfo {
  time: string;
  location: string;
  desc: string;
}

// 校历事件
interface CalendarEvent {
  date: string;
  title: string;
  type: string;
}

/**
 * 生活服务Tab内容组件
 * 从独立页面改为组件内嵌，由Home主容器通过Tabs切换
 */

@Component
export struct LifeContent {
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State tab: string = '失物招领';
  @State searchText: string = '';
  @State refreshing: boolean = false;

  // 失物招领
  @State lostFilterType: string = '全部';
  @State lostFilterCat: string = '全部';
  @State lostItems: LostItem[] = [
    { title: '黑色校园卡', type: '失物', category: '校园卡', place: '一食堂二楼', time: '今天 12:20', desc: '黑色卡面，有校徽图案', phone: '138****2026', imageUri: '' },
    { title: '蓝色雨伞', type: '拾物', category: '衣物', place: '图书馆门口', time: '昨天 18:30', desc: '深蓝色长柄伞', phone: '156****0918', imageUri: '' },
    { title: '无线耳机盒', type: '失物', category: '电子产品', place: '信工楼 A306', time: '周一 10:00', desc: '白色充电盒', phone: '188****6621', imageUri: '' },
    { title: '校园卡一张', type: '拾物', category: '校园卡', place: '操场篮球场', time: '周二 16:00', desc: '普通蓝色校园卡', phone: '139****5523', imageUri: '' },
    { title: '双肩背包', type: '失物', category: '书包', place: '二食堂', time: '周三 11:30', desc: '灰色双肩包', phone: '150****7788', imageUri: '' }
  ];

  // 校园美食
  @State foodFilter: string = '全部';
  @State foods: FoodItem[] = [
    { name: '香辣鸡腿饭', place: '一食堂二楼', feature: '微辣、出餐快、配小菜', score: 5, collected: true, imageUri: '' },
    { name: '番茄牛腩面', place: '二食堂窗口6', feature: '汤底浓郁、牛腩软烂', score: 4, collected: false, imageUri: '' },
    { name: '轻食沙拉碗', place: '新食堂', feature: '低脂、可自选配料', score: 4, collected: false, imageUri: '' },
    { name: '红烧排骨饭', place: '一食堂一楼', feature: '排骨软烂、酱香浓郁', score: 5, collected: true, imageUri: '' },
    { name: '麻辣香锅', place: '校园小吃街', feature: '自选菜、麻辣鲜香', score: 4, collected: false, imageUri: '' }
  ];
  @State foodImageUri: string = '';

  // 音乐播放器
  @StorageLink('musicPlaying') @Watch('onPlayingChanged') playing: boolean = false;
  @StorageLink('musicSelectedIndex') @Watch('onMusicSelected') selectedSong: number = 0;
  @StorageLink('musicProgress') currentProgress: number = 0;
  @StorageLink('musicSongName') musicSongName: string = '';
  @StorageLink('musicSinger') musicSinger: string = '';
  @StorageLink('musicDuration') musicDuration: number = 0;
  @State hasAudioFile: boolean = false;
  @State floatWindowOn: boolean = false;
  @State songs: SongItem[] = [
    { name: 'Campus Morning', singer: 'Local Demo', duration: 10, uri: 'campus_morning.wav' },
    { name: 'Library Light', singer: 'Harmony Band', duration: 10, uri: 'library_light.wav' },
    { name: 'After Class', singer: 'Student Mix', duration: 10, uri: 'after_class.wav' }
  ];
  @State foodVersion: number = 0;
  @State lostVersion: number = 0;

  // 计算器
  @State showCalculator: boolean = false;
  @State calcDisplay: string = '0';
  @State calcOperator: string = '';
  @State calcPrev: number = 0;
  @State calcJustEvaluated: boolean = false;
  @State calcWaitingForOperand: boolean = false;

  // 倒计时
  @State showCountdown: boolean = false;
  @State countdownMinutes: number = 25;
  @State countdownSeconds: number = 0;
  @State countdownRunning: boolean = false;
  @State countdownRemaining: number = 0;

  // 快递查询
  @State showExpress: boolean = false;
  @State expressNumber: string = '';
  @State expressResult: ExpressInfo[] = [];

  // 校历
  @State showCalendar: boolean = false;

  private progressTimer: number = 0;
  private countdownTimer: number = 0;
  private avPlayer?: media.AVPlayer;
  private isAVPlayerReady: boolean = false;
  private avDuration: number = 0;
  private musicFloatWindow?: window.Window;

  private lostFilters: string[] = ['全部', '失物', '拾物', '校园卡', '电子产品'];
  private foodCategories: string[] = ['全部', '中餐', '面食', '轻食', '小吃'];
  private lastMusicIndex: number = -1;

  onMusicSelected(): void {
    if (this.selectedSong === this.lastMusicIndex) return;
    this.lastMusicIndex = this.selectedSong;
    if (this.selectedSong >= 0 && this.selectedSong < this.songs.length) {
      this.selectSong(this.selectedSong);
    }
  }

  async aboutToAppear(): Promise<void> {
    console.info('LifeContent aboutToAppear');
    try {
      const savedLost = await DataManager.loadLostItems();
      if (savedLost && (savedLost as LostItem[]).length > 0) this.lostItems = savedLost as LostItem[];
      const savedFoods = await DataManager.loadFoods();
      if (savedFoods && (savedFoods as FoodItem[]).length > 0) this.foods = savedFoods as FoodItem[];
      const savedSongs = await DataManager.loadSongs();
      if (savedSongs && (savedSongs as SongItem[]).length > 0) this.songs = savedSongs as SongItem[];
    } catch (e) {
      console.error('LifeContent aboutToAppear error: ' + JSON.stringify(e));
    }
    this.syncMusicState();
  }

  async aboutToDisappear(): Promise<void> {
    this.stopProgress();
    this.stopCountdown();
    if (this.avPlayer) {
      try {
        await this.avPlayer.stop();
        await this.avPlayer.release();
      } catch (_) {}
      this.avPlayer = undefined;
    }
    this.closeMusicFloatWindow();
    await DataManager.saveLostItems(this.lostItems);
    await DataManager.saveFoods(this.foods);
    await DataManager.saveSongs(this.songs);
  }

  build() {
    Column() {
      // 导航栏（无返回箭头，白色背景）
      Row() {
        Text('生活服务').fontSize(30).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode)).lineHeight(30 * AppColors.LINE_HEIGHT_TITLE_L)
      }
      .width('100%').padding({ left: 20, right: 20, top: 14, bottom: 10 }).backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Refresh({ refreshing: $$this.refreshing }) {
        Scroll() {
          Column({ space: 16 }) {
            if (this.showCalculator) {
              this.CalculatorPanel()
            } else if (this.showCountdown) {
              this.CountdownPanel()
            } else if (this.showExpress) {
              this.ExpressPanel()
            } else if (this.showCalendar) {
              this.CalendarPanel()
            } else {
              this.EntryGrid()
              if (this.tab === '失物招领') this.LostAndFound()
              else if (this.tab === '校园美食') this.FoodList()
              else if (this.tab === '音乐播放') this.MusicPlayer()
              else this.ToolsPanel()
            }
          }
          .width('100%').padding({ left: 20, right: 20, top: 12, bottom: 18 })
        }
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        this.refreshing = true;
        setTimeout(() => {
          this.refreshing = false;
          try { this.getUIContext()?.getPromptAction()?.showToast({ message: '刷新完成' }); } catch (_) {}
        }, 1500);
      })
      .refreshOffset(64).layoutWeight(1)
    }
    .width('100%').height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // ===== 2行×2列分类入口 =====
  @Builder EntryGrid() {
    Grid() {
      GridItem() { this.EntryCard('失物招领', '📋') }
      GridItem() { this.EntryCard('校园美食', '🍜') }
      GridItem() { this.EntryCard('音乐播放', '🎵') }
      GridItem() { this.EntryCard('校园工具', '🔧') }
    }
    .columnsTemplate('1fr 1fr').columnsGap('2%').rowsGap(12).width('100%')
  }

  @Builder EntryCard(label: string, icon: string) {
    Column({ space: 10 }) {
      Text(icon).fontSize(48)
      Text(label).fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
    }
    .width('100%').aspectRatio(1.5)
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
    .border({ width: this.tab === label ? 2 : 1, color: this.tab === label ? AppColors.PRIMARY : AppColors.BORDER })
    .onClick(() => { this.tab = label; })
  }

  // ===== 失物招领 =====
  @Builder
  SwipeDeleteButton() {
    Button('删除').fontColor(AppColors.BG_CARD).backgroundColor(AppColors.WARNING)
  }

  @Builder LostAndFound() {
    Column({ space: 12 }) {
      // 发布按钮（暖橙48px圆角8px）
      Button('📋 发布信息')
        .height(48).fontSize(26).fontColor(AppColors.BG_CARD)
        .backgroundColor(AppColors.WARNING).borderRadius(8).width('100%')
        .onClick(() => router.pushUrl({ url: 'pages/life/LostPublish' }))

      // 搜索栏
      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(24)
          .fontColor([AppColors.PRIMARY])
        TextInput({ text: this.searchText, placeholder: '搜索物品/地点/描述' })
          .fontSize(24).backgroundColor(Color.Transparent).layoutWeight(1)
          .onChange((v: string) => this.searchText = v)
      }
      .height(48).padding({ left: 16, right: 16 }).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(24)

      // 筛选标签（一行：全部/失物/拾物/校园卡/电子产品）
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.lostFilters, (f: string) => {
            Text(f).fontSize(24)
              .fontColor(
                ((f === '失物' || f === '拾物') && this.lostFilterType === f) ||
                ((f === '校园卡' || f === '电子产品') && this.lostFilterCat === f) ||
                (f === '全部' && this.lostFilterType === '全部' && this.lostFilterCat === '全部')
                  ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(
                ((f === '失物' || f === '拾物') && this.lostFilterType === f) ? AppColors.PRIMARY :
                ((f === '校园卡' || f === '电子产品') && this.lostFilterCat === f) ? AppColors.WARNING :
                (f === '全部' && this.lostFilterType === '全部' && this.lostFilterCat === '全部') ? AppColors.PRIMARY :
                AppColors.DIVIDER)
              .borderRadius(8)
              .onClick(() => {
                if (f === '全部') { this.lostFilterType = '全部'; this.lostFilterCat = '全部'; }
                else if (f === '失物' || f === '拾物') { this.lostFilterType = f; this.lostFilterCat = '全部'; }
                else { this.lostFilterCat = f; this.lostFilterType = '全部'; }
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 物品列表（64x64图片+名称+时间+地点）
      List() {
         ForEach(this.getFilteredLostItems(), (item: LostItem, idx: number) => {
           ListItem() {
             Row({ space: 12 }) {
               Image(item.imageUri || $r('app.media.foreground'))
                 .width(64).height(64).objectFit(ImageFit.Cover).borderRadius(8).backgroundColor(AppColors.BG_PAGE)
               Column({ space: 4 }) {
                 Row() {
                   Text(item.title).fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode)).lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
                   Text(item.type).fontSize(24)
                     .fontColor(item.type === '失物' ? AppColors.WARNING : AppColors.SUCCESS)
                     .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                     .backgroundColor(item.type === '失物' ? AppColors.WARNING_LIGHT : AppColors.SUCCESS_LIGHT).borderRadius(4).margin({ left: 8 })
                 }
                 Text(`${item.time} · ${item.place}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                 Text(`📞 ${item.phone}`).fontSize(24).fontColor(AppColors.PRIMARY)
               }
               .alignItems(HorizontalAlign.Start).layoutWeight(1)
             }
             .padding(14).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
           }
           .margin({ bottom: 10 })
           .swipeAction({
             end: {
               builder: this.SwipeDeleteButton,
               onAction: () => {
                 const realIdx = this.lostItems.indexOf(item);
                 if (realIdx >= 0) { this.lostItems.splice(realIdx, 1); this.lostVersion += 1; this.getUIContext()?.getPromptAction()?.showToast({ message: '已删除' }); }
               }
             }
           })
         }, (item: LostItem) => item.title + item.time)
      }
      .width('100%')
    }
  }

  private getFilteredLostItems(): LostItem[] {
    let arr = [...this.lostItems];
    if (this.lostFilterType !== '全部') arr = arr.filter((i: LostItem) => i.type === this.lostFilterType);
    else if (this.lostFilterCat !== '全部') arr = arr.filter((i: LostItem) => i.category === this.lostFilterCat);
    if (this.searchText.trim()) {
      const kw = this.searchText.trim().toLowerCase();
      arr = arr.filter((i: LostItem) => i.title.toLowerCase().includes(kw) || i.place.toLowerCase().includes(kw) || i.desc.toLowerCase().includes(kw));
    }
    return arr;
  }

  // ===== 校园美食 =====
  @Builder FoodList() {
    Column({ space: 12 }) {
      // 推荐 + 上传图片
      Row({ space: 8 }) {
        Button('+ 推荐美食').height(48).fontSize(26).fontColor(AppColors.BG_CARD)
          .backgroundColor(AppColors.WARNING).borderRadius(8).layoutWeight(1)
          .onClick(() => {
            this.foods.unshift({ name: '新推荐美食', place: '校园美食街', feature: '特色美味', score: 3, collected: false, imageUri: this.foodImageUri });
            this.foodImageUri = '';
            this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟添加美食推荐' });
          })
        Button('📷 上传图片').height(48).fontSize(24).fontColor(AppColors.PRIMARY)
          .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(8).padding({ left: 14, right: 14 })
          .onClick(() => this.pickFoodImage())
      }

      if (this.foodImageUri.length > 0) {
        Row({ space: 8 }) {
          Image($r('app.media.foreground')).width(72).height(72).objectFit(ImageFit.Cover).borderRadius(8)
          Text('点击上方按钮推荐美食').fontSize(24).fontColor(ThemeUtil.subColor(this.darkMode))
        }
      }

      // 分类筛选
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.foodCategories, (cat: string) => {
            Text(cat).fontSize(24)
              .fontColor(cat === this.foodFilter ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .backgroundColor(cat === this.foodFilter ? AppColors.WARNING : AppColors.WARNING_LIGHT).borderRadius(8)
              .onClick(() => this.foodFilter = cat)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 美食列表（图片150px+名称+食堂+评分+右侧收藏按钮）
      List() {
         ForEach(this.getFilteredFoods(), (food: FoodItem, idx: number) => {
          ListItem() {
            Column({ space: 8 }) {
              Image(food.imageUri || $r('app.media.background'))
                .width('100%').height(150).objectFit(ImageFit.Cover).borderRadius(8)

              Row() {
                Column({ space: 4 }) {
                  Text(food.name).fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode)).lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
                  Text(`${food.place} · ${food.feature}`).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)
                Column({ space: 4 }) {
                  this.StarRating(food.score, idx)
                  // 收藏按钮（右侧）
                  Text(food.collected ? '❤' : '🤍').fontSize(28)
                    .onClick(() => {
                      this.foods[idx].collected = !this.foods[idx].collected;
                      this.foodVersion += 1;
                      this.getUIContext()?.getPromptAction()?.showToast({ message: this.foods[idx].collected ? '已收藏' : '已取消收藏' });
                    })
                }
                .alignItems(HorizontalAlign.Center)
              }
            }
            .padding(14).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          }
          .margin({ bottom: 12 })
         }, (food: FoodItem) => food.name)
      }
      .width('100%')
    }
  }

  @Builder StarRating(score: number, idx: number) {
    Row({ space: 2 }) {
      ForEach([1, 2, 3, 4, 5], (star: number) => {
        Text(star <= score ? '★' : '☆').fontSize(26).fontColor(AppColors.WARNING)
          .onClick(() => {
            this.foods[idx].score = star;
            this.getUIContext()?.getPromptAction()?.showToast({ message: `已评分 ${star} 星` });
          })
      })
    }
  }

  private getFilteredFoods(): FoodItem[] {
    if (this.foodFilter === '全部') return this.foods;
    return this.foods.filter((f: FoodItem) => {
      if (this.foodFilter === '中餐') return f.name.includes('饭') || f.place.includes('食堂');
      if (this.foodFilter === '面食') return f.name.includes('面');
      if (this.foodFilter === '轻食') return f.name.includes('轻食') || f.name.includes('沙拉') || f.feature.includes('低脂');
      if (this.foodFilter === '小吃') return f.place.includes('小吃') || f.feature.includes('麻辣');
      return true;
    });
  }

  private pickFoodImage(): void {
    try {
      const docPicker = new picker.DocumentViewPicker();
      const options = new picker.DocumentSelectOptions();
      options.maxSelectNumber = 1;
      docPicker.select(options).then((uris: string[]) => {
        if (uris && uris.length > 0) { this.foodImageUri = uris[0]; this.getUIContext()?.getPromptAction()?.showToast({ message: '美食图片已选择' }); }
      }).catch(() => { this.foodImageUri = 'local_food_' + Date.now(); this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟选择美食图片' }); });
    } catch (_) { this.foodImageUri = 'local_food_' + Date.now(); this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟选择美食图片' }); }
  }

  // ===== 音乐播放器 =====
  @Builder MusicPlayer() {
    Column({ space: 16 }) {
      // 上半部分：专辑封面180px圆形旋转
      Column({ space: 12 }) {
        Image($r('app.media.logo'))
          .width(180).height(180).borderRadius(90)
          .rotate({ angle: this.playing ? 360 : 0 })
          .backgroundColor(AppColors.PRIMARY_LIGHT)
          .animation({ duration: 8000, curve: Curve.Linear, iterations: this.playing ? -1 : 1, playMode: PlayMode.Normal })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 下半部分
      Column({ space: 14 }) {
        // 歌曲信息（28sp歌名+24sp歌手居中）
        Column({ space: 4 }) {
          Text(this.songs[this.selectedSong].name)
            .fontSize(28 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode)).textAlign(TextAlign.Center).lineHeight(28 * this.fontScale * AppColors.LINE_HEIGHT_TITLE_M)
          Text(this.songs[this.selectedSong].singer)
            .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode)).textAlign(TextAlign.Center)
        }

        // 进度条（鸿蒙蓝+左右时间）
        Column({ space: 4 }) {
          Slider({ value: this.currentProgress, min: 0, max: this.songs[this.selectedSong].duration })
            .blockColor(AppColors.PRIMARY).trackColor(AppColors.PRIMARY_BG).selectedColor(AppColors.PRIMARY).width('100%')
            .onChange(async (v: number) => {
              this.currentProgress = v;
              if (this.avPlayer && this.isAVPlayerReady) {
                try {
                  await this.avPlayer.seek(v * 1000);
                } catch (_) {}
              }
            })
          Row() {
            Text(this.formatTime(this.currentProgress)).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
            Blank()
            Text(this.formatTime(this.songs[this.selectedSong].duration)).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
          }
          .width('100%')
        }

        // 控制按钮（40px鸿蒙蓝间距32px）
        Row({ space: 32 }) {
          Text('⏮').fontSize(40).fontColor(AppColors.PRIMARY).onClick(() => this.prevSong())
          Text(this.playing ? '⏸' : '▶️').fontSize(40).fontColor(AppColors.PRIMARY).onClick(() => this.togglePlay())
          Text('⏭').fontSize(40).fontColor(AppColors.PRIMARY).onClick(() => this.nextSong())
        }

        // 本地音乐按钮
        Button(this.hasAudioFile ? '本地音乐' : '导入音频')
          .height(36).fontSize(24)
          .fontColor(this.hasAudioFile ? AppColors.BG_CARD : AppColors.PRIMARY)
          .backgroundColor(this.hasAudioFile ? AppColors.SUCCESS : AppColors.PRIMARY_LIGHT).borderRadius(8)
          .onClick(() => router.pushUrl({ url: 'pages/life/MusicList', params: { songs: this.songs } }))

        // 播放列表
        Column({ space: 0 }) {
          Text('播放列表')
            .fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode))
            .alignSelf(ItemAlign.Start).margin({ top: 10, bottom: 10 })
          ForEach(this.songs, (song: SongItem, si: number) => {
            Row() {
              Text(si === this.selectedSong && this.playing ? '🎵' : '🎶').fontSize(24)
              Column({ space: 4 }) {
                Text(song.name).fontSize(24 * this.fontScale).fontWeight(FontWeight.Bold)
                  .fontColor(si === this.selectedSong ? AppColors.PRIMARY : ThemeUtil.titleColor(this.darkMode)).lineHeight(24 * this.fontScale * AppColors.LINE_HEIGHT_AUX)
                Text(song.singer).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
              }
              .alignItems(HorizontalAlign.Start).margin({ left: 10 }).layoutWeight(1)
              Text(this.formatTime(song.duration)).fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
            }
            .width('100%').padding({ top: 10, bottom: 10 })
            .border({ width: { bottom: si < this.songs.length - 1 ? 1 : 0 }, color: AppColors.DIVIDER })
            .onClick(() => { this.selectSong(si); })
           }, (song: SongItem) => song.name)
        }

        // 悬浮窗开关
        Button(this.floatWindowOn ? '关闭悬浮窗播放' : '开启悬浮窗播放')
          .height(48).fontSize(26)
          .fontColor(this.floatWindowOn ? AppColors.BG_CARD : AppColors.PRIMARY)
          .backgroundColor(this.floatWindowOn ? AppColors.PRIMARY : AppColors.PRIMARY_LIGHT).borderRadius(8).width('100%')
          .onClick(() => {
            this.floatWindowOn = !this.floatWindowOn;
            if (this.floatWindowOn) this.showMusicFloatWindow();
            else { this.closeMusicFloatWindow(); this.getUIContext()?.getPromptAction()?.showToast({ message: '已关闭悬浮窗播放' }); }
          })
      }
      .width('100%')
    }
    .width('100%').padding(20).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8).alignItems(HorizontalAlign.Center)
  }

  private async togglePlay(): Promise<void> {
    if (this.playing) {
      if (this.avPlayer && this.isAVPlayerReady) {
        try {
          await this.avPlayer.pause();
        } catch (_) {}
      }
      this.playing = false;
      this.stopProgress();
    } else {
      this.playing = true;
      this.syncMusicState();
      const song = this.songs[this.selectedSong];
      await this.playSong(song);
    }
  }

  private syncMusicState(): void {
    if (this.selectedSong >= 0 && this.selectedSong < this.songs.length) {
      this.musicSongName = this.songs[this.selectedSong].name;
      this.musicSinger = this.songs[this.selectedSong].singer;
      this.musicDuration = this.songs[this.selectedSong].duration;
    }
  }

  /** 悬浮窗切换播放状态时联动控制 AVPlayer */
  private async onPlayingChanged(): Promise<void> {
    if (this.playing) {
      const song = this.songs[this.selectedSong];
      if (this.avPlayer && this.isAVPlayerReady) {
        try { await this.avPlayer.play(); } catch (_) {}
      } else {
        await this.playSong(song);
      }
      this.simulateProgress();
    } else {
      if (this.avPlayer && this.isAVPlayerReady) {
        try { await this.avPlayer.pause(); } catch (_) {}
      }
      this.stopProgress();
    }
  }

  private async prevSong(): Promise<void> {
    this.stopProgress();
    this.selectedSong = (this.selectedSong + this.songs.length - 1) % this.songs.length;
    this.currentProgress = 0;
    this.syncMusicState();
    if (this.playing) {
      await this.playSong(this.songs[this.selectedSong]);
    }
  }

  private async nextSong(): Promise<void> {
    this.stopProgress();
    this.selectedSong = (this.selectedSong + 1) % this.songs.length;
    this.currentProgress = 0;
    this.syncMusicState();
    if (this.playing) {
      await this.playSong(this.songs[this.selectedSong]);
    }
  }

  private async selectSong(index: number): Promise<void> {
    this.stopProgress();
    this.selectedSong = index;
    this.currentProgress = 0;
    this.playing = true;
    this.syncMusicState();
    await this.playSong(this.songs[this.selectedSong]);
  }

  private async playSong(song: SongItem): Promise<void> {
    if (song.uri && !song.uri.startsWith('/')) {
      await this.playRawfile(song.uri);
    } else if (song.uri && song.uri.startsWith('/')) {
      await this.loadAndPlay(song.uri);
    } else {
      this.simulateProgress();
    }
  }

  private async playRawfile(fileName: string): Promise<void> {
    try {
      await this.initAVPlayer();
      if (!this.avPlayer) {
        this.simulateProgress();
        return;
      }
      if (this.isAVPlayerReady) {
        await this.avPlayer.stop();
        this.isAVPlayerReady = false;
      }
      const context = getContext(this);
      const rawFd = await context.resourceManager.getRawFd(fileName);
      this.avPlayer.fdSrc = { fd: rawFd.fd, offset: rawFd.offset, length: rawFd.length };
      await this.avPlayer.prepare();
      await this.avPlayer.play();
      this.playing = true;
    } catch (e) {
      console.error('playRawfile error: ' + JSON.stringify(e));
      this.simulateProgress();
    }
  }

  private pickAudioFile(): void {
    try {
      const docPicker = new picker.DocumentViewPicker();
      const options = new picker.DocumentSelectOptions();
      options.maxSelectNumber = 1;
      docPicker.select(options).then(async (uris: string[]) => {
        if (uris && uris.length > 0) {
          this.hasAudioFile = true;
          const uri = uris[0];
          this.songs.unshift({ name: '本地曲目 ' + (this.songs.length + 1), singer: '本地文件', duration: 200, uri: uri });
          this.selectedSong = 0;
          this.currentProgress = 0;
          this.playing = true;
          await this.loadAndPlay(uri);
          this.getUIContext()?.getPromptAction()?.showToast({ message: '已加载本地音频文件' });
        }
      }).catch(() => { this.hasAudioFile = true; this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟加载本地音频' }); });
    } catch (_) { this.hasAudioFile = true; this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟加载本地音频文件' }); }
  }

  private async initAVPlayer(): Promise<void> {
    if (this.avPlayer) return;
    try {
      this.avPlayer = await media.createAVPlayer();
      this.avPlayer.on('stateChange', (state: string) => {
        if (state === 'prepared') {
          this.isAVPlayerReady = true;
          this.avDuration = this.avPlayer?.duration ?? 0;
          if (this.avDuration > 0) {
            this.songs[this.selectedSong].duration = Math.floor(this.avDuration / 1000);
          }
        } else if (state === 'completed') {
          this.isAVPlayerReady = false;
          this.playing = false;
          this.nextSong();
        } else if (state === 'stopped' || state === 'released' || state === 'idle') {
          this.isAVPlayerReady = false;
        }
      });
      this.avPlayer.on('timeUpdate', (time: number) => {
        this.currentProgress = Math.floor(time / 1000);
      });
      this.avPlayer.on('error', () => {
        this.isAVPlayerReady = false;
      });
    } catch (e) {
      console.error('initAVPlayer error: ' + JSON.stringify(e));
    }
  }

  private async loadAndPlay(uri: string): Promise<void> {
    await this.initAVPlayer();
    if (!this.avPlayer) {
      this.simulateProgress();
      return;
    }
    try {
      if (this.isAVPlayerReady) {
        await this.avPlayer.stop();
        this.isAVPlayerReady = false;
      }
      this.avPlayer.url = uri;
      await this.avPlayer.prepare();
      await this.avPlayer.play();
      this.playing = true;
    } catch (e) {
      console.error('loadAndPlay error: ' + JSON.stringify(e));
      this.simulateProgress();
    }
  }

  private simulateProgress(): void {
    this.stopProgress();
    this.progressTimer = setInterval(() => {
      if (!this.playing) { this.stopProgress(); return; }
      this.currentProgress += 1;
      if (this.currentProgress >= this.songs[this.selectedSong].duration) {
        this.currentProgress = 0;
        this.selectedSong = (this.selectedSong + 1) % this.songs.length;
        this.syncMusicState();
      }
    }, 1000);
  }

  private stopProgress(): void {
    if (this.progressTimer !== 0) { clearInterval(this.progressTimer); this.progressTimer = 0; }
  }

  private formatTime(seconds: number): string {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  private async showMusicFloatWindow(): Promise<void> {
    try {
      if (this.musicFloatWindow) { await this.musicFloatWindow.destroyWindow(); this.musicFloatWindow = undefined; }
      const song = this.songs[this.selectedSong];
      this.musicFloatWindow = await window.createWindow({
        name: 'music_float',
        windowType: window.WindowType.TYPE_FLOAT,
        ctx: getContext(this)
      });
      await this.musicFloatWindow.setUIContent('pages/life/MusicFloat');
      await this.musicFloatWindow.showWindow();
      this.getUIContext()?.getPromptAction()?.showToast({ message: `音乐悬浮窗已开启\n正在播放：${song.name} - ${song.singer}` });
    } catch (_) { this.getUIContext()?.getPromptAction()?.showToast({ message: '悬浮窗播放已模拟开启' }); }
  }

  private async closeMusicFloatWindow(): Promise<void> {
    try { if (this.musicFloatWindow) { await this.musicFloatWindow.destroyWindow(); this.musicFloatWindow = undefined; } } catch (_) { }
  }

  // ===== 校园工具 =====
  @Builder ToolsPanel() {
    Grid() {
      ForEach(['倒计时', '计算器', '快递查询', '校历'], (name: string) => {
        GridItem() {
          Column({ space: 8 }) {
            Text(this.getToolIcon(name)).fontSize(36)
            Text(name).fontSize(24 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
          }
          .width('100%').aspectRatio(1).justifyContent(FlexAlign.Center)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          .onClick(() => {
            if (name === '计算器') {
              this.showCalculator = true;
              this.calcDisplay = '0';
              this.calcOperator = '';
              this.calcPrev = 0;
              this.calcJustEvaluated = false;
              this.calcWaitingForOperand = false;
            } else if (name === '倒计时') {
              this.showCountdown = true;
            } else if (name === '快递查询') {
              this.showExpress = true;
              this.expressNumber = '';
              this.expressResult = [];
            } else if (name === '校历') {
              this.showCalendar = true;
            }
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr').columnsGap(12).rowsGap(12)
  }

  private getToolIcon(name: string): string {
    switch (name) {
      case '倒计时': return '⏰';
      case '计算器': return '🧮';
      case '快递查询': return '📦';
      case '校历': return '📅';
      default: return '🔧';
    }
  }

  // ===== 快递查询 =====
  @Builder ExpressPanel() {
    Column({ space: 12 }) {
      Row() {
        Text('← 返回').fontSize(24).fontColor(AppColors.PRIMARY)
          .onClick(() => { this.showExpress = false; })
        Blank()
        Text('快递查询').fontSize(26 * this.fontScale).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
        Blank()
        Text('').width(60)
      }
      .width('100%')

      Row({ space: 10 }) {
        TextInput({ text: this.expressNumber, placeholder: '输入快递单号' })
          .fontSize(24)
          .layoutWeight(1)
          .height(48)
          .onChange((v: string) => this.expressNumber = v)
        Button('查询').height(48).fontSize(24).fontColor(AppColors.BG_CARD)
          .backgroundColor(AppColors.PRIMARY).borderRadius(8)
          .onClick(() => {
            if (this.expressNumber.trim().length < 5) {
              this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入正确的快递单号' });
              return;
            }
            // 模拟快递轨迹
            this.expressResult = [
              { time: '2026-06-25 08:30', location: '【配送中】', desc: '快件已到达 校园快递驿站' },
              { time: '2026-06-24 22:15', location: '转运中心', desc: '快件已从 市分拨中心 发出' },
              { time: '2026-06-24 14:00', location: '分拨中心', desc: '快件已到达 市分拨中心' },
              { time: '2026-06-23 09:45', location: '已揽收', desc: '快递员已揽收' },
              { time: '2026-06-22 18:00', location: '已下单', desc: '订单已提交' }
            ];
            this.getUIContext()?.getPromptAction()?.showToast({ message: '查询成功' });
          })
      }
      .width('100%')

      if (this.expressResult.length > 0) {
        List() {
          ForEach(this.expressResult, (item: ExpressInfo) => {
            ListItem() {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(item.time).fontSize(22).fontColor(AppColors.TEXT_SECONDARY)
                  Text(item.desc).fontSize(24).fontColor(ThemeUtil.titleColor(this.darkMode))
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)
                Text(item.location).fontSize(22).fontColor(AppColors.PRIMARY)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(4)
              }
              .width('100%').padding(12)
              .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
              .margin({ bottom: 8 })
            }
          })
        }
        .width('100%').layoutWeight(1)
      } else {
        Column() {
          Text('📦').fontSize(64)
          Text('输入快递单号查询物流信息').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).margin({ top: 12 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
  }

  // ===== 校历 =====
  @Builder CalendarPanel() {
    Column({ space: 12 }) {
      Row() {
        Text('← 返回').fontSize(24).fontColor(AppColors.PRIMARY)
          .onClick(() => { this.showCalendar = false; })
        Blank()
        Text('校历').fontSize(26 * this.fontScale).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
        Blank()
        Text('').width(60)
      }
      .width('100%')

      // 学期概览
      Column({ space: 8 }) {
        Text('2025-2026学年 第二学期').fontSize(26).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
        Text('2026年2月23日 - 2026年7月4日').fontSize(22).fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%').padding(16)
      .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

      // 重要事件
      Text('重要日程').fontSize(26).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
        .width('100%').margin({ top: 4 })

      List() {
        ForEach([
          { date: '02.23-02.24', title: '学生报到注册', type: '教学' },
          { date: '02.25', title: '正式上课', type: '教学' },
          { date: '04.14-04.18', title: '期中考试', type: '考试' },
          { date: '04.30-05.05', title: '劳动节假期', type: '假期' },
          { date: '06.22-06.28', title: '期末考试周', type: '考试' },
          { date: '07.01', title: '暑假开始', type: '假期' }
        ], (event: CalendarEvent) => {
          ListItem() {
            Row({ space: 14 }) {
              Column({ space: 4 }) {
                Text(event.date).fontSize(24).fontWeight(600).fontColor(AppColors.PRIMARY)
              }
              .width(100).alignItems(HorizontalAlign.Center)
              .padding({ top: 4, bottom: 4 })

              Column({ space: 4 }) {
                Text(event.title).fontSize(26).fontColor(ThemeUtil.titleColor(this.darkMode))
                Text(event.type).fontSize(22)
                  .fontColor(event.type === '考试' ? AppColors.WARNING : event.type === '假期' ? AppColors.SUCCESS : AppColors.PRIMARY)
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)
            }
            .width('100%').padding(12)
            .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          }
          .margin({ bottom: 8 })
        })
      }
      .width('100%').layoutWeight(1)
    }
    .width('100%')
  }

  // ===== 计算器 =====
  @Builder CalculatorPanel() {
    Column({ space: 12 }) {
      // 顶部返回按钮
      Row() {
        Text('← 返回').fontSize(24).fontColor(AppColors.PRIMARY)
          .onClick(() => { this.showCalculator = false; })
        Blank()
        Text('计算器').fontSize(26 * this.fontScale).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
        Blank()
        Text('').width(60)
      }
      .width('100%')

      // 显示屏
      Column() {
        Text(this.calcDisplay)
          .fontSize(32)
          .fontColor(ThemeUtil.titleColor(this.darkMode))
          .textAlign(TextAlign.End)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%').height(80).justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

      // 4x4 按钮网格
      Grid() {
        ForEach(this.getCalcButtons(), (row: string[]) => {
          GridItem() {
            Row({ space: 10 }) {
              ForEach(row, (btn: string) => {
                Button(btn)
                  .width('22%').height(48).fontSize(24)
                  .fontColor(this.isCalcOperator(btn) || btn === '=' ? Color.White : ThemeUtil.titleColor(this.darkMode))
                  .backgroundColor(
                    btn === '=' ? AppColors.SUCCESS :
                    this.isCalcOperator(btn) ? AppColors.PRIMARY :
                    btn === 'C' ? AppColors.WARNING :
                    AppColors.BG_PAGE
                  )
                  .borderRadius(8)
                  .layoutWeight(1)
                  .onClick(() => this.onCalcButtonPress(btn))
              })
            }
            .width('100%')
          }
        })
      }
      .columnsTemplate('1fr').rowsGap(10)
    }
    .width('100%').padding(16).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  private getCalcButtons(): string[][] {
    return [
      ['C', '÷', '×', '⌫'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '', '']
    ];
  }

  private isCalcOperator(btn: string): boolean {
    return btn === '+' || btn === '-' || btn === '×' || btn === '÷';
  }

  private onCalcButtonPress(btn: string): void {
    if (btn === '') return;
    if (btn === 'C') {
      this.calcDisplay = '0';
      this.calcOperator = '';
      this.calcPrev = 0;
      this.calcJustEvaluated = false;
      this.calcWaitingForOperand = false;
      return;
    }
    if (btn === '⌫') {
      if (this.calcDisplay.length > 1) {
        this.calcDisplay = this.calcDisplay.substring(0, this.calcDisplay.length - 1);
      } else {
        this.calcDisplay = '0';
      }
      return;
    }
    if (this.isCalcOperator(btn)) {
      if (this.calcWaitingForOperand) {
        this.calcOperator = btn;
        this.calcDisplay = this.formatCalcResult(this.calcPrev) + ' ' + btn;
        return;
      }
      const current = parseFloat(this.calcDisplay);
      if (this.calcOperator !== '' && !this.calcJustEvaluated) {
        const result = this.calcCompute(this.calcPrev, current, this.calcOperator);
        this.calcDisplay = this.formatCalcResult(result);
        this.calcPrev = result;
      } else {
        this.calcPrev = current;
      }
      this.calcOperator = btn;
      this.calcJustEvaluated = false;
      this.calcWaitingForOperand = true;
      this.calcDisplay = this.formatCalcResult(this.calcPrev) + ' ' + btn;
      return;
    }
    if (btn === '=') {
      if (this.calcWaitingForOperand) {
        this.calcDisplay = this.formatCalcResult(this.calcPrev);
        this.calcOperator = '';
        this.calcWaitingForOperand = false;
        this.calcJustEvaluated = true;
        return;
      }
      const current = parseFloat(this.calcDisplay);
      if (this.calcOperator !== '') {
        const result = this.calcCompute(this.calcPrev, current, this.calcOperator);
        this.calcDisplay = this.formatCalcResult(result);
        this.calcPrev = result;
        this.calcOperator = '';
        this.calcJustEvaluated = true;
      }
      return;
    }
    // 数字和小数点
    if (this.calcJustEvaluated) {
      this.calcDisplay = btn === '.' ? '0.' : btn;
      this.calcJustEvaluated = false;
      this.calcPrev = 0;
      this.calcOperator = '';
    } else if (this.calcWaitingForOperand) {
      this.calcDisplay = btn === '.' ? '0.' : btn;
      this.calcWaitingForOperand = false;
    } else {
      if (btn === '.' && this.calcDisplay.indexOf('.') >= 0) return;
      if (this.calcDisplay === '0' && btn !== '.') {
        this.calcDisplay = btn;
      } else {
        this.calcDisplay = this.calcDisplay + btn;
      }
    }
  }

  private calcCompute(a: number, b: number, op: string): number {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b !== 0 ? a / b : 0;
      default: return b;
    }
  }

  private formatCalcResult(num: number): string {
    if (Number.isInteger(num) && Math.abs(num) < 1e15) {
      return num.toString();
    }
    const s = num.toFixed(8);
    return s.replace(/0+$/, '').replace(/\.$/, '');
  }

  // ===== 倒计时 =====
  @Builder CountdownPanel() {
    Column({ space: 16 }) {
      // 顶部返回按钮
      Row() {
        Text('← 返回').fontSize(24).fontColor(AppColors.PRIMARY)
          .onClick(() => { this.showCountdown = false; this.stopCountdown(); })
        Blank()
        Text('倒计时').fontSize(26 * this.fontScale).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
        Blank()
        Text('').width(60)
      }
      .width('100%')

      // 预设时间选择
      Column({ space: 8 }) {
        Text('选择时间').fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode)).alignSelf(ItemAlign.Start)
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach([5, 10, 15, 25, 30, 45, 60], (min: number) => {
            Text(`${min}分钟`)
              .fontSize(24)
              .fontColor(this.countdownMinutes === min && !this.countdownRunning ? Color.White : ThemeUtil.titleColor(this.darkMode))
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.countdownMinutes === min && !this.countdownRunning ? AppColors.PRIMARY : AppColors.BG_PAGE)
              .borderRadius(20)
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                if (!this.countdownRunning) {
                  this.countdownMinutes = min;
                  this.countdownSeconds = 0;
                  this.countdownRemaining = min * 60;
                }
              })
          })
        }
      }

      // 大号倒计时显示
      Column() {
        Text(this.formatCountdownDisplay())
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.countdownRemaining <= 10 && this.countdownRunning ? AppColors.WARNING : ThemeUtil.titleColor(this.darkMode))
          .textAlign(TextAlign.Center)
      }
      .width('100%').aspectRatio(1.5).justifyContent(FlexAlign.Center)
      .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

      // 控制按钮
      Row({ space: 12 }) {
        if (!this.countdownRunning) {
          Button('开始')
            .height(48).fontSize(24).fontColor(Color.White)
            .backgroundColor(AppColors.PRIMARY).borderRadius(8).layoutWeight(1)
            .onClick(() => this.startCountdown())
        } else {
          Button('暂停')
            .height(48).fontSize(24).fontColor(Color.White)
            .backgroundColor(AppColors.WARNING).borderRadius(8).layoutWeight(1)
            .onClick(() => this.pauseCountdown())
        }
        Button('重置')
          .height(48).fontSize(24).fontColor(AppColors.PRIMARY)
          .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(8).layoutWeight(1)
          .onClick(() => this.resetCountdown())
      }
      .width('100%')
    }
    .width('100%').padding(16).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  private formatCountdownDisplay(): string {
    let total = this.countdownRemaining;
    if (!this.countdownRunning && total === 0) {
      total = this.countdownMinutes * 60 + this.countdownSeconds;
    }
    const m = Math.floor(total / 60);
    const s = total % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  private startCountdown(): void {
    if (this.countdownRemaining <= 0) {
      this.countdownRemaining = this.countdownMinutes * 60 + this.countdownSeconds;
    }
    if (this.countdownRemaining <= 0) return;
    this.countdownRunning = true;
    this.stopCountdown();
    this.countdownTimer = setInterval(() => {
      if (this.countdownRemaining <= 0) {
        this.stopCountdown();
        this.countdownRunning = false;
        try { this.getUIContext()?.getPromptAction()?.showToast({ message: '倒计时结束' }); } catch (_) {}
        return;
      }
      this.countdownRemaining -= 1;
      if (this.countdownRemaining <= 0) {
        this.countdownRemaining = 0;
        this.stopCountdown();
        this.countdownRunning = false;
        try { this.getUIContext()?.getPromptAction()?.showToast({ message: '倒计时结束' }); } catch (_) {}
      }
    }, 1000);
  }

  private pauseCountdown(): void {
    this.stopCountdown();
    this.countdownRunning = false;
  }

  private resetCountdown(): void {
    this.stopCountdown();
    this.countdownRunning = false;
    this.countdownRemaining = this.countdownMinutes * 60;
  }

  private stopCountdown(): void {
    if (this.countdownTimer !== 0) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = 0;
    }
  }
}
