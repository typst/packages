# Nth

Provides functions `#nth()` and `#nths()` which take a number and return it suffixed by an english ordinal.

This package is named after the nth [LaTeX macro](https://ctan.org/pkg/nth) by Donald Arseneau.

## Usage

Include this line in your document to import the package.

```typst
#import "@preview/nth:1.0.1": *
```

Then, you can use `#nth()` to markup ordinal numbers in your document.

For example, `#nth(1)` shows 1st,  
`#nth(2)` shows 2nd,  
`#nth(3)` shows 3rd,  
`#nth(4)` shows 4th,  
and `#nth(11)` shows 11th.

If you want the ordinal to be in superscript, use `#nths` with an 's' at the end.

For example, `#nths(1)` shows 1<sup>st</sup>.
