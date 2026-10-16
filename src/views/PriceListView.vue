<script setup>
import { computed } from 'vue'
import { ArrowDownToLine, ArrowRight, Check } from '@lucide/vue'
import { useSiteStore } from '../stores/site'
import { formatPrice } from '../data/demo'

const site = useSiteStore()
const categories = computed(() => site.categories.map((category) => ({ ...category, packages: site.packages.filter((item) => site.services.some((service) => service.id === item.service_id && service.category_id === category.id)) })).filter((category) => category.packages.length))
function downloadPdf() { window.print() }
</script>

<template>
  <section class="page-hero"><div class="container"><span class="eyebrow">TRANSPARAN SEJAK AWAL</span><h1>Ruang untuk momen,<br>sesuai rencana Anda.</h1><p>Kenali kisaran harga layanan dan paket kami. Setiap perayaan dapat disesuaikan dengan kebutuhan khusus Anda.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Daftar harga</span></div></div></section>
  <section class="section section-paper">  <div class="container"><div class="price-intro"><div><span class="eyebrow">DAFTAR PAKET</span><h2>Temukan titik awalnya.</h2></div><button class="button button-outline print-button" @click="downloadPdf"><ArrowDownToLine :size="16" /> Simpan sebagai PDF</button></div>
    <div v-for="category in categories" :key="category.id" class="price-category"><div class="price-category-heading"><div><span class="eyebrow">{{ category.name.toUpperCase() }}</span><h3>{{ category.description }}</h3></div><RouterLink class="text-link" to="/kontak">Tanya lebih lanjut <ArrowRight :size="15" /></RouterLink></div><div class="price-table-wrap"><table class="price-table"><thead><tr><th>Paket</th><th>Termasuk</th><th>Harga mulai dari</th><th></th></tr></thead><tbody><tr v-for="item in category.packages" :key="item.id"><td><strong>{{ item.name }}</strong><small>{{ item.description }}</small></td><td><span v-for="inclusion in item.inclusions.slice(0, 2)" :key="inclusion" class="price-inclusion"><Check :size="13" />{{ inclusion }}</span><span v-if="item.inclusions.length > 2" class="more-inclusions">+ {{ item.inclusions.length - 2 }} layanan lainnya</span></td><td class="price-amount"><small>{{ item.price_label || 'Mulai dari' }}</small><strong>{{ formatPrice(item.price) }}</strong></td><td><RouterLink class="price-arrow" :to="`/layanan/${site.services.find((service) => service.id === item.service_id)?.slug}`" :aria-label="`Lihat ${item.name}`"><ArrowRight :size="17" /></RouterLink></td></tr></tbody></table></div></div>
    <div class="price-note"><strong>Penawaran dibuat untuk cerita Anda.</strong><p>Harga akhir dapat berubah mengikuti jumlah tamu, lokasi, tanggal, dan kebutuhan khusus. Biaya tambahan akan dikomunikasikan secara transparan.</p><RouterLink class="button button-dark" to="/kontak">Minta penawaran personal <ArrowRight :size="15" /></RouterLink></div>
  </div></section>
</template>
