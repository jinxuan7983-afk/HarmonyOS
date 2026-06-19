import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { MessageItem } from '../../common/constants/DataModels';

/**
 * 消息中心页
 * 展示系统通知、课程提醒、公告提醒等消息列表
 */

@Entry
@Component
struct MessageCenter {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @State messages: MessageItem[] = [
    { title: '期末考试安排已发布', content: '公共课考试周安排已发布，请同学们及时查看考场信息。', time: '06-09 09:30', type: '公告', read: true },
    { title: '图书馆端午假期开放时间', content: '假期开放时间调整为 8:30-21:30，请互相转告。', time: '06-08 18:00', type: '公告', read: true },
    { title: '课程提醒：移动开发技术', content: '明天上午 08:20 在信工楼 A306 上课，请准时到达。', time: '06-08 20:00', type: '课程', read: false },
    { title: '待办提醒：完成实验报告', content: '你设置的"完成移动开发实验报告"待办已到提醒时间。', time: '06-07 18:00', type: '待办', read: false },
    { title: '社团活动：换届选举通知', content: '羽毛球社团新一届干事选举将于下周三举行。', time: '06-06 14:00', type: '活动', read: true },
    { title: '成绩已更新', content: '软件工程课程期末成绩已发布，请登录查看。', time: '06-05 10:00', type: '成绩', read: true }
  ];

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor(AppColors.PRIMARY)
          .onClick(() => router.back())
        Text('消息中心')
          .fontSize(30).fontWeight(600).fontColor(AppColors.TEXT_PRIMARY).margin({ left: 8 }).layoutWeight(1)
        Text('全部已读')
          .fontSize(24).fontColor(AppColors.PRIMARY)
          .onClick(() => {
            this.messages.forEach((m: MessageItem) => m.read = true);
            this.getUIContext()?.getPromptAction()?.showToast({ message: '全部标为已读' });
          })
      }
      .width('100%').height(52).padding({ left: 16, right: 16 }).backgroundColor(AppColors.BG_CARD)

      List() {
        ForEach(this.messages, (msg: MessageItem) => {
          ListItem() {
            Row({ space: 12 }) {
              // 未读蓝点
              Column() {
                if (!msg.read) {
                  Circle().width(8).height(8).fill(AppColors.PRIMARY)
                } else {
                  Circle().width(8).height(8).fill(AppColors.BORDER)
                }
              }
              .width(12).height('100%').justifyContent(FlexAlign.Center)

              // 消息类型标签
              Text(this.getTypeIcon(msg.type))
                .fontSize(24)
                .width(40).height(40).textAlign(TextAlign.Center)
                .backgroundColor(this.getTypeBg(msg.type)).borderRadius(20)

              Column({ space: 4 }) {
                Text(msg.title)
                  .fontSize(26).fontWeight(msg.read ? FontWeight.Normal : FontWeight.Bold)
                  .fontColor(msg.read ? AppColors.TEXT_SECONDARY : AppColors.TEXT_PRIMARY).maxLines(1)
                Text(msg.content)
                  .fontSize(22).fontColor(AppColors.TEXT_SECONDARY).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)

              Text(msg.time)
                .fontSize(20).fontColor(AppColors.TEXT_PLACEHOLDER)
            }
            .width('100%').padding(16)
            .onClick(() => {
              msg.read = true;
              this.getUIContext()?.getPromptAction()?.showToast({ message: msg.title });
            })
          }
          .border({ width: { bottom: 0.5 }, color: AppColors.DIVIDER })
        })
      }
      .width('100%').layoutWeight(1).scrollBar(BarState.Off).backgroundColor(AppColors.BG_CARD)
    }
    .width('100%').height('100%').backgroundColor(AppColors.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private getTypeIcon(type: string): string {
    const map: Record<string, string> = { '公告': '📢', '课程': '📅', '待办': '✅', '活动': '🎉', '成绩': '📊' };
    return map[type] || '📌';
  }

  private getTypeBg(type: string): string {
    const map: Record<string, string> = { '公告': AppColors.PRIMARY_LIGHT, '课程': AppColors.SUCCESS_LIGHT, '待办': AppColors.WARNING_LIGHT, '活动': AppColors.PURPLE_LIGHT, '成绩': AppColors.DANGER_LIGHT };
    return map[type] || AppColors.BG_PAGE;
  }
}
