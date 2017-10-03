2017

#Vue.js Starter Template

<!--- tags: javascript -->

[Webpack](https://webpack.js.org/) based template for [Vue.js](https://vuejs.org) web client applications.

![](r/vue-starter-template/app.png)

The template helps starting with following features:

* UI uses [Bootstrap 4](http://getbootstrap.com/) (via SASS) and [Font Awesome](http://fontawesome.io/icons/) icons.
* Full sample of using Bootstrap modal dialogs, including events.
* Vue render JSX support.
* [Vuex](https://vuex.vuejs.org/en/) is fully integrated along with persistence on client. Example actions are provided.
* [vue-router](https://router.vuejs.org/en/) is used to handle routing. Nested routes are demonstrated.
* [vue-i18n](http://kazupon.github.io/vue-i18n/en/) internationalization fully integrated.
* Sample starter code to help with Ajax (via [axios](https://github.com/axios/axios)), logging, authentication, timers.
* ES2015+ via Babel with `async` / `await`.
* Unit tests with Karma and jasmine in chrome headless with code coverage. Example of [vue-test-utils](https://vue-test-utils.vuejs.org/en/) included.

##Getting Started

To start clone the template locally from GitHub (link below) and initialize the project after cloning using:

```
npm install
```

Vue Starter Template template does not use `vue-client`. I learned a lot from the `vue-client` official template and used it as a basis, but my template is a bit different and also does not support end-to-end tests. I think it is better to keep end-to-end tests in separate projects.

##Main Actions

* To debug application with hot replacement use (application starts by default at http://localhost:8080):

    ```
    npm run start-debug
    ```

* To debug both application and unit tests with hot replacement use:

    ```
    npm start-debug-withtests
    ```
 
  Unit tests are available in browser via http://localhost:8080/test.html URL.

* To build a release use:

    ```
    npm build-release
    ```

* To start `http-server` on release output folder (`./dist`) use:

    ```
    npm run start-release
    ```

* To run release unit tests via karma with headless chrome use:

    ```
    npm test
    ```

* Less useful commands:

    ```
    # run eslint, release build fails on eslint errors
    npm run lint

    # a debug build (npm run start-release works with this one too)
    npm run build-debug

    # build release with source maps
    npm run build-release-withsourcemaps
    ```


##Sample Application

Sample starter Vue.js application that comes with the template needs a mock backend to work. To start mock backend run the following commands in a terminal:

```
cd backend
npm install
node index.js
```

Backend will run at port http://localhost:3000 by default.

##VSCode Configuration (Extensions)

* [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
* [Prettier - JavaScript formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
  ```
  "prettier.singleQuote": true,
  "prettier.semi": false,
  "prettier.eslintIntegration": true
  ```
* [Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)
  ```
  "vetur.format.defaultFormatter": {
        "html": "prettier"
  }
  ```
* [Vue Peek](https://marketplace.visualstudio.com/items?itemName=dariofuzinato.vue-peek)

See also: [Vue.js Extension Pack](https://marketplace.visualstudio.com/items?itemName=mubaidr.vuejs-extension-pack).

##Vue.Js Resources

* [Vue.Js Guide](https://vuejs.org/v2/guide/)
* [vue-router](https://router.vuejs.org/en/)
* [Vuex](https://vuex.vuejs.org/en/)
* [Vue Style Guide](https://vuejs.org/v2/style-guide/)
* [vue-i18n](http://kazupon.github.io/vue-i18n/en/)
* [vue-test-utils](https://vue-test-utils.vuejs.org/en/)



