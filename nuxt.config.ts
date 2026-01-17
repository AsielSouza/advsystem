// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxtjs/tailwindcss', '@nuxtjs/supabase'],
  supabase: {
    redirect: true,
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      exclude: [
        '/login',
        '/register',
        '/confirm'
      ]
    }
  },
  // Configurações para reduzir avisos de desenvolvimento
  experimental: {
    // Suprime avisos experimentais do Vue
    payloadExtraction: false
  },
  // Configurações de build
  build: {
    // Reduz avisos de preload desnecessários
    transpile: []
  },
  // Configurações de runtime
  runtimeConfig: {
    // Configurações públicas
    public: {}
  },
  // Suprime avisos de recursos não utilizados
  nitro: {
    prerender: {
      crawlLinks: false
    }
  }
})