<script setup>
import { computed, ref } from 'vue'
import { onMounted } from 'vue'
import { ArrowRight, Clock3, Mail, MapPin, MessageCircle, Phone } from '@lucide/vue'
import { useRoute, useRouter } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { useToast } from '../composables/useToast'
import { supabase, supabaseConfigured } from '../lib/supabase'

const site = useSiteStore()
const route = useRoute()
const router = useRouter()
const { notify } = useToast()
const form = ref({ name: '', email: '', phone: '', event_type: '', event_date: '', guest_count: '', message: '' })
const errors = ref({})
const submitting = ref(false)
onMounted(() => {
  if (typeof route.query.package === 'string') {
    form.value.message = `Saya tertarik dengan paket ${route.query.package}. Mohon kirimkan informasi lebih lanjut.`
  }
})
const mapLocation = computed(() => site.settings.map_location || 'Tasikmalaya, Jawa Barat')
const mapsUrl = computed(() => `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(mapLocation.value)}`)
const mapEmbedUrl = computed(() => `https://www.google.com/maps?q=${encodeURIComponent(mapLocation.value)}&output=embed`)
function validate() {
  const result = {}
  if (form.value.name.trim().length < 2) result.name = 'Masukkan nama minimal 2 karakter.'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) result.email = 'Masukkan alamat email yang valid.'
  if (form.value.phone.replace(/\D/g, '').length < 9) result.phone = 'Masukkan nomor WhatsApp yang valid.'
  if (!form.value.event_type) result.event_type = 'Pilih jenis acara.'
  if (form.value.message.trim().length < 15) result.message = 'Ceritakan kebutuhan Anda minimal 15 karakter.'
  errors.value = result
  return Object.keys(result).length === 0
}
async function submitInquiry() {
  if (!validate() || submitting.value) return
  submitting.value = true
  try {
    if (supabaseConfigured) {
      const { error } = await supabase.from('inquiries').insert({
        name: form.value.name.trim(), email: form.value.email.trim().toLowerCase(),
        phone: form.value.phone.trim(), event_type: form.value.event_type,
        event_date: form.value.event_date || null,
        guest_count: form.value.guest_count ? Number(form.value.guest_count) : null,
        message: `${route.query.package ? `Paket pilihan: ${route.query.package}\n\n` : ''}${form.value.message.trim()}`,
      })
      if (error) throw error
    } else {
      const saved = JSON.parse(localStorage.getItem('anaj-demo-inquiries') || '[]')
      saved.push({ ...form.value, id: Date.now(), status: 'baru', created_at: new Date().toISOString() })
      localStorage.setItem('anaj-demo-inquiries', JSON.stringify(saved))
    }
    notify('Terima kasih! Cerita Anda sudah kami terima.')
    form.value = { name: '', email: '', phone: '', event_type: '', event_date: '', guest_count: '', message: '' }
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
    <form class="contact-form" novalidate @submit.prevent="submitInquiry"><span class="eyebrow">FORMULIR KONSULTASI</span><h2>Ceritakan rencana Anda.</h2><p class="form-intro">Isi beberapa hal berikut agar kami dapat mempersiapkan percakapan yang lebih bermakna.</p><div class="form-grid">
      <label class="field"><span>Nama lengkap *</span><input v-model="form.name" autocomplete="name" placeholder="Nama Anda" @blur="validate"><small v-if="errors.name" class="field-error">{{ errors.name }}</small></label>
      <label class="field"><span>Email *</span><input v-model="form.email" type="email" autocomplete="email" placeholder="nama@email.com" @blur="validate"><small v-if="errors.email" class="field-error">{{ errors.email }}</small></label>
      <label class="field"><span>Nomor WhatsApp *</span><input v-model="form.phone" type="tel" autocomplete="tel" placeholder="+62 812 3456 7890" @blur="validate"><small v-if="errors.phone" class="field-error">{{ errors.phone }}</small></label>
      <label class="field"><span>Jenis acara *</span><select v-model="form.event_type"><option disabled value="">Pilih jenis acara</option><option v-for="category in site.categories" :key="category.id" :value="category.name">{{ category.name }}</option><option value="Lainnya">Lainnya</option></select><small v-if="errors.event_type" class="field-error">{{ errors.event_type }}</small></label>
      <label class="field"><span>Tanggal acara</span><input v-model="form.event_date" type="date"></label>
      <label class="field"><span>Perkiraan jumlah tamu</span><input v-model="form.guest_count" type="number" min="1" placeholder="Contoh: 150"></label>
      <label class="field field-wide"><span>Apa yang ingin Anda rayakan? *</span><textarea v-model="form.message" rows="4" placeholder="Ceritakan konsep, lokasi, atau hal yang penting untuk Anda..." @blur="validate"></textarea><small v-if="errors.message" class="field-error">{{ errors.message }}</small></label>
    </div><button class="button button-dark form-submit" type="submit" :disabled="submitting">{{ submitting ? 'Mengirim cerita...' : 'Kirim cerita Anda' }} <ArrowRight :size="16" /></button><small class="privacy-note">Informasi Anda hanya digunakan untuk menghubungi Anda terkait acara ini.</small></form>
    <aside class="contact-aside"><div class="contact-aside-main"><span class="eyebrow eyebrow-light">KAMI SIAP MENDENGARKAN</span><h3>Temukan orang<br>yang tepat untuk<br>membantu Anda.</h3><a class="contact-direct" :href="`https://wa.me/${site.settings.whatsapp || '6281234567890'}`" target="_blank" rel="noreferrer"><MessageCircle :size="18" /><span><small>Konsultasi umum</small><strong>WhatsApp kami</strong></span><ArrowRight :size="16" /></a></div><div class="contact-details"><div v-for="person in site.contacts" :key="person.id" class="contact-person"><span class="contact-avatar">{{ person.name.charAt(0) }}</span><div><strong>{{ person.name }}</strong><small>{{ person.title }} · {{ person.division }}</small><a :href="`https://wa.me/${person.phone}`"><Phone :size="12" /> Hubungi konsultan</a></div></div><div class="contact-info-row"><MapPin :size="16" /><span><strong>Lokasi</strong><a :href="mapsUrl" target="_blank" rel="noreferrer">{{ mapLocation }}</a></span></div><div class="contact-info-row"><Clock3 :size="16" /><span><strong>Jam operasional</strong><small>Senin – Sabtu · 09.00 – 17.00</small></span></div><div class="contact-info-row"><Mail :size="16" /><span><strong>Email</strong><a href="mailto:halo@abadinanjaya.id">halo@abadinanjaya.id</a></span></div></div></aside>
  </div></section>
  <section class="map-section"><iframe :title="`Peta lokasi Abadi nan Jaya di ${mapLocation}`" :src="mapEmbedUrl" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe></section>
</template>
