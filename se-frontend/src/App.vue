<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <header>
    <div>My Search Engine</div>
    <nav>
      <RouterLink to="/">Load Engine</RouterLink>
      <RouterLink to="/searchterm">Search for Term</RouterLink>
      <RouterLink to="/topn">Top N</RouterLink>
    </nav>
  </header>
  <div class="layout">
    <RouterView />
  </div>
</template>

<style scoped>
header {
  background-color: #333;
  color: white;
  padding: 1rem;
  height: fit-content;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

a {
  color: white;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

nav {
  flex-basis: 30%;
  min-width: 300px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.layout {
  height: calc(100% - 50px);
}
</style>