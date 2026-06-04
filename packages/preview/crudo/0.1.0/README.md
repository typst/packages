# Crudo

Crudo allows conveniently working with `raw` blocks in terms of individual lines. It allows you to e.g.

- filter lines by content
- filter lines by range (slicing)
- transform lines
- join multiple raw blocks

While transforming the content, the original [parameters](https://typst.app/docs/reference/text/raw/#parameters) specified on the given raw block will be preserved.

`````typ
#import "@preview/crudo:0.1.0"

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
`````

See the [manual](docs/manual.pdf) for details.
