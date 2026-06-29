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

interface CategoryItem {
  name: string
  icon: string
}

@Entry
@Component
struct TipPage {
  @State currentTab: number = 0
  @State expandedIndex: number = -1
  @State displayTips: Array<TipItem> = []
  @State searchText: string = ''
  @State favoriteTitles: Array<string> = []
  @State pressedKey: string = ''
  @State listOpacity: number = 0
  @State favPulse: string = ''
  prefDB: preferences.Preferences | null = null

  categories: Array<CategoryItem> = [
    { name: '全部', icon: '🌿' },
    { name: '收藏', icon: '⭐' },
    { name: '浇水', icon: '💧' },
    { name: '光照', icon: '☀️' },
    { name: '施肥', icon: '🌾' },
    { name: '病虫', icon: '🐛' },
    { name: '其他', icon: '📌' }
  ]

  allTips: Array<TipItem> = [
    { title: '绿萝浇水指南', content: '绿萝喜欢湿润环境，春夏季每5-7天浇一次水，秋冬减少到10-15天一次。浇水要浇透，但不能积水，否则容易烂根。判断是否需要浇水：用手指插入土壤2-3cm处，如果干了就可以浇水。', icon: '🌿', tag: '浇水', color: '#2D5A1B', bg: '#EEF6EA' },
    { title: '多肉植物浇水技巧', content: '多肉耐旱，遵循"宁干勿湿"。春秋15-20天浇一次，夏季高温约30天一次，冬季可45天以上再浇。浇水选择晴天早晨或傍晚，避免浇到叶片上。', icon: '🪴', tag: '浇水', color: '#8A5C20', bg: '#FFF8E6' },
    { title: '月季浇水要点', content: '月季喜水但怕涝，土表2cm干了就要浇透。夏季勤检查，冬季减少浇水频率。浇水从花盆边缘浇入，不要直接冲根部，避免烂根。', icon: '🌹', tag: '浇水', color: '#8A2055', bg: '#FCE8F2' },
    { title: '不同植物的光照需求', content: '喜光植物（月季、多肉、仙人掌）每天需要4-6小时直射光；半阴植物（绿萝、富贵竹）适合散射光；喜阴植物（文竹）尽量避免阳光直晒。', icon: '☀️', tag: '光照', color: '#8A4820', bg: '#FFF8E6' },
    { title: '多肉光照技巧', content: '多肉需要充足光照保持紧凑株型，夏季中午适当遮阴，冬季尽量靠近南向窗台接受全日照。', icon: '🪴', tag: '光照', color: '#8A5C20', bg: '#FFF8E6' },
    { title: '绿萝的光照管理', content: '绿萝耐阴但需要明亮散射光。放在室内明亮散射光处最好，如客厅茶几或书桌上。光照过强叶片发黄卷边，太弱叶片变小变淡。', icon: '🌿', tag: '光照', color: '#2D5A1B', bg: '#EEF6EA' },
    { title: '绿植施肥基础', content: '春秋生长期每月施肥1-2次，夏季高温和冬季低温暂停。原则是"薄肥勤施"——浓度低，频率适当增加，避免烧根。', icon: '🌾', tag: '施肥', color: '#4A6A20', bg: '#EFF8DC' },
    { title: '富贵竹施肥方法', content: '水培富贵竹每2-3周滴入少量营养液即可。刚换水或换盆后一周内不要施肥。', icon: '🎋', tag: '施肥', color: '#2D5A1B', bg: '#EEF6EA' },
    { title: '常见病害处理', content: '白粉病用多菌灵；黑斑病剪除病叶并喷杀菌剂；根腐病要停水、修根、换土。发现后要尽早处理，防止扩散。', icon: '🐛', tag: '病虫', color: '#6A3820', bg: '#FFF0E8' },
    { title: '常见虫害防治', content: '蚜虫可用肥皂水，红蜘蛛要增加湿度，介壳虫可用酒精棉签处理。保持通风是最好的预防方法。', icon: '🪲', tag: '病虫', color: '#6A3820', bg: '#FFF0E8' },
    { title: '吊兰全方位养护', content: '吊兰喜温暖湿润、半阴环境，适宜15-25℃。夏季可向叶面喷水增湿，每月施一次薄肥，每年春季换盆一次。', icon: '🌱', tag: '其他', color: '#205A6A', bg: '#E8F4F8' },
    { title: '龟背竹养护全攻略', content: '龟背竹喜半阴和湿润环境，最适温度20-25℃。夏季早晚喷水，定期擦拭叶片保持光泽，每2-3周施一次液体肥。', icon: '🍃', tag: '其他', color: '#2D5A1B', bg: '#EEF6EA' }
  ]

  aboutToAppear() {
    try {
      preferences.getPreferences(getContext(this), 'tipDB')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          try {
            this.favoriteTitles = JSON.parse(pref.getSync('favoriteTips', '[]') as string) as Array<string>
          } catch (e) { this.favoriteTitles = [] }
          this.applyFilter()
        }).catch(() => { this.applyFilter() })
    } catch (e) { this.applyFilter() }
  }

  applyFilter() {
    this.listOpacity = 0
    const kw = this.searchText.trim()
    const cat = this.categories[this.currentTab].name
    const res: Array<TipItem> = []
    for (let i = 0; i < this.allTips.length; i++) {
      const it = this.allTips[i]
      const mc = cat === '全部' || it.tag === cat || (cat === '收藏' && this.isFav(it.title))
      const mk = kw.length === 0 || it.title.indexOf(kw) >= 0 || it.content.indexOf(kw) >= 0 || it.tag.indexOf(kw) >= 0
      if (mc && mk) res.push(it)
    }
    this.displayTips = res
    animateTo({ duration: 260, curve: Curve.EaseOut }, () => { this.listOpacity = 1 })
  }

  isFav(title: string): boolean {
    for (let i = 0; i < this.favoriteTitles.length; i++) {
      if (this.favoriteTitles[i] === title) return true
    }
    return false
  }

  toggleFav(title: string) {
    const next: Array<string> = []
    let existed = false
    for (let i = 0; i < this.favoriteTitles.length; i++) {
      if (this.favoriteTitles[i] === title) existed = true
      else next.push(this.favoriteTitles[i])
    }
    if (!existed) next.push(title)
    this.favoriteTitles = next
    this.favPulse = title
    setTimeout(() => { this.favPulse = '' }, 240)
    try {
      this.prefDB?.putSync('favoriteTips', JSON.stringify(this.favoriteTitles))
      this.prefDB?.flush().catch(() => {})
      promptAction.showToast({ message: existed ? '已取消收藏' : '已收藏到植物百科 ⭐' })
    } catch (e) {}
    this.applyFilter()
  }

  changeTab(idx: number) {
    this.currentTab = idx
    this.expandedIndex = -1
    this.applyFilter()
  }

  toggleExpand(index: number) {
    this.expandedIndex = this.expandedIndex === index ? -1 : index
  }

  pressDown(k: string) { this.pressedKey = k }
  pressUp() { this.pressedKey = '' }

  build() {
    Column() {
      // 图1风格：深绿头部
      Column() {
        Row() {
          Button({ type: ButtonType.Normal }) {
            Text('‹ 返回').fontSize(15).fontColor('#A5C87A')
          }
          .height(36).backgroundColor(Color.Transparent)
          .onClick(() => { try { router.back() } catch (e) {} })
          Blank()
          Column({ space: 1 }) {
            Text('PLANT WIKI')
              .fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('植物百科')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Text('⭐').fontSize(18)
            .onClick(() => { try { router.pushUrl({ url: 'pages/favorite' }) } catch (e) {} })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 14, bottom: 14 })

        // 图3 editorial 副标题
        Column({ space: 4 }) {
          Text('Your plants called.')
            .fontSize(22)
            .fontStyle(FontStyle.Italic)
            .fontColor('#C8E8B8')
            .letterSpacing(0.3)
          Text('They want more knowledge.')
            .fontSize(16)
            .fontStyle(FontStyle.Italic)
            .fontColor('#A5C87A')
            .letterSpacing(0.2)
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 22, right: 22, bottom: 22 })
      }
      .backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 16 }) {

          // 搜索框
          Row() {
            Text('🔍').fontSize(15).margin({ left: 14, right: 8 })
            TextInput({ text: this.searchText, placeholder: '搜索浇水、光照、病虫害...' })
              .layoutWeight(1).height(48)
              .backgroundColor(Color.Transparent)
              .fontSize(14).placeholderColor('#C0C0C0')
              .onChange((v: string) => { this.searchText = v; this.applyFilter() })
            if (this.searchText.length > 0) {
              Text('×').fontSize(18).fontColor('#AAAAAA')
                .padding({ right: 14 })
                .onClick(() => { this.searchText = ''; this.applyFilter() })
            }
          }
          .height(52).width('100%').borderRadius(20)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 10, color: '#00000008', offsetY: 4 })

          // 分类标签横向滚动
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.categories, (cat: CategoryItem, idx: number) => {
                Row({ space: 5 }) {
                  Text(cat.icon).fontSize(13)
                  Text(cat.name)
                    .fontSize(13)
                    .fontColor(this.currentTab === idx ? '#FFFFFF' : '#4A7C2F')
                    .fontWeight(this.currentTab === idx ? FontWeight.Bold : FontWeight.Normal)
                    .letterSpacing(0.3)
                }
                .height(36).padding({ left: 14, right: 14 })
                .borderRadius(24)
                .backgroundColor(this.currentTab === idx ? '#4A7C2F' : '#EEF6EA')
                .border({ width: 1, color: this.currentTab === idx ? '#4A7C2F' : '#C8D8BE', style: BorderStyle.Solid })
                .scale({ x: this.pressedKey === cat.name ? 0.92 : 1, y: this.pressedKey === cat.name ? 0.92 : 1 })
                .opacity(this.pressedKey === cat.name ? 0.7 : 1)
                .onClick(() => { this.changeTab(idx) })
                .onTouch((e: TouchEvent) => {
                  if (e.type === TouchType.Down) this.pressDown(cat.name)
                  else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.displayTips.length === 0) {
            Column({ space: 12 }) {
              Text(this.currentTab === 1 ? '⭐' : '🔍').fontSize(62).opacity(0.55)
              Text(this.currentTab === 1 ? '还没有收藏贴士' : '没有找到相关贴士')
                .fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
              Text(this.currentTab === 1 ? '点击卡片右上角星标即可收藏。' : '换个关键词或分类试试。')
                .fontSize(13).fontColor('#8A8A8A')
            }
            .width('100%').padding(32).borderRadius(28)
            .backgroundColor('#FFFDF8')
            .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
            .shadow({ radius: 14, color: '#00000010', offsetY: 5 })
            .opacity(this.listOpacity)
          } else {
            ForEach(this.displayTips, (item: TipItem, index: number) => {
              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Column() { Text(item.icon).fontSize(28) }
                    .width(52).height(52).borderRadius(18)
                    .backgroundColor(item.bg).justifyContent(FlexAlign.Center)

                  Column({ space: 5 }) {
                    Text(item.title)
                      .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
                    Row({ space: 8 }) {
                      Text(item.tag)
                        .fontSize(11).fontColor(item.color)
                        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                        .backgroundColor(item.bg).borderRadius(12)
                      Text(this.expandedIndex === index ? '收起 ▲' : '展开 ▼')
                        .fontSize(11).fontColor('#8A8A8A')
                    }
                  }
                  .alignItems(HorizontalAlign.Start).layoutWeight(1)

                  Text(this.isFav(item.title) ? '★' : '☆')
                    .fontSize(24)
                    .fontColor(this.isFav(item.title) ? '#C8A020' : '#C0C0C0')
                    .scale({
                      x: this.favPulse === item.title ? 1.28 : (this.pressedKey === `st-${index}` ? 0.85 : 1),
                      y: this.favPulse === item.title ? 1.28 : (this.pressedKey === `st-${index}` ? 0.85 : 1)
                    })
                    .onClick(() => { this.toggleFav(item.title) })
                    .onTouch((e: TouchEvent) => {
                      if (e.type === TouchType.Down) this.pressDown(`st-${index}`)
                      else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                    })
                }
                .width('100%')
                .onClick(() => { this.toggleExpand(index) })

                if (this.expandedIndex === index) {
                  Column() {
                    Divider().color('#EEE8E0').width('100%')
                    Blank().height(8)
                    Text(item.content)
                      .fontSize(14).fontColor('#3C3A35')
                      .lineHeight(24).width('100%')
                  }
                  .width('100%')
                }
              }
              .width('92%').padding(18).borderRadius(28)
              .backgroundColor('#FFFDF8')
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .shadow({ radius: 12, color: '#00000010', offsetY: 4 })
              .opacity(this.pressedKey === `tp-${index}` ? 0.74 : this.listOpacity)
              .scale({ x: this.pressedKey === `tp-${index}` ? 0.97 : 1, y: this.pressedKey === `tp-${index}` ? 0.97 : 1 })
              .onTouch((e: TouchEvent) => {
                if (e.type === TouchType.Down) this.pressDown(`tp-${index}`)
                else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
              })
            }, (item: TipItem) => item.title)
          }

          Blank().height(24)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 0, right: 0, top: 16 })
      }
      .layoutWeight(1).width('100%')
      .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }
    .width('100%').height('100%').backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct TipPreview {
  build() { TipPage() }
}
