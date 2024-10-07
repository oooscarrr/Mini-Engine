import { ref } from "vue"
import axios from "axios"

const data = ref([])
const time = ref(0)

export const useSearchData = () => {
  const searchData = (term) => {
    return new Promise((resolve, reject) => {
      const start = Date.now()
      axios.get(`http://localhost:5001/api/search?term=${term}`)
        .then(response => {
          const end = Date.now()
          time.value = end - start
          data.value = response.data.data
          console.log("data received: " + data.value)
          resolve(response.data)
        })
        .catch(error => {
          reject(error)
        })
      // to-do
    })
  }

  return { searchData, data, time }
}