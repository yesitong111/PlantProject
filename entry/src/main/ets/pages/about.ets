import router from '@ohos.router'
import { bundleManager } from '@kit.AbilityKit'

@Entry
@Component
struct AboutPage {
  @State appVersion: string = '1.0.0'
  @State contentOpacity: number = 0
  @State swiperIndex: number = 0

  features: Array<string> = [
    '🌿 记录校园绿植成长',
    '💧 智能浇水提醒',
    '📖 12+ 条养护百科',
    '✅ 每日养护打卡',
    '⭐ 收藏常用贴士'
  ]

  team: Array<string> = [
    '成员 A — 首页 & 登录模块',
    '成员 B — 植物管理模块',
    '成员 C — 百科 & 统计模块'
  ]

  aboutToAppear() {
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    try {
      bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
        .then((info: bundleManager.BundleInfo) => {
          this.appVersion = info.versionName || '1.0.0'
        }).catch(() => {})
    } catch (e) {}
  }

  build() {
    Column() {
      Column() {
        Row() {
          Button({ type: ButtonType.Normal }) {
            Text('‹ 返回').fontSize(15).fontColor('#A5C87A')
          }.height(36).backgroundColor(Color.Transparent)
            .onClick(() => { try { router.back() } catch (e) {} })
          Blank()
          Column({ space: 1 }) {
            Text('ABOUT').fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('关于应用').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 10 }) {
            Text('🌿').fontSize(56)
            Text('校园绿植养护助手').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text('Plant Care · Campus Edition').fontSize(12).fontColor('#8A8A8A').letterSpacing(1)
            Text(`版本 ${this.appVersion}`).fontSize(11).fontColor('#BBBBBB')
          }.width('100%').padding(28).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
          .alignItems(HorizontalAlign.Center)

          Swiper() {
            ForEach(this.features, (f: string) => {
              Column() {
                Text(f).fontSize(16).fontColor('#1A1A1A').fontWeight(FontWeight.Medium)
              }.width('100%').height(80).borderRadius(20).backgroundColor('#EEF6EA')
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('100%').height(80).indicator(true)
          .autoPlay(true).interval(3000).loop(true)
          .onChange((idx: number) => { this.swiperIndex = idx })

          Column({ space: 12 }) {
            Text('应用简介').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text('一款面向校园场景的绿植养护助手，帮助同学们记录植物成长、获取养护知识、设置提醒并完成每日打卡。数据全部本地存储，保护隐私。')
              .fontSize(13).fontColor('#5A5A5A').lineHeight(22)
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 10 }) {
            Text('开发团队（3人小组）').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            ForEach(this.team, (m: string) => {
              Text(m).fontSize(13).fontColor('#5A5A5A').width('100%')
            })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 8 }) {
            Text('技术栈').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text('HarmonyOS · ArkTS · Preferences 本地存储 · Router 路由')
              .fontSize(13).fontColor('#5A5A5A')
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Text('© 2026 Campus Plant Care Team')
            .fontSize(11).fontColor('#CCCCCC').width('100%').textAlign(TextAlign.Center)

          Blank().height(24)
        }.width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct AboutPreview {
  build() { AboutPage() }
}
