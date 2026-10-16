<script setup>
import { ArrowUpRight, Link2, Mail, MapPin } from '@lucide/vue'
import { RouterLink } from 'vue-router'
import { useSiteStore } from '../stores/site'

const site = useSiteStore()
const year = new Date().getFullYear()
</script>

<template>
  <footer class="site-footer">
    <div class="container footer-main">
      <div class="footer-brand">
        <RouterLink to="/" class="brand brand-light">
          <img v-if="site.settings.logo_url" class="brand-logo" :src="site.settings.logo_url" :alt="site.settings.brand_name || 'Abadi nan Jaya'">
          <span v-else class="brand-mark">A<span>J</span></span>
          <span class="brand-name">{{ site.settings.brand_name || 'Abadi nan Jaya' }}<small>EVENTS · STORIES · CELEBRATIONS</small></span>
        </RouterLink>
        <p>Ruang untuk merayakan setiap cerita, bersama orang-orang yang paling berarti.</p>
        <a :href="`https://instagram.com/${(site.settings.instagram || '@abadinanjaya').replace('@', '')}`" target="_blank" rel="noreferrer" class="social-link"><Link2 :size="16" /> {{ site.settings.instagram || '@abadinanjaya' }}</a>
      </div>
      <div class="footer-col"><h3>Jelajahi</h3><RouterLink to="/layanan">Semua layanan</RouterLink><RouterLink to="/booking">Booking acara</RouterLink><RouterLink to="/portofolio">Portofolio</RouterLink><RouterLink to="/harga">Daftar harga</RouterLink><RouterLink to="/tentang-kami">Tentang kami</RouterLink></div>
      <div class="footer-col"><h3>Hubungi kami</h3><RouterLink to="/kontak"><Mail :size="15" /> Konsultasi acara</RouterLink><span><MapPin :size="15" /> Indonesia</span><a :href="`https://wa.me/${site.settings.whatsapp || '6281234567890'}`" target="_blank" rel="noreferrer">WhatsApp kami <ArrowUpRight :size="14" /></a></div>
    </div>
    <div class="container footer-bottom">    <span>© {{ year }} {{ site.settings.brand_name || 'Abadi nan Jaya' }}. Dibuat dengan sepenuh hati.</span><RouterLink to="/admin/login">Admin</RouterLink></div>
  </footer>
</template>
