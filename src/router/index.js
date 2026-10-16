import { createRouter, createWebHistory } from 'vue-router'
import { requireSupabase, supabase } from '../lib/supabase'
import HomeView from '../views/HomeView.vue'
import CatalogView from '../views/CatalogView.vue'
import ServiceDetailView from '../views/ServiceDetailView.vue'
import PortfolioView from '../views/PortfolioView.vue'
import PriceListView from '../views/PriceListView.vue'
import ContactView from '../views/ContactView.vue'
import BookingView from '../views/BookingView.vue'
import AboutView from '../views/AboutView.vue'
import AdminView from '../views/AdminView.vue'
import AdminLoginView from '../views/AdminLoginView.vue'
import NotFoundView from '../views/NotFoundView.vue'

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior: () => ({ top: 0, behavior: 'smooth' }),
  routes: [
    { path: '/', name: 'home', component: HomeView, meta: { title: 'Beranda' } },
    { path: '/layanan', name: 'catalog', component: CatalogView, meta: { title: 'Katalog layanan' } },
    { path: '/layanan/:slug', name: 'service', component: ServiceDetailView, meta: { title: 'Detail layanan' } },
    { path: '/portofolio', name: 'portfolio', component: PortfolioView, meta: { title: 'Portofolio' } },
    { path: '/harga', name: 'prices', component: PriceListView, meta: { title: 'Daftar harga' } },
    { path: '/kontak', name: 'contact', component: ContactView, meta: { title: 'Kontak' } },
    { path: '/booking', name: 'booking', component: BookingView, meta: { title: 'Booking acara' } },
    { path: '/tentang-kami', name: 'about', component: AboutView, meta: { title: 'Tentang kami' } },
    { path: '/admin/login', name: 'admin-login', component: AdminLoginView, meta: { title: 'Masuk admin', publicOnly: true } },
    { path: '/admin/:pathMatch(.*)*', name: 'admin', component: AdminView, meta: { title: 'Dashboard admin', requiresAdmin: true } },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundView, meta: { title: 'Halaman tidak ditemukan' } },
  ],
})

router.beforeEach(async (to) => {
  document.title = `${to.meta.title || 'Abadi nan Jaya'} — Abadi nan Jaya`
  if (to.meta.requiresAdmin) {
    if (!supabase) return to.query.demo === '1' ? true : { name: 'admin-login', query: { setup: 'supabase' } }
    const client = requireSupabase()
    const { data: { session }, error } = await client.auth.getSession()
    if (error || !session) return { name: 'admin-login', query: { redirect: to.fullPath } }
    const { data: profile, error: profileError } = await client.from('profiles').select('id,role,full_name').eq('id', session.user.id).single()
    if (profileError || !profile || !['super_admin', 'editor'].includes(profile.role)) {
      await client.auth.signOut()
      return { name: 'admin-login', query: { error: 'Akun ini belum memiliki akses admin.' } }
    }
    to.meta.profile = profile
  }
  return true
})

export default router
