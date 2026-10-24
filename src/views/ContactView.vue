<script setup>
import { computed, nextTick, onMounted, ref } from 'vue'
import { ArrowRight, Clock3, Mail, MapPin, MessageCircle, Phone } from '@lucide/vue'
import { useRoute, useRouter } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { useToast } from '../composables/useToast'
import { supabase, supabaseConfigured } from '../lib/supabase'
import { toLocalIndonesianPhone } from '../lib/phone'

const site = useSiteStore()
const route = useRoute()
const router = useRouter()
const { notify } = useToast()
const form = ref({ name: '', email: '', phone: '', event_type: '', event_date: '', guest_count: '', message: '' })
const errors = ref({})
const submitting = ref(false)
const validationAttempted = ref(false)
const today = new Date()
const minimumDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
onMounted(() => {
  if (typeof route.query.package === 'string') {
    form.value.message = `Saya tertarik dengan paket ${route.query.package}. Mohon kirimkan informasi lebih lanjut.`
  }
})
const mapLocation = computed(() => site.settings.map_location || 'Tasikmalaya, Jawa Barat')
const mapsUrl = computed(() => `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(mapLocation.value)}`)
const mapEmbedUrl = computed(() => `https://www.google.com/maps?q=${encodeURIComponent(mapLocation.value)}&output=embed`)
function getValidationErrors() {
  const result = {}
  if (form.value.name.trim().length < 2 || form.value.name.trim().length > 120) result.name = 'Nama harus berisi 2–120 karakter.'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email.trim()) || form.value.email.trim().length > 254) result.email = 'Masukkan alamat email yang valid.'
  if (!/^08\d{8,11}$/.test(toLocalIndonesianPhone(form.value.phone))) result.phone = 'Masukkan nomor WhatsApp Indonesia yang diawali 08.'
  if (!form.value.event_type) result.event_type = 'Pilih jenis acara.'
  if (form.value.event_date && form.value.event_date < minimumDate) result.event_date = 'Tanggal acara tidak boleh di masa lalu.'
  if (form.value.guest_count && (!Number.isSafeInteger(Number(form.value.guest_count)) || Number(form.value.guest_count) < 1 || Number(form.value.guest_count) > 100000)) result.guest_count = 'Jumlah tamu harus berupa angka bulat antara 1–100.000.'
  if (form.value.message.trim().length < 15 || form.value.message.trim().length > 5000) result.message = 'Pesan harus berisi 15–5.000 karakter.'
  return result
}

function validate() {
  validationAttempted.value = true
  const result = getValidationErrors()
  errors.value = result
  return Object.keys(result).length === 0
}

function validateField(field) {
  const result = getValidationErrors()
  if (result[field]) errors.value[field] = result[field]
  else delete errors.value[field]
}

function normalizePhone() {
  form.value.phone = toLocalIndonesianPhone(form.value.phone)
  validateField('phone')
}
async function submitInquiry() {
  if (submitting.value) return
  normalizePhone()
  if (!validate()) {
    await nextTick()
    document.querySelector('.contact-form [aria-invalid="true"]')?.focus()
    return
  }
  submitting.value = true
  try {
    if (supabaseConfigured) {
      const { error } = await supabase.from('inquiries').insert({
        name: form.value.name.trim(), email: form.value.email.trim().toLowerCase(),
        phone: toLocalIndonesianPhone(form.value.phone), event_type: form.value.event_type,
        event_date: form.value.event_date || null,
        guest_count: form.value.guest_count ? Number(form.value.guest_count) : null,
        message: `${route.query.package ? `Paket pilihan: ${route.query.package}\n\n` : ''}${form.value.message.trim()}`,
      })
      if (error) throw error
    } else {
      const saved = JSON.parse(localStorage.getItem('anaj-demo-inquiries') || '[]')
      saved.push({ ...form.value, phone: toLocalIndonesianPhone(form.value.phone), id: Date.now(), status: 'baru', created_at: new Date().toISOString() })
      localStorage.setItem('anaj-demo-inquiries', JSON.stringify(saved))
    }
    notify('Terima kasih! Cerita Anda sudah kami terima.')
    form.value = { name: '', email: '', phone: '', event_type: '', event_date: '', guest_count: '', message: '' }
    errors.value = {}
    validationAttempted.value = false
    await router.replace({ path: '/kontak' })
  } catch (error) {
    console.error('Inquiry submission failed:', error)
    notify(`Pesan belum terkirim. ${error.message || 'Silakan coba lagi.'}`, 'error')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="page-hero"><div class="container"><span class="eyebrow">MARI MULAI BERCERITA</span><h1>Rencana besar dimulai<br>dari percakapan.</h1><p>Ceritakan momen yang ingin Anda rayakan. Tim kami akan menghubungi Anda dalam satu hari kerja.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Kontak</span></div></div></section>
  <section class="section section-paper"><div class="container contact-layout">
    <form class="contact-form" novalidate @submit.prevent="submitInquiry"><span class="eyebrow">FORMULIR KONSULTASI</span><h2>Ceritakan rencana Anda.</h2><p class="form-intro">Isi beberapa hal berikut agar kami dapat mempersiapkan percakapan yang lebih bermakna.</p><div v-if="validationAttempted && Object.keys(errors).length" class="form-error-summary" role="alert"><strong>Periksa kembali isian berikut:</strong><span>{{ Object.keys(errors).length }} bagian perlu diperbaiki sebelum pesan dikirim.</span></div><div class="form-grid">
      <label class="field"><span>Nama lengkap *</span><input v-model="form.name" name="name" autocomplete="name" maxlength="120" placeholder="Nama Anda" :aria-invalid="Boolean(errors.name)" aria-describedby="contact-name-error" @blur="validateField('name')"><small v-if="errors.name" id="contact-name-error" class="field-error" role="alert">{{ errors.name }}</small></label>
      <label class="field"><span>Email *</span><input v-model="form.email" name="email" type="email" maxlength="254" autocomplete="email" placeholder="nama@email.com" :aria-invalid="Boolean(errors.email)" aria-describedby="contact-email-error" @blur="validateField('email')"><small v-if="errors.email" id="contact-email-error" class="field-error" role="alert">{{ errors.email }}</small></label>
      <label class="field"><span>Nomor WhatsApp *</span><input v-model="form.phone" name="phone" type="tel" inputmode="numeric" autocomplete="tel-national" maxlength="18" placeholder="0812 3456 78910" :aria-invalid="Boolean(errors.phone)" aria-describedby="contact-phone-error" @blur="normalizePhone"><small v-if="errors.phone" id="contact-phone-error" class="field-error" role="alert">{{ errors.phone }}</small></label>
      <label class="field"><span>Jenis acara *</span><select v-model="form.event_type" name="event_type" :aria-invalid="Boolean(errors.event_type)" aria-describedby="contact-event-type-error" @blur="validateField('event_type')"><option disabled value="">Pilih jenis acara</option><option v-for="category in site.categories" :key="category.id" :value="category.name">{{ category.name }}</option><option value="Lainnya">Lainnya</option></select><small v-if="errors.event_type" id="contact-event-type-error" class="field-error" role="alert">{{ errors.event_type }}</small></label>
      <label class="field"><span>Tanggal acara</span><input v-model="form.event_date" name="event_date" type="date" :min="minimumDate" :aria-invalid="Boolean(errors.event_date)" aria-describedby="contact-date-error" @blur="validateField('event_date')"><small v-if="errors.event_date" id="contact-date-error" class="field-error" role="alert">{{ errors.event_date }}</small></label>
      <label class="field"><span>Perkiraan jumlah tamu</span><input v-model="form.guest_count" name="guest_count" type="number" min="1" max="100000" step="1" inputmode="numeric" placeholder="Contoh: 150" :aria-invalid="Boolean(errors.guest_count)" aria-describedby="contact-guests-error" @blur="validateField('guest_count')"><small v-if="errors.guest_count" id="contact-guests-error" class="field-error" role="alert">{{ errors.guest_count }}</small></label>
      <label class="field field-wide"><span>Apa yang ingin Anda rayakan? *</span><textarea v-model="form.message" name="message" minlength="15" maxlength="5000" rows="4" placeholder="Ceritakan konsep, lokasi, atau hal yang penting untuk Anda..." :aria-invalid="Boolean(errors.message)" aria-describedby="contact-message-help contact-message-error" @blur="validateField('message')"></textarea><small id="contact-message-help" class="field-help">Minimal 15 karakter; maksimal 5.000 karakter.</small><small v-if="errors.message" id="contact-message-error" class="field-error" role="alert">{{ errors.message }}</small></label>
    </div><button class="button button-dark form-submit" type="submit" :disabled="submitting">{{ submitting ? 'Mengirim cerita...' : 'Kirim cerita Anda' }} <ArrowRight :size="16" /></button><small class="privacy-note">Informasi Anda hanya digunakan untuk menghubungi Anda terkait acara ini.</small></form>
    <aside class="contact-aside"><div class="contact-aside-main"><span class="eyebrow eyebrow-light">KAMI SIAP MENDENGARKAN</span><h3>Temukan orang<br>yang tepat untuk<br>membantu Anda.</h3><a class="contact-direct" :href="`https://wa.me/${site.settings.whatsapp || '6281234567890'}`" target="_blank" rel="noreferrer"><MessageCircle :size="18" /><span><small>Konsultasi umum</small><strong>WhatsApp kami</strong></span><ArrowRight :size="16" /></a></div><div class="contact-details"><div v-for="person in site.contacts" :key="person.id" class="contact-person"><span class="contact-avatar">{{ person.name.charAt(0) }}</span><div><strong>{{ person.name }}</strong><small>{{ person.title }} · {{ person.division }}</small><a :href="`https://wa.me/${person.phone}`"><Phone :size="12" /> Hubungi konsultan</a></div></div><div class="contact-info-row"><MapPin :size="16" /><span><strong>Lokasi</strong><a :href="mapsUrl" target="_blank" rel="noreferrer">{{ mapLocation }}</a></span></div><div class="contact-info-row"><Clock3 :size="16" /><span><strong>Jam operasional</strong><small>Senin – Sabtu · 09.00 – 17.00</small></span></div><div class="contact-info-row"><Mail :size="16" /><span><strong>Email</strong><a href="mailto:halo@abadinanjaya.id">halo@abadinanjaya.id</a></span></div></div></aside>
  </div></section>
  <section class="map-section"><iframe :title="`Peta lokasi Abadi nan Jaya di ${mapLocation}`" :src="mapEmbedUrl" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe></section>
</template>
