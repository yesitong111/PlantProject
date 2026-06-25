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
  prefDB: preferences.Preferences | null = null

  typeOptions: Array<TypeOption> = [
    { label: '多肉', icon: '🪴', bg: '#FFF8E6' },
    { label: '绿萝', icon: '🌿', bg: '#E8F7EE' },
    { label: '月季', icon: '🌹', bg: '#FCE7F3' },
    { label: '富贵竹', icon: '🎋', bg: '#EFF8DC' },
    { label: '仙人掌', icon: '🌵', bg: '#E0F7F2' },
    { label: '吊兰', icon: '🌱', bg: '#E6F7FA' },
    { label: '龟背竹', icon: '🍃', bg: '#E8F7EE' },
    { label: '文竹', icon: '🎍', bg: '#F0F8E6' },
    { label: '其他', icon: '🌻', bg: '#F3F4F6' }
  ]

  sunlightOptions: Array<string> = ['充足光照', '散射光', '半阴环境']
  sunlightIcons: Array<string> = ['☀️', '🌤️', '🌥️']

  aboutToAppear() {
    try {
      preferences.getPreferences(getContext(this), 'plantDB')
        .then((res: preferences.Preferences) => {
          this.prefDB = res
        })
        .catch(() => {})
    } catch (e) {}
  }

  savePlant() {
    if (this.plantName.trim() === '') {
      try { promptAction.showToast({ message: '请先给绿植起个名字' }) } catch (e) {}
      return
    }
    if (this.plantName.trim().length > 20) {
      try { promptAction.showToast({ message: '名称不能超过20个字' }) } catch (e) {}
      return
    }

    this.isSaving = true
    const now = new Date()
    const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
    const newPlant: PlantItem = {
      name: this.plantName.trim(),
      type: this.plantType,
      waterDays: this.waterDays.toString(),
      sunlight: this.sunlight,
      notes: this.notes.trim(),
      date: dateStr
    }

    try {
      const raw = this.prefDB?.getSync('plantList', '[]') as string
      const list = JSON.parse(raw) as Array<PlantItem>
      list.unshift(newPlant)
      this.prefDB?.putSync('plantList', JSON.stringify(list))
      this.prefDB?.flush().catch(() => {})
    } catch (e) {}

    setTimeout(() => {
      this.isSaving = false
      try { promptAction.showToast({ message: `「${newPlant.name}」已加入你的植物角` }) } catch (e) {}
      try { router.back() } catch (e) {}
    }, 450)
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
        Text('新增绿植')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
        Blank()
        Row().width(58)
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 18 }) {
          // Hero
          Row({ space: 14 }) {
            Column() {
              Text('🌿')
                .fontSize(44)
            }
            .width(76)
            .height(76)
            .borderRadius(24)
            .backgroundColor('#E8F7EE')
            .justifyContent(FlexAlign.Center)

            Column({ space: 6 }) {
              Text('给新植物建档')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')
              Text('记录名字、浇水频率和光照偏好。')
                .fontSize(13)
                .fontColor('#8A8A8A')
                .lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 名称
          Column({ space: 10 }) {
            this.FormLabel('🌱', '绿植名称')
            TextInput({ text: this.plantName, placeholder: '例如：窗边的小绿萝' })
              .width('100%')
              .height(54)
              .borderRadius(18)
              .backgroundColor('#F6FAF7')
              .fontSize(15)
              .placeholderColor('#B8B8B8')
              .padding({ left: 16, right: 16 })
              .border({ width: 1, color: '#E5EFE9', style: BorderStyle.Solid })
              .onChange((val: string) => { this.plantName = val })
          }
          .width('100%')
          .padding(18)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 类型
          Column({ space: 12 }) {
            this.FormLabel('🪴', '选择植物类型')
            Grid() {
              ForEach(this.typeOptions, (option: TypeOption) => {
                GridItem() {
                  Column({ space: 6 }) {
                    Text(option.icon)
                      .fontSize(25)
                    Text(option.label)
                      .fontSize(12)
                      .fontWeight(this.plantType === option.label ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.plantType === option.label ? '#18A558' : '#666666')
                  }
                  .width('100%')
                  .height(70)
                  .borderRadius(18)
                  .backgroundColor(this.plantType === option.label ? '#E8F7EE' : option.bg)
                  .border({
                    width: this.plantType === option.label ? 2 : 0,
                    color: '#2FBF71',
                    style: BorderStyle.Solid
                  })
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => { this.plantType = option.label })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(10)
            .columnsGap(10)
            .width('100%')
            .height(158)
          }
          .width('100%')
          .padding(18)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 浇水
          Column({ space: 12 }) {
            Row() {
              this.FormLabel('💧', '浇水频率')
              Blank()
              Text(`${this.waterDays} 天/次`)
                .fontSize(13)
                .fontColor('#18A558')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#E8F7EE')
                .borderRadius(18)
            }
            .width('100%')
            Slider({ value: this.waterDays, min: 1, max: 30, step: 1, style: SliderStyle.InSet })
              .width('100%')
              .blockColor('#2FBF71')
              .selectedColor('#58D68D')
              .trackColor('#E8F7EE')
              .onChange((value: number) => { this.waterDays = value })
          }
          .width('100%')
          .padding(18)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 光照
          Column({ space: 12 }) {
            this.FormLabel('☀️', '光照偏好')
            Row({ space: 10 }) {
              ForEach(this.sunlightOptions, (item: string, index: number) => {
                Column({ space: 5 }) {
                  Text(this.sunlightIcons[index])
                    .fontSize(22)
                  Text(item)
                    .fontSize(12)
                    .fontColor(this.sunlight === item ? '#FFFFFF' : '#666666')
                    .fontWeight(this.sunlight === item ? FontWeight.Bold : FontWeight.Normal)
                }
                .layoutWeight(1)
                .height(64)
                .borderRadius(20)
                .backgroundColor(this.sunlight === item ? '#2FBF71' : '#F6FAF7')
                .justifyContent(FlexAlign.Center)
                .onClick(() => { this.sunlight = item })
              })
            }
          }
          .width('100%')
          .padding(18)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          // 备注
          Column({ space: 10 }) {
            this.FormLabel('📝', '备注')
            TextArea({ text: this.notes, placeholder: '记录来源、叶片状态或养护注意事项...' })
              .width('100%')
              .height(96)
              .borderRadius(18)
              .backgroundColor('#F6FAF7')
              .fontSize(14)
              .placeholderColor('#B8B8B8')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .border({ width: 1, color: '#E5EFE9', style: BorderStyle.Solid })
              .onChange((val: string) => { this.notes = val })
          }
          .width('100%')
          .padding(18)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#00000014', offsetY: 8 })

          Button({ type: ButtonType.Normal }) {
            if (this.isSaving) {
              Row({ space: 8 }) {
                LoadingProgress().width(20).height(20).color('#FFFFFF')
                Text('保存中').fontSize(16).fontColor('#FFFFFF')
              }
            } else {
              Text('保存绿植')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
          }
          .width('100%')
          .height(56)
          .borderRadius(30)
          .linearGradient({ angle: 90, colors: [['#58D68D', 0.0], ['#18A558', 1.0]] })
          .shadow({ radius: 20, color: '#2FBF7133', offsetY: 8 })
          .scale({ x: this.saveScale, y: this.saveScale })
          .enabled(!this.isSaving)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.saveScale = 0.96 })
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              animateTo({ duration: 180, curve: Curve.EaseOut }, () => { this.saveScale = 1.0 })
            }
          })
          .onClick(() => { this.savePlant() })

          Blank().height(22)
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

  @Builder
  FormLabel(icon: string, title: string) {
    Row({ space: 6 }) {
      Text(icon)
        .fontSize(16)
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222222')
    }
  }
}

@Component
@Preview
struct AddPlantPreview {
  build() {
    AddPlantPage()
  }
}
