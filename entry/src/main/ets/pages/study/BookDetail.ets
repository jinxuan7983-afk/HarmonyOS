import router from '@ohos.router';
import { AppColors } from '../../common/constants/AppColors';
import { ThemeUtil } from '../../common/utils/ThemeUtil';
import { StatusBarUtil } from '../../common/utils/StatusBarUtil';

/**
 * 【学习助手 · 图书详情页】
 * 设计规范：导航栏30sp、中标题28sp、正文26sp、辅助文字24sp
 * 展示图书完整信息：封面 + 书名/作者/ISBN + 馆藏信息 + 收藏按钮 + 简介
 */
interface BookDetailParams {
  name: string;
  author: string;
  isbn: string;
  location: string;
  count: number;
  status: string;
}

interface BookInfoItem {
  label: string;
  value: string;
  color?: string;
}

@Entry
@Component
struct BookDetail {
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
  }

  @StorageLink('darkMode') darkMode: boolean = false;
  @StorageLink('fontScale') fontScale: number = 1.0;
  @State statusBarHeight: number = 0;
  @State name: string = '';
  @State author: string = '';
  @State isbn: string = '';
  @State location: string = '';
  @State count: number = 0;
  @State status: string = 'none';

  async aboutToAppear(): Promise<void> {
    this.statusBarHeight = await StatusBarUtil.getStatusBarHeight(this.getUIContext().getHostContext());
    const params = router.getParams() as BookDetailParams;
    if (params) {
      this.name = params.name || '未命名图书';
      this.author = params.author || '';
      this.isbn = params.isbn || '';
      this.location = params.location || '';
      this.count = params.count ?? 0;
      this.status = params.status || 'none';
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
        Text('图书详情')
          .fontSize(30).fontWeight(600).fontColor(ThemeUtil.titleColor(this.darkMode))
          .margin({ left: 8 }).layoutWeight(1)
        SymbolGlyph(this.status === 'saved' ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
          .fontSize(24)
          .fontColor([this.status === 'saved' ? AppColors.WARNING : AppColors.PRIMARY])
          .onClick(() => {
            this.status = this.status === 'saved' ? 'none' : 'saved';
            this.getUIContext()?.getPromptAction()?.showToast({
              message: this.status === 'saved' ? '已收藏' : '已取消收藏'
            });
          })
      }
      .width('100%').height(52).padding({ left: 16, right: 16 })
      .backgroundColor(ThemeUtil.cardBg(this.darkMode))

      Scroll() {
        Column({ space: 16 }) {
          // 图书封面 + 基本信息
          Row({ space: 16 }) {
            // 封面
            Column() {
              SymbolGlyph($r('sys.symbol.book'))
                .fontSize(48).fontColor([AppColors.PRIMARY])
            }
            .width(120).height(160)
            .backgroundColor(AppColors.PRIMARY_LIGHT).borderRadius(8)
            .justifyContent(FlexAlign.Center)

            // 基本信息
            Column({ space: 8 }) {
              Text(this.name)
                .fontSize(28 * this.fontScale).fontWeight(600)
                .fontColor(ThemeUtil.titleColor(this.darkMode))
                .lineHeight(28 * this.fontScale * AppColors.LINE_HEIGHT_TITLE_M)
                .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              Text(this.author)
                .fontSize(26 * this.fontScale)
                .fontColor(ThemeUtil.subColor(this.darkMode))

              Text(`ISBN: ${this.isbn}`)
                .fontSize(24 * this.fontScale)
                .fontColor(ThemeUtil.subColor(this.darkMode))

              // 馆藏状态标签
              Row() {
                Text(this.count > 0 ? '可借阅' : '已借完')
                  .fontSize(22 * this.fontScale)
                  .fontColor(this.count > 0 ? AppColors.SUCCESS : AppColors.DANGER)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .backgroundColor(this.count > 0 ? AppColors.SUCCESS_LIGHT : AppColors.DANGER_LIGHT)
                  .borderRadius(4)
              }
              .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .width('100%').padding(16)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

          // 馆藏信息
          Column({ space: 0 }) {
            Text('馆藏信息')
              .fontSize(26 * this.fontScale).fontWeight(600)
              .fontColor(ThemeUtil.titleColor(this.darkMode))
              .width('100%').padding({ bottom: 12 })

            ForEach(this.getBookInfoItems(), (item: BookInfoItem) => {
              Row() {
                Text(item.label)
                  .fontSize(26 * this.fontScale)
                  .fontColor(ThemeUtil.subColor(this.darkMode))
                  .width(100)
                Text(item.value)
                  .fontSize(26 * this.fontScale)
                  .fontColor(item.color || ThemeUtil.titleColor(this.darkMode))
                  .layoutWeight(1)
              }
              .width('100%').height(48)

              Divider().color(AppColors.DIVIDER).strokeWidth(1).width('94%')
            })
          }
          .width('100%').padding(16)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

          // 图书简介
          Column({ space: 12 }) {
            Text('图书简介')
              .fontSize(26 * this.fontScale).fontWeight(600)
              .fontColor(ThemeUtil.titleColor(this.darkMode))
              .width('100%')

            Text(this.getBookSummary())
              .fontSize(26 * this.fontScale)
              .fontColor(ThemeUtil.subColor(this.darkMode))
              .lineHeight(26 * this.fontScale * AppColors.LINE_HEIGHT_BODY)
              .width('100%')
          }
          .width('100%').padding(16)
          .backgroundColor(ThemeUtil.cardBg(this.darkMode)).borderRadius(8)

          // 操作按钮
          Row({ space: 16 }) {
            Button(this.status === 'borrowed' ? '归还图书' : '预约借阅')
              .fontSize(26 * this.fontScale).fontColor(AppColors.BG_CARD)
              .backgroundColor(AppColors.PRIMARY)
              .layoutWeight(1).height(48).borderRadius(8)
              .onClick(() => {
                if (this.status === 'borrowed') {
                  this.status = 'none';
                  this.count += 1;
                  this.getUIContext()?.getPromptAction()?.showToast({ message: '已模拟归还' });
                } else {
                  this.getUIContext()?.getPromptAction()?.showToast({ message: `已预约借阅《${this.name}》，请到${this.location}取书` });
                }
              })
            Button(this.getStatusLabel())
              .fontSize(26 * this.fontScale)
              .fontColor(this.status === 'saved' ? AppColors.WARNING : AppColors.PRIMARY)
              .backgroundColor(this.status === 'saved' ? AppColors.WARNING_LIGHT : AppColors.PRIMARY_LIGHT)
              .layoutWeight(1).height(48).borderRadius(8)
              .onClick(() => {
                if (this.status === 'none') {
                  this.status = 'saved';
                  this.getUIContext()?.getPromptAction()?.showToast({ message: '已收藏' });
                } else if (this.status === 'saved') {
                  this.status = 'want';
                  this.getUIContext()?.getPromptAction()?.showToast({ message: '标记想看' });
                } else if (this.status === 'want') {
                  this.status = 'borrowed';
                  this.count = Math.max(0, this.count - 1);
                  this.getUIContext()?.getPromptAction()?.showToast({ message: '标记已借' });
                } else {
                  this.status = 'none';
                  this.getUIContext()?.getPromptAction()?.showToast({ message: '取消标记' });
                }
              })
          }
          .width('100%')
        }
        .width('100%').padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor(ThemeUtil.pageBg(this.darkMode))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private getBookInfoItems(): BookInfoItem[] {
    return [
      { label: '馆藏位置', value: this.location, color: AppColors.PRIMARY },
      { label: '剩余数量', value: `${this.count} 册`, color: this.count > 0 ? AppColors.SUCCESS : AppColors.DANGER },
      { label: 'ISBN', value: this.isbn },
      { label: '作者', value: this.author },
      { label: '出版社', value: this.getPublisher() }
    ];
  }

  private getPublisher(): string {
    if (this.isbn.includes('7-121')) return '电子工业出版社';
    if (this.isbn.includes('7-302')) return '清华大学出版社';
    if (this.isbn.includes('7-111')) return '机械工业出版社';
    return '未知出版社';
  }

  private getStatusLabel(): string {
    switch (this.status) {
      case 'saved': return '已收藏';
      case 'want': return '想读';
      case 'borrowed': return '已借出';
      default: return '收藏';
    }
  }

  private getBookSummary(): string {
    const summaries: Record<string, string> = {
      'HarmonyOS开发实战': '本书是面向 HarmonyOS NEXT 开发者的实战指南，涵盖 ArkUI 声明式开发范式、Stage 模型、ArkTS 语言基础等核心内容。通过丰富的项目案例，从 UI 布局、数据管理、页面路由到多媒体应用，循序渐进地带领读者掌握鸿蒙应用开发全流程。适合高等院校移动应用开发课程使用。',
      '移动应用UI设计': '本书系统讲解移动端用户界面设计的理论与实战方法，涵盖设计规范、色彩搭配、交互设计、组件库构建等核心知识。结合 HarmonyOS、iOS、Android 三大平台的设计语言差异，帮助读者建立跨平台 UI 设计思维。配有大量真实案例和可复用的设计模板。',
      '软件工程导论': '本书是软件工程领域的经典教材，全面介绍软件开发生命周期、需求分析、系统设计、编码实现、测试维护等核心概念。结合敏捷开发、DevOps 等现代方法论，帮助读者建立系统化的软件工程思维。适合计算机科学与技术、软件工程专业本科教学使用。',
      '数据库系统概念': '本书是数据库领域的经典之作，从关系代数、SQL 语言到事务管理、并发控制，系统阐述数据库系统核心原理。最新版增加了 NoSQL、分布式数据库、大数据处理等内容，适合作为计算机科学本科高年级及研究生教材。',
      '人工智能基础': '本书深入浅出地介绍人工智能核心概念与算法，涵盖机器学习、深度学习、自然语言处理、计算机视觉等前沿领域。通过 Python 代码实例，帮助读者从理论到实践全面掌握 AI 技术。适合高等院校人工智能通识课程及自学使用。'
    };
    return summaries[this.name] || `${this.name}是一本优秀的学术著作，由${this.author}编著。本书内容丰富、结构清晰，适合作为高等院校相关专业的教材或参考书。馆藏位置：${this.location}，当前剩余${this.count}册可供借阅。`;
  }
}
