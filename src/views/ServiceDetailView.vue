<script setup>
import { computed } from 'vue'
import { ArrowLeft, ArrowRight, Check, Plus, Sparkles } from '@lucide/vue'
import { useRoute } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { categoryName, formatPrice } from '../data/demo'

const route = useRoute()
const site = useSiteStore()
const service = computed(() => site.services.find((item) => item.slug === route.params.slug))
const getCategoryName = (id) => site.categories.find((category) => category.id === id)?.name || categoryName(id)
const packages = computed(() => site.packages.filter((item) => item.service_id === service.value?.id))
const whatsapp = (item) => `https://wa.me/${site.settings.whatsapp || '6281234567890'}?text=${encodeURIComponent(`Halo Abadi nan Jaya, saya tertarik dengan ${item} untuk acara saya.`)}`
</script>

<template>
  <div v-if="service">
    <section class="detail-hero"><img :src="service.image_url" :alt="service.title"><div class="detail-shade"></div><div class="container detail-content"><div class="breadcrumb breadcrumb-light"><RouterLink to="/">Beranda</RouterLink><span>/</span><RouterLink to="/layanan">Layanan</RouterLink><span>/</span><span>{{ service.title }}</span></div><span class="eyebrow eyebrow-light">{{ getCategoryName(service.category_id) }}</span><h1>{{ service.title }}</h1><p>{{ service.summary }}</p><a class="button button-light" :href="whatsapp(service.title)" target="_blank" rel="noreferrer">Konsultasi via WhatsApp <ArrowRight :size="16" /></a></div></section>
    <section class="section section-paper"><div class="container detail-layout"><article><span class="eyebrow">DIRANGKAI UNTUK ANDA</span><h2>Hari yang terasa<br><em>seperti milik Anda.</em></h2><p class="detail-description">{{ service.description }}</p><p class="detail-description">Setiap detail kami rancang bersama Anda, agar momen ini menjadi pengalaman yang paling autentik dan mudah dikenang.</p><RouterLink class="text-link" to="/kontak">Ceritakan rencana Anda <ArrowRight :size="15" /></RouterLink></article><div class="detail-note"><Sparkles :size="21" /><h3>Penuh perhatian,<br>sejak percakapan pertama.</h3><p>Tim kami akan mendengarkan cerita Anda dan merancang penawaran yang sesuai.</p><RouterLink class="text-link" to="/kontak">Minta penawaran <ArrowRight :size="15" /></RouterLink></div></div></section>
    <section class="section section-cream"><div class="container"><div class="section-heading split-heading"><div><span class="eyebrow">PAKET PILIHAN</span><h2>Pilih cara Anda merayakan.</h2></div><p class="muted-copy">Semua paket dapat disesuaikan<br>dengan kebutuhan momen Anda.</p></div>
      <div v-if="packages.length" class="package-grid detail-packages"><article v-for="(item, index) in packages" :key="item.id" class="package-card" :class="{ 'package-featured': index === 1 }"><span class="package-category">{{ getCategoryName(service.category_id) }}</span><h3>{{ item.name }}</h3><p>{{ item.description }}</p><div class="package-price"><small>{{ item.price_label || 'Mulai dari' }}</small><strong>{{ formatPrice(item.price) }}</strong></div><h4>Sudah termasuk</h4><ul><li v-for="inclusion in item.inclusions" :key="inclusion"><Check :size="15" />{{ inclusion }}</li></ul><div v-if="item.addons?.length" class="addon-list"><h4>Pilihan add-on & peralatan <Plus :size="13" /></h4><span v-for="addon in item.addons" :key="addon.id || addon.name">{{ addon.name }} <small>{{ formatPrice(addon.price) }}</small></span></div><a class="button button-outline" :href="whatsapp(item.name)" target="_blank" rel="noreferrer">Tanya via WhatsApp <ArrowRight :size="15" /></a><RouterLink class="button button-dark" :to="{ name: 'booking', query: { package: item.slug } }">Booking paket ini <ArrowRight :size="15" /></RouterLink></article></div>
      <div v-else class="empty-state">Paket untuk layanan ini sedang disiapkan. <RouterLink class="text-link" to="/kontak">Minta penawaran khusus</RouterLink></div>
    </div></section>
    <section class="section section-paper"><div class="container detail-bottom"><div><span class="eyebrow">PUNYA PERTANYAAN?</span><h2>Mari mulai dari<br>sebuah percakapan.</h2></div><RouterLink class="button button-dark" to="/kontak">Hubungi konsultan kami <ArrowRight :size="16" /></RouterLink></div></section>
  </div>
  <section v-else class="empty-state page-empty"><h1>Layanan tidak ditemukan.</h1><RouterLink class="button button-dark" to="/layanan"><ArrowLeft :size="16" /> Kembali ke katalog</RouterLink></section>
</template>
