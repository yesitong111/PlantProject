import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import preferences from '@ohos.data.preferences'
import { DataHelper } from '../common/DataHelper'
import { PlantItem, getPlantIcon, getPlantBg } from '../common/PlantTypes'

@Entry
@Component
struct PlantDetailPage {
  @State plant: PlantItem | null = null
  @State contentOpacity: number = 0
  @State pressedKey: string = ''
  plantName: string = ''

  aboutToAppear() {
    try {
      const params = router.getParams() as Record<string, string>
      this.plantName = params['name'] || ''
    } catch (e) { this.plantName = '' }
    this.loadPlant()
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
  }

  loadPlant() {
    DataHelper.getPref('plantDB', getContext(this)).then((pref: preferences.Preferences | null) => {
      if (!pref) return
      const list = DataHelper.loadPlants(pref)
      for (let i = 0; i < list.length; i++) {
        if (list[i].name === this.plantName) {
          this.plant = list[i]
          break
        }
      }
    })
  }

  goEdit() {
    if (!this.plant) return
    try {
      router.pushUrl({ url: 'pages/editPlant', params: { name: this.plant.name } })
    } catch (e) {}
  }

  showDelete() {
    if (!this.plant) return
    const name = this.plant.name
    AlertDialog.show({
      title: '确认删除',
      message: `确定删除「${name}」吗？`,
      primaryButton: {
        value: '删除', fontColor: '#E03030',
        action: () => {
          DataHelper.getPref('plantDB', getContext(this)).then((pref: preferences.Preferences | null) => {
            if (!pref) return
            const list = DataHelper.loadPlants(pref)
            const nl: Array<PlantItem> = []
            for (let i = 0; i < list.length; i++) {
              if (list[i].name !== name) nl.push(list[i])
            }
            DataHelper.savePlants(pref, nl)
            try { promptAction.showToast({ message: '已删除' }) } catch (e) {}
            try { router.back() } catch (e) {}
          })
        }
      },
      secondaryButton: { value: '取消', fontColor: '#4A7C2F', action: () => {} }
    })
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
            Text('PLANT DETAIL').fontSize(10).fontColor('#A5C87A').letterSpacing(2)
            Text('植物详情').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Button('编辑', { type: ButtonType.Normal })
            .height(32).borderRadius(16).fontSize(12).fontColor('#2D5A1B').backgroundColor('#FFFFFFCC')
            .onClick(() => { this.goEdit() })
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      if (this.plant === null) {
        Column({ space: 12 }) {
          Text('🪴').fontSize(56).opacity(0.5)
          Text('未找到该植物记录').fontSize(15).fontColor('#8A8A8A')
          Button('返回列表', { type: ButtonType.Normal })
            .height(40).borderRadius(20).fontSize(13).fontColor('#FFFFFF').backgroundColor('#4A7C2F')
            .onClick(() => { try { router.back() } catch (e) {} })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 14 }) {
              Column() {
                Text(getPlantIcon(this.plant!.type)).fontSize(56)
              }.width(100).height(100).borderRadius(30)
              .backgroundColor(getPlantBg(this.plant!.type))
              .justifyContent(FlexAlign.Center)

              Text(this.plant!.name).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
              Text(this.plant!.type).fontSize(13).fontColor('#4A7C2F')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .borderRadius(12).backgroundColor('#EEF6EA')
            }.width('100%').padding(24).borderRadius(28).backgroundColor('#FFFDF8')
            .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

            this.infoRow('💧 浇水频率', `${this.plant!.waterDays} 天/次`)
            this.infoRow('☀️ 光照需求', this.plant!.sunlight)
            this.infoRow('📅 添加日期', this.plant!.date)

            if (this.plant!.notes.length > 0) {
              Column({ space: 8 }) {
                Text('📝 备注').fontSize(13).fontColor('#6D6A62').fontWeight(FontWeight.Medium)
                Text(this.plant!.notes).fontSize(14).fontColor('#4A4A4A').lineHeight(22)
              }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
            }

            Row({ space: 12 }) {
              Button('编辑信息', { type: ButtonType.Normal })
                .layoutWeight(1).height(46).borderRadius(24)
                .fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                .backgroundColor('#4A7C2F')
                .scale({ x: this.pressedKey === 'edit' ? 0.95 : 1, y: this.pressedKey === 'edit' ? 0.95 : 1 })
                .onClick(() => { this.goEdit() })
                .onTouch((e: TouchEvent) => {
                  if (e.type === TouchType.Down) this.pressedKey = 'edit'
                  else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressedKey = ''
                })
              Button('删除', { type: ButtonType.Normal })
                .layoutWeight(1).height(46).borderRadius(24)
                .fontSize(14).fontColor('#E03030')
                .backgroundColor('#FFF0F0')
                .border({ width: 1, color: '#F5D0D0', style: BorderStyle.Solid })
                .onClick(() => { this.showDelete() })
            }.width('100%')

            Blank().height(24)
          }.width('92%').opacity(this.contentOpacity)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }

  @Builder
  infoRow(label: string, val: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#6D6A62')
      Blank()
      Text(val).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
    }.width('100%').padding(18).borderRadius(22)
    .backgroundColor('#FFFDF8')
    .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
  }
}

@Component
@Preview
struct PlantDetailPreview {
  build() { PlantDetailPage() }
}
