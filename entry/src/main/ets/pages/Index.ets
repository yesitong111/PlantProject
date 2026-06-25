import router from '@ohos.router'

@Entry
@Component
struct SplashPage {
  @State opacityValue: number = 0
  @State scaleValue: number = 0.85
  @State loadingProgress: number = 0

  aboutToAppear() {
    animateTo({ duration: 900, curve: Curve.EaseOut }, () => {
      this.opacityValue = 1
      this.scaleValue = 1.0
    })

    let count = 0
    const timer = setInterval(() => {
      count += 0.13
      this.loadingProgress = Math.min(count, 1.0)
      if (this.loadingProgress >= 1.0) {
        clearInterval(timer)
        setTimeout(() => {
          try {
            router.replaceUrl({ url: 'pages/home' })
          } catch (e) {}
        }, 350)
      }
    }, 300)
  }

  build() {
    Column() {
      Column({ space: 18 }) {
        Row() {
          Image($r('app.media.startIcon'))
            .width(82)
            .height(82)
            .borderRadius(22)
            .objectFit(ImageFit.Contain)
        }
        .width(110)
        .height(110)
        .borderRadius(30)
        .backgroundColor('#4CAF50')
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 24, color: '#4CAF5055', offsetY: 10 })

        Column({ space: 6 }) {
          Text('校园绿植养护助手')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1B5E20')

          Text('用心呵护每一片绿色 🌿')
            .fontSize(15)
            .fontColor('#66BB6A')
        }
      }
      .opacity(this.opacityValue)
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .margin({ top: 170 })

      Blank()

      Column({ space: 12 }) {
        Progress({ value: this.loadingProgress * 100, total: 100, type: ProgressType.Linear })
          .width('52%')
          .height(4)
          .color('#4CAF50')
          .backgroundColor('#C8E6C9')
          .borderRadius(2)

        Text('正在加载中...')
          .fontSize(13)
          .fontColor('#AAAAAA')
      }
      .margin({ bottom: 64 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6FBF6')
  }
}
