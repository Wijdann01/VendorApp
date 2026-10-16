<script setup>
import { ArrowRight, Heart, Sparkles, Users } from '@lucide/vue'
import { RouterLink } from 'vue-router'
import { useSiteStore } from '../stores/site'
import { localImages } from '../data/demo'

const site = useSiteStore()
const about = site.sections.find((section) => section.section_key === 'about')
</script>

<template>
  <section class="page-hero"><div class="container"><span class="eyebrow">KENALI ABADI NAN JAYA</span><h1>Kami merayakan cerita<br>di balik setiap pertemuan.</h1><p>Sebuah tim kecil dengan hati besar, hadir untuk menjadikan momen Anda terasa utuh.</p><div class="breadcrumb"><RouterLink to="/">Beranda</RouterLink><span>/</span><span>Tentang kami</span></div></div></section>
  <section class="section section-paper about-story"><div class="container about-layout"><div class="about-image"><img :src="about?.image_url || localImages.about" alt="Tim merangkai dekorasi perayaan" loading="lazy"><span>EST. 2014 · INDONESIA</span></div><article><span class="eyebrow">CERITA KAMI</span><h2>{{ about?.title || 'Acara selesai.' }}<br><em>{{ about?.subtitle || 'Cerita tetap tinggal.' }}</em></h2><p>{{ about?.body || 'Abadi nan Jaya berawal dari satu keyakinan sederhana: perayaan terbaik bukan soal seberapa megah, tetapi seberapa dekat ia terasa.' }}</p><p>Sejak 2014, kami hadir sebagai partner bagi keluarga yang merayakan cinta, sekolah yang melepas generasi, dan tim yang ingin berbagi pencapaian. Kami mendengarkan dulu, merangkai bersama, lalu menjaga setiap detail hingga hari itu tiba.</p><RouterLink class="text-link" to="/kontak">Mari kenalan <ArrowRight :size="15" /></RouterLink></article></div></section>
  <section class="section section-cream"><div class="container"><div class="section-heading centered-heading"><span class="eyebrow">YANG KAMI PERCAYAI</span><h2>Cara kami membuat cerita berarti.</h2></div><div class="values-grid"><article><Heart :size="22" /><h3>Personal, selalu</h3><p>Setiap orang punya cara berbeda dalam merayakan. Kami mulai dengan mendengarkan cerita Anda.</p></article><article><Sparkles :size="22" /><h3>Detail yang terasa</h3><p>Hal kecil sering jadi yang paling diingat. Kami merawat detail dari awal hingga akhir acara.</p></article><article><Users :size="22" /><h3>Tenang bersama</h3><p>Partner yang baik membuat Anda hadir sepenuhnya, tanpa harus memikirkan semua urusan teknis.</p></article></div></div></section>
  <section class="closing-cta"><div class="container closing-inner"><span class="eyebrow eyebrow-light">CERITA ANDA ADALAH BERIKUTNYA</span><h2>Mari rangkai sesuatu<br>yang berarti.</h2><RouterLink class="button button-light" to="/kontak">Mulai percakapan <ArrowRight :size="16" /></RouterLink></div></section>
</template>
