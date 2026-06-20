/**
 * 【3.1.1 悬浮窗】校园待办悬浮窗页面
 * 在应用后台时展示核心待办信息
 */
import { AppColors } from '../../common/constants/AppColors';
import { TodoItem } from '../../common/constants/DataModels';
import window from '@ohos.window';

@Entry
@Component
struct TodoFloat {
  @StorageLink('floatTodos') todos: TodoItem[] = [];
  @State todoVersion: number = 0;

  async aboutToAppear(): Promise<void> {
    try {
      const win = await window.getLastWindow(getContext(this));
      win.setWindowLayoutFullScreen(true);
    } catch (_) {}
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('待办提醒')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.BG_CARD)
        Blank()
        Image($r('sys.media.ohos_ic_public_close'))
          .width(16)
          .height(16)
          .fillColor(AppColors.BG_CARD)
          .onClick(async () => {
            try {
              const win = await window.getLastWindow(getContext(this));
              await win.destroyWindow();
            } catch (_) {}
          })
      }
      .width('100%')
      .height(40)
      .padding({ left: 14, right: 14 })
      .backgroundColor(AppColors.PRIMARY)
      .borderRadius({ topLeft: 12, topRight: 12 })

      // 待办列表
      List() {
        ForEach(this.todos.filter((t: TodoItem) => !t.done), (todo: TodoItem, index: number) => {
          ListItem() {
            Row({ space: 8 }) {
              Checkbox()
                .select(todo.done)
                .selectedColor(AppColors.PRIMARY)
                .width(16)
                .height(16)
                .onChange((checked: boolean) => {
                  const idx = this.todos.indexOf(todo);
                  if (idx >= 0) {
                    this.todos[idx].done = checked;
                  }
                })

              Text(todo.title)
                .fontSize(24)
                .fontColor(AppColors.TEXT_PRIMARY)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .onClick(() => {
              this.getUIContext()?.getPromptAction()?.showToast({ message: `待办：${todo.title}` });
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 14, right: 14 })
      .backgroundColor(AppColors.BG_CARD)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })

      // 底部进度提示
      Row() {
        Progress({
          value: this.todos.filter((t: TodoItem) => t.done).length,
          total: this.todos.length,
          type: ProgressType.Linear
        })
          .color(AppColors.PRIMARY)
          .backgroundColor(AppColors.PRIMARY_LIGHT)
          .layoutWeight(1)

        Text(`${this.todos.filter((t: TodoItem) => t.done).length}/${this.todos.length} 已完成`)
          .fontSize(24)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .backgroundColor(AppColors.BG_CARD)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(AppColors.TRANSPARENT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
