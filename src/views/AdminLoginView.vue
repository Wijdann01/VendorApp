<script setup>
import { ref } from 'vue'
import { ArrowLeft, ArrowRight, LockKeyhole } from '@lucide/vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase, supabaseConfigured } from '../lib/supabase'

const route = useRoute()
const router = useRouter()
const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)
async function login() {
  error.value = ''
  if (!email.value || !password.value) {
    error.value = 'Masukkan email dan kata sandi.'
    return
  }
  if (!supabaseConfigured) {
    error.value = 'Supabase belum dikonfigurasi. Salin .env.example menjadi .env.local, lalu isi URL dan anon key proyek Anda.'
    return
  }
  loading.value = true
  try {
    const { data, error: authError } = await supabase.auth.signInWithPassword({ email: email.value.trim(), password: password.value })
    if (authError) throw authError
    const { data: profile, error: profileError } = await supabase.from('profiles').select('role').eq('id', data.user.id).single()
    if (profileError) throw profileError
    if (!['super_admin', 'editor'].includes(profile.role)) {
      await supabase.auth.signOut()
      throw new Error('Akun Anda belum memiliki peran admin yang sesuai.')
    }
    await router.replace(typeof route.query.redirect === 'string' ? route.query.redirect : '/admin')
  } catch (cause) {
    error.value = cause.message || 'Tidak dapat masuk. Periksa koneksi dan kredensial Anda.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <main class="admin-login-page"><RouterLink class="admin-back" to="/"><ArrowLeft :size="15" /> Kembali ke situs</RouterLink><div class="login-card"><RouterLink to="/" class="brand"><img class="brand-logo" src="/AnJ.svg" alt=""><span class="brand-name">abadi nan jaya<small>ADMIN STUDIO</small></span></RouterLink><div class="login-heading"><span class="login-icon"><LockKeyhole :size="19" /></span><span class="eyebrow">RUANG PENGELOLA</span><h1>Selamat datang<br>kembali.</h1><p>Masuk untuk mengelola situs Abadi nan Jaya.</p></div>
    <p v-if="route.query.setup === 'supabase'" class="login-alert">Lengkapi konfigurasi Supabase terlebih dahulu untuk mengaktifkan login dan data permanen.</p><p v-if="route.query.error" class="login-alert">{{ route.query.error }}</p><form @submit.prevent="login"><label class="field"><span>Email</span><input v-model="email" type="email" autocomplete="username" placeholder="nama@email.com" required></label><label class="field"><span>Kata sandi</span><input v-model="password" type="password" autocomplete="current-password" placeholder="Masukkan kata sandi" required></label><p v-if="error" class="field-error login-error">{{ error }}</p><button class="button button-dark login-submit" :disabled="loading">{{ loading ? 'Memeriksa...' : 'Masuk ke dashboard' }} <ArrowRight :size="15" /></button></form><RouterLink v-if="!supabaseConfigured" class="demo-login" to="/admin?demo=1">Lihat preview dashboard demo <ArrowRight :size="14" /></RouterLink><small class="login-footnote">Akses khusus tim Abadi nan Jaya.</small></div></main>
</template>
