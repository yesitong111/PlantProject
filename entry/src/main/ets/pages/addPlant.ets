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

interface TypeOption {
  label: string
  icon: string
  bg: string
}

@Entry
@Component
struct AddPlantPage {
  @State plantName: string = ''
  @State plantType: string = '多肉'
  @State waterDays: number = 7
  @State sunlight: string = '散射光'
  @State notes: string = ''
  @State isSaving: boolean = false
  @State saveScale: number = 1.0
  @State contentOpacity: number = 0
  @State contentY: number = 16
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
    animateTo({ duration: 480, curve: Curve.EaseOut, delay: 80 }, () => {
      this.contentOpacity = 1
      this.contentY = 0
    })
    try {
      preferences.getPreferences(getContext(this), 'plantDB')
        .then((r: preferences.Preferences) => { this.prefDB = r })
        .catch(() => {})
    } catch (e) {}
  }

  savePlant() {
    if (this.plantName.trim() === '') {
      try { promptAction.showToast({ message: '请先给绿植起个名字 🌱' }) } catch (e) {}
      return
    }
    if (this.plantName.trim().length > 20) {
      try { promptAction.showToast({ message: '名称不能超过20个字' }) } catch (e) {}
      return
    }
    this.isSaving = true
    const now = new Date()
    const ds = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
    const np: PlantItem = {
      name: this.plantName.trim(),
      type: this.plantType,
      waterDays: this.waterDays.toString(),
      sunlight: this.sunlight,
      notes: this.notes.trim(),
      date: ds
    }
    try {
      const raw = this.prefDB?.getSync('plantList', '[]') as string
      const list = JSON.parse(raw) as Array<PlantItem>
      list.unshift(np)
      this.prefDB?.putSync('plantList', JSON.stringify(list))
      this.prefDB?.flush().catch(() => {})
    } catch (e) {}
    setTimeout(() => {
      this.isSaving = false
      try { promptAction.showToast({ message: `「${np.name}」已加入你的植物角 🎉` }) } catch (e) {}
      try { router.back() } catch (e) {}
    }, 450)
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
            Text('NEW PLANT')
              .fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('新增绿植')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 14, bottom: 18 })
      }
      .backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 16 }) {

          // Hero 引导
          Row({ space: 14 }) {
            Column() { Text('🌿').fontSize(44) }
              .width(74).height(74).borderRadius(24)
              .backgroundColor('#EEF6EA').justifyContent(FlexAlign.Center)
            Column({ space: 6 }) {
              Text('给新植物建档')
                .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
              Text('记录品种、浇水频率和光照偏好，建立专属养护档案。')
                .fontSize(13).fontColor('#8A8A8A').lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .width('100%').padding(18).borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

          // 名称
          Column({ space: 10 }) {
            this.Label('🌱', 'PLANT NAME', '绿植名称')
            TextInput({ text: this.plantName, placeholder: '例如：窗边的小绿萝' })
              .width('100%').height(52).borderRadius(18)
              .backgroundColor('#FAFAF8').fontSize(15)
              .placeholderColor('#BBBBBB')
              .padding({ left: 16, right: 16 })
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .onChange((v: string) => { this.plantName = v })
          }
          .width('100%').padding(18).borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

          // 类型
          Column({ space: 12 }) {
            this.Label('🪴', 'PLANT TYPE', '选择植物类型')
            Grid() {
              ForEach(this.typeOptions, (opt: TypeOption) => {
                GridItem() {
                  Column({ space: 5 }) {
                    Text(opt.icon).fontSize(24)
                    Text(opt.label)
                      .fontSize(12)
                      .fontColor(this.plantType === opt.label ? '#2D5A1B' : '#666666')
                      .fontWeight(this.plantType === opt.label ? FontWeight.Bold : FontWeight.Normal)
                  }
                  .width('100%').height(68).borderRadius(18)
                  .backgroundColor(this.plantType === opt.label ? '#D8F0D0' : opt.bg)
                  .border({
                    width: this.plantType === opt.label ? 2 : 0,
                    color: '#4A7C2F', style: BorderStyle.Solid
                  })
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => { this.plantType = opt.label })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(10).columnsGap(10)
            .width('100%').height(158)
          }
          .width('100%').padding(18).borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

          // 浇水频率
          Column({ space: 12 }) {
            Row() {
              this.Label('💧', 'WATER FREQUENCY', '浇水频率')
              Blank()
              Text(`${this.waterDays} 天/次`)
                .fontSize(13).fontColor('#4A7C2F')
                .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                .backgroundColor('#D8F0D0').borderRadius(16)
            }
            .width('100%')
            Slider({ value: this.waterDays, min: 1, max: 30, step: 1, style: SliderStyle.InSet })
              .width('100%')
              .blockColor('#4A7C2F').selectedColor('#A5C87A').trackColor('#E8E0D4')
              .onChange((v: number) => { this.waterDays = v })
            Row() {
              Text('1天').fontSize(10).fontColor('#CCCCCC')
              Blank()
              Text('15天').fontSize(10).fontColor('#CCCCCC')
              Blank()
              Text('30天').fontSize(10).fontColor('#CCCCCC')
            }
            .width('100%')
          }
          .width('100%').padding(18).borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

          // 光照偏好
          Column({ space: 12 }) {
            this.Label('☀️', 'LIGHT', '光照偏好')
            Row({ space: 10 }) {
              ForEach(this.sunlightOptions, (opt: string, idx: number) => {
                Column({ space: 5 }) {
                  Text(this.sunlightIcons[idx]).fontSize(22)
                  Text(opt)
                    .fontSize(12)
                    .fontColor(this.sunlight === opt ? '#FFFFFF' : '#555555')
                    .fontWeight(this.sunlight === opt ? FontWeight.Bold : FontWeight.Normal)
                }
                .layoutWeight(1).height(62).borderRadius(18)
                .backgroundColor(this.sunlight === opt ? '#4A7C2F' : '#F2F8EE')
                .justifyContent(FlexAlign.Center)
                .onClick(() => { this.sunlight = opt })
              })
            }
            .width('100%')
          }
          .width('100%').padding(18).borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

          // 备注
          Column({ space: 10 }) {
            Row({ space: 4 }) {
              this.Label('📝', 'NOTES', '备注')
              Text('选填').fontSize(11).fontColor('#BBBBBB')
            }
            TextArea({ text: this.notes, placeholder: '记录来源、叶片状态或养护注意事项...' })
              .width('100%').height(90).borderRadius(18)
              .backgroundColor('#FAFAF8').fontSize(14)
              .placeholderColor('#BBBBBB')
              .padding({ left: 14, right: 14, top: 12, bottom: 12 })
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .onChange((v: string) => { this.notes = v })
          }
          .width('100%').padding(18).borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
          .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

          // 保存按钮
          Button({ type: ButtonType.Normal }) {
            if (this.isSaving) {
              Row({ space: 8 }) {
                LoadingProgress().width(20).height(20).color('#FFFFFF')
                Text('保存中...').fontSize(15).fontColor('#FFFFFF')
              }
            } else {
              Row({ space: 8 }) {
                Text('🌿').fontSize(16)
                Text('保存绿植').fontSize(15).fontColor('#FFFFFF').fontWeight(FontWeight.Bold).letterSpacing(0.5)
              }
            }
          }
          .width('100%').height(54).borderRadius(30)
          .backgroundColor('#4A7C2F')
          .shadow({ radius: 18, color: '#2D5A1B35', offsetY: 8 })
          .scale({ x: this.saveScale, y: this.saveScale })
          .enabled(!this.isSaving)
          .onTouch((e: TouchEvent) => {
            if (e.type === TouchType.Down) {
              animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.saveScale = 0.95 })
            } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
              animateTo({ duration: 180, curve: Curve.EaseOut }, () => { this.saveScale = 1.0 })
            }
          })
          .onClick(() => { this.savePlant() })

          Blank().height(26)
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 16 })
        .opacity(this.contentOpacity)
        .translate({ y: this.contentY })
      }
      .layoutWeight(1).width('100%')
      .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }
    .width('100%').height('100%').backgroundColor('#F7F4EF')
  }

  @Builder
  Label(icon: string, en: string, zh: string) {
    Column({ space: 2 }) {
      Text(`${icon}  ${en}`)
        .fontSize(10).fontColor('#8A8A8A').letterSpacing(2)
      Text(zh)
        .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
@Preview
struct AddPlantPreview {
  build() { AddPlantPage() }
}
