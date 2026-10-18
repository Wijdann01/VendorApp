<script setup>
import { ArrowRight, Heart, Sparkles, Users } from '@lucide/vue'
import { RouterLink } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { localImages } from '../data/demo'

const site = useSiteStore()
const about = site.sections.find((section) => section.section_key === 'about')
</script>

<template>
  <section class="page-hero"><div class="container"><span class="eyebrow">KENALI ABADI NAN JAYA</span><h1>Acara tertata.<br>Semua bisa ikut merayakan.</h1><p>Partner sekolah untuk perpisahan, wisuda, dan yearbook—juga untuk acara komunitas, corporate, dan personal.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Tentang kami</span></div></div></section>
  <section class="section section-paper about-story"><div class="container about-layout"><div class="about-image"><img :src="about?.image_url || localImages.about" alt="Tim merencanakan dan menyiapkan sebuah acara" loading="lazy"><span>EST. 2014 · INDONESIA</span></div><article><span class="eyebrow">CERITA KAMI</span><h2>{{ about?.title || 'Rencana matang.' }}<br><em>Hari acara lebih tenang.</em></h2><p>{{ about?.body || 'Abadi nan Jaya membantu panitia mengubah banyak kebutuhan menjadi acara yang terkoordinasi—dengan fokus pada perpisahan, wisuda, dan kenangan satu angkatan.' }}</p><p>Kami bekerja bersama sekolah, komunitas, dan perusahaan mulai dari menyusun konsep dan anggaran, memilih kebutuhan produksi, hingga memastikan jalannya acara. Setiap program disesuaikan dengan tujuan, jumlah peserta, dan karakter penyelenggara.</p><RouterLink class="text-link" to="/kontak">Diskusikan acara Anda <ArrowRight :size="15" /></RouterLink></article></div></section>
  <section class="section section-cream"><div class="container"><div class="section-heading centered-heading"><span class="eyebrow">CARA KAMI BEKERJA</span><h2>Rencana jelas, panitia lebih tenang.</h2></div><div class="values-grid"><article><Heart :size="22" /><h3>Dengar kebutuhan</h3><p>Kami mulai dari tujuan acara, jumlah peserta, anggaran, dan ide dari sekolah atau panitia.</p></article><article><Sparkles :size="22" /><h3>Rinci dan terkoordinasi</h3><p>Rundown, vendor, produksi, dan kebutuhan teknis disatukan dalam rencana yang mudah diikuti.</p></article><article><Users :size="22" /><h3>Siap di hari-H</h3><p>Tim lapangan membantu acara berjalan sesuai rencana agar panitia dapat hadir bersama siswa dan tamu.</p></article></div></div></section>
  <section class="closing-cta"><div class="container closing-inner"><span class="eyebrow eyebrow-light">SEDANG MENYIAPKAN ACARA SEKOLAH?</span><h2>Mari rencanakan<br>perayaan angkatan Anda.</h2><RouterLink class="button button-light" to="/booking">Diskusikan kebutuhan acara <ArrowRight :size="16" /></RouterLink></div></section>
</template>
