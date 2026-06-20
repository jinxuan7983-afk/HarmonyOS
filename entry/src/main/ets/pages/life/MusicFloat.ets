import { AppColors } from '../../common/constants/AppColors';
import window from '@ohos.window';

@Entry
@Component
struct MusicFloat {
  @StorageLink('musicPlaying') playing: boolean = false;
  @StorageLink('musicSongName') songName: string = '';
  @StorageLink('musicSinger') singer: string = '';
  @StorageLink('musicProgress') progress: number = 0;
  @StorageLink('musicDuration') duration: number = 0;

  async aboutToAppear(): Promise<void> {
    try {
      const win = await window.getLastWindow(getContext(this));
      win.setWindowLayoutFullScreen(true);
    } catch (_) {}
  }

  private formatTime(seconds: number): string {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Image($r('app.media.logo'))
          .width(36).height(36).borderRadius(18)
          .rotate({ angle: this.playing ? 360 : 0 })
          .animation({ duration: 8000, curve: Curve.Linear, iterations: this.playing ? -1 : 1, playMode: PlayMode.Normal })
          .backgroundColor(AppColors.PRIMARY_LIGHT)

        Column({ space: 2 }) {
          Text(this.songName)
            .fontSize(24).fontWeight(FontWeight.Bold).fontColor(AppColors.TEXT_PRIMARY)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.singer)
            .fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)

        Text(this.playing ? '⏸' : '▶️')
          .fontSize(24).fontColor(AppColors.PRIMARY)
          .onClick(() => {
            this.playing = !this.playing;
          })

        Image($r('sys.media.ohos_ic_public_close'))
          .width(14).height(14).fillColor(AppColors.TEXT_SECONDARY)
          .margin({ left: 4 })
          .onClick(async () => {
            try {
              const win = await window.getLastWindow(getContext(this));
              await win.destroyWindow();
            } catch (_) {}
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })

      Progress({ value: this.progress, total: Math.max(this.duration, 1), type: ProgressType.Linear })
        .color(AppColors.PRIMARY)
        .backgroundColor(AppColors.PRIMARY_LIGHT)
        .width('100%')
        .height(2)
    }
    .width('100%')
    .height(52)
    .backgroundColor(AppColors.BG_CARD)
    .borderRadius(8)
    .shadow({ radius: 8, color: '#33000000', offsetY: 2 })
    .padding(0)
  }
}
