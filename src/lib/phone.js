export function toLocalIndonesianPhone(value) {
  const digits = String(value || '').replace(/\D/g, '')
  if (digits.startsWith('0062')) return `0${digits.slice(4)}`
  if (digits.startsWith('62')) return `0${digits.slice(2)}`
  if (digits.startsWith('8')) return `0${digits}`
  return digits
}

export function toWhatsAppPhone(value) {
  const localPhone = toLocalIndonesianPhone(value)
  return localPhone.startsWith('0') ? `62${localPhone.slice(1)}` : localPhone
}
