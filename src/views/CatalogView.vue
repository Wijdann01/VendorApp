<script setup>
import { computed, ref } from 'vue'
import { ArrowRight, Search, X } from '@lucide/vue'
import { useSiteStore } from '../stores/site'
import { categoryName } from '../data/demo'

const site = useSiteStore()
const selected = ref('Semua')
const search = ref('')
const getCategoryName = (id) => site.categories.find((category) => category.id === id)?.name || categoryName(id)
const categories = computed(() => ['Semua', ...site.categories.map((category) => category.name)])
const filtered = computed(() => site.services.filter((item) => (selected.value === 'Semua' || getCategoryName(item.category_id) === selected.value) && `${item.title} ${item.summary} ${getCategoryName(item.category_id)}`.toLowerCase().includes(search.value.toLowerCase())))
</script>

<template>
  <section class="page-hero"><div class="container"><span class="eyebrow">LAYANAN ABADI NAN JAYA</span><h1>Setiap cerita, punya cara<br>untuk dirayakan.</h1><p>Dari hari istimewa hingga perayaan bersama, temukan partner yang tepat untuk momen Anda.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Layanan</span></div></div></section>
  <section class="section section-paper"><div class="container">
    <div class="catalog-toolbar"><div class="filter-list"><button v-for="category in categories" :key="category" class="filter-chip" :class="{ selected: selected === category }" @click="selected = category">{{ category }}</button></div><label class="search-box"><Search :size="17" /><input v-model="search" type="search" placeholder="Cari layanan..."><button v-if="search" aria-label="Hapus pencarian" @click="search = ''"><X :size="15" /></button></label></div>
    <p class="result-count">{{ filtered.length }} layanan ditemukan</p>
    <div v-if="filtered.length" class="service-grid catalog-grid"><RouterLink v-for="item in filtered" :key="item.id" :to="`/layanan/${item.slug}`" class="service-card"><div class="service-image"><img :src="item.image_url" :alt="item.title" loading="lazy"><span class="service-arrow"><ArrowRight :size="18" /></span></div><span class="eyebrow">{{ getCategoryName(item.category_id) }}</span><h3>{{ item.title }}</h3><p>{{ item.summary }}</p></RouterLink></div>
    <div v-else class="empty-state"><span>Belum ada layanan yang sesuai.</span><button class="text-link" @click="selected = 'Semua'; search = ''">Atur ulang filter</button></div>
  </div></section>
</template>
