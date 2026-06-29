import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'
import { DataHelper } from '../common/DataHelper'
import { PlantItem } from '../common/PlantTypes'

interface TypeOption {
  label: string
  icon: string
  bg: string
}

@Entry
@Component
struct EditPlantPage {
  @State plantName: string = ''
  @State plantType: string = '多肉'
  @State waterDays: number = 7
  @State sunlight: string = '散射光'
  @State notes: string = ''
  @State isSaving: boolean = false
  @State contentOpacity: number = 0
  originalName: string = ''
  prefDB: preferences.Preferences | null = null

  typeOptions: Array<TypeOption> = [
    { label: '多肉', icon: '🪴', bg: '#FFF8E6' },
    { label: '绿萝', icon: '🌿', bg: '#EEF6EA' },
    { label: '月季', icon: '🌹', bg: '#FCE8F2' },
    { label: '富贵竹', icon: '🎋', bg: '#EFF8DC' },
    { label: '仙人掌', icon: '🌵', bg: '#E6F4F0' },
    { label: '吊兰', icon: '🌱', bg: '#E8F4F8' },
    { label: '龟背竹', icon: '🍃', bg: '#EEF6EA' },
    { label: '文竹', icon: '🎍', bg: '#F2F8E8' },
    { label: '其他', icon: '🌻', bg: '#F4F4F0' }
  ]
  sunlightOptions: Array<string> = ['充足光照', '散射光', '半阴环境']
  sunlightIcons: Array<string> = ['☀️', '🌤️', '🌥️']

  aboutToAppear() {
    try {
      const params = router.getParams() as Record<string, string>
      this.originalName = params['name'] || ''
    } catch (e) {}
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    DataHelper.getPref('plantDB', getContext(this)).then((pref: preferences.Preferences | null) => {
      this.prefDB = pref
      if (!pref) return
      const list = DataHelper.loadPlants(pref)
      for (let i = 0; i < list.length; i++) {
        if (list[i].name === this.originalName) {
          this.plantName = list[i].name
          this.plantType = list[i].type
          this.waterDays = parseInt(list[i].waterDays) || 7
          this.sunlight = list[i].sunlight
          this.notes = list[i].notes
          break
        }
      }
    })
  }

  saveEdit() {
    if (this.plantName.trim() === '') {
      try { promptAction.showToast({ message: '名称不能为空' }) } catch (e) {}
      return
    }
    this.isSaving = true
    if (!this.prefDB) {
      this.isSaving = false
      return
    }
    const list = DataHelper.loadPlants(this.prefDB)
    let oldDate = ''
    for (let i = 0; i < list.length; i++) {
      if (list[i].name === this.originalName) {
        oldDate = list[i].date
        list[i] = {
          name: this.plantName.trim(),
          type: this.plantType,
          waterDays: this.waterDays.toString(),
          sunlight: this.sunlight,
          notes: this.notes.trim(),
          date: oldDate
        }
        break
      }
    }
    DataHelper.savePlants(this.prefDB, list)
    setTimeout(() => {
      this.isSaving = false
      try { promptAction.showToast({ message: '修改已保存' }) } catch (e) {}
      try { router.back() } catch (e) {}
    }, 350)
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
            Text('EDIT PLANT').fontSize(10).fontColor('#A5C87A').letterSpacing(2)
            Text('编辑绿植').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 10 }) {
            Text('植物名称').fontSize(13).fontColor('#6D6A62')
            TextInput({ text: this.plantName, placeholder: '植物名称' })
              .width('100%').height(48).borderRadius(18).fontSize(15)
              .backgroundColor('#FAFAF8').padding({ left: 16, right: 16 })
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .onChange((v: string) => { this.plantName = v })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 12 }) {
            Text('植物类型').fontSize(13).fontColor('#6D6A62')
            Grid() {
              ForEach(this.typeOptions, (opt: TypeOption) => {
                GridItem() {
                  Column({ space: 4 }) {
                    Text(opt.icon).fontSize(22)
                    Text(opt.label).fontSize(11).fontColor(this.plantType === opt.label ? '#FFFFFF' : '#6D6A62')
                  }.width('100%').height(68).borderRadius(16).justifyContent(FlexAlign.Center)
                  .backgroundColor(this.plantType === opt.label ? '#4A7C2F' : opt.bg)
                  .onClick(() => { this.plantType = opt.label })
                }
              })
            }.columnsTemplate('1fr 1fr 1fr').rowsGap(8).columnsGap(8)
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 12 }) {
            Row() {
              Text('浇水频率').fontSize(13).fontColor('#6D6A62')
              Blank()
              Text(`${this.waterDays} 天/次`).fontSize(14).fontColor('#4A7C2F').fontWeight(FontWeight.Bold)
            }.width('100%')
            Slider({ value: this.waterDays, min: 1, max: 30, step: 1, style: SliderStyle.InSet })
              .blockColor('#4A7C2F').trackColor('#E8E0D4').selectedColor('#4A7C2F')
              .onChange((v: number) => { this.waterDays = v })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 12 }) {
            Text('光照需求').fontSize(13).fontColor('#6D6A62')
            Row({ space: 10 }) {
              ForEach(this.sunlightOptions, (opt: string, idx: number) => {
                Column({ space: 4 }) {
                  Text(this.sunlightIcons[idx]).fontSize(20)
                  Text(opt).fontSize(11).fontColor(this.sunlight === opt ? '#FFFFFF' : '#6D6A62')
                }.layoutWeight(1).height(64).borderRadius(16).justifyContent(FlexAlign.Center)
                .backgroundColor(this.sunlight === opt ? '#4A7C2F' : '#FAFAF8')
                .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
                .onClick(() => { this.sunlight = opt })
              })
            }.width('100%')
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 10 }) {
            Text('备注').fontSize(13).fontColor('#6D6A62')
            TextArea({ text: this.notes, placeholder: '养护备注...' })
              .width('100%').height(100).borderRadius(18).fontSize(14)
              .backgroundColor('#FAFAF8').padding(12)
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .onChange((v: string) => { this.notes = v })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Button({ type: ButtonType.Normal }) {
            if (this.isSaving) {
              LoadingProgress().width(22).height(22).color('#FFFFFF')
            } else {
              Text('保存修改').fontSize(15).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
            }
          }.width('100%').height(50).borderRadius(26).backgroundColor('#4A7C2F')
          .enabled(!this.isSaving).onClick(() => { this.saveEdit() })

          Blank().height(24)
        }.width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct EditPlantPreview {
  build() { EditPlantPage() }
}
