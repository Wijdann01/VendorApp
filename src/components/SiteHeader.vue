<script setup>
import { ref } from 'vue'
import { Menu, X, ArrowUpRight } from '@lucide/vue'
import { RouterLink, useRoute } from 'vue-router'
import { useSiteStore } from '../stores/site'

const site = useSiteStore()
const route = useRoute()
const open = ref(false)
const links = [
  { label: 'Beranda', to: '/' },
  { label: 'Layanan', to: '/layanan' },
  { label: 'Booking acara', to: '/booking' },
  { label: 'Portofolio', to: '/portofolio' },
  { label: 'Daftar harga', to: '/harga' },
  { label: 'Tentang kami', to: '/tentang-kami' },
]
</script>

<template>
  <header class="site-header">
    <div class="header-inner">
      <RouterLink to="/" class="brand" aria-label="Abadi nan Jaya, beranda" @click="open = false">
        <img v-if="site.settings.logo_url" class="brand-logo" :src="site.settings.logo_url" :alt="site.settings.brand_name || 'Abadi nan Jaya'">
        <img v-else class="brand-logo" src="/AnJ.svg" alt="">
        <span class="brand-name">{{ site.settings.brand_name || 'Abadi nan Jaya' }}<small>EVENTS · STORIES · CELEBRATIONS</small></span>
      </RouterLink>
      <button class="mobile-menu" type="button" :aria-label="open ? 'Tutup menu' : 'Buka menu'" @click="open = !open">
        <X v-if="open" :size="20" /><Menu v-else :size="20" />
      </button>
      <nav class="desktop-nav" aria-label="Navigasi utama">
        <RouterLink v-for="link in links" :key="link.to" :to="link.to" :class="{ active: route.path === link.to }">{{ link.label }}</RouterLink>
        <RouterLink class="button button-dark nav-cta" to="/kontak">Konsultasi <ArrowUpRight :size="15" /></RouterLink>
      </nav>
    </div>
    <nav v-if="open" class="mobile-nav" aria-label="Navigasi mobile">
      <RouterLink v-for="link in links" :key="link.to" :to="link.to" @click="open = false">{{ link.label }}</RouterLink>
      <RouterLink class="button button-dark" to="/kontak" @click="open = false">Konsultasi <ArrowUpRight :size="15" /></RouterLink>
    </nav>
  </header>
</template>
