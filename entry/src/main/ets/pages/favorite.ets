import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

interface TipItem {
  title: string
  content: string
  icon: string
  tag: string
  color: string
  bg: string
}

@Entry
@Component
struct FavoritePage {
  @State favTips: Array<TipItem> = []
  @State listOpacity: number = 0
  @State expandedIndex: number = -1
  @State pressedKey: string = ''
  prefDB: preferences.Preferences | null = null

  allTips: Array<TipItem> = [
    { title: '绿萝浇水指南', content: '绿萝喜欢湿润环境，春夏季每5-7天浇一次水，秋冬减少到10-15天一次。', icon: '🌿', tag: '浇水', color: '#2D5A1B', bg: '#EEF6EA' },
    { title: '多肉植物浇水技巧', content: '多肉耐旱，遵循"宁干勿湿"。春秋15-20天浇一次。', icon: '🪴', tag: '浇水', color: '#8A5C20', bg: '#FFF8E6' },
    { title: '月季浇水要点', content: '月季喜水但怕涝，土表2cm干了就要浇透。', icon: '🌹', tag: '浇水', color: '#8A2055', bg: '#FCE8F2' },
    { title: '不同植物的光照需求', content: '喜光植物每天需要4-6小时直射光；半阴植物适合散射光。', icon: '☀️', tag: '光照', color: '#8A4820', bg: '#FFF8E6' },
    { title: '多肉光照技巧', content: '多肉需要充足光照保持紧凑株型，夏季中午适当遮阴。', icon: '🪴', tag: '光照', color: '#8A5C20', bg: '#FFF8E6' },
    { title: '绿萝的光照管理', content: '绿萝耐阴但需要明亮散射光，放在室内明亮处最好。', icon: '🌿', tag: '光照', color: '#2D5A1B', bg: '#EEF6EA' },
    { title: '绿植施肥基础', content: '春秋生长期每月施肥1-2次，原则是"薄肥勤施"。', icon: '🌾', tag: '施肥', color: '#4A6A20', bg: '#EFF8DC' },
    { title: '富贵竹施肥方法', content: '水培富贵竹每2-3周滴入少量营养液即可。', icon: '🎋', tag: '施肥', color: '#2D5A1B', bg: '#EEF6EA' },
    { title: '常见病害处理', content: '白粉病用多菌灵；黑斑病剪除病叶并喷杀菌剂。', icon: '🐛', tag: '病虫', color: '#6A3820', bg: '#FFF0E8' },
    { title: '常见虫害防治', content: '蚜虫可用肥皂水，红蜘蛛要增加湿度。', icon: '🪲', tag: '病虫', color: '#6A3820', bg: '#FFF0E8' },
    { title: '吊兰全方位养护', content: '吊兰喜温暖湿润、半阴环境，适宜15-25℃。', icon: '🌱', tag: '其他', color: '#205A6A', bg: '#E8F4F8' },
    { title: '龟背竹养护全攻略', content: '龟背竹喜半阴和湿润环境，最适温度20-25℃。', icon: '🍃', tag: '其他', color: '#2D5A1B', bg: '#EEF6EA' }
  ]

  aboutToAppear() { this.loadFavorites() }
  onPageShow() { this.loadFavorites() }

  loadFavorites() {
    this.listOpacity = 0
    try {
      preferences.getPreferences(getContext(this), 'tipDB')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          let titles: Array<string> = []
          try {
            titles = JSON.parse(pref.getSync('favoriteTips', '[]') as string) as Array<string>
          } catch (e) {}
          const res: Array<TipItem> = []
          for (let i = 0; i < this.allTips.length; i++) {
            for (let j = 0; j < titles.length; j++) {
              if (this.allTips[i].title === titles[j]) {
                res.push(this.allTips[i])
                break
              }
            }
          }
          this.favTips = res
          animateTo({ duration: 300, curve: Curve.EaseOut }, () => { this.listOpacity = 1 })
        }).catch(() => { this.listOpacity = 1 })
    } catch (e) { this.listOpacity = 1 }
  }

  removeFav(title: string) {
    let titles: Array<string> = []
    try {
      titles = JSON.parse(this.prefDB?.getSync('favoriteTips', '[]') as string || '[]') as Array<string>
    } catch (e) {}
    const nl: Array<string> = []
    for (let i = 0; i < titles.length; i++) {
      if (titles[i] !== title) nl.push(titles[i])
    }
    try {
      this.prefDB?.putSync('favoriteTips', JSON.stringify(nl))
      this.prefDB?.flush().catch(() => {})
    } catch (e) {}
    this.loadFavorites()
    try { promptAction.showToast({ message: '已取消收藏' }) } catch (e) {}
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
            Text('FAVORITES').fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('收藏贴士').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Text('百科').fontSize(13).fontColor('#A5C87A')
            .onClick(() => { try { router.pushUrl({ url: 'pages/tip' }) } catch (e) {} })
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      if (this.favTips.length === 0) {
        Column({ space: 12 }) {
          Text('⭐').fontSize(62).opacity(0.5)
          Text('还没有收藏贴士').fontSize(15).fontColor('#8A8A8A')
          Text('在植物百科页面点击星标即可收藏。').fontSize(13).fontColor('#BBBBBB')
          Button('去百科看看', { type: ButtonType.Normal })
            .height(42).borderRadius(21).fontSize(14).fontColor('#FFFFFF').backgroundColor('#4A7C2F')
            .onClick(() => { try { router.pushUrl({ url: 'pages/tip' }) } catch (e) {} })
        }.layoutWeight(1).justifyContent(FlexAlign.Center).opacity(this.listOpacity)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Text(`共收藏 ${this.favTips.length} 条`).fontSize(12).fontColor('#8A8A8A').width('100%')
            ForEach(this.favTips, (item: TipItem, index: number) => {
              Column({ space: 10 }) {
                Row({ space: 12 }) {
                  Column() { Text(item.icon).fontSize(26) }
                    .width(52).height(52).borderRadius(16).backgroundColor(item.bg).justifyContent(FlexAlign.Center)
                  Column({ space: 4 }) {
                    Text(item.title).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
                    Text(item.tag).fontSize(11).fontColor(item.color)
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .borderRadius(8).backgroundColor(item.bg)
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                  Text('★').fontSize(22).fontColor('#C0832A')
                    .onClick(() => { this.removeFav(item.title) })
                }.width('100%')
                if (this.expandedIndex === index) {
                  Divider().color('#EEE8E0')
                  Text(item.content).fontSize(13).fontColor('#5A5A5A').lineHeight(22)
                }
                Text(this.expandedIndex === index ? '收起 ▲' : '展开 ▼')
                  .fontSize(12).fontColor('#4A7C2F').width('100%').textAlign(TextAlign.End)
              }.width('100%').padding(16).borderRadius(24)
              .backgroundColor('#FFFDF8')
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .opacity(this.listOpacity)
              .scale({ x: this.pressedKey === item.title ? 0.98 : 1, y: this.pressedKey === item.title ? 0.98 : 1 })
              .onClick(() => { this.expandedIndex = this.expandedIndex === index ? -1 : index })
              .onTouch((e: TouchEvent) => {
                if (e.type === TouchType.Down) this.pressedKey = item.title
                else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressedKey = ''
              })
            })
            Blank().height(24)
          }.width('92%')
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct FavoritePreview {
  build() { FavoritePage() }
}
