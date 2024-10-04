<script setup>
import { useRouter } from 'vue-router'
import { useSearchData } from '@/use/useSearchData';

const router = useRouter()
const { searchData } = useSearchData();

const search = () => {
  const term = document.getElementById('term').value
  if (term) {
    // to-do
    searchData(term).then(() => {
      router.push('/searchresults')
    }).catch((error) => {
      console.error(error)
    })
  }
}
</script>

<template>
  <main>
    <h1>Enter Your Search Term</h1>
    <input type="text" id="term" placeholder="Type your search here..." autocomplete="off" />
    <button type="button" @click="search">Search</button>
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

input {
  width: 400px;
  padding: 5px;
}

button {
  height: 60px;
  width: 200px;
  padding: 20px 40px;
  background-color: rgb(197, 196, 196);
  border-radius: 5px;
  cursor: pointer;
}

button:hover {
  background-color: rgb(177, 176, 176);
}
</style>