import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

interface PlantItem {
  name: string
  type: string
}

@Entry
@Component
struct AddPlantPage {
  @State plantName: string = ""
  @State plantType: string = "多肉"
  typeArr: Array<string> = ["多肉", "绿萝", "月季", "其他"]
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    preferences.getPreferences(getContext(this), "plantDB")
      .then((res: preferences.Preferences) => {
        this.prefDB = res
      })
  }

  savePlant() {
    if (this.plantName == "") {
      promptAction.showToast({ message: "请输入绿植名称！" })
      return
    }
    const raw: string = this.prefDB?.getSync("plantList", '[]') as string
    const list: Array<PlantItem> = JSON.parse(raw)
    list.push({
      name: this.plantName,
      type: this.plantType
    })
    this.prefDB?.putSync("plantList", JSON.stringify(list))
    promptAction.showToast({ message: "添加成功" })
    router.back()
  }

  build() {
    Column({ space: 20 }) {
      Text("新增绿植")
        .fontSize(26)
        .margin({ bottom: 10 })

      TextInput({ text: this.plantName, placeholder: "绿植名称（例：小绿萝）" })
        .width("90%")
        .height(50)
        .onChange((val: string) => this.plantName = val)

      Text("选择品种：").fontSize(20)
      Row({ space: 8 }) {
        ForEach(this.typeArr, (item: string) => {
          Button(item)
            .width(80)
            .backgroundColor(this.plantType === item ? "#007DFF" : "#ffffff")
            .fontColor(this.plantType === item ? "#ffffff" : "#000000")
            .onClick(() => {
              this.plantType = item
            })
        })
      }

      Row({ space: 20 }) {
        Button("取消")
          .width("42%")
          .height(55)
          .onClick(() => router.back())
        Button("保存")
          .width("42%")
          .height(55)
          .onClick(() => this.savePlant())
      }
      .width("100%")
      .margin({ top: 20 })
    }
    .width("100%")
    .height("100%")
    .padding(18)
  }
}