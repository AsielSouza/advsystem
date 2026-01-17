<script setup lang="ts">
const user = useSupabaseUser()
const redirectInfo = useSupabaseCookieRedirect()

watch(user, () => {
  if (user.value) {
    const path = redirectInfo.pluck() // Pega e limpa o cookie
    return navigateTo(path || '/')
  }
}, { immediate: true })
</script>

<template>
  <div class="h-full w-full flex items-center justify-center p-4">
    <div class="text-center">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
      <p class="text-gray-600">Aguarde, confirmando autenticação...</p>
    </div>
  </div>
</template>

