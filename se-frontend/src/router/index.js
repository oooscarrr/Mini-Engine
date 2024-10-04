import { createRouter, createWebHistory } from 'vue-router'
import LoadEngineView from '../views/LoadEngineView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'LoadEngine',
      component: LoadEngineView
    },
    {
      path: '/engineloaded',
      name: 'EngineLoaded',
      component: () => import('../views/EngineLoadedView.vue')
    },
    {
      path: '/searchterm',
      name: 'SearchTerm',
      component: () => import('../views/SearchTermView.vue')
    },
    { path: '/searchresults',
      name: 'SearchResults',
      component: () => import('../views/SearchResultsView.vue'),
      props: route => ({ term: route.query.term })
    },
    {
      path: '/topn',
      name: 'TopN',
      component: () => import('../views/TopNView.vue')
    },
    {
      path: '/topnresults',
      name: 'TopNResults',
      component: () => import('../views/TopNResultsView.vue'),
      props: route => ({ n: route.query.n })
    }
  ]
})

export default router
