# The `libra` Package
<div align="center">Version 0.1.0</div>

Offers a single function, `balance`, which balances the lines of a given text.
It is most useful for balancing especially laid-out text such as headings or captions.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

## Getting Started

These instructions will get you a copy of the project up and running on the typst web app.
For more details, check out the [manual](docs/manual.pdf).

```typst
#import "@preview/libra:0.1.0": balance

#balance(lorem(20))
```
