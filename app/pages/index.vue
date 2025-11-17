<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-8">
    <div class="max-w-7xl mx-auto space-y-8">
      <!-- Header -->
      <header class="bg-white rounded-lg shadow-md p-6">
        <h1 class="text-4xl font-bold text-gray-800 mb-2">
          Teste de Componentes Tailwind CSS
        </h1>
        <p class="text-gray-600">
          Esta página contém diversos elementos do Tailwind para testes
        </p>
      </header>

      <!-- Cards Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-xl transition-shadow">
          <div class="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center mb-4">
            <span class="text-white text-2xl">🎨</span>
          </div>
          <h3 class="text-xl font-semibold text-gray-800 mb-2">Card 1</h3>
          <p class="text-gray-600">
            Este é um card de exemplo com hover effect e ícone circular.
          </p>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-xl transition-shadow">
          <div class="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center mb-4">
            <span class="text-white text-2xl">✨</span>
          </div>
          <h3 class="text-xl font-semibold text-gray-800 mb-2">Card 2</h3>
          <p class="text-gray-600">
            Card com gradiente e animações suaves.
          </p>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-xl transition-shadow">
          <div class="w-12 h-12 bg-purple-500 rounded-full flex items-center justify-center mb-4">
            <span class="text-white text-2xl">🚀</span>
          </div>
          <h3 class="text-xl font-semibold text-gray-800 mb-2">Card 3</h3>
          <p class="text-gray-600">
            Design responsivo e moderno.
          </p>
        </div>
      </div>

      <!-- Buttons Section -->
      <section class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Botões</h2>
        <div class="flex flex-wrap gap-4">
          <button class="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors font-medium">
            Botão Primário
          </button>
          <button class="px-6 py-3 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors font-medium">
            Botão Sucesso
          </button>
          <button class="px-6 py-3 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors font-medium">
            Botão Perigo
          </button>
          <button class="px-6 py-3 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors font-medium">
            Botão Aviso
          </button>
          <button class="px-6 py-3 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium">
            Botão Outline
          </button>
        </div>
      </section>

      <!-- Badges/Tags -->
      <section class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Badges e Tags</h2>
        <div class="flex flex-wrap gap-3">
          <span class="px-4 py-2 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
            Tag Azul
          </span>
          <span class="px-4 py-2 bg-green-100 text-green-800 rounded-full text-sm font-medium">
            Tag Verde
          </span>
          <span class="px-4 py-2 bg-red-100 text-red-800 rounded-full text-sm font-medium">
            Tag Vermelha
          </span>
          <span class="px-4 py-2 bg-yellow-100 text-yellow-800 rounded-full text-sm font-medium">
            Tag Amarela
          </span>
          <span class="px-4 py-2 bg-purple-100 text-purple-800 rounded-full text-sm font-medium">
            Tag Roxa
          </span>
          <span class="px-4 py-2 bg-gray-100 text-gray-800 rounded-full text-sm font-medium">
            Tag Cinza
          </span>
        </div>
      </section>

      <!-- Alerts -->
      <section class="space-y-4">
        <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
          <div class="flex">
            <div class="flex-shrink-0">
              <span class="text-blue-500 text-xl">ℹ️</span>
            </div>
            <div class="ml-3">
              <p class="text-sm text-blue-700">
                Esta é uma mensagem informativa usando Tailwind CSS.
              </p>
            </div>
          </div>
        </div>

        <div class="bg-green-50 border-l-4 border-green-500 p-4 rounded">
          <div class="flex">
            <div class="flex-shrink-0">
              <span class="text-green-500 text-xl">✓</span>
            </div>
            <div class="ml-3">
              <p class="text-sm text-green-700">
                Esta é uma mensagem de sucesso.
              </p>
            </div>
          </div>
        </div>

        <div class="bg-yellow-50 border-l-4 border-yellow-500 p-4 rounded">
          <div class="flex">
            <div class="flex-shrink-0">
              <span class="text-yellow-500 text-xl">⚠️</span>
            </div>
            <div class="ml-3">
              <p class="text-sm text-yellow-700">
                Esta é uma mensagem de aviso.
              </p>
            </div>
          </div>
        </div>

        <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded">
          <div class="flex">
            <div class="flex-shrink-0">
              <span class="text-red-500 text-xl">✕</span>
            </div>
            <div class="ml-3">
              <p class="text-sm text-red-700">
                Esta é uma mensagem de erro.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Forms -->
      <section class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Formulários</h2>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Nome
            </label>
            <input
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
              placeholder="Digite seu nome"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Email
            </label>
            <input
              type="email"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
              placeholder="seu@email.com"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Mensagem
            </label>
            <textarea
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition resize-none"
              rows="4"
              placeholder="Digite sua mensagem..."
            ></textarea>
          </div>
          <div>
            <label class="flex items-center space-x-2">
              <input
                type="checkbox"
                class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              />
              <span class="text-sm text-gray-700">Aceito os termos e condições</span>
            </label>
          </div>
        </div>
      </section>

      <!-- Progress Bars -->
      <section class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Barras de Progresso</h2>
        <div class="space-y-4">
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Progresso 1</span>
              <span class="text-sm text-gray-600">75%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div class="bg-blue-500 h-3 rounded-full" style="width: 75%"></div>
            </div>
          </div>
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Progresso 2</span>
              <span class="text-sm text-gray-600">50%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div class="bg-green-500 h-3 rounded-full" style="width: 50%"></div>
            </div>
          </div>
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Progresso 3</span>
              <span class="text-sm text-gray-600">90%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div class="bg-purple-500 h-3 rounded-full" style="width: 90%"></div>
            </div>
          </div>
        </div>
      </section>

      <!-- Tables -->
      <section class="bg-white rounded-lg shadow-md p-6 overflow-x-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Tabelas</h2>
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Nome
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Email
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ações
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                João Silva
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                joao@example.com
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                  Ativo
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <button class="text-blue-600 hover:text-blue-900">Editar</button>
              </td>
            </tr>
            <tr class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                Maria Santos
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                maria@example.com
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                  Pendente
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <button class="text-blue-600 hover:text-blue-900">Editar</button>
              </td>
            </tr>
            <tr class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                Pedro Costa
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                pedro@example.com
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                  Inativo
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <button class="text-blue-600 hover:text-blue-900">Editar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </section>

      <!-- Spacing & Layout -->
      <section class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Espaçamento e Layout</h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div class="bg-blue-100 p-4 rounded text-center">Col 1</div>
          <div class="bg-green-100 p-4 rounded text-center">Col 2</div>
          <div class="bg-yellow-100 p-4 rounded text-center">Col 3</div>
          <div class="bg-purple-100 p-4 rounded text-center">Col 4</div>
        </div>
      </section>

      <!-- Shadows & Effects -->
      <section class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Sombras e Efeitos</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
            <p class="text-gray-700">Shadow SM</p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p class="text-gray-700">Shadow MD</p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-lg border border-gray-200">
            <p class="text-gray-700">Shadow LG</p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-xl border border-gray-200">
            <p class="text-gray-700">Shadow XL</p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-2xl border border-gray-200">
            <p class="text-gray-700">Shadow 2XL</p>
          </div>
          <div class="bg-white p-6 rounded-lg shadow-inner border border-gray-200">
            <p class="text-gray-700">Shadow Inner</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
// Página de teste do Tailwind CSS
</script>

