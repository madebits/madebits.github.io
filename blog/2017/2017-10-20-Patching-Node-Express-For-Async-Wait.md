#Patching Node Express For Async Wait

2017-10-20

<!--- tags: nodejs express -->

Node [Express](https://expressjs.com/) route action callbacks have are not aware of promisses and cannot be used directly with `async / await`. The following self-contained example shows how to patch Express router to be used with both async and normal callbacks:

```javascript
'use strict';

const express = require('express');
const fs = require('fs');
const util = require('util');
const readdir = util.promisify(fs.readdir);

const patchRouterInstance = (router) => {
    if(!router) return null;
    const Router = Object.getPrototypeOf(router);
    const isAsync = fn => fn[Symbol.toStringTag] === 'AsyncFunction';
    const wrap = fn => (req, res, next) => isAsync(fn) 
        ? fn(req, res, next).catch(next)
        : fn(req, res, next);
    const applyWrap = (original, path, ...args) =>
        original.call(router, path, ...([...args].map(_ => wrap(_))));
    router.get = (path, ...args) => applyWrap(Router.get, path, ...args);
    router.post = (path, ...args) => applyWrap(Router.post, path, ...args);
    return router;
};

const app = express();
const router = patchRouterInstance(express.Router());

app.use('/', router);

app.use(function(err, req, res, next) {
	if(err.stack && !err.status) {
        console.error('error reported by express:', err);
        return res.json(err);
    }
});

router.get('/', async (req, res) => {
	res.json(await readdir('/home'));
});

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2018/2018-01-27-Dirac-Notation-Cheatsheet.md'>Dirac Notation Cheatsheet</a> <a rel='next' id='fnext' href='#blog/2017/2017-10-13-Blocking-BlockAdBlock.md'>Blocking BlockAdBlock</a></ins>
