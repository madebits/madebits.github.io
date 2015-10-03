#Blocking BlockAdBlock.md

2017-10-13

<!--- tags: browser javascript -->

Somehow [F.F.AdBlock](https://github.com/Mechazawa/FuckFuckAdblock) user script did not work for me to block [BlockAdBlock](https://github.com/sitexw/FuckAdBlock). Below is a modified version tested to work:

```javascript
// ==UserScript==
// @name            BlockFuckAdBlock
// @namespace       BlockFuckAdBlock
// @include         *
// @run-at          document-start
// @grant           none
// ==/UserScript==

// https://stackoverflow.com/questions/10485992/hijacking-a-variable-with-a-userscript-for-chrome
var code = function() {

  class FuckAdBlock {
    onDetected() { return this; }
    onNotDetected(cb) { if(cb) cb(); return this; }
    on(on, cb) { if(!on && cb) cb(); return this; }
    setOption() { return this; }
  }

  Object.defineProperty(window, 'FuckAdBlock', { value: FuckAdBlock, enumerable: true, writable: false });
  Object.defineProperty(window, 'BlockAdBlock', { value: FuckAdBlock, enumerable: true, writable: false });

  var fuck = new FuckAdBlock();

  Object.defineProperty(window, 'fuckAdBlock', { value: fuck, enumerable: true, writable: false });
  Object.defineProperty(window, 'blockAdBlock', { value: fuck, enumerable: true, writable: false });
  Object.defineProperty(window, 'sniffAdBlock', { value: fuck, enumerable: true, writable: false });
  Object.defineProperty(window, 'duckAdBlock', { value: fuck, enumerable: true, writable: false }); 
  Object.defineProperty(window, 'FuckFuckFuckAdBlock', { value: fuck, enumerable: true, writable: false });

};

var script = document.createElement('script');
script.textContent = '(' + code + ')()';
(document.head||document.documentElement).appendChild(script);
script.parentNode.removeChild(script);
```

Save the above code as BlockBlockAdBlock.user.js and install as extension on Chrome.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-10-08-VSCode-Extensions.md'>VSCode Extensions</a></ins>
