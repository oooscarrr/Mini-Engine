import { ref } from "vue"
import axios from "axios"

const searchData = ref([])
const time = ref(0)

export const useSearchData = () => {
  const getSearchData = (term) => {
    return new Promise((resolve, reject) => {
      const start = Date.now()
      axios.get(`http://localhost:5001/api/search?term=${term}`)
        .then(response => {
          const end = Date.now()
          time.value = end - start
          const data = response.data.data.documents
          searchData.value = data.map((item, index) => ({
            id: index + 1,
            folder: item.folder,
            name: item.name,
            count: item.count 
          }))
          resolve(response.data)
        })
        .catch(error => {
          reject(error)
        })
    })
  }

  return { getSearchData, searchData, time }
}