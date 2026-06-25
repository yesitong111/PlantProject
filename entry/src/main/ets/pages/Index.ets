import router from '@ohos.router'
import preferences from '@ohos.data.preferences'

@Entry
@Component
struct SplashPage {
  @State pgOpacity: number = 0
  @State textX: number = -28
  @State plantY: number = 50
  @State plantOpacity: number = 0
  @State ringAngle: number = 0
  @State dotStep: number = 0

  aboutToAppear() {
    animateTo({ duration: 660, curve: Curve.EaseOut }, () => {
      this.pgOpacity = 1
      this.textX = 0
    })
    animateTo({ duration: 900, curve: Curve.EaseOut, delay: 280 }, () => {
      this.plantY = 0
      this.plantOpacity = 1
    })
    let tick = 0
    const timer = setInterval(() => {
      tick++
      this.dotStep = tick % 3
      animateTo({ duration: 460, curve: Curve.EaseInOut }, () => {
        this.ringAngle += 120
      })
      if (tick >= 7) {
        clearInterval(timer)
        // 加载完成后判断登录状态，决定跳转目标
        setTimeout(() => {
          this.navigateByLoginState()
        }, 280)
      }
    }, 560)
  }

  navigateByLoginState() {
    try {
      preferences.getPreferences(getContext(this), 'userData')
        .then((pref: preferences.Preferences) => {
          let savedUser = ''
          try {
            savedUser = pref.getSync('user', '') as string
          } catch (e) {}
          // 有保存的用户名 → 直接进首页；否则 → 登录页
          const target = (savedUser && savedUser.length > 0) ? 'pages/home' : 'pages/login'
          try { router.replaceUrl({ url: target }) } catch (e) {}
        })
        .catch(() => {
          // 读取失败也去登录页，保证功能正常
          try { router.replaceUrl({ url: 'pages/login' }) } catch (e) {}
        })
    } catch (e) {
      try { router.replaceUrl({ url: 'pages/login' }) } catch (err) {}
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {

      // ── 主内容 ──
      Column() {
        // 图3 editorial 大斜体标题
        Column({ space: 2 }) {
          Text('Your plants')
            .fontSize(40)
            .fontWeight(FontWeight.Medium)
            .fontStyle(FontStyle.Italic)
            .fontColor('#1A1A1A')
            .letterSpacing(0.4)
          Text('called.')
            .fontSize(40)
            .fontWeight(FontWeight.Medium)
            .fontStyle(FontStyle.Italic)
            .fontColor('#1A1A1A')
            .letterSpacing(0.4)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding({ left: 38, right: 38, top: 94 })
        .translate({ x: this.textX })
        .opacity(this.pgOpacity)

        Blank().height(24)

        Text('They want more sunlight.')
          .fontSize(21)
          .fontStyle(FontStyle.Italic)
          .fontColor('#555555')
          .letterSpacing(0.3)
          .padding({ left: 38 })
          .opacity(this.pgOpacity)

        Blank().height(36)

        Column({ space: 8 }) {
          Text('校园绿植养护助手')
            .fontSize(13)
            .fontColor('#4A7C2F')
            .letterSpacing(2.5)
          Text('Weekly Plant Care Tips')
            .fontSize(12)
            .fontColor('#8A8A8A')
            .letterSpacing(1)
          Text('— campus.grovedaily.edu')
            .fontSize(11)
            .fontColor('#C0C0C0')
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 38 })
        .opacity(this.pgOpacity)

        Blank()

        // 加载指示器
        Column({ space: 10 }) {
          Row({ space: 18 }) {
            Stack({ alignContent: Alignment.Center }) {
              Circle()
                .width(28).height(28)
                .fill(Color.Transparent)
                .stroke('#C5DEB8')
                .strokeWidth(2.5)
              Text('◜')
                .fontSize(28)
                .fontColor('#4A7C2F')
                .fontWeight(FontWeight.Bold)
                .rotate({ angle: this.ringAngle })
            }

            Row({ space: 7 }) {
              Text('·').fontSize(24).fontColor('#4A7C2F')
                .opacity(this.dotStep === 0 ? 1 : 0.28)
              Text('·').fontSize(24).fontColor('#4A7C2F')
                .opacity(this.dotStep === 1 ? 1 : 0.28)
              Text('·').fontSize(24).fontColor('#4A7C2F')
                .opacity(this.dotStep === 2 ? 1 : 0.28)
            }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')

          Text('正在唤醒校园植物角...')
            .fontSize(12)
            .fontColor('#BBBBBB')
            .letterSpacing(1)
        }
        .padding({ bottom: 64 })
        .opacity(this.pgOpacity)
      }
      .width('100%')
      .height('100%')

      // 图3：右下角大植物插图
      Column() {
        Text('🌿')
          .fontSize(168)
          .opacity(0.52)
      }
      .margin({ bottom: -42, right: -22 })
      .translate({ y: this.plantY })
      .opacity(this.plantOpacity)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F4EF')
  }
}
