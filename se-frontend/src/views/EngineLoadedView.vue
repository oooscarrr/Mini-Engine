<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

</script>

<template>
  <main>
    <div class="title">
      <div>Engine was loaded</div>
      <div>&</div>
      <div>Inverted indicies were constructed successfully!</div>
    </div>
    <h1>Please Select Action</h1>

    <button type="button" @click="router.push('/searchterm')">Search for Term</button>
    <button type="button" @click="router.push('/topn')">Top N</button>
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

.title {
  text-align: center;
  font-size: 2em;
  font-weight: bold;
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