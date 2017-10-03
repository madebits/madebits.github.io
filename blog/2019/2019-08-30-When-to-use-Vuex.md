#When to use Vuex

2019-08-30

<!--- tags: vue javascript -->

[Vuex](https://vuex.vuejs.org/) helps manage state and cache data in [Vue.js](https://vuejs.org/) applications. Some rules of thumb on when to use it:

* If you need data in one Vue component only and do not mind about caching in Vuex (may be you have some other cache for network data, or simply do not need cache) **do not use** Vuex.
* If you to share state between Vue components (or in same or in different SPA pages) in same browser tab and refresh is not an issue, use Vuex as is, with its per tab **in-memory** storage.
* If you want some shared state between Vue components (or in same or in different SPA pages) in the same browser tab that survives a browser page refresh, use Vuex with **session storage** persistence (use some ready-made plug-in (better), or write one on your own).
* If you want to cache some shared state between tabs, such as authentication tokens or user profile and locale, use Vuex with **local storage** persistence (use some plug-in, or write one on your own).
* If you want real-time state propagation between tabs (e.g. when users changes UI locale), you need to use browser local storage events to **react to changes** and update Vuex store on each tab.
* If you want to store data long term (should be rate) in Vuex even if the browser is closed use Vuex with **cookie storage** (use some plug-in, or write one on your own).

In an Vue.js application, there is usually a need for most or all of these. An example follows:

```javascript
// index.js
import Vue from 'vue'
import Vuex from 'vuex'
import Cookies from 'js-cookie'
import createPersistedState from 'vuex-persistedstate'
import state from './state'
import actions from './default/actions'
import mutations from './default/mutations'
import getters from './default/getters'
import someModule from './someModule'
import storeLocalSync from './storeLocalSync'
import storeWatchers from './storeWatchers'
import symbols from '@/store/default/symbols'

Vue.use(Vuex)

const store = new Vuex.Store({
  strict: DEBUG,
  state: Object.assign(state, {}),
  getters,
  actions,
  mutations,
  modules: {
    someModule
  },
  plugins: [
    createPersistedState({
      paths: ['cookie'],
      storage: {
        getItem: key => Cookies.get(key),
        setItem: (key, value) => Cookies.set(key, value), //session
        removeItem: key => Cookies.remove(key)
      }
    }),
    createPersistedState({
      paths: ['local'],
      filter: mutation => mutation.type !== symbols.mutations.storeLocalSync
    }),
    createPersistedState({
      key: 'vuexSession',
      paths: ['session'],
      storage: window.sessionStorage
    }),
    storeLocalSync, // sync shared state between tabs
    storeWatchers // deal with reactivity
  ]
})

if (module.hot) {
  module.hot.accept(
    [
      './default/getters',
      './default/actions',
      './default/mutations',
      './someModule'
    ],
    () => {
      store.hotUpdate({
        getters: require('./default/getters').default,
        actions: require('./default/actions').default,
        mutations: require('./default/mutations').default,
        modules: {
          someModule: require('./someModule').default
        }
      })
    }
  )
}

export default store
```

In the above example, we rely that different parts of **state** object are persisted in difference places, so application developers can choose where to put their data based on rules of thumb above:

```javascript
// state.js
export default {
  cookie: { // any data here is put into a shared session cookie
  },
  local: { // any data here is put in local storage
    locale: 'en-US',
    auth: {
      token: null,
      refreshToken: null,
    },
    userProfile: null,
    version: null
  },
  session: { // any data here is put in session storage
    context: {
    },
    errors: {
      lastError: null,
      lastErrors: null
    }
  }
  // rest of data is in page memory
}
```

The last two plug-ins added to Vuex in this example `storeLocalSync` and `   storeWatchers` deal with specific cases when state needs to be synchronized between tabs and when store needs to react to local storage changes.

```javascript
// storeLocalSync.js
import symbols from '@/store/default/symbols'
import log from '@/common/logger'

export default store => {
  window.addEventListener('storage', event => {
    //log.debug('local storage changed', event.newValue)
    if (event.key !== 'vuex') return
    try {
      const data = JSON.parse(event.newValue)
      if (data.local) {
        store.commit(symbols.mutations.storeLocalSync, data.local)
      }
    } catch (e) {
      log.error(e)
    }
  })
}
```

```javascript
// storeWatchers.js
import getters from './default/getters'
import symbols from '@/store/default/symbols'

export default store => {
  // use same language if propagated from other tabs
  store.watch(getters[symbols.getters.locale], (newValue, oldValue) => {
    store.dispatch(symbols.actions.locale, newValue)
  })
}
```

Nothing specific about the `storeLocalSync` mutation used above - it is shown next to complete the example:

```javascript
// mutations.js (extract)
import symbols from '@/store/default/symbols'
import util from '@/common/util'
import initialState from '@/store/state'
import otherMutations from './otherMutations'

export default Object.assign({

  [symbols.mutations.storeLocalSync](state, shared) {
    if (shared) {
      state.local = shared
    }
  },

  [symbols.mutations.clearState](state) {
    state.session = util.cloneData(initialState.session || {})
  }
},
othergMutations
)
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-04-16-SFTP-With-Shared-Access.md'>SFTP With Shared Access</a></ins>
