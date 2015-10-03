2016

#NumericSort

<!--- tags: javascript nodejs -->

[**numericsort**](https://www.npmjs.com/package/numericsort) enables sorting strings numerically in Node.js. It is a Javascript port of [some C#](r/msnet-numeric-sort.md) code as a lightweight Node.js package with no external dependencies.

##Usage

To install:

```
npm install numericsort --save
```

To use:

```javascript
var nsort = require('numericsort');

console.log(['1', '10', '3'].sort(nsort)); // logs: ["1", "3", "10"] 
console.log(['1', '10', '3'].sort());  // logs: ["1", "10", "3"] 
```

#Details

**numericsort** package exports a single function

`numericsort(s1, s2, [zeroesFirst])`:

* `s1`: first string to compare.
* `s2`: second string to compare.
* `zeroesFirst`: if `false` (default) then `['001', '01', '1', '002', '02', '2']` in combination with `Array.prototype.sort` remains as is. If `true`, it becomes `['001', '002', '01', '02', '1', '2']`.

The function returns:

* `0` if `s1 === s2`
* `-1` if `s1 < s2`
* `1` if `s1 > s2`. 

`s1` and `s2` are converted to strings using `toString()` method if they are not string. Internally, `String.prototype.localeCompare` is used for comparing strings.



