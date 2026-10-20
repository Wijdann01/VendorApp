<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: [Number, String],
    default: null,
  },
  placeholder: {
    type: String,
    default: '0',
  },
  ariaLabel: {
    type: String,
    default: 'Nominal rupiah',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  nullable: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['update:modelValue'])
const formatter = new Intl.NumberFormat('id-ID', { maximumFractionDigits: 0 })
const displayValue = computed(() => {
  const value = Number(props.modelValue)
  return Number.isFinite(value) && value > 0 ? formatter.format(value) : ''
})

function updateValue(event) {
  const digits = event.target.value.replace(/\D/g, '')
  if (!digits) {
    emit('update:modelValue', props.nullable ? null : 0)
    return
  }
  const value = Number(digits)
  if (!Number.isSafeInteger(value)) return
  emit('update:modelValue', value)
}
</script>

<template>
  <input
    :value="displayValue"
    type="text"
    inputmode="numeric"
    autocomplete="off"
    :placeholder="placeholder"
    :aria-label="ariaLabel"
    :disabled="disabled"
    @input="updateValue"
  >
</template>
