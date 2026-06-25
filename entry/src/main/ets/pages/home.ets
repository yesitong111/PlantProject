import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

interface PlantItem {
  name: string
  type: string
  waterDays: string
  sunlight: string
  notes: string
  date: string
}

interface QuickAction {
  icon: string
  title: string
  desc: string
  url: string
  bg: string
}

interface RecommendPlant {
  icon: string
  name: string
  reason: string
  water: string
  light: string
}

interface WikiItem {
  icon: string
  title: string
  desc: string
  bg: string
}

function getTodayKey(): string {
  const now = new Date()
  return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`
}

@Entry
@Component
struct HomePage {
  @State userName: string = ''
  @State plantCount: number = 0
  @State todayChecked: boolean = false
  @State dailyReminder: string = '今天适合给绿萝检查土壤湿度，保持微润但不要积水。'
  @State recommendIndex: number = 0
  @State plantList: Array<PlantItem> = []
  @State appearScale: number = 0.96
  prefUser: preferences.Preferences | null = null
  prefPlant: preferences.Preferences | null = null

  quickActions: Array<QuickAction> = [
    { icon: '🌱', title: '我的绿植', desc: '记录成长', url: 'pages/myPlant', bg: '#E8F7EE' },
    { icon: '＋', title: '新增绿植', desc: '添加新伙伴', url: 'pages/addPlant', bg: '#FFF8E6' },
    { icon: '📖', title: '植物百科', desc: '养护知识', url: 'pages/tip', bg: '#EEF6FF' },
    { icon: '✨', title: '今日提醒', desc: '随机养护', url: 'pages/tip', bg: '#F5F0FF' }
  ]

  reminders: Array<string> = [
    '今天适合检查盆土湿度，表层干了再浇水，避免频繁少量浇水。',
    '给叶片擦一擦灰尘吧，干净叶面能更好地进行光合作用。',
    '把绿植转动一个方向，让每一面都能均匀接受散射光。',
    '观察叶背有没有小虫或黑点，早发现就能轻松处理。',
    '水培植物可以换一次清水，保持根系干净透亮。'
  ]

  recommendPlants: Array<RecommendPlant> = [
    { icon: '🌿', name: '绿萝', reason: '耐阴好养，适合宿舍和书桌。', water: '7天/次', light: '散射光' },
    { icon: '🪴', name: '多肉', reason: '小巧治愈，阳台党入门首选。', water: '15天/次', light: '充足光照' },
    { icon: '🌵', name: '仙人掌', reason: '耐旱省心，适合忙碌学生党。', water: '25天/次', light: '强光' },
    { icon: '🎋', name: '富贵竹', reason: '水培清爽，桌面氛围感很强。', water: '7天换水', light: '半阴' }
  ]

  wikiList: Array<WikiItem> = [
    { icon: '💧', title: '浇水不是越勤越好', desc: '多数植物更怕积水烂根。', bg: '#E8F7EE' },
    { icon: '☀️', title: '散射光最适合室内绿植', desc: '避开正午直晒，叶片更稳定。', bg: '#FFF8E6' }
  ]

  aboutToAppear() {
    this.refreshData()
    const idx = Math.floor(Math.random() * this.reminders.length)
    this.dailyReminder = this.reminders[idx]
    this.recommendIndex = Math.floor(Math.random() * this.recommendPlants.length)
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => {
      this.appearScale = 1
    })
  }

  onPageShow() {
    this.refreshData()
  }

  refreshData() {
    try {
      preferences.getPreferences(getContext(this), 'userData')
        .then((pref: preferences.Preferences) => {
          this.prefUser = pref
          try {
            const savedUser = pref.getSync('user', '') as string
            this.userName = savedUser
          } catch (e) {}
        })
        .catch(() => {})
    } catch (e) {}

    try {
      preferences.getPreferences(getContext(this), 'plantDB')
        .then((pref: preferences.Preferences) => {
          this.prefPlant = pref
          try {
            const raw = pref.getSync('plantList', '[]') as string
            this.plantList = JSON.parse(raw) as Array<PlantItem>
            this.plantCount = this.plantList.length
            const checkedDate = pref.getSync('todayChecked', '') as string
            this.todayChecked = checkedDate === getTodayKey()
          } catch (e) {
            this.plantList = []
            this.plantCount = 0
          }
        })
        .catch(() => {})
    } catch (e) {}
  }

  doCheckIn() {
    if (this.todayChecked) {
      try { promptAction.showToast({ message: '今天已经完成养护打卡啦 🌿' }) } catch (e) {}
      return
    }
    this.todayChecked = true
    try {
      this.prefPlant?.putSync('todayChecked', getTodayKey())
      this.prefPlant?.flush().catch(() => {})
      promptAction.showToast({ message: '今日打卡成功，坚持养护很棒！' })
    } catch (e) {}
  }

  go(url: string) {
    try { router.pushUrl({ url: url }) } catch (e) {}
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          // 欢迎 Header
          Column({ space: 18 }) {
            Row() {
              Column({ space: 6 }) {
                Text(this.userName ? `Hi, ${this.userName}` : 'Hi, Plant Parent')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('记录植物成长，让校园生活更清新')
                  .fontSize(13)
                  .fontColor('#FFFFFFCC')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Column() {
                Text(this.userName ? this.userName.charAt(0).toUpperCase() : '🌿')
                  .fontSize(20)
                  .fontColor('#2FBF71')
                  .fontWeight(FontWeight.Bold)
              }
              .width(52)
              .height(52)
              .borderRadius(999)
              .backgroundColor('#FFFFFF')
              .justifyContent(FlexAlign.Center)
              .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
              .onClick(() => { this.go('pages/login') })
            }
            .width('100%')

            // 今日天气
            Row() {
              Column({ space: 4 }) {
                Text('今日天气')
                  .fontSize(12)
                  .fontColor('#FFFFFFAA')
                Text('24℃  多云  ·  适合通风')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text('🌤️')
                .fontSize(34)
            }
            .width('100%')
            .padding(16)
            .borderRadius(24)
            .backgroundColor('#FFFFFF22')
          }
          .width('100%')
          .padding({ left: 22, right: 22, top: 24, bottom: 26 })
          .linearGradient({
            angle: 135,
            colors: [['#58D68D', 0.0], ['#2FBF71', 0.55], ['#18A558', 1.0]]
          })

          // 植物统计
          Grid() {
            GridItem() {
              this.StatCard('🌱', this.plantCount.toString(), '我的绿植')
            }
            GridItem() {
              this.StatCard('✅', this.todayChecked ? '已完成' : '未打卡', '今日打卡')
            }
            GridItem() {
              this.StatCard('📖', '12', '百科贴士')
            }
            GridItem() {
              this.StatCard('💧', '轻养护', '今日节奏')
            }
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(12)
          .columnsGap(12)
          .width('100%')
          .height(188)
          .padding({ left: 20, right: 20 })

          // 快捷功能
          Column({ space: 12 }) {
            this.SectionTitle('快捷功能', '2×2 常用入口')
            Grid() {
              ForEach(this.quickActions, (item: QuickAction) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Text(item.icon)
                      .fontSize(28)
                    Text(item.title)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#222222')
                    Text(item.desc)
                      .fontSize(11)
                      .fontColor('#8A8A8A')
                  }
                  .width('100%')
                  .height(116)
                  .borderRadius(24)
                  .backgroundColor(item.bg)
                  .justifyContent(FlexAlign.Center)
                  .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
                  .onClick(() => { this.go(item.url) })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(12)
            .columnsGap(12)
            .width('100%')
            .height(244)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 今日植物推荐
          Column({ space: 12 }) {
            this.SectionTitle('今日植物推荐', '适合校园桌面')
            Row({ space: 14 }) {
              Text(this.recommendPlants[this.recommendIndex].icon)
                .fontSize(46)
              Column({ space: 8 }) {
                Text(this.recommendPlants[this.recommendIndex].name)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#222222')
                Text(this.recommendPlants[this.recommendIndex].reason)
                  .fontSize(13)
                  .fontColor('#8A8A8A')
                  .lineHeight(20)
                Row({ space: 8 }) {
                  this.TagText(`💧 ${this.recommendPlants[this.recommendIndex].water}`)
                  this.TagText(`☀️ ${this.recommendPlants[this.recommendIndex].light}`)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(18)
            .borderRadius(24)
            .backgroundColor('#FFFFFF')
            .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 今日养护提醒
          Column({ space: 12 }) {
            Row() {
              this.SectionTitle('今日养护提醒', '随机切换')
              Blank()
              Text('换一条')
                .fontSize(12)
                .fontColor('#18A558')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#E8F7EE')
                .borderRadius(20)
                .onClick(() => {
                  const idx = Math.floor(Math.random() * this.reminders.length)
                  this.dailyReminder = this.reminders[idx]
                })
            }
            .width('100%')
            Row({ space: 12 }) {
              Text('💡')
                .fontSize(28)
              Text(this.dailyReminder)
                .fontSize(14)
                .fontColor('#5B4B22')
                .lineHeight(22)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(18)
            .borderRadius(24)
            .backgroundColor('#FFF8E6')

            Button(this.todayChecked ? '今日已打卡' : '完成今日打卡', { type: ButtonType.Normal })
              .width('100%')
              .height(52)
              .borderRadius(30)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .linearGradient({
                angle: 90,
                colors: this.todayChecked ? [['#9BE3B8', 0.0], ['#58D68D', 1.0]] : [['#58D68D', 0.0], ['#18A558', 1.0]]
              })
              .shadow({ radius: 20, color: '#2FBF7133', offsetY: 8 })
              .onClick(() => { this.doCheckIn() })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 百科推荐
          Column({ space: 12 }) {
            this.SectionTitle('植物百科推荐', '收藏你的养护知识')
            ForEach(this.wikiList, (item: WikiItem) => {
              Row({ space: 12 }) {
                Text(item.icon)
                  .fontSize(28)
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                  Text(item.desc)
                    .fontSize(12)
                    .fontColor('#8A8A8A')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text('›')
                  .fontSize(22)
                  .fontColor('#BEBEBE')
              }
              .width('100%')
              .padding(16)
              .borderRadius(24)
              .backgroundColor(item.bg)
              .onClick(() => { this.go('pages/tip') })
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 最近记录
          Column({ space: 12 }) {
            this.SectionTitle('最近记录', this.plantList.length > 0 ? '你的植物成长中' : '暂无记录')
            if (this.plantList.length === 0) {
              Column({ space: 10 }) {
                Text('🪴')
                  .fontSize(50)
                  .opacity(0.55)
                Text('还没有绿植记录')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#222222')
                Text('添加第一盆绿植，开始植物养护日记。')
                  .fontSize(12)
                  .fontColor('#8A8A8A')
              }
              .width('100%')
              .padding(24)
              .borderRadius(24)
              .backgroundColor('#FFFFFF')
              .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
            } else {
              ForEach(this.plantList.slice(0, 3), (item: PlantItem) => {
                Row({ space: 12 }) {
                  Text('🌿')
                    .fontSize(28)
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#222222')
                    Text(`${item.type} · ${item.waterDays}天/次 · ${item.date}`)
                      .fontSize(12)
                      .fontColor('#8A8A8A')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(16)
                .borderRadius(24)
                .backgroundColor('#FFFFFF')
                .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
              })
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 28 })
        }
        .width('100%')
        .scale({ x: this.appearScale, y: this.appearScale })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6FAF7')
  }

  @Builder
  SectionTitle(title: string, sub: string) {
    Column({ space: 3 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222222')
      Text(sub)
        .fontSize(12)
        .fontColor('#8A8A8A')
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TagText(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor('#18A558')
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor('#E8F7EE')
      .borderRadius(18)
  }

  @Builder
  StatCard(icon: string, value: string, label: string) {
    Column({ space: 7 }) {
      Text(icon)
        .fontSize(22)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222222')
        .maxLines(1)
      Text(label)
        .fontSize(11)
        .fontColor('#8A8A8A')
    }
    .width('100%')
    .height(88)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
  }
}

@Component
@Preview
struct HomePreview {
  build() {
    HomePage()
  }
}
