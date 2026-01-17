<template>
  <button
    @click="handleClick"
    class="w-full text-left px-4 py-3 text-sm text-gray-700 hover:bg-primary-50 hover:text-primary-700 transition-all duration-150 flex items-center gap-3 group"
  >
    <slot name="icon">
      <svg
        v-if="icon"
        xmlns="http://www.w3.org/2000/svg"
        class="h-5 w-5 text-gray-400 group-hover:text-primary-600 transition-colors"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        stroke-width="2"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          :d="icon"
        />
      </svg>
    </slot>
    <span class="font-medium">
      <slot>{{ label }}</slot>
    </span>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="h-4 w-4 text-gray-300 group-hover:text-primary-500 ml-auto transition-colors"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      stroke-width="2"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M9 5l7 7-7 7"
      />
    </svg>
  </button>
</template>

<script setup>
const props = defineProps({
  label: {
    type: String,
    default: ''
  },
  icon: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['click'])

const handleClick = () => {
  emit('click')
}
</script>
