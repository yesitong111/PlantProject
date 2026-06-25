import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct LoginPage {
  @State userName: string = ''
  @State password: string = ''
  @State rememberPwd: boolean = false
  @State isLogging: boolean = false
  @State userNameFocused: boolean = false
  @State passwordFocused: boolean = false
  @State btnScale: number = 1.0
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    try {
      preferences.getPreferences(getContext(this), 'userData')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          try {
            const savedRemember = pref.getSync('rememberPwd', false) as boolean
            this.rememberPwd = savedRemember
            if (savedRemember) {
              this.userName = pref.getSync('user', '') as string
              this.password = pref.getSync('password', '') as string
            }
          } catch (e) {}
        })
        .catch(() => {})
    } catch (e) {}
  }

  submitLogin() {
    if (this.userName.trim() === '') {
      try { promptAction.showToast({ message: '请输入用户名或学号 😊', duration: 2000 }) } catch (e) {}
      return
    }
    if (this.password.trim() === '') {
      try { promptAction.showToast({ message: '请输入密码哦~', duration: 2000 }) } catch (e) {}
      return
    }
    if (this.password.length < 3) {
      try { promptAction.showToast({ message: '密码至少需要3位字符', duration: 2000 }) } catch (e) {}
      return
    }

    this.isLogging = true

    try {
      this.prefDB?.putSync('user', this.userName.trim())
      if (this.rememberPwd) {
        this.prefDB?.putSync('password', this.password)
        this.prefDB?.putSync('rememberPwd', true)
      } else {
        this.prefDB?.putSync('password', '')
        this.prefDB?.putSync('rememberPwd', false)
      }
      this.prefDB?.flush().catch(() => {})
    } catch (e) {}

    setTimeout(() => {
      this.isLogging = false
      try { promptAction.showToast({ message: `🎉 欢迎回来，${this.userName.trim()}！`, duration: 2000 }) } catch (e) {}
      try {
        router.replaceUrl({ url: 'pages/home' })
      } catch (e) {
        try { router.back() } catch (err) {}
      }
    }, 600)
  }

  build() {
    Column() {

      // ===== 返回按钮（极简，浮在顶部）=====
      Row() {
        Button({ type: ButtonType.Normal }) {
          Row({ space: 4 }) {
            Text('‹').fontSize(22).fontColor('#FFFFFFCC').fontWeight(FontWeight.Bold)
            Text('返回').fontSize(14).fontColor('#FFFFFFBB')
          }
        }
        .backgroundColor(Color.Transparent)
        .height(40)
        .padding({ left: 6, right: 14 })
        .onClick(() => {
          try { router.back() } catch (e) {}
        })
        Blank()
      }
      .width('100%')
      .padding({ top: 10, left: 4 })

      // ===== 植物插画横幅（模拟植物插图感）=====
      Column({ space: 6 }) {
        Row() {
          Text('🌵').fontSize(36).margin({ bottom: 0 })
          Text('🌿').fontSize(52).margin({ top: 10 })
          Text('🌸').fontSize(30).margin({ bottom: 4 })
          Text('🪴').fontSize(48).margin({ top: 4 })
          Text('🍃').fontSize(34).margin({ bottom: 6 })
          Text('🌱').fontSize(40).margin({ top: 8 })
        }
        .width('90%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Text('Monstera  ·  绿萝  ·  仙人掌  ·  多肉')
          .fontSize(11)
          .fontColor('#FFFFFF88')
          .letterSpacing(0.5)
      }
      .margin({ top: 4, bottom: 20 })

      // ===== App Logo（缩小版）+ 名称 + Slogan =====
      Column({ space: 8 }) {
        Column() {
          Image($r('app.media.startIcon'))
            .width(46)
            .height(46)
            .borderRadius(13)
            .objectFit(ImageFit.Contain)
        }
        .width(64)
        .height(64)
        .borderRadius(20)
        .backgroundColor('#FFFFFF22')
        .border({ width: 1.5, color: '#FFFFFF40', style: BorderStyle.Solid })
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 12, color: '#00000025', offsetY: 4 })

        Text('校园绿植养护助手')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text('记录植物成长，让养护变简单 🌿')
          .fontSize(13)
          .fontColor('#FFFFFFAA')
          .letterSpacing(0.3)
      }
      .margin({ bottom: 28 })

      // ===== 磨砂玻璃登录卡片 =====
      Scroll() {
        Column({ space: 0 }) {
          Column({ space: 22 }) {

            // 卡片顶部标题
            Row() {
              Column({ space: 3 }) {
                Text('登录账号')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('欢迎回到你的绿植空间')
                  .fontSize(12)
                  .fontColor('#FFFFFF88')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text('✦').fontSize(20).fontColor('#4ADE8088')
            }
            .width('100%')

            // ===== 用户名输入框（icon + 清除 + 焦点描边）=====
            Column({ space: 7 }) {
              Text('用户名 / 学号')
                .fontSize(12)
                .fontColor('#FFFFFFBB')
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .padding({ left: 2 })

              Row() {
                Text('👤')
                  .fontSize(17)
                  .margin({ left: 14, right: 10 })
                  .opacity(0.85)

                TextInput({ text: this.userName, placeholder: '请输入用户名或学号' })
                  .layoutWeight(1)
                  .height(50)
                  .backgroundColor(Color.Transparent)
                  .fontSize(15)
                  .fontColor('#FFFFFF')
                  .caretColor('#4ADE80')
                  .placeholderColor('#FFFFFF55')
                  .onChange((val: string) => { this.userName = val })
                  .onEditChange((isEditing: boolean) => {
                    this.userNameFocused = isEditing
                  })

                if (this.userName.length > 0) {
                  Column() {
                    Text('✕')
                      .fontSize(13)
                      .fontColor('#FFFFFF77')
                  }
                  .width(38)
                  .height(50)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => { this.userName = '' })
                }
              }
              .width('100%')
              .height(52)
              .borderRadius(14)
              .backgroundColor(this.userNameFocused ? '#FFFFFF22' : '#FFFFFF12')
              .border({
                width: this.userNameFocused ? 2 : 1,
                color: this.userNameFocused ? '#4ADE80' : '#FFFFFF28',
                style: BorderStyle.Solid
              })
            }

            // ===== 密码输入框（icon + 清除 + 焦点描边）=====
            Column({ space: 7 }) {
              Text('密码')
                .fontSize(12)
                .fontColor('#FFFFFFBB')
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
                .padding({ left: 2 })

              Row() {
                Text('🔒')
                  .fontSize(17)
                  .margin({ left: 14, right: 10 })
                  .opacity(0.85)

                TextInput({ text: this.password, placeholder: '请输入密码（至少3位）' })
                  .layoutWeight(1)
                  .height(50)
                  .backgroundColor(Color.Transparent)
                  .fontSize(15)
                  .fontColor('#FFFFFF')
                  .caretColor('#4ADE80')
                  .placeholderColor('#FFFFFF55')
                  .type(InputType.Password)
                  .onChange((val: string) => { this.password = val })
                  .onEditChange((isEditing: boolean) => {
                    this.passwordFocused = isEditing
                  })

                if (this.password.length > 0) {
                  Column() {
                    Text('✕')
                      .fontSize(13)
                      .fontColor('#FFFFFF77')
                  }
                  .width(38)
                  .height(50)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => { this.password = '' })
                }
              }
              .width('100%')
              .height(52)
              .borderRadius(14)
              .backgroundColor(this.passwordFocused ? '#FFFFFF22' : '#FFFFFF12')
              .border({
                width: this.passwordFocused ? 2 : 1,
                color: this.passwordFocused ? '#4ADE80' : '#FFFFFF28',
                style: BorderStyle.Solid
              })
            }

            // 记住密码 + 忘记密码
            Row() {
              Toggle({ type: ToggleType.Checkbox, isOn: this.rememberPwd })
                .width(18)
                .height(18)
                .selectedColor('#4ADE80')
                .onChange((isOn: boolean) => { this.rememberPwd = isOn })
              Text('  记住密码')
                .fontSize(13)
                .fontColor('#FFFFFFCC')
              Blank()
              Text('忘记密码？')
                .fontSize(13)
                .fontColor('#86EFAC')
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  try { promptAction.showToast({ message: '请联系管理员重置密码', duration: 2000 }) } catch (e) {}
                })
            }
            .width('100%')

            // ===== 渐变登录按钮（浅绿→深绿 + 点击缩放动画）=====
            Button({ type: ButtonType.Normal }) {
              if (this.isLogging) {
                Row({ space: 8 }) {
                  LoadingProgress().width(20).height(20).color('#FFFFFF')
                  Text('登录中...').fontSize(16).fontColor('#FFFFFF')
                }
              } else {
                Row({ space: 8 }) {
                  Text('🌿').fontSize(16)
                  Text('立  即  登  录')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .letterSpacing(1)
                }
              }
            }
            .width('100%')
            .height(54)
            .borderRadius(27)
            .linearGradient({
              angle: 90,
              colors: [['#86EFAC', 0.0], ['#22C55E', 0.45], ['#15803D', 1.0]]
            })
            .shadow({ radius: 18, color: '#22C55E66', offsetY: 7 })
            .scale({ x: this.btnScale, y: this.btnScale })
            .enabled(!this.isLogging)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
                  this.btnScale = 0.95
                })
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
                  this.btnScale = 1.0
                })
              }
            })
            .onClick(() => { this.submitLogin() })

            // 体验提示
            Row({ space: 5 }) {
              Text('💡').fontSize(12)
              Text('任意用户名 + 3位以上密码即可体验')
                .fontSize(12)
                .fontColor('#FFFFFF66')
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 26, bottom: 30 })
          .borderRadius(28)
          .backgroundColor('#FFFFFF15')
          .backgroundBlurStyle(BlurStyle.Thin)
          .border({ width: 1.5, color: '#FFFFFF25', style: BorderStyle.Solid })
          .shadow({ radius: 32, color: '#00000028', offsetY: 14 })

          Blank().height(48)
        }
        .width('92%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 168,
      colors: [['#052E16', 0.0], ['#064E27', 0.25], ['#0F6B35', 0.55], ['#166534', 0.8], ['#15803D', 1.0]]
    })
  }
}

@Component
@Preview
struct LoginPreview {
  build() {
    LoginPage()
  }
}
