import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'
import { deviceInfo } from '@kit.BasicServicesKit'
import { DataHelper } from '../common/DataHelper'
import { PlantItem } from '../common/PlantTypes'

@Entry
@Component
struct ProfilePage {
  @State userName: string = ''
  @State nickname: string = ''
  @State plantCount: number = 0
  @State checkInDays: number = 0
  @State contentOpacity: number = 0
  @State pressedKey: string = ''
  prefUser: preferences.Preferences | null = null
  prefPlant: preferences.Preferences | null = null

  aboutToAppear() {
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    this.loadData()
  }

  onPageShow() { this.loadData() }

  loadData() {
    DataHelper.getPref('userData', getContext(this)).then((p: preferences.Preferences | null) => {
      this.prefUser = p
      if (p) {
        try {
          this.userName = p.getSync('user', '') as string
          this.nickname = p.getSync('nickname', '') as string || this.userName
        } catch (e) {}
      }
    })
    DataHelper.getPref('plantDB', getContext(this)).then((p: preferences.Preferences | null) => {
      this.prefPlant = p
      if (p) {
        const list = DataHelper.loadPlants(p)
        this.plantCount = list.length
        this.checkInDays = DataHelper.loadCheckIns(p).length
      }
    })
  }

  saveNickname() {
    if (this.nickname.trim().length === 0) {
      try { promptAction.showToast({ message: '昵称不能为空' }) } catch (e) {}
      return
    }
    try {
      this.prefUser?.putSync('nickname', this.nickname.trim())
      this.prefUser?.flush().catch(() => {})
      promptAction.showToast({ message: '昵称已更新' })
    } catch (e) {}
  }

  doLogout() {
    AlertDialog.show({
      title: '退出登录',
      message: '确定退出当前账号吗？',
      primaryButton: {
        value: '退出', fontColor: '#E03030',
        action: () => {
          try {
            this.prefUser?.putSync('user', '')
            this.prefUser?.putSync('password', '')
            this.prefUser?.flush().catch(() => {})
          } catch (e) {}
          try { router.replaceUrl({ url: 'pages/login' }) } catch (e) {}
        }
      },
      secondaryButton: { value: '取消', fontColor: '#4A7C2F', action: () => {} }
    })
  }

  go(url: string) { try { router.pushUrl({ url: url }) } catch (e) {} }

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
            Text('PROFILE').fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('个人中心').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 12 }) {
            Column() {
              Text(this.nickname ? this.nickname.charAt(0).toUpperCase() : '🌿')
                .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#2D5A1B')
            }.width(72).height(72).borderRadius(36).backgroundColor('#FFFFFFCC')
            .justifyContent(FlexAlign.Center)
            .shadow({ radius: 12, color: '#00000018', offsetY: 4 })

            Text(this.nickname || '植物爱好者').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            Text(this.userName ? `@${this.userName}` : '未登录').fontSize(13).fontColor('#8A8A8A')

            Row({ space: 20 }) {
              Column({ space: 4 }) {
                Text(this.plantCount.toString()).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#4A7C2F')
                Text('绿植').fontSize(11).fontColor('#8A8A8A')
              }
              Divider().vertical(true).height(36).color('#E8E0D4')
              Column({ space: 4 }) {
                Text(this.checkInDays.toString()).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#4A7C2F')
                Text('打卡天').fontSize(11).fontColor('#8A8A8A')
              }
            }
          }.width('100%').padding(24).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Column({ space: 10 }) {
            Text('编辑昵称').fontSize(13).fontColor('#6D6A62')
            Row() {
              TextInput({ text: this.nickname, placeholder: '输入昵称' })
                .layoutWeight(1).height(44).backgroundColor(Color.Transparent).fontSize(15)
                .onChange((v: string) => { this.nickname = v })
              Button('保存', { type: ButtonType.Normal })
                .height(36).borderRadius(18).fontSize(13).fontColor('#FFFFFF').backgroundColor('#4A7C2F')
                .onClick(() => { this.saveNickname() })
            }.width('100%').padding({ left: 14, right: 8 })
            .borderRadius(18).backgroundColor('#FAFAF8')
            .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          this.menuItem('📊', '养护统计', '查看植物数据与打卡记录', 'pages/statistics', 's1')
          this.menuItem('🔔', '养护提醒', '管理浇水与养护提醒', 'pages/reminder', 's2')
          this.menuItem('⭐', '收藏贴士', '我的植物百科收藏', 'pages/favorite', 's3')
          this.menuItem('🌤️', '天气养护', '今日天气与养护建议', 'pages/weather', 's4')
          this.menuItem('ℹ️', '关于应用', '版本信息与团队介绍', 'pages/about', 's5')

          Text(`设备：${deviceInfo.productModel || 'HarmonyOS'}`)
            .fontSize(11).fontColor('#BBBBBB').width('100%').textAlign(TextAlign.Center)

          Button('退出登录', { type: ButtonType.Normal })
            .width('100%').height(46).borderRadius(24)
            .fontSize(14).fontColor('#E03030')
            .backgroundColor('#FFF0F0')
            .border({ width: 1, color: '#F5D0D0', style: BorderStyle.Solid })
            .onClick(() => { this.doLogout() })

          Blank().height(24)
        }
        .width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }

  @Builder
  menuItem(icon: string, title: string, desc: string, url: string, key: string) {
    Row({ space: 14 }) {
      Text(icon).fontSize(24)
      Column({ space: 3 }) {
        Text(title).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
        Text(desc).fontSize(11).fontColor('#8A8A8A')
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('›').fontSize(20).fontColor('#CCCCCC')
    }
    .width('100%').padding(16).borderRadius(22)
    .backgroundColor('#FFFDF8')
    .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
    .scale({ x: this.pressedKey === key ? 0.97 : 1, y: this.pressedKey === key ? 0.97 : 1 })
    .onClick(() => { this.go(url) })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) this.pressedKey = key
      else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressedKey = ''
    })
  }
}

@Component
@Preview
struct ProfilePreview {
  build() { ProfilePage() }
}
