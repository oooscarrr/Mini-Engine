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
          const data = response.data.data
          topNData.value = Object.entries(data).map(([term, stats]) => ({
            term: term,
            total_frequency: stats.total_frequency
          }))
          .sort((a, b) => b.total_frequency - a.total_frequency)

          console.log(response.data.data)
        })
        .catch(error => {
          reject(error)
        })
    })
  }

  return { getTopN, topNData, nValue };
}