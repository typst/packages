# pariman
A Framework on Engineering Calculation With Units in Typst. Featured with unit and number formatting by [zero](https://github.com/Mc-Zen/zero.git) package.

 
# Installation
Import the package by
```typst
#import "@preview/pariman:0.1.0": *
```
Or install the package locally by cloning this package into your local package location.

# Usage
## The `quantity` function
The package provides a dictonary-based element called `quantity`. This `quantity` can be used as a number to all of the calculation functions in Pariman's framework. The quantity is declared by specify its value and unit.

```typst
#let a = quantity("1.0e5", "m/s^2")
Display value and unit: #a.display \
Display only the formatted value: #a.show \
Display the raw value verbatim: #a.text \
Significant figures: #a.figures \
Decimal places: #a.places
```
<img alt="img1" src="https://github.com/pacaunt/pariman/blob/main/docs/image1.png"/>

Pariman's `quantity` takes care of the significant figure calculations and unit formatting automatically. The unit formatting functionality is provided by the [zero](https://github.com/Mc-Zen/zero.git) package. Therefore, the format options for the unit can be used.

```typst
#let b = quantity("1234.56", "kg m/s^2")
The formatted value and unit: #b.display  \
#zero.set-unit(fraction: "fraction")
After new fraction mode: #b.display
```
<img alt="img2" src="https://github.com/pacaunt/pariman/blob/main/docs/image2.png"/>
Pariman loads the `zero` package automatically, so the the unit formatting options can be modified by `zero.set-xxx` functions.

For exact values like integers, pi, or other constants, that should not be counted as significant figures, Pariman have the `#exact` function for exact number quantities. The `#exact` function does not accept unit and has 99 significant figures.

```typst
#let pi = exact(calc.pi)
The value: #pi.display \
Significant figures: #pi.figures
```
<img alt="img3" src="https://github.com/pacaunt/pariman/blob/main/docs/image3.png"/>
Note that the `quantity` function can accept only the value for the unitless quantoity.

## The `calculation` module
The `calculation` module provides a framework for calculations involving units. Every function will modify the input `quantity`s into a new value with a new unit corresponding to the law of unit relationships.

```typst
#let s = quantity("1.0", "m")
#let t = quantity("5.0", "s")
#let v = calculation.div(s, t) // division
The velocity is given by #v.display. \
The unit is combined!
```
<img alt="img4" src="https://github.com/pacaunt/pariman/blob/main/docs/image4.png"/>

Moreover, each quantity also have a `method` property that can show its previous calculation.

```typst
#let V = quantity("2.0", "cm^3")
#let d = quantity("0.89", "g/cm^3")
#let m = calculation.mul(d, V)
From $V = #V.display$, and density $d = #d.display$, we have
$ m = d V = #m.method = #m.display. $
```
<img alt="img5" src="https://github.com/pacaunt/pariman/blob/main/docs/image5.png"/>
The `method` property is recursive, meaning that it is accumulated if your calculation is complicated. Initially, `method` is set to `auto`.

```typst
#let A = quantity("1.50e4", "1/s")
#let Ea = quantity("50e3", "J/mol")
#let R = quantity("8.314", "J/mol K")
#let T = quantity("298", "K")

Arrhenius equation is given by
$ k = A e^(-E_a/(R T)) $
This $k$, at $A = #A.display$, $E_a = #Ea.display$, and $T = #T.display$, we have
#let k = {
  import calculation: *
  mul(A, exp(
    div(
      neg(Ea),
      mul(R, T)
    )
  ))
}
$ 
  k &= #k.method \ 
    &= #k.display 
$
```
<img alt="img6" src="https://github.com/pacaunt/pariman/blob/main/docs/image6.png"/>

## `set-quantity` 
If you want to manually set the formatting unit and numbers in the `quantity`, you can use the `set-quantity` function. 
```typst
#let R = quantity("8.314", "J/mol K")
#let T = quantity("298.15", "K")

#calculation.mul(R, T).display 
// 4 figures, follows R (the least).

// reset the significant figures
#let R = set-quantity(R, figures: 8) 
#calculation.mul(R, T).display 
// 5 figures, follows the T.
```
<img alt="img7" src="https://github.com/pacaunt/pariman/blob/main/docs/image7.png"/>

Moreover, if you want to reset the `method` property of a quantity, you can use `set-quantity(q, method: auto)` as 

```typst 
#let R = quantity("8.314", "J/mol K")
#let T = quantity("298.15", "K")

#let prod = calculation.mul(R, T)
Before reset:
$ prod.method = prod.display $
// reset
#let prod = set-quantity(prod, method: auto) 
After reset:
$ prod.method = prod.display $
```
<img alt="img8" src="https://github.com/pacaunt/pariman/blob/main/docs/image8.png"/>

## Unit conversions 
The `new-factor` function creates a new quantity that can be used as a conversion factor. This conversion factor have the following characteristics: 
+ It has, by default, 10 significant figures. 
+ It have a method called `inv` for inverting the numerator and denominator units.
```typst
#let v0 = quantity("60.0", "km/hr")
#let km-m = new-factor(
  quantity("1", "km"), 
  quantity("1000", "m")
) // km -> m

#let hr-s = new-factor(
  quantity("1", "hr"),
  quantity("3600", "s"), 
) // s -> hr

#let v1 = calculation.mul(v0, km-m)
First conversion, from km to m
$ v1.method = v1.display $

// change from hr -> s, use `hr-s.inv` because hr is in the denominator
#let v2 = calculation.mul(v1, hr-s.inv)
Second conversion: 
$ v2.method = v2.display $
```
<img alt="img9" src="https://github.com/pacaunt/pariman/blob/main/docs/image9.png"/>

# Available Calculation Methods 
- `neg(a)` negate a number, returns negative value of `a`. 
- `add(..q)` addition. Error if the unit of each added quantity has different units. Returns the sum of all `q`.
- `sub(a, b)` subtraction. Error if the unit of each quantity is not the same. Returns the quantity of `a - b`. 
- `mul(..q)` multiplication, returns the product of all `q`.
- `div(a, b)` division, returns the quantity of `a/b`.
- `inv(a)` returns the reciprocal of `a`.
- `exp(a)` exponentiation on based $e$. Error if the argumenrt of $e$ has any leftover unit. Returns a unitless `exp(a)`.
- `pow(a, n)` returns $a^n$. If $n$ is not an integer, `a` must be unitless. 
- `ln(a)` returns the natural log of `a`. The quantity `a` must be unitless. 
- `log(a, base: 10)` returns the logarithm of `a` on base `base`. Error if `a` is not unitless.
- `root(a, n)` returns the $n$th root of `a`. If `n` is not an integer, then `a` must be unitless. 
- `solver(func, init: none)` solves the function that is written in the form `f(x) = 0`. It returns another quantity that has the same dimension as the `init` value. //

