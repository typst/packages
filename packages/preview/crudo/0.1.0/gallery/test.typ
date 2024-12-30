// make the PDF reproducible to ease version control
#set document(date: none)

// #import "../src/lib.typ"
#import "@preview/crudo:0.1.0"

#import "@preview/codly:0.2.1": *

#show: codly-init
#codly()

#let preamble = ```typ
#import "@preview/crudo:0.0.1"

```

#let example = ````typ
#crudo.r2l(```c
int main() {
  return 0;
}
```)
````

#let full-example = crudo.join(preamble, example)

= The example

#example

= The example with preamble

#full-example

(usually you don't show this)

= Evaluating the example

#eval(full-example.text, mode: "markup")
