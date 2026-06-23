import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { CourseItem } from '../../common/constants/DataModels';

/**
 * 【3.4.1 课程表编辑页】
 * 支持手动添加/修改课程信息：
 * - 课程名称、授课老师、上课时间、上课地点、学分
 * - 单选框选择上课周次
 * - 提醒开关
 */

interface RouterParams {
  mode: string;    // 'add' | 'edit'
  course?: CourseItem;
  courseIndex?: number;
}

@Entry
@Component
struct CourseEdit {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @State mode: string = 'add';
  @State editIndex: number = -1;
  @State courseName: string = '';
  @State teacher: string = '';
  @State day: string = '周一';
  @State startTime: string = '08:20';
  @State endTime: string = '10:00';
  @State place: string = '';
  @State credits: string = '';
  @State remindOn: boolean = true;
  @State selectedColor: string = AppColors.PRIMARY;

  private days: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private timeOptions: string[] = ['08:20', '10:20', '14:00', '16:00', '19:00'];
  private colors: string[] = [AppColors.PRIMARY, AppColors.SUCCESS, AppColors.WARNING, AppColors.PURPLE, AppColors.DANGER, AppColors.INFO, AppColors.WARNING, AppColors.PINK];

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams;
    if (params) {
      this.mode = params.mode || 'add';
      if (params.mode === 'edit' && params.course) {
        const c = params.course;
        this.courseName = c.name;
        this.teacher = c.teacher;
        this.day = c.day;
        this.startTime = c.time.split('-')[0] || '08:20';
        this.endTime = c.time.split('-')[1] || '10:00';
        this.place = c.place;
        this.credits = c.credits || '';
        this.remindOn = c.remindOn !== false;
        this.selectedColor = c.color;
        this.editIndex = params.courseIndex ?? -1;
      }
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(AppColors.PRIMARY)
          .onClick(() => router.back())
        Text(this.mode === 'add' ? '添加课程' : '编辑课程')
          .fontSize(30)
          .fontWeight(600)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 8 })
          .layoutWeight(1)
        if (this.mode === 'edit') {
          Button('删除')
            .height(36)
            .fontSize(24)
            .fontColor(AppColors.DANGER)
            .backgroundColor(AppColors.DANGER_LIGHT)
            .borderRadius(8)
            .onClick(() => {
              AppStorage.setOrCreate('courseEditResult', { action: 'delete', index: this.editIndex });
              router.back();
            })
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(AppColors.BG_CARD)

      Scroll() {
        Column({ space: 18 }) {
          // 表单字段
          this.InputField('课程名称', '请输入课程名称', this.courseName, (v: string) => this.courseName = v)
          this.InputField('授课老师', '请输入授课老师', this.teacher, (v: string) => this.teacher = v)
          this.InputField('上课地点', '请输入上课地点（如 信工楼 A306）', this.place, (v: string) => this.place = v)
          this.InputField('学分', '请输入学分数（如 3）', this.credits, (v: string) => this.credits = v)

          // 【3.4.1 单选框】选择上课日
          Column({ space: 8 }) {
            Text('上课日').fontSize(24).fontColor(AppColors.TEXT_PRIMARY).alignSelf(ItemAlign.Start)
            Row({ space: 6 }) {
              ForEach(this.days, (d: string) => {
                Text(d)
                  .fontSize(24)
                  .fontColor(this.day === d ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(this.day === d ? AppColors.PRIMARY : AppColors.DIVIDER)
                  .borderRadius(8)
                  .onClick(() => this.day = d)
              })
            }
          }

          // 【3.4.1 单选框】上课时间
          Column({ space: 8 }) {
            Text('上课时段').fontSize(24).fontColor(AppColors.TEXT_PRIMARY).alignSelf(ItemAlign.Start)
            Row({ space: 8 }) {
              ForEach(this.timeOptions.slice(0, 4), (t: string) => {
                Text(t)
                  .fontSize(24)
                  .fontColor(this.startTime === t ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(this.startTime === t ? AppColors.PRIMARY : AppColors.DIVIDER)
                  .borderRadius(8)
                  .onClick(() => this.startTime = t)
              })
            }
            Text(`结束时间：${this.getEndTime()}`)
              .fontSize(24)
              .fontColor(AppColors.TEXT_SECONDARY)
              .alignSelf(ItemAlign.Start)
              .margin({ left: 4 })
          }

          // 课程颜色选择
          Column({ space: 8 }) {
            Text('课程颜色').fontSize(24).fontColor(AppColors.TEXT_PRIMARY).alignSelf(ItemAlign.Start)
            Row({ space: 10 }) {
              ForEach(this.colors, (color: string) => {
                Column() {
                  Circle()
                    .width(this.selectedColor === color ? 32 : 28)
                    .height(this.selectedColor === color ? 32 : 28)
                    .fill(color)
                  if (this.selectedColor === color) {
                    Text('✓').fontSize(10).fontColor(color)
                  }
                }
                .onClick(() => this.selectedColor = color)
              })
            }
          }

          // 【3.4.1 课程提醒】Toggle开关
          Row() {
            Column({ space: 4 }) {
              Text('课程开始前提醒').fontSize(24).fontColor(AppColors.TEXT_PRIMARY)
              Text('课前10分钟推送通知提醒').fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.remindOn })
              .selectedColor(AppColors.PRIMARY)
              .onChange((checked: boolean) => {
                this.remindOn = checked;
                this.getUIContext()?.getPromptAction()?.showToast({ message: checked ? '已开启课程提醒' : '已关闭课程提醒' });
              })
          }

          // 预览卡片
          if (this.courseName.length > 0) {
            Column() {
              Text('课程卡片预览').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
              Row({ space: 12 }) {
                Text('')
                  .width(5)
                  .height(48)
                  .backgroundColor(this.selectedColor)
                  .borderRadius(4)
                Column({ space: 4 }) {
                  Text(this.courseName || '课程名称').fontSize(26).fontColor(AppColors.TEXT_PRIMARY)
                  Text(`${this.startTime}-${this.getEndTime()} · ${this.place || '上课地点'}`).fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
                  Text(`授课教师：${this.teacher || '老师'}  ·  ${this.credits || '0'}学分`).fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .padding(10)
              .backgroundColor(AppColors.PRIMARY_LIGHT)
              .borderRadius(8)
            }
          }

          // 保存按钮
          Button('保存课程')
            .width('100%')
            .height(48)
            .fontSize(26)
            .fontColor(AppColors.BG_CARD)
            .backgroundColor(AppColors.PRIMARY)
            .borderRadius(8)
            .onClick(() => {
              if (!this.courseName.trim()) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入课程名称' });
                return;
              }
              if (!this.place.trim()) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入上课地点' });
                return;
              }
              // 构建课程对象返回
              const course: CourseItem = {
                name: this.courseName.trim(),
                teacher: this.teacher.trim() || '未指定',
                day: this.day,
                time: `${this.startTime}-${this.getEndTime()}`,
                place: this.place.trim(),
                credits: this.credits.trim() || '0',
                color: this.selectedColor,
                remindOn: this.remindOn
              };
              AppStorage.setOrCreate('courseEditResult', {
                action: this.mode === 'edit' ? 'edit' : 'add',
                index: this.editIndex,
                course: course
              });
              router.back();
            })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  InputField(label: string, placeholder: string, value: string, callback: (v: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(24)
        .fontColor(AppColors.TEXT_PRIMARY)
        .alignSelf(ItemAlign.Start)
      TextInput({ text: value, placeholder: placeholder })
        .height(48)
        .fontSize(24)
        .backgroundColor(AppColors.BG_CARD)
        .borderRadius(8)
        .padding({ left: 14, right: 14 })
        .onChange((text: string) => callback(text))
    }
    .width('100%')
  }

  private getEndTime(): string {
    const index = this.timeOptions.indexOf(this.startTime);
    if (index >= 0 && index < 3) {
      return this.timeOptions[index + 1];
    }
    return '22:00';
  }
}
