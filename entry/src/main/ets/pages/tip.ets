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
    { title: '绿萝浇水指南', content: '绿萝喜欢湿润环境，春夏季每5-7天浇一次水，秋冬减少到10-15天一次。浇水要浇透，但不能积水，否则容易烂根。', icon: '🌿', tag: '浇水', color: '#18A558', bg: '#E8F7EE' },
    { title: '多肉植物浇水技巧', content: '多肉耐旱，遵循“宁干勿湿”。春秋15-20天浇一次，夏季高温约30天一次，冬季可45天以上再浇。', icon: '🪴', tag: '浇水', color: '#D97706', bg: '#FFF8E6' },
    { title: '月季浇水要点', content: '月季喜水但怕涝，土表2cm干了就要浇透。夏季勤检查，冬季减少浇水频率。', icon: '🌹', tag: '浇水', color: '#DB2777', bg: '#FCE7F3' },
    { title: '不同植物的光照需求', content: '喜光植物需要4-6小时直射光；绿萝、富贵竹适合散射光；文竹等喜阴植物避免阳光直晒。', icon: '☀️', tag: '光照', color: '#EA580C', bg: '#FFF8E6' },
    { title: '多肉光照技巧', content: '多肉需要充足光照保持紧凑株型，夏季中午适当遮阴，冬季尽量靠近南向窗台。', icon: '🪴', tag: '光照', color: '#D97706', bg: '#FFF8E6' },
    { title: '绿萝的光照管理', content: '绿萝耐阴但需要明亮散射光。光照过强会黄叶卷边，太弱会叶片变小、颜色变淡。', icon: '🌿', tag: '光照', color: '#18A558', bg: '#E8F7EE' },
    { title: '绿植施肥基础', content: '春秋生长期每月施肥1-2次，夏季高温和冬季低温暂停。记住“薄肥勤施”，避免烧根。', icon: '🌾', tag: '施肥', color: '#65A30D', bg: '#EFF8DC' },
    { title: '富贵竹施肥方法', content: '水培富贵竹每2-3周滴入少量营养液即可。刚换水或换盆后一周内不要施肥。', icon: '🎋', tag: '施肥', color: '#18A558', bg: '#E8F7EE' },
    { title: '常见病害处理', content: '白粉病用多菌灵；黑斑病剪除病叶并喷杀菌剂；根腐病要停水、修根、换土。', icon: '🐛', tag: '病虫', color: '#92400E', bg: '#FFF8E6' },
    { title: '常见虫害防治', content: '蚜虫可用肥皂水，红蜘蛛要增加湿度，介壳虫可用酒精棉签处理。保持通风是最好的预防。', icon: '🪲', tag: '病虫', color: '#92400E', bg: '#FFF8E6' },
    { title: '吊兰全方位养护', content: '吊兰喜温暖湿润、半阴环境。夏季可向叶面喷水增湿，每月施一次薄肥。', icon: '🌱', tag: '其他', color: '#0891B2', bg: '#E6F7FA' },
    { title: '龟背竹养护全攻略', content: '龟背竹喜半阴和湿润环境，夏季早晚喷水，定期擦拭叶片，保持叶面光泽。', icon: '🍃', tag: '其他', color: '#15803D', bg: '#E8F7EE' }
  ]

  aboutToAppear() {
    try {
      preferences.getPreferences(getContext(this), 'tipDB')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          try {
            const raw = pref.getSync('favoriteTips', '[]') as string
            this.favoriteTitles = JSON.parse(raw) as Array<string>
          } catch (e) {
            this.favoriteTitles = []
          }
          this.applyFilter()
        })
        .catch(() => {
          this.applyFilter()
        })
    } catch (e) {
      this.applyFilter()
    }
  }

  applyFilter() {
    const keyword = this.searchText.trim()
    const category = this.categories[this.currentTab].name
    const result: Array<TipItem> = []
    for (let i = 0; i < this.allTips.length; i++) {
      const item = this.allTips[i]
      const matchCategory = category === '全部' || item.tag === category || (category === '收藏' && this.isFavorite(item.title))
      const matchText = keyword.length === 0 || item.title.indexOf(keyword) >= 0 || item.content.indexOf(keyword) >= 0 || item.tag.indexOf(keyword) >= 0
      if (matchCategory && matchText) {
        result.push(item)
      }
    }
    this.displayTips = result
  }

  isFavorite(title: string): boolean {
    for (let i = 0; i < this.favoriteTitles.length; i++) {
      if (this.favoriteTitles[i] === title) {
        return true
      }
    }
    return false
  }

  toggleFavorite(title: string) {
    const next: Array<string> = []
    let existed = false
    for (let i = 0; i < this.favoriteTitles.length; i++) {
      if (this.favoriteTitles[i] === title) {
        existed = true
      } else {
        next.push(this.favoriteTitles[i])
      }
    }
    if (!existed) {
      next.push(title)
    }
    this.favoriteTitles = next
    try {
      this.prefDB?.putSync('favoriteTips', JSON.stringify(this.favoriteTitles))
      this.prefDB?.flush().catch(() => {})
      promptAction.showToast({ message: existed ? '已取消收藏' : '已收藏到植物百科' })
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

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('‹ 返回')
            .fontSize(15)
            .fontColor('#2FBF71')
        }
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => { try { router.back() } catch (e) {} })
        Blank()
        Text('植物百科')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
        Blank()
        Row().width(58)
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 10 }) {
            Text('Plant Wiki')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#222222')
            Text('收藏有用的养护知识，做更懂植物的 Plant Parent。')
              .fontSize(13)
              .fontColor('#8A8A8A')
              .lineHeight(20)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 20, right: 20 })

          Row() {
            Text('🔍')
              .fontSize(16)
              .margin({ left: 14, right: 8 })
            TextInput({ text: this.searchText, placeholder: '搜索浇水、光照、病虫害...' })
              .layoutWeight(1)
              .height(50)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
              .placeholderColor('#B8B8B8')
              .onChange((value: string) => {
                this.searchText = value
                this.applyFilter()
              })
            if (this.searchText.length > 0) {
              Text('×')
                .fontSize(18)
                .fontColor('#8A8A8A')
                .padding({ right: 14 })
                .onClick(() => {
                  this.searchText = ''
                  this.applyFilter()
                })
            }
          }
          .height(52)
          .width('90%')
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.categories, (cat: CategoryItem, idx: number) => {
                Row({ space: 5 }) {
                  Text(cat.icon)
                    .fontSize(14)
                  Text(cat.name)
                    .fontSize(13)
                    .fontWeight(this.currentTab === idx ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(this.currentTab === idx ? '#FFFFFF' : '#2FBF71')
                }
                .height(36)
                .padding({ left: 14, right: 14 })
                .borderRadius(30)
                .backgroundColor(this.currentTab === idx ? '#2FBF71' : '#E8F7EE')
                .onClick(() => { this.changeTab(idx) })
              })
            }
            .padding({ left: 20, right: 20 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.displayTips.length === 0) {
            Column({ space: 12 }) {
              Text(this.currentTab === 1 ? '⭐' : '🔍')
                .fontSize(64)
                .opacity(0.65)
              Text(this.currentTab === 1 ? '还没有收藏贴士' : '没有找到相关贴士')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')
              Text(this.currentTab === 1 ? '点击卡片右上角星标即可收藏。' : '换个关键词或分类试试。')
                .fontSize(13)
                .fontColor('#8A8A8A')
            }
            .width('90%')
            .padding(34)
            .borderRadius(24)
            .backgroundColor('#FFFFFF')
            .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
          } else {
            ForEach(this.displayTips, (item: TipItem, index: number) => {
              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Column() {
                    Text(item.icon)
                      .fontSize(28)
                  }
                  .width(54)
                  .height(54)
                  .borderRadius(20)
                  .backgroundColor(item.bg)
                  .justifyContent(FlexAlign.Center)

                  Column({ space: 5 }) {
                    Text(item.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#222222')
                    Text(item.tag)
                      .fontSize(11)
                      .fontColor(item.color)
                      .padding({ left: 9, right: 9, top: 3, bottom: 3 })
                      .backgroundColor(item.bg)
                      .borderRadius(16)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(this.isFavorite(item.title) ? '★' : '☆')
                    .fontSize(24)
                    .fontColor(this.isFavorite(item.title) ? '#F5B84B' : '#B8B8B8')
                    .onClick(() => { this.toggleFavorite(item.title) })
                }
                .width('100%')
                .onClick(() => { this.toggleExpand(index) })

                if (this.expandedIndex === index) {
                  Divider()
                    .color('#F0F0F0')
                  Text(item.content)
                    .fontSize(14)
                    .fontColor('#555555')
                    .lineHeight(24)
                    .width('100%')
                }
              }
              .width('90%')
              .padding(18)
              .borderRadius(24)
              .backgroundColor('#FFFFFF')
              .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
            }, (item: TipItem) => item.title)
          }

          Blank().height(24)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6FAF7')
  }
}

@Component
@Preview
struct TipPreview {
  build() {
    TipPage()
  }
}
