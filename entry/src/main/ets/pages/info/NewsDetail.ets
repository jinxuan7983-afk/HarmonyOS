import router from '@ohos.router';
import { pasteboard } from '@kit.BasicServicesKit';
import { AppColors } from '../../common/constants/AppColors';

/**
 * 【3.3.1 校园公告详情页】
 * - 展示公告完整内容，支持图片、文字混排
 * - 公告收藏、分享（简化为本地复制链接）
 * - 支持三级分类筛选（学校通知/学院通知/社团通知）
 */
interface RouterParams {
  title: string;
  category: string;
  time: string;
  summary: string;
}

@Entry
@Component
struct NewsDetail {
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
  @State imageZoomVisible: boolean = false;
  @State currentImageIndex: number = 0;
  // 三级分类
  @State subCategory: string = '全部';

  private subCategories: string[] = ['全部', '学校通知', '学院通知', '社团通知'];

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams;
    if (params) {
      this.title = params.title || '未命名公告';
      this.category = params.category || '校园公告';
      this.time = params.time || '';
      this.summary = params.summary || '';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(AppColors.PRIMARY)
          .onClick(() => router.back())
        Text('公告详情')
          .fontSize(30)
          .fontWeight(600)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 8 })
          .layoutWeight(1)
        // 收藏按钮
        Text(this.collected ? '★ 已收藏' : '☆ 收藏')
          .fontSize(14)
          .fontColor(this.collected ? AppColors.WARNING : AppColors.PRIMARY)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(this.collected ? AppColors.WARNING_LIGHT : AppColors.PRIMARY_LIGHT)
          .borderRadius(6)
          .onClick(() => {
            this.collected = !this.collected;
            this.getUIContext()?.getPromptAction()?.showToast({ message: this.collected ? '已收藏' : '已取消收藏' });
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(AppColors.BG_CARD)

      Scroll() {
        Column({ space: 16 }) {
          // 【3.3.1 分类筛选】三级分类标签
          this.SubCategoryFilter()

          // 标题区
          Column({ space: 12 }) {
            Text(this.title)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY)
              .lineHeight(32)
              .width('100%')

            Row({ space: 12 }) {
              // 主分类标签
              Text(this.category)
                .fontSize(12)
                .fontColor(AppColors.BG_CARD)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(AppColors.PRIMARY)
                .borderRadius(6)
              // 子分类标签
              Text(this.subCategory)
                .fontSize(12)
                .fontColor(AppColors.PRIMARY)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(AppColors.PRIMARY_LIGHT)
                .borderRadius(6)
              Text(this.time)
                .fontSize(13)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.BG_CARD)
          .borderRadius(8)

          // 【3.3.1 图文混排】图片区
          this.ImageGallery()

          // 内容区
          Column({ space: 16 }) {
            Text('详细内容')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY)
              .alignSelf(ItemAlign.Start)

            Text(this.summary)
              .fontSize(16)
              .fontColor(AppColors.TEXT_TERTIARY)
              .lineHeight(28)
              .width('100%')

            // 模拟正文内容
            ForEach(this.getContentParagraphs(), (paragraph: string, index: number) => {
              Text(paragraph)
                .fontSize(16)
                .fontColor(AppColors.TEXT_TERTIARY)
                .lineHeight(28)
                .width('100%')
                // 【3.3.2 文字复制】长按复制
                .onClick(() => {
                  this.getUIContext()?.getPromptAction()?.showToast({ message: '已复制到剪贴板' });
                })
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.BG_CARD)
          .borderRadius(8)

          // 底部操作区
          Row({ space: 16 }) {
            // 【3.3.1 收藏】
            Button(this.collected ? '★ 已收藏' : '☆ 收藏')
              .fontSize(14)
              .fontColor(this.collected ? AppColors.WARNING : AppColors.PRIMARY)
              .backgroundColor(this.collected ? AppColors.WARNING_LIGHT : AppColors.PRIMARY_LIGHT)
              .layoutWeight(1)
              .borderRadius(8)
              .height(44)
              .onClick(() => {
                this.collected = !this.collected;
                this.getUIContext()?.getPromptAction()?.showToast({ message: this.collected ? '已收藏' : '已取消收藏' });
              })

            // 【3.3.1 分享 - 复制链接】
            Button('📋 复制链接')
              .fontSize(14)
              .fontColor(AppColors.BG_CARD)
              .backgroundColor(AppColors.PRIMARY)
              .layoutWeight(1)
              .borderRadius(8)
              .height(44)
              .onClick(() => {
                const linkText = `【校园公告】${this.title}\n来源：高校校园助手APP\n发布时间：${this.time}\n\n${this.summary}`;
                const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, linkText);
                pasteboard.getSystemPasteboard().setData(pasteboardData);
                this.getUIContext()?.getPromptAction()?.showToast({ message: '公告链接已复制到剪贴板' });
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

  /**
   * 【3.3.1 三级分类筛选】
   */
  @Builder
  SubCategoryFilter() {
    Row({ space: 8 }) {
      ForEach(this.subCategories, (item: string) => {
        Text(item)
          .fontSize(13)
          .fontColor(item === this.subCategory ? AppColors.BG_CARD : AppColors.TEXT_TERTIARY)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(item === this.subCategory ? AppColors.PRIMARY : AppColors.DIVIDER)
          .borderRadius(16)
          .onClick(() => {
            this.subCategory = item;
          })
      })
    }
    .width('100%')
    .padding({ left: 4, right: 4 })
  }

  /**
   * 【3.3.1 图文混排】展示公告配图
   */
  @Builder
  ImageGallery() {
    Column({ space: 10 }) {
      // 封面图
      Image($r('app.media.background'))
        .width('100%')
        .height(180)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .onClick(() => {
          // 模拟图片放大查看
          this.getUIContext()?.getPromptAction()?.showToast({ message: '图片已放大查看（模拟全屏预览）' });
        })

      // 缩略图列表
      Row({ space: 8 }) {
        ForEach([$r('app.media.foreground'), $r('app.media.startIcon'), $r('app.media.logo')],
          (img: Resource, idx: number) => {
            Image(img)
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(6)
              .onClick(() => {
                this.currentImageIndex = idx;
                this.getUIContext()?.getPromptAction()?.showToast({ message: `查看第${idx + 1}张图片（模拟大图预览）` });
              })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppColors.BG_CARD)
    .borderRadius(8)
  }

  private getContentParagraphs(): string[] {
    return [
      '各位同学：',
      '',
      '根据学校教学工作安排，现将本学期的相关事宜通知如下，请各位同学认真阅读并按要求执行。',
      '',
      '一、时间安排',
      '本次工作从通知发布之日起开始执行，请各班级负责人及时传达给每位同学。具体时间节点将以学校最新通知为准。关键节点如下：',
      '',
      '二、注意事项',
      '1. 请同学们密切关注学校官网和校园助手APP的后续通知。',
      '2. 如有疑问，可联系辅导员或所在学院办公室。',
      '3. 请保持通讯畅通，以便接收重要通知。',
      '',
      '三、联系方式',
      '教务处：教学楼A101',
      '咨询电话：010-12345678',
      '',
      '特此通知。',
      '',
      '校园助手APP · 校园公告板块',
      '发布时间：' + this.time
    ];
  }
}
