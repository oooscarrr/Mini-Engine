import { ref } from "vue"
import axios from "axios"

const data = ref([
  { id: 1, folder: 'folder1', name: 'name1', frequency: 'frequency1' },
  { id: 2, folder: 'folder2', name: 'name2', frequency: 'frequency2' },
  { id: 3, folder: 'folder3', name: 'name3', frequency: 'frequency3' },
  { id: 4, folder: 'folder4', name: 'name4', frequency: 'frequency4' },
  { id: 5, folder: 'folder5', name: 'name5', frequency: 'frequency5' }
])
const time = ref(0)
const term = ref('')

export const useSearchData = () => {
  const searchData = (searchTerm) => {
    return new Promise((resolve, reject) => {
      const start = Date.now()
      // axios.get(`http://localhost:8000/api/search?search_term=${searchTerm}`)
      //   .then(response => {
      //     const end = Date.now()
      //     time.value = end - start
      //     term.value = searchTerm
      //     resolve(response.data)
      //   })
      //   .catch(error => {
      //     reject(error)
      //   })
      const end = Date.now()
      time.value = end - start
      term.value = searchTerm
      resolve(data)
      // to-do
    })
  }

  return { searchData, data, time, term }
}