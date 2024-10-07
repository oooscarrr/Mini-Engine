import { ref } from "vue"
import axios from "axios"

const topNData = ref([])
const nValue = ref(0)

export const useTopNData = () => {
  const getTopN = (n) => {
    return new Promise((resolve, reject) => {
      axios.get(`http://localhost:5001/api/topn?n=${n}`)
        .then(response => {
          nValue.value = n
          topNData.value = response.data.data
          console.log("data received: " + topNData.value)
          resolve(response.data)
        })
        .catch(error => {
          reject(error)
        })
      // to-do
    })
  }

  return { getTopN, topNData, nValue };
}