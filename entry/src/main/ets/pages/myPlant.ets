import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import preferences from '@ohos.data.preferences'
import { DataHelper } from '../common/DataHelper'
import { getTodayKey } from '../common/PlantTypes'

interface PlantItem {
  name: string
  type: string
  waterDays: string
  sunlight: string
  notes: string
  date: string
}

function getPlantIcon(t: string): string {
  const m: Record<string, string> = {
    '多肉': '🪴', '绿萝': '🌿', '月季': '🌹', '富贵竹': '🎋',
    '仙人掌': '🌵', '吊兰': '🌱', '龟背竹': '🍃', '文竹': '🎍', '其他': '🌻'
  }
  return m[t] || '🪴'
}

function getPlantBg(t: string): string {
  const m: Record<string, string> = {
    '多肉': '#FFF8E6', '绿萝': '#EEF6EA', '月季': '#FCE8F2',
    '富贵竹': '#EFF8DC', '仙人掌': '#E6F4F0', '吊兰': '#E8F4F8',
    '龟背竹': '#EEF6EA', '文竹': '#F2F8E8', '其他': '#F4F4F4'
  }
  return m[t] || '#F4F4F4'
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
  @State contentOpacity: number = 0
  @State pressedKey: string = ''
  @State refreshAngle: number = 0
  prefDB: preferences.Preferences | null = null

  typeTabs: Array<string> = ['全部', '多肉', '绿萝', '月季', '仙人掌', '其他']
  weekDays: Array<string> = ['一', '二', '三', '四', '五', '六', '日']

  aboutToAppear() { this.loadData() }
  onPageShow() { this.loadData() }

  loadData() {
    this.isLoading = true
    this.contentOpacity = 0
    try {
      preferences.getPreferences(getContext(this), 'plantDB')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          try {
            this.plantList = JSON.parse(pref.getSync('plantList', '[]') as string) as Array<PlantItem>
            const key = getTodayKey()
            const ck = pref.getSync('plantCheckIn', '') as string
            const tc = pref.getSync('todayChecked', '') as string
            this.todayChecked = ck === key || tc === key
          } catch (e) { this.plantList = [] }
          this.applyFilter()
          this.isLoading = false
          animateTo({ duration: 280, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
        }).catch(() => { this.isLoading = false })
    } catch (e) { this.isLoading = false }
  }

  applyFilter() {
    const kw = this.searchText.trim()
    const res: Array<PlantItem> = []
    for (let i = 0; i < this.plantList.length; i++) {
      const it = this.plantList[i]
      const mt = this.selectedType === '全部' || it.type === this.selectedType
      const mk = kw.length === 0 || it.name.indexOf(kw) >= 0 || it.type.indexOf(kw) >= 0 || it.notes.indexOf(kw) >= 0
      if (mt && mk) res.push(it)
    }
    this.displayList = res
  }

  doCheckIn() {
    if (this.todayChecked) {
      try { promptAction.showToast({ message: '今天已经完成成长打卡啦' }) } catch (e) {}
      return
    }
    const key = getTodayKey()
    this.todayChecked = true
    try {
      if (this.prefDB) {
        DataHelper.addCheckIn(this.prefDB, key, '我的绿植页完成成长打卡')
      }
      promptAction.showToast({ message: '成长打卡成功！' })
    } catch (e) {}
  }

  refreshNow() {
    animateTo({ duration: 440, curve: Curve.EaseOut }, () => { this.refreshAngle += 360 })
    this.loadData()
  }

  pressDown(k: string) { this.pressedKey = k }
  pressUp() { this.pressedKey = '' }

  showDeleteConfirm(index: number) {
    const name = this.displayList[index].name
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除「${name}」吗？\n删除后数据无法恢复。`,
      primaryButton: {
        value: '删除', fontColor: '#E03030',
        action: () => {
          const nl: Array<PlantItem> = []
          for (let i = 0; i < this.plantList.length; i++) {
            if (this.plantList[i].name !== name) nl.push(this.plantList[i])
          }
          this.plantList = nl
          this.applyFilter()
          try {
            this.prefDB?.putSync('plantList', JSON.stringify(this.plantList))
            this.prefDB?.flush().catch(() => {})
            promptAction.showToast({ message: '已删除绿植记录' })
          } catch (e) {}
        }
      },
      secondaryButton: { value: '取消', fontColor: '#4A7C2F', action: () => {} }
    })
  }

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
            Text('MY PLANTS')
              .fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('我的绿植')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }

          Blank()

          Button('+ 添加', { type: ButtonType.Normal })
            .height(34).borderRadius(20).fontSize(12)
            .fontColor('#2D5A1B').backgroundColor('#C8E8B8')
            .padding({ left: 14, right: 14 })
            .onClick(() => { try { router.pushUrl({ url: 'pages/addPlant' }) } catch (e) {} })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 14, bottom: 18 })
      }
      .backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 16 }) {

          // 成长打卡卡片
          Column({ space: 14 }) {
            Row() {
              Column({ space: 3 }) {
                Text('GROWTH CHECK-IN')
                  .fontSize(10).fontColor('#8A8A8A').letterSpacing(2)
                Text('成长打卡日历')
                  .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
                Text(this.todayChecked ? '今日已完成，继续保持' : '今天还没有记录养护状态')
                  .fontSize(12).fontColor(this.todayChecked ? '#4A7C2F' : '#C0832A')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Button(this.todayChecked ? '已打卡' : '打卡', { type: ButtonType.Normal })
                .height(36).borderRadius(20).fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor(this.todayChecked ? '#8AB875' : '#4A7C2F')
                .padding({ left: 16, right: 16 })
                .scale({ x: this.pressedKey === 'ci' ? 0.93 : 1, y: this.pressedKey === 'ci' ? 0.93 : 1 })
                .onClick(() => { this.doCheckIn() })
                .onTouch((e: TouchEvent) => {
                  if (e.type === TouchType.Down) this.pressDown('ci')
                  else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                })
            }
            .width('100%')

            Row({ space: 6 }) {
              ForEach(this.weekDays, (day: string, idx: number) => {
                Column({ space: 5 }) {
                  Text(day).fontSize(10).fontColor('#8A8A8A')
                  Text(idx === 3 && this.todayChecked ? '✓' : '·')
                    .fontSize(idx === 3 && this.todayChecked ? 16 : 18)
                    .fontColor(idx === 3 && this.todayChecked ? '#FFFFFF' : '#4A7C2F')
                }
                .layoutWeight(1).height(54).borderRadius(16)
                .backgroundColor(idx === 3 && this.todayChecked ? '#4A7C2F' : '#EEF6EA')
                .justifyContent(FlexAlign.Center)
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })
          .opacity(this.contentOpacity)

          // 刷新行
          Row() {
            Column({ space: 2 }) {
              Text('PLANT RECORDS')
                .fontSize(10).fontColor('#8A8A8A').letterSpacing(2)
              Text('植物记录')
                .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Row({ space: 6 }) {
              Text('↻')
                .fontSize(16).fontColor('#4A7C2F')
                .rotate({ angle: this.refreshAngle })
              Text('刷新').fontSize(13).fontColor('#4A7C2F')
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(24).backgroundColor('#EEF6EA')
            .scale({ x: this.pressedKey === 'rf' ? 0.93 : 1, y: this.pressedKey === 'rf' ? 0.93 : 1 })
            .onClick(() => { this.refreshNow() })
            .onTouch((e: TouchEvent) => {
              if (e.type === TouchType.Down) this.pressDown('rf')
              else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
            })
          }
          .width('100%')
          .opacity(this.contentOpacity)

          // 搜索框
          Row() {
            Text('🔍').fontSize(15).margin({ left: 14, right: 8 })
            TextInput({ text: this.searchText, placeholder: '搜索植物名称、类型或备注' })
              .layoutWeight(1).height(46)
              .backgroundColor(Color.Transparent)
              .fontSize(14).placeholderColor('#C0C0C0')
              .onChange((v: string) => { this.searchText = v; this.applyFilter() })
            if (this.searchText.length > 0) {
              Text('×').fontSize(18).fontColor('#AAAAAA')
                .padding({ right: 14 })
                .onClick(() => { this.searchText = ''; this.applyFilter() })
            }
          }
          .width('100%').height(52).borderRadius(20)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 10, color: '#00000008', offsetY: 4 })
          .opacity(this.contentOpacity)

          // 分类筛选
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.typeTabs, (t: string) => {
                Text(t)
                  .fontSize(13)
                  .fontColor(this.selectedType === t ? '#FFFFFF' : '#4A7C2F')
                  .fontWeight(this.selectedType === t ? FontWeight.Bold : FontWeight.Normal)
                  .letterSpacing(0.5)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .borderRadius(24)
                  .backgroundColor(this.selectedType === t ? '#4A7C2F' : '#EEF6EA')
                  .scale({ x: this.pressedKey === `tab-${t}` ? 0.93 : 1, y: this.pressedKey === `tab-${t}` ? 0.93 : 1 })
                  .onClick(() => { this.selectedType = t; this.applyFilter() })
                  .onTouch((e: TouchEvent) => {
                    if (e.type === TouchType.Down) this.pressDown(`tab-${t}`)
                    else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                  })
              })
            }
          }
          .width('100%')
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .opacity(this.contentOpacity)

          // 内容区
          if (this.isLoading) {
            Column({ space: 12 }) {
              this.SkeletonCard()
              this.SkeletonCard()
              this.SkeletonCard()
            }
            .width('100%').opacity(0.8)
          } else if (this.displayList.length === 0) {
            Column({ space: 12 }) {
              Text('🪴').fontSize(68).opacity(0.5)
              Text(this.plantList.length === 0 ? '还没有绿植记录' : '没有匹配的绿植')
                .fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
              Text(this.plantList.length === 0 ? '添加第一盆植物，建立你的校园植物角。' : '换个关键词或分类试试。')
                .fontSize(13).fontColor('#8A8A8A').textAlign(TextAlign.Center).lineHeight(20)
              Button('添加绿植', { type: ButtonType.Normal })
                .height(48).borderRadius(28).fontSize(14).fontColor('#FFFFFF')
                .backgroundColor('#4A7C2F').padding({ left: 28, right: 28 })
                .onClick(() => { try { router.pushUrl({ url: 'pages/addPlant' }) } catch (e) {} })
            }
            .width('100%').padding(28).borderRadius(28)
            .backgroundColor('#FFFDF8')
            .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
            .shadow({ radius: 14, color: '#00000010', offsetY: 5 })
            .opacity(this.contentOpacity)
          } else {
            ForEach(this.displayList, (item: PlantItem, index: number) => {
              Row({ space: 14 }) {
                Column() { Text(getPlantIcon(item.type)).fontSize(32) }
                  .width(64).height(64).borderRadius(22)
                  .backgroundColor(getPlantBg(item.type))
                  .justifyContent(FlexAlign.Center)

                Column({ space: 6 }) {
                  Text(item.name)
                    .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
                  Row({ space: 8 }) {
                    Text(item.type)
                      .fontSize(11).fontColor('#4A7C2F')
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                      .backgroundColor('#D8F0D0').borderRadius(12)
                    Text(`💧 ${item.waterDays}天/次`)
                      .fontSize(11).fontColor('#8A8A8A')
                  }
                  Text(`${item.sunlight} · ${item.date}`)
                    .fontSize(11).fontColor('#AAAAAA').maxLines(1)
                  if (item.notes && item.notes.length > 0) {
                    Text(item.notes)
                      .fontSize(11).fontColor('#BBBBBB').maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('删除')
                  .fontSize(11).fontColor('#E03030')
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor('#FCEAEA').borderRadius(16)
                  .scale({ x: this.pressedKey === `del-${index}` ? 0.88 : 1, y: this.pressedKey === `del-${index}` ? 0.88 : 1 })
                  .onClick(() => { this.showDeleteConfirm(index) })
                  .onTouch((e: TouchEvent) => {
                    if (e.type === TouchType.Down) this.pressDown(`del-${index}`)
                    else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                  })
              }
              .width('100%').padding(16).borderRadius(24)
              .backgroundColor('#FFFDF8')
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .shadow({ radius: 12, color: '#00000010', offsetY: 4 })
              .scale({ x: this.pressedKey === `pl-${index}` ? 0.97 : 1, y: this.pressedKey === `pl-${index}` ? 0.97 : 1 })
              .opacity(this.pressedKey === `pl-${index}` ? 0.76 : this.contentOpacity)
              .onClick(() => {
                try {
                  router.pushUrl({ url: 'pages/plantDetail', params: { name: item.name } })
                } catch (e) {}
              })
              .onTouch((e: TouchEvent) => {
                if (e.type === TouchType.Down) this.pressDown(`pl-${index}`)
                else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
              })
            })
          }

          Blank().height(24)
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 16 })
      }
      .layoutWeight(1).width('100%')
      .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }
    .width('100%').height('100%').backgroundColor('#F7F4EF')
  }

  @Builder
  SkeletonCard() {
    Row({ space: 14 }) {
      Column().width(64).height(64).borderRadius(22).backgroundColor('#EEF6EA')
      Column({ space: 10 }) {
        Row().width('68%').height(14).borderRadius(7).backgroundColor('#EEEBE4')
        Row().width('50%').height(11).borderRadius(6).backgroundColor('#F3EFE8')
        Row().width('80%').height(11).borderRadius(6).backgroundColor('#F3EFE8')
      }
      .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding(16).borderRadius(24)
    .backgroundColor('#FFFDF8').shadow({ radius: 12, color: '#00000008', offsetY: 4 })
  }
}

@Component
@Preview
struct MyPlantPreview {
  build() { MyPlantPage() }
}
