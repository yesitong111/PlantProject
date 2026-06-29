import preferences from '@ohos.data.preferences'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { PlantItem, UserRecord, ReminderItem, CheckInRecord } from './PlantTypes'

const TAG = 'PlantDataHelper'
const DOMAIN = 0x0001

export class DataHelper {
  static async getPref(name: string, ctx: common.Context): Promise<preferences.Preferences | null> {
    try {
      return await preferences.getPreferences(ctx, name)
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'getPref failed: %{public}s', name)
      return null
    }
  }

  static genId(): string {
    const now = Date.now()
    const rnd = Math.floor(Math.random() * 100000)
    return `${now}-${rnd}`
  }

  static loadPlants(pref: preferences.Preferences): Array<PlantItem> {
    try {
      return JSON.parse(pref.getSync('plantList', '[]') as string) as Array<PlantItem>
    } catch (e) {
      return []
    }
  }

  static savePlants(pref: preferences.Preferences, list: Array<PlantItem>): void {
    try {
      pref.putSync('plantList', JSON.stringify(list))
      pref.flush().catch(() => {})
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'savePlants failed')
    }
  }

  static loadUsers(pref: preferences.Preferences): Array<UserRecord> {
    try {
      return JSON.parse(pref.getSync('registeredUsers', '[]') as string) as Array<UserRecord>
    } catch (e) {
      return []
    }
  }

  static saveUsers(pref: preferences.Preferences, list: Array<UserRecord>): void {
    try {
      pref.putSync('registeredUsers', JSON.stringify(list))
      pref.flush().catch(() => {})
    } catch (e) {}
  }

  static loadReminders(pref: preferences.Preferences): Array<ReminderItem> {
    try {
      return JSON.parse(pref.getSync('reminderList', '[]') as string) as Array<ReminderItem>
    } catch (e) {
      return []
    }
  }

  static saveReminders(pref: preferences.Preferences, list: Array<ReminderItem>): void {
    try {
      pref.putSync('reminderList', JSON.stringify(list))
      pref.flush().catch(() => {})
    } catch (e) {}
  }

  static loadCheckIns(pref: preferences.Preferences): Array<CheckInRecord> {
    try {
      return JSON.parse(pref.getSync('checkInHistory', '[]') as string) as Array<CheckInRecord>
    } catch (e) {
      return []
    }
  }

  static addCheckIn(pref: preferences.Preferences, date: string, note: string): void {
    const list = DataHelper.loadCheckIns(pref)
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].date === date) {
        list[i].note = note
        found = true
        break
      }
    }
    if (!found) {
      list.unshift({ date: date, note: note })
    }
    try {
      pref.putSync('checkInHistory', JSON.stringify(list))
      pref.putSync('plantCheckIn', date)
      pref.putSync('todayChecked', date)
      pref.flush().catch(() => {})
    } catch (e) {}
  }
}
