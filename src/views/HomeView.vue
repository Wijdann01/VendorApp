<script setup>
import { computed, ref } from 'vue'
import { ArrowDown, ArrowRight, ArrowUpRight, Check, ChevronDown, Heart, Sparkles, Star } from '@lucide/vue'
import { RouterLink } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { categoryName, formatPrice, localImages } from '../data/demo'

const site = useSiteStore()
const openFaq = ref(0)
const visible = (key) => site.sections.find((section) => section.section_key === key)?.is_enabled !== false
const section = (key) => site.sections.find((item) => item.section_key === key)
const orderFor = (key, fallback) => site.sections.find((item) => item.section_key === key)?.sort_order ?? fallback
const getCategoryName = (id) => site.categories.find((category) => category.id === id)?.name || categoryName(id)
const featuredServices = computed(() => site.services.filter((service) => service.featured).slice(0, 4))
const featuredPackages = computed(() => site.packages.filter((item) => item.featured).slice(0, 3))
const featuredWork = computed(() => site.portfolios.slice(0, 3))
</script>

<template>
  <div v-if="site.loading && !site.loaded" class="container page-loader"><span class="skeleton skeleton-title"></span><span class="skeleton skeleton-card"></span><span class="skeleton skeleton-card"></span></div>
  <div v-else class="home-page">
    <section v-if="visible('hero')" class="hero" :style="{ order: orderFor('hero', 1) }">
      <div class="hero-image" role="img" aria-label="Pesta pernikahan di taman" :style="{ backgroundImage: `url('${section('hero')?.image_url || localImages.wedding}')` }"></div>
      <div class="hero-overlay"></div>
      <div class="container hero-content">
        <span class="eyebrow eyebrow-light"><span></span> WEDDINGS · EVENTS · STORIES</span>
        <h1>{{ section('hero')?.title || 'Setiap perayaan punya cerita.' }}</h1>
        <p>{{ section('hero')?.subtitle || 'Kami hadir untuk merancang momen yang terasa dekat, indah, dan selalu diingat.' }}</p>
        <div class="hero-actions"><RouterLink class="button button-light" :to="section('hero')?.cta_url || '/layanan'">{{ section('hero')?.cta_label || 'Temukan layanan' }} <ArrowRight :size="16" /></RouterLink><RouterLink class="text-link text-link-light" to="/portofolio">Lihat cerita kami <ArrowUpRight :size="15" /></RouterLink></div>
        <div class="hero-note"><Heart :size="15" /> Momen berarti, dirangkai dengan sepenuh hati</div>
      </div>
      <a class="hero-scroll" href="#layanan"><ArrowDown :size="17" /> GULIR UNTUK MENJELAJAH</a>
      <div class="hero-index">01 — 05</div>
    </section>

    <section v-if="visible('services')" id="layanan" class="section section-paper" :style="{ order: orderFor('services', 2) }">
      <div class="container">
        <div class="section-heading split-heading"><div><span class="eyebrow">APA YANG KAMI RANGKAI</span><h2>{{ section('services')?.title || 'Satu partner untuk setiap perayaan.' }}</h2></div><RouterLink class="text-link" to="/layanan">Lihat semua layanan <ArrowRight :size="16" /></RouterLink></div>
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
        <div class="section-heading centered-heading"><span class="eyebrow">PILIHAN FAVORIT</span><h2>{{ section('packages')?.title || 'Awali dari yang paling sesuai.' }}</h2><p>{{ section('packages')?.subtitle || 'Setiap cerita berbeda. Temukan paket yang terasa pas untuk momen Anda.' }}</p></div>
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

    <section v-if="visible('about')" class="story-band" :style="{ order: orderFor('about', 5) }"><div class="story-image" :style="{ backgroundImage: `url('${section('about')?.image_url || localImages.about}')` }"></div><div class="story-copy"><span class="eyebrow eyebrow-light">TENTANG ABADI NAN JAYA</span><h2>{{ section('about')?.title || 'Bukan sekadar acara.' }}<br><em>{{ section('about')?.subtitle || 'Sebuah cerita untuk dikenang.' }}</em></h2><p>{{ section('about')?.body || 'Kami percaya momen terbaik lahir ketika semua terasa dekat dan bermakna. Sejak 2014, kami membantu keluarga, sekolah, dan brand merayakan perjalanan mereka.' }}</p><RouterLink class="text-link text-link-light" to="/tentang-kami">Kenali kami lebih dekat <ArrowRight :size="16" /></RouterLink></div></section>

    <section v-if="visible('testimonials')" class="section section-cream" :style="{ order: orderFor('testimonials', 6) }"><div class="container">
      <div class="section-heading centered-heading"><span class="eyebrow">CERITA DARI MEREKA</span><h2>{{ section('testimonials')?.title || 'Kata mereka setelah hari istimewa.' }}</h2></div>
      <div class="testimonial-grid"><article v-for="item in site.testimonials.slice(0, 3)" :key="item.id" class="testimonial-card"><div class="stars"><Star v-for="star in (item.rating || 5)" :key="star" :size="14" fill="currentColor" /></div><blockquote>“{{ item.quote }}”</blockquote><div class="testimonial-author"><span class="avatar">{{ item.name?.charAt(0) }}</span><div><strong>{{ item.name }}</strong><small>{{ item.role }}</small></div></div></article></div>
    </div></section>

    <section v-if="visible('clients')" class="section section-paper clients-section" :style="{ order: orderFor('clients', 7) }"><div class="container"><span class="eyebrow">{{ section('clients')?.title || 'MEREKA YANG TELAH BERSAMA KAMI' }}</span><div class="client-row"><span v-for="client in site.clients.slice(0, 5)" :key="client.id">{{ client.name }}</span></div></div></section>

    <section v-if="visible('faq')" class="section section-cream" :style="{ order: orderFor('faq', 8) }"><div class="container faq-layout"><div class="faq-intro"><span class="eyebrow">FAQ</span><h2>{{ section('faq')?.title || 'Pertanyaan yang sering muncul.' }}</h2><p>Belum menemukan jawaban? Kami dengan senang hati membantu.</p><RouterLink class="text-link" to="/kontak">Tanyakan pada kami <ArrowRight :size="16" /></RouterLink></div><div class="faq-list"><article v-for="(faq, index) in site.faqs" :key="faq.id" class="faq-item" :class="{ expanded: openFaq === index }"><button type="button" @click="openFaq = openFaq === index ? -1 : index"><span>{{ faq.question }}</span><ChevronDown :size="17" /></button><p v-if="openFaq === index">{{ faq.answer }}</p></article></div></div></section>

    <section v-if="visible('cta')" class="closing-cta" :style="{ order: orderFor('cta', 9) }"><div class="container closing-inner"><Sparkles :size="23" /><span class="eyebrow eyebrow-light">MOMEN BERIKUTNYA BISA JADI MILIK ANDA</span><h2>{{ section('cta')?.title || 'Ada cerita yang ingin Anda rayakan?' }}</h2><p>{{ section('cta')?.subtitle || 'Ceritakan rencana Anda. Kami akan membantu merangkai sisanya.' }}</p><RouterLink class="button button-light" :to="section('cta')?.cta_url || '/kontak'">{{ section('cta')?.cta_label || 'Mulai percakapan' }} <ArrowRight :size="16" /></RouterLink></div></section>
  </div>
</template>
