# Fractus

Fractus is a library for performing mathematical operations on fractions with [Typst](https://typst.app).

In the etymology tree of the word *fraction*, *fractus* is the past participle of the Latin verb *frangere* (to break).

## Examples

```typ
#import "@preview/fractus:0.1.0" as frac

//Manipulating and displaying a fraction
#frac.simplify("15/-21")

#frac.opposite("15/-21")

#frac.inverse("15/-21")

$#frac.display("3/-18") + 3/7$

#frac.display("3/18", style: "display")

#frac.display("5/1", style: "display")

#frac.float("3/18")

//Calculate and compare fractions
#frac.sum(2, "3/18", "5/12", "5/6")

#frac.difference("3/18", decimal("0.3"))

#frac.product("-3/18", "5/12", "5/-6")

#frac.division("3/18", "5/12")

#frac.eq("-4/-8", frac.opposite("-4/8"), "5/10")

#frac.eq("-4/-8", "-1/2", "5/10")
```
