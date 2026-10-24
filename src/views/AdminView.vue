<script setup>
import { computed, nextTick, onMounted, ref } from 'vue'
import { Activity, ArrowDownToLine, ArrowRight, ArrowUpRight, BookOpen, CalendarDays, ChevronDown, CircleHelp, FileImage, LayoutDashboard, LogOut, Menu, MessageSquareText, Package, Pencil, Plus, Search, Settings, ShieldCheck, Trash2, Users, X } from '@lucide/vue'
import Swal from 'sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'
import { useRoute, useRouter } from 'vue-router'
import { supabase, supabaseConfigured } from '../lib/supabase'
import { toLocalIndonesianPhone, toWhatsAppPhone } from '../lib/phone'
import { demoCategories, demoFaqs, demoLandingSections, demoPackages, demoServices, demoTestimonials, formatPrice, localImages } from '../data/demo'
import { useToast } from '../composables/useToast'
import { useSiteStore } from '../stores/site'
import CurrencyInput from '../components/CurrencyInput.vue'

const route = useRoute()
const router = useRouter()
const { notify } = useToast()
const publicSite = useSiteStore()
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
const filterDay = ref('semua')
const filterMonth = ref('semua')
const filterYear = ref('semua')
const selectionMode = ref(false)
const selectedInquiryIds = ref([])
const deletingInquiries = ref(false)
const inquiries = ref([])
const counts = ref({ inquiries: 0, newInquiries: 0, newBookings: 0, services: 0, portfolios: 0, packages: 0 })
const dataSets = ref({ services: [], categories: [], packages: [], portfolios: [], testimonials: [], faqs: [], contacts: [], clients: [], price_list: [], landing_sections: [], event_types: [], site_settings: [], profiles: [] })
const serviceCounts = ref([])
const notice = ref('')
const editing = ref(null)
const formErrors = ref({})
const accountErrors = ref({})
const mapLocationErrors = ref({})
const saving = ref(false)
const form = ref({})
const pendingImages = ref({})
const pendingLandingBlockImages = ref({})
const accountEditing = ref(null)
const accountForm = ref({ full_name: '', email: '', password: '', role: 'editor' })
const accountsLoading = ref(false)
const imageFieldKeys = computed(() => {
  const fields = ['image_url', 'cover_image_url', 'logo_url', 'avatar_url'].filter((key) => key in form.value)
  if (active.value === 'site_settings' && form.value.key === 'logo_url' && !fields.includes('value')) fields.push('value')
  return fields
})
const selectedPackageEventType = computed(() => dataSets.value.event_types.find((eventType) => eventType.id === form.value.event_type_id))
const packageServices = computed(() => dataSets.value.services.filter((service) =>
  selectedPackageEventType.value?.service_ids?.includes(service.id)))
const packageEventTypes = computed(() => dataSets.value.event_types.filter((eventType) =>
  eventType.is_published || eventType.id === form.value.event_type_id))
const landingBlockTypes = [
  { value: 'heading', label: 'Judul' },
  { value: 'text', label: 'Teks' },
  { value: 'image', label: 'Gambar' },
  { value: 'button', label: 'Tombol' },
  { value: 'quote', label: 'Kutipan' },
]
const allMenuItems = [
  { id: 'dashboard', label: 'Ringkasan', icon: LayoutDashboard },
  { id: 'inquiries', label: 'Pertanyaan', icon: MessageSquareText },
  { id: 'bookings', label: 'Booking acara', icon: CalendarDays },
  { id: 'event_types', label: 'Jenis acara booking', icon: CalendarDays },
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
const isBookingInquiry = (item) => Boolean(item.service_id || item.package_id || item.organization_name || item.event_city || item.event_location || item.selected_addons?.length)
const consultationInquiries = computed(() => inquiries.value.filter((item) => !isBookingInquiry(item)))
const receivedYears = computed(() => [...new Set(inquiries.value.map((item) => item.created_at ? new Date(item.created_at).getFullYear() : null).filter(Boolean))].sort((a, b) => b - a))
const monthOptions = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember']
const matchesReceivedDate = (item) => {
  if (!item.created_at) return filterDay.value === 'semua' && filterMonth.value === 'semua' && filterYear.value === 'semua'
  const received = new Date(item.created_at)
  return (filterDay.value === 'semua' || received.getDate() === Number(filterDay.value))
    && (filterMonth.value === 'semua' || received.getMonth() + 1 === Number(filterMonth.value))
    && (filterYear.value === 'semua' || received.getFullYear() === Number(filterYear.value))
}
const filteredInquiries = computed(() => consultationInquiries.value.filter((item) => (filterStatus.value === 'semua' || item.status === filterStatus.value) && matchesReceivedDate(item) && `${item.name} ${item.email} ${item.event_type} ${toLocalIndonesianPhone(item.phone)}`.toLowerCase().includes(query.value.toLowerCase())))
const bookingInquiries = computed(() => inquiries.value.filter(isBookingInquiry))
const filteredBookings = computed(() => bookingInquiries.value.filter((item) => (filterStatus.value === 'semua' || item.status === filterStatus.value) && matchesReceivedDate(item) && `${item.name} ${item.email} ${item.event_type} ${toLocalIndonesianPhone(item.phone)} ${item.organization_name || ''} ${item.event_city || ''}`.toLowerCase().includes(query.value.toLowerCase())))
const visibleInquiryRows = computed(() => active.value === 'bookings' ? filteredBookings.value : filteredInquiries.value)
const activeInquiryTypeRows = computed(() => active.value === 'bookings' ? bookingInquiries.value : consultationInquiries.value)
const visibleSelectedIds = computed(() => visibleInquiryRows.value.filter((item) => selectedInquiryIds.value.includes(item.id)).map((item) => item.id))
const allVisibleSelected = computed(() => visibleInquiryRows.value.length > 0 && visibleSelectedIds.value.length === visibleInquiryRows.value.length)
const allTypeSelected = computed(() => activeInquiryTypeRows.value.length > 0 && activeInquiryTypeRows.value.every((item) => selectedInquiryIds.value.includes(item.id)))
const hasDateFilter = computed(() => filterDay.value !== 'semua' || filterMonth.value !== 'semua' || filterYear.value !== 'semua')
const dateFilterLabel = computed(() => {
  const parts = [
    filterDay.value === 'semua' ? '' : String(filterDay.value).padStart(2, '0'),
    filterMonth.value === 'semua' ? '' : monthOptions[Number(filterMonth.value) - 1],
    filterYear.value === 'semua' ? '' : filterYear.value,
  ].filter(Boolean)
  return parts.length ? parts.join(' ') : 'Semua tanggal'
})
const upcomingBookings = computed(() => bookingInquiries.value.filter((item) => item.event_date && item.event_date >= new Date().toISOString().slice(0, 10) && !['selesai', 'dibatalkan'].includes(item.status)).length)
const organizationBookings = computed(() => bookingInquiries.value.filter((item) => item.booking_type === 'organization' || item.organization_name).length)
const actionableBookings = computed(() => bookingInquiries.value.filter((item) => !['selesai', 'dibatalkan'].includes(item.status)))
const summaryItems = computed(() => menu.value
  .filter((item) => item.id !== 'dashboard')
  .map((item) => {
    const rows = dataSets.value[item.id] || []
    const value = item.id === 'inquiries' ? consultationInquiries.value.length
      : item.id === 'bookings' ? bookingInquiries.value.length
        : item.id === 'services' ? dataSets.value.services.length + dataSets.value.categories.length
          : item.id === 'packages' ? counts.value.packages
            : item.id === 'portfolios' ? counts.value.portfolios
          : rows.length
    const detail = item.id === 'inquiries' ? `${counts.value.newInquiries} perlu dibalas`
      : item.id === 'bookings' ? `${actionableBookings.value.length} perlu ditindaklanjuti`
        : item.id === 'services' ? `${dataSets.value.services.length} layanan · ${dataSets.value.categories.length} kategori`
          : item.id === 'packages' ? `${dataSets.value.packages.length} paket tersedia`
            : item.id === 'portfolios' ? 'Karya dan dokumentasi acara'
              : item.id === 'landing_sections' ? 'Susunan konten beranda'
                : item.id === 'site_settings' ? 'Identitas dan tampilan situs'
                  : item.id === 'profiles' ? 'Akun dan hak akses'
                    : 'Konten terkelola'
    return { ...item, value, detail }
  }))
const currentRows = computed(() => active.value === 'inquiries' ? filteredInquiries.value : active.value === 'bookings' ? filteredBookings.value : dataSets.value[active.value] || [])
const sortableTables = new Set(['services', 'categories', 'packages', 'portfolios', 'testimonials', 'faqs', 'contacts', 'clients', 'landing_sections', 'site_settings', 'price_list', 'event_types'])
const nextSortOrder = (table) => Math.max(0, ...(dataSets.value[table] || []).map((item, index) => {
  const order = Number(item.sort_order)
  return item.sort_order !== null && item.sort_order !== '' && Number.isFinite(order) ? order : index + 1
})) + 1
const fieldsForTable = (table) => ({
  services: ['title', 'category_id', 'summary', 'is_published'],
  categories: ['name', 'slug', 'description'],
  packages: ['name', 'event_type_id', 'service_id', 'price', 'is_published'],
  portfolios: ['title', 'category', 'is_published'],
  faqs: ['question', 'answer', 'is_published'],
  landing_sections: ['title', 'subtitle', 'is_enabled'],
  contacts: ['name', 'division', 'phone'],
  clients: ['name', 'website_url', 'is_published'],
  event_types: ['name', 'booking_type', 'is_published'],
})[table] || ['name', 'role', 'is_published']
const headings = { dashboard: 'Selamat datang kembali', inquiries: 'Pertanyaan masuk', bookings: 'Ringkasan booking', event_types: 'Jenis acara booking', services: 'Layanan & kategori', categories: 'Kategori layanan', packages: 'Paket & daftar harga', portfolios: 'Portofolio', testimonials: 'Testimoni', clients: 'Klien & partner', faqs: 'Pertanyaan umum', contacts: 'Kontak person', landing_sections: 'Konten halaman utama', site_settings: 'Pengaturan situs', profiles: 'Akun & hak akses' }
const dateLabel = (date) => date ? new Intl.DateTimeFormat('id-ID', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(date)) : '—'
const bookingContactName = (item) => item.booking_type === 'organization' ? item.organization_name || 'Instansi / sekolah' : item.name || 'Pelanggan personal'
const whatsappLink = (item) => `https://wa.me/${toWhatsAppPhone(item.phone)}?text=${encodeURIComponent(`Halo ${item.name}, kami menindaklanjuti permintaan ${item.event_type || 'acara'}${item.event_date ? ` pada ${dateLabel(item.event_date)}` : ''}.`)}`
const hasBookingConflict = (item) => Boolean(item.event_date && bookingInquiries.value.some((booking) => booking.id !== item.id && booking.event_date === item.event_date && booking.event_type === item.event_type && !['selesai', 'dibatalkan'].includes(booking.status)))
async function showDateFilter() {
  const dayOptions = Array.from({ length: 31 }, (_, index) => `<option value="${index + 1}" ${Number(filterDay.value) === index + 1 ? 'selected' : ''}>${index + 1}</option>`).join('')
  const monthSelectOptions = monthOptions.map((month, index) => `<option value="${index + 1}" ${Number(filterMonth.value) === index + 1 ? 'selected' : ''}>${month}</option>`).join('')
  const yearOptions = receivedYears.value.map((year) => `<option value="${year}" ${Number(filterYear.value) === year ? 'selected' : ''}>${year}</option>`).join('')
  const result = await Swal.fire({
    title: 'Filter tanggal diterima',
    html: `<div class="admin-date-filter"><label><span>Tanggal</span><select id="filter-day"><option value="semua">Semua</option>${dayOptions}</select></label><label><span>Bulan</span><select id="filter-month"><option value="semua">Semua</option>${monthSelectOptions}</select></label><label><span>Tahun</span><select id="filter-year"><option value="semua">Semua</option>${yearOptions}</select></label></div>`,
    customClass: { popup: 'admin-swal-popup', confirmButton: 'admin-swal-confirm', cancelButton: 'admin-swal-cancel', denyButton: 'admin-swal-deny' },
    showCancelButton: true,
    showDenyButton: true,
    confirmButtonText: 'Terapkan filter',
    denyButtonText: 'Reset filter',
    cancelButtonText: 'Batal',
    buttonsStyling: false,
    preConfirm: () => ({
      day: Swal.getPopup().querySelector('#filter-day').value,
      month: Swal.getPopup().querySelector('#filter-month').value,
      year: Swal.getPopup().querySelector('#filter-year').value,
    }),
  })
  if (result.isConfirmed) {
    filterDay.value = result.value.day
    filterMonth.value = result.value.month
    filterYear.value = result.value.year
  } else if (result.isDenied) {
    filterDay.value = 'semua'
    filterMonth.value = 'semua'
    filterYear.value = 'semua'
  }
}
function toggleSelectionMode() {
  selectionMode.value = !selectionMode.value
  selectedInquiryIds.value = []
}
function toggleInquirySelection(id) {
  selectedInquiryIds.value = selectedInquiryIds.value.includes(id)
    ? selectedInquiryIds.value.filter((selectedId) => selectedId !== id)
    : [...selectedInquiryIds.value, id]
}
function toggleSelectAllVisible() {
  const visibleIds = visibleInquiryRows.value.map((item) => item.id)
  selectedInquiryIds.value = allVisibleSelected.value
    ? selectedInquiryIds.value.filter((id) => !visibleIds.includes(id))
    : [...new Set([...selectedInquiryIds.value, ...visibleIds])]
}
function selectAllInquiries() {
  selectedInquiryIds.value = [...new Set([...selectedInquiryIds.value, ...activeInquiryTypeRows.value.map((item) => item.id)])]
}
async function deleteInquiryRows(ids, scopeLabel) {
  if (!isSuperAdmin.value) {
    notify('Hanya super admin yang dapat menghapus booking atau pertanyaan.', 'error')
    return
  }
  if (!ids.length || deletingInquiries.value) return
  const result = await Swal.fire({
    title: `Hapus ${scopeLabel}?`,
    text: `${ids.length} data akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.`,
    icon: 'warning',
    customClass: { popup: 'admin-swal-popup', confirmButton: 'admin-swal-confirm admin-swal-danger', cancelButton: 'admin-swal-cancel' },
    showCancelButton: true,
    confirmButtonText: 'Ya, hapus data',
    cancelButtonText: 'Batal',
    buttonsStyling: false,
    reverseButtons: true,
  })
  if (!result.isConfirmed) return
  deletingInquiries.value = true
  try {
    if (isLocalDemo) {
      const remaining = inquiries.value.filter((item) => !ids.includes(item.id))
      localStorage.setItem('anaj-demo-inquiries', JSON.stringify(remaining))
    } else {
      const { error } = await supabase.from('inquiries').delete().in('id', ids)
      if (error) throw error
    }
    selectedInquiryIds.value = []
    selectionMode.value = false
    notify(`${ids.length} data berhasil dihapus.`)
    await loadDashboard()
  } catch (error) {
    notify(`Tidak dapat menghapus data: ${error.message}`, 'error')
  } finally {
    deletingInquiries.value = false
  }
}
function deleteSelectedInquiries() {
  return deleteInquiryRows(visibleSelectedIds.value, `${visibleSelectedIds.value.length} data terpilih`)
}
function deleteAllInquiries() {
  const typeLabel = active.value === 'bookings' ? 'semua booking' : 'semua pertanyaan'
  return deleteInquiryRows(activeInquiryTypeRows.value.map((item) => item.id), typeLabel)
}
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
  filterStatus.value = 'semua'
  filterDay.value = 'semua'
  filterMonth.value = 'semua'
  filterYear.value = 'semua'
  selectionMode.value = false
  selectedInquiryIds.value = []
  if (id === 'profiles') loadAdminAccounts()
}

async function loadDashboard() {
  loading.value = true
  try {
    if (isLocalDemo) {
      inquiries.value = JSON.parse(localStorage.getItem('anaj-demo-inquiries') || '[]')
      counts.value = { inquiries: inquiries.value.filter((item) => !isBookingInquiry(item)).length, newInquiries: inquiries.value.filter((item) => !isBookingInquiry(item) && item.status === 'baru').length, newBookings: inquiries.value.filter((item) => isBookingInquiry(item) && item.status === 'baru').length, services: demoServices.length, portfolios: 6, packages: demoPackages.length }
      serviceCounts.value = popularCategories(inquiries.value)
      dataSets.value.services = demoServices
      dataSets.value.categories = demoCategories
      dataSets.value.event_types = publicSite.eventTypes
      dataSets.value.packages = demoPackages
      dataSets.value.price_list = demoPackages
      dataSets.value.portfolios = Array.from({ length: 6 }, (_, index) => ({ id: `demo-${index}`, title: ['Malam Perpisahan Angkatan 2025', 'Yearbook: Our Little Universe', 'Together, Forward', 'The Art of Gathering', 'A Garden Wedding', 'Golden Hour Vows'][index], category: ['Perpisahan & Wisuda', 'Yearbook', 'Event & Corporate', 'Event', 'Wedding', 'Wedding'][index], image_url: demoServices[index % demoServices.length].image_url, is_published: true }))
      dataSets.value.testimonials = demoTestimonials
      dataSets.value.faqs = demoFaqs
      dataSets.value.contacts = [{ id: 'c2', name: 'Raka Mahendra', title: 'Konsultan Acara Sekolah', division: 'Sekolah & Event', is_published: true }, { id: 'c1', name: 'Alya Putri', title: 'Wedding Consultant', division: 'Wedding & Personal', is_published: true }]
      dataSets.value.clients = [{ id: 'cl1', name: 'Nusantara Group', is_published: true }, { id: 'cl2', name: 'SMA Cakrawala', is_published: true }]
      dataSets.value.landing_sections = demoLandingSections
      dataSets.value.site_settings = [{ id: 'name', key: 'brand_name', label: 'Nama brand', value: 'Abadi nan Jaya' }, { id: 'whatsapp', key: 'whatsapp', label: 'Nomor WhatsApp', value: '6281234567890' }, { id: 'instagram', key: 'instagram', label: 'Instagram', value: '@abadinanjaya' }, { id: 'map-location', key: 'map_location', label: 'Lokasi peta', value: 'Tasikmalaya, Jawa Barat' }]
      dataSets.value.profiles = JSON.parse(localStorage.getItem('anaj-demo-admin-users') || 'null') || [
        { id: 'demo-super', full_name: 'Admin Abadi nan Jaya', email: 'admin@abadinanjaya.test', role: 'super_admin', created_at: new Date().toISOString() },
        { id: 'demo-editor', full_name: 'Editor Konten', email: 'editor@abadinanjaya.test', role: 'editor', created_at: new Date().toISOString() },
      ]
    } else {
      const [inquiryResult, servicesResult, portfolioResult, packagesResult, serviceRows, allQueries] = await Promise.all([
        supabase.from('inquiries').select('*', { count: 'exact' }).order('created_at', { ascending: false }),
        supabase.from('services').select('*', { count: 'exact' }),
        supabase.from('portfolios').select('*', { count: 'exact' }),
        supabase.from('packages').select('*', { count: 'exact' }),
        supabase.from('services').select('category_id'),
        Promise.all(['services', 'categories', 'packages', 'portfolios', 'testimonials', 'faqs', 'contacts', 'clients', 'landing_sections', 'site_settings', 'profiles', 'price_list', 'event_types'].map((table) => {
          const selection = table === 'packages' ? '*,addons(*),package_items(*)' : table === 'profiles' ? 'id,full_name,role,created_at' : table === 'event_types' ? '*,event_type_services(service_id)' : '*'
          const query = supabase.from(table).select(selection)
          return table === 'profiles'
            ? query.order('created_at', { ascending: false }).limit(200)
            : query.order('sort_order', { ascending: true }).limit(200)
        })),
      ])
      for (const result of [inquiryResult, servicesResult, portfolioResult, packagesResult, serviceRows, ...allQueries]) if (result.error) throw result.error
      inquiries.value = inquiryResult.data || []
      const allInquiries = inquiryResult.data || []
      counts.value = {
        inquiries: allInquiries.filter((item) => !isBookingInquiry(item)).length,
        newInquiries: allInquiries.filter((item) => !isBookingInquiry(item) && item.status === 'baru').length,
        newBookings: allInquiries.filter((item) => isBookingInquiry(item) && item.status === 'baru').length,
        services: servicesResult.count || 0,
        portfolios: portfolioResult.count || 0,
        packages: packagesResult.count || 0,
      }
      serviceCounts.value = popularCategories(inquiries.value, serviceRows.data || [], allQueries[1].data || [])
      const keys = ['services', 'categories', 'packages', 'portfolios', 'testimonials', 'faqs', 'contacts', 'clients', 'landing_sections', 'site_settings', 'profiles', 'price_list', 'event_types']
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
            : key === 'event_types'
              ? rows.map((item) => ({ ...item, service_ids: (item.event_type_services || []).map((relation) => relation.service_id) }))
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
  for (const item of exportRows) rows.push([item.name, item.email, toLocalIndonesianPhone(item.phone), item.booking_type, item.organization_name, item.contact_position, item.package_id, item.event_type, item.event_date, [item.event_start_time, item.event_end_time].filter(Boolean).join(' - '), item.guest_count, item.event_location, item.event_city, item.venue_type, item.budget_min, item.budget_max, item.event_theme, (item.selected_addons || []).map((addon) => `${addon.name} x ${addon.quantity || 1}`).join('; '), item.special_requirements, item.status, item.notes, item.message, item.created_at])
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
  if (table === 'event_types' && dataSets.value.packages.some((itemPackage) => itemPackage.event_type_id === item.id)) {
    notify('Jenis acara ini masih digunakan oleh paket. Ubah jenis acara paket terlebih dahulu.', 'error')
    return
  }
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
  formErrors.value = {}
  editing.value = item.id || `new-${Date.now()}`
  const updated = { ...item }
  if (active.value === 'event_types') updated.service_ids = [...(item.service_ids || item.event_type_services?.map((relation) => relation.service_id) || [])]
  if (active.value === 'landing_sections' && item.section_key?.startsWith('custom-')) {
    updated.content_blocks = normalizeLandingContentBlocks(item)
  }
  const imageField = ['image_url', 'cover_image_url', 'logo_url', 'avatar_url'].find((key) => key in updated)
    || (active.value === 'site_settings' && updated.key === 'logo_url' ? 'value' : null)
  if (imageField && updated[imageField] && !updated[imageField].startsWith('/') && !updated[imageField].startsWith('data:image/') && !updated[imageField].includes('.supabase.co/storage/v1/object/public/')) {
    const category = dataSets.value.categories.find((entry) => entry.id === updated.category_id || entry.name === updated.category)
    updated[imageField] = active.value === 'clients'
      ? ''
      : active.value === 'landing_sections'
      ? localImages[updated.section_key === 'about' ? 'about' : 'graduation']
      : localImages[category?.slug] || (active.value === 'portfolios' ? localImages.graduation : localImages.production)
  }
  form.value = updated
}
function newRow() {
  clearPendingImages()
  formErrors.value = {}
  editing.value = 'new'
  const sortOrder = sortableTables.has(active.value) ? nextSortOrder(active.value) : undefined
  const templates = {
    services: { title: '', slug: '', summary: '', description: '', category_id: '', image_url: localImages.production, featured: false, is_published: false, sort_order: sortOrder },
    categories: { name: '', slug: '', description: '', icon: '', is_published: false, sort_order: sortOrder },
    packages: { name: '', slug: '', description: '', event_type_id: '', service_id: '', price: 0, price_label: 'Mulai dari', inclusions: [], addons: [], is_published: false, sort_order: sortOrder },
    event_types: { name: '', booking_type: 'organization', is_published: true, service_ids: [], sort_order: sortOrder },
    portfolios: { title: '', slug: '', category: '', category_id: '', description: '', cover_image_url: localImages.graduation, is_published: false, sort_order: sortOrder },
    faqs: { question: '', answer: '', is_published: false, sort_order: sortOrder },
    contacts: { name: '', title: '', division: '', phone: '', email: '', is_published: false, sort_order: sortOrder },
    testimonials: { name: '', role: '', quote: '', avatar_url: '', rating: 5, is_published: false, sort_order: sortOrder },
    clients: { name: '', logo_url: '', website_url: '', is_published: false, sort_order: sortOrder },
    landing_sections: { section_key: '', title: '', subtitle: '', body: '', image_url: '', cta_label: '', cta_url: '', content_blocks: [createLandingRow()], is_enabled: true, sort_order: sortOrder },
    site_settings: { key: '', value: '', sort_order: sortOrder },
    price_list: { name: '', description: '', price: 0, price_label: 'Mulai dari', is_published: false, sort_order: sortOrder },
  }
  form.value = { ...(templates[active.value] || { name: '' }) }
}
function getRowValidationErrors(record, table) {
  const errors = {}
  const nameField = ['services', 'portfolios', 'landing_sections'].includes(table) ? 'title' : table === 'faqs' ? 'question' : 'name'
  const nameLabel = table === 'services' ? 'Judul layanan' : table === 'portfolios' ? 'Judul portofolio' : table === 'event_types' ? 'Nama jenis acara' : table === 'faqs' ? 'Pertanyaan' : table === 'landing_sections' ? 'Judul bagian' : 'Nama'
  const nameValue = record[nameField]
  if (['services', 'categories', 'packages', 'portfolios', 'event_types', 'contacts', 'clients', 'testimonials', 'faqs', 'landing_sections', 'price_list'].includes(table)) {
    if (typeof nameValue !== 'string' || nameValue.trim().length < 2) errors[nameField] = `${nameLabel} minimal 2 karakter.`
    else if (nameValue.trim().length > 160) errors[nameField] = `${nameLabel} maksimal 160 karakter.`
  }
  if (table === 'services' && !record.category_id) errors.category_id = 'Pilih kategori layanan.'
  if (table === 'event_types') {
    if (!['organization', 'personal'].includes(record.booking_type)) errors.booking_type = 'Pilih tipe pemesan.'
    if (!record.service_ids?.length) errors.service_ids = 'Pilih minimal satu layanan.'
  }
  if (table === 'packages') {
    if (!record.event_type_id) errors.event_type_id = 'Pilih jenis acara.'
    if (!record.service_id) errors.service_id = 'Pilih layanan.'
    if (!Number.isFinite(Number(record.price)) || Number(record.price) < 0) errors.price = 'Harga harus berupa angka nol atau lebih.'
  }
  if (table === 'faqs') {
    if (!record.question?.trim()) errors.question = 'Isi pertanyaan.'
    if (!record.answer?.trim()) errors.answer = 'Isi jawaban.'
  }
  if (table === 'testimonials' && !record.quote?.trim()) errors.quote = 'Isi kutipan testimoni.'
  if (table === 'site_settings') {
    if (!record.key?.trim()) errors.key = 'Isi nama pengaturan.'
    if (!String(record.value ?? '').trim()) errors.value = 'Isi nilai pengaturan.'
  }
  if (table === 'price_list' && (!Number.isFinite(Number(record.price)) || Number(record.price) < 0)) errors.price = 'Harga harus berupa angka nol atau lebih.'
  if (record.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(record.email.trim())) errors.email = 'Masukkan alamat email yang valid.'
  if (record.website_url && !/^https?:\/\/\S+$/i.test(record.website_url.trim())) errors.website_url = 'Gunakan URL lengkap yang diawali http:// atau https://.'
  if (table === 'testimonials' && record.rating !== undefined && (!Number.isInteger(Number(record.rating)) || Number(record.rating) < 1 || Number(record.rating) > 5)) errors.rating = 'Rating harus berupa angka bulat 1–5.'
  return errors
}
function validateRowField(field) {
  if (!Object.keys(formErrors.value).length) return
  const errors = getRowValidationErrors(form.value, active.value)
  if (errors[field]) formErrors.value[field] = errors[field]
  else delete formErrors.value[field]
}
function createLandingId() {
  return `block-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
}
function createLandingRow() {
  return { id: createLandingId(), columns: [{ id: createLandingId(), width: 12, blocks: [] }] }
}
function normalizeLandingContentBlocks(section) {
  if (Array.isArray(section.content_blocks) && section.content_blocks.length) {
    return JSON.parse(JSON.stringify(section.content_blocks))
  }
  const blocks = []
  if (section.subtitle) blocks.push({ id: createLandingId(), type: 'text', text: section.subtitle, lead: true })
  if (section.body) blocks.push({ id: createLandingId(), type: 'text', text: section.body })
  if (section.image_url) blocks.push({ id: createLandingId(), type: 'image', image_url: section.image_url, alt: section.title || '' })
  if (section.cta_label || section.cta_url) blocks.push({ id: createLandingId(), type: 'button', label: section.cta_label || '', url: section.cta_url || '/kontak' })
  return [{ id: createLandingId(), columns: [{ id: createLandingId(), width: 12, blocks }] }]
}
function addLandingRow() {
  form.value.content_blocks.push(createLandingRow())
}
function removeLandingRow(rowIndex) {
  form.value.content_blocks.splice(rowIndex, 1)
  if (!form.value.content_blocks.length) addLandingRow()
}
function moveLandingItem(items, index, direction) {
  const nextIndex = index + direction
  if (nextIndex < 0 || nextIndex >= items.length) return
  const [item] = items.splice(index, 1)
  items.splice(nextIndex, 0, item)
}
function addLandingColumn(row) {
  row.columns.push({ id: createLandingId(), width: 6, blocks: [] })
}
function removeLandingColumn(row, columnIndex) {
  row.columns.splice(columnIndex, 1)
  if (!row.columns.length) row.columns.push({ id: createLandingId(), width: 12, blocks: [] })
}
function addLandingBlock(column, type = 'text') {
  column.blocks.push({
    id: createLandingId(),
    type,
    text: '',
    label: '',
    url: '/kontak',
    image_url: '',
    alt: '',
    level: 3,
    lead: false,
  })
}
function removeLandingBlock(column, blockIndex) {
  const block = column.blocks[blockIndex]
  const pending = pendingLandingBlockImages.value[block.id]
  if (pending) {
    URL.revokeObjectURL(pending.previewUrl)
    delete pendingLandingBlockImages.value[block.id]
  }
  column.blocks.splice(blockIndex, 1)
}
function selectLandingBlockImage(event, block) {
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
  const previous = pendingLandingBlockImages.value[block.id]
  if (previous) URL.revokeObjectURL(previous.previewUrl)
  const previewUrl = URL.createObjectURL(file)
  pendingLandingBlockImages.value[block.id] = { file, previewUrl }
  block.image_url = previewUrl
}
function addPackageInclusion() {
  form.value.inclusions = [...(form.value.inclusions || []), '']
}
function removePackageInclusion(index) {
  form.value.inclusions = form.value.inclusions.filter((_, itemIndex) => itemIndex !== index)
}
function addPackageAddon() {
  form.value.addons = [...(form.value.addons || []), { name: '', price: 0, description: '' }]
}
function removePackageAddon(index) {
  form.value.addons = form.value.addons.filter((_, itemIndex) => itemIndex !== index)
}
function syncPublicContent(table) {
  if (table === 'landing_sections') {
    publicSite.sections = dataSets.value.landing_sections.filter((section) => section.is_enabled)
  }
  if (table === 'packages' || table === 'event_types') {
    publicSite.packages = dataSets.value.packages
      .filter((item) => item.is_published && dataSets.value.event_types.some((eventType) => eventType.id === item.event_type_id && eventType.is_published))
      .map((item) => ({ ...item, addons: (item.addons || []).filter((addon) => addon.is_published !== false) }))
  }
  if (table === 'clients') {
    publicSite.clients = dataSets.value.clients.filter((client) => client.is_published)
  }
  if (table === 'testimonials') {
    publicSite.testimonials = dataSets.value.testimonials.filter((testimonial) => testimonial.is_published)
  }
  if (table === 'site_settings') {
    publicSite.settings = { ...publicSite.settings, ...Object.fromEntries(dataSets.value.site_settings.map(({ key, value }) => [key, value])) }
  }
  if (table === 'event_types') {
    publicSite.eventTypes = dataSets.value.event_types.filter((eventType) => eventType.is_published)
  }
}
function createLandingSectionKey(title) {
  const base = `custom-${slugify(title) || 'bagian-baru'}`
  const existingKeys = new Set(dataSets.value.landing_sections
    .filter((section) => section.id !== form.value.id)
    .map((section) => section.section_key))
  let key = base
  let suffix = 2
  while (existingKeys.has(key)) key = `${base}-${suffix++}`
  return key
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
  for (const pending of Object.values(pendingLandingBlockImages.value)) URL.revokeObjectURL(pending.previewUrl)
  pendingLandingBlockImages.value = {}
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
async function uploadLandingBlockImages(record) {
  for (const row of record.content_blocks || []) {
    for (const column of row.columns || []) {
      for (const block of column.blocks || []) {
        const pending = pendingLandingBlockImages.value[block.id]
        if (!pending) continue
        if (isLocalDemo) {
          block.image_url = await readAsDataUrl(pending.file)
          continue
        }
        const safeName = pending.file.name.replace(/[^a-zA-Z0-9._-]/g, '-')
        const path = `content/landing_sections/${Date.now()}-${crypto.randomUUID()}-${safeName}`
        const { error } = await supabase.storage.from('portfolio-media').upload(path, pending.file, {
          upsert: false,
          contentType: pending.file.type,
        })
        if (error) throw error
        const { data: { publicUrl } } = supabase.storage.from('portfolio-media').getPublicUrl(path)
        block.image_url = publicUrl
      }
    }
  }
}
async function saveMapLocation(item) {
  if (!isSuperAdmin.value || saving.value) return
  const location = item.value.trim()
  if (!location || location.length > 160) {
    mapLocationErrors.value[item.id] = !location
      ? 'Isi nama kota atau alamat lokasi peta.'
      : 'Lokasi peta maksimal 160 karakter.'
    await nextTick()
    document.getElementById(`map-location-${item.id}`)?.focus()
    return
  }
  delete mapLocationErrors.value[item.id]
  saving.value = true
  try {
    if (isLocalDemo) {
      item.value = location
      syncPublicContent('site_settings')
      notify('Lokasi peta diperbarui untuk sesi demo ini.')
      return
    }
    const { error } = await supabase.from('site_settings').update({ value: { map_location: location } }).eq('id', item.id)
    if (error) throw error
    item.value = location
    syncPublicContent('site_settings')
    notify('Lokasi peta berhasil diperbarui.')
  } catch (error) {
    notify(`Tidak dapat menyimpan lokasi peta: ${error.message}`, 'error')
  } finally {
    saving.value = false
  }
}
async function saveRow() {
  const table = active.value
  if (table === 'site_settings' && !isSuperAdmin.value) {
    notify('Hanya super admin yang dapat mengubah pengaturan situs.', 'error')
    return
  }
  const record = { ...form.value }
  formErrors.value = getRowValidationErrors(record, table)
  if (Object.keys(formErrors.value).length) {
    await nextTick()
    document.querySelector('.admin-edit-form [aria-invalid="true"]')?.focus()
    return
  }
  if (editing.value === 'new' && sortableTables.has(table)) record.sort_order = nextSortOrder(table)
  if (table === 'landing_sections') {
    if (!record.title?.trim()) {
      notify('Isi judul bagian halaman utama terlebih dahulu.', 'error')
      return
    }
    if (editing.value === 'new') record.section_key = createLandingSectionKey(record.title)
    if (editing.value === 'new' || record.section_key?.startsWith('custom-')) {
      record.content_blocks = (record.content_blocks || []).map((row) => ({
        ...row,
        columns: (row.columns || []).map((column) => ({
          ...column,
          width: Math.max(1, Math.min(12, Number(column.width) || 12)),
          blocks: (column.blocks || [])
            .filter((block) => landingBlockTypes.some((type) => type.value === block.type))
            .filter((block) => !['text', 'heading', 'quote'].includes(block.type) || block.text?.trim())
            .filter((block) => block.type !== 'button' || block.label?.trim())
            .filter((block) => block.type !== 'image' || block.image_url?.trim()),
        })),
      }))
    } else {
      delete record.content_blocks
    }
    delete record.slug
  }
  if (table === 'event_types') {
    if (!record.name?.trim() || record.name.trim().length < 2 || record.name.trim().length > 120 || !['organization', 'personal'].includes(record.booking_type)) {
      notify('Isi nama jenis acara dan pilih tipe pemesan yang sesuai.', 'error')
      return
    }
    if (!record.service_ids?.length) {
      formErrors.value = { service_ids: 'Pilih minimal satu layanan yang sesuai untuk jenis acara ini.' }
      return
    }
    const usedServices = dataSets.value.packages
      .filter((itemPackage) => itemPackage.event_type_id === record.id)
      .map((itemPackage) => itemPackage.service_id)
    if (usedServices.some((serviceId) => !record.service_ids.includes(serviceId))) {
      formErrors.value = { service_ids: 'Layanan yang digunakan paket tidak dapat dilepas. Ubah layanan pada paket terkait terlebih dahulu.' }
      return
    }
    record.name = record.name.trim()
  }
  if (table === 'packages' && (!record.name?.trim() || !record.service_id || !Number.isFinite(Number(record.price)) || Number(record.price) < 0)) {
    notify('Isi nama layanan dan harga paket yang valid terlebih dahulu.', 'error')
    return
  }
  if (table === 'packages') {
    const eventType = dataSets.value.event_types.find((item) => item.id === record.event_type_id)
    if (!eventType || !eventType.service_ids?.includes(record.service_id)) {
      formErrors.value = { service_id: 'Pilih layanan yang terhubung dengan jenis acara ini.' }
      return
    }
  }
  if (table === 'packages') record.price = Number(record.price || 0)
  if (['services', 'categories', 'packages', 'portfolios'].includes(table) && !(record.title || record.name)?.trim()) {
    notify('Isi nama atau judul terlebih dahulu.', 'error')
    return
  }
  if (table === 'portfolios') {
    const selectedCategory = dataSets.value.categories.find((category) => category.id === record.category_id)
    record.category = selectedCategory?.name || ''
    record.category_id = record.category_id || null
  }
  const addonItems = table === 'packages' ? (record.addons || []).map((addon) => {
    if (typeof addon === 'string') {
      const [name, price = '0', description = ''] = addon.split('|')
      return { name: name.trim(), price: Number(price) || 0, description: description.trim() }
    }
    return { name: addon.name?.trim(), price: Number(addon.price) || 0, description: addon.description?.trim() || '' }
  }).filter((addon) => addon.name) : null
  if (table === 'packages') {
    delete record.addons
    delete record.package_items
    delete record.event_type
    record.inclusions = (record.inclusions || []).map((value) => typeof value === 'string' ? value.trim() : '').filter(Boolean)
  }
  if (table === 'event_types') {
    delete record.service_ids
    delete record.event_type_services
  }
  if (Array.isArray(record.inclusions)) record.inclusions = record.inclusions.map((value) => typeof value === 'string' ? value.trim() : value).filter(Boolean)
  if (['services', 'categories', 'packages', 'portfolios'].includes(table) && (record.title || record.name)) {
    record.slug = slugify(record.title || record.name)
  }
  if (table === 'inquiries' && isLocalDemo) return updateInquiry(record)
  saving.value = true
  if (isLocalDemo) {
    try {
      await uploadSelectedImages(record, table)
      if (table === 'landing_sections') await uploadLandingBlockImages(record)
      if (editing.value === 'new') record.id = `${table}-${Date.now()}`
      const list = dataSets.value[active.value] || []
      if (table === 'packages') record.addons = addonItems
      if (table === 'event_types') record.service_ids = [...form.value.service_ids]
      dataSets.value[active.value] = editing.value === 'new' ? [...list, record] : list.map((item) => item.id === record.id ? record : item)
      syncPublicContent(table)
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
    if (editing.value === 'new' && sortableTables.has(table)) {
      const { data: lastOrderedRow, error: orderError } = await supabase
        .from(table)
        .select('sort_order')
        .order('sort_order', { ascending: false })
        .limit(1)
        .maybeSingle()
      if (orderError) throw orderError
      record.sort_order = Number(lastOrderedRow?.sort_order || 0) + 1
    }
    await uploadSelectedImages(record, table)
    if (table === 'landing_sections') await uploadLandingBlockImages(record)
    if (table === 'site_settings') {
      record.value = typeof record.value === 'string' ? { [record.key]: record.value } : record.value
      delete record.label
    }
    let savedPackageId = record.id
    const { data, error } = editing.value === 'new'
      ? await supabase.from(table).insert(record).select('id').single()
      : await supabase.from(table).update(record).eq('id', record.id).select('id').single()
    if (error) throw error
    if (table === 'event_types') {
      const eventTypeId = data.id
      if (editing.value === 'new') {
        editing.value = eventTypeId
        form.value.id = eventTypeId
      }
      const { error: relationError } = await supabase.rpc('set_event_type_services', {
        p_event_type_id: eventTypeId,
        p_service_ids: form.value.service_ids,
      })
      if (relationError) throw relationError
    }
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
    await loadDashboard()
    syncPublicContent(table)
    notify('Perubahan berhasil disimpan.')
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
    counts.value.inquiries = next.filter((entry) => !isBookingInquiry(entry)).length
    counts.value.newInquiries = next.filter((entry) => !isBookingInquiry(entry) && entry.status === 'baru').length
    counts.value.newBookings = next.filter((entry) => isBookingInquiry(entry) && entry.status === 'baru').length
    localStorage.setItem('anaj-demo-inquiries', JSON.stringify(next))
    notify(isBookingInquiry(item) ? 'Status booking diperbarui.' : 'Status pertanyaan diperbarui.')
    return
  }
  saving.value = true
  try {
    const { error } = await supabase.from('inquiries').update({ status: item.status, notes: item.notes }).eq('id', item.id)
    if (error) throw error
    await loadDashboard()
    notify(isBookingInquiry(item) ? 'Status booking diperbarui.' : 'Status pertanyaan diperbarui.')
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
  accountErrors.value = {}
  accountForm.value = { full_name: '', email: '', password: '', role: 'editor' }
}
function editAccount(account) {
  accountEditing.value = account.id
  accountErrors.value = {}
  accountForm.value = { full_name: account.full_name || '', email: account.email || '', password: '', role: account.role }
}
function cancelAccountEdit() {
  accountEditing.value = null
  accountErrors.value = {}
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
  accountErrors.value = {}
  if (fullName.length < 2 || fullName.length > 120) accountErrors.value.full_name = 'Nama harus berisi 2–120 karakter.'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) accountErrors.value.email = 'Masukkan alamat email yang valid.'
  if ((accountEditing.value === 'new' || password) && password.length < 8) accountErrors.value.password = 'Kata sandi minimal 8 karakter.'
  if (Object.keys(accountErrors.value).length) {
    await nextTick()
    document.querySelector('.admin-account-form [aria-invalid="true"]')?.focus()
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
    if (/email.*(sudah|used|exists|duplicate)|duplicate.*email/i.test(error.message || '')) {
      accountErrors.value.email = error.message
      await nextTick()
      document.querySelector('.admin-account-form [aria-invalid="true"]')?.focus()
    }
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
  if (field === 'event_type_id') return dataSets.value.event_types.find((eventType) => eventType.id === value)?.name || value || '—'
  if (field === 'service_id') return dataSets.value.services.find((service) => service.id === value)?.title || value || '—'
  if (field === 'price' && value !== undefined) return formatPrice(value)
  if (field === 'booking_type') return value === 'organization' ? 'Instansi / sekolah / organisasi' : value === 'personal' ? 'Personal' : value
  if (field === 'is_published' || field === 'is_enabled') return value ? 'Aktif' : 'Nonaktif'
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
      <RouterLink to="/" class="brand admin-brand"><img class="brand-logo" src="/AnJ.svg" alt=""><span class="brand-name">Abadi nan Jaya<small>ADMIN STUDIO</small></span></RouterLink>
      <div class="workspace-label">WORKSPACE <span>LIVE</span></div>
      <nav class="admin-nav"><button v-for="item in menu" :key="item.id" type="button" :class="{ active: active === item.id }" @click="setPage(item.id)"><component :is="item.icon" :size="17" /><span>{{ item.label }}</span><i v-if="item.id === 'inquiries' && counts.newInquiries">{{ counts.newInquiries }}</i><i v-else-if="item.id === 'bookings' && actionableBookings.length">{{ actionableBookings.length }}</i></button></nav>
      <div class="sidebar-bottom"><a class="view-site" href="/" target="_blank" rel="noreferrer"><ArrowUpRight :size="15" /> Lihat situs</a><div class="admin-user"><span class="admin-avatar">{{ (profile.full_name || 'A').charAt(0) }}</span><span class="admin-user-info"><strong>{{ profile.full_name || 'Admin Abadi nan Jaya' }}</strong><small>{{ isLocalDemo ? 'Mode demo' : role.replace('_', ' ') }}</small></span></div><button class="sidebar-logout" type="button" @click="logout"><LogOut :size="15" /> Keluar dari admin</button></div>
    </aside>
    <main class="admin-main">
      <header class="admin-topbar"><button class="mobile-menu admin-menu-toggle" aria-label="Buka menu" @click="sidebarOpen = true"><Menu :size="20" /></button><div class="admin-breadcrumb">Workspace <span>/</span> <strong>{{ menu.find((item) => item.id === active)?.label }}</strong></div><div class="admin-top-actions"><span class="admin-status"><i></i> Situs aktif</span><div class="account-menu-wrap"><button class="account-menu-trigger" type="button" :aria-expanded="accountMenuOpen" @click="accountMenuOpen = !accountMenuOpen"><span class="admin-top-avatar">{{ (profile.full_name || 'A').charAt(0) }}</span><ChevronDown :size="14" /></button><div v-if="accountMenuOpen" class="account-menu"><strong>{{ profile.full_name || 'Admin Abadi nan Jaya' }}</strong><small>{{ isLocalDemo ? 'Mode demo' : role.replace('_', ' ') }}</small><button type="button" @click="logout"><LogOut :size="15" /> Keluar dari admin</button></div></div></div></header>
      <div class="admin-content">
        <div class="admin-page-heading"><div><span class="eyebrow">{{ active === 'dashboard' ? 'RINGKASAN HARI INI' : 'KELOLA KONTEN' }}</span><h1>{{ active === 'dashboard' ? 'Ruang cerita Anda.' : headings[active] }}</h1><p>{{ active === 'dashboard' ? 'Berikut yang terjadi di Abadi nan Jaya.' : `Atur dan perbarui ${headings[active]?.toLowerCase()} tanpa menyentuh kode.` }}</p></div><button v-if="['services','categories','packages','portfolios','faqs','contacts','testimonials','landing_sections','clients','price_list','event_types'].includes(active) || (isSuperAdmin && ['site_settings','profiles'].includes(active))" class="button button-dark admin-add" @click="active === 'profiles' ? startNewAccount() : newRow()"><Plus :size="16" /> {{ active === 'profiles' ? 'Tambah akun' : active === 'landing_sections' ? 'Tambah bagian beranda' : active === 'packages' ? 'Tambah paket' : active === 'event_types' ? 'Tambah jenis acara' : 'Tambah baru' }}</button></div>
        <div v-if="isLocalDemo" class="demo-banner"><span>Mode preview lokal.</span> Data pengelolaan contoh tidak tersimpan permanen. Konfigurasikan Supabase untuk mengaktifkan dashboard penuh.</div>
        <div v-else-if="!isSuperAdmin" class="demo-banner"><span>Akses editor.</span> Anda dapat mengelola konten dan tindak lanjut inquiry. Pengaturan situs, penghapusan konten, serta pengelolaan role hanya tersedia bagi super admin.</div>
        <div v-if="notice" class="admin-error"><span>{{ notice }}</span><button @click="loadDashboard">Coba lagi</button></div>
        <div v-if="['inquiries', 'bookings'].includes(active)" class="table-toolbar date-filter-toolbar">
          <button class="button button-outline date-filter-trigger" :class="{ 'date-filter-active': hasDateFilter }" type="button" @click="showDateFilter"><CalendarDays :size="16" /><span><strong>{{ dateFilterLabel }}</strong><small>Tanggal diterima</small></span><ChevronDown :size="15" /></button>
        </div>
        <template v-if="active === 'dashboard'">
          <div class="admin-stats"><article class="stat-card"><span>KONSULTASI MASUK</span><div><strong>{{ counts.inquiries }}</strong><span class="stat-icon stat-icon-peach"><MessageSquareText :size="18" /></span></div><small>{{ counts.newInquiries }} belum dibalas</small></article><article class="stat-card"><span>BOOKING PERLU TINDAKAN</span><div><strong>{{ actionableBookings.length }}</strong><span class="stat-icon stat-icon-gold"><CalendarDays :size="18" /></span></div><small>{{ counts.newBookings }} booking baru</small></article><article class="stat-card"><span>LAYANAN AKTIF</span><div><strong>{{ counts.services }}</strong><span class="stat-icon stat-icon-green"><BookOpen :size="18" /></span></div><small>Di seluruh kategori</small></article><article class="stat-card"><span>PAKET</span><div><strong>{{ counts.packages }}</strong><span class="stat-icon stat-icon-blue"><Package :size="18" /></span></div><small>Paket dan add-on</small></article></div>
          <div class="admin-overview-grid"><section class="admin-panel inquiry-panel"><div class="panel-heading"><div><h2>Konsultasi terbaru</h2><p>Pesan dari formulir konsultasi, tidak termasuk booking.</p></div><button class="text-link" @click="setPage('inquiries')">Lihat semua <ArrowRight :size="14" /></button></div><div v-if="loading" class="admin-loading"><span class="skeleton skeleton-card"></span></div><div v-else-if="consultationInquiries.length" class="recent-list"><article v-for="item in consultationInquiries.slice(0, 5)" :key="item.id" class="recent-inquiry"><span class="inquiry-initial">{{ item.name?.charAt(0) }}</span><div class="recent-main"><strong>{{ item.name }}</strong><small>{{ item.event_type }} · {{ dateLabel(item.created_at) }}</small></div><span class="status-pill" :class="`status-${item.status}`">{{ item.status }}</span><button aria-label="Lihat inquiry" @click="setPage('inquiries')"><ArrowRight :size="15" /></button></article></div><div v-else class="admin-empty"><MessageSquareText :size="24" /><strong>Belum ada konsultasi</strong><span>Pesan dari formulir konsultasi akan muncul di sini.</span></div></section>
            <section class="admin-panel popular-panel"><div class="panel-heading"><div><h2>Layanan populer</h2><p>Jumlah layanan per kategori.</p></div></div><div class="popular-list"><div v-for="item in serviceCounts" :key="item.name" class="popular-row"><span>{{ item.name }}</span><div class="popular-track"><i :style="{ width: `${Math.max(8, item.value / Math.max(...serviceCounts.map((row) => row.value), 1) * 100)}%` }"></i></div><strong>{{ item.value }}</strong></div></div><RouterLink class="popular-link" to="/layanan" target="_blank">Lihat katalog publik <ArrowUpRight :size="14" /></RouterLink></section></div>
          <section class="admin-panel summary-menu-panel"><div class="panel-heading"><div><h2>Ringkasan semua menu</h2><p>Pilih bagian untuk membuka dan mengelola detailnya.</p></div></div><div class="summary-menu-grid"><button v-for="item in summaryItems" :key="item.id" class="summary-menu-card" type="button" @click="setPage(item.id)"><span class="summary-menu-icon"><component :is="item.icon" :size="18" /></span><span class="summary-menu-copy"><strong>{{ item.label }}</strong><small>{{ item.detail }}</small></span><span class="summary-menu-count">{{ item.value }}</span><ArrowRight :size="15" class="summary-menu-arrow" /></button></div></section>
        </template>
        <template v-else-if="active === 'bookings'">
          <div class="admin-stats booking-admin-stats">
            <article class="stat-card"><span>SEMUA BOOKING</span><div><strong>{{ bookingInquiries.length }}</strong><span class="stat-icon stat-icon-peach"><CalendarDays :size="18" /></span></div><small>Permintaan dengan detail rencana acara</small></article>
            <article class="stat-card"><span>PERLU DITINDAKLANJUTI</span><div><strong>{{ bookingInquiries.filter((item) => item.status === 'baru').length }}</strong><span class="stat-icon stat-icon-gold"><Activity :size="18" /></span></div><small>Booking baru belum diproses</small></article>
            <article class="stat-card"><span>ACARA MENDATANG</span><div><strong>{{ upcomingBookings }}</strong><span class="stat-icon stat-icon-green"><CalendarDays :size="18" /></span></div><small>Tanggal acara hari ini atau berikutnya</small></article>
            <article class="stat-card"><span>INSTANSI / SEKOLAH</span><div><strong>{{ organizationBookings }}</strong><span class="stat-icon stat-icon-blue"><Users :size="18" /></span></div><small>Permintaan dari organisasi</small></article>
          </div>
          <section class="booking-list-panel">
            <div class="table-toolbar booking-toolbar"><label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari nama, instansi, kota..."></label><select v-model="filterStatus" class="select-control"><option value="semua">Semua status</option><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option><option value="dibatalkan">Dibatalkan</option></select><button v-if="isSuperAdmin" class="button button-outline admin-selection-toggle" :class="{ 'admin-selection-on': selectionMode }" type="button" @click="toggleSelectionMode"><Trash2 :size="15" /> {{ selectionMode ? 'Tutup mode hapus' : 'Pilih untuk hapus' }}</button><button class="button button-outline export-button" @click="exportCsv"><ArrowDownToLine :size="15" /> Ekspor booking CSV</button></div>
            <div v-if="selectionMode && isSuperAdmin" class="admin-delete-toolbar"><span>{{ visibleSelectedIds.length }} booking dipilih dari {{ bookingInquiries.length }} total</span><div><button class="button button-outline" type="button" :disabled="!filteredBookings.length || allVisibleSelected" @click="toggleSelectAllVisible">Pilih semua hasil</button><button class="button button-outline" type="button" :disabled="allTypeSelected" @click="selectAllInquiries">Pilih semua booking</button><button class="button button-danger" type="button" :disabled="!visibleSelectedIds.length || deletingInquiries" @click="deleteSelectedInquiries"><Trash2 :size="14" /> Hapus terpilih</button><button class="button button-danger button-danger-quiet" type="button" :disabled="!bookingInquiries.length || deletingInquiries" @click="deleteAllInquiries"><Trash2 :size="14" /> Hapus semua booking</button></div></div>
            <div v-for="item in filteredBookings" :key="item.id" class="booking-admin-card" :class="{ 'booking-admin-card-cancelled': item.status === 'dibatalkan', 'booking-admin-card-selected': selectionMode && selectedInquiryIds.includes(item.id) }">
              <label v-if="selectionMode && isSuperAdmin" class="admin-row-select"><input type="checkbox" :checked="selectedInquiryIds.includes(item.id)" @change="toggleInquirySelection(item.id)"><span>Pilih booking ini</span></label>
              <div class="booking-admin-card-head">
                <div class="booking-admin-customer"><span class="inquiry-initial">{{ item.name?.charAt(0) }}</span><div><strong>{{ bookingContactName(item) }}</strong><small>{{ item.booking_type === 'organization' ? `${item.name} · ${item.organization_type || 'Instansi / sekolah'}` : 'Pelanggan personal' }}</small><small>{{ item.email }} · {{ toLocalIndonesianPhone(item.phone) }}</small></div></div>
                <label class="booking-status-field"><span>Status booking</span><select v-model="item.status" class="status-select" :class="`status-${item.status}`" :disabled="saving" @change="updateInquiry(item)"><option value="baru">Baru</option><option value="diproses">Sedang diproses</option><option value="selesai">Selesai</option><option value="dibatalkan">Batalkan booking</option></select></label>
              </div>
              <div v-if="hasBookingConflict(item)" class="booking-conflict-notice"><CalendarDays :size="16" /><span><strong>Periksa jadwal:</strong> ada permintaan acara {{ item.event_type }} lain pada tanggal yang sama. Konfirmasi ketersediaan sebelum menerima booking ini.</span></div>
              <div class="booking-admin-facts">
                <section><span>JENIS ACARA</span><strong>{{ item.event_type || 'Belum ditentukan' }}</strong><small>{{ item.event_date ? dateLabel(item.event_date) : 'Tanggal fleksibel' }}<template v-if="item.event_start_time"> · {{ item.event_start_time }}<template v-if="item.event_end_time">–{{ item.event_end_time }}</template></template></small><small>{{ item.guest_count ? `${Number(item.guest_count).toLocaleString('id-ID')} peserta / tamu` : 'Jumlah belum ditentukan' }}</small></section>
                <section><span>LAYANAN & PAKET</span><strong>{{ dataSets.packages.find((entry) => entry.id === item.package_id)?.name || 'Minta rekomendasi paket' }}</strong><small>{{ dataSets.services.find((entry) => entry.id === item.service_id)?.title || 'Layanan belum dipilih' }}</small><small>{{ item.venue_type || 'Jenis venue belum ditentukan' }}</small></section>
                <section><span>LOKASI</span><strong>{{ item.event_city || 'Kota belum diisi' }}</strong><small>{{ item.event_location || 'Alamat / venue belum ditentukan' }}</small><small>Diterima {{ dateLabel(item.created_at) }}</small></section>
              </div>
              <div v-if="item.selected_addons?.length" class="booking-admin-selected-addons"><strong>Tambahan yang dipilih</strong><div v-for="addon in item.selected_addons" :key="addon.id || addon.name"><span>{{ addon.name }} × {{ addon.quantity || 1 }}</span><b>{{ formatPrice((addon.price || 0) * (addon.quantity || 1)) }}</b></div></div>
              <details class="booking-admin-details">
                <summary>Lihat tema, anggaran, dan kebutuhan acara</summary>
                <div class="booking-detail-grid">
                  <section><h4>Tema / konsep</h4><p>{{ item.event_theme || 'Belum ditentukan' }}</p></section>
                  <section><h4>Anggaran</h4><p>{{ item.budget_min || item.budget_max ? `${item.budget_min ? formatPrice(item.budget_min) : 'Belum ditentukan'} – ${item.budget_max ? formatPrice(item.budget_max) : 'Fleksibel'}` : 'Belum diberikan' }}</p></section>
                  <section><h4>Kebutuhan khusus</h4><p>{{ item.special_requirements || 'Tidak ada kebutuhan khusus yang dicatat.' }}</p></section>
                  <section class="booking-detail-message"><h4>Pesan dari pelanggan</h4><p>{{ item.message || 'Tidak ada pesan tambahan.' }}</p></section>
                </div>
              </details>
              <div class="booking-admin-card-foot">
                <label class="booking-note-field"><span>Catatan internal tim</span><input v-model="item.notes" class="notes-input" placeholder="Contoh: Hubungi kembali setelah cek venue" :disabled="saving" @change="updateInquiry(item)"></label>
                <div class="booking-followup-actions"><a class="button button-outline" :href="whatsappLink(item)" target="_blank" rel="noreferrer" :aria-disabled="!item.phone"><MessageSquareText :size="15" /> Hubungi via WhatsApp</a><a class="button button-outline" :href="`mailto:${item.email}?subject=${encodeURIComponent(`Tindak lanjut ${item.event_type || 'booking acara'}`)}`"><ArrowRight :size="15" /> Email pelanggan</a></div>
              </div>
            </div>
            <div v-if="!filteredBookings.length" class="admin-empty booking-empty"><CalendarDays :size="25" /><strong>Belum ada booking ditemukan</strong><span>Booking pelanggan akan muncul di sini dengan jadwal, paket, kebutuhan, dan pilihan tindak lanjut.</span></div>
          </section>
        </template>
        <template v-else-if="active === 'inquiries'">
          <section class="admin-panel table-panel">
            <div class="table-toolbar">
              <label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari nama, email, acara..."></label>
              <select v-model="filterStatus" class="select-control"><option value="semua">Semua status</option><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option></select>
              <button v-if="isSuperAdmin" class="button button-outline admin-selection-toggle" :class="{ 'admin-selection-on': selectionMode }" type="button" @click="toggleSelectionMode"><Trash2 :size="15" /> {{ selectionMode ? 'Tutup mode hapus' : 'Pilih untuk hapus' }}</button>
              <button class="button button-outline export-button" @click="exportCsv"><ArrowDownToLine :size="15" /> Ekspor CSV</button>
            </div>
            <div v-if="selectionMode && isSuperAdmin" class="admin-delete-toolbar"><span>{{ visibleSelectedIds.length }} pertanyaan dipilih dari {{ consultationInquiries.length }} total</span><div><button class="button button-outline" type="button" :disabled="!filteredInquiries.length || allVisibleSelected" @click="toggleSelectAllVisible">Pilih semua hasil</button><button class="button button-outline" type="button" :disabled="allTypeSelected" @click="selectAllInquiries">Pilih semua pertanyaan</button><button class="button button-danger" type="button" :disabled="!visibleSelectedIds.length || deletingInquiries" @click="deleteSelectedInquiries"><Trash2 :size="14" /> Hapus terpilih</button><button class="button button-danger button-danger-quiet" type="button" :disabled="!consultationInquiries.length || deletingInquiries" @click="deleteAllInquiries"><Trash2 :size="14" /> Hapus semua pertanyaan</button></div></div>
            <div class="table-scroll">
              <table class="admin-table">
                <thead><tr><th v-if="selectionMode && isSuperAdmin"><input type="checkbox" aria-label="Pilih semua pertanyaan yang terlihat" :checked="allVisibleSelected" @change="toggleSelectAllVisible"></th><th>PIC & KONTAK</th><th>PEMESAN / PAKET</th><th>DETAIL ACARA</th><th>DITERIMA</th><th>STATUS</th><th>CATATAN</th><th>AKSI</th></tr></thead>
                <tbody>
                  <tr v-for="item in filteredInquiries" :key="item.id">
                    <td v-if="selectionMode && isSuperAdmin"><input type="checkbox" :aria-label="`Pilih pertanyaan dari ${item.name}`" :checked="selectedInquiryIds.includes(item.id)" @change="toggleInquirySelection(item.id)"></td>
                    <td><strong>{{ item.name }}</strong><small>{{ item.email }} · {{ toLocalIndonesianPhone(item.phone) }}</small><details class="inquiry-message"><summary>Pesan & add-on</summary><p>{{ item.message }}</p><div v-if="item.selected_addons?.length" class="inquiry-addon-summary"><strong>Tambahan yang dipilih:</strong><span v-for="addon in item.selected_addons" :key="addon.id || addon.name">{{ addon.name }} × {{ addon.quantity || 1 }} — {{ formatPrice((addon.price || 0) * (addon.quantity || 1)) }}</span></div><div v-if="item.special_requirements"><strong>Kebutuhan khusus:</strong> {{ item.special_requirements }}</div></details></td>
                    <td>{{ item.booking_type === 'organization' ? item.organization_name || 'Instansi / sekolah' : 'Personal' }}<small>{{ item.organization_type || '' }} {{ item.contact_position ? `· ${item.contact_position}` : '' }}</small><small>{{ dataSets.packages.find((entry) => entry.id === item.package_id)?.name || (item.package_id ? 'Paket terpilih' : 'Minta rekomendasi') }}</small></td>
                    <td>{{ item.event_type || '—' }}<small>{{ item.guest_count ? `${item.guest_count} peserta/tamu` : '' }}</small><small>{{ item.event_date ? dateLabel(item.event_date) : 'Fleksibel' }} {{ item.event_start_time ? `· ${item.event_start_time}` : '' }}</small><small>{{ [item.event_location, item.event_city].filter(Boolean).join(' · ') }}</small></td>
                    <td>{{ dateLabel(item.created_at) }}</td>
                    <td><select v-model="item.status" class="status-select" :class="`status-${item.status}`" :disabled="saving" @change="updateInquiry(item)"><option value="baru">Baru</option><option value="diproses">Diproses</option><option value="selesai">Selesai</option></select></td>
                    <td><input v-model="item.notes" class="notes-input" placeholder="Catatan internal" @change="updateInquiry(item)"></td>
                    <td><a v-if="item.phone" class="button button-outline inquiry-whatsapp" :href="whatsappLink(item)" target="_blank" rel="noreferrer"><MessageSquareText :size="14" /> WhatsApp</a><span v-else>—</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-if="!filteredInquiries.length" class="admin-empty"><MessageSquareText :size="25" /><strong>Tidak ada pertanyaan ditemukan</strong><span>Pesan publik atau ubah filter pencarian.</span></div>
          </section>
        </template>
        <template v-else>
          <section v-if="active === 'profiles'" class="admin-panel role-management">
            <div class="panel-heading"><div><h2>Kelola akun admin</h2><p>Buat akun, perbarui detail dan hak akses, atau hapus akses pengguna admin.</p></div></div>
            <div v-if="isLocalDemo" class="demo-banner account-demo-note"><span>Mode demo.</span> Perubahan akun hanya tersimpan di browser ini dan tidak membuat pengguna Supabase sungguhan.</div>
            <div v-if="accountEditing" class="admin-account-form">
              <div class="panel-heading"><h3>{{ accountEditing === 'new' ? 'Buat akun admin' : 'Ubah akun admin' }}</h3><button class="icon-button" type="button" @click="cancelAccountEdit"><X :size="18" /></button></div>
              <div class="edit-fields">
                <label class="field"><span>Nama lengkap</span><input v-model.trim="accountForm.full_name" type="text" maxlength="120" autocomplete="name" required :aria-invalid="Boolean(accountErrors.full_name)" aria-describedby="account-name-error" @blur="accountForm.full_name = accountForm.full_name.trim()"><small v-if="accountErrors.full_name" id="account-name-error" class="field-error" role="alert">{{ accountErrors.full_name }}</small></label>
                <label class="field"><span>Email</span><input v-model.trim="accountForm.email" type="email" maxlength="254" autocomplete="email" required :aria-invalid="Boolean(accountErrors.email)" aria-describedby="account-email-error" @blur="accountForm.email = accountForm.email.trim().toLowerCase()"><small v-if="accountErrors.email" id="account-email-error" class="field-error" role="alert">{{ accountErrors.email }}</small></label>
                <label class="field"><span>{{ accountEditing === 'new' ? 'Kata sandi awal' : 'Kata sandi baru (opsional)' }}</span><input v-model="accountForm.password" type="password" minlength="8" maxlength="128" :required="accountEditing === 'new'" autocomplete="new-password" :placeholder="accountEditing === 'new' ? 'Minimal 8 karakter' : 'Kosongkan jika tidak diubah'" :aria-invalid="Boolean(accountErrors.password)" aria-describedby="account-password-error"><small v-if="accountErrors.password" id="account-password-error" class="field-error" role="alert">{{ accountErrors.password }}</small></label>
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
          <section class="admin-panel table-panel"><div class="table-toolbar"><label class="search-box"><Search :size="16" /><input v-model="query" placeholder="Cari konten..."></label><span class="table-total">{{ currentRows.filter((item) => JSON.stringify(item).toLowerCase().includes(query.toLowerCase())).length }} item</span><select v-if="['services','packages','portfolios','categories','faqs','event_types'].includes(active)" v-model="filterStatus" class="select-control"><option value="semua">Semua status</option><option value="published">Aktif</option><option value="draft">Nonaktif / draft</option></select></div>
            <div v-if="editing" class="admin-edit-form">
              <div class="panel-heading"><h2>{{ editing === 'new' ? active === 'landing_sections' ? 'Tambah bagian beranda' : active === 'packages' ? 'Tambah paket' : 'Tambah item' : active === 'landing_sections' ? 'Edit bagian beranda' : active === 'packages' ? 'Edit paket' : 'Edit item' }}</h2><button class="icon-button" @click="cancelEdit"><X :size="18" /></button></div>
              <p v-if="active === 'landing_sections'" class="admin-form-hint">Bagian ini akan muncul di beranda. Nama bagian dibuat otomatis—Anda tidak perlu mengisi kode atau slug.</p>
              <p v-else-if="active === 'packages'" class="admin-form-hint">Isi detail paket. Untuk menambahkan beberapa item atau add-on, gunakan tombol tambah di bagian masing-masing.</p>
              <p v-else-if="active === 'event_types'" class="admin-form-hint">Jenis acara akan menyaring layanan dan paket di formulir booking. Satu acara dapat memiliki beberapa layanan yang sesuai.</p>
              <div v-if="Object.keys(formErrors).length" class="form-error-summary" role="alert"><strong>Periksa kembali data yang dimasukkan.</strong><span>{{ Object.keys(formErrors).length }} bagian perlu diperbaiki sebelum disimpan.</span></div>
              <div v-if="active === 'event_types'" class="edit-fields">
                <label class="field"><span>Nama jenis acara</span><input v-model.trim="form.name" name="name" type="text" required minlength="2" maxlength="160" placeholder="Contoh: Pentas seni sekolah" :aria-invalid="Boolean(formErrors.name)" aria-describedby="admin-event-name-error" @blur="validateRowField('name')"><small v-if="formErrors.name" id="admin-event-name-error" class="field-error" role="alert">{{ formErrors.name }}</small></label>
                <label class="field"><span>Tipe pemesan</span><select v-model="form.booking_type" name="booking_type" required :aria-invalid="Boolean(formErrors.booking_type)" aria-describedby="admin-event-booking-type-error" @change="validateRowField('booking_type')"><option value="organization">Instansi / sekolah / organisasi</option><option value="personal">Personal</option></select><small v-if="formErrors.booking_type" id="admin-event-booking-type-error" class="field-error" role="alert">{{ formErrors.booking_type }}</small></label>
                <label class="field"><span>Status</span><select v-model="form.is_published"><option :value="true">Aktif di formulir booking</option><option :value="false">Nonaktif</option></select></label>
                <div class="field field-wide"><span>Layanan yang tersedia untuk jenis acara ini</span><small class="field-help">Pilih satu atau lebih layanan. Pelanggan hanya akan melihat layanan yang dipilih.</small><div class="event-type-service-list"><label v-for="service in dataSets.services" :key="service.id" class="event-type-service-option"><input v-model="form.service_ids" type="checkbox" :value="service.id" :aria-invalid="Boolean(formErrors.service_ids)" aria-describedby="admin-event-services-error" @change="validateRowField('service_ids')"><span>{{ service.title }}<small>{{ dataSets.categories.find((category) => category.id === service.category_id)?.name || 'Tanpa kategori' }}{{ service.is_published ? '' : ' · Draft (tidak tampil ke pelanggan)' }}</small></span></label><small v-if="!dataSets.services.length" class="field-help">Tambahkan layanan terlebih dahulu di menu Layanan & kategori.</small></div><small v-if="formErrors.service_ids" id="admin-event-services-error" class="field-error" role="alert">{{ formErrors.service_ids }}</small></div>
              </div>
              <div v-else-if="active === 'packages'" class="edit-fields">
                <label class="field"><span>Nama paket</span><input v-model.trim="form.name" type="text" required minlength="2" maxlength="160" placeholder="Contoh: Paket Perpisahan Sekolah" :aria-invalid="Boolean(formErrors.name)" aria-describedby="admin-package-name-error" @blur="validateRowField('name')"><small v-if="formErrors.name" id="admin-package-name-error" class="field-error" role="alert">{{ formErrors.name }}</small></label>
                <label class="field"><span>Jenis acara</span><select v-model="form.event_type_id" required :aria-invalid="Boolean(formErrors.event_type_id)" aria-describedby="admin-package-event-type-error" @change="!packageServices.some((service) => service.id === form.service_id) && (form.service_id = ''); validateRowField('event_type_id')"><option value="">Pilih jenis acara</option><option v-for="eventType in packageEventTypes" :key="eventType.id" :value="eventType.id">{{ eventType.name }}{{ eventType.booking_type === 'organization' ? ' · Instansi / sekolah' : ' · Personal' }}{{ eventType.is_published ? '' : ' · Nonaktif' }}</option></select><small class="field-help">Paket ini hanya akan ditawarkan untuk jenis acara yang dipilih.</small><small v-if="formErrors.event_type_id" id="admin-package-event-type-error" class="field-error" role="alert">{{ formErrors.event_type_id }}</small></label>
                <label class="field"><span>Layanan</span><select v-model="form.service_id" required :disabled="!form.event_type_id" :aria-invalid="Boolean(formErrors.service_id)" aria-describedby="admin-package-service-error" @change="validateRowField('service_id')"><option value="">Pilih layanan</option><option v-for="service in packageServices" :key="service.id" :value="service.id">{{ service.title }}</option></select><small v-if="formErrors.service_id" id="admin-package-service-error" class="field-error" role="alert">{{ formErrors.service_id }}</small></label>
                <label class="field field-wide"><span>Deskripsi singkat</span><textarea v-model="form.description" rows="3" placeholder="Jelaskan paket ini secara singkat"></textarea></label>
                <label class="field"><span>Harga (Rp)</span><CurrencyInput v-model="form.price" aria-label="Harga paket dalam rupiah" placeholder="Contoh: 1.000.000" :aria-invalid="Boolean(formErrors.price)" aria-describedby="admin-package-price-error" @blur="validateRowField('price')" /><small v-if="formErrors.price" id="admin-package-price-error" class="field-error" role="alert">{{ formErrors.price }}</small></label>
                <label class="field"><span>Keterangan harga</span><input v-model="form.price_label" type="text" placeholder="Contoh: Mulai dari / per siswa"></label>
                <label class="field"><span>Tampilkan di halaman utama</span><select v-model="form.featured"><option :value="true">Ya</option><option :value="false">Tidak</option></select></label>
                <label class="field"><span>Status paket</span><select v-model="form.is_published"><option :value="true">Dipublikasikan</option><option :value="false">Draft</option></select></label>
                <div class="field field-wide repeater-field">
                  <div class="repeater-heading"><span>Yang termasuk dalam paket</span><button class="row-edit" type="button" @click="addPackageInclusion"><Plus :size="14" /> Tambah item</button></div>
                  <p class="field-help">Contoh: dekorasi panggung, sound system, dokumentasi foto.</p>
                  <div v-for="(item, index) in form.inclusions" :key="index" class="repeater-row">
                    <input v-model="form.inclusions[index]" type="text" :aria-label="`Isi paket ${index + 1}`" placeholder="Contoh: Dokumentasi foto acara">
                    <button class="row-delete" type="button" :aria-label="`Hapus isi paket ${index + 1}`" @click="removePackageInclusion(index)"><Trash2 :size="14" /> Hapus</button>
                  </div>
                  <span v-if="!form.inclusions.length" class="field-empty">Belum ada isi paket. Klik “Tambah item” untuk mulai mengisi.</span>
                </div>
                <div class="field field-wide repeater-field">
                  <div class="repeater-heading"><span>Tambahan / add-on</span><button class="row-edit" type="button" @click="addPackageAddon"><Plus :size="14" /> Tambah add-on</button></div>
                  <p class="field-help">Tambahkan peralatan atau layanan ekstra yang bisa dipilih pelanggan.</p>
                  <div v-for="(addon, index) in form.addons" :key="addon.id || index" class="package-addon-editor">
                    <label class="field"><span>Nama add-on</span><input v-model.trim="addon.name" type="text" placeholder="Contoh: Photobooth"></label>
                    <label class="field"><span>Harga (Rp)</span><CurrencyInput v-model="addon.price" :aria-label="`Harga add-on ${index + 1} dalam rupiah`" placeholder="Contoh: 500.000" /></label>
                    <label class="field"><span>Keterangan</span><input v-model.trim="addon.description" type="text" placeholder="Contoh: Foto cetak untuk tamu"></label>
                    <button class="row-delete" type="button" :aria-label="`Hapus add-on ${index + 1}`" @click="removePackageAddon(index)"><Trash2 :size="14" /> Hapus</button>
                  </div>
                  <span v-if="!form.addons.length" class="field-empty">Belum ada add-on. Bagian ini boleh dikosongkan.</span>
                </div>
              </div>
              <div v-else-if="active === 'landing_sections'" class="edit-fields">
                <label class="field field-wide"><span>Judul bagian</span><input v-model.trim="form.title" type="text" required maxlength="160" placeholder="Contoh: Layanan tambahan kami" :aria-invalid="Boolean(formErrors.title)" aria-describedby="admin-landing-title-error" @blur="validateRowField('title')"><small class="field-help">Judul ini menjadi heading utama bagian di halaman beranda.</small><small v-if="formErrors.title" id="admin-landing-title-error" class="field-error" role="alert">{{ formErrors.title }}</small></label>
                <div v-if="editing === 'new' || form.section_key?.startsWith('custom-')" class="field field-wide landing-builder">
                  <div class="landing-builder-heading"><div><strong>Susun isi bagian</strong><p>Tambahkan baris dan kolom, lalu masukkan elemen sesuai kebutuhan. Atur lebar kolom agar susunannya lebih bebas.</p></div><button class="row-edit" type="button" @click="addLandingRow"><Plus :size="14" /> Tambah baris</button></div>
                  <section v-for="(row, rowIndex) in form.content_blocks" :key="row.id" class="landing-builder-row">
                    <header class="landing-builder-row-head"><strong>Baris {{ rowIndex + 1 }}</strong><div class="landing-builder-controls"><button class="row-edit" type="button" :disabled="rowIndex === 0" aria-label="Pindahkan baris ke atas" @click="moveLandingItem(form.content_blocks, rowIndex, -1)">↑</button><button class="row-edit" type="button" :disabled="rowIndex === form.content_blocks.length - 1" aria-label="Pindahkan baris ke bawah" @click="moveLandingItem(form.content_blocks, rowIndex, 1)">↓</button><button class="row-edit" type="button" @click="addLandingColumn(row)"><Plus :size="14" /> Tambah kolom</button><button class="row-delete" type="button" @click="removeLandingRow(rowIndex)"><Trash2 :size="14" /> Hapus baris</button></div></header>
                    <div class="landing-builder-columns">
                      <article v-for="(column, columnIndex) in row.columns" :key="column.id" class="landing-builder-column" :style="{ gridColumn: `span ${Math.max(1, Math.min(12, Number(column.width) || 12))}` }">
                        <header class="landing-builder-column-head"><strong>Kolom {{ columnIndex + 1 }}</strong><div class="landing-builder-controls"><label class="landing-width-control"><span>Lebar</span><select v-model.number="column.width" :aria-label="`Lebar kolom ${columnIndex + 1} dari 12`"><option v-for="width in [3, 4, 6, 8, 9, 12]" :key="width" :value="width">{{ width }} / 12</option></select></label><button class="row-edit" type="button" :disabled="columnIndex === 0" aria-label="Pindahkan kolom ke kiri" @click="moveLandingItem(row.columns, columnIndex, -1)">←</button><button class="row-edit" type="button" :disabled="columnIndex === row.columns.length - 1" aria-label="Pindahkan kolom ke kanan" @click="moveLandingItem(row.columns, columnIndex, 1)">→</button><button v-if="row.columns.length > 1" class="row-delete" type="button" aria-label="Hapus kolom" @click="removeLandingColumn(row, columnIndex)"><Trash2 :size="13" /></button></div></header>
                        <div v-for="(block, blockIndex) in column.blocks" :key="block.id" class="landing-builder-block">
                          <header class="landing-builder-block-head"><select v-model="block.type" aria-label="Jenis elemen"><option v-for="type in landingBlockTypes" :key="type.value" :value="type.value">{{ type.label }}</option></select><div class="landing-builder-controls"><button class="row-edit" type="button" :disabled="blockIndex === 0" aria-label="Pindahkan elemen ke atas" @click="moveLandingItem(column.blocks, blockIndex, -1)">↑</button><button class="row-edit" type="button" :disabled="blockIndex === column.blocks.length - 1" aria-label="Pindahkan elemen ke bawah" @click="moveLandingItem(column.blocks, blockIndex, 1)">↓</button><button class="row-delete" type="button" aria-label="Hapus elemen" @click="removeLandingBlock(column, blockIndex)"><Trash2 :size="13" /></button></div></header>
                          <template v-if="block.type === 'heading'"><label class="field"><span>Judul</span><input v-model.trim="block.text" type="text" placeholder="Tulis judul"></label><label class="landing-inline-field"><span>Tingkat judul</span><select v-model.number="block.level"><option :value="3">Sedang</option><option :value="4">Kecil</option></select></label></template>
                          <label v-else-if="block.type === 'text'" class="field"><span>Teks</span><textarea v-model="block.text" rows="4" placeholder="Tulis informasi yang ingin ditampilkan"></textarea><span class="landing-inline-field"><input v-model="block.lead" type="checkbox"> Teks pembuka lebih besar</span></label>
                          <template v-else-if="block.type === 'image'"><label class="field"><span>Gambar</span><input type="file" accept="image/jpeg,image/png,image/webp,image/avif,image/gif" :disabled="saving" @change="selectLandingBlockImage($event, block)"></label><label class="field"><span>Keterangan gambar (opsional)</span><input v-model.trim="block.alt" type="text" placeholder="Deskripsikan gambar"></label><img v-if="block.image_url" class="landing-block-image-preview" :src="block.image_url" alt="Pratinjau gambar"></template>
                          <template v-else-if="block.type === 'button'"><label class="field"><span>Teks tombol</span><input v-model.trim="block.label" type="text" placeholder="Contoh: Hubungi kami"></label><label class="field"><span>Tujuan tombol</span><input v-model.trim="block.url" type="text" placeholder="Contoh: /kontak atau https://..."></label></template>
                          <label v-else class="field"><span>Kutipan</span><textarea v-model="block.text" rows="3" placeholder="Tulis kutipan yang ingin ditonjolkan"></textarea></label>
                        </div>
                        <div class="landing-builder-add"><button v-for="type in landingBlockTypes" :key="type.value" class="row-edit" type="button" @click="addLandingBlock(column, type.value)"><Plus :size="13" /> {{ type.label }}</button></div>
                      </article>
                    </div>
                  </section>
                  <span v-if="!form.content_blocks.length" class="field-empty">Belum ada baris. Klik “Tambah baris” untuk mulai menyusun bagian.</span>
                </div>
                <template v-else>
                  <label class="field"><span>Teks pendukung</span><input v-model="form.subtitle" type="text" placeholder="Kalimat singkat di bawah judul (opsional)"></label>
                  <label class="field field-wide"><span>Isi bagian</span><textarea v-model="form.body" rows="4" placeholder="Tuliskan informasi yang ingin ditampilkan di beranda"></textarea></label>
                  <label class="field field-wide admin-image-field"><span>Gambar bagian <small>Opsional. Pilih gambar dari perangkat Anda.</small></span><input type="file" accept="image/jpeg,image/png,image/webp,image/avif,image/gif" :disabled="saving" @change="selectImage($event, 'image_url')"><img v-if="form.image_url" class="admin-image-preview" :src="form.image_url" alt="Pratinjau gambar bagian"></label>
                  <label class="field"><span>Teks tombol (opsional)</span><input v-model="form.cta_label" type="text" placeholder="Contoh: Lihat semua layanan"></label>
                  <label class="field"><span>Tujuan tombol</span><input v-model="form.cta_url" type="text" placeholder="Contoh: /layanan"></label>
                </template>
                <label class="field"><span>Status bagian</span><select v-model="form.is_enabled"><option :value="true">Tampilkan di beranda</option><option :value="false">Sembunyikan</option></select></label>
              </div>
              <div v-else class="edit-fields">
                <template v-for="(value, key) in form" :key="key">
                  <label v-if="key !== 'id' && key !== 'created_at' && key !== 'updated_at' && key !== 'sort_order' && key !== 'metadata' && key !== 'addons' && key !== 'inclusions' && key !== 'media' && key !== 'service_ids' && key !== 'event_type_services' && key !== 'value' && key !== 'package_id' && key !== 'category_id' && key !== 'service_id' && key !== 'is_public' && key !== 'slug' && !(active === 'portfolios' && key === 'category') && !['image_url', 'cover_image_url', 'logo_url', 'avatar_url'].includes(key)" class="field">
                    <span>{{ key.replaceAll('_', ' ') }}</span>
                    <select v-if="typeof value === 'boolean'" v-model="form[key]" :aria-invalid="Boolean(formErrors[key])" @change="validateRowField(key)"><option :value="true">Aktif</option><option :value="false">Draft</option></select>
                    <textarea v-else-if="['description','summary','answer','quote','subtitle','body','message','notes','address'].includes(key)" v-model="form[key]" rows="3" :aria-invalid="Boolean(formErrors[key])" @blur="validateRowField(key)"></textarea>
                    <CurrencyInput v-else-if="key === 'price'" v-model="form[key]" aria-label="Harga dalam rupiah" placeholder="Contoh: 1.000.000" :aria-invalid="Boolean(formErrors[key])" @blur="validateRowField(key)" />
                    <input v-else-if="key === 'rating' || key === 'guest_count'" v-model.number="form[key]" type="number" min="0" :max="key === 'rating' ? 5 : 100000" :aria-invalid="Boolean(formErrors[key])" @blur="validateRowField(key)">
                    <input v-else v-model.trim="form[key]" :type="key === 'email' ? 'email' : 'text'" :maxlength="['name', 'title', 'question'].includes(key) ? 160 : undefined" :aria-invalid="Boolean(formErrors[key])" @blur="validateRowField(key)">
                    <small v-if="formErrors[key]" :id="`admin-field-${key}-error`" class="field-error" role="alert">{{ formErrors[key] }}</small>
                  </label>
                  <label v-if="key === 'category_id'" class="field"><span>Kategori</span><select v-model="form[key]" :aria-invalid="Boolean(formErrors.category_id)" aria-describedby="admin-category-error" @change="validateRowField('category_id')"><option value="">Pilih kategori</option><option v-for="category in dataSets.categories" :key="category.id" :value="category.id">{{ category.name }}</option></select><small v-if="formErrors.category_id" id="admin-category-error" class="field-error" role="alert">{{ formErrors.category_id }}</small></label>
                  <label v-if="key === 'service_id'" class="field"><span>Layanan</span><select v-model="form[key]" :aria-invalid="Boolean(formErrors.service_id)" aria-describedby="admin-service-error" @change="validateRowField('service_id')"><option value="">Pilih layanan</option><option v-for="service in dataSets.services" :key="service.id" :value="service.id">{{ service.title }}</option></select><small v-if="formErrors.service_id" id="admin-service-error" class="field-error" role="alert">{{ formErrors.service_id }}</small></label>
                  <label v-if="key === 'value' && !(active === 'site_settings' && form.key === 'logo_url')" class="field"><span>Nilai</span><input v-model="form.value" type="text" :aria-invalid="Boolean(formErrors.value)" aria-describedby="admin-setting-value-error" @blur="validateRowField('value')"><small v-if="formErrors.value" id="admin-setting-value-error" class="field-error" role="alert">{{ formErrors.value }}</small></label>
                </template>
                <label v-for="key in imageFieldKeys" :key="`image-${key}`" class="field field-wide admin-image-field">
                  <span>{{ key === 'cover_image_url' ? 'Gambar sampul' : key === 'logo_url' && active === 'clients' ? 'Logo klien / partner' : key === 'logo_url' || (active === 'site_settings' && key === 'value') ? 'Logo situs' : key === 'avatar_url' ? 'Foto profil pemberi testimoni' : 'Gambar' }} <small>{{ active === 'clients' ? 'Pilih logo dari perangkat Anda; logo akan ditampilkan di bagian Klien & partner.' : active === 'testimonials' && key === 'avatar_url' ? 'Pilih foto profil yang akan ditampilkan pada kartu testimoni di halaman utama.' : 'Pilih berkas gambar dari perangkat Anda.' }}</small></span>
                  <input type="file" accept="image/jpeg,image/png,image/webp,image/avif,image/gif" :disabled="saving" @change="selectImage($event, key)">
                  <img v-if="form[key]" class="admin-image-preview" :src="form[key]" alt="Pratinjau gambar terpilih">
                </label>
              </div>
              <div class="edit-actions"><button class="button button-outline" @click="cancelEdit">Batal</button><button class="button button-dark" :disabled="saving" @click="saveRow">{{ saving ? 'Menyimpan...' : 'Simpan perubahan' }}</button></div>
            </div>
            <div class="table-scroll"><table v-if="active !== 'site_settings'" class="admin-table"><thead><tr><th v-for="field in fieldsForTable(active)" :key="field">{{ field === 'is_enabled' || field === 'is_published' ? 'STATUS' : field === 'booking_type' ? 'TIPE PEMESAN' : field === 'event_type_id' ? 'JENIS ACARA' : field.replaceAll('_',' ').toUpperCase() }}</th><th>AKSI</th></tr></thead><tbody><tr v-for="item in currentRows.filter((row) => JSON.stringify(row).toLowerCase().includes(query.toLowerCase()) && (filterStatus === 'semua' || (filterStatus === 'published' ? row.is_published : !row.is_published)))" :key="item.id"><td v-for="field in fieldsForTable(active)" :key="field">{{ displayValue(item, field) }}</td><td class="row-actions"><button class="row-edit" @click="editRow(item)">Edit</button><button v-if="item.is_published !== undefined || item.is_enabled !== undefined" class="row-toggle" @click="togglePublished(item)">{{ (item.is_published ?? item.is_enabled) ? 'Sembunyikan' : 'Publikasikan' }}</button><button v-if="isSuperAdmin" class="row-delete" @click="deleteRow(item)">Hapus</button></td></tr></tbody></table>
              <div v-if="active === 'site_settings'" class="settings-list"><article v-for="item in dataSets.site_settings" :key="item.id || item.key" class="setting-row"><div><strong>{{ item.label || item.key?.replaceAll('_',' ') || item.name }}</strong><small>{{ item.key === 'map_location' ? 'Lokasi yang ditampilkan pada peta halaman Kontak' : 'Pengaturan situs' }}</small></div><template v-if="item.key === 'map_location'"><input :id="`map-location-${item.id}`" v-model="item.value" maxlength="160" aria-label="Lokasi peta" :aria-invalid="Boolean(mapLocationErrors[item.id])" :aria-describedby="mapLocationErrors[item.id] ? `map-location-error-${item.id}` : undefined" placeholder="Contoh: Tasikmalaya, Jawa Barat" @input="delete mapLocationErrors[item.id]"><button class="row-edit" :disabled="saving" @click="saveMapLocation(item)">{{ saving ? 'Menyimpan...' : 'Simpan' }}</button></template><template v-else><input v-model="item.value" @change="editRow(item)"><button class="row-edit" @click="editRow(item)">Ubah</button></template><span v-if="item.key === 'map_location' && mapLocationErrors[item.id]" :id="`map-location-error-${item.id}`" class="field-error" role="alert">{{ mapLocationErrors[item.id] }}</span></article></div>
              <div v-if="!currentRows.length" class="admin-empty"><span>Belum ada konten. Mulai dengan menambahkan item baru.</span></div></div>
          </section>
          </template>
        </template>
        <div class="admin-footer">ABADI NAN JAYA · ADMIN STUDIO <span>{{ new Date().getFullYear() }}</span></div>
      </div>
    </main>
  </div>
</template>
