<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useSearchData } from '@/use/useSearchData';

const { data, term, time } = useSearchData();
console.log(term.value);
</script>

<template>
  <main>
    <RouterLink class="router-link" to="/searchterm">Go Back To Search</RouterLink>
    <div class="description">You searched for the term: {{ term }}</div>
    <div class="description">Your search was executed in {{ time }} ms</div>
    <table>
        <thead>
            <tr>
              <th>Doc ID</th>
              <th>Doc Folder</th>
              <th>Doc Name</th>
              <th>Frequencies</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="item in data" :key="item.id">
              <td>{{ item.id }}</td>
              <td>{{ item.folder }}</td>
              <td>{{ item.name }}</td>
              <td>{{ item.frequency }}</td>
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