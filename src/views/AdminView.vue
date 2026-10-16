<script setup>
import { computed, onMounted, ref } from 'vue'
import { Activity, ArrowDownToLine, ArrowRight, ArrowUpRight, BookOpen, CalendarDays, ChevronDown, CircleHelp, FileImage, LayoutDashboard, LogOut, Menu, MessageSquareText, Package, Pencil, Plus, Search, Settings, ShieldCheck, Trash2, Users, X } from '@lucide/vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase, supabaseConfigured } from '../lib/supabase'
import { demoCategories, demoFaqs, demoLandingSections, demoPackages, demoServices, demoTestimonials, formatPrice, localImages } from '../data/demo'
import { useToast } from '../composables/useToast'

const route = useRoute()
const router = useRouter()
const { notify } = useToast()
const profile = computed(() => route.meta.profile || {})
const isLocalDemo = !supabaseConfigured
const role = computed(() => profile.value.role || (isLocalDemo ? 'super_admin' : 'editor'))
const isSuperAdmin = computed(() => role.value === 'super_admin')
const active = ref('dashboard')
const sidebarOpen = ref(false)
const accountMenuOpen = ref(false)
const loading = ref(false)
const query = ref('')
const filterStatus = ref('semua')
const inquiries = ref([])
const counts = ref({ inquiries: 0, newInquiries: 0, services: 0, portfolios: 0, packages: 0 })
const dataSets = ref({ services: [], categories: [], packages: [], portfolios: [], testimonials: [], faqs: [], contacts: [], clients: [], price_list: [], landing_sections: [], site_settings: [], profiles: [] })
const serviceCounts = ref([])
const notice = ref('')
const editing = ref(null)
const saving = ref(false)
const form = ref({})
const pendingImages = ref({})
const accountEditing = ref(null)
const accountForm = ref({ full_name: '', email: '', password: '', role: 'editor' })
const accountsLoading = ref(false)
const imageFieldKeys = computed(() => {
  const fields = ['image_url', 'cover_image_url', 'logo_url', 'avatar_url'].filter((key) => key in form.value)
  if (active.value === 'site_settings' && form.value.key === 'logo_url' && !fields.includes('value')) fields.push('value')
  return fields
})
const allMenuItems = [
  { id: 'dashboard', label: 'Ringkasan', icon: LayoutDashboard },
  { id: 'inquiries', label: 'Pertanyaan', icon: MessageSquareText },
  { id: 'bookings', label: 'Booking acara', icon: CalendarDays },
  { id: 'services', label: 'Layanan & kategori', icon: BookOpen },
  { id: 'categories', label: 'Kategori layanan', icon: ChevronDown },
  { id: 'packages', label: 'Paket & harga', icon: Package },
  { id: 'portfolios', label: 'Portofolio', icon: FileImage },
  { id: 'testimonials', label: 'Testimoni', icon: Users },
  { id: 'clients', label: 'Klien & partner', icon: Users },
  { id: 'faqs', label: 'FAQ', icon: CircleHelp },
  { id: 'contacts', label: 'Kontak person', icon: Users },
  { id: 'landing_sections', label: 'Halaman utama', icon: Activity },
  { id: 'site_settings', label: 'Pengaturan situs', icon: Settings, superAdminOnly: true },
  { id: 'profiles', label: 'Akun & hak akses', icon: ShieldCheck, superAdminOnly: true },
]
const menu = computed(() => allMenuItems.filter((item) => !item.superAdminOnly || isSuperAdmin.value))
const filteredInquiries = computed(() => inquiries.value.filter((item) => (filterStatus.value === 'semua' || item.status === filterStatus.value) && `${item.name} ${item.email} ${item.event_type} ${item.phone} ${item.organization_name || ''} ${item.event_city || ''}`.toLowerCase().includes(query.value.toLowerCase())))
const bookingInquiries = computed(() => inquiries.value.filter((item) => item.event_city || item.service_id || item.package_id || item.organization_name || item.selected_addons?.length))
const filteredBookings = computed(() => bookingInquiries.value.filter((item) => (filterStatus.value === 'semua' || item.status === filterStatus.value) && `${item.name} ${item.email} ${item.event_type} ${item.phone} ${item.organization_name || ''} ${item.event_city || ''}`.toLowerCase().includes(query.value.toLowerCase())))
const upcomingBookings = computed(() => bookingInquiries.value.filter((item) => item.event_date && item.event_date >= new Date().toISOString().slice(0, 10)).length)
const organizationBookings = computed(() => bookingInquiries.value.filter((item) => item.booking_type === 'organization' || item.organization_name).length)
const currentRows = computed(() => active.value === 'inquiries' ? filteredInquiries.value : active.value === 'bookings' ? filteredBookings.value : dataSets.value[active.value] || [])
const headings = { dashboard: 'Selamat datang kembali', inquiries: 'Pertanyaan masuk', bookings: 'Ringkasan booking', services: 'Layanan & kategori', categories: 'Kategori layanan', packages: 'Paket & daftar harga', portfolios: 'Portofolio', testimonials: 'Testimoni', clients: 'Klien & partner', faqs: 'Pertanyaan umum', contacts: 'Kontak person', landing_sections: 'Konten halaman utama', site_settings: 'Pengaturan situs', profiles: 'Akun & hak akses' }
const dateLabel = (date) => new Intl.DateTimeFormat('id-ID', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(date))
const setPage = (id) => {
  if (id === 'site_settings' || id === 'profiles') {
    if (!isSuperAdmin.value) {
      notify('Halaman ini hanya dapat diakses super admin.', 'error')
      return
    }
  }
  if (!menu.value.some((item) => item.id === id)) return
  active.value = id
  sidebarOpen.value = false
  editing.value = null
  accountEditing.value = null
  if (id === 'profiles') loadAdminAccounts()
}

async function loadDashboard() {
  loading.value = true
  try {
    if (isLocalDemo) {
      inquiries.value = JSON.parse(localStorage.getItem('anaj-demo-inquiries') || '[]')
      counts.value = { inquiries: inquiries.value.length, newInquiries: inquiries.value.filter((item) => item.status === 'baru').length, services: demoServices.length, portfolios: 6, packages: demoPackages.length }
      serviceCounts.value = popularCategories(inquiries.value)
      dataSets.value.services = demoServices
      dataSets.value.categories = demoCategories
      dataSets.value.packages = demoPackages
      dataSets.value.portfolios = Array.from({ length: 6 }, (_, index) => ({ id: `demo-${index}`, title: ['A Garden Wedding', 'Together, Forward', 'Class of 2025', 'The Art of Gathering', 'Our Little Universe', 'Golden Hour Vows'][index], category: ['Wedding', 'Corporate', 'Graduation', 'Event', 'Yearbook', 'Wedding'][index], image_url: demoServices[index % demoServices.length].image_url, is_published: true }))
      dataSets.value.testimonials = demoTestimonials
      dataSets.value.faqs = demoFaqs
      dataSets.value.contacts = [{ id: 'c1', name: 'Alya Putri', title: 'Wedding Consultant', division: 'Wedding & Personal', is_published: true }, { id: 'c2', name: 'Raka Mahendra', title: 'Event Consultant', division: 'Corporate & School', is_published: true }]
      dataSets.value.clients = [{ id: 'cl1', name: 'Nusantara Group', is_published: true }, { id: 'cl2', name: 'SMA Cakrawala', is_published: true }]
      dataSets.value.landing_sections = demoLandingSections
      dataSets.value.site_settings = [{ id: 'name', key: 'brand_name', label: 'Nama brand', value: 'Abadi nan Jaya' }, { id: 'whatsapp', key: 'whatsapp', label: 'Nomor WhatsApp', value: '6281234567890' }, { id: 'instagram', key: 'instagram', label: 'Instagram', value: '@abadinanjaya' }]
      dataSets.value.profiles = JSON.parse(localStorage.getItem('anaj-demo-admin-users') || 'null') || [
        { id: 'demo-super', full_name: 'Admin Abadi nan Jaya', email: 'admin@abadinanjaya.test', role: 'super_admin', created_at: new Date().toISOString() },
        { id: 'demo-editor', full_name: 'Editor Konten', email: 'editor@abadinanjaya.test', role: 'editor', created_at: new Date().toISOString() },
      ]
    } else {
      const [inquiryResult, servicesResult, portfolioResult, packagesResult, newResult, serviceRows, allQueries] = await Promise.all([
        supabase.from('inquiries').select('*', { count: 'exact' }).order('created_at', { ascending: false }),
        supabase.from('services').select('*', { count: 'exact' }),
        supabase.from('portfolios').select('*', { count: 'exact' }),
        supabase.from('packages').select('*', { count: 'exact' }),
        supabase.from('inquiries').select('*', { count: 'exact', head: true }).eq('status', 'baru'),
        supabase.from('services').select('category_id'),
        Promise.all(['services', 'categories', 'packages', 'portfolios', 'testimonials', 'faqs', 'contacts', 'clients', 'landing_sections', 'site_settings', 'profiles'].map((table) => {
          const selection = table === 'packages' ? '*,addons(*),package_items(*)' : table === 'profiles' ? 'id,full_name,role,created_at' : '*'
          const query = supabase.from(table).select(selection)
          return table === 'profiles'
            ? query.order('created_at', { ascending: false }).limit(200)
            : query.order('sort_order', { ascending: true }).limit(200)
        })),
      ])
      for (const result of [inquiryResult, servicesResult, portfolioResult, packagesResult, newResult, serviceRows, ...allQueries]) if (result.error) throw result.error
      inquiries.value = inquiryResult.data || []
      counts.value = { inquiries: inquiryResult.count || 0, newInquiries: newResult.count || 0, services: servicesResult.count || 0, portfolios: portfolioResult.count || 0, packages: packagesResult.count || 0 }
      serviceCounts.value = popularCategories(inquiries.value, serviceRows.data || [], allQueries[1].data || [])
      const keys = ['services', 'categories', 'packages', 'portfolios', 'testimonials', 'faqs', 'contacts', 'clients', 'landing_sections', 'site_settings', 'profiles']
      keys.forEach((key, index) => {
        const rows = allQueries[index].data || []
        dataSets.value[key] = key === 'site_settings'
          ? rows.map((item) => ({ ...item, label: item.key.replaceAll('_', ' '), value: Object.values(item.value || {})[0] || '' }))
          : key === 'packages'
            ? rows.map((item) => ({
              ...item,
              inclusions: item.package_items?.length ? item.package_items.sort((a, b) => a.sort_order - b.sort_order).map((entry) => entry.name) : item.inclusions || [],
              addons: item.addons || [],
            }))
            : rows
      })
    }
    notice.value = ''
  } catch (error) {
    notice.value = error.message || 'Data tidak dapat dimuat.'
    notify(notice.value, 'error')
  } finally {
    loading.value = false
  }
}

function popularCategories(rows, services = demoServices, categories = demoCategories) {
  const countsByName = rows.reduce((counts, inquiry) => {
    if (inquiry.event_type) counts[inquiry.event_type] = (counts[inquiry.event_type] || 0) + 1
    return counts
  }, {})
  if (Object.values(countsByName).some(Boolean)) {
    return Object.entries(countsByName).map(([name, value]) => ({ name, value })).sort((a, b) => b.value - a.value).slice(0, 5)
  }
  return categories.map((category) => ({ name: category.name, value: services.filter((service) => service.category_id === category.id).length }))
}

function exportCsv() {
  const rows = [['Nama PIC', 'Email', 'WhatsApp', 'Tipe pemesan', 'Instansi', 'Jabatan PIC', 'Paket ID', 'Jenis acara', 'Tanggal acara', 'Waktu', 'Jumlah tamu/peserta', 'Venue/alamat', 'Kota', 'Tipe venue', 'Anggaran min', 'Anggaran max', 'Tema', 'Add-on/peralatan', 'Kebutuhan khusus', 'Status', 'Catatan internal', 'Pesan', 'Diterima']]
  const exportRows = active.value === 'bookings' ? filteredBookings.value : filteredInquiries.value
  for (const item of exportRows) rows.push([item.name, item.email, item.phone, item.booking_type, item.organization_name, item.contact_position, item.package_id, item.event_type, item.event_date, [item.event_start_time, item.event_end_time].filter(Boolean).join(' - '), item.guest_count, item.event_location, item.event_city, item.venue_type, item.budget_min, item.budget_max, item.event_theme, (item.selected_addons || []).map((addon) => `${addon.name} x ${addon.quantity || 1}`).join('; '), item.special_requirements, item.status, item.notes, item.message, item.created_at])
  const csv = `\uFEFF${rows.map((row) => row.map((cell) => {
    const value = String(cell ?? '')
    const safeValue = typeof cell === 'string' && /^[\s]*[=+\-@]/.test(value) ? `'${value}` : value
    return `"${safeValue.replaceAll('"', '""')}"`
  }).join(',')).join('\r\n')}`
  const link = document.createElement('a')
  link.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' }))
  link.download = `inquiry-abadi-nan-jaya-${new Date().toISOString().slice(0, 10)}.csv`
  link.click()
  URL.revokeObjectURL(link.href)
}
async function deleteRow(item) {
  if (!isSuperAdmin.value) {
    notify('Hanya super admin yang dapat menghapus konten.', 'error')
    return
  }
  if (!window.confirm(`Hapus "${item.title || item.name || item.question || item.section_key}"? Tindakan ini tidak dapat dibatalkan.`)) return
  const table = active.value
  if (isLocalDemo) {
    dataSets.value[table] = dataSets.value[table].filter((row) => row.id !== item.id)
    notify('Item dihapus dari sesi demo ini.')
    return
  }
  try {
    const { error } = await supabase.from(table).delete().eq('id', item.id)
    if (error) throw error
    notify('Item berhasil dihapus.')
    await loadDashboard()
  } catch (error) {
    notify(`Tidak dapat menghapus item: ${error.message}`, 'error')
  }
}
function editRow(item) {
  clearPendingImages()
  editing.value = item.id || `new-${Date.now()}`
  const updated = { ...item }
  const imageField = ['image_url', 'cover_image_url', 'logo_url', 'avatar_url'].find((key) => key in updated)
    || (active.value === 'site_settings' && updated.key === 'logo_url' ? 'value' : null)
  if (imageField && updated[imageField] && !updated[imageField].startsWith('/') && !updated[imageField].includes('.supabase.co/storage/v1/object/public/')) {
    const category = dataSets.value.categories.find((entry) => entry.id === updated.category_id || entry.name === updated.category)
    updated[imageField] = active.value === 'landing_sections'
      ? localImages[updated.section_key === 'about' ? 'about' : 'wedding']
      : localImages[category?.slug] || (active.value === 'portfolios' ? localImages.wedding : localImages.production)
  }
  form.value = updated
}
function newRow() {
  clearPendingImages()
  editing.value = 'new'
  const templates = {
    services: { title: '', slug: '', summary: '', description: '', category_id: '', image_url: localImages.production, featured: false, is_published: false },
    categories: { name: '', slug: '', description: '', icon: '', sort_order: 0, is_published: false },
    packages: { name: '', slug: '', description: '', service_id: '', price: 0, price_label: 'Mulai dari', inclusions: [], addons: [], is_published: false },
    portfolios: { title: '', slug: '', category: '', category_id: '', description: '', cover_image_url: localImages.wedding, is_published: false },
    faqs: { question: '', answer: '', sort_order: 0, is_published: false },
    contacts: { name: '', title: '', division: '', phone: '', email: '', sort_order: 0, is_published: false },
    testimonials: { name: '', role: '', quote: '', avatar_url: '', rating: 5, is_published: false },
    clients: { name: '', logo_url: '', website_url: '', sort_order: 0, is_published: false },
    landing_sections: { section_key: '', title: '', subtitle: '', body: '', image_url: localImages.wedding, cta_label: '', cta_url: '', is_enabled: true, sort_order: 0 },
    site_settings: { key: '', value: '' },
  }
  form.value = { ...(templates[active.value] || { name: '' }) }
}
function slugify(value) {
  return value.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}
function selectImage(event, field) {
  const file = event.target.files?.[0]
  event.target.value = ''
  if (!file) return
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/avif', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    notify('Pilih gambar JPG, PNG, WebP, AVIF, atau GIF.', 'error')
    return
  }
  if (file.size > 50 * 1024 * 1024) {
    notify('Ukuran gambar tidak boleh lebih dari 50 MB.', 'error')
    return
  }
  if (pendingImages.value[field] && form.value[field]?.startsWith('blob:')) URL.revokeObjectURL(form.value[field])
  pendingImages.value[field] = file
  form.value[field] = URL.createObjectURL(file)
}
function clearPendingImages() {
  for (const field of Object.keys(pendingImages.value)) {
    if (form.value[field]?.startsWith('blob:')) URL.revokeObjectURL(form.value[field])
  }
  pendingImages.value = {}
}
function cancelEdit() {
  clearPendingImages()
  editing.value = null
}
function readAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(reader.result)
    reader.onerror = () => reject(reader.error || new Error('Gambar tidak dapat dibaca.'))
    reader.readAsDataURL(file)
  })
}
async function uploadSelectedImages(record, table) {
  for (const [field, file] of Object.entries(pendingImages.value)) {
    if (isLocalDemo) {
      record[field] = await readAsDataUrl(file)
      continue
    }
    const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '-')
    const path = `content/${table}/${Date.now()}-${crypto.randomUUID()}-${safeName}`
    const { error } = await supabase.storage.from('portfolio-media').upload(path, file, {
      upsert: false,
      contentType: file.type,
    })
    if (error) throw error
    const { data: { publicUrl } } = supabase.storage.from('portfolio-media').getPublicUrl(path)
    record[field] = publicUrl
  }
}
async function saveRow() {
  const table = active.value
  if (table === 'site_settings' && !isSuperAdmin.value) {
    notify('Hanya super admin yang dapat mengubah pengaturan situs.', 'error')
    return
  }
  const record = { ...form.value }
  const addonItems = table === 'packages' ? (record.addons || []).map((addon) => {
    if (typeof addon === 'string') {
      const [name, price = '0', description = ''] = addon.split('|')
      return { name: name.trim(), price: Number(price) || 0, description: description.trim() }
    }
    return { name: addon.name?.trim(), price: Number(addon.price) || 0, description: addon.description?.trim() || '' }
  }).filter((addon) => addon.name) : null
  if (table === 'packages') delete record.addons
  if (Array.isArray(record.inclusions)) record.inclusions = record.inclusions.map((value) => typeof value === 'string' ? value.trim() : value).filter(Boolean)
  if (['services', 'categories', 'packages', 'portfolios'].includes(table) && !record.slug && (record.title || record.name)) {
    record.slug = slugify(record.title || record.name)
  }
  if (table === 'inquiries' && isLocalDemo) return updateInquiry(record)
  saving.value = true
  if (isLocalDemo) {
    try {
      await uploadSelectedImages(record, table)
      if (editing.value === 'new') record.id = `${table}-${Date.now()}`
      const list = dataSets.value[active.value] || []
      if (table === 'packages') record.addons = addonItems
      dataSets.value[active.value] = editing.value === 'new' ? [...list, record] : list.map((item) => item.id === record.id ? record : item)
      editing.value = null
      clearPendingImages()
      notify('Perubahan tersimpan di sesi demo ini. Konfigurasikan Supabase untuk menyimpan secara permanen.')
    } catch (error) {
      notify(`Tidak dapat menyimpan: ${error.message}`, 'error')
    } finally {
      saving.value = false
    }
    return
  }
  try {
    await uploadSelectedImages(record, table)
    if (table === 'site_settings') {
      record.value = typeof record.value === 'string' ? { [record.key]: record.value } : record.value
      delete record.label
    }
    let savedPackageId = record.id
    const { data, error } = editing.value === 'new'
      ? await supabase.from(table).insert(record).select('id').single()
      : await supabase.from(table).update(record).eq('id', record.id).select('id').single()
    if (error) throw error
    if (table === 'packages') {
      savedPackageId = data.id
      const { error: deleteError } = await supabase.from('addons').delete().eq('package_id', savedPackageId)
      if (deleteError) throw deleteError
      const { error: deleteItemsError } = await supabase.from('package_items').delete().eq('package_id', savedPackageId)
      if (deleteItemsError) throw deleteItemsError
      if (record.inclusions.length) {
        const { error: itemsError } = await supabase.from('package_items').insert(record.inclusions.map((name, index) => ({ package_id: savedPackageId, name, sort_order: index + 1 })))
        if (itemsError) throw itemsError
      }
      if (addonItems.length) {
        const { error: addonError } = await supabase.from('addons').insert(addonItems.map((addon, index) => ({ package_id: savedPackageId, ...addon, sort_order: index + 1 })))
        if (addonError) throw addonError
      }
    }
    editing.value = null
    clearPendingImages()
    notify('Perubahan berhasil disimpan.')
    await loadDashboard()
  } catch (error) {
    notify(`Tidak dapat menyimpan: ${error.message}`, 'error')
  } finally {
    saving.value = false
  }
}
async function updateInquiry(item) {
  const next = inquiries.value.map((entry) => entry.id === item.id ? item : entry)
  if (isLocalDemo) {
    inquiries.value = next
    counts.value.inquiries = next.length
    counts.value.newInquiries = next.filter((entry) => entry.status === 'baru').length
    localStorage.setItem('anaj-demo-inquiries', JSON.stringify(next))
    notify('Status inquiry diperbarui.')
    return
  }
  saving.value = true
  try {
    const { error } = await supabase.from('inquiries').update({ status: item.status, notes: item.notes }).eq('id', item.id)
    if (error) throw error
    await loadDashboard()
    notify('Status inquiry diperbarui.')
  } catch (error) {
    notify(`Tidak dapat memperbarui: ${error.message}`, 'error')
  } finally {
    saving.value = false
  }
}
async function invokeAdminUsers(body) {
  const { data, error } = await supabase.functions.invoke('admin-users', { body })
  if (error) {
    let message = error.message
    const status = error.context instanceof Response ? error.context.status : null
    try {
      const detail = await error.context?.json()
      if (detail?.error) message = detail.error
    } catch {
      const cause = error.context?.cause
      if (cause instanceof Error) message = `${message} (${cause.message})`
    }
    if (error.name === 'FunctionsFetchError') {
      message = 'Tidak dapat terhubung ke Edge Function admin-users. Pastikan fungsi sudah di-deploy ke proyek Supabase yang sama dengan VITE_SUPABASE_URL, lalu coba lagi.'
    } else if (status === 404) {
      message = 'Edge Function admin-users belum ditemukan di proyek Supabase. Deploy fungsi ke proyek yang sama dengan VITE_SUPABASE_URL, lalu coba lagi.'
    }
    throw new Error(message)
  }
  if (data?.error) throw new Error(data.error)
  return data
}
async function loadAdminAccounts() {
  if (isLocalDemo || !isSuperAdmin.value) return true
  accountsLoading.value = true
  try {
    const { users } = await invokeAdminUsers({ action: 'list' })
    dataSets.value.profiles = users
    return true
  } catch (error) {
    notify(`Tidak dapat memuat akun admin: ${error.message}`, 'error')
    return false
  } finally {
    accountsLoading.value = false
  }
}
function startNewAccount() {
  accountEditing.value = 'new'
  accountForm.value = { full_name: '', email: '', password: '', role: 'editor' }
}
function editAccount(account) {
  accountEditing.value = account.id
  accountForm.value = { full_name: account.full_name || '', email: account.email || '', password: '', role: account.role }
}
function cancelAccountEdit() {
  accountEditing.value = null
  accountForm.value = { full_name: '', email: '', password: '', role: 'editor' }
}
async function saveAccount() {
  if (!isSuperAdmin.value) {
    notify('Hanya super admin yang dapat mengelola akun.', 'error')
    return
  }
  const fullName = accountForm.value.full_name.trim()
  const email = accountForm.value.email.trim().toLowerCase()
  const password = accountForm.value.password
  if (fullName.length < 2 || fullName.length > 120 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    notify('Isi nama (2–120 karakter) dan alamat email yang valid.', 'error')
    return
  }
  if (accountEditing.value === 'new' && password.length < 8) {
    notify('Kata sandi akun baru harus minimal 8 karakter.', 'error')
    return
  }
  if (password && password.length < 8) {
    notify('Kata sandi baru harus minimal 8 karakter.', 'error')
    return
  }
  saving.value = true
  try {
    const body = {
      action: accountEditing.value === 'new' ? 'create' : 'update',
      id: accountEditing.value === 'new' ? undefined : accountEditing.value,
      full_name: fullName,
      email,
      role: accountForm.value.role,
      ...(password ? { password } : {}),
    }
    if (isLocalDemo) {
      const current = dataSets.value.profiles
      const duplicateEmail = current.some((account) => account.email?.toLowerCase() === email && account.id !== accountEditing.value)
      if (duplicateEmail) throw new Error('Email sudah digunakan oleh akun lain.')
      dataSets.value.profiles = accountEditing.value === 'new'
        ? [...current, { id: `demo-${Date.now()}`, full_name: fullName, email, role: accountForm.value.role, created_at: new Date().toISOString() }]
        : current.map((account) => account.id === accountEditing.value ? { ...account, full_name: fullName, email, role: accountForm.value.role } : account)
      localStorage.setItem('anaj-demo-admin-users', JSON.stringify(dataSets.value.profiles))
    } else {
      await invokeAdminUsers(body)
      const refreshed = await loadAdminAccounts()
      if (!refreshed) {
        cancelAccountEdit()
        return
      }
    }
    cancelAccountEdit()
    notify(isLocalDemo ? 'Akun demo diperbarui pada browser ini saja.' : 'Akun admin berhasil disimpan.')
  } catch (error) {
    notify(`Tidak dapat menyimpan akun: ${error.message}`, 'error')
  } finally {
    saving.value = false
  }
}
async function deleteAccount(account) {
  if (!isSuperAdmin.value) {
    notify('Hanya super admin yang dapat menghapus akun.', 'error')
    return
  }
  if (account.id === profile.value.id || (isLocalDemo && account.id === 'demo-super')) {
    notify('Akun yang sedang digunakan tidak dapat dihapus.', 'error')
    return
  }
  if (!window.confirm(`Hapus akun ${account.email || account.full_name}? Pengguna ini tidak dapat masuk lagi.`)) return
  saving.value = true
  try {
    if (isLocalDemo) {
      dataSets.value.profiles = dataSets.value.profiles.filter((item) => item.id !== account.id)
      localStorage.setItem('anaj-demo-admin-users', JSON.stringify(dataSets.value.profiles))
    } else {
      await invokeAdminUsers({ action: 'delete', id: account.id })
      if (!(await loadAdminAccounts())) return
    }
    if (accountEditing.value === account.id) cancelAccountEdit()
    notify(isLocalDemo ? 'Akun demo dihapus dari browser ini.' : 'Akun admin berhasil dihapus.')
  } catch (error) {
    notify(`Tidak dapat menghapus akun: ${error.message}`, 'error')
  } finally {
    saving.value = false
  }
}
async function updateProfileRole(item, nextRole) {
  if (!isSuperAdmin.value || !['super_admin', 'editor'].includes(nextRole)) {
    notify('Perubahan role hanya dapat dilakukan oleh super admin.', 'error')
    return
  }
  if ((item.id === profile.value.id || (isLocalDemo && item.id === 'demo-super')) && nextRole !== 'super_admin') {
    notify('Anda tidak dapat menurunkan role akun yang sedang digunakan.', 'error')
    await loadAdminAccounts()
    return
  }
  if (item.role === nextRole) return
  saving.value = true
  try {
    if (isLocalDemo) {
      dataSets.value.profiles = dataSets.value.profiles.map((entry) => entry.id === item.id ? { ...entry, role: nextRole } : entry)
      localStorage.setItem('anaj-demo-admin-users', JSON.stringify(dataSets.value.profiles))
    } else {
      await invokeAdminUsers({ action: 'update', id: item.id, role: nextRole })
      if (!(await loadAdminAccounts())) return
    }
    notify('Hak akses akun berhasil diperbarui.')
  } catch (error) {
    notify(`Tidak dapat mengubah role: ${error.message}`, 'error')
    await loadAdminAccounts()
  } finally {
    saving.value = false
  }
}
function togglePublished(item) {
  const field = item.is_published !== undefined ? 'is_published' : 'is_enabled'
  form.value = { ...item, [field]: !item[field] }
  editing.value = item.id
  saveRow()
}
async function logout() {
  accountMenuOpen.value = false
  if (!isLocalDemo) {
    const { error } = await supabase.auth.signOut()
    if (error) notify(`Tidak dapat keluar: ${error.message}`, 'error')
  }
  await router.replace('/admin/login')
}
async function uploadMedia(event) {
  const files = Array.from(event.target.files || [])
  if (!files.length) return
  if (!supabaseConfigured) {
    notify('Unggah media memerlukan konfigurasi Supabase Storage.', 'error')
    return
  }
  saving.value = true
  try {
    for (const file of files) {
      const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '-')
      const path = `${Date.now()}-${safeName}`
      const { error } = await supabase.storage.from('portfolio-media').upload(path, file, { upsert: false, contentType: file.type })
      if (error) throw error
      const { data: { publicUrl } } = supabase.storage.from('portfolio-media').getPublicUrl(path)
      const title = file.name.replace(/\.[^.]+$/, '')
      const slug = `${slugify(title)}-${Date.now()}`
      const isVideo = file.type.startsWith('video/')
      const { data: portfolio, error: portfolioError } = await supabase.from('portfolios').insert({ title, slug, category: 'Lainnya', cover_image_url: isVideo ? '' : publicUrl, is_published: false }).select('id').single()
      if (portfolioError) throw portfolioError
      const { error: mediaError } = await supabase.from('portfolio_media').insert({ portfolio_id: portfolio.id, storage_path: path, media_url: publicUrl, media_type: isVideo ? 'video' : 'image', alt_text: title })
      if (mediaError) throw mediaError
    }
    await loadDashboard()
    notify(`${files.length} file berhasil diunggah sebagai draft portofolio.`)
  } catch (error) {
    notify(`Unggah gagal: ${error.message}`, 'error')
  } finally {
    saving.value = false
    event.target.value = ''
  }
}
function displayValue(item, field) {
  const value = item[field]
  if (field === 'category_id') return dataSets.value.categories.find((category) => category.id === value)?.name || value || '—'
  if (field === 'service_id') return dataSets.value.services.find((service) => service.id === value)?.title || value || '—'
  if (field === 'price' && value !== undefined) return formatPrice(value)
  if (field === 'is_published' || field === 'is_enabled') return value ? 'Aktif' : 'Draft'
  if (Array.isArray(value)) return value.join(', ')
  if (typeof value === 'object' && value) return JSON.stringify(value)
  return value || '—'
}
onMounted(loadDashboard)
</script>

<template>
  <div class="admin-shell" :class="{ 'admin-sidebar-open': sidebarOpen, 'admin-editor': !isSuperAdmin }">
    <button v-if="sidebarOpen" class="sidebar-backdrop" aria-label="Tutup menu" @click="sidebarOpen = false"></button>
    <aside class="admin-sidebar">
      <RouterLink to="/" class="brand admin-brand"><span class="brand-mark">A<span>J</span></span><span class="brand-name">abadi nan jaya<small>ADMIN STUDIO</small></span></RouterLink>
      <div class="workspace-label">WORKSPACE <span>LIVE</span></div>
      <nav class="admin-nav"><button v-for="item in menu" :key="item.id" type="button" :class="{ active: active === item.id }" @click="setPage(item.id)"><component :is="item.icon" :size="17" /><span>{{ item.label }}</span><i v-if="item.id === 'inquiries' && counts.newInquiries">{{ counts.newInquiries }}</i><i v-else-if="item.id === 'bookings' && bookingInquiries.length">{{ bookingInquiries.length }}</i></button></nav>
      <div class="sidebar-bottom"><a class="view-site" href="/" target="_blank" rel="noreferrer"><ArrowUpRight :size="15" /> Lihat situs</a><div class="admin-user"><span class="admin-avatar">{{ (profile.full_name || 'A').charAt(0) }}</span><span class="admin-user-info"><strong>{{ profile.full_name || 'Admin Abadi nan Jaya' }}</strong><small>{{ isLocalDemo ? 'Mode demo' : role.replace('_', ' ') }}</small></span></div><button class="sidebar-logout" type="button" @click="logout"><LogOut :size="15" /> Keluar dari admin</button></div>
    </aside>
    <main class="admin-main">
      <header class="admin-topbar"><button class="mobile-menu admin-menu-toggle" aria-label="Buka menu" @click="sidebarOpen = true"><Menu :size="20" /></button><div class="admin-breadcrumb">Workspace <span>/</span> <strong>{{ menu.find((item) => item.id === active)?.label }}</strong></div><div class="admin-top-actions"><span class="admin-status"><i></i> Situs aktif</span><div class="account-menu-wrap"><button class="account-menu-trigger" type="button" :aria-expanded="accountMenuOpen" @click="accountMenuOpen = !accountMenuOpen"><span class="admin-top-avatar">{{ (profile.full_name || 'A').charAt(0) }}</span><ChevronDown :size="14" /></button><div v-if="accountMenuOpen" class="account-menu"><strong>{{ profile.full_name || 'Admin Abadi nan Jaya' }}</strong><small>{{ isLocalDemo ? 'Mode demo' : role.replace('_', ' ') }}</small><button type="button" @click="logout"><LogOut :size="15" /> Keluar dari admin</button></div></div></div></header>
      <div class="admin-content">
        <div class="admin-page-heading"><div><span class="eyebrow">{{ active === 'dashboard' ? 'RINGKASAN HARI INI' : 'KELOLA KONTEN' }}</span><h1>{{ active === 'dashboard' ? 'Ruang cerita Anda.' : headings[active] }}</h1><p>{{ active === 'dashboard' ? 'Berikut yang terjadi di Abadi nan Jaya.' : `Atur dan perbarui ${headings[active]?.toLowerCase()} tanpa menyentuh kode.` }}</p></div><button v-if="['services','categories','packages','portfolios','faqs','contacts','testimonials','landing_sections','clients','price_list'].includes(active) || (isSuperAdmin && ['site_settings','profiles'].includes(active))" class="button button-dark admin-add" @click="active === 'profiles' ? startNewAccount() : newRow()"><Plus :size="16" /> {{ active === 'profiles' ? 'Tambah akun' : 'Tambah baru' }}</button></div>
        <div v-if="isLocalDemo" class="demo-banner"><span>Mode preview lokal.</span> Data pengelolaan contoh tidak tersimpan permanen. Konfigurasikan Supabase untuk mengaktifkan dashboard penuh.</div>
        <div v-else-if="!isSuperAdmin" class="demo-banner"><span>Akses editor.</span> Anda dapat mengelola konten dan tindak lanjut inquiry. Pengaturan situs, penghapusan konten, serta pengelolaan role hanya tersedia bagi super admin.</div>
        <div v-if="notice" class="admin-error"><span>{{ notice }}</span><button @click="loadDashboard">Coba lagi</button></div>
        <template v-if="active === 'dashboard'">
          <div class="admin-stats"><article class="stat-card"><span>SEMUA PERTANYAAN</span><div><strong>{{ counts.inquiries }}</strong><span class="stat-icon stat-icon-peach"><MessageSquareText :size="18" /></span></div><small>Total inquiry masuk</small></article><article class="stat-card"><span>PERLU DITINDAKLANJUTI</span><div><strong>{{ counts.newInquiries }}</strong><span class="stat-icon stat-icon-gold"><Activity :size="18" /></span></div><small>Pertanyaan berstatus baru</small></article><article class="stat-card"><span>LAYANAN AKTIF</span><div><strong>{{ counts.services }}</strong><span class="stat-icon stat-icon-green"><BookOpen :size="18" /></span></div><small>Di seluruh kategori</small></article><article class="stat-card"><span>PORTOFOLIO</span><div><strong>{{ counts.portfolios }}</strong><span class="stat-icon stat-icon-blue"><FileImage :size="18" /></span></div><small>Cerita yang dipublikasikan</small></article></div>
          <div class="admin-overview-grid"><section class="admin-panel inquiry-panel"><div class="panel-heading"><div><h2>Pertanyaan terbaru</h2><p>Percakapan yang masuk dari formulir situs.</p></div><button class="text-link" @click="setPage('inquiries')">Lihat semua <ArrowRight :size="14" /></button></div><div v-if="loading" class="admin-loading"><span class="skeleton skeleton-card"></span></div><div v-else-if="inquiries.length" class="recent-list"><article v-for="item in inquiries.slice(0, 5)" :key="item.id" class="recent-inquiry"><span class="inquiry-initial">{{ item.name?.charAt(0) }}</span><div class="recent-main"><strong>{{ item.name }}</strong><small>{{ item.event_type }} · {{ dateLabel(item.created_at) }}</small></div><span class="status-pill" :class="`status-${item.status}`">{{ item.status }}</span><button aria-label="Lihat inquiry" @click="setPage('inquiries')"><ArrowRight :size="15" /></button></article></div><div v-else class="admin-empty"><MessageSquareText :size="24" /><strong>Belum ada pertanyaan</strong><span>Pertanyaan dari formulir publik akan muncul di sini.</span></div></section>
            <section class="admin-panel popular-panel"><div class="panel-heading"><div><h2>Layanan populer</h2><p>Jumlah layanan per kategori.</p></div></div><div class="popular-list"><div v-for="item in serviceCounts" :key="item.name" class="popular-row"><span>{{ item.name }}</span><div class="popular-track"><i :style="{ width: `${Math.max(8, item.value / Math.max(...serviceCounts.map((row) => row.value), 1) * 100)}%` }"></i></div><strong>{{ item.value }}</strong></div></div><RouterLink class="popular-link" to="/layanan" target="_blank">Lihat katalog publik <ArrowUpRight :size="14" /></RouterLink></section></div>
          <section class="admin-panel quick-panel"><div class="panel-heading"><div><h2>Kelola situs Anda</h2><p>Akses cepat ke hal-hal yang paling sering diperbarui.</p></div></div><div class="quick-actions"><button v-for="item in menu.slice(1, 6)" :key="item.id" @click="setPage(item.id)"><component :is="item.icon" :size="18" /><span>{{ item.label }}</span><ArrowRight :size="15" /></button></div></section>
        </template>
        <template v-else-if="active === 'bookings'">
          <div class="admin-stats booking-admin-stats">
            <article class="stat-card"><span>SEMUA BOOKING</span><div><strong>{{ bookingInquiries.length }}</strong><span class="stat-icon stat-icon-peach"><CalendarDays :size="18" /></span></div><small>Permintaan dengan detail rencana acara</small></article>
            <article class="stat-card"><span>PERLU DITINDAKLANJUTI</span><div><strong>{{ bookingInquiries.filter((item) => item.status === 'baru').length }}</strong><span class="stat-icon stat-icon-gold"><Activity :size="18" /></span></div><small>Booking baru belum diproses</small></article>
            <article class="stat-card"><span>ACARA MENDATANG</span><div><strong>{{ upcomingBookings }}</strong><span class="stat-icon stat-icon-green"><CalendarDays :size="18" /></span></div><small>Tanggal acara hari ini atau berikutnya</small></article>
            <article class="stat-card"><span>INSTANSI / SEKOLAH</span><div><strong>{{ organizationBookings }}</strong><span class="stat-icon stat-icon-blue"><Users :size="18" /></span></div><small>Permintaan dari organisasi</small></article>
          </div>
          <section class="admin-panel table-panel">
            <div class="table-toolbar"><label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari nama, instansi, kota..."></label><select v-model="filterStatus" class="select-control"><option value="semua">Semua status</option><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option></select><button class="button button-outline export-button" @click="exportCsv"><ArrowDownToLine :size="15" /> Ekspor booking CSV</button></div>
            <div class="table-scroll"><table class="admin-table booking-admin-table"><thead><tr><th>PIC & KONTAK</th><th>PEMESAN / PAKET</th><th>ACARA & JADWAL</th><th>ADD-ON</th><th>STATUS</th><th>CATATAN INTERNAL</th></tr></thead><tbody>
              <tr v-for="item in filteredBookings" :key="item.id">
                <td><strong>{{ item.name }}</strong><small>{{ item.email }} · {{ item.phone }}</small></td>
                <td>{{ item.booking_type === 'organization' ? item.organization_name || 'Instansi / sekolah' : 'Personal' }}<small>{{ item.organization_type || '' }} {{ item.contact_position ? `· ${item.contact_position}` : '' }}</small><small>{{ dataSets.packages.find((entry) => entry.id === item.package_id)?.name || (item.package_id ? 'Paket terpilih' : 'Minta rekomendasi') }}</small></td>
                <td>{{ item.event_type || '—' }}<small>{{ item.event_date ? dateLabel(item.event_date) : 'Tanggal fleksibel' }} {{ item.event_start_time ? `· ${item.event_start_time}` : '' }}</small><small>{{ item.guest_count ? `${item.guest_count} peserta/tamu` : '' }} {{ item.event_city ? `· ${item.event_city}` : '' }}</small><small>{{ item.event_location || '' }}</small><details class="inquiry-message"><summary>Lihat detail & kebutuhan</summary><p>{{ item.message }}</p><div v-if="item.special_requirements"><strong>Kebutuhan khusus:</strong> {{ item.special_requirements }}</div></details></td>
                <td><span v-if="item.selected_addons?.length" v-for="addon in item.selected_addons" :key="addon.id || addon.name" class="booking-admin-addon">{{ addon.name }} × {{ addon.quantity || 1 }}<small>{{ formatPrice((addon.price || 0) * (addon.quantity || 1)) }}</small></span><small v-else>Belum dipilih</small></td>
                <td><select v-model="item.status" class="status-select" :class="`status-${item.status}`" :disabled="saving" @change="updateInquiry(item)"><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option></select></td>
                <td><input v-model="item.notes" class="notes-input" placeholder="Catatan internal" @change="updateInquiry(item)"></td>
              </tr>
            </tbody></table></div>
            <div v-if="!filteredBookings.length" class="admin-empty"><CalendarDays :size="25" /><strong>Belum ada booking ditemukan</strong><span>Booking yang dikirim melalui formulir akan dirangkum di halaman ini.</span></div>
          </section>
        </template>
        <template v-else-if="active === 'inquiries'">
          <section class="admin-panel table-panel"><div class="table-toolbar"><label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari nama, email, acara..."></label><select v-model="filterStatus" class="select-control"><option value="semua">Semua status</option><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option></select><button class="button button-outline export-button" @click="exportCsv"><ArrowDownToLine :size="15" /> Ekspor CSV</button></div><div class="table-scroll"><table class="admin-table"><thead><tr><th>PIC & KONTAK</th><th>PEMESAN / PAKET</th><th>DETAIL ACARA</th><th>DITERIMA</th><th>STATUS</th><th>CATATAN</th></tr></thead><tbody><tr v-for="item in filteredInquiries" :key="item.id"><td><strong>{{ item.name }}</strong><small>{{ item.email }} · {{ item.phone }}</small><details class="inquiry-message"><summary>Pesan & add-on</summary><p>{{ item.message }}</p><div v-if="item.selected_addons?.length" class="inquiry-addon-summary"><strong>Tambahan yang dipilih:</strong><span v-for="addon in item.selected_addons" :key="addon.id || addon.name">{{ addon.name }} × {{ addon.quantity || 1 }} — {{ formatPrice((addon.price || 0) * (addon.quantity || 1)) }}</span></div><div v-if="item.special_requirements"><strong>Kebutuhan khusus:</strong> {{ item.special_requirements }}</div></details></td><td>{{ item.booking_type === 'organization' ? item.organization_name || 'Instansi / sekolah' : 'Personal' }}<small>{{ item.organization_type || '' }} {{ item.contact_position ? `· ${item.contact_position}` : '' }}</small><small>{{ dataSets.packages.find((entry) => entry.id === item.package_id)?.name || (item.package_id ? 'Paket terpilih' : 'Minta rekomendasi') }}</small></td><td>{{ item.event_type || '—' }}<small>{{ item.guest_count ? `${item.guest_count} peserta/tamu` : '' }}</small><small>{{ item.event_date ? dateLabel(item.event_date) : 'Fleksibel' }} {{ item.event_start_time ? `· ${item.event_start_time}` : '' }}</small><small>{{ [item.event_location, item.event_city].filter(Boolean).join(' · ') }}</small></td><td>{{ dateLabel(item.created_at) }}</td><td><select v-model="item.status" class="status-select" :class="`status-${item.status}`" :disabled="saving" @change="updateInquiry(item)"><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option></select></td><td><input v-model="item.notes" class="notes-input" placeholder="Catatan internal" @change="updateInquiry(item)"></td></tr></tbody></table></div><div v-if="!filteredInquiries.length" class="admin-empty"><MessageSquareText :size="25" /><strong>Tidak ada pertanyaan ditemukan</strong><span>Pesan publik atau ubah filter pencarian.</span></div></section>
        </template>
        <template v-else>
          <section v-if="active === 'profiles'" class="admin-panel role-management">
            <div class="panel-heading"><div><h2>Kelola akun admin</h2><p>Buat akun, perbarui detail dan hak akses, atau hapus akses pengguna admin.</p></div></div>
            <div v-if="isLocalDemo" class="demo-banner account-demo-note"><span>Mode demo.</span> Perubahan akun hanya tersimpan di browser ini dan tidak membuat pengguna Supabase sungguhan.</div>
            <div v-if="accountEditing" class="admin-account-form">
              <div class="panel-heading"><h3>{{ accountEditing === 'new' ? 'Buat akun admin' : 'Ubah akun admin' }}</h3><button class="icon-button" type="button" @click="cancelAccountEdit"><X :size="18" /></button></div>
              <div class="edit-fields">
                <label class="field"><span>Nama lengkap</span><input v-model.trim="accountForm.full_name" type="text" maxlength="120" autocomplete="name" required></label>
                <label class="field"><span>Email</span><input v-model.trim="accountForm.email" type="email" maxlength="254" autocomplete="email" required></label>
                <label class="field"><span>{{ accountEditing === 'new' ? 'Kata sandi awal' : 'Kata sandi baru (opsional)' }}</span><input v-model="accountForm.password" type="password" minlength="8" :required="accountEditing === 'new'" :autocomplete="accountEditing === 'new' ? 'new-password' : 'new-password'" :placeholder="accountEditing === 'new' ? 'Minimal 8 karakter' : 'Kosongkan jika tidak diubah'"></label>
                <label class="field"><span>Hak akses</span><select v-model="accountForm.role"><option value="editor">Editor</option><option value="super_admin">Super admin</option></select></label>
              </div>
              <div class="edit-actions"><button class="button button-outline" type="button" :disabled="saving" @click="cancelAccountEdit">Batal</button><button class="button button-dark" type="button" :disabled="saving" @click="saveAccount">{{ saving ? 'Menyimpan...' : 'Simpan akun' }}</button></div>
            </div>
            <div class="table-toolbar account-toolbar"><label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari nama atau email akun..."></label><span class="table-total">{{ dataSets.profiles.length }} akun</span></div>
            <div v-if="accountsLoading" class="admin-loading"><span class="skeleton skeleton-card"></span></div>
            <div v-else class="table-scroll"><table class="admin-table"><thead><tr><th>NAMA AKUN</th><th>EMAIL</th><th>HAK AKSES</th><th>DIBUAT</th><th>AKSI</th></tr></thead><tbody>
              <tr v-for="item in dataSets.profiles.filter((row) => `${row.full_name} ${row.email} ${row.id}`.toLowerCase().includes(query.toLowerCase()))" :key="item.id">
                <td><strong>{{ item.full_name || 'Admin tanpa nama' }}</strong><small>{{ item.id === profile.id || (isLocalDemo && item.id === 'demo-super') ? 'Akun yang sedang digunakan' : 'Akun staf' }}</small></td>
                <td>{{ item.email || '—' }}</td>
                <td><select class="status-select" :value="item.role" :disabled="saving || item.id === profile.id || (isLocalDemo && item.id === 'demo-super')" :aria-label="`Role ${item.full_name || item.id}`" @change="updateProfileRole(item, $event.target.value)"><option value="editor">Editor</option><option value="super_admin">Super admin</option></select></td>
                <td>{{ dateLabel(item.created_at) }}</td>
                <td class="row-actions"><button class="row-edit" type="button" :disabled="saving" aria-label="Ubah akun" @click="editAccount(item)"><Pencil :size="14" /> Ubah</button><button class="row-delete" type="button" :disabled="saving || item.id === profile.id || (isLocalDemo && item.id === 'demo-super')" aria-label="Hapus akun" @click="deleteAccount(item)"><Trash2 :size="14" /> Hapus</button></td>
              </tr>
            </tbody></table></div>
            <div v-if="!accountsLoading && !dataSets.profiles.length" class="admin-empty"><strong>Belum ada akun admin</strong><span>Gunakan tombol Tambah akun untuk membuat akun pertama.</span></div>
          </section>
          <template v-if="active !== 'profiles'">
          <section v-if="active === 'portfolios'" class="admin-panel upload-panel"><span class="upload-icon"><FileImage :size="22" /></span><div><strong>Unggah foto atau video portofolio</strong><p>Pilih beberapa file untuk menyimpan foto ke Supabase Storage dan menghubungkannya ke portofolio.</p><label class="button button-dark upload-button">Pilih file<input type="file" accept="image/*,video/*" multiple @change="uploadMedia"></label></div></section>
          <section class="admin-panel table-panel"><div class="table-toolbar"><label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari konten..."></label><span class="table-total">{{ currentRows.filter((item) => JSON.stringify(item).toLowerCase().includes(query.toLowerCase())).length }} item</span><select v-if="['services','packages','portfolios','categories','faqs'].includes(active)" v-model="filterStatus" class="select-control"><option value="semua">Semua status</option><option value="published">Dipublikasikan</option><option value="draft">Draft</option></select></div>
            <div v-if="editing" class="admin-edit-form">
              <div class="panel-heading"><h2>{{ editing === 'new' ? 'Tambah item' : 'Edit item' }}</h2><button class="icon-button" @click="cancelEdit"><X :size="18" /></button></div>
              <div class="edit-fields">
                <template v-for="(value, key) in form" :key="key">
                  <label v-if="key !== 'id' && key !== 'created_at' && key !== 'updated_at' && key !== 'sort_order' && key !== 'metadata' && key !== 'addons' && key !== 'inclusions' && key !== 'media' && key !== 'value' && key !== 'package_id' && key !== 'category_id' && key !== 'service_id' && key !== 'is_public' && !['image_url', 'cover_image_url', 'logo_url', 'avatar_url'].includes(key)" class="field">
                    <span>{{ key.replaceAll('_', ' ') }}</span>
                    <select v-if="typeof value === 'boolean'" v-model="form[key]"><option :value="true">Aktif</option><option :value="false">Draft</option></select>
                    <textarea v-else-if="['description','summary','answer','quote','subtitle','body','message','notes','address'].includes(key)" v-model="form[key]" rows="3"></textarea>
                    <input v-else-if="key === 'price' || key === 'rating' || key === 'guest_count'" v-model.number="form[key]" type="number" min="0">
                    <input v-else v-model="form[key]" :type="key === 'email' ? 'email' : 'text'">
                  </label>
                  <label v-if="key === 'sort_order'" class="field"><span>Urutan</span><input v-model.number="form[key]" type="number" min="0"></label>
                  <label v-if="key === 'category_id'" class="field"><span>Kategori</span><select v-model="form[key]"><option value="">Pilih kategori</option><option v-for="category in dataSets.categories" :key="category.id" :value="category.id">{{ category.name }}</option></select></label>
                  <label v-if="key === 'service_id'" class="field"><span>Layanan</span><select v-model="form[key]"><option value="">Pilih layanan</option><option v-for="service in dataSets.services" :key="service.id" :value="service.id">{{ service.title }}</option></select></label>
                  <label v-if="key === 'value' && !(active === 'site_settings' && form.key === 'logo_url')" class="field"><span>Nilai</span><input v-model="form.value" type="text"></label>
                  <label v-if="key === 'inclusions'" class="field field-wide"><span>Isi paket (pisahkan dengan koma)</span><textarea :value="form.inclusions.join(', ')" rows="2" @input="form.inclusions = $event.target.value.split(',').map((item) => item.trim())"></textarea></label>
                  <label v-if="key === 'addons'" class="field field-wide"><span>Add-on / peralatan (satu item per baris: nama | harga | deskripsi)</span><textarea :value="form.addons.map((addon) => `${addon.name || addon} | ${addon.price || 0} | ${addon.description || ''}`).join('\n')" rows="5" @input="form.addons = $event.target.value.split('\n').map((line) => { const [name, price = '0', description = ''] = line.split('|'); return { name: name.trim(), price: Number(price.trim()) || 0, description: description.trim() } }).filter((addon) => addon.name)"></textarea></label>
                </template>
                <label v-for="key in imageFieldKeys" :key="`image-${key}`" class="field field-wide admin-image-field">
                  <span>{{ key === 'cover_image_url' ? 'Gambar sampul' : key === 'logo_url' || (active === 'site_settings' && key === 'value') ? 'Logo situs' : key === 'avatar_url' ? 'Foto profil' : 'Gambar' }} <small>Pilih berkas gambar dari perangkat Anda.</small></span>
                  <input type="file" accept="image/jpeg,image/png,image/webp,image/avif,image/gif" :disabled="saving" @change="selectImage($event, key)">
                  <img v-if="form[key]" class="admin-image-preview" :src="form[key]" alt="Pratinjau gambar terpilih">
                </label>
              </div>
              <div class="edit-actions"><button class="button button-outline" @click="cancelEdit">Batal</button><button class="button button-dark" :disabled="saving" @click="saveRow">{{ saving ? 'Menyimpan...' : 'Simpan perubahan' }}</button></div>
            </div>
            <div class="table-scroll"><table v-if="active !== 'site_settings'" class="admin-table"><thead><tr><th v-for="field in (active === 'services' ? ['title','category_id','summary','is_published'] : active === 'categories' ? ['name','slug','description','sort_order'] : active === 'packages' ? ['name','service_id','price','is_published'] : active === 'portfolios' ? ['title','category','is_published'] : active === 'faqs' ? ['question','answer','is_published'] : active === 'landing_sections' ? ['section_key','title','is_enabled'] : active === 'contacts' ? ['name','division','phone'] : active === 'clients' ? ['name','website_url','is_published'] : ['name','role','is_published'])" :key="field">{{ field.replaceAll('_',' ').toUpperCase() }}</th><th>AKSI</th></tr></thead><tbody><tr v-for="item in currentRows.filter((row) => JSON.stringify(row).toLowerCase().includes(query.toLowerCase()) && (filterStatus === 'semua' || (filterStatus === 'published' ? row.is_published : !row.is_published)))" :key="item.id"><td v-for="field in (active === 'services' ? ['title','category_id','summary','is_published'] : active === 'categories' ? ['name','slug','description','sort_order'] : active === 'packages' ? ['name','service_id','price','is_published'] : active === 'portfolios' ? ['title','category','is_published'] : active === 'faqs' ? ['question','answer','is_published'] : active === 'landing_sections' ? ['section_key','title','is_enabled'] : active === 'contacts' ? ['name','division','phone'] : active === 'clients' ? ['name','website_url','is_published'] : ['name','role','is_published'])" :key="field">{{ displayValue(item, field) }}</td><td class="row-actions"><button class="row-edit" @click="editRow(item)">Edit</button><button v-if="item.is_published !== undefined || item.is_enabled !== undefined" class="row-toggle" @click="togglePublished(item)">{{ (item.is_published ?? item.is_enabled) ? 'Sembunyikan' : 'Publikasikan' }}</button><button v-if="isSuperAdmin" class="row-delete" @click="deleteRow(item)">Hapus</button></td></tr></tbody></table>
              <div v-if="active === 'site_settings'" class="settings-list"><article v-for="item in dataSets.site_settings" :key="item.id || item.key" class="setting-row"><div><strong>{{ item.label || item.key?.replaceAll('_',' ') || item.name }}</strong><small>Pengaturan situs</small></div><input v-model="item.value" @change="editRow(item)"><button class="row-edit" @click="editRow(item)">Ubah</button></article></div>
              <div v-if="!currentRows.length" class="admin-empty"><span>Belum ada konten. Mulai dengan menambahkan item baru.</span></div></div>
          </section>
          </template>
        </template>
        <div class="admin-footer">ABADI NAN JAYA · ADMIN STUDIO <span>{{ new Date().getFullYear() }}</span></div>
      </div>
    </main>
  </div>
</template>
