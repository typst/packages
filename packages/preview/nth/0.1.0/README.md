# Nth

Provides a function `#nth()` which takes a number and returns it suffixed by an english ordinal.

This package is named after the nth [LaTeX macro](https://ctan.org/pkg/nth) by Donald Arseneau.

## Usage

Include this line in your document to import the package.

```typst
#import "@preview/nth:0.1.0": nth
```

Then, you can use `#nth()` to markup ordinal numbers in your document.

For example, writing `#nth(1)` shows 1<sup>st</sup>,  
`#nth(2)` shows 2<sup>nd</sup>,  
`#nth(3)` shows 3<sup>rd</sup>,  
`#nth(4)` shows 4<sup>th</sup>,  
and `#nth(11)` shows 11<sup>th</sup>.

## Content

This is a very simple package.

```typst
#let nth(ordinal-num) = {
  let ordinal-str = str(ordinal-num)
  if ordinal-str.ends-with(regex("1[0-9]")) {
    show: ordinal-str + super("th")
  }
  else if ordinal-str.last() == "1" {
    show: ordinal-str + super("st")
  }
  else if ordinal-str.last() == "2" {
    show: ordinal-str + super("nd")
  }
  else if ordinal-str.last() == "3" {
    show: ordinal-str + super("rd")
  }
  else {
    show: ordinal-str + super("th")
  }
}
```

## TODO

* Pass argument to choose whether or not to put ordinals in superscript.
