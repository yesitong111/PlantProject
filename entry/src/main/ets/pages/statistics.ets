import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import { DataHelper } from '../common/DataHelper'
import { PlantItem, CheckInRecord, getPlantIcon } from '../common/PlantTypes'

interface TypeStat {
  type: string
  count: number
  percent: number
}

@Entry
@Component
struct StatisticsPage {
  @State plantCount: number = 0
  @State checkInCount: number = 0
  @State favCount: number = 0
  @State typeStats: Array<TypeStat> = []
  @State checkIns: Array<CheckInRecord> = []
  @State contentOpacity: number = 0
  @State currentTab: number = 0

  aboutToAppear() {
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    this.loadStats()
  }

  onPageShow() { this.loadStats() }

  loadStats() {
    DataHelper.getPref('plantDB', getContext(this)).then((pref: preferences.Preferences | null) => {
      if (!pref) return
      const list = DataHelper.loadPlants(pref)
      this.plantCount = list.length
      this.checkIns = DataHelper.loadCheckIns(pref)
      this.checkInCount = this.checkIns.length
      this.calcTypeStats(list)
    })
    DataHelper.getPref('tipDB', getContext(this)).then((pref: preferences.Preferences | null) => {
      if (!pref) return
      try {
        const favs = JSON.parse(pref.getSync('favoriteTips', '[]') as string) as Array<string>
        this.favCount = favs.length
      } catch (e) { this.favCount = 0 }
    })
  }

  calcTypeStats(list: Array<PlantItem>) {
    const map: Record<string, number> = {}
    for (let i = 0; i < list.length; i++) {
      const t = list[i].type
      map[t] = (map[t] || 0) + 1
    }
    const stats: Array<TypeStat> = []
    const keys = Object.keys(map)
    for (let i = 0; i < keys.length; i++) {
      stats.push({
        type: keys[i],
        count: map[keys[i]],
        percent: list.length > 0 ? Math.round(map[keys[i]] / list.length * 100) : 0
      })
    }
    this.typeStats = stats
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
            Text('STATISTICS').fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('养护统计').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 14 }) {
          Row({ space: 12 }) {
            this.statCard('🪴', '绿植总数', this.plantCount.toString(), '#EEF6EA')
            this.statCard('✅', '打卡天数', this.checkInCount.toString(), '#FFF8E6')
            this.statCard('⭐', '收藏贴士', this.favCount.toString(), '#FCE8F2')
          }.width('100%')

          Tabs({ barPosition: BarPosition.Start, index: this.currentTab }) {
            TabContent() {
              Column({ space: 12 }) {
                Text('植物类型分布').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1A1A1A').width('100%')
                if (this.typeStats.length === 0) {
                  Text('暂无植物数据，去添加第一盆吧。').fontSize(13).fontColor('#8A8A8A').padding(20)
                } else {
                  ForEach(this.typeStats, (s: TypeStat) => {
                    Column({ space: 6 }) {
                      Row() {
                        Text(`${getPlantIcon(s.type)} ${s.type}`).fontSize(14).fontColor('#1A1A1A')
                        Blank()
                        Text(`${s.count} 盆 · ${s.percent}%`).fontSize(12).fontColor('#8A8A8A')
                      }.width('100%')
                      Progress({ value: s.percent, total: 100, type: ProgressType.Linear })
                        .width('100%').height(8).borderRadius(4)
                        .color('#4A7C2F').backgroundColor('#E8E0D4')
                    }.width('100%').padding(14).borderRadius(18)
                    .backgroundColor('#FAFAF8')
                  })
                }
              }.width('100%').padding(16)
            }.tabBar('类型分布')

            TabContent() {
              Column({ space: 10 }) {
                Text('打卡记录').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1A1A1A').width('100%')
                if (this.checkIns.length === 0) {
                  Text('还没有打卡记录。').fontSize(13).fontColor('#8A8A8A').padding(20)
                } else {
                  ForEach(this.checkIns, (rec: CheckInRecord) => {
                    Row({ space: 10 }) {
                      Text('✓').fontSize(14).fontColor('#4A7C2F')
                        .width(28).height(28).borderRadius(14).backgroundColor('#EEF6EA')
                        .textAlign(TextAlign.Center)
                      Column({ space: 2 }) {
                        Text(rec.date).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
                        Text(rec.note || '完成养护打卡').fontSize(12).fontColor('#8A8A8A')
                      }.alignItems(HorizontalAlign.Start)
                    }.width('100%').padding(12).borderRadius(16).backgroundColor('#FAFAF8')
                  })
                }
              }.width('100%').padding(16)
            }.tabBar('打卡记录')
          }
          .width('100%').barHeight(44).barMode(BarMode.Fixed)
          .onChange((idx: number) => { this.currentTab = idx })
          .backgroundColor('#FFFDF8').borderRadius(28)
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Blank().height(24)
        }.width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }

  @Builder
  statCard(icon: string, label: string, val: string, bg: string) {
    Column({ space: 6 }) {
      Text(icon).fontSize(22)
      Text(val).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
      Text(label).fontSize(10).fontColor('#8A8A8A')
    }.layoutWeight(1).padding(14).borderRadius(22).backgroundColor(bg)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
@Preview
struct StatisticsPreview {
  build() { StatisticsPage() }
}
