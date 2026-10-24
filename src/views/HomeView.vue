<script setup>
import { computed, ref } from 'vue'
import { ArrowDown, ArrowLeft, ArrowRight, ArrowUpRight, CalendarDays, Check, ChevronDown, Sparkles, Star } from '@lucide/vue'
import { RouterLink } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { categoryName, formatPrice, localImages } from '../data/demo'

const site = useSiteStore()
const openFaq = ref(0)
const clientTrack = ref(null)
const builtInSectionKeys = new Set(['hero', 'services', 'packages', 'portfolio', 'about', 'testimonials', 'clients', 'faq', 'cta'])
const visible = (key) => site.sections.find((section) => section.section_key === key)?.is_enabled !== false
const section = (key) => site.sections.find((item) => item.section_key === key)
const orderFor = (key, fallback) => site.sections.find((item) => item.section_key === key)?.sort_order ?? fallback
const customSections = computed(() => site.sections
  .filter((item) => !builtInSectionKeys.has(item.section_key) && item.is_enabled !== false)
  .sort((first, second) => (first.sort_order ?? 0) - (second.sort_order ?? 0)))
const safeLandingUrl = (value) => {
  const url = String(value || '').trim()
  return url.startsWith('/') || /^https?:\/\//i.test(url) ? url : '#'
}
const isExternalLandingUrl = (value) => /^https?:\/\//i.test(String(value || '').trim())
const getCategoryName = (id) => site.categories.find((category) => category.id === id)?.name || categoryName(id)
const featuredServices = computed(() => site.services.filter((service) => service.featured).slice(0, 4))
const featuredPackages = computed(() => site.packages
  .filter((item) => item.featured)
  .sort((first, second) => {
    const categoryOrder = (item) => site.categories.find((category) => category.id === site.services.find((service) => service.id === item.service_id)?.category_id)?.sort_order ?? 99
    return categoryOrder(first) - categoryOrder(second) || (first.sort_order ?? 0) - (second.sort_order ?? 0)
  })
  .slice(0, 3))
const featuredWork = computed(() => site.portfolios.slice(0, 3))
const scrollClients = (direction) => {
  const track = clientTrack.value
  if (!track) return
  const card = track.querySelector('.client-logo-card')
  const gap = Number.parseFloat(getComputedStyle(track).columnGap) || 14
  const distance = card ? (card.getBoundingClientRect().width + gap) * 2 : track.clientWidth * .8
  track.scrollBy({
    left: distance * direction,
    behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth',
  })
}
</script>

<template>
  <div v-if="site.loading && !site.loaded" class="container page-loader"><span class="skeleton skeleton-title"></span><span class="skeleton skeleton-card"></span><span class="skeleton skeleton-card"></span></div>
  <div v-else class="home-page">
    <section v-if="visible('hero')" class="hero" :style="{ order: orderFor('hero', 1) }">
      <div class="hero-image" role="img" aria-label="Perayaan sekolah di aula acara" :style="{ backgroundImage: `url('${section('hero')?.image_url || localImages.graduation}')` }"></div>
      <div class="hero-overlay"></div>
      <div class="container hero-content">
        <span class="eyebrow eyebrow-light"><span></span> PERPISAHAN SEKOLAH · WISUDA · EVENT</span>
        <h1>{{ section('hero')?.title || 'Perpisahan sekolah, jadi cerita satu angkatan.' }}</h1>
        <p>{{ section('hero')?.subtitle || 'Panggung, hiburan, rundown, dan dokumentasi kami siapkan. Sekolah dan siswa tinggal menikmati momennya.' }}</p>
        <div class="hero-actions"><RouterLink class="button button-light" :to="section('hero')?.cta_url || '/booking'">{{ section('hero')?.cta_label || 'Rencanakan acara sekolah' }} <ArrowRight :size="16" /></RouterLink><RouterLink class="text-link text-link-light" to="/portofolio">Lihat cerita kami <ArrowUpRight :size="15" /></RouterLink></div>
        <div class="hero-note"><CalendarDays :size="15" /> Dari rapat panitia sampai hari acara, kami bantu koordinasikan</div>
      </div>
      <a class="hero-scroll" href="#layanan"><ArrowDown :size="17" /> GULIR UNTUK MENJELAJAH</a>
      <div class="hero-index">01 — 05</div>
    </section>

    <section v-if="visible('services')" id="layanan" class="section section-paper" :style="{ order: orderFor('services', 2) }">
      <div class="container">
        <div class="section-heading split-heading"><div><span class="eyebrow">FOKUS KAMI: ACARA SEKOLAH</span><h2>{{ section('services')?.title || 'Partner acara untuk sekolah dan banyak cerita lain.' }}</h2></div><RouterLink class="text-link" to="/layanan">Lihat semua layanan <ArrowRight :size="16" /></RouterLink></div>
        <div class="service-grid">
          <RouterLink v-for="(service, index) in featuredServices" :key="service.id" :to="`/layanan/${service.slug}`" class="service-card">
            <div class="service-image"><img :src="service.image_url" :alt="service.title" loading="lazy"><span class="image-index">0{{ index + 1 }}</span><span class="service-arrow"><ArrowUpRight :size="18" /></span></div>
            <span class="eyebrow">{{ categoryName(service.category_id) }}</span><h3>{{ service.title }}</h3><p>{{ service.summary }}</p>
          </RouterLink>
        </div>
      </div>
    </section>

    <section v-if="visible('packages')" class="section section-cream" :style="{ order: orderFor('packages', 3) }">
      <div class="container">
        <div class="section-heading centered-heading"><span class="eyebrow">PAKET ACARA</span><h2>{{ section('packages')?.title || 'Paket perpisahan yang bisa disesuaikan.' }}</h2><p>{{ section('packages')?.subtitle || 'Mulai dari kebutuhan inti sampai tambahan panggung, photobooth, dokumentasi, dan yearbook.' }}</p></div>
        <div class="package-grid">
          <article v-for="(item, index) in featuredPackages" :key="item.id" class="package-card" :class="{ 'package-featured': index === 1 }">
            <span class="package-category">{{ getCategoryName(site.services.find((service) => service.id === item.service_id)?.category_id) }}</span><h3>{{ item.name }}</h3><p>{{ item.description }}</p>
            <div class="package-price"><small>{{ item.price_label || 'Mulai dari' }}</small><strong>{{ formatPrice(item.price) }}</strong></div>
            <ul><li v-for="inclusion in (item.inclusions || []).slice(0, 3)" :key="inclusion"><Check :size="15" />{{ inclusion }}</li></ul>
            <RouterLink class="button" :class="index === 1 ? 'button-dark' : 'button-outline'" :to="`/layanan/${site.services.find((service) => service.id === item.service_id)?.slug || 'layanan'}`">Jelajahi paket <ArrowRight :size="15" /></RouterLink>
          </article>
        </div>
      </div>
    </section>

    <section v-if="visible('portfolio')" class="section section-paper" :style="{ order: orderFor('portfolio', 4) }">
      <div class="container">
        <div class="section-heading split-heading"><div><span class="eyebrow">MOMEN YANG PERNAH KAMI RANGKAI</span><h2>{{ section('portfolio')?.title || 'Cerita yang pernah kami rangkai.' }}</h2></div><RouterLink class="text-link" to="/portofolio">Jelajahi portofolio <ArrowRight :size="16" /></RouterLink></div>
        <div class="work-grid"><RouterLink v-for="(work, index) in featuredWork" :key="work.id" to="/portofolio" class="work-card" :class="`work-card-${index + 1}`"><img :src="work.image_url" :alt="work.title" loading="lazy"><div class="work-caption"><span>{{ work.category }}</span><h3>{{ work.title }}</h3><ArrowUpRight :size="19" /></div></RouterLink></div>
      </div>
    </section>

    <section v-if="visible('about')" class="story-band" :style="{ order: orderFor('about', 5) }"><div class="story-image" :style="{ backgroundImage: `url('${section('about')?.image_url || localImages.about}')` }"></div><div class="story-copy"><span class="eyebrow eyebrow-light">TENTANG ABADI NAN JAYA</span><h2>{{ section('about')?.title || 'Acara tertata.' }}<br><em>{{ section('about')?.subtitle || 'Semua bisa ikut merayakan.' }}</em></h2><p>{{ section('about')?.body || 'Abadi nan Jaya membantu panitia mengelola konsep, produksi, dan koordinasi acara. Fokus utama kami adalah perayaan sekolah—mulai dari perpisahan dan wisuda hingga buku kenangan—serta berbagai acara komunitas, corporate, dan personal.' }}</p><RouterLink class="text-link text-link-light" to="/tentang-kami">Kenali kami lebih dekat <ArrowRight :size="16" /></RouterLink></div></section>

    <section v-if="visible('testimonials')" class="section section-cream" :style="{ order: orderFor('testimonials', 6) }"><div class="container">
      <div class="section-heading centered-heading"><span class="eyebrow">CERITA DARI MEREKA</span><h2>{{ section('testimonials')?.title || 'Cerita dari panitia dan sekolah.' }}</h2></div>
      <div class="testimonial-grid"><article v-for="item in site.testimonials.slice(0, 3)" :key="item.id" class="testimonial-card"><div class="stars"><Star v-for="star in (item.rating || 5)" :key="star" :size="14" fill="currentColor" /></div><blockquote>“{{ item.quote }}”</blockquote><div class="testimonial-author"><img v-if="item.avatar_url" class="testimonial-avatar" :src="item.avatar_url" :alt="`Foto profil ${item.name}`" loading="lazy"><span v-else class="avatar">{{ item.name?.charAt(0) }}</span><div><strong>{{ item.name }}</strong><small>{{ item.role }}</small></div></div></article></div>
    </div></section>

    <section v-if="visible('clients')" class="section section-paper clients-section" :style="{ order: orderFor('clients', 7) }"><div class="container">
      <div class="clients-heading"><span class="eyebrow">{{ section('clients')?.title || 'MEREKA YANG TELAH BERSAMA KAMI' }}</span><div v-if="site.clients.length > 1" class="clients-controls"><span>{{ site.clients.length }} partner</span><button type="button" aria-label="Geser partner ke kiri" @click="scrollClients(-1)"><ArrowLeft :size="17" /></button><button type="button" aria-label="Geser partner ke kanan" @click="scrollClients(1)"><ArrowRight :size="17" /></button></div></div>
      <div ref="clientTrack" class="client-row" role="region" aria-label="Carousel klien dan partner" tabindex="0"><div v-for="client in site.clients" :key="client.id" class="client-logo-card"><img v-if="client.logo_url" :src="client.logo_url" :alt="`Logo ${client.name}`" loading="lazy"><span class="client-logo-name">{{ client.name }}</span></div></div>
    </div></section>

    <section v-if="visible('faq')" class="section section-cream" :style="{ order: orderFor('faq', 8) }"><div class="container faq-layout"><div class="faq-intro"><span class="eyebrow">FAQ</span><h2>{{ section('faq')?.title || 'Pertanyaan yang sering muncul.' }}</h2><p>Belum menemukan jawaban? Kami dengan senang hati membantu.</p><RouterLink class="text-link" to="/kontak">Tanyakan pada kami <ArrowRight :size="16" /></RouterLink></div><div class="faq-list"><article v-for="(faq, index) in site.faqs" :key="faq.id" class="faq-item" :class="{ expanded: openFaq === index }"><button type="button" @click="openFaq = openFaq === index ? -1 : index"><span>{{ faq.question }}</span><ChevronDown :size="17" /></button><p v-if="openFaq === index">{{ faq.answer }}</p></article></div></div></section>

    <section v-if="visible('cta')" class="closing-cta" :style="{ order: orderFor('cta', 9) }"><div class="container closing-inner"><Sparkles :size="23" /><span class="eyebrow eyebrow-light">MOMEN BERIKUTNYA BISA JADI MILIK ANDA</span><h2>{{ section('cta')?.title || 'Ada cerita yang ingin Anda rayakan?' }}</h2><p>{{ section('cta')?.subtitle || 'Ceritakan rencana Anda. Kami akan membantu merangkai sisanya.' }}</p><RouterLink class="button button-light" :to="section('cta')?.cta_url || '/kontak'">{{ section('cta')?.cta_label || 'Mulai percakapan' }} <ArrowRight :size="16" /></RouterLink></div></section>

    <section v-for="customSection in customSections" :key="customSection.id" class="section section-paper custom-home-section" :style="{ order: customSection.sort_order }">
      <div class="container custom-home-builder">
        <h2 class="custom-home-section-title">{{ customSection.title }}</h2>
        <div v-for="(row, rowIndex) in customSection.content_blocks || []" :key="row.id || rowIndex" class="custom-home-row">
          <div v-for="(column, columnIndex) in row.columns || []" :key="column.id || columnIndex" class="custom-home-column" :style="{ gridColumn: `span ${Math.max(1, Math.min(12, Number(column.width) || 12))}` }">
            <template v-for="(block, blockIndex) in column.blocks || []" :key="block.id || blockIndex">
              <component :is="block.level === 4 ? 'h4' : 'h3'" v-if="block.type === 'heading' && block.text" class="custom-home-block-heading">{{ block.text }}</component>
              <p v-else-if="block.type === 'text' && block.text" :class="{ 'custom-home-lead': block.lead }">{{ block.text }}</p>
              <img v-else-if="block.type === 'image' && block.image_url" class="custom-home-block-image" :src="block.image_url" :alt="block.alt || customSection.title" loading="lazy">
              <blockquote v-else-if="block.type === 'quote' && block.text" class="custom-home-quote">{{ block.text }}</blockquote>
              <a v-else-if="block.type === 'button' && block.label" class="button button-outline custom-home-block-button" :href="safeLandingUrl(block.url)" :target="isExternalLandingUrl(block.url) ? '_blank' : undefined" :rel="isExternalLandingUrl(block.url) ? 'noreferrer' : undefined">{{ block.label }} <ArrowRight :size="15" /></a>
            </template>
          </div>
        </div>
        <div v-if="!customSection.content_blocks?.length" class="custom-home-legacy">
          <p v-if="customSection.subtitle" class="custom-home-lead">{{ customSection.subtitle }}</p>
          <p v-if="customSection.body">{{ customSection.body }}</p>
          <img v-if="customSection.image_url" class="custom-home-block-image" :src="customSection.image_url" :alt="customSection.title" loading="lazy">
          <a v-if="customSection.cta_label" class="button button-outline custom-home-block-button" :href="safeLandingUrl(customSection.cta_url)">{{ customSection.cta_label }} <ArrowRight :size="15" /></a>
        </div>
      </div>
    </section>
  </div>
</template>
