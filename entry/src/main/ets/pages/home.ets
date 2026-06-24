import router from '@ohos.router'

@Entry
@Component
struct HomePage {
  build() {
    Column({space: 15}) {
      Text("校园绿植养护助手")
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({bottom: 30})
      Button("账号登录", {stateEffect: true})
        .width("85%")
        .height(60)
        .fontSize(20)
        .onClick(()=>{
          router.pushUrl({url: "pages/login"})
        })
      Button("我的绿植", {stateEffect: true})
        .width("85%")
        .height(60)
        .fontSize(20)
        .onClick(()=>{
          router.pushUrl({url: "pages/myPlant"})
        })
      Button("养护小贴士", {stateEffect: true})
        .width("85%")
        .height(60)
        .fontSize(20)
        .onClick(()=>{
          router.pushUrl({url: "pages/tip"})
        })
    }
    .width("100%")
    .height("100%")
    .padding(20)
  }
}


@Preview
struct HomePreview {
  build() {
    HomePage()
  }
}