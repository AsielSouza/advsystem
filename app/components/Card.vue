<template>
  <div :class="cardClasses">
    <div v-if="icon" :class="iconContainerClasses">
      <span v-if="iconEmoji" class="text-white text-2xl">{{ iconEmoji }}</span>
      <slot v-else name="icon" />
    </div>
    <h3 v-if="title" :class="titleClasses">{{ title }}</h3>
    <p v-if="description" :class="descriptionClasses">{{ description }}</p>
    <slot />
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    default: ''
  },
  icon: {
    type: String,
    default: ''
  },
  iconEmoji: {
    type: String,
    default: ''
  },
  iconColor: {
    type: String,
    default: 'blue',
    validator: (value) => ['blue', 'green', 'purple', 'red', 'yellow', 'gray'].includes(value)
  },
  hover: {
    type: Boolean,
    default: true
  },
  shadow: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg', 'xl', '2xl', 'none'].includes(value)
  }
})

const iconColorClasses = {
  blue: 'bg-blue-500',
  green: 'bg-green-500',
  purple: 'bg-purple-500',
  red: 'bg-red-500',
  yellow: 'bg-yellow-500',
  gray: 'bg-gray-500'
}

const shadowClasses = {
  sm: 'shadow-sm',
  md: 'shadow-md',
  lg: 'shadow-lg',
  xl: 'shadow-xl',
  '2xl': 'shadow-2xl',
  none: ''
}

const cardClasses = computed(() => [
  'bg-white',
  'rounded-xl',
  'p-6',
  shadowClasses[props.shadow],
  props.hover ? 'hover:shadow-xl transition-shadow' : '',
  'border',
  'border-gray-200'
])

const iconContainerClasses = computed(() => [
  'w-12',
  'h-12',
  iconColorClasses[props.iconColor],
  'rounded-full',
  'flex',
  'items-center',
  'justify-center',
  'mb-4'
])

const titleClasses = computed(() => [
  'text-xl',
  'font-semibold',
  'text-gray-800',
  'mb-2'
])

const descriptionClasses = computed(() => [
  'text-gray-600'
])
</script>

