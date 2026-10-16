<script setup>
import { Check, CircleAlert, X } from '@lucide/vue'
import { useToast } from '../composables/useToast'
const { toasts, dismiss } = useToast()
</script>

<template>
  <div class="toast-stack" aria-live="polite">
    <div v-for="toast in toasts" :key="toast.id" class="toast" :class="`toast-${toast.type}`">
      <Check v-if="toast.type === 'success'" :size="17" /><CircleAlert v-else :size="17" />
      <span>{{ toast.message }}</span>
      <button type="button" aria-label="Tutup notifikasi" @click="dismiss(toast.id)"><X :size="15" /></button>
    </div>
  </div>
</template>
