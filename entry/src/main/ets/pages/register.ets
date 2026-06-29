import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DataHelper } from '../common/DataHelper'
import { UserRecord, formatDateStr } from '../common/PlantTypes'

@Entry
@Component
struct RegisterPage {
  @State userName: string = ''
  @State password: string = ''
  @State confirmPwd: string = ''
  @State nickname: string = ''
  @State isSaving: boolean = false
  @State contentOpacity: number = 0
  @State btnScale: number = 1.0
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    animateTo({ duration: 480, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    DataHelper.getPref('userData', getContext(this)).then((p: preferences.Preferences | null) => { this.prefDB = p })
  }

  doRegister() {
    if (this.userName.trim().length < 2) {
      try { promptAction.showToast({ message: '用户名至少2个字符' }) } catch (e) {}
      return
    }
    if (this.password.length < 3) {
      try { promptAction.showToast({ message: '密码至少3位' }) } catch (e) {}
      return
    }
    if (this.password !== this.confirmPwd) {
      try { promptAction.showToast({ message: '两次密码不一致' }) } catch (e) {}
      return
    }
    this.isSaving = true
    const users = this.prefDB ? DataHelper.loadUsers(this.prefDB) : []
    for (let i = 0; i < users.length; i++) {
      if (users[i].user === this.userName.trim()) {
        this.isSaving = false
        try { promptAction.showToast({ message: '该用户名已被注册' }) } catch (e) {}
        return
      }
    }
    const record: UserRecord = {
      user: this.userName.trim(),
      password: this.password,
      nickname: this.nickname.trim() || this.userName.trim(),
      registerDate: formatDateStr(new Date())
    }
    users.push(record)
    if (this.prefDB) {
      DataHelper.saveUsers(this.prefDB, users)
      try {
        this.prefDB.putSync('user', record.user)
        this.prefDB.putSync('password', record.password)
        this.prefDB.putSync('nickname', record.nickname)
        this.prefDB.flush().catch(() => {})
      } catch (e) {}
    }
    hilog.info(0x0001, 'RegisterPage', 'user registered')
    setTimeout(() => {
      this.isSaving = false
      try { promptAction.showToast({ message: '注册成功，欢迎加入植物角！' }) } catch (e) {}
      try { router.replaceUrl({ url: 'pages/home' }) } catch (e) {}
    }, 400)
  }

  build() {
    Column() {
      Column() {
        Row() {
          Button({ type: ButtonType.Normal }) {
            Text('‹ 返回').fontSize(15).fontColor('#A5C87A')
          }.height(36).backgroundColor(Color.Transparent)
            .onClick(() => { try { router.back() } catch (e) {} })
          Blank()
          Column({ space: 1 }) {
            Text('SIGN UP').fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('注册账号').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('🌱').fontSize(52)
            Text('加入校园植物角').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text('创建账号，开始记录你的绿植成长。').fontSize(13).fontColor('#8A8A8A')
          }.width('100%').padding(20).alignItems(HorizontalAlign.Center)

          this.fieldCard('用户名 / 学号', this.userName, '请输入用户名', (v: string) => { this.userName = v })
          this.fieldCard('昵称（选填）', this.nickname, '给自己起个植物名', (v: string) => { this.nickname = v })
          this.fieldCard('密码', this.password, '至少3位', (v: string) => { this.password = v }, true)
          this.fieldCard('确认密码', this.confirmPwd, '再次输入密码', (v: string) => { this.confirmPwd = v }, true)

          Button({ type: ButtonType.Normal }) {
            if (this.isSaving) {
              Row({ space: 8 }) {
                LoadingProgress().width(20).height(20).color('#FFFFFF')
                Text('注册中...').fontSize(15).fontColor('#FFFFFF')
              }
            } else {
              Text('完成注册').fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
            }
          }
          .width('100%').height(50).borderRadius(26)
          .backgroundColor('#4A7C2F')
          .scale({ x: this.btnScale, y: this.btnScale })
          .enabled(!this.isSaving)
          .onClick(() => { this.doRegister() })
          .onTouch((e: TouchEvent) => {
            if (e.type === TouchType.Down) animateTo({ duration: 100 }, () => { this.btnScale = 0.95 })
            else if (e.type === TouchType.Up || e.type === TouchType.Cancel) animateTo({ duration: 100 }, () => { this.btnScale = 1 })
          })

          Row({ space: 4 }) {
            Text('已有账号？').fontSize(13).fontColor('#8A8A8A')
            Text('去登录').fontSize(13).fontColor('#4A7C2F').fontWeight(FontWeight.Bold)
              .onClick(() => { try { router.replaceUrl({ url: 'pages/login' }) } catch (e) {} })
          }.justifyContent(FlexAlign.Center).width('100%')

          Blank().height(24)
        }
        .width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }

  @Builder
  fieldCard(label: string, val: string, ph: string, onCh: (v: string) => void, isPwd: boolean = false) {
    Column({ space: 8 }) {
      Text(label).fontSize(13).fontColor('#6D6A62').fontWeight(FontWeight.Medium)
      TextInput({ text: val, placeholder: ph })
        .width('100%').height(48).borderRadius(18)
        .backgroundColor('#FAFAF8').fontSize(15).placeholderColor('#BBBBBB')
        .padding({ left: 16, right: 16 })
        .type(isPwd ? InputType.Password : InputType.Normal)
        .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
        .onChange(onCh)
    }
    .width('100%').padding(18).borderRadius(28)
    .backgroundColor('#FFFDF8')
    .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
  }
}

@Component
@Preview
struct RegisterPreview {
  build() { RegisterPage() }
}
