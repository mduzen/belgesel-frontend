<template>
  <div class="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-4xl mx-auto">
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h1 class="text-3xl font-bold text-gray-900 mb-8 text-center">PDF Yükleme ve İçerik Görüntüleme</h1>
        
        <!-- File Upload Section -->
        <div class="mb-8">
          <div class="flex items-center justify-center w-full">
            <label class="flex flex-col w-full h-32 border-4 border-dashed hover:bg-gray-100 hover:border-gray-300">
              <div class="flex flex-col items-center justify-center pt-5 pb-6">
                <svg class="w-8 h-8 mb-2 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                </svg>
                <p class="mb-2 text-sm text-gray-500">
                  <span class="font-semibold">PDF dosyası yüklemek için tıklayın</span> veya sürükleyin
                </p>
                <p class="text-xs text-gray-500">PDF (MAX. 10MB)</p>
              </div>
              <input type="file" class="opacity-0" accept=".pdf" @change="handleFileUpload" />
            </label>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="text-center py-4">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
        </div>

        <!-- History Section -->
        <div v-if="history.length > 0" class="mb-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Geçmiş İşlemler</h2>
          <div class="space-y-2">
            <div v-for="item in history" :key="item.id" class="bg-white border rounded-lg overflow-hidden">
              <button 
                @click="toggleHistoryItem(item.id)"
                class="w-full px-4 py-3 flex items-center justify-between hover:bg-gray-50 focus:outline-none"
              >
                <div class="flex items-center">
                  <svg class="w-5 h-5 text-gray-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  <span class="text-sm font-medium text-gray-900">
                    {{ new Date(item.timestamp).toLocaleString() }}
                  </span>
                </div>
                <svg 
                  class="w-5 h-5 text-gray-500 transform transition-transform duration-200" 
                  :class="{ 'rotate-180': expandedHistoryItems[item.id] }"
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              
              <!-- History Item Content -->
              <div v-if="expandedHistoryItems[item.id]" class="px-4 pb-4">
                <div class="prose max-w-none">
                  <div v-for="(contentItem, index) in item.data" :key="index" class="mb-4">
                    <div class="bg-gray-50 p-4 rounded-lg">
                      <div class="markdown-content" v-html="renderMarkdown(contentItem.content)"></div>
                      
                      <!-- Chunk Details -->
                      <div class="mt-4">
                        <h4 class="font-medium text-gray-700">Chunk Detayları:</h4>
                        <div class="space-y-2 mt-2">
                          <div v-if="contentItem.chunk">
                            <h5 class="font-medium text-gray-600">Sayfa İçeriği:</h5>
                            <pre class="mt-1 p-2 bg-white rounded text-sm overflow-x-auto">{{ contentItem.chunk.pageContent }}</pre>
                          </div>
                          <div v-if="contentItem.chunk?.metadata">
                            <h5 class="font-medium text-gray-600">Metadata:</h5>
                            <pre class="mt-1 p-2 bg-white rounded text-sm overflow-x-auto">{{ JSON.stringify(contentItem.chunk.metadata, null, 2) }}</pre>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Current Content Display Section -->
        <div v-if="content" class="mt-8">
          <div class="prose max-w-none">
            <div v-for="(item, index) in content" :key="index" class="mb-8">
              <div class="bg-gray-50 p-6 rounded-lg">
                <div class="markdown-content" v-html="renderMarkdown(item.content)"></div>
                
                <!-- Details Button -->
                <button 
                  @click="toggleDetails(index)"
                  class="mt-4 flex items-center justify-center w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  <span>{{ expandedItems[index] ? 'Detayları Gizle' : 'Detayları Göster' }}</span>
                  <svg 
                    class="ml-2 h-5 w-5 transform transition-transform duration-200" 
                    :class="{ 'rotate-180': expandedItems[index] }"
                    xmlns="http://www.w3.org/2000/svg" 
                    viewBox="0 0 20 20" 
                    fill="currentColor"
                  >
                    <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                  </svg>
                </button>

                <!-- Chunk Details -->
                <div 
                  v-if="expandedItems[index]" 
                  class="mt-4 p-4 bg-white rounded-lg border border-gray-200"
                >
                  <h3 class="text-lg font-semibold mb-2">Chunk Detayları:</h3>
                  <div class="space-y-2">
                    <div v-if="item.chunk">
                      <h4 class="font-medium text-gray-700">Sayfa İçeriği:</h4>
                      <pre class="mt-1 p-2 bg-gray-50 rounded text-sm overflow-x-auto">{{ item.chunk }}</pre>
                    </div>
                    <div v-if="item.chunk?.metadata">
                      <h4 class="font-medium text-gray-700">Metadata:</h4>
                      <pre class="mt-1 p-2 bg-gray-50 rounded text-sm overflow-x-auto">{{ JSON.stringify(item.chunk.metadata, null, 2) }}</pre>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { marked } from 'marked'

const loading = ref(false)
const content = ref(null)
const expandedItems = ref({})
const history = ref([])
const expandedHistoryItems = ref({})

// Load history from localStorage on component mount
onMounted(() => {
  const savedHistory = localStorage.getItem('pdfHistory')
  if (savedHistory) {
    history.value = JSON.parse(savedHistory)
  }
})

const toggleDetails = (index) => {
  expandedItems.value[index] = !expandedItems.value[index]
}

const toggleHistoryItem = (id) => {
  expandedHistoryItems.value[id] = !expandedHistoryItems.value[id]
}

const saveToHistory = (data) => {
  const newItem = {
    id: Date.now().toString(),
    timestamp: Date.now(),
    data: data
  }
  
  history.value.unshift(newItem)
  // Keep only last 10 items
  if (history.value.length > 10) {
    history.value.pop()
  }
  
  // Save to localStorage
  localStorage.setItem('pdfHistory', JSON.stringify(history.value))
}

const handleFileUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  if (file.type !== 'application/pdf') {
    alert('Lütfen sadece PDF dosyası yükleyin.')
    return
  }

  if (file.size > 10 * 1024 * 1024) {
    alert('Dosya boyutu 10MB\'dan küçük olmalıdır.')
    return
  }

  const formData = new FormData()
  formData.append('file', file)

  loading.value = true
  try {
    //const response = await $fetch('http://localhost:3080/api/uploadPdf', {
    const response = await $fetch('https://belgesel-backend-734033514286.us-central1.run.app/api/uploadPdf', {
      method: 'POST',
      body: formData,
    })
    content.value = response.data
    // Save to history
    saveToHistory(response.data)
    // Reset expanded items when new content is loaded
    expandedItems.value = {}
  } catch (error) {
    console.error('Upload error:', error)
    alert('Dosya yüklenirken bir hata oluştu.')
  } finally {
    loading.value = false
  }
}

const renderMarkdown = (markdown) => {
  return marked(markdown)
}
</script>

<style>
.markdown-content {
  @apply text-gray-800;
}

.markdown-content h1 {
  @apply text-2xl font-bold mb-4;
}

.markdown-content h2 {
  @apply text-xl font-bold mb-3;
}

.markdown-content p {
  @apply mb-4;
}

.markdown-content ul {
  @apply list-disc list-inside mb-4;
}

.markdown-content ol {
  @apply list-decimal list-inside mb-4;
}

.markdown-content li {
  @apply mb-2;
}

pre {
  @apply whitespace-pre-wrap;
}
</style> 