import { createClient } from '@supabase/supabase-js'

const configuredUrl = import.meta.env.VITE_SUPABASE_URL
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

function normalizeSupabaseUrl(value) {
  if (!value) return ''
  const parsed = new URL(value.trim())
  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new Error('VITE_SUPABASE_URL harus menggunakan URL http atau https.')
  }
  parsed.pathname = parsed.pathname.replace(/(?:\/rest\/v1)+\/?$/i, '').replace(/\/+$/, '')
  return parsed.toString().replace(/\/$/, '')
}

const url = normalizeSupabaseUrl(configuredUrl)
export const supabaseConfigured = Boolean(url && anonKey)
export const supabase = supabaseConfigured
  ? createClient(url, anonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    })
  : null

export function requireSupabase() {
  if (!supabase) {
    throw new Error('Supabase belum dikonfigurasi. Isi VITE_SUPABASE_URL dan VITE_SUPABASE_ANON_KEY.')
  }
  return supabase
}
