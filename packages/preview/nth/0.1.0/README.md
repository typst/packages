# Nth

Provides a function `#nth()` which takes a number and returns it suffixed by an english ordinal.

This package is named after the nth [LaTeX macro](https://ctan.org/pkg/nth) by Donald Arseneau.

## Usage

Import the package

```typst
import "@preview/nth:0.1.0": *
```

Then, you can use `#nth()` to markup ordinal numbers in your document. For example, writing `#nth(1)` gives '1<sup>st</sup>', `#nth(2)` gives '2<sup>nd</sup>', `#nth(3)` gives '3<sup>rd</sup>', and `#nth(4)` gives '4<sup>th</sup>'.

## TODO

* Pass argument to choose whether or not to put ordinals in superscript.
