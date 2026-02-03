<template>
  <div class="relative" ref="dropdownRef">
    <!-- Botão do ícone de engrenagem -->
    <button
      @click="toggleConfig"
      class="p-2 text-gray-600 hover:text-primary-600 hover:bg-gray-100 rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2"
      aria-label="Configurações"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        stroke-width="2"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
        />
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
        />
      </svg>
    </button>

    <!-- Dropdown de Configuração -->
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 scale-95 translate-y-1"
      enter-to-class="opacity-100 scale-100 translate-y-0"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 scale-100 translate-y-0"
      leave-to-class="opacity-0 scale-95 translate-y-1"
    >
      <div
        v-if="isOpen"
        class="absolute right-0 mt-2 w-64 bg-white rounded-xl shadow-2xl border border-gray-100 py-2 z-50 overflow-hidden"
      >
        <!-- Itens do Menu -->
        <div class="py-2">
          <ConfigurationMenuItem
            label="Gestão de Sócios"
            @click="goToSocios"
          >
            <template #icon>
              <svg
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
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
            </template>
          </ConfigurationMenuItem>
          <ConfigurationMenuItem
            label="Alterar senha"
            @click="abrirModalAlterarSenha"
          >
            <template #icon>
              <svg
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
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            </template>
          </ConfigurationMenuItem>
        </div>
      </div>
    </Transition>

    <!-- Modal Alterar senha -->
    <Modal
      v-model="showModalAlterarSenha"
      title="Alterar senha"
      size="md"
    >
      <form @submit.prevent="confirmarAlterarSenha" class="space-y-4">
        <InputPassword
          v-model="formSenha.senhaAtual"
          label="Senha atual"
          placeholder="Digite sua senha atual"
          :error="erroSenhaAtual"
          required
          id="config-senha-atual"
        />
        <InputPassword
          v-model="formSenha.novaSenha"
          label="Nova senha"
          placeholder="Digite a nova senha"
          :error="erroNovaSenha"
          required
          id="config-nova-senha"
        />
        <InputPassword
          v-model="formSenha.confirmarNovaSenha"
          label="Confirmar nova senha"
          placeholder="Confirme a nova senha"
          :error="erroConfirmarSenha"
          required
          id="config-confirmar-senha"
        />
        <p
          v-if="erroGeral"
          class="text-sm text-danger-600 font-medium"
        >
          {{ erroGeral }}
        </p>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <Button
            type="button"
            variant="outline"
            @click="fecharModalAlterarSenha"
          >
            Cancelar
          </Button>
          <Button
            type="button"
            variant="primary"
            :disabled="isAlterandoSenha"
            @click="confirmarAlterarSenha"
          >
            {{ isAlterandoSenha ? 'Alterando...' : 'Confirmar alteração' }}
          </Button>
        </div>
      </template>
    </Modal>

    <!-- Toast -->
    <Toast
      v-if="toast.showToast.value"
      :message="toast.toastMessage.value"
      :type="toast.toastType.value"
      :duration="toast.toastDuration.value"
      @close="toast.close"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import ConfigurationMenuItem from './ConfigurationMenuItem.vue'
import Modal from './Modal.vue'
import InputPassword from './InputPassword.vue'
import Button from './Button.vue'
import Toast from './Toast.vue'

const router = useRouter()
const { changePassword } = useAuth()
const toast = useToast()

const isOpen = ref(false)
const dropdownRef = ref(null)
const showModalAlterarSenha = ref(false)
const isAlterandoSenha = ref(false)

const formSenha = reactive({
  senhaAtual: '',
  novaSenha: '',
  confirmarNovaSenha: ''
})

const erroSenhaAtual = ref('')
const erroNovaSenha = ref('')
const erroConfirmarSenha = ref('')
const erroGeral = ref('')

const toggleConfig = () => {
  isOpen.value = !isOpen.value
}

const closeConfig = () => {
  isOpen.value = false
}

const goToSocios = () => {
  closeConfig()
  router.push('/socios')
}

const abrirModalAlterarSenha = () => {
  closeConfig()
  formSenha.senhaAtual = ''
  formSenha.novaSenha = ''
  formSenha.confirmarNovaSenha = ''
  erroSenhaAtual.value = ''
  erroNovaSenha.value = ''
  erroConfirmarSenha.value = ''
  erroGeral.value = ''
  showModalAlterarSenha.value = true
}

const fecharModalAlterarSenha = () => {
  showModalAlterarSenha.value = false
}

const confirmarAlterarSenha = async () => {
  erroSenhaAtual.value = ''
  erroNovaSenha.value = ''
  erroConfirmarSenha.value = ''
  erroGeral.value = ''

  const { senhaAtual, novaSenha, confirmarNovaSenha } = formSenha

  if (!senhaAtual?.trim()) {
    erroSenhaAtual.value = 'Informe a senha atual.'
    return
  }
  if (!novaSenha?.trim()) {
    erroNovaSenha.value = 'Informe a nova senha.'
    return
  }
  if (novaSenha.trim().length < 6) {
    erroNovaSenha.value = 'A nova senha deve ter no mínimo 6 caracteres.'
    return
  }
  if (novaSenha !== confirmarNovaSenha) {
    erroConfirmarSenha.value = 'A confirmação da senha não confere.'
    return
  }

  isAlterandoSenha.value = true
  const result = await changePassword(senhaAtual, novaSenha)
  isAlterandoSenha.value = false

  if (result.success) {
    fecharModalAlterarSenha()
    toast.success('Senha alterada com sucesso.', 3000)
  } else {
    erroGeral.value = result.error || 'Erro ao alterar senha.'
  }
}

// Fechar dropdown ao clicar fora
const handleClickOutside = (event) => {
  if (dropdownRef.value && !dropdownRef.value.contains(event.target)) {
    closeConfig()
  }
}

// Fechar ao pressionar ESC
const handleEscape = (event) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeConfig()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleEscape)
})
</script>

