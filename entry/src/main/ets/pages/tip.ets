@Entry
@Component
struct TipPage {
  plantTips: Array<string> = [
    "绿萝：喜阴凉，7天浇一次水，避免阳光直晒",
    "多肉：少浇水，半个月一次，多晒太阳",
    "月季：每天4小时光照，土壤保持微湿",
    "富贵竹：清水养护，每周换一次水"
  ]

  build() {
    Column() {
      Text("绿植养护小贴士")
        .fontSize(26)
        .margin({bottom: 20})
      List() {
        ForEach(this.plantTips, (item: string)=>{
          ListItem() {
            Text(item)
              .fontSize(18)
              .padding(12)
          }
          .margin({bottom: 8})
          .width("95%")
        })
      }
      .width("100%")
      .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
    .padding(15)
  }
}