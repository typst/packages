# Nth

Provides a function `#nth()` which takes a number and returns it suffixed by an english ordinal.

This package is named after the nth [LaTeX macro](https://ctan.org/pkg/nth) by Donald Arseneau.

## Usage

Include this line in your document to import the package.

```typst
#import "@preview/nth:0.2.0": nth
```

Then, you can use `#nth()` to markup ordinal numbers in your document.

For example, writing `#nth(1)` shows 1<sup>st</sup>,  
`#nth(2)` shows 2<sup>nd</sup>,  
`#nth(3)` shows 3<sup>rd</sup>,  
`#nth(4)` shows 4<sup>th</sup>,  
and `#nth(11)` shows 11<sup>th</sup>.

_Please use version 0.2.0 as version 0.1.0 is broken!_
See issue [here](https://github.com/typst/packages/pull/162) (thanks to jeffa5)._

## TODO

* Pass argument to choose whether or not to put ordinals in superscript.

