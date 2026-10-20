<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { ArrowLeft, ArrowRight, CalendarDays, Check, ChevronDown, CircleAlert, Clock3, MapPin, Minus, Plus, Users } from '@lucide/vue'
import { useRoute, useRouter } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { useToast } from '../composables/useToast'
import { formatPrice } from '../data/demo'
import { supabase, supabaseConfigured } from '../lib/supabase'
import CurrencyInput from '../components/CurrencyInput.vue'

const route = useRoute()
const router = useRouter()
const site = useSiteStore()
const { notify } = useToast()
const form = ref({
  booking_type: 'organization',
  name: '',
  email: '',
  phone: '',
  organization_name: '',
  organization_type: '',
  contact_position: '',
  service_id: '',
  package_id: '',
  event_type: '',
  event_date: '',
  event_start_time: '',
  event_end_time: '',
  guest_count: '',
  event_location: '',
  event_city: '',
  venue_type: '',
  budget_min: '',
  budget_max: '',
  event_theme: '',
  message: '',
  special_requirements: '',
})
const selectedAddons = ref({})
const errors = ref({})
const submitting = ref(false)
const submitted = ref(false)
const selectedPackage = computed(() => site.packages.find((item) => item.id === form.value.package_id || item.slug === form.value.package_id))
const packageService = computed(() => site.services.find((service) => service.id === selectedPackage.value?.service_id))
const availableAddons = computed(() => selectedPackage.value?.addons || [])
const availableServices = computed(() => site.services.filter((service) => selectedEventType.value?.service_ids?.includes(service.id)))
const availablePackages = computed(() => site.packages.filter((item) =>
  selectedEventType.value
  && item.event_type_id === selectedEventType.value.id
  && availableServices.value.some((service) => service.id === item.service_id)
  && (!form.value.service_id || item.service_id === form.value.service_id)))
const availableEventTypes = computed(() => site.eventTypes.filter((eventType) => eventType.booking_type === form.value.booking_type && eventType.is_published))
const selectedEventType = computed(() => availableEventTypes.value.find((eventType) => eventType.name === form.value.event_type))
const selectedItems = computed(() => availableAddons.value
  .filter((addon) => selectedAddons.value[addon.id || addon.name])
  .map((addon) => ({ id: addon.id, name: addon.name, price: Number(addon.price || 0), quantity: Number(selectedAddons.value[addon.id || addon.name]) })))
const addonTotal = computed(() => selectedItems.value.reduce((sum, addon) => sum + addon.price * addon.quantity, 0))
const packagePrice = computed(() => Number(selectedPackage.value?.price || 0))
const estimatedTotal = computed(() => packagePrice.value + addonTotal.value)
const today = new Date()
const minimumDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`

onMounted(async () => {
  if (!site.loaded) {
    try {
      await site.loadPublicContent()
    } catch (error) {
      console.error('Booking content failed to load:', error)
    }
  }
  const packageSlug = typeof route.query.package === 'string' ? route.query.package : ''
  const initialPackage = site.packages.find((item) => item.slug === packageSlug)
  if (initialPackage) {
    const eventType = site.eventTypes.find((entry) => entry.id === initialPackage.event_type_id)
    if (eventType) {
      form.value.booking_type = eventType.booking_type
      form.value.event_type = eventType.name
    }
    choosePackage(initialPackage)
  }
})

watch(() => form.value.package_id, () => {
  selectedAddons.value = {}
})

function choosePackage(item) {
  const service = site.services.find((entry) => entry.id === item.service_id)
  const eventType = site.eventTypes.find((entry) => entry.id === item.event_type_id && entry.is_published)
  if (item.id && (!availableServices.value.some((entry) => entry.id === service?.id) || eventType?.name !== form.value.event_type || eventType?.booking_type !== form.value.booking_type)) {
    form.value.package_id = ''
    notify('Paket ini tidak sesuai dengan jenis acara dan tipe pemesan yang dipilih.', 'error')
    return
  }
  form.value.package_id = item.id
  if (service) {
    form.value.service_id = service.id
  }
}

function changeBookingType(type) {
  if (form.value.booking_type === type) return
  form.value.booking_type = type
  form.value.service_id = ''
  form.value.package_id = ''
  form.value.event_type = ''
  form.value.organization_name = ''
  form.value.organization_type = ''
  form.value.contact_position = ''
  selectedAddons.value = {}
  errors.value = {}
}

function changeService(serviceId) {
  form.value.service_id = serviceId
  form.value.package_id = ''
  selectedAddons.value = {}
}

function changeEventType(eventTypeName) {
  form.value.event_type = eventTypeName
  if (!selectedEventType.value?.service_ids?.includes(form.value.service_id)) {
    form.value.service_id = ''
  }
  if (selectedPackage.value?.event_type_id !== selectedEventType.value?.id || !availableServices.value.some((service) => service.id === selectedPackage.value?.service_id)) {
    form.value.package_id = ''
    selectedAddons.value = {}
  }
}

function validate() {
  const result = {}
  if (form.value.name.trim().length < 2) result.name = 'Nama minimal 2 karakter.'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email.trim())) result.email = 'Masukkan email yang valid.'
  if (form.value.phone.replace(/\D/g, '').length < 9) result.phone = 'Masukkan nomor WhatsApp yang valid.'
  if (form.value.booking_type === 'organization' && form.value.organization_name.trim().length < 2) result.organization_name = 'Masukkan nama instansi atau sekolah.'
  if (form.value.booking_type === 'organization' && !form.value.organization_type) result.organization_type = 'Pilih jenis instansi.'
  if (!form.value.event_type) result.event_type = 'Pilih jenis acara.'
  else if (!selectedEventType.value) result.event_type = 'Jenis acara tidak sesuai dengan tipe pemesan.'
  if (!form.value.service_id || !availableServices.value.some((service) => service.id === form.value.service_id)) result.service_id = 'Pilih layanan yang tersedia untuk jenis acara ini.'
  if (form.value.package_id && !availablePackages.value.some((item) => item.id === form.value.package_id)) result.package_id = 'Paket harus sesuai dengan jenis acara dan layanan yang dipilih.'
  if (!form.value.event_date) result.event_date = 'Tentukan tanggal acara atau pilih tanggal sementara.'
  else if (form.value.event_date < minimumDate) result.event_date = 'Tanggal acara tidak boleh di masa lalu.'
  if (form.value.event_start_time && form.value.event_end_time && form.value.event_end_time <= form.value.event_start_time) result.event_end_time = 'Waktu selesai harus setelah waktu mulai.'
  if (!form.value.event_city.trim()) result.event_city = 'Masukkan kota tempat acara.'
  if (!Number.isSafeInteger(Number(form.value.guest_count)) || Number(form.value.guest_count) < 1 || Number(form.value.guest_count) > 100000) result.guest_count = 'Masukkan jumlah peserta atau tamu yang valid (1–100.000).'
  if (form.value.budget_min && (!Number.isFinite(Number(form.value.budget_min)) || Number(form.value.budget_min) < 0)) result.budget_min = 'Anggaran minimum harus angka nol atau lebih.'
  if (form.value.budget_max && (!Number.isFinite(Number(form.value.budget_max)) || Number(form.value.budget_max) < 0)) result.budget_max = 'Anggaran maksimum harus angka nol atau lebih.'
  if (form.value.budget_min && form.value.budget_max && Number(form.value.budget_max) < Number(form.value.budget_min)) result.budget_max = 'Batas maksimum harus lebih besar dari minimum.'
  if (form.value.message.trim().length < 15) result.message = 'Jelaskan acara Anda minimal 15 karakter.'
  errors.value = result
  return Object.keys(result).length === 0
}

function changeAddon(addon, amount) {
  const key = addon.id || addon.name
  const next = Math.max(0, Number(selectedAddons.value[key] || 0) + amount)
  if (next === 0) {
    const { [key]: removed, ...remaining } = selectedAddons.value
    selectedAddons.value = remaining
    return
  }
  selectedAddons.value = { ...selectedAddons.value, [key]: next }
}

async function submitBooking() {
  if (submitting.value || !validate()) return
  submitting.value = true
  const payload = {
    name: form.value.name.trim(),
    email: form.value.email.trim().toLowerCase(),
    phone: form.value.phone.trim(),
    event_type: form.value.event_type,
    event_date: form.value.event_date || null,
    guest_count: Number(form.value.guest_count),
    booking_type: form.value.booking_type,
    organization_name: form.value.organization_name.trim(),
    organization_type: form.value.organization_type,
    contact_position: form.value.contact_position.trim(),
    service_id: form.value.service_id || null,
    package_id: selectedPackage.value?.id || null,
    event_start_time: form.value.event_start_time || null,
    event_end_time: form.value.event_end_time || null,
    event_location: form.value.event_location.trim(),
    event_city: form.value.event_city.trim(),
    venue_type: form.value.venue_type,
    budget_min: form.value.budget_min ? Number(form.value.budget_min) : null,
    budget_max: form.value.budget_max ? Number(form.value.budget_max) : null,
    event_theme: form.value.event_theme.trim(),
    selected_addons: selectedItems.value,
    special_requirements: form.value.special_requirements.trim(),
    message: form.value.message.trim(),
    status: 'baru',
  }
  try {
    if (supabaseConfigured) {
      const { error } = await supabase.from('inquiries').insert(payload)
      if (error) throw error
    } else {
      const saved = JSON.parse(localStorage.getItem('anaj-demo-inquiries') || '[]')
      saved.push({ ...payload, id: `demo-${Date.now()}`, created_at: new Date().toISOString(), notes: '' })
      localStorage.setItem('anaj-demo-inquiries', JSON.stringify(saved))
    }
    submitted.value = true
    window.scrollTo({ top: 0, behavior: 'smooth' })
    notify('Permintaan booking Anda berhasil dikirim.')
  } catch (error) {
    console.error('Booking submission failed:', error)
    notify(`Booking belum terkirim. ${error.message || 'Silakan coba lagi.'}`, 'error')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="page-hero booking-page-hero"><div class="container"><span class="eyebrow">BOOKING & KONSULTASI ACARA</span><h1>Rencanakan acara sekolah,<br>mulai dari sini.</h1><p>Ceritakan rencana perpisahan, wisuda, atau yearbook sekolah Anda. Kami bantu susun kebutuhan acara dan penawarannya.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Booking acara</span></div></div></section>
  <section v-if="submitted" class="section section-paper"><div class="container booking-success"><span class="booking-success-icon"><Check :size="24" /></span><span class="eyebrow">PERMINTAAN BOOKING TERKIRIM</span><h2>Terima kasih sudah berbagi cerita.</h2><p>Tim kami akan meninjau detail acara dan menghubungi Anda untuk konfirmasi paket, ketersediaan tanggal, serta penawaran final. Booking baru terkonfirmasi setelah ada persetujuan tim kami.</p><div class="booking-success-actions"><RouterLink class="button button-dark" to="/layanan">Jelajahi layanan</RouterLink><RouterLink class="text-link" to="/">Kembali ke beranda <ArrowRight :size="15" /></RouterLink></div></div></section>
  <section v-else class="section section-paper"><div class="container booking-layout">
    <form class="booking-form" novalidate @submit.prevent="submitBooking">
      <div class="booking-step-heading"><span>01</span><div><h2>Siapa yang sedang merayakan?</h2><p>Pilih tipe pemesan agar kami menyesuaikan kebutuhan acara.</p></div></div>
      <div class="booking-type-switch"><button type="button" :class="{ selected: form.booking_type === 'organization' }" @click="changeBookingType('organization')"><span class="booking-type-icon">01</span><strong>Instansi / Sekolah</strong><small>Perpisahan, wisuda, yearbook, corporate</small></button><button type="button" :class="{ selected: form.booking_type === 'personal' }" @click="changeBookingType('personal')"><span class="booking-type-icon">02</span><strong>Personal</strong><small>Wedding, ulang tahun, perayaan keluarga</small></button></div>
      <div class="booking-form-grid">
        <label class="field"><span>{{ form.booking_type === 'organization' ? 'Nama PIC / penanggung jawab *' : 'Nama lengkap *' }}</span><input v-model="form.name" autocomplete="name" placeholder="Nama Anda"><small v-if="errors.name" class="field-error">{{ errors.name }}</small></label>
        <label class="field"><span>Email aktif *</span><input v-model="form.email" type="email" autocomplete="email" placeholder="nama@email.com"><small v-if="errors.email" class="field-error">{{ errors.email }}</small></label>
        <label class="field"><span>Nomor WhatsApp *</span><input v-model="form.phone" type="tel" autocomplete="tel" placeholder="+62 812 3456 7890"><small v-if="errors.phone" class="field-error">{{ errors.phone }}</small></label>
        <label v-if="form.booking_type === 'organization'" class="field"><span>Nama instansi / sekolah *</span><input v-model="form.organization_name" placeholder="Contoh: SMA Cakrawala"><small v-if="errors.organization_name" class="field-error">{{ errors.organization_name }}</small></label>
        <label v-if="form.booking_type === 'organization'" class="field"><span>Jenis instansi *</span><select v-model="form.organization_type"><option value="">Pilih jenis instansi</option><option>Sekolah / universitas</option><option>Perusahaan / korporasi</option><option>Komunitas / organisasi</option><option>Pemerintahan</option><option>Lainnya</option></select><small v-if="errors.organization_type" class="field-error">{{ errors.organization_type }}</small></label>
        <label v-if="form.booking_type === 'organization'" class="field"><span>Jabatan PIC</span><input v-model="form.contact_position" placeholder="Contoh: Wakil Kepala Sekolah"></label>
      </div>

      <div class="booking-step-heading booking-step-divider"><span>02</span><div><h2>Pilih layanan dan paket</h2><p>Anda dapat meminta rekomendasi jika belum menentukan paket.</p></div></div>
      <div class="booking-form-grid">
        <label class="field"><span>Jenis acara *</span><select :value="form.event_type" @change="changeEventType($event.target.value)"><option value="">Pilih jenis acara</option><option v-for="eventType in availableEventTypes" :key="eventType.id" :value="eventType.name">{{ eventType.name }}</option></select><small v-if="errors.event_type" class="field-error">{{ errors.event_type }}</small></label>
        <label class="field"><span>Layanan yang dibutuhkan *</span><select :value="form.service_id" :disabled="!selectedEventType" @change="changeService($event.target.value)"><option value="">{{ selectedEventType ? 'Pilih layanan' : 'Pilih jenis acara terlebih dahulu' }}</option><option v-for="service in availableServices" :key="service.id" :value="service.id">{{ service.title }}</option></select><small v-if="errors.service_id" class="field-error">{{ errors.service_id }}</small></label>
        <label class="field"><span>Paket pilihan</span><select :value="form.package_id" :disabled="!selectedEventType" @change="choosePackage(availablePackages.find((item) => item.id === $event.target.value) || { id: '', service_id: form.service_id })"><option value="">{{ selectedEventType ? 'Minta rekomendasi paket' : 'Pilih jenis acara terlebih dahulu' }}</option><option v-for="item in availablePackages" :key="item.id" :value="item.id">{{ item.name }} — {{ formatPrice(item.price) }}</option></select><small v-if="errors.package_id" class="field-error">{{ errors.package_id }}</small></label>
        <label class="field"><span>Tema atau konsep acara</span><input v-model="form.event_theme" placeholder="Contoh: garden party, formal, tropical"></label>
      </div>

      <div v-if="selectedPackage && availableAddons.length" class="booking-addons">
        <div class="booking-addons-heading"><div><span class="eyebrow">PERSONALISASIKAN PAKET</span><h3>Add-on & peralatan</h3><p>Pilih peralatan atau layanan tambahan. Jumlah item bisa disesuaikan.</p></div><span class="addon-count">{{ selectedItems.length }} dipilih</span></div>
        <div class="booking-addon-list"><label v-for="addon in availableAddons" :key="addon.id || addon.name" class="booking-addon-row"><span class="addon-check" :class="{ checked: selectedAddons[addon.id || addon.name] }"><Check v-if="selectedAddons[addon.id || addon.name]" :size="13" /></span><input class="visually-hidden" type="checkbox" :checked="Boolean(selectedAddons[addon.id || addon.name])" @change="changeAddon(addon, $event.target.checked ? 1 : -Number(selectedAddons[addon.id || addon.name] || 0))"><span class="booking-addon-copy"><strong>{{ addon.name }}</strong><small>{{ addon.description || 'Tambahan opsional untuk acara Anda.' }}</small></span><strong class="booking-addon-price">{{ formatPrice(addon.price) }}</strong><span class="addon-quantity" @click.prevent><button type="button" aria-label="Kurangi jumlah" :disabled="!selectedAddons[addon.id || addon.name]" @click="changeAddon(addon, -1)"><Minus :size="12" /></button><span>{{ selectedAddons[addon.id || addon.name] || 0 }}</span><button type="button" aria-label="Tambah jumlah" @click="changeAddon(addon, 1)"><Plus :size="12" /></button></span></label></div>
        <p class="addon-disclaimer"><CircleAlert :size="14" /> Harga add-on merupakan estimasi. Jumlah dan ketersediaan peralatan akan dikonfirmasi tim kami.</p>
      </div>

      <div class="booking-step-heading booking-step-divider"><span>03</span><div><h2>Detail waktu dan lokasi</h2><p>Informasi ini membantu kami memeriksa kebutuhan produksi dan ketersediaan.</p></div></div>
      <div class="booking-form-grid">
        <label class="field"><span>Tanggal acara *</span><input v-model="form.event_date" type="date" :min="minimumDate"><small v-if="errors.event_date" class="field-error">{{ errors.event_date }}</small></label>
        <label class="field"><span>Jumlah tamu / peserta *</span><input v-model.number="form.guest_count" type="number" min="1" placeholder="Contoh: 250"><small v-if="errors.guest_count" class="field-error">{{ errors.guest_count }}</small></label>
        <label class="field"><span>Waktu mulai</span><input v-model="form.event_start_time" type="time"></label>
        <label class="field"><span>Waktu selesai</span><input v-model="form.event_end_time" type="time"><small v-if="errors.event_end_time" class="field-error">{{ errors.event_end_time }}</small></label>
        <label class="field"><span>Kota acara *</span><input v-model="form.event_city" placeholder="Contoh: Jakarta Selatan"><small v-if="errors.event_city" class="field-error">{{ errors.event_city }}</small></label>
        <label class="field"><span>Jenis venue</span><select v-model="form.venue_type"><option value="">Belum ditentukan</option><option>Ballroom / hotel</option><option>Gedung / aula sekolah</option><option>Outdoor / taman</option><option>Kantor / convention center</option><option>Rumah / private venue</option><option>Venue belum dipilih</option><option>Lainnya</option></select></label>
        <label class="field field-wide"><span>Nama venue dan alamat (jika sudah ada)</span><input v-model="form.event_location" placeholder="Nama venue, alamat lengkap, atau tautan lokasi"></label>
      </div>

      <div class="booking-step-heading booking-step-divider"><span>04</span><div><h2>Anggaran dan kebutuhan khusus</h2><p>Opsional — membantu kami menyusun rekomendasi yang realistis.</p></div></div>
      <div class="booking-form-grid">
        <label class="field"><span>Anggaran minimum (Rp)</span><CurrencyInput v-model="form.budget_min" aria-label="Anggaran minimum dalam rupiah" placeholder="Contoh: 1.000.000" nullable /><small v-if="errors.budget_min" class="field-error">{{ errors.budget_min }}</small></label>
        <label class="field"><span>Anggaran maksimum (Rp)</span><CurrencyInput v-model="form.budget_max" aria-label="Anggaran maksimum dalam rupiah" placeholder="Contoh: 10.000.000" nullable /><small v-if="errors.budget_max" class="field-error">{{ errors.budget_max }}</small></label>
        <label class="field field-wide"><span>Kebutuhan khusus atau perlengkapan</span><textarea v-model="form.special_requirements" rows="3" placeholder="Contoh: akses kursi roda, kebutuhan listrik, panggung tambahan, konsumsi khusus..."></textarea></label>
        <label class="field field-wide"><span>Ceritakan rencana acara Anda *</span><textarea v-model="form.message" rows="4" placeholder="Tujuan acara, susunan kegiatan, hal yang paling penting untuk Anda, atau kebutuhan lain..." /><small v-if="errors.message" class="field-error">{{ errors.message }}</small></label>
      </div>
      <div class="booking-submit-row"><p>Permintaan ini belum mengunci tanggal atau menimbulkan biaya. Tim kami akan mengonfirmasi ketersediaan dan penawaran terlebih dahulu.</p><button class="button button-dark" type="submit" :disabled="submitting">{{ submitting ? 'Mengirim permintaan...' : 'Kirim permintaan booking' }} <ArrowRight :size="16" /></button></div>
    </form>

    <aside class="booking-summary"><div class="booking-summary-sticky"><span class="eyebrow">RINGKASAN RENCANA</span><h3>{{ selectedPackage?.name || 'Booking acara Anda' }}</h3><p>{{ packageService?.title || 'Pilih layanan untuk memulai' }}</p>
      <div class="summary-line"><span>Tipe pemesan</span><strong>{{ form.booking_type === 'organization' ? 'Instansi / sekolah' : 'Personal' }}</strong></div>
      <div class="summary-line"><span>Paket</span><strong>{{ selectedPackage ? formatPrice(packagePrice) : 'Belum dipilih' }}</strong></div>
      <div v-if="selectedItems.length" class="summary-selected"><span>Add-on pilihan</span><div v-for="item in selectedItems" :key="item.id"><span>{{ item.name }} × {{ item.quantity }}</span><strong>{{ formatPrice(item.price * item.quantity) }}</strong></div></div>
      <div class="summary-total"><span>Estimasi paket + add-on</span><strong>{{ formatPrice(estimatedTotal) }}</strong><small v-if="selectedPackage?.price_label?.includes('buku')">Harga paket per buku, estimasi belum dikalikan jumlah cetak.</small></div>
      <div class="summary-help"><CalendarDays :size="17" /><span><strong>Tanggal belum terkonfirmasi</strong><small>Tim kami akan mengecek ketersediaan setelah permintaan diterima.</small></span></div>
      <RouterLink v-if="selectedPackage" class="text-link" :to="`/layanan/${packageService?.slug || ''}`"><ArrowLeft :size="14" /> Kembali ke detail paket</RouterLink>
    </div></aside>
  </div></section>
</template>
