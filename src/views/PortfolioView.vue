<script setup>
import { computed, ref } from 'vue'
import { ArrowLeft, ArrowRight, X } from '@lucide/vue'
import { useSiteStore } from '../stores/site'

const site = useSiteStore()
const active = ref('Semua')
const lightbox = ref(null)
const categories = computed(() => ['Semua', ...new Set(site.portfolios.map((item) => item.category))])
const filtered = computed(() => site.portfolios.filter((item) => active.value === 'Semua' || item.category === active.value))
const move = (step) => {
  const index = filtered.value.findIndex((item) => item.id === lightbox.value?.id)
  lightbox.value = filtered.value[(index + step + filtered.value.length) % filtered.value.length]
}
</script>

<template>
  <section class="page-hero"><div class="container"><span class="eyebrow">RUANG CERITA</span><h1>Momen-momen yang<br>terus hidup di ingatan.</h1><p>Setiap perayaan punya detail kecil yang membuatnya terasa istimewa. Inilah beberapa cerita yang kami rangkai bersama.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Portofolio</span></div></div></section>
  <section class="section section-paper"><div class="container">
    <div class="filter-list portfolio-filters"><button v-for="category in categories" :key="category" class="filter-chip" :class="{ selected: active === category }" @click="active = category">{{ category }}</button></div>
    <div class="portfolio-grid"><button v-for="(work, index) in filtered" :key="work.id" class="portfolio-item" :class="`portfolio-item-${(index % 4) + 1}`" @click="lightbox = work"><video v-if="work.media?.[0]?.media_type === 'video'" :src="work.media[0].media_url" muted playsinline preload="metadata"></video><img v-else :src="work.image_url || work.media?.[0]?.media_url" :alt="work.title" loading="lazy"><span class="portfolio-caption"><small>{{ work.category }}</small><strong>{{ work.title }}</strong><span>{{ work.description }}</span></span></button></div>
    <div v-if="!filtered.length" class="empty-state">Belum ada cerita dalam kategori ini.</div>
  </div></section>
  <div v-if="lightbox" class="lightbox" role="dialog" aria-modal="true" :aria-label="lightbox.title" @click.self="lightbox = null" @keydown.esc="lightbox = null">
    <button class="lightbox-close" aria-label="Tutup" @click="lightbox = null"><X :size="22" /></button><button class="lightbox-arrow lightbox-prev" aria-label="Sebelumnya" @click="move(-1)"><ArrowLeft :size="20" /></button>
    <figure><video v-if="lightbox.media?.[0]?.media_type === 'video'" :src="lightbox.media[0].media_url" controls autoplay playsinline></video><img v-else :src="lightbox.image_url || lightbox.media?.[0]?.media_url" :alt="lightbox.title"><figcaption><small>{{ lightbox.category }}</small><strong>{{ lightbox.title }}</strong><span>{{ lightbox.description }}</span></figcaption></figure>
    <button class="lightbox-arrow lightbox-next" aria-label="Berikutnya" @click="move(1)"><ArrowRight :size="20" /></button>
  </div>
</template>
