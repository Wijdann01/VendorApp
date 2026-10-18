import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import './event-theme.css'
import App from './App.vue'
import router from './router'

createApp(App).use(createPinia()).use(router).mount('#app')
