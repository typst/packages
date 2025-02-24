# Eqalc

Convert your [Typst](https://typst.app/home) math equations to functions in order to graph or plot them.
So you only have to write your equation out ONCE!

[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/7ijme/eqalc/blob/main/LICENSE)

Install eqalc by cloning it and then importing like this:

```typ
#import "@preview/eqalc:0.1.0": math-to-func, math-to-code, math-to-table

#let f = $g(t)=2t dot sqrt(e^t)+ln(t)+2pi$
#f\
#math-to-code(f)
#math-to-table(f, min: 1, max: 5, step: 1)

// `math-to-func` will return a function that can be used to map over values
```
![image](https://github.com/user-attachments/assets/b151af4e-a0d5-4320-8bf3-3642dd5e6e33)


Available functions at the moment:

- `math-to-func`
- `math-to-code`
- `math-to-table`
- `math-to-data`
