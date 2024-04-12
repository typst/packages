#set page(height: auto, width: auto, fill: black, margin: 1em)
#set text(fill: white)
#import "../lib.typ": *

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
