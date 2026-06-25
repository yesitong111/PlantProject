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
  @State userFocused: boolean = false
  @State pwdFocused: boolean = false
  @State btnScale: number = 1.0
  @State heroOpacity: number = 0
  @State heroY: number = -20
  @State formOpacity: number = 0
  @State formY: number = 20
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.heroOpacity = 1
      this.heroY = 0
    })
    animateTo({ duration: 700, curve: Curve.EaseOut, delay: 200 }, () => {
      this.formOpacity = 1
      this.formY = 0
    })
    try {
      preferences.getPreferences(getContext(this), 'userData')
        .then((pref: preferences.Preferences) => {
          this.prefDB = pref
          try {
            const r = pref.getSync('rememberPwd', false) as boolean
            this.rememberPwd = r
            if (r) {
              this.userName = pref.getSync('user', '') as string
              this.password = pref.getSync('password', '') as string
            }
          } catch (e) {}
        }).catch(() => {})
    } catch (e) {}
  }

  submitLogin() {
    if (this.userName.trim() === '') {
      try { promptAction.showToast({ message: '请输入用户名或学号', duration: 2000 }) } catch (e) {}
      return
    }
    if (this.password.trim() === '') {
      try { promptAction.showToast({ message: '请输入密码', duration: 2000 }) } catch (e) {}
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
      try { promptAction.showToast({ message: `欢迎回来，${this.userName.trim()}！`, duration: 2000 }) } catch (e) {}
      try {
        router.replaceUrl({ url: 'pages/home' })
      } catch (e) {
        try { router.back() } catch (err) {}
      }
    }, 500)
  }

  build() {
    Column() {
      // 图2风格：顶部 blush/粉色 hero 区
      Column() {
        // 返回按钮
        Row() {
          Button({ type: ButtonType.Normal }) {
            Text('‹ 返回').fontSize(15).fontColor('#5A4A4A')
          }
          .height(36).backgroundColor(Color.Transparent)
          .onClick(() => { try { router.back() } catch (e) {} })
          Blank()
        }
        .width('100%')
        .padding({ left: 16, top: 12 })

        Blank().height(8)

        // 大植物主图（模拟 img2 的大仙人掌）
        Column() {
          Text('🌵')
            .fontSize(120)
            .margin({ top: 20 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)

        Blank().height(16)

        // 三小缩略图（模拟 img2 底部三张）
        Row({ space: 14 }) {
          Column() {
            Text('🌳').fontSize(36)
          }
          .width(88).height(88).borderRadius(20)
          .backgroundColor('#FFFDF0')
          .border({ width: 1, color: '#E8D8C8', style: BorderStyle.Solid })
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('🪴').fontSize(38)
          }
          .width(88).height(88).borderRadius(20)
          .backgroundColor('#FFF8E6')
          .border({ width: 1, color: '#E8D8C8', style: BorderStyle.Solid })
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('🌿').fontSize(34)
          }
          .width(88).height(88).borderRadius(20)
          .backgroundColor('#EFF8EA')
          .border({ width: 1, color: '#C8D8C0', style: BorderStyle.Solid })
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 28 })
      }
      .width('100%')
      .backgroundColor('#FDE8E4')
      .opacity(this.heroOpacity)
      .translate({ y: this.heroY })

      // 图2风格：大字标 + SWIPE UP 感
      Column({ space: 4 }) {
        Text('PLANT')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8FB3C9')
          .letterSpacing(8)
        Text('CARE')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8FB3C9')
          .letterSpacing(8)
        Text('校园绿植养护助手')
          .fontSize(13)
          .fontColor('#4A7C2F')
          .letterSpacing(2)
          .margin({ top: 4 })
        Text('记录植物成长 · 让养护变简单')
          .fontSize(12)
          .fontColor('#AAAAAA')
          .letterSpacing(0.5)
      }
      .padding({ top: 20, bottom: 18 })
      .opacity(this.formOpacity)
      .translate({ y: this.formY })

      // 登录表单区
      Scroll() {
        Column({ space: 16 }) {
          // 表单卡片
          Column({ space: 18 }) {
            Row() {
              Text('LOGIN')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .letterSpacing(3)
              Blank()
              Text('🌿').fontSize(18)
            }
            .width('100%')

            Column({ space: 7 }) {
              Text('用户名 / 学号')
                .fontSize(12).fontColor('#6D6A62')
                .alignSelf(ItemAlign.Start)
              Row() {
                Text('👤').fontSize(16).margin({ left: 14, right: 10 })
                TextInput({ text: this.userName, placeholder: '请输入用户名或学号' })
                  .layoutWeight(1).height(48)
                  .backgroundColor(Color.Transparent)
                  .fontSize(15).fontColor('#1A1A1A')
                  .caretColor('#4A7C2F').placeholderColor('#BBBBBB')
                  .onChange((v: string) => { this.userName = v })
                  .onEditChange((b: boolean) => { this.userFocused = b })
                if (this.userName.length > 0) {
                  Text('×').fontSize(18).fontColor('#BBBBBB')
                    .padding({ right: 14 })
                    .onClick(() => { this.userName = '' })
                }
              }
              .height(52).width('100%').borderRadius(18)
              .backgroundColor('#FAFAF8')
              .border({
                width: this.userFocused ? 2 : 1,
                color: this.userFocused ? '#4A7C2F' : '#E4DDD0',
                style: BorderStyle.Solid
              })
            }

            Column({ space: 7 }) {
              Text('密码')
                .fontSize(12).fontColor('#6D6A62')
                .alignSelf(ItemAlign.Start)
              Row() {
                Text('🔒').fontSize(16).margin({ left: 14, right: 10 })
                TextInput({ text: this.password, placeholder: '请输入密码（至少3位）' })
                  .layoutWeight(1).height(48)
                  .backgroundColor(Color.Transparent)
                  .fontSize(15).fontColor('#1A1A1A')
                  .caretColor('#4A7C2F').placeholderColor('#BBBBBB')
                  .type(InputType.Password)
                  .onChange((v: string) => { this.password = v })
                  .onEditChange((b: boolean) => { this.pwdFocused = b })
                if (this.password.length > 0) {
                  Text('×').fontSize(18).fontColor('#BBBBBB')
                    .padding({ right: 14 })
                    .onClick(() => { this.password = '' })
                }
              }
              .height(52).width('100%').borderRadius(18)
              .backgroundColor('#FAFAF8')
              .border({
                width: this.pwdFocused ? 2 : 1,
                color: this.pwdFocused ? '#4A7C2F' : '#E4DDD0',
                style: BorderStyle.Solid
              })
            }

            Row() {
              Toggle({ type: ToggleType.Checkbox, isOn: this.rememberPwd })
                .width(18).height(18).selectedColor('#4A7C2F')
                .onChange((b: boolean) => { this.rememberPwd = b })
              Text(' 记住密码').fontSize(13).fontColor('#6D6A62')
              Blank()
              Text('忘记密码？').fontSize(13).fontColor('#4A7C2F')
                .onClick(() => {
                  try { promptAction.showToast({ message: '请联系管理员重置密码', duration: 2000 }) } catch (e) {}
                })
            }
            .width('100%')

            // 图2 SWIPE UP 风格登录按钮
            Button({ type: ButtonType.Normal }) {
              if (this.isLogging) {
                Row({ space: 8 }) {
                  LoadingProgress().width(20).height(20).color('#FFFFFF')
                  Text('登录中...').fontSize(16).fontColor('#FFFFFF')
                }
              } else {
                Text('SWIPE UP  /  立即登录')
                  .fontSize(14).fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF').letterSpacing(1.5)
              }
            }
            .height(54).width('100%').borderRadius(30)
            .backgroundColor('#4A7C2F')
            .shadow({ radius: 18, color: '#2D5A1B30', offsetY: 8 })
            .scale({ x: this.btnScale, y: this.btnScale })
            .enabled(!this.isLogging)
            .onTouch((e: TouchEvent) => {
              if (e.type === TouchType.Down) {
                animateTo({ duration: 100, curve: Curve.EaseOut }, () => { this.btnScale = 0.96 })
              } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
                animateTo({ duration: 180, curve: Curve.EaseOut }, () => { this.btnScale = 1.0 })
              }
            })
            .onClick(() => { this.submitLogin() })

            Text('任意用户名 + 3位以上密码即可体验')
              .fontSize(11).fontColor('#CCCCCC')
          }
          .width('90%')
          .padding({ left: 22, right: 22, top: 22, bottom: 24 })
          .borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
          .shadow({ radius: 18, color: '#00000014', offsetY: 8 })

          Blank().height(28)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .opacity(this.formOpacity)
      .translate({ y: this.formY })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct LoginPreview {
  build() { LoginPage() }
}
