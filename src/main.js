import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import './event-theme.css'
import App from './App.vue'
import router from './router'

const motionTargets = [
  '.page-hero',
  '.detail-hero',
  '.story-band',
  '.closing-cta',
  '.section-heading',
  '.service-card',
  '.package-card',
  '.work-card',
  '.portfolio-item',
  '.testimonial-card',
  '.client-logo-card',
  '.faq-item',
  '.faq-intro',
  '.story-copy',
  '.detail-content',
  '.detail-layout > *',
  '.about-layout > *',
  '.values-grid > *',
  '.price-category',
  '.price-note',
  '.booking-layout > *',
  '.contact-form',
  '.contact-aside',
  '.custom-home-section',
  '.closing-inner > *',
  '.admin-page-heading',
  '.admin-stats',
  '.stat-card',
  '.admin-overview-grid',
  '.admin-panel',
  '.booking-list-panel',
  '.role-management',
  '.booking-admin-card',
  '.summary-menu-card',
].join(',')

const motion3dTargets = [
  '.service-card',
  '.package-card',
  '.work-card',
  '.portfolio-item',
  '.testimonial-card',
  '.client-logo-card',
  '.stat-card',
  '.booking-admin-card',
  '.summary-menu-card',
].join(',')

const motionReveal = {
  mounted(root) {
    if (!('IntersectionObserver' in window)) return

    root.__motionPointerHandlers = new Map()
    const setTiltFromPoint = (target, clientX, clientY, strength = 1) => {
      const bounds = target.getBoundingClientRect()
      const x = (clientX - bounds.left) / bounds.width
      const y = (clientY - bounds.top) / bounds.height
      target.style.setProperty('--tilt-x', `${(0.5 - y) * 30 * strength}deg`)
      target.style.setProperty('--tilt-y', `${(x - 0.5) * 38 * strength}deg`)
    }
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return
        entry.target.classList.add('is-in-view')
        observer.unobserve(entry.target)
      })
    }, { threshold: 0.01, rootMargin: '0px 0px -48px 0px' })

    const observeTargets = (node) => {
      if (!(node instanceof Element)) return
      const targets = []
      if (node.matches(motionTargets)) targets.push(node)
      targets.push(...node.querySelectorAll(motionTargets))

      targets.forEach((target) => {
        if (target.classList.contains('scroll-reveal')) return
        target.classList.add('scroll-reveal')
        if (target.matches(motion3dTargets)) {
          target.classList.add('motion-3d')
          let touchResetTimer
          const handlePointerMove = (event) => {
            if (event.pointerType !== 'mouse' || !window.matchMedia('(hover: hover) and (pointer: fine)').matches) return
            setTiltFromPoint(target, event.clientX, event.clientY)
          }
          const resetPointer = () => {
            window.clearTimeout(touchResetTimer)
            target.style.setProperty('--tilt-x', '0deg')
            target.style.setProperty('--tilt-y', '0deg')
          }
          const handlePointerDown = (event) => {
            if (event.pointerType !== 'touch' || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
            window.clearTimeout(touchResetTimer)
            setTiltFromPoint(target, event.clientX, event.clientY, 0.7)
            target.classList.add('is-touch-tilted')
          }
          const handlePointerUp = (event) => {
            if (event.pointerType !== 'touch') return
            touchResetTimer = window.setTimeout(() => {
              resetPointer()
              target.classList.remove('is-touch-tilted')
            }, 650)
          }
          target.addEventListener('pointermove', handlePointerMove)
          target.addEventListener('pointerleave', resetPointer)
          target.addEventListener('pointerdown', handlePointerDown)
          target.addEventListener('pointerup', handlePointerUp)
          target.addEventListener('pointercancel', handlePointerUp)
          root.__motionPointerHandlers.set(target, [handlePointerMove, resetPointer, handlePointerDown, handlePointerUp])
        }
        revealObserver.observe(target)
      })
    }

    const cleanupTargets = (node) => {
      if (!(node instanceof Element)) return
      const targets = []
      if (root.__motionPointerHandlers.has(node)) targets.push(node)
      targets.push(...node.querySelectorAll(motion3dTargets))
      targets.forEach((target) => {
        const handlers = root.__motionPointerHandlers.get(target)
        if (!handlers) return
        handlers[1]()
        target.removeEventListener('pointermove', handlers[0])
        target.removeEventListener('pointerleave', handlers[1])
        target.removeEventListener('pointerdown', handlers[2])
        target.removeEventListener('pointerup', handlers[3])
        target.removeEventListener('pointercancel', handlers[3])
        root.__motionPointerHandlers.delete(target)
      })
    }

    observeTargets(root)
    const mutationObserver = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach(observeTargets)
        mutation.removedNodes.forEach(cleanupTargets)
      })
    })
    mutationObserver.observe(root, { childList: true, subtree: true })

    root.__motionObservers = [revealObserver, mutationObserver]
  },
  unmounted(root) {
    root.__motionObservers?.forEach((observer) => observer.disconnect())
    root.__motionPointerHandlers?.forEach(([target, handlers]) => {
      handlers[1]()
      target.removeEventListener('pointermove', handlers[0])
      target.removeEventListener('pointerleave', handlers[1])
      target.removeEventListener('pointerdown', handlers[2])
      target.removeEventListener('pointerup', handlers[3])
      target.removeEventListener('pointercancel', handlers[3])
    })
  },
}

createApp(App)
  .use(createPinia())
  .use(router)
  .directive('motion', motionReveal)
  .mount('#app')
