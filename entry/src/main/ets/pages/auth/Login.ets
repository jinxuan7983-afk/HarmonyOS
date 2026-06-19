import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import { AppColors } from '../../common/constants/AppColors';

/**
 * 【2.3 登录/注册页】合并布局，标签切换
 * 设计规范：
 * - 标签栏：28sp，选中鸿蒙蓝+2px下划线，未选中文字辅色
 * - 输入框：48px高，8px圆角，左右内边距16px，左侧图标鸿蒙蓝
 * - 按钮：100%宽，48px高，26sp白色文字，8px圆角
 * - 未激活：#C6E2FF背景 + #86909C文字
 * - 记住密码/忘记密码：24sp
 * - 验证码按钮：暖橙小按钮，白色文字24sp
 * - 注册协议文字：22sp
 * - 底部切换：24sp
 * - 第三方登录图标：圆形36px
 */
@Entry
@Component
struct Login {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .opacity(0)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .opacity(0)
  }
  @State activeTab: string = '登录';
  @State loginAccount: string = '20260001';
  @State loginPassword: string = '123456';
  @State showPassword: boolean = false;
  @State rememberPwd: boolean = true;
  @State loginLoading: boolean = false;
  @State focusLoginAccount: boolean = false;
  @State focusLoginPassword: boolean = false;

  @State regName: string = '';
  @State regAccount: string = '';
  @State regPassword: string = '';
  @State regConfirmPwd: string = '';
  @State regVerifyCode: string = '';
  @State agreeProtocol: boolean = false;
  @State codeSending: boolean = false;
  @State codeCountdown: number = 0;
  @State regLoading: boolean = false;

  @State showProtocolModal: boolean = false;

  private verifyTimer: number = 0;

  aboutToAppear(): void {
    console.info('Login页面 aboutToAppear');
    this.loadSavedCredentials();
  }

  aboutToDisappear(): void {
    console.info('Login页面 aboutToDisappear');
    if (this.verifyTimer !== 0) {
      clearInterval(this.verifyTimer);
      this.verifyTimer = 0;
    }
  }

  private async loadSavedCredentials(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_info');
      const savedAccount = await prefs.get('account', '');
      const savedPassword = await prefs.get('password', '');
      const savedRemember = await prefs.get('remember', false);
      if (savedRemember && savedAccount) {
        this.loginAccount = savedAccount as string;
        this.loginPassword = savedPassword as string;
        this.rememberPwd = true;
      }
    } catch (_err) {
      // 首次无缓存
    }
  }

  private async saveCredentials(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_info');
      await prefs.put('account', this.loginAccount);
      await prefs.put('password', this.rememberPwd ? this.loginPassword : '');
      await prefs.put('remember', this.rememberPwd);
      await prefs.flush();
    } catch (_err) {
      // 保存失败不影响登录
    }
  }

  private async saveUserInfo(name: string, account: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_info');
      await prefs.put('nickname', name || '校园助手用户');
      await prefs.put('account', account);
      await prefs.put('loggedIn', true);
      await prefs.flush();
    } catch (_err) {
      // 忽略
    }
  }

  private isLoginActive(): boolean {
    return this.loginAccount.trim().length > 0 && this.loginPassword.trim().length > 0;
  }

  private isRegisterActive(): boolean {
    return this.regName.trim().length > 0 &&
      this.regAccount.trim().length > 0 &&
      this.regPassword.trim().length >= 6 &&
      this.regConfirmPwd.trim().length > 0 &&
      this.regVerifyCode.trim().length > 0 &&
      this.agreeProtocol;
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 0 }) {
        // Logo区域
        Image($r('app.media.logo'))
          .width(88)
          .height(88)
          .borderRadius(24)
          .margin({ top: 44 })

        Text('高校校园助手')
          .fontSize(32)
          .fontWeight(700)
          .fontColor(AppColors.PRIMARY)
          .margin({ top: 14 })

        Text('校园信息 · 学习助手 · 生活服务')
          .fontSize(24)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: 8 })

        // ===== 标签栏 =====
        Row() {
          Column({ space: 8 }) {
            Text('登录')
              .fontSize(28)
              .fontWeight(this.activeTab === '登录' ? 600 : 400)
              .fontColor(this.activeTab === '登录' ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY)
            if (this.activeTab === '登录') {
              Divider()
                .width(40)
                .height(2)
                .color(AppColors.PRIMARY)
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => { this.activeTab = '登录'; })

          Column({ space: 8 }) {
            Text('注册')
              .fontSize(28)
              .fontWeight(this.activeTab === '注册' ? 600 : 400)
              .fontColor(this.activeTab === '注册' ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY)
            if (this.activeTab === '注册') {
              Divider()
                .width(40)
                .height(2)
                .color(AppColors.PRIMARY)
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => { this.activeTab = '注册'; })
        }
        .width('90%')
        .margin({ top: 30 })

        // ===== 表单 =====
        if (this.activeTab === '登录') {
          this.LoginForm()
        } else {
          this.RegisterForm()
        }

        // ===== 底部切换 =====
        Row() {
          Text(this.activeTab === '登录' ? '暂无账号？' : '已有账号？')
            .fontSize(24)
            .fontColor(AppColors.TEXT_SECONDARY)
          Text(this.activeTab === '登录' ? '立即注册' : '立即登录')
            .fontSize(24)
            .fontColor(AppColors.PRIMARY)
            .fontWeight(500)
            .margin({ left: 4 })
            .onClick(() => {
              this.activeTab = this.activeTab === '登录' ? '注册' : '登录';
            })
        }
        .margin({ top: 24 })

        // ===== 第三方登录 =====
        Column({ space: 16 }) {
          Text('其他登录方式')
            .fontSize(24)
            .fontColor(AppColors.TEXT_SECONDARY)

          Row({ space: 32 }) {
            Column({ space: 6 }) {
              Text('微')
                .fontSize(22)
                .fontColor(AppColors.BG_CARD)
                .width(36)
                .height(36)
                .textAlign(TextAlign.Center)
                .backgroundColor('#07C160')
                .borderRadius(18)
              Text('微信')
                .fontSize(22)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .onClick(() => this.getUIContext()?.getPromptAction()?.showToast({ message: '微信登录功能开发中' }))

            Column({ space: 6 }) {
              Text('Q')
                .fontSize(22)
                .fontColor(AppColors.BG_CARD)
                .width(36)
                .height(36)
                .textAlign(TextAlign.Center)
                .backgroundColor('#12B7F5')
                .borderRadius(18)
              Text('QQ')
                .fontSize(22)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .onClick(() => this.getUIContext()?.getPromptAction()?.showToast({ message: 'QQ登录功能开发中' }))
          }
        }
        .margin({ top: 28, bottom: 40 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.BG_PAGE)
      .scrollBar(BarState.Off)

      // 注册协议弹窗
      if (this.showProtocolModal) {
        this.ProtocolModal()
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // ========== 协议弹窗 ==========
  @Builder
  ProtocolModal() {
    Column() {
      Column({ space: 16 }) {
        Text('用户注册协议')
          .fontSize(28)
          .fontWeight(700)
          .fontColor(AppColors.TEXT_PRIMARY)
          .width('100%')
          .textAlign(TextAlign.Center)

        Text('欢迎使用高校校园助手APP。请您仔细阅读以下条款：\n\n一、用户信息保护\n我们仅收集您的学号、姓名等必要信息用于身份识别，不会泄露给第三方。\n\n二、使用规范\n您承诺不利用本APP进行任何违法违规活动。\n\n三、功能说明\n本APP为课程演示项目，所有数据均为本地存储，不会上传至服务器。\n\n四、免责声明\n本APP中的数据仅供参考，以学校官方通知为准。')
          .fontSize(24)
          .fontColor(AppColors.TEXT_TERTIARY)
          .lineHeight(36)
          .width('100%')

        Row({ space: 12 }) {
          Button('不同意')
            .layoutWeight(1)
            .height(48)
            .fontSize(26)
            .fontColor(AppColors.TEXT_SECONDARY)
            .backgroundColor(AppColors.DIVIDER)
            .borderRadius(8)
            .onClick(() => { this.showProtocolModal = false; })
          Button('同意并继续')
            .layoutWeight(1)
            .height(48)
            .fontSize(26)
            .fontColor(AppColors.BG_CARD)
            .backgroundColor(AppColors.PRIMARY)
            .borderRadius(8)
            .onClick(() => {
              this.agreeProtocol = true;
              this.showProtocolModal = false;
              this.getUIContext()?.getPromptAction()?.showToast({ message: '已同意用户协议' });
            })
        }
        .width('100%')
      }
      .width('88%')
      .padding(24)
      .backgroundColor(AppColors.BG_CARD)
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#66000000')
    .position({ x: 0, y: 0 })
    .onClick(() => { this.showProtocolModal = false; })
  }

  // ========== 登录表单 ==========
  @Builder
  LoginForm() {
    Column({ space: 18 }) {
      // 学号
      Column({ space: 8 }) {
        Text('学号')
          .fontSize(24)
          .fontColor(AppColors.TEXT_SECONDARY)
          .alignSelf(ItemAlign.Start)
        Row({ space: 12 }) {
          Text('🎓')
            .fontSize(24)
            .fontColor(AppColors.PRIMARY)
            .width(32)
            .textAlign(TextAlign.Center)
          TextInput({ text: $$this.loginAccount, placeholder: '请输入你的学号' })
            .height(48)
            .fontSize(26)
            .type(InputType.Normal)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onFocus(() => { this.focusLoginAccount = true; })
            .onBlur(() => { this.focusLoginAccount = false; })
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor(AppColors.BG_CARD)
        .borderRadius(8)
        .border({ width: 1, color: this.focusLoginAccount ? AppColors.PRIMARY : AppColors.BORDER })
      }
      .width('90%')

      // 密码
      Column({ space: 8 }) {
        Text('密码')
          .fontSize(24)
          .fontColor(AppColors.TEXT_SECONDARY)
          .alignSelf(ItemAlign.Start)
        Row({ space: 12 }) {
          Text('🔒')
            .fontSize(24)
            .fontColor(AppColors.PRIMARY)
            .width(32)
            .textAlign(TextAlign.Center)
          TextInput({ text: $$this.loginPassword, placeholder: '请输入你的密码' })
            .height(48)
            .fontSize(26)
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onFocus(() => { this.focusLoginPassword = true; })
            .onBlur(() => { this.focusLoginPassword = false; })
          Text(this.showPassword ? '👁' : '👁‍🗨')
            .fontSize(24)
            .width(32)
            .textAlign(TextAlign.Center)
            .onClick(() => { this.showPassword = !this.showPassword; })
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor(AppColors.BG_CARD)
        .borderRadius(8)
        .border({ width: 1, color: this.focusLoginPassword ? AppColors.PRIMARY : AppColors.BORDER })
      }
      .width('90%')

      // 记住密码 + 忘记密码
      Row() {
        Row({ space: 8 }) {
          Checkbox()
            .select(this.rememberPwd)
            .selectedColor(AppColors.PRIMARY)
            .width(22)
            .height(22)
            .onChange((checked: boolean) => { this.rememberPwd = checked; })
          Text('记住密码')
            .fontSize(24)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        Blank()
        Text('忘记密码')
          .fontSize(24)
          .fontColor(AppColors.PRIMARY)
          .fontWeight(500)
          .onClick(() => router.pushUrl({ url: 'pages/auth/ForgotPassword' }))
      }
      .width('90%')

      // 登录按钮
      Button('登录')
        .width('90%')
        .height(48)
        .fontSize(26)
        .fontColor(this.isLoginActive() ? AppColors.BG_CARD : AppColors.TEXT_SECONDARY)
        .backgroundColor(this.isLoginActive() ? AppColors.PRIMARY : AppColors.PRIMARY_BG)
        .borderRadius(8)
        .shadow(this.isLoginActive() ?
          { radius: 10, color: AppColors.PRIMARY_DARK, offsetX: 0, offsetY: 4 } :
          { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
        .onClick(() => {
          if (!this.isLoginActive()) {
            this.getUIContext()?.getPromptAction()?.showToast({ message: '请输入学号和密码' });
            return;
          }
          this.loginLoading = true;
          this.getUIContext()?.getPromptAction()?.showToast({ message: '登录成功' });
          this.saveCredentials();
          this.saveUserInfo('校园助手用户', this.loginAccount);
          setTimeout(() => {
            this.loginLoading = false;
            router.replaceUrl({ url: 'pages/home/Home' });
          }, 800);
        })

      if (this.loginLoading) {
        Row({ space: 8 }) {
          LoadingProgress().width(24).height(24).color(AppColors.PRIMARY)
          Text('正在登录...').fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
        }
      }
    }
  }

  // ========== 注册表单 ==========
  @Builder
  RegisterForm() {
    Column({ space: 16 }) {
      this.RegField('姓名', '请输入你的真实姓名', '👤', this.regName, (v: string) => this.regName = v)
      this.RegField('学号', '请输入你的学号', '🎓', this.regAccount, (v: string) => this.regAccount = v)

      // 密码
      Column({ space: 8 }) {
        Text('密码').fontSize(24).fontColor(AppColors.TEXT_SECONDARY).alignSelf(ItemAlign.Start)
        Row({ space: 12 }) {
          Text('🔒').fontSize(24).fontColor(AppColors.PRIMARY).width(32).textAlign(TextAlign.Center)
          TextInput({ text: $$this.regPassword, placeholder: '请设置密码（至少6位）' })
            .height(48).fontSize(26).type(InputType.Password)
            .backgroundColor(Color.Transparent).layoutWeight(1)
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
          TextInput({ text: $$this.regConfirmPwd, placeholder: '请再次输入密码' })
            .height(48).fontSize(26).type(InputType.Password)
            .backgroundColor(Color.Transparent).layoutWeight(1)
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
          TextInput({ text: $$this.regVerifyCode, placeholder: '请输入验证码' })
            .height(48).fontSize(26).type(InputType.Normal)
            .backgroundColor(Color.Transparent).layoutWeight(1)
          Button(this.codeSending ? `${this.codeCountdown}s` : '获取验证码')
            .height(36).fontSize(24)
            .fontColor(this.codeSending ? AppColors.TEXT_SECONDARY : AppColors.BG_CARD)
            .backgroundColor(this.codeSending ? AppColors.DIVIDER : AppColors.WARNING)
            .borderRadius(8)
            .enabled(!this.codeSending)
            .onClick(() => { this.sendVerifyCode(); })
        }
        .width('100%').height(48).padding({ left: 16, right: 8 })
        .backgroundColor(AppColors.BG_CARD).borderRadius(8).border({ width: 1, color: AppColors.BORDER })
      }
      .width('90%')

      // 注册协议
      Row({ space: 6 }) {
        Checkbox()
          .select(this.agreeProtocol)
          .selectedColor(AppColors.PRIMARY)
          .width(22).height(22)
          .onChange((checked: boolean) => { this.agreeProtocol = checked; })
        Text('我已阅读并同意')
          .fontSize(22)
          .fontColor(AppColors.TEXT_SECONDARY)
        Text('《用户注册协议》')
          .fontSize(22)
          .fontColor(AppColors.PRIMARY)
          .fontWeight(500)
          .onClick(() => { this.showProtocolModal = true; })
      }
      .width('90%')

      // 注册按钮
      Button('注册')
        .width('90%')
        .height(48)
        .fontSize(26)
        .fontColor(this.isRegisterActive() ? AppColors.BG_CARD : AppColors.TEXT_SECONDARY)
        .backgroundColor(this.isRegisterActive() ? AppColors.PRIMARY : AppColors.PRIMARY_BG)
        .borderRadius(8)
        .shadow(this.isRegisterActive() ?
          { radius: 10, color: AppColors.PRIMARY_DARK, offsetX: 0, offsetY: 4 } :
          { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
        .onClick(() => {
          if (!this.isRegisterActive()) {
            this.getUIContext()?.getPromptAction()?.showToast({ message: '请填写完整信息并同意协议' });
            return;
          }
          if (this.regPassword !== this.regConfirmPwd) {
            this.getUIContext()?.getPromptAction()?.showToast({ message: '两次密码不一致' });
            return;
          }
          if (this.regPassword.length < 6) {
            this.getUIContext()?.getPromptAction()?.showToast({ message: '密码至少6位' });
            return;
          }
          this.regLoading = true;
          this.getUIContext()?.getPromptAction()?.showToast({ message: '注册成功！已进入演示账号' });
          this.saveUserInfo(this.regName, this.regAccount);
          setTimeout(() => {
            this.regLoading = false;
            router.replaceUrl({ url: 'pages/home/Home' });
          }, 800);
        })

      if (this.regLoading) {
        Row({ space: 8 }) {
          LoadingProgress().width(24).height(24).color(AppColors.PRIMARY)
          Text('正在注册...').fontSize(24).fontColor(AppColors.TEXT_SECONDARY)
        }
      }
    }
  }

  private sendVerifyCode(): void {
    this.codeSending = true;
    this.codeCountdown = 60;
    this.getUIContext()?.getPromptAction()?.showToast({ message: '验证码：8888（模拟发送）' });
    if (this.verifyTimer !== 0) clearInterval(this.verifyTimer);
    this.verifyTimer = setInterval(() => {
      this.codeCountdown -= 1;
      if (this.codeCountdown <= 0) {
        this.codeSending = false;
        clearInterval(this.verifyTimer);
        this.verifyTimer = 0;
      }
    }, 1000);
  }

  @Builder
  RegField(label: string, placeholder: string, icon: string, value: string, onChange: (v: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(24)
        .fontColor(AppColors.TEXT_SECONDARY)
        .alignSelf(ItemAlign.Start)
      Row({ space: 12 }) {
        Text(icon)
          .fontSize(24)
          .fontColor(AppColors.PRIMARY)
          .width(32)
          .textAlign(TextAlign.Center)
        TextInput({ text: value, placeholder: placeholder })
          .height(48)
          .fontSize(26)
          .type(InputType.Normal)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((v: string) => onChange(v))
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor(AppColors.BG_CARD)
      .borderRadius(8)
      .border({ width: 1, color: AppColors.BORDER })
    }
    .width('90%')
  }
}
