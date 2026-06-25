import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

interface PlantItem {
  name: string
  type: string
  waterDays: string
  sunlight: string
  notes: string
  date: string
}

interface RecommendPlant {
  icon: string
  name: string
  reason: string
  water: string
  light: string
}

function getTodayKey(): string {
  const now = new Date()
  return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`
}

@Entry
@Component
struct HomePage {
  @State userName: string = ''
  @State plantCount: number = 0
  @State todayChecked: boolean = false
  @State dailyReminder: string = '今天适合检查土壤湿度，表层干了再浇水。'
  @State recommendIndex: number = 0
  @State plantList: Array<PlantItem> = []
  @State contentOpacity: number = 0
  @State contentY: number = 18
  @State pressedKey: string = ''
  @State checkInPulse: boolean = false
  @State panelVisible: boolean = false
  @State panelOpacity: number = 0
  @State panelY: number = 200
  private pulseTimer: number = -1
  prefUser: preferences.Preferences | null = null
  prefPlant: preferences.Preferences | null = null

  reminders: Array<string> = [
    '今天适合检查土壤湿度，表层干了再浇水。',
    '给叶片擦一擦灰尘，植物会更有精神。',
    '把花盆转动方向，让叶片均匀接受散射光。',
    '检查叶背有没有小虫，保持通风减少病虫害。',
    '水培植物可以换一次清水，保持根系干净。'
  ]

  recommendPlants: Array<RecommendPlant> = [
    { icon: '🌿', name: '绿萝', reason: '耐阴好养，适合宿舍和书桌。', water: '7天/次', light: '散射光' },
    { icon: '🪴', name: '多肉', reason: '小巧治愈，阳台党入门首选。', water: '15天/次', light: '充足光照' },
    { icon: '🌵', name: '仙人掌', reason: '耐旱省心，适合忙碌学生党。', water: '25天/次', light: '强光' },
    { icon: '🎋', name: '富贵竹', reason: '水培清爽，桌面氛围感很强。', water: '7天换水', light: '半阴' }
  ]

  aboutToAppear() {
    this.refreshData()
    const idx = Math.floor(Math.random() * this.reminders.length)
    this.dailyReminder = this.reminders[idx]
    this.recommendIndex = Math.floor(Math.random() * this.recommendPlants.length)
    animateTo({ duration: 500, curve: Curve.EaseOut, delay: 100 }, () => {
      this.contentOpacity = 1
      this.contentY = 0
    })
    this.startPulse()
  }

  onPageShow() { this.refreshData() }

  aboutToDisappear() {
    if (this.pulseTimer !== -1) {
      clearInterval(this.pulseTimer)
      this.pulseTimer = -1
    }
  }

  startPulse() {
    if (this.pulseTimer !== -1) clearInterval(this.pulseTimer)
    this.pulseTimer = setInterval(() => {
      if (this.todayChecked) {
        clearInterval(this.pulseTimer)
        this.pulseTimer = -1
        this.checkInPulse = false
        return
      }
      animateTo({ duration: 680, curve: Curve.EaseInOut }, () => {
        this.checkInPulse = !this.checkInPulse
      })
    }, 1360)
  }

  refreshData() {
    try {
      preferences.getPreferences(getContext(this), 'userData')
        .then((pref: preferences.Preferences) => {
          this.prefUser = pref
          try { this.userName = pref.getSync('user', '') as string } catch (e) {}
        }).catch(() => {})
    } catch (e) {}
    try {
      preferences.getPreferences(getContext(this), 'plantDB')
        .then((pref: preferences.Preferences) => {
          this.prefPlant = pref
          try {
            const raw = pref.getSync('plantList', '[]') as string
            this.plantList = JSON.parse(raw) as Array<PlantItem>
            this.plantCount = this.plantList.length
            this.todayChecked = pref.getSync('todayChecked', '') as string === getTodayKey()
          } catch (e) { this.plantList = []; this.plantCount = 0 }
        }).catch(() => {})
    } catch (e) {}
  }

  doCheckIn() {
    if (this.todayChecked) {
      try { promptAction.showToast({ message: '今天已经完成养护打卡啦 🌿' }) } catch (e) {}
      return
    }
    this.todayChecked = true
    this.checkInPulse = false
    try {
      this.prefPlant?.putSync('todayChecked', getTodayKey())
      this.prefPlant?.flush().catch(() => {})
      promptAction.showToast({ message: '今日打卡成功，植物很开心！' })
    } catch (e) {}
  }

  go(url: string) { try { router.pushUrl({ url: url }) } catch (e) {} }
  pressDown(k: string) { this.pressedKey = k }
  pressUp() { this.pressedKey = '' }

  onAvatarTap() {
    if (this.userName && this.userName.length > 0) {
      // 已登录：提供注销选项
      AlertDialog.show({
        title: `Hi, ${this.userName}`,
        message: '确定要退出登录吗？退出后需要重新登录。',
        primaryButton: {
          value: '退出登录',
          fontColor: '#E03030',
          action: () => {
            try {
              this.prefUser?.putSync('user', '')
              this.prefUser?.putSync('password', '')
              this.prefUser?.putSync('rememberPwd', false)
              this.prefUser?.flush().catch(() => {})
            } catch (e) {}
            this.userName = ''
            try { promptAction.showToast({ message: '已退出登录' }) } catch (e) {}
          }
        },
        secondaryButton: {
          value: '取消',
          fontColor: '#4A7C2F',
          action: () => {}
        }
      })
    } else {
      // 未登录：跳转登录页
      this.go('pages/login')
    }
  }

  openPanel() {
    this.panelVisible = true
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.panelOpacity = 1; this.panelY = 0
    })
  }

  closePanel() {
    animateTo({ duration: 240, curve: Curve.EaseIn }, () => {
      this.panelOpacity = 0; this.panelY = 200
    })
    setTimeout(() => { this.panelVisible = false }, 250)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {

      Scroll() {
        Column({ space: 0 }) {

          // ══ 图1风格：深绿大头帖 Hero ══════════════
          Column() {
            // 顶部细节行
            Row() {
              Text('CAMPUS GREEN')
                .fontSize(10)
                .fontColor('#A5C87A')
                .letterSpacing(3.5)
                .fontWeight(FontWeight.Medium)
              Blank()
              Text('PLANT CARE')
                .fontSize(10)
                .fontColor('#A5C87A88')
                .letterSpacing(2)
            }
            .width('100%')

            Blank().height(16)

            Row() {
              Column({ space: 6 }) {
                Text(this.userName
                  ? `HI, ${this.userName.toUpperCase()}. 👋`
                  : 'HI, PLANT PARENT.')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .letterSpacing(0.6)
                Text('记录植物成长，让校园更清新')
                  .fontSize(13)
                  .fontColor('#C8E8B8')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Text(this.userName ? this.userName.charAt(0).toUpperCase() : '🌿')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2D5A1B')
              }
              .width(46)
              .height(46)
              .borderRadius(999)
              .backgroundColor('#FFFFFFCC')
              .justifyContent(FlexAlign.Center)
              .shadow({ radius: 10, color: '#00000030', offsetY: 4 })
            .scale({ x: this.pressedKey === 'av' ? 0.9 : 1, y: this.pressedKey === 'av' ? 0.9 : 1 })
            .onClick(() => { this.onAvatarTap() })
              .onTouch((e: TouchEvent) => {
                if (e.type === TouchType.Down) this.pressDown('av')
                else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
              })
            }
            .width('100%')

            Blank().height(22)

            // 图1风格：叶片装饰行（三色块）
            Row({ space: 10 }) {
              Column() { Text('🌵').fontSize(28) }
                .width(72).height(72).borderRadius(20)
                .backgroundColor('#3D7020').justifyContent(FlexAlign.Center)
              Column() { Text('🌿').fontSize(34) }
                .width(96).height(72).borderRadius(20)
                .backgroundColor('#4A8A28').justifyContent(FlexAlign.Center)
              Column() { Text('🌸').fontSize(24) }
                .width(64).height(72).borderRadius(20)
                .backgroundColor('#5A9E30').justifyContent(FlexAlign.Center)
              Blank()
              Column() { Text('🪴').fontSize(30) }
                .width(78).height(72).borderRadius(20)
                .backgroundColor('#3D7020').justifyContent(FlexAlign.Center)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 22, right: 22, top: 28, bottom: 26 })
          .backgroundColor('#2D5A1B')

          // ══ Bento Grid 主内容区 ══════════════════
          Column({ space: 14 }) {

            // 天气卡（毛玻璃 + 暖米色）
            Row() {
              Column({ space: 5 }) {
                Text('TODAY · 今日天气')
                  .fontSize(10)
                  .fontColor('#7A7A7A')
                  .letterSpacing(1.5)
                Text('24℃  多云  ·  适合通风养护')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Column({ space: 4 }) {
                Text('🌤️').fontSize(28)
                Text('宜养护').fontSize(10).fontColor('#4A7C2F')
              }
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ left: 18, right: 18, top: 14, bottom: 14 })
            .borderRadius(28)
            .backgroundColor('#EEEAE2CC')
            .border({ width: 1, color: '#D8D0C4', style: BorderStyle.Solid })
            .backgroundBlurStyle(BlurStyle.Thin)
            .opacity(this.contentOpacity)
            .translate({ y: this.contentY })

            // 大横幅：我的绿植
            Row({ space: 14 }) {
              Column({ space: 8 }) {
                Text(this.plantCount.toString())
                  .fontSize(54)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .lineHeight(58)
                Text('PLANTS')
                  .fontSize(11)
                  .fontColor('#C8E8B8')
                  .letterSpacing(3)
                Text(this.plantCount === 0 ? '去添加你的第一盆 →' : this.plantList[0].name)
                  .fontSize(12)
                  .fontColor('#A8D890')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 10 }) {
                Text('🌿').fontSize(58)
                Button('查看全部', { type: ButtonType.Normal })
                  .height(28)
                  .borderRadius(18)
                  .fontSize(11)
                  .fontColor('#2D5A1B')
                  .backgroundColor('#C8E8B8CC')
                  .padding({ left: 12, right: 12 })
                  .onClick(() => { this.go('pages/myPlant') })
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .padding({ left: 22, right: 16, top: 22, bottom: 22 })
            .borderRadius(28)
            .backgroundColor('#4A7C2F')
            .shadow({ radius: 18, color: '#2D5A1B28', offsetY: 8 })
            .scale({ x: this.pressedKey === 'pb' ? 0.98 : 1, y: this.pressedKey === 'pb' ? 0.98 : 1 })
            .opacity(this.pressedKey === 'pb' ? 0.84 : this.contentOpacity)
            .translate({ y: this.contentY })
            .onClick(() => { this.go('pages/myPlant') })
            .onTouch((e: TouchEvent) => {
              if (e.type === TouchType.Down) this.pressDown('pb')
              else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
            })

            // Bento 行：打卡竖卡 + 两小卡
            Row({ space: 12 }) {

              // 左：今日打卡
              Column({ space: 12 }) {
                Row() {
                  Column({ space: 3 }) {
                    Text('TODAY')
                      .fontSize(10)
                      .fontColor('#7A7A7A')
                      .letterSpacing(2.5)
                    Text('今日打卡')
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1A1A1A')
                    Text(this.todayChecked ? '已完成 ✓' : '待完成')
                      .fontSize(11)
                      .fontColor(this.todayChecked ? '#4A7C2F' : '#C0832A')
                  }
                  .alignItems(HorizontalAlign.Start)
                  Blank()
                  Text(this.todayChecked ? '✅' : '⏰').fontSize(24)
                }
                .width('100%')

                Column({ space: 6 }) {
                  Text('轻养护节奏')
                    .fontSize(10)
                    .fontColor('#8A8A8A')
                    .letterSpacing(1)
                    .alignSelf(ItemAlign.Start)
                  Row({ space: 4 }) {
                    Column().width(9).height(9).borderRadius(5).backgroundColor('#4A7C2F')
                    Column().width(9).height(9).borderRadius(5).backgroundColor('#4A7C2F')
                    Column().width(9).height(9).borderRadius(5).backgroundColor('#4A7C2F')
                    Column().width(9).height(9).borderRadius(5).backgroundColor('#D8D0C4')
                    Column().width(9).height(9).borderRadius(5).backgroundColor('#D8D0C4')
                    Text('💧').fontSize(12)
                  }
                }

                Blank()

                Button(this.todayChecked ? '今日已打卡' : '完成打卡', { type: ButtonType.Normal })
                  .width('100%')
                  .height(42)
                  .borderRadius(24)
                  .fontSize(13)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(this.todayChecked ? '#8AB875' : '#4A7C2F')
                  .shadow({
                    radius: this.todayChecked ? 4 : 12,
                    color: this.todayChecked ? '#8AB87520' : '#2D5A1B35',
                    offsetY: 4
                  })
                  .scale({
                    x: this.pressedKey === 'ci' ? 0.93 : (!this.todayChecked && this.checkInPulse ? 1.04 : 1),
                    y: this.pressedKey === 'ci' ? 0.93 : (!this.todayChecked && this.checkInPulse ? 1.04 : 1)
                  })
                  .onClick(() => { this.doCheckIn() })
                  .onTouch((e: TouchEvent) => {
                    if (e.type === TouchType.Down) this.pressDown('ci')
                    else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                  })
              }
              .layoutWeight(1)
              .height(220)
              .padding(16)
              .borderRadius(28)
              .backgroundColor('#FFFDF8')
              .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
              .shadow({ radius: 14, color: '#00000010', offsetY: 5 })

              // 右：两个小卡
              Column({ space: 12 }) {
                Column({ space: 7 }) {
                  Text('📖').fontSize(28)
                  Text('PLANT WIKI')
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1A1A1A')
                    .letterSpacing(1.5)
                  Text('12 条知识')
                    .fontSize(10)
                    .fontColor('#7A7A7A')
                }
                .layoutWeight(1).width('100%').borderRadius(24)
                .backgroundColor('#EEF6EA')
                .border({ width: 1, color: '#C8DCBE', style: BorderStyle.Solid })
                .justifyContent(FlexAlign.Center)
                .scale({ x: this.pressedKey === 'wk' ? 0.93 : 1, y: this.pressedKey === 'wk' ? 0.93 : 1 })
                .opacity(this.pressedKey === 'wk' ? 0.7 : 1)
                .onClick(() => { this.go('pages/tip') })
                .onTouch((e: TouchEvent) => {
                  if (e.type === TouchType.Down) this.pressDown('wk')
                  else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                })

                Column({ space: 7 }) {
                  Text('💡').fontSize(28)
                  Text('TODAY')
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1A1A1A')
                    .letterSpacing(1.5)
                  Text('点击查看提醒')
                    .fontSize(10)
                    .fontColor('#7A7A7A')
                }
                .layoutWeight(1).width('100%').borderRadius(24)
                .backgroundColor('#FFF8EE')
                .border({ width: 1, color: '#EFE0BC', style: BorderStyle.Solid })
                .justifyContent(FlexAlign.Center)
                .scale({ x: this.pressedKey === 'rm' ? 0.93 : 1, y: this.pressedKey === 'rm' ? 0.93 : 1 })
                .opacity(this.pressedKey === 'rm' ? 0.7 : 1)
                .onClick(() => { this.openPanel() })
                .onTouch((e: TouchEvent) => {
                  if (e.type === TouchType.Down) this.pressDown('rm')
                  else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
                })
              }
              .layoutWeight(1)
              .height(220)
            }
            .width('100%')
            .opacity(this.contentOpacity)
            .translate({ y: this.contentY })

            // 新增绿植 虚线卡
            Row({ space: 14 }) {
              Column({ space: 5 }) {
                Text('NEW PLANT')
                  .fontSize(10)
                  .fontColor('#4A7C2F')
                  .letterSpacing(2.5)
                Text('给新植物建一份档案')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                Text('记录品种、浇水频率和光照偏好')
                  .fontSize(12)
                  .fontColor('#8A8A8A')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Text('＋')
                  .fontSize(28)
                  .fontColor('#4A7C2F')
                  .fontWeight(FontWeight.Bold)
              }
              .width(52).height(52)
              .borderRadius(999)
              .backgroundColor('#D8F0D0')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding({ left: 20, right: 16, top: 16, bottom: 16 })
            .borderRadius(28)
            .backgroundColor('#F7F4EF')
            .border({ width: 1.5, color: '#B8D4A8', style: BorderStyle.Dashed })
            .scale({ x: this.pressedKey === 'ap' ? 0.97 : 1, y: this.pressedKey === 'ap' ? 0.97 : 1 })
            .opacity(this.pressedKey === 'ap' ? 0.74 : this.contentOpacity)
            .translate({ y: this.contentY })
            .onClick(() => { this.go('pages/addPlant') })
            .onTouch((e: TouchEvent) => {
              if (e.type === TouchType.Down) this.pressDown('ap')
              else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressUp()
            })

            // 今日植物推荐
            Column({ space: 13 }) {
              Row() {
                Column({ space: 2 }) {
                  Text('DAILY PICK')
                    .fontSize(10)
                    .fontColor('#8A8A8A')
                    .letterSpacing(2.5)
                  Text('今日植物推荐')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1A1A1A')
                }
                .alignItems(HorizontalAlign.Start)
                Blank()
                Text('适合校园桌面')
                  .fontSize(11)
                  .fontColor('#8A8A8A')
              }
              .width('100%')

              Row({ space: 16 }) {
                Text(this.recommendPlants[this.recommendIndex].icon)
                  .fontSize(54)
                Column({ space: 9 }) {
                  Text(this.recommendPlants[this.recommendIndex].name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1A1A1A')
                  Text(this.recommendPlants[this.recommendIndex].reason)
                    .fontSize(13)
                    .fontColor('#6A6A6A')
                    .lineHeight(20)
                  Row({ space: 8 }) {
                    Text(`💧 ${this.recommendPlants[this.recommendIndex].water}`)
                      .fontSize(11).fontColor('#2D5A1B')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor('#C8E8C0').borderRadius(14)
                    Text(`☀️ ${this.recommendPlants[this.recommendIndex].light}`)
                      .fontSize(11).fontColor('#8A5C20')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor('#FDEFC8').borderRadius(14)
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
            }
            .width('100%')
            .padding(20)
            .borderRadius(28)
            .backgroundColor('#FFFDF8')
            .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
            .shadow({ radius: 14, color: '#00000010', offsetY: 5 })
            .opacity(this.contentOpacity)
            .translate({ y: this.contentY })

            // 最近记录
            Column({ space: 12 }) {
              Row() {
                Column({ space: 2 }) {
                  Text('RECENT')
                    .fontSize(10)
                    .fontColor('#8A8A8A')
                    .letterSpacing(2.5)
                  Text('最近记录')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1A1A1A')
                }
                .alignItems(HorizontalAlign.Start)
                Blank()
                if (this.plantCount > 0) {
                  Text(`共 ${this.plantCount} 盆`)
                    .fontSize(11).fontColor('#4A7C2F')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor('#D8F0D0').borderRadius(12)
                }
              }
              .width('100%')

              if (this.plantList.length === 0) {
                Column({ space: 8 }) {
                  Text('🪴').fontSize(46).opacity(0.5)
                  Text('还没有绿植记录')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#3C3A35')
                  Text('点击上方虚线卡片开始记录')
                    .fontSize(12)
                    .fontColor('#AAAAAA')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .padding({ top: 16, bottom: 20 })
              } else {
                ForEach(this.plantList.slice(0, 3), (item: PlantItem, index: number) => {
                  Column() {
                    Row({ space: 12 }) {
                      Text('🌿').fontSize(22)
                      Column({ space: 3 }) {
                        Text(item.name)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#1A1A1A')
                        Text(`${item.type} · ${item.waterDays}天/次 · ${item.date}`)
                          .fontSize(11)
                          .fontColor('#8A8A8A')
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      Text('›').fontSize(18).fontColor('#C0C0C0')
                    }
                    .width('100%')
                    .padding({ top: 12, bottom: 12 })

                    if (index < this.plantList.slice(0, 3).length - 1) {
                      Divider().color('#EEE8E0').width('100%')
                    }
                  }
                })
              }
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 18, bottom: 14 })
            .borderRadius(28)
            .backgroundColor('#FFFDF8')
            .shadow({ radius: 14, color: '#00000010', offsetY: 5 })
            .opacity(this.contentOpacity)
            .translate({ y: this.contentY })

            Blank().height(28)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#F7F4EF')

      // ══ 今日提醒浮层面板 ══════════════════════
      if (this.panelVisible) {
        Column({ space: 18 }) {
          Row() {
            Column({ space: 2 }) {
              Text('TODAY')
                .fontSize(10)
                .fontColor('#8A8A8A')
                .letterSpacing(2.5)
              Text('今日养护提醒')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('✕')
              .fontSize(20)
              .fontColor('#AAAAAA')
              .onClick(() => { this.closePanel() })
          }
          .width('100%')

          Text(this.dailyReminder)
            .fontSize(14)
            .fontColor('#3C3A35')
            .lineHeight(24)
            .width('100%')

          Row({ space: 12 }) {
            Button('换一条', { type: ButtonType.Normal })
              .layoutWeight(1).height(46).borderRadius(26)
              .fontSize(14).fontColor('#4A7C2F')
              .backgroundColor('#D8F0D0')
              .onClick(() => {
                const idx = Math.floor(Math.random() * this.reminders.length)
                this.dailyReminder = this.reminders[idx]
              })
            Button(this.todayChecked ? '已打卡 ✓' : '完成打卡', { type: ButtonType.Normal })
              .layoutWeight(1).height(46).borderRadius(26)
              .fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
              .backgroundColor(this.todayChecked ? '#8AB875' : '#4A7C2F')
              .onClick(() => { this.doCheckIn(); this.closePanel() })
          }
          .width('100%')
        }
        .width('88%')
        .padding({ left: 24, right: 24, top: 22, bottom: 28 })
        .borderRadius(32)
        .backgroundColor('#FFFDF8')
        .border({ width: 1, color: '#E4DDD0', style: BorderStyle.Solid })
        .shadow({ radius: 32, color: '#00000028', offsetY: 16 })
        .opacity(this.panelOpacity)
        .translate({ y: this.panelY })
        .margin({ bottom: 32, right: '6%' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct HomePreview {
  build() { HomePage() }
}
