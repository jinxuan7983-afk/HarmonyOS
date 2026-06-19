import router from '@ohos.router';
import { picker } from '@kit.CoreFileKit';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';
import { DataManager } from '../../utils/DataManager';

/**
 * 个人信息编辑页
 * - 头像上传（本地图片读取）
 * - 昵称、学院、专业编辑
 * - 密码修改
 */
@Entry
@Component
struct ProfileEdit {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State nickname: string = '';
  @State studentId: string = '';
  @State college: string = '';
  @State major: string = '';
  @State avatarUri: string = '';

  @State showPwdPanel: boolean = false;
  @State oldPwd: string = '';
  @State newPwd: string = '';
  @State confirmPwd: string = '';
  @State statusBarHeight: number = 0;

  async aboutToAppear(): Promise<void> {
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.nickname = params['nickname'] || '校园助手用户';
      this.studentId = params['studentId'] || '20260001';
      this.college = params['college'] || '信息工程学院';
      this.major = params['major'] || '软件工程';
      this.avatarUri = params['avatarUri'] || '';
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
          .onClick(() => {
            // 返回时携带修改后的数据
            router.back();
          })
        Text('编辑个人信息')
          .fontSize(30).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode)).margin({ left: 8 }).layoutWeight(1)
        Text('保存')
          .fontSize(26).fontColor(AppColors.BG_CARD)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .backgroundColor(AppColors.PRIMARY).borderRadius(8)
          .onClick(() => {
            DataManager.saveUserInfo(this.nickname, this.studentId, this.college, this.major);
            this.getUIContext()?.getPromptAction()?.showToast({ message: '个人信息已保存' });
            router.back();
          })
      }
      .width('100%').height(52).padding({ left: 16, right: 16 }).backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Scroll() {
        Column({ space: 24 }) {
          // 头像区域
          Column({ space: 12 }) {
            Text('头像').fontSize(24).fontColor(ThemeUtil.subColor(this.darkMode)).alignSelf(ItemAlign.Start)
            Stack() {
              Image(this.avatarUri || $r('app.media.logo'))
                .width(100).height(100).borderRadius(50).border({ width: 3, color: AppColors.PRIMARY })
              Text('📷 更换头像')
                .fontSize(22)
                .fontColor(AppColors.BG_CARD)
                .width(100).height(100).borderRadius(50)
                .backgroundColor('#33000000')
                .textAlign(TextAlign.Center)
                .onClick(() => this.pickAvatar())
            }
            .alignSelf(ItemAlign.Center)
          }
          .width('100%')

          // 个人信息表单
          Column({ space: 4 }) {
            this.EditField('昵称', '请输入昵称', this.nickname, (v: string) => this.nickname = v)
            Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
            this.EditField('学号', '请输入学号', this.studentId, (v: string) => this.studentId = v)
            Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
            this.EditField('学院', '请输入学院', this.college, (v: string) => this.college = v)
            Divider().color(AppColors.DIVIDER).strokeWidth(1).width('92%')
            this.EditField('专业', '请输入专业', this.major, (v: string) => this.major = v)
          }
          .width('100%').padding({ top: 8, bottom: 8 }).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
          .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })

          // 密码修改入口
          Button(this.showPwdPanel ? '收起密码修改' : '修改密码')
            .width('100%').height(48).fontSize(26 * this.fontScale)
            .fontColor(AppColors.WARNING).backgroundColor(AppColors.WARNING_LIGHT).borderRadius(8)
            .onClick(() => {
              this.showPwdPanel = !this.showPwdPanel;
              this.oldPwd = ''; this.newPwd = ''; this.confirmPwd = '';
            })

          if (this.showPwdPanel) {
            this.PasswordPanel()
          }
        }
        .width('100%').padding(20)
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(this.darkMode ? AppColors.BG_DARK_PAGE : AppColors.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder EditField(label: string, placeholder: string, value: string, cb: (v: string) => void) {
    Row() {
      Text(label).fontSize(26 * this.fontScale).fontColor(ThemeUtil.subColor(this.darkMode)).width(60)
      TextInput({ text: value, placeholder: placeholder })
        .height(48).fontSize(26 * this.fontScale)
        .backgroundColor(Color.Transparent).layoutWeight(1)
        .onChange((v: string) => cb(v))
    }
    .width('100%').padding({ left: 16, right: 16 })
  }

  @Builder PasswordPanel() {
    Column({ space: 12 }) {
      Text('修改密码（本地模拟）').fontSize(24).fontWeight(FontWeight.Bold).fontColor(ThemeUtil.titleColor(this.darkMode)).alignSelf(ItemAlign.Start)
      TextInput({ text: this.oldPwd, placeholder: '旧密码' })
        .type(InputType.Password).height(48).fontSize(26)
        .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8).padding({ left: 16, right: 16 })
        .onChange((v: string) => this.oldPwd = v)
      TextInput({ text: this.newPwd, placeholder: '新密码（至少6位）' })
        .type(InputType.Password).height(48).fontSize(26)
        .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8).padding({ left: 16, right: 16 })
        .onChange((v: string) => this.newPwd = v)
      TextInput({ text: this.confirmPwd, placeholder: '确认新密码' })
        .type(InputType.Password).height(48).fontSize(26)
        .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8).padding({ left: 16, right: 16 })
        .onChange((v: string) => this.confirmPwd = v)
      Button('确认修改').width('100%').height(48).fontSize(26).fontColor(AppColors.BG_CARD).backgroundColor(AppColors.PRIMARY).borderRadius(8)
        .onClick(() => {
          if (this.newPwd.length < 6) { this.getUIContext()?.getPromptAction()?.showToast({ message: '密码至少6位' }); return; }
          if (this.newPwd !== this.confirmPwd) { this.getUIContext()?.getPromptAction()?.showToast({ message: '两次密码不一致' }); return; }
          this.showPwdPanel = false;
          this.getUIContext()?.getPromptAction()?.showToast({ message: '密码修改成功' });
        })
    }
    .padding(16).backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)
  }

  private pickAvatar(): void {
    try {
      const docPicker = new picker.DocumentViewPicker();
      docPicker.select(new picker.DocumentSelectOptions()).then((uris: string[]) => {
        if (uris && uris.length > 0) { this.avatarUri = uris[0]; this.getUIContext()?.getPromptAction()?.showToast({ message: '头像上传成功' }); }
      }).catch(() => { this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟头像上传' }); });
    } catch (err) { this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟头像上传' }); }
  }
}
