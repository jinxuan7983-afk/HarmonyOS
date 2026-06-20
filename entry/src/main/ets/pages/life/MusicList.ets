import router from '@ohos.router';
import { picker } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';
import { SongItem } from '../../common/constants/DataModels';

/**
 * 本地音乐列表页
 * - 显示本地音频文件列表
 * - 支持导入本地音频
 * - 点击歌曲返回播放页播放
 */
@Entry
@Component
struct MusicList {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State statusBarHeight: number = 0;
  @State songs: SongItem[] = [];
  @State searchText: string = '';
  @State scanning: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
    // 从路由参数获取已有歌曲列表
    const params = router.getParams() as Record<string, Object>;
    if (params && params['songs']) {
      this.songs = params['songs'] as SongItem[];
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
        Text('本地音乐')
          .fontSize(28).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
          .margin({ left: 8 }).layoutWeight(1)
      }
      .width('100%').height(52).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))

      // 搜索栏
      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(24).fontColor([AppColors.PRIMARY])
        TextInput({ text: this.searchText, placeholder: '搜索歌曲/歌手' })
          .fontSize(24).backgroundColor(Color.Transparent).layoutWeight(1)
          .onChange((v: string) => this.searchText = v)
      }
      .width('95%').height(48).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(24)
      .margin({ top: 12 })

      // 导入按钮
      Button('导入本地音频')
        .width('95%').height(48).fontSize(26).fontColor(AppColors.BG_CARD)
        .backgroundColor(AppColors.PRIMARY).borderRadius(8).margin({ top: 16 })
        .onClick(() => this.pickAudioFile())

      // 歌曲列表
      if (this.getFilteredSongs().length === 0) {
        Column() {
          SymbolGlyph($r('sys.symbol.headphones'))
            .fontSize(48).fontColor([AppColors.TEXT_PLACEHOLDER])
          Text('暂无本地音乐')
            .fontSize(26 * this.fontScale).fontColor(AppColors.TEXT_PLACEHOLDER).margin({ top: 12 })
          Text('点击上方按钮导入音频文件')
            .fontSize(24 * this.fontScale).fontColor(AppColors.TEXT_PLACEHOLDER).margin({ top: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getFilteredSongs(), (song: SongItem, index: number) => {
            ListItem() {
              Row({ space: 14 }) {
                SymbolGlyph($r('sys.symbol.headphones'))
                  .fontSize(28).fontColor([AppColors.PRIMARY])
                  .width(48).height(48)
                  .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(24)
                Column({ space: 4 }) {
                  Text(song.name)
                    .fontSize(26 * this.fontScale).fontColor(ThemeUtil.titleColor(this.darkMode))
                    .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(song.singer)
                    .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)
                Text(this.formatTime(song.duration))
                  .fontSize(24 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode))
              }
              .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
            }
            .onClick(() => {
              const realIdx = this.songs.indexOf(song);
              AppStorage.setOrCreate('musicSelectedIndex', realIdx >= 0 ? realIdx : index);
              router.back();
             })
           }, (song: SongItem, index: number) => song.name + String(index))
        }
        .width('100%').layoutWeight(1).scrollBar(BarState.Off)
        .margin({ top: 12 })
      }
    }
    .width('100%').height('100%').backgroundColor(ThemeUtil.pageBg(this.darkMode))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private getFilteredSongs(): SongItem[] {
    if (!this.searchText.trim()) return this.songs;
    const kw = this.searchText.trim().toLowerCase();
    return this.songs.filter((s: SongItem) =>
      s.name.toLowerCase().includes(kw) || s.singer.toLowerCase().includes(kw)
    );
  }

  private formatTime(seconds: number): string {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  private pickAudioFile(): void {
    try {
      const docPicker = new picker.DocumentViewPicker();
      const options = new picker.DocumentSelectOptions();
      options.maxSelectNumber = 10;
      docPicker.select(options).then((uris: string[]) => {
        if (uris && uris.length > 0) {
          uris.forEach((uri: string, i: number) => {
            this.songs.push({
              name: '本地曲目 ' + (this.songs.length + i + 1),
              singer: '本地文件',
              duration: 0,
              uri: uri
            });
          });
          this.getUIContext()?.getPromptAction()?.showToast({ message: `已导入${uris.length}首歌曲` });
        }
      }).catch(() => {
        this.getUIContext()?.getPromptAction()?.showToast({ message: '已取消选择' });
      });
    } catch (_) {
      this.getUIContext()?.getPromptAction()?.showToast({ message: '导入功能暂不可用' });
    }
  }
}
