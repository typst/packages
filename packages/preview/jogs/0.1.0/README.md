# Jogs

Quickjs javascript runtime for typst. This package provides a typst plugin for evaluating javascript code.

## Example

````typst
#import "@preview/jogs:0.1.0": *

#set page(height: auto, width: auto, fill: black)
#set text(fill: white)

#show raw.where(lang: "jogs"): it => eval-js(it)

```jogs
let a = {a: 0, c: 1, b: "123"}
let res = []
function fib(n) {
  if (n < 2) return n
  return fib(n - 1) + fib(n - 2)
}
for (let i = 0; i < 10; i++) {
  res.push(fib(i))
}
a.d = res
a
```

````

result: 

![](typst-package/examples/fib.svg)

## Documentation

This package provide following function(s):

### `eval-js`

Run a Javascript code snippet.

#### Arguments
* `code` - The Javascript code to run. It can be a string or a raw block.

#### Returns
The result of the Javascript code. The type is the typst type which most closely resembles the Javascript type.

#### Example

```typ
#let result = eval-js("1 + 1")
```
