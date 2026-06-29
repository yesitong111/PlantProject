import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'
import { DataHelper } from '../common/DataHelper'
import { ReminderItem } from '../common/PlantTypes'

@Entry
@Component
struct ReminderPage {
  @State reminders: Array<ReminderItem> = []
  @State newTitle: string = ''
  @State newContent: string = ''
  @State contentOpacity: number = 0
  @State pressedKey: string = ''
  prefDB: preferences.Preferences | null = null

  aboutToAppear() {
    animateTo({ duration: 450, curve: Curve.EaseOut }, () => { this.contentOpacity = 1 })
    this.loadData()
  }

  onPageShow() { this.loadData() }

  loadData() {
    DataHelper.getPref('plantDB', getContext(this)).then((pref: preferences.Preferences | null) => {
      this.prefDB = pref
      if (pref) {
        const list = DataHelper.loadReminders(pref)
        if (list.length === 0) {
          this.reminders = [
            { id: '1', title: '检查土壤湿度', content: '表层干了再浇水，避免积水烂根。', enabled: true, time: '09:00' },
            { id: '2', title: '叶片除尘', content: '用湿布轻擦叶片，帮助光合作用。', enabled: true, time: '18:00' },
            { id: '3', title: '转动花盆', content: '让植物均匀接受散射光。', enabled: false, time: '12:00' }
          ]
          DataHelper.saveReminders(pref, this.reminders)
        } else {
          this.reminders = list
        }
      }
    })
  }

  addReminder() {
    if (this.newTitle.trim().length === 0) {
      try { promptAction.showToast({ message: '请输入提醒标题' }) } catch (e) {}
      return
    }
    const item: ReminderItem = {
      id: DataHelper.genId(),
      title: this.newTitle.trim(),
      content: this.newContent.trim() || '记得完成养护任务。',
      enabled: true,
      time: '09:00'
    }
    this.reminders = [item, ...this.reminders]
    if (this.prefDB) DataHelper.saveReminders(this.prefDB, this.reminders)
    this.newTitle = ''
    this.newContent = ''
    try { promptAction.showToast({ message: '提醒已添加' }) } catch (e) {}
  }

  toggleItem(idx: number) {
    this.reminders[idx].enabled = !this.reminders[idx].enabled
    this.reminders = [...this.reminders]
    if (this.prefDB) DataHelper.saveReminders(this.prefDB, this.reminders)
  }

  deleteItem(idx: number) {
    AlertDialog.show({
      title: '删除提醒',
      message: `确定删除「${this.reminders[idx].title}」吗？`,
      primaryButton: {
        value: '删除', fontColor: '#E03030',
        action: () => {
          const nl: Array<ReminderItem> = []
          for (let i = 0; i < this.reminders.length; i++) {
            if (i !== idx) nl.push(this.reminders[i])
          }
          this.reminders = nl
          if (this.prefDB) DataHelper.saveReminders(this.prefDB, this.reminders)
        }
      },
      secondaryButton: { value: '取消', fontColor: '#4A7C2F', action: () => {} }
    })
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
            Text('REMINDER').fontSize(10).fontColor('#A5C87A').letterSpacing(3)
            Text('养护提醒').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          Blank()
          Row().width(60)
        }.width('100%')
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 18 }).backgroundColor('#2D5A1B')

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 12 }) {
            Text('新增提醒').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            TextInput({ text: this.newTitle, placeholder: '提醒标题，如：浇水提醒' })
              .width('100%').height(44).borderRadius(16).fontSize(14)
              .backgroundColor('#FAFAF8').padding({ left: 14, right: 14 })
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .onChange((v: string) => { this.newTitle = v })
            TextArea({ text: this.newContent, placeholder: '提醒内容（选填）' })
              .width('100%').height(72).borderRadius(16).fontSize(13)
              .backgroundColor('#FAFAF8').padding(12)
              .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
              .onChange((v: string) => { this.newContent = v })
            Button('+ 添加提醒', { type: ButtonType.Normal })
              .width('100%').height(42).borderRadius(21)
              .fontSize(14).fontColor('#FFFFFF').backgroundColor('#4A7C2F')
              .onClick(() => { this.addReminder() })
          }.width('100%').padding(18).borderRadius(28).backgroundColor('#FFFDF8')
          .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })

          Text(`共 ${this.reminders.length} 条提醒`)
            .fontSize(12).fontColor('#8A8A8A').width('100%')

          List({ space: 10 }) {
            ForEach(this.reminders, (item: ReminderItem, idx: number) => {
              ListItem() {
                Row({ space: 12 }) {
                  Toggle({ type: ToggleType.Switch, isOn: item.enabled })
                    .selectedColor('#4A7C2F')
                    .onChange((on: boolean) => {
                      this.reminders[idx].enabled = on
                      this.reminders = [...this.reminders]
                      if (this.prefDB) DataHelper.saveReminders(this.prefDB, this.reminders)
                    })
                  Column({ space: 4 }) {
                    Text(item.title).fontSize(15).fontWeight(FontWeight.Medium)
                      .fontColor(item.enabled ? '#1A1A1A' : '#BBBBBB')
                    Text(item.content).fontSize(12).fontColor('#8A8A8A').maxLines(2)
                    Text(`⏰ ${item.time}`).fontSize(11).fontColor('#4A7C2F')
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                  Text('×').fontSize(20).fontColor('#CCCCCC')
                    .onClick(() => { this.deleteItem(idx) })
                }.width('100%').padding(14).borderRadius(22)
                .backgroundColor('#FFFDF8')
                .border({ width: 1, color: '#E8E0D4', style: BorderStyle.Solid })
                .opacity(item.enabled ? 1 : 0.65)
                .scale({ x: this.pressedKey === item.id ? 0.98 : 1, y: this.pressedKey === item.id ? 0.98 : 1 })
                .onTouch((e: TouchEvent) => {
                  if (e.type === TouchType.Down) this.pressedKey = item.id
                  else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressedKey = ''
                })
              }
            })
          }.width('100%').divider({ strokeWidth: 0 })

          Blank().height(24)
        }.width('92%').opacity(this.contentOpacity)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F7F4EF')
  }
}

@Component
@Preview
struct ReminderPreview {
  build() { ReminderPage() }
}
