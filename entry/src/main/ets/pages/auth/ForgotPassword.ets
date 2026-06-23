import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import { AppColors } from '../../common/constants/AppColors';

/**
 * 【2.3 忘记密码页】
 * 简易找回密码：学号 + 验证码
 */
@Entry
@Component
struct ForgotPassword {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @State account: string = '';
  @State verifyCode: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State codeCountdown: number = 0;
  private verifyTimer: number = 0;

  aboutToDisappear(): void {
    if (this.verifyTimer !== 0) {
      clearInterval(this.verifyTimer);
      this.verifyTimer = 0;
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24).fillColor(AppColors.PRIMARY)
          .onClick(() => router.back())
        Text('找回密码')
          .fontSize(30).fontWeight(600).fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 8 }).layoutWeight(1)
      }
      .width('100%').height(52).padding({ left: 16, right: 16 }).backgroundColor(AppColors.BG_CARD)

      Scroll() {
        Column({ space: 24 }) {
          // 说明文字
          Text('请输入学号并通过验证码验证后重设密码')
            .fontSize(24).fontColor(AppColors.TEXT_SECONDARY).lineHeight(24 * AppColors.LINE_HEIGHT_AUX)
            .width('90%').margin({ top: 24 })

          // 学号
          Column({ space: 8 }) {
            Text('学号').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
            Row({ space: 12 }) {
              Text('🎓').fontSize(24).fontColor(AppColors.PRIMARY).width(32).textAlign(TextAlign.Center)
              TextInput({ text: $$this.account, placeholder: '请输入你的学号' })
                .height(48).fontSize(26).backgroundColor(Color.Transparent).layoutWeight(1)
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            .backgroundColor(AppColors.BG_CARD).borderRadius(8).border({ width: 1, color: AppColors.BORDER })
          }
          .width('90%')

          // 验证码
          Column({ space: 8 }) {
            Text('验证码').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
            Row({ space: 10 }) {
              Text('📱').fontSize(24).fontColor(AppColors.PRIMARY).width(32).textAlign(TextAlign.Center)
              TextInput({ text: $$this.verifyCode, placeholder: '请输入验证码' })
                .height(48).fontSize(26).backgroundColor(Color.Transparent).layoutWeight(1)
              Button(this.codeCountdown > 0 ? `${this.codeCountdown}s` : '获取验证码')
                .height(36).fontSize(24)
                .fontColor(this.codeCountdown > 0 ? AppColors.TEXT_SECONDARY : AppColors.BG_CARD)
                .backgroundColor(this.codeCountdown > 0 ? AppColors.DIVIDER : AppColors.WARNING)
                .borderRadius(8)
                .onClick(() => this.sendCode())
            }
            .width('100%').height(48).padding({ left: 16, right: 8 })
            .backgroundColor(AppColors.BG_CARD).borderRadius(8).border({ width: 1, color: AppColors.BORDER })
          }
          .width('90%')

          // 新密码
          Column({ space: 8 }) {
            Text('新密码').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
            Row({ space: 12 }) {
              Text('🔒').fontSize(24).fontColor(AppColors.PRIMARY).width(32).textAlign(TextAlign.Center)
              TextInput({ text: $$this.newPassword, placeholder: '请设置新密码（至少6位）' })
                .height(48).fontSize(26).type(InputType.Password).backgroundColor(Color.Transparent).layoutWeight(1)
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            .backgroundColor(AppColors.BG_CARD).borderRadius(8).border({ width: 1, color: AppColors.BORDER })
          }
          .width('90%')

          // 确认密码
          Column({ space: 8 }) {
            Text('确认密码').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
            Row({ space: 12 }) {
              Text('🔒').fontSize(24).fontColor(AppColors.PRIMARY).width(32).textAlign(TextAlign.Center)
              TextInput({ text: $$this.confirmPassword, placeholder: '请再次输入新密码' })
                .height(48).fontSize(26).type(InputType.Password).backgroundColor(Color.Transparent).layoutWeight(1)
            }
            .width('100%').height(48).padding({ left: 16, right: 16 })
            .backgroundColor(AppColors.BG_CARD).borderRadius(8).border({ width: 1, color: AppColors.BORDER })
          }
          .width('90%')

          // 重置按钮
          Button('重置密码')
            .width('100%').height(48).fontSize(26)
            .fontColor(this.canReset() ? AppColors.BG_CARD : AppColors.TEXT_SECONDARY)
            .backgroundColor(this.canReset() ? AppColors.PRIMARY : AppColors.PRIMARY_BG)
            .borderRadius(8)
            .onClick(async () => {
              if (!this.canReset()) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '请填写完整信息' });
                return;
              }
              if (this.newPassword.length < 6) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '密码至少6位' });
                return;
              }
              if (this.newPassword !== this.confirmPassword) {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '两次密码不一致' });
                return;
              }
              this.getUIContext()?.getPromptAction()?.showToast({ message: '密码重置成功' });
              try {
                const prefs = await preferences.getPreferences(getContext(this), 'user_info');
                await prefs.put('password', this.newPassword);
                await prefs.flush();
              } catch (_) {}
              router.back();
            })
        }
        .width('100%').alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(AppColors.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private sendCode(): void {
    if (this.account.trim().length === 0) {
      this.getUIContext()?.getPromptAction()?.showToast({ message: '请先输入学号' });
      return;
    }
    this.codeCountdown = 60;
    this.getUIContext()?.getPromptAction()?.showToast({ message: '验证码：6666（模拟发送）' });
    if (this.verifyTimer !== 0) clearInterval(this.verifyTimer);
    this.verifyTimer = setInterval(() => {
      this.codeCountdown -= 1;
      if (this.codeCountdown <= 0) {
        clearInterval(this.verifyTimer);
        this.verifyTimer = 0;
      }
    }, 1000);
  }

  private canReset(): boolean {
    return this.account.trim().length > 0 &&
      this.verifyCode.trim().length > 0 &&
      this.newPassword.trim().length >= 6 &&
      this.confirmPassword.trim().length > 0;
  }
}
