<script setup>
import { computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import SiteHeader from './components/SiteHeader.vue'
import SiteFooter from './components/SiteFooter.vue'
import ToastHost from './components/ToastHost.vue'
import { useSiteStore } from './stores/site'

const route = useRoute()
const site = useSiteStore()
const isAdmin = computed(() => route.path.startsWith('/admin'))
watch(() => site.settings, (settings) => {
  document.documentElement.style.setProperty('--gold', settings.theme_primary || '#a58a6a')
  document.documentElement.style.setProperty('--ink', settings.theme_ink || '#27241f')
  const description = document.querySelector('meta[name="description"]')
  if (description && settings.seo_description) description.setAttribute('content', settings.seo_description)
}, { deep: true, immediate: true })
watch(() => [route.meta.title, site.settings.brand_name], ([title, brand]) => {
  document.title = `${title || 'Beranda'} — ${brand || 'Abadi nan Jaya'}`
})
onMounted(() => site.loadPublicContent().catch((error) => console.error(error)))
</script>

<template>
  <div class="min-h-screen">
    <SiteHeader v-if="!isAdmin" />
    <main>
      <div v-if="site.error && !isAdmin" class="site-error" role="alert">
        <span>Konten situs belum dapat dimuat: {{ site.error }}</span>
        <button type="button" @click="site.loadPublicContent(true).catch((error) => console.error(error))">Coba lagi</button>
      </div>
      <RouterView />
    </main>
    <SiteFooter v-if="!isAdmin" />
    <ToastHost />
  </div>
</template>
