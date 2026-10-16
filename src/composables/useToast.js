import { ref } from 'vue'

const toasts = ref([])
let nextId = 0

export function useToast() {
  function notify(message, type = 'success') {
    const id = ++nextId
    toasts.value.push({ id, message, type })
    window.setTimeout(() => { toasts.value = toasts.value.filter((toast) => toast.id !== id) }, 4200)
  }
  function dismiss(id) {
    toasts.value = toasts.value.filter((toast) => toast.id !== id)
  }
  return { toasts, notify, dismiss }
}
