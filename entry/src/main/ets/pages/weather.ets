import router from '@ohos.router'
import { DataHelper } from '../common/DataHelper'

interface SeasonTip {
  season: string
  icon: string
  tips: Array<string>
}

interface WeatherCard {
  label: string
  value: string
  icon: string
  progress: number
}

@Entry
@Component
struct WeatherPage {
  @State currentMonth: number = 1
  @State seasonName: string = '春季'
  @State seasonTips: Array<string> = []
  @State weatherCards: Array<WeatherCard> = []
  @State contentOpacity: number = 0
  @State swiperIdx: number = 0

  seasons: Array<SeasonTip> = [
    { season: '春季', icon: '🌸', tips: ['逐步增加浇水频率', '开始薄肥勤施', '注意倒春寒保护'] },
    { season: '夏季', icon: '☀️', tips: ['避开正午强光', '增加通风防虫', '多肉减少浇水'] },
    { season: '秋季', icon: '🍂', tips: ['减少施肥', '检查是否有病虫害', '准备入室过冬'] },
    { season: '冬季', icon: '❄️', tips: ['控水防冻', '保持适当光照', '远离暖气出风口'] }
  ]

  aboutToAppear() {
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    this.loadWeatherData()
  }

  loadWeatherData() {
    const now = new Date()
    this.currentMonth = now.getMonth() + 1
    if (this.currentMonth >= 3 && this.currentMonth <= 5) {
      this.seasonName = '春季'
      this.seasonTips = this.seasons[0].tips
    } else if (this.currentMonth >= 6 && this.currentMonth <= 8) {
      this.seasonName = '夏季'
      this.seasonTips = this.seasons[1].tips
    } else if (this.currentMonth >= 9 && this.currentMonth <= 11) {
      this.seasonName = '秋季'
      this.seasonTips = this.seasons[2].tips
    } else {
      this.seasonName = '冬季'
      this.seasonTips = this.seasons[3].tips
    }
    const humidity = 55 + (this.currentMonth % 5) * 8
    const temp = 18 + (this.currentMonth % 6) * 2
    this.weatherCards = [
      { label: '适宜温度', value: `${temp}℃`, icon: '🌡️', progress: temp * 3 },
      { label: '空气湿度', value: `${humidity}%`, icon: '💧', progress: humidity },
      { label: '光照指数', value: '中等', icon: '☀️', progress: 65 },
      { label: '养护指数', value: '宜养护', icon: '🌿', progress: 80 }
    ]
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
            Text('WEATHER CARE').fontSize(10).fontColor('#A5C87A').letterSpacing(2)
            Text('天气养护').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 14 }) {
          Row() {
            Column({ space: 6 }) {
              Text(`TODAY · ${this.seasonName}`).fontSize(10).fontColor('#7A7A7A').letterSpacing(1.5)
              Text('24℃  多云  ·  适合通风养护').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
              Text(`${this.currentMonth}月 · 校园植物角养护建议`).fontSize(12).fontColor('#8A8A8A')
            }.alignItems(HorizontalAlign.Start)
            Blank()
            Text('🌤️').fontSize(40)
          }.width('100%').padding(20).borderRadius(28)
          .backgroundColor('#EEEAE2CC').border({ width: 1, color: '#D8D0C4', style: BorderStyle.Solid })
          .backgroundBlurStyle(BlurStyle.Thin)

          Grid() {
            ForEach(this.weatherCards, (card: WeatherCard) => {
              GridItem() {
                Column({ space: 8 }) {
                  Text(card.icon).fontSize(22)
                  Text(card.value).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
                  Text(card.label).fontSize(11).fontColor('#8A8A8A')
                  Progress({ value: card.progress, total: 100, type: ProgressType.Linear })
                    .width('80%').height(4).borderRadius(2).color('#4A7C2F').backgroundColor('#E8E0D4')
                }.width('100%').padding(16).borderRadius(22).backgroundColor('#FFFDF8')
                .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
                .alignItems(HorizontalAlign.Center)
              }
            })
          }.columnsTemplate('1fr 1fr').rowsGap(10).columnsGap(10).width('100%')

          Swiper() {
            ForEach(this.seasons, (s: SeasonTip) => {
              Column({ space: 12 }) {
                Text(`${s.icon} ${s.season}养护`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
                ForEach(s.tips, (tip: string) => {
                  Row({ space: 8 }) {
                    Text('·').fontSize(16).fontColor('#4A7C2F')
                    Text(tip).fontSize(13).fontColor('#5A5A5A')
                  }.width('100%')
                })
              }.width('100%').padding(20).borderRadius(24).backgroundColor('#EEF6EA')
            })
          }.width('100%').height(160).indicator(true).loop(true)
          .onChange((idx: number) => { this.swiperIdx = idx })

          Column({ space: 10 }) {
            Text(`${this.seasonName}重点提醒`).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            ForEach(this.seasonTips, (tip: string, idx: number) => {
              Row({ space: 10 }) {
                Text(`${idx + 1}`).fontSize(12).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  .width(24).height(24).borderRadius(12).backgroundColor('#4A7C2F')
                  .textAlign(TextAlign.Center)
                Text(tip).fontSize(14).fontColor('#4A4A4A').layoutWeight(1)
              }.width('100%').padding(12).borderRadius(16).backgroundColor('#FAFAF8')
            })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Button('查看养护提醒', { type: ButtonType.Normal })
            .width('100%').height(46).borderRadius(24)
            .fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
            .backgroundColor('#4A7C2F')
            .onClick(() => {
              try { router.pushUrl({ url: 'pages/reminder' }) } catch (e) {}
            })

          Blank().height(24)
        }.width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct WeatherPreview {
  build() { WeatherPage() }
}
