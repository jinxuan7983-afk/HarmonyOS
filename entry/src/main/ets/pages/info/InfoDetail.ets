import router from '@ohos.router';
import { pasteboard } from '@kit.BasicServicesKit';
import { AppColors } from '../../common/constants/AppColors';

/**
 * 【3.3.2 校园资讯详情页】
 * - 展示校园新闻、社团活动、讲座信息等完整内容
 * - 支持图片放大查看（全屏预览模拟）
 * - 支持文字复制到剪贴板
 */
interface RouterParams {
  title: string;
  category: string;
  time: string;
  summary: string;
}

@Entry
@Component
struct InfoDetail {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }
  @State title: string = '';
  @State category: string = '';
  @State time: string = '';
  @State summary: string = '';
  @State collected: boolean = false;
  @State fullScreenImage: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams;
    if (params) {
      this.title = params.title || '未命名资讯';
      this.category = params.category || '校园资讯';
      this.time = params.time || '';
      this.summary = params.summary || '';
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
        Text('资讯详情')
          .fontSize(30)
          .fontWeight(600)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 8 })
          .layoutWeight(1)
        Text(this.collected ? '★' : '☆')
          .fontSize(20)
          .fontColor(this.collected ? AppColors.WARNING : AppColors.TEXT_SECONDARY)
          .onClick(() => {
            this.collected = !this.collected;
            this.getUIContext()?.getPromptAction()?.showToast({ message: this.collected ? '已收藏' : '取消收藏' });
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(AppColors.BG_CARD)

      Scroll() {
        Column({ space: 16 }) {
          // 大图展示
          Stack() {
            Image($r('app.media.background'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
            // 图片放大按钮
            Column() {
              Text('🔍 点击放大查看')
                .fontSize(13)
                .fontColor(AppColors.BG_CARD)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#33000000')
                .borderRadius(4)
            }
            .width('100%')
            .height('100%')
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.End)
            .padding(12)
          }
          .onClick(() => {
            this.fullScreenImage = !this.fullScreenImage;
            this.getUIContext()?.getPromptAction()?.showToast({
              message: this.fullScreenImage ? '已进入全屏预览模式（模拟）' : '已退出全屏预览'
            });
          })

          // 标题区
          Column({ space: 12 }) {
            Text(this.title)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY)
              .lineHeight(38)
              .width('100%')

            Row({ space: 12 }) {
              Text(this.category)
                .fontSize(14)
                .fontColor(AppColors.PRIMARY)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(AppColors.PRIMARY_LIGHT)
                .borderRadius(6)
              Text(this.time)
                .fontSize(14)
                .fontColor(AppColors.TEXT_SECONDARY)
              Blank()
              Text('阅读 1.2k')
                .fontSize(13)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.BG_CARD)
          .borderRadius(8)

          // 正文区 - 完整内容
          Column({ space: 16 }) {
            ForEach(this.getFullContent(), (paragraph: string, index: number) => {
              if (paragraph.startsWith('【图片】')) {
                // 文中插图
                Column({ space: 6 }) {
                  Image($r('app.media.foreground'))
                    .width('100%')
                    .height(180)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(6)
                    .onClick(() => {
                      this.getUIContext()?.getPromptAction()?.showToast({ message: '图片已放大（模拟全屏预览）' });
                    })
                  Text(paragraph.replace('【图片】', ''))
                    .fontSize(13)
                    .fontColor(AppColors.TEXT_SECONDARY)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                }
              } else if (paragraph.startsWith('##')) {
                // 小标题
                Text(paragraph.replace('##', ''))
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .width('100%')
                  .margin({ top: 8 })
              } else if (paragraph === '') {
                // 空行保留间距
                Text('').height(4).width('100%')
              } else {
                // 正文段落
                Text(paragraph)
                  .fontSize(17)
                  .fontColor(AppColors.TEXT_TERTIARY)
                  .lineHeight(30)
                  .width('100%')
                  .onClick(() => {
                    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, paragraph);
                    pasteboard.getSystemPasteboard().setData(pasteData);
                    this.getUIContext()?.getPromptAction()?.showToast({ message: '已复制到剪贴板' });
                  })
              }
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.BG_CARD)
          .borderRadius(8)

          // 底部操作
          Row({ space: 16 }) {
            Button('📋 复制全文')
              .fontSize(14)
              .fontColor(AppColors.PRIMARY)
              .backgroundColor(AppColors.PRIMARY_LIGHT)
              .layoutWeight(1)
              .borderRadius(8)
              .height(44)
              .onClick(() => {
                const fullText = `【${this.category}】${this.title}\n\n${this.summary}`;
                const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, fullText);
                pasteboard.getSystemPasteboard().setData(pasteData);
                this.getUIContext()?.getPromptAction()?.showToast({ message: '全文已复制到剪贴板' });
              })
            Button('分享')
              .fontSize(14)
              .fontColor(AppColors.BG_CARD)
              .backgroundColor(AppColors.PRIMARY)
              .layoutWeight(1)
              .borderRadius(8)
              .height(44)
              .onClick(() => {
                this.getUIContext()?.getPromptAction()?.showToast({ message: '已生成分享链接（本地模拟）' });
              })
          }
          .width('100%')
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

  private getFullContent(): string[] {
    const category = this.category;
    const common: string[] = [
      `近日，${category === '学术讲座' ? '学校' : '校园内'}迎来一项重要活动，吸引了大批同学关注和参与。`,
      '',
      this.summary,
      ''
    ];

    if (category === '校园资讯') {
      return common.concat([
        '##活动详情',
        '本次活动面向全校师生开放，不限专业和年级。活动筹备工作已提前两周展开，由学生社团联合会牵头，联合多个学院共同举办。',
        '',
        '现场设置了多个互动环节，包括知识问答、趣味游戏和抽奖活动，参与者在轻松愉快的氛围中收获知识和快乐。',
        '',
        '【图片】活动现场盛况',
        '',
        '活动期间还展示了过去一年校园文化建设的成果，让同学们充分了解学校在丰富课余生活方面所做的努力和取得的成效。',
        '',
        '##参与反馈',
        '参与活动的张同学表示："这样的活动非常有意义，不仅丰富了我们的课余生活，还让我们学到了很多课堂上学不到的知识。"',
        '',
        '来自不同学院的同学们纷纷表示，希望学校能继续举办更多类似的活动，让校园生活更加多彩。',
        '',
        '活动负责人介绍，未来还将持续推出更多校园文化活动，涵盖学术交流、文艺展演、体育竞技、创新创业等多个领域，欢迎大家持续关注校园助手APP获取最新资讯。',
        '',
        '##温馨提示',
        '· 更多精彩活动请关注校园助手APP',
        '· 活动精彩照片可在校园相册中查看',
        '· 点击首页"校园信息"获取更多校园资讯',
        '',
        `发布时间：${this.time}`,
        '来源：高校校园助手 · 校园资讯频道'
      ]);
    } else if (category === '社团活动') {
      return common.concat([
        '##活动安排',
        '本次社团活动由相关社团精心策划组织，旨在为同学们提供一个展示自我、交流学习的平台。活动内容丰富多样，适合各年级学生参与。',
        '',
        '活动组织方提前做好了充分准备，包括场地布置、物资采购、人员分工等，确保活动顺利进行。',
        '',
        '【图片】社团活动精彩瞬间',
        '',
        '##参与方式',
        '报名时间：即日起至活动开始前一天',
        '报名方式：通过校园助手APP在线报名或现场报名',
        '活动地点：详见具体活动通知',
        '',
        '注意事项：请参与同学遵守活动规则，保管好个人物品，听从工作人员指引。',
        '',
        '##往期回顾',
        '过去一学期，各社团已成功举办了数十场精彩活动，涵盖了文艺表演、体育竞技、志愿服务、科技创新等多个方面，丰富了同学们的校园文化生活。',
        '',
        `发布时间：${this.time}`,
        '来源：高校校园助手 · 社团活动频道'
      ]);
    } else if (category === '学术讲座') {
      return common.concat([
        '##讲座简介',
        '本次讲座邀请到相关领域的专家学者进行分享，内容涵盖前沿科技、学术研究方法、行业发展动态等方面，帮助同学们拓展学术视野、了解学科前沿。',
        '',
        '讲座将持续约90分钟，包括主讲人主题演讲和互动问答两个环节。',
        '',
        '【图片】讲座嘉宾介绍',
        '',
        '##讲座亮点',
        '· 邀请业界知名专家现场分享',
        '· 涵盖最新学术热点与技术趋势',
        '· 设有互动提问环节，可与专家面对面交流',
        '· 参与讲座可计入课外学术活动学分',
        '',
        '##往期回顾',
        '上一学期已成功举办了5场高水平学术讲座，累计参与学生超过2000人次，内容覆盖人工智能、大数据、新能源等前沿领域，受到了同学们的广泛好评。',
        '',
        '本学期将继续邀请更多专家学者，为同学们带来高质量的学术盛宴。',
        '',
        `发布时间：${this.time}`,
        '来源：高校校园助手 · 学术讲座频道'
      ]);
    }
    return common.concat([
      '活动得到了学校领导和各相关部门的大力支持，活动现场气氛热烈。',
      '',
      `发布时间：${this.time}`,
      '来源：高校校园助手'
    ]);
  }
}
