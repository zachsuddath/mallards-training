import { createContext, useContext, useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'

const DEFAULTS = {
  company_name: 'Mallards',
  tagline: 'Training Portal',
  primary_color: '#1B3A6B',
  accent_color: '#C9A227',
  logo_url: '',
}

const SettingsContext = createContext({ settings: DEFAULTS, updateSetting: async () => {}, loaded: false })

function applyColors(primary, accent) {
  document.documentElement.style.setProperty('--navy', primary || DEFAULTS.primary_color)
  document.documentElement.style.setProperty('--navy-dark', shadeColor(primary || DEFAULTS.primary_color, -20))
  document.documentElement.style.setProperty('--accent', accent || DEFAULTS.accent_color)
}

function shadeColor(hex, percent) {
  try {
    const num = parseInt(hex.replace('#', ''), 16)
    const r = Math.min(255, Math.max(0, (num >> 16) + percent * 2.55))
    const g = Math.min(255, Math.max(0, ((num >> 8) & 0xff) + percent * 2.55))
    const b = Math.min(255, Math.max(0, (num & 0xff) + percent * 2.55))
    return `#${Math.round(r).toString(16).padStart(2,'0')}${Math.round(g).toString(16).padStart(2,'0')}${Math.round(b).toString(16).padStart(2,'0')}`
  } catch { return hex }
}

export function SettingsProvider({ children }) {
  const [settings, setSettings] = useState(DEFAULTS)
  const [loaded, setLoaded] = useState(false)

  useEffect(() => { loadSettings() }, [])

  async function loadSettings() {
    try {
      const { data } = await supabase.from('settings').select('key, value')
      if (data?.length) {
        const merged = { ...DEFAULTS }
        data.forEach(row => { if (row.key in DEFAULTS) merged[row.key] = row.value || DEFAULTS[row.key] })
        setSettings(merged)
        applyColors(merged.primary_color, merged.accent_color)
      }
    } catch {}
    setLoaded(true)
  }

  async function updateSetting(key, value) {
    await supabase.from('settings').upsert({ key, value }, { onConflict: 'key' })
    setSettings(s => {
      const next = { ...s, [key]: value }
      applyColors(next.primary_color, next.accent_color)
      return next
    })
  }

  async function uploadLogo(file) {
    const ext = file.name.split('.').pop()
    const path = `logo/brand-logo.${ext}`
    await supabase.storage.from('training-images').remove([path])
    const { error } = await supabase.storage.from('training-images').upload(path, file, { upsert: true })
    if (error) throw error
    const { data: { publicUrl } } = supabase.storage.from('training-images').getPublicUrl(path)
    await updateSetting('logo_url', publicUrl)
    return publicUrl
  }

  return (
    <SettingsContext.Provider value={{ settings, updateSetting, uploadLogo, loaded }}>
      {children}
    </SettingsContext.Provider>
  )
}

export function useSettings() {
  return useContext(SettingsContext)
}
