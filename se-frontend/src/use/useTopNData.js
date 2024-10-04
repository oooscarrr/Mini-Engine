import { ref } from "vue";
import axios from "axios";

const data = ref([
    { term: 'term1', frequency: 'frequency1' },
    { term: 'term2', frequency: 'frequency2' },
    { term: 'term3', frequency: 'frequency3' },
    { term: 'term4', frequency: 'frequency4' },
    { term: 'term5', frequency: 'frequency5' }
]);
const nValue = ref(0);

export const useTopNData = () => {
  const getTopN = (n) => {
    return new Promise((resolve, reject) => {
      // axios.get(`http://localhost:8000/api/topn?n=${n}`)
      //   .then(response => {
      //     nValue.value = n
      //     resolve(response.data)
      //   })
      //   .catch(error => {
      //     reject(error)
      //   })
      nValue.value = n
      resolve(data)
      // to-do
    })
  }

  return { getTopN, data, nValue };
}