<script setup>
import { computed, ref } from 'vue'
import { ArrowDown, ArrowRight, ArrowUpRight, CalendarDays, Check, ChevronDown, Sparkles, Star } from '@lucide/vue'
import { RouterLink } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { categoryName, formatPrice, localImages } from '../data/demo'

const site = useSiteStore()
const openFaq = ref(0)
const builtInSectionKeys = new Set(['hero', 'services', 'packages', 'portfolio', 'about', 'testimonials', 'clients', 'faq', 'cta'])
const visible = (key) => site.sections.find((section) => section.section_key === key)?.is_enabled !== false
const section = (key) => site.sections.find((item) => item.section_key === key)
const orderFor = (key, fallback) => site.sections.find((item) => item.section_key === key)?.sort_order ?? fallback
const customSections = computed(() => site.sections
  .filter((item) => !builtInSectionKeys.has(item.section_key) && item.is_enabled !== false)
  .sort((first, second) => (first.sort_order ?? 0) - (second.sort_order ?? 0)))
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
      <div class="testimonial-grid"><article v-for="item in site.testimonials.slice(0, 3)" :key="item.id" class="testimonial-card"><div class="stars"><Star v-for="star in (item.rating || 5)" :key="star" :size="14" fill="currentColor" /></div><blockquote>“{{ item.quote }}”</blockquote><div class="testimonial-author"><span class="avatar">{{ item.name?.charAt(0) }}</span><div><strong>{{ item.name }}</strong><small>{{ item.role }}</small></div></div></article></div>
    </div></section>

    <section v-if="visible('clients')" class="section section-paper clients-section" :style="{ order: orderFor('clients', 7) }"><div class="container"><span class="eyebrow">{{ section('clients')?.title || 'MEREKA YANG TELAH BERSAMA KAMI' }}</span><div class="client-row"><span v-for="client in site.clients.slice(0, 5)" :key="client.id">{{ client.name }}</span></div></div></section>

    <section v-if="visible('faq')" class="section section-cream" :style="{ order: orderFor('faq', 8) }"><div class="container faq-layout"><div class="faq-intro"><span class="eyebrow">FAQ</span><h2>{{ section('faq')?.title || 'Pertanyaan yang sering muncul.' }}</h2><p>Belum menemukan jawaban? Kami dengan senang hati membantu.</p><RouterLink class="text-link" to="/kontak">Tanyakan pada kami <ArrowRight :size="16" /></RouterLink></div><div class="faq-list"><article v-for="(faq, index) in site.faqs" :key="faq.id" class="faq-item" :class="{ expanded: openFaq === index }"><button type="button" @click="openFaq = openFaq === index ? -1 : index"><span>{{ faq.question }}</span><ChevronDown :size="17" /></button><p v-if="openFaq === index">{{ faq.answer }}</p></article></div></div></section>

    <section v-if="visible('cta')" class="closing-cta" :style="{ order: orderFor('cta', 9) }"><div class="container closing-inner"><Sparkles :size="23" /><span class="eyebrow eyebrow-light">MOMEN BERIKUTNYA BISA JADI MILIK ANDA</span><h2>{{ section('cta')?.title || 'Ada cerita yang ingin Anda rayakan?' }}</h2><p>{{ section('cta')?.subtitle || 'Ceritakan rencana Anda. Kami akan membantu merangkai sisanya.' }}</p><RouterLink class="button button-light" :to="section('cta')?.cta_url || '/kontak'">{{ section('cta')?.cta_label || 'Mulai percakapan' }} <ArrowRight :size="16" /></RouterLink></div></section>

    <section v-for="customSection in customSections" :key="customSection.id" class="section section-paper custom-home-section" :style="{ order: customSection.sort_order }">
      <div class="container" :class="{ 'custom-home-content-with-image': customSection.image_url }">
        <img v-if="customSection.image_url" class="custom-home-image" :src="customSection.image_url" :alt="customSection.title" loading="lazy">
        <div class="custom-home-copy">
          <span class="eyebrow">INFORMASI</span>
          <h2>{{ customSection.title }}</h2>
          <p v-if="customSection.subtitle" class="custom-home-subtitle">{{ customSection.subtitle }}</p>
          <p v-if="customSection.body">{{ customSection.body }}</p>
          <RouterLink v-if="customSection.cta_label && customSection.cta_url" class="button button-outline" :to="customSection.cta_url">{{ customSection.cta_label }} <ArrowRight :size="15" /></RouterLink>
        </div>
      </div>
    </section>
  </div>
</template>
