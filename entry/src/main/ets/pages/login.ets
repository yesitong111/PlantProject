import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'
import { DataHelper } from '../common/DataHelper'

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
  @State currentUser: string = ''
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
            this.currentUser = pref.getSync('user', '') as string
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

  doLogout() {
    AlertDialog.show({
      title: '退出登录',
      message: `确定退出「${this.currentUser}」的账号吗？`,
      primaryButton: {
        value: '确认退出',
        fontColor: '#E03030',
        action: () => {
          try {
            this.prefDB?.putSync('user', '')
            this.prefDB?.putSync('password', '')
            this.prefDB?.putSync('rememberPwd', false)
            this.prefDB?.flush().catch(() => {})
          } catch (e) {}
          this.currentUser = ''
          this.userName = ''
          this.password = ''
          try { promptAction.showToast({ message: '已退出登录', duration: 2000 }) } catch (e) {}
        }
      },
      secondaryButton: {
        value: '取消',
        fontColor: '#4A7C2F',
        action: () => {}
      }
    })
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
    const users = this.prefDB ? DataHelper.loadUsers(this.prefDB) : []
    let matched = false
    for (let i = 0; i < users.length; i++) {
      if (users[i].user === this.userName.trim() && users[i].password === this.password) {
        matched = true
        break
      }
    }
    if (users.length > 0 && !matched) {
      this.isLogging = false
      try { promptAction.showToast({ message: '用户名或密码错误', duration: 2000 }) } catch (e) {}
      return
    }
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
      // ── 顶部返回按钮（固定，不跟着滚）──
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('‹ 返回').fontSize(15).fontColor('#5A4A4A')
        }
        .height(36).backgroundColor(Color.Transparent)
        .onClick(() => { try { router.back() } catch (e) {} })
        Blank()
      }
      .width('100%')
      .padding({ left: 16, top: 12, bottom: 4 })
      .backgroundColor('#FDE8E4')
      .opacity(this.heroOpacity)

      // ── 整页内容全部在同一个 Scroll 里 ──
      // hero 区紧凑化 + PLANT CARE 缩小 + 表单紧跟，首屏可见
      Scroll() {
        Column({ space: 0 }) {

          // Hero 区：压缩高度，仙人掌缩小，三卡缩小
          Column() {
            Column() {
              Text('🌵').fontSize(88)
            }
            .width('100%')
            .height(138)
            .justifyContent(FlexAlign.Center)

            Row({ space: 10 }) {
              Column() { Text('🌳').fontSize(28) }
                .width(66).height(66).borderRadius(16)
                .backgroundColor('#FFFDF0')
                .border({ width: 1, color: '#E8D8C8', style: BorderStyle.Solid })
                .justifyContent(FlexAlign.Center)

              Column() { Text('🪴').fontSize(30) }
                .width(66).height(66).borderRadius(16)
                .backgroundColor('#FFF8E6')
                .border({ width: 1, color: '#E8D8C8', style: BorderStyle.Solid })
                .justifyContent(FlexAlign.Center)

              Column() { Text('🌿').fontSize(26) }
                .width(66).height(66).borderRadius(16)
                .backgroundColor('#EFF8EA')
                .border({ width: 1, color: '#C8D8C0', style: BorderStyle.Solid })
                .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ bottom: 16 })
          }
          .width('100%')
          .backgroundColor('#FDE8E4')
          .opacity(this.heroOpacity)
          .translate({ y: this.heroY })

          // PLANT CARE 标题：紧凑横排
          Row({ space: 0 }) {
            Column({ space: 2 }) {
              Row({ space: 12 }) {
                Text('PLANT').fontSize(26).fontWeight(FontWeight.Bold)
                  .fontColor('#8FB3C9').letterSpacing(5)
                Text('CARE').fontSize(26).fontWeight(FontWeight.Bold)
                  .fontColor('#8FB3C9').letterSpacing(5)
              }
              Text('校园绿植养护助手 · 记录植物成长，让养护变简单')
                .fontSize(11).fontColor('#AAAAAA').letterSpacing(0.4)
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
          }
          .width('100%')
          .padding({ top: 14, bottom: 14 })
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F7F4EF')
          .opacity(this.formOpacity)
          .translate({ y: this.formY })

          // ── 登录表单卡片 ──
          Column({ space: 18 }) {
            Row() {
              Text('LOGIN')
                .fontSize(18).fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A').letterSpacing(3)
              Blank()
              Text('🌿').fontSize(18)
            }
            .width('100%')

            // 已登录状态提示
            if (this.currentUser && this.currentUser.length > 0) {
              Row() {
                Text('✅').fontSize(14)
                Text(` 当前账号：${this.currentUser}`)
                  .fontSize(13).fontColor('#4A7C2F').fontWeight(FontWeight.Medium)
                Blank()
                Text('退出登录')
                  .fontSize(12).fontColor('#E03030')
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor('#FCEAEA').borderRadius(14)
                  .onClick(() => { this.doLogout() })
              }
              .width('100%')
              .padding({ left: 2, right: 2, top: 6, bottom: 6 })
              .borderRadius(12).backgroundColor('#F0FBF0')
              .border({ width: 1, color: '#C8E8B8', style: BorderStyle.Solid })
            }

            Column({ space: 7 }) {
              Text('用户名 / 学号')
                .fontSize(12).fontColor('#6D6A62').alignSelf(ItemAlign.Start)
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
                .fontSize(12).fontColor('#6D6A62').alignSelf(ItemAlign.Start)
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

            Button({ type: ButtonType.Normal }) {
              if (this.isLogging) {
                Row({ space: 8 }) {
                  LoadingProgress().width(20).height(20).color('#FFFFFF')
                  Text('登录中...').fontSize(16).fontColor('#FFFFFF')
                }
              } else {
                Text('立 即 登 录')
                  .fontSize(15).fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF').letterSpacing(2)
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

            Row({ space: 4 }) {
              Text('还没有账号？').fontSize(13).fontColor('#8A8A8A')
              Text('立即注册').fontSize(13).fontColor('#4A7C2F').fontWeight(FontWeight.Bold)
                .onClick(() => { try { router.pushUrl({ url: 'pages/register' }) } catch (e) {} })
            }.justifyContent(FlexAlign.Center).width('100%').margin({ top: 4 })
          }
          .width('92%')
          .padding({ left: 22, right: 22, top: 22, bottom: 24 })
          .borderRadius(28)
          .backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
          .shadow({ radius: 18, color: '#00000014', offsetY: 8 })
          .margin({ top: 0 })
          .opacity(this.formOpacity)
          .translate({ y: this.formY })

          Blank().height(36)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
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
