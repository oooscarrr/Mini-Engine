<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const selectedFiles = ref([])
let fileInput = null

const hasFiles = computed(() => selectedFiles.value.length > 0)

onMounted(() => {
  fileInput = document.getElementById('file-input')
})

const handleFileChange = (e) => {
  selectedFiles.value = Array.from(e.target.files)
}

const openFileSelector = () => {
  if (fileInput) {
    fileInput.click()
  }
}

const loadEngine = () => {
  if (selectedFiles.value.length > 0) {
    // to-do
    router.push('/engineloaded')
  }
}
</script>

<template>
  <main>
    <h1>Load My Engine</h1>
    <input type="file" multiple @change="handleFileChange" style="display: none;" id="file-input" />
    <button type="button" @click="openFileSelector">Choose Files</button>
    <div v-if="hasFiles">
      <ul>
        <li v-for="file in selectedFiles" :key="file.name">{{ file.name }}</li>
      </ul>
    </div>
    <button type="button" @click="loadEngine">{{ hasFiles ? 'Load Engine' : 'Construct Inverted Indicies' }}</button>
  </main>
</template>

<style scoped>
main {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
  height: 80%;
}

button {
  height: 60px;
  width: fit-content;
  padding: 20px 40px;
  background-color: rgb(197, 196, 196);
  border-radius: 5px;
  cursor: pointer;
}

button:hover {
  background-color: rgb(177, 176, 176);
}

ul {
  list-style-type: none;
  padding: 0;
}
</style>