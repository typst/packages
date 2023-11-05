#set page(height: auto, width: auto, fill: black)
#set text(fill: white)
#import "../lib.typ": *

#show raw.where(lang: "jogs"): it => eval-js(it)

```jogs
function fib(n) {
  if (n < 2) return n;
  return fib(n - 1) + fib(n - 2);
}
res = []
for (let i = 0; i < 10; i++) {
  res.push(fib(i))
}
res
```
