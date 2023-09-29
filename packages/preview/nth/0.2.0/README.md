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

## Content

This is a very simple package.

```typst
#let nth(ordinal-num) = {
  let ordinal-str = str(ordinal-num)
  let ordinal-suffix = if ordinal-str.ends-with(regex("1[0-9]")) {
    "th"
  }
  else if ordinal-str.last() == "1" {
    "st"
  }
  else if ordinal-str.last() == "2" {
    "nd"
  }
  else if ordinal-str.last() == "3" {
    "rd"
  }
  else {
    "th"
  }
  show: ordinal-str + super(ordinal-suffix)
}
```

## TODO

* Pass argument to choose whether or not to put ordinals in superscript.
