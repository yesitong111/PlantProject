import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import preferences from '@ohos.data.preferences'

interface PlantItem {
  name: string
  type: string
  waterDays: string
  sunlight: string
  notes: string
  date: string
}

function getPlantIcon(plantType: string): string {
  const iconMap: Record<string, string> = {
    '多肉': '🪴',
    '绿萝': '🌿',
    '月季': '🌹',
    '富贵竹': '🎋',
    '仙人掌': '🌵',
    '吊兰': '🌱',
    '龟背竹': '🍃',
    '文竹': '🎍',
    '其他': '🌻'
  }
  return iconMap[plantType] || '🪴'
}

function getPlantLightBg(plantType: string): string {
  const colorMap: Record<string, string> = {
    '多肉': '#FFF8E6',
    '绿萝': '#E8F7EE',
    '月季': '#FCE7F3',
    '富贵竹': '#EFF8DC',
    '仙人掌': '#E0F7F2',
    '吊兰': '#E6F7FA',
    '龟背竹': '#E8F7EE',
    '文竹': '#F0F8E6',
    '其他': '#F3F4F6'
  }
  return colorMap[plantType] || '#F3F4F6'
}

@Entry
@Component
struct MyPlantPage {
  @State plantList: Array<PlantItem> = []
  @State displayList: Array<PlantItem> = []
  @State isLoading: boolean = true
  @State searchText: string = ''
  @State selectedType: string = '全部'
  @State todayChecked: boolean = false
  @State cardScale: number = 1.0
  prefDB: preferences.Preferences | null = null

  typeTabs: Array<string> = ['全部', '多肉', '绿萝', '月季', '仙人掌', '其他']
  weekDays: Array<string> = ['一', '二', '三', '四', '五', '六', '日']

  aboutToAppear() {
    this.loadPlantData()
  }

  onPageShow() {
    this.loadPlantData()
  }

  loadPlantData() {
    this.isLoading = true
    try {
      preferences.getPreferences(getContext(this), 'plantDB')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          try {
            const data = pref.getSync('plantList', '[]') as string
            this.plantList = JSON.parse(data) as Array<PlantItem>
            const checkedDate = pref.getSync('plantCheckIn', '') as string
            const now = new Date()
            this.todayChecked = checkedDate === `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`
          } catch (e) {
            this.plantList = []
          }
          this.applyFilter()
          this.isLoading = false
        })
        .catch(() => { this.isLoading = false })
    } catch (e) {
      this.isLoading = false
    }
  }

  applyFilter() {
    const keyword = this.searchText.trim()
    const result: Array<PlantItem> = []
    for (let i = 0; i < this.plantList.length; i++) {
      const item = this.plantList[i]
      const matchType = this.selectedType === '全部' || item.type === this.selectedType
      const matchText = keyword.length === 0 || item.name.indexOf(keyword) >= 0 || item.type.indexOf(keyword) >= 0 || item.notes.indexOf(keyword) >= 0
      if (matchType && matchText) {
        result.push(item)
      }
    }
    this.displayList = result
  }

  doCheckIn() {
    if (this.todayChecked) {
      try { promptAction.showToast({ message: '今天已经完成成长打卡啦' }) } catch (e) {}
      return
    }
    const now = new Date()
    this.todayChecked = true
    try {
      this.prefDB?.putSync('plantCheckIn', `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`)
      this.prefDB?.flush().catch(() => {})
      promptAction.showToast({ message: '成长打卡成功！' })
    } catch (e) {}
  }

  showDeleteConfirm(index: number) {
    const plantName = this.displayList[index].name
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除「${plantName}」吗？\n删除后数据无法恢复。`,
      primaryButton: {
        value: '删除',
        fontColor: '#F04438',
        action: () => {
          const newList: Array<PlantItem> = []
          for (let i = 0; i < this.plantList.length; i++) {
            if (this.plantList[i].name !== plantName) {
              newList.push(this.plantList[i])
            }
          }
          this.plantList = newList
          this.applyFilter()
          try {
            this.prefDB?.putSync('plantList', JSON.stringify(this.plantList))
            this.prefDB?.flush().catch(() => {})
            promptAction.showToast({ message: '已删除绿植记录' })
          } catch (e) {}
        }
      },
      secondaryButton: {
        value: '取消',
        fontColor: '#2FBF71',
        action: () => {}
      }
    })
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
        Text('我的绿植')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
        Blank()
        Button('+ 添加', { type: ButtonType.Normal })
          .height(36)
          .borderRadius(30)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#2FBF71')
          .padding({ left: 14, right: 14 })
          .onClick(() => { try { router.pushUrl({ url: 'pages/addPlant' }) } catch (e) {} })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 12, bottom: 8 })
      .backgroundColor('#F6FAF7')

      Scroll() {
        Column({ space: 18 }) {
          // 成长打卡卡片
          Column({ space: 14 }) {
            Row() {
              Column({ space: 4 }) {
                Text('成长打卡日历')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#222222')
                Text(this.todayChecked ? '今日已完成，继续保持' : '今天还没有记录养护状态')
                  .fontSize(12)
                  .fontColor('#8A8A8A')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Button(this.todayChecked ? '已打卡' : '打卡', { type: ButtonType.Normal })
                .height(38)
                .borderRadius(30)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .linearGradient({ angle: 90, colors: [['#58D68D', 0.0], ['#18A558', 1.0]] })
                .padding({ left: 18, right: 18 })
                .onClick(() => { this.doCheckIn() })
            }
            .width('100%')

            Row({ space: 8 }) {
              ForEach(this.weekDays, (day: string, index: number) => {
                Column({ space: 6 }) {
                  Text(day)
                    .fontSize(11)
                    .fontColor('#8A8A8A')
                  Text(index === 3 && this.todayChecked ? '✓' : '•')
                    .fontSize(index === 3 && this.todayChecked ? 18 : 16)
                    .fontColor(index === 3 && this.todayChecked ? '#FFFFFF' : '#2FBF71')
                }
                .layoutWeight(1)
                .height(58)
                .borderRadius(18)
                .backgroundColor(index === 3 && this.todayChecked ? '#2FBF71' : '#E8F7EE')
                .justifyContent(FlexAlign.Center)
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 搜索框
          Row() {
            Text('🔍')
              .fontSize(16)
              .margin({ left: 14, right: 8 })
            TextInput({ text: this.searchText, placeholder: '搜索植物名称、类型或备注' })
              .layoutWeight(1)
              .height(48)
              .backgroundColor(Color.Transparent)
              .fontSize(14)
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
          .width('100%')
          .height(52)
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 分类筛选
          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.typeTabs, (typeName: string) => {
                Text(typeName)
                  .fontSize(13)
                  .fontColor(this.selectedType === typeName ? '#FFFFFF' : '#2FBF71')
                  .fontWeight(this.selectedType === typeName ? FontWeight.Bold : FontWeight.Normal)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .borderRadius(30)
                  .backgroundColor(this.selectedType === typeName ? '#2FBF71' : '#E8F7EE')
                  .onClick(() => {
                    this.selectedType = typeName
                    this.applyFilter()
                  })
              })
            }
          }
          .width('100%')
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

          if (this.isLoading) {
            Column({ space: 12 }) {
              LoadingProgress()
                .width(42)
                .height(42)
                .color('#2FBF71')
              Text('正在加载绿植记录')
                .fontSize(13)
                .fontColor('#8A8A8A')
            }
            .width('100%')
            .padding(40)
          } else if (this.displayList.length === 0) {
            Column({ space: 12 }) {
              Text('🪴')
                .fontSize(72)
                .opacity(0.7)
              Text(this.plantList.length === 0 ? '还没有绿植记录' : '没有找到匹配的绿植')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')
              Text(this.plantList.length === 0 ? '添加第一盆植物，建立你的校园植物角。' : '换个关键词或分类试试。')
                .fontSize(13)
                .fontColor('#8A8A8A')
              Button('添加绿植', { type: ButtonType.Normal })
                .height(50)
                .borderRadius(30)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .linearGradient({ angle: 90, colors: [['#58D68D', 0.0], ['#18A558', 1.0]] })
                .padding({ left: 28, right: 28 })
                .onClick(() => { try { router.pushUrl({ url: 'pages/addPlant' }) } catch (e) {} })
            }
            .width('100%')
            .padding(30)
            .borderRadius(24)
            .backgroundColor('#FFFFFF')
            .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
          } else {
            ForEach(this.displayList, (item: PlantItem, index: number) => {
              Row({ space: 14 }) {
                Column() {
                  Text(getPlantIcon(item.type))
                    .fontSize(34)
                }
                .width(66)
                .height(66)
                .borderRadius(24)
                .backgroundColor(getPlantLightBg(item.type))
                .justifyContent(FlexAlign.Center)

                Column({ space: 6 }) {
                  Text(item.name)
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                  Row({ space: 8 }) {
                    Text(item.type)
                      .fontSize(11)
                      .fontColor('#18A558')
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                      .backgroundColor('#E8F7EE')
                      .borderRadius(14)
                    Text(`💧 ${item.waterDays}天/次`)
                      .fontSize(11)
                      .fontColor('#8A8A8A')
                  }
                  Text(`${item.sunlight} · ${item.date}`)
                    .fontSize(12)
                    .fontColor('#8A8A8A')
                    .maxLines(1)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('删除')
                  .fontSize(12)
                  .fontColor('#F04438')
                  .padding({ left: 10, right: 10, top: 7, bottom: 7 })
                  .backgroundColor('#FFF1F0')
                  .borderRadius(18)
                  .onClick(() => { this.showDeleteConfirm(index) })
              }
              .width('100%')
              .padding(16)
              .borderRadius(24)
              .backgroundColor('#FFFFFF')
              .shadow({ radius: 20, color: '#00000014', offsetY: 8 })
              .scale({ x: this.cardScale, y: this.cardScale })
            })
          }

          Blank().height(24)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8 })
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
struct MyPlantPreview {
  build() {
    MyPlantPage()
  }
}
