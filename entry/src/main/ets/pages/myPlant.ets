import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import preferences from '@ohos.data.preferences'

interface PlantItem {
  name: string
  type: string
}

@Entry
@Component
struct MyPlantPage {
  @State plantList: Array<PlantItem> = []
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    preferences.getPreferences(getContext(this), "plantDB")
      .then(pref=>{
        this.prefDB = pref
        let data = this.prefDB?.getSync("plantList", '[]')
        this.plantList = JSON.parse(data as string)
      })
  }

  delPlant(index: number) {
    this.plantList.splice(index,1)
    this.prefDB?.putSync("plantList", JSON.stringify(this.plantList))
    promptAction.showToast({message: "已删除"})
  }

  build() {
    Column() {
      Row() {
        Text("我的盆栽绿植")
          .fontSize(24)
        Blank()
        Button("+ 添加绿植")
          .width(110)
          .height(40)
          .onClick(()=>{
            router.pushUrl({url: "pages/addPlant"})
          })
      }
      .width("100%")
      .margin({bottom: 15})

      List() {
        ForEach(this.plantList, (item:PlantItem, index:number)=>{
          ListItem() {
            Row() {
              Column() {
                Text(item.name).fontSize(20)
                Text("品种："+item.type).fontSize(16).fontColor("#666666")
              }
              Blank()
              Button("删除", {type: ButtonType.Normal})
                .fontSize(14)
                .backgroundColor("#ff4444")
                .onClick(()=>this.delPlant(index))
            }
            .width("100%")
            .padding(12)
          }
          .margin({bottom: 10})
          .width("98%")
        })
      }
      .layoutWeight(1)
      .width("100%")
    }
    .width("100%")
    .height("100%")
    .padding(15)
  }
}