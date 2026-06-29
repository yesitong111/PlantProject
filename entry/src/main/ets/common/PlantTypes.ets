export interface PlantItem {
  name: string
  type: string
  waterDays: string
  sunlight: string
  notes: string
  date: string
}

export interface UserRecord {
  user: string
  password: string
  nickname: string
  registerDate: string
}

export interface ReminderItem {
  id: string
  title: string
  content: string
  enabled: boolean
  time: string
}

export interface CheckInRecord {
  date: string
  note: string
}

export function getPlantIcon(t: string): string {
  const m: Record<string, string> = {
    '多肉': '🪴', '绿萝': '🌿', '月季': '🌹', '富贵竹': '🎋',
    '仙人掌': '🌵', '吊兰': '🌱', '龟背竹': '🍃', '文竹': '🎍', '其他': '🌻'
  }
  return m[t] || '🪴'
}

export function getPlantBg(t: string): string {
  const m: Record<string, string> = {
    '多肉': '#FFF8E6', '绿萝': '#EEF6EA', '月季': '#FCE8F2',
    '富贵竹': '#EFF8DC', '仙人掌': '#E6F4F0', '吊兰': '#E8F4F8',
    '龟背竹': '#EEF6EA', '文竹': '#F2F8E8', '其他': '#F4F4F4'
  }
  return m[t] || '#F4F4F4'
}

export function getTodayKey(): string {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
}

export function formatDateStr(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}
