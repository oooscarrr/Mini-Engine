<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useTopNData } from '@/use/useTopNData'

const props = defineProps(['n'])

const { getTopN, topNData, nValue } = useTopNData()

onMounted(() => {
  getTopN(props.n).catch((error) => {
    console.error(error)
  })
})
</script>

<template>
  <main>
    <RouterLink class="router-link" to="/topn">Go Back To Search</RouterLink>
    <div class="description">Top-{{ nValue }} Frequent Terms</div>
    <table>
        <thead>
            <tr>
              <th>Term</th>
              <th>Total Frequencies</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in topNData" :key="item.term">
              <td>{{ item.term }}</td>
              <td>{{ item.total_frequency }}</td>
            </tr>
        </tbody>
    </table>
  </main>
</template>

<style scoped>
main {
  margin: auto;
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  height: 100%;
  width: 80%;
}

.router-link {
  align-self: flex-end;
}

.description {
  font-size: 1.5em;
}

table {
  width: 50%;
  align-self: center;
}

table, th, td {
  border: 1px solid grey;
  border-collapse: collapse;
  padding: 10px;
  text-align: center;
}

th {
  background-color: #f2f2f2;
}
</style>