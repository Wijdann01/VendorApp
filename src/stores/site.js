import { defineStore } from 'pinia'
import { ref } from 'vue'
import { demoCategories, demoClients, demoContacts, demoFaqs, demoLandingSections, demoPackages, demoPortfolios, demoServices, demoTestimonials, localImages } from '../data/demo'
import { supabase, supabaseConfigured } from '../lib/supabase'

const uploadedStorageUrl = (value) => /^https:\/\/[^/]+\.supabase\.co\/storage\/v1\/object\/public\//.test(value || '')
const keepLocalOrUploaded = (value, fallback) => value?.startsWith('/') || uploadedStorageUrl(value) ? value : fallback

export const useSiteStore = defineStore('site', () => {
  const categories = ref([])
  const services = ref([])
  const packages = ref([])
  const portfolios = ref([])
  const testimonials = ref([])
  const faqs = ref([])
  const clients = ref([])
  const contacts = ref([])
  const sections = ref([])
  const eventTypes = ref([
    { id: 'org-school-graduation', name: 'Perpisahan & Wisuda', booking_type: 'organization', sort_order: 1, is_published: true, service_ids: ['graduation-celebration', 'visual-production'] },
    { id: 'org-yearbook', name: 'Yearbook', booking_type: 'organization', sort_order: 2, is_published: true, service_ids: ['yearbook-story', 'visual-production'] },
    { id: 'org-event-corporate', name: 'Event & Corporate', booking_type: 'organization', sort_order: 3, is_published: true, service_ids: ['corporate-event', 'visual-production'] },
    { id: 'org-event-organizer', name: 'Event Organizer', booking_type: 'organization', sort_order: 4, is_published: true, service_ids: ['event-organizer', 'corporate-event', 'visual-production'] },
    { id: 'org-company-event', name: 'Acara perusahaan', booking_type: 'organization', sort_order: 5, is_published: true, service_ids: ['corporate-event', 'event-organizer', 'visual-production'] },
    { id: 'org-company-gathering', name: 'Gathering perusahaan', booking_type: 'organization', sort_order: 6, is_published: true, service_ids: ['corporate-event', 'event-organizer', 'visual-production'] },
    { id: 'org-community-event', name: 'Acara komunitas', booking_type: 'organization', sort_order: 7, is_published: true, service_ids: ['corporate-event', 'event-organizer', 'visual-production'] },
    { id: 'org-other-event', name: 'Lainnya', booking_type: 'organization', sort_order: 8, is_published: true, service_ids: ['graduation-celebration', 'yearbook-story', 'corporate-event', 'event-organizer', 'visual-production'] },
    { id: 'personal-wedding', name: 'Wedding', booking_type: 'personal', sort_order: 1, is_published: true, service_ids: ['wedding-planning', 'visual-production'] },
    { id: 'personal-birthday', name: 'Ulang tahun', booking_type: 'personal', sort_order: 2, is_published: true, service_ids: ['wedding-planning', 'visual-production'] },
    { id: 'personal-family', name: 'Perayaan keluarga', booking_type: 'personal', sort_order: 3, is_published: true, service_ids: ['wedding-planning', 'visual-production'] },
    { id: 'personal-gathering', name: 'Gathering pribadi', booking_type: 'personal', sort_order: 4, is_published: true, service_ids: ['wedding-planning', 'visual-production'] },
    { id: 'personal-other-event', name: 'Lainnya', booking_type: 'personal', sort_order: 5, is_published: true, service_ids: ['wedding-planning', 'visual-production'] },
  ])
  const settings = ref({ brand_name: 'Abadi nan Jaya', whatsapp: '6281234567890', tagline: 'Merayakan setiap cerita', instagram: '@abadinanjaya', map_location: 'Tasikmalaya, Jawa Barat' })
  const loading = ref(false)
  const loaded = ref(false)
  const error = ref('')

  async function loadPublicContent(force = false) {
    if (loaded.value && !force) return
    loading.value = true
    error.value = ''
    try {
    if (supabaseConfigured) {
      const tables = ['categories', 'services', 'packages', 'portfolios', 'testimonials', 'faqs', 'clients', 'contacts', 'landing_sections', 'event_types']
      const results = await Promise.all(tables.map((table) => {
        const columns = table === 'packages'
          ? '*,addons(id,name,description,price,is_published),package_items(name,sort_order)'
          : table === 'event_types'
            ? '*,event_type_services(service_id)'
          : table === 'portfolios'
            ? '*,portfolio_media(media_url,media_type,alt_text,sort_order)'
            : '*'
        const query = supabase.from(table).select(columns)
        return query.eq(table === 'landing_sections' ? 'is_enabled' : 'is_published', true).order('sort_order', { ascending: true }).limit(100)
      }))
      const failed = results.find((result) => result.error)
      if (failed) {
        loading.value = false
        error.value = failed.error.message
        throw new Error(`Gagal memuat konten publik: ${failed.error.message}`)
      }
      ;[categories.value, services.value, packages.value, portfolios.value, testimonials.value, faqs.value, clients.value, contacts.value, sections.value, eventTypes.value] = results.map(({ data }, index) => {
        if (index === 2) return (data || []).map((item) => ({
          ...item,
          inclusions: item.package_items?.length ? item.package_items.sort((a, b) => a.sort_order - b.sort_order).map((entry) => entry.name) : item.inclusions,
          addons: (item.addons || []).filter((addon) => addon.is_published),
        }))
        if (index === 3) return (data || []).map((item) => ({ ...item, image_url: item.cover_image_url || item.image_url }))
          .map((item) => ({ ...item, media: (item.portfolio_media || []).sort((a, b) => a.sort_order - b.sort_order) }))
        if (index === 9) return (data || []).map((item) => ({
          ...item,
          service_ids: (item.event_type_services || []).map((relation) => relation.service_id),
        }))
        return data || []
      })
      packages.value = packages.value.filter((item) => eventTypes.value.some((eventType) => eventType.id === item.event_type_id))
      const categoryImage = (categoryId) => {
        const slug = categories.value.find((category) => category.id === categoryId)?.slug
        return localImages[slug] || localImages.production
      }
      services.value = services.value.map((service) => ({
        ...service,
        image_url: keepLocalOrUploaded(service.image_url, localImages[service.slug] || categoryImage(service.category_id)),
      }))
      const portfolioImages = {
        'a-garden-wedding': localImages.wedding,
        'together-forward': localImages.corporate,
        'class-of-2025': localImages.graduation,
        'the-art-of-gathering': localImages.organizing,
        'our-little-universe': localImages.yearbook,
        'golden-hour-vows': localImages.weddingSunset,
      }
      portfolios.value = portfolios.value.map((portfolio) => ({
        ...portfolio,
        image_url: keepLocalOrUploaded(portfolio.image_url, portfolioImages[portfolio.slug] || categoryImage(portfolio.category_id)),
        media: (portfolio.media || []).map((item) => ({
          ...item,
          media_url: keepLocalOrUploaded(item.media_url, portfolioImages[portfolio.slug] || categoryImage(portfolio.category_id)),
        })),
      }))
      sections.value = sections.value.map((section) => ({
        ...section,
        image_url: section.image_url?.startsWith('/') || uploadedStorageUrl(section.image_url)
          ? section.image_url
          : section.section_key === 'hero'
            ? localImages.graduation
            : section.section_key === 'about'
              ? localImages.about
              : '',
      }))
      const { data: siteSettings, error: settingsError } = await supabase.from('site_settings').select('key,value').eq('is_public', true)
      if (settingsError) {
        loading.value = false
        error.value = settingsError.message
        throw new Error(`Gagal memuat pengaturan situs: ${settingsError.message}`)
      }
      for (const entry of siteSettings || []) settings.value = { ...settings.value, ...entry.value }
      settings.value.logo_url = keepLocalOrUploaded(settings.value.logo_url, '')
    } else {
      categories.value = demoCategories
      services.value = demoServices
      packages.value = demoPackages
      portfolios.value = demoPortfolios
      testimonials.value = demoTestimonials
      faqs.value = demoFaqs
      clients.value = demoClients.map((name, index) => ({ id: `client-${index}`, name, is_published: true }))
      contacts.value = demoContacts
      sections.value = demoLandingSections
      eventTypes.value = eventTypes.value.filter((item) => item.is_published)
    }
    loaded.value = true
    } catch (cause) {
      error.value = cause.message || 'Konten situs tidak dapat dimuat.'
      throw cause
    } finally {
      loading.value = false
    }
  }

  return { categories, services, packages, portfolios, testimonials, faqs, clients, contacts, sections, eventTypes, settings, loading, loaded, error, loadPublicContent }
})
