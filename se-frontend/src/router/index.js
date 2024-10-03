import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/searchterm',
      name: 'searchterm',
      component: () => import('../views/SearchTermView.vue')
    },
    {
      path: '/topn',
      name: 'topn',
      component: () => import('../views/TopNView.vue')
    }
  ]
})

export default router
