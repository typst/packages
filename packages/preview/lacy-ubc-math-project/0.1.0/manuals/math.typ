#import "@preview/physica:0.9.4": *
#show: super-T-as-transpose // Render "..^T" as transposed matrix
#import "@preview/equate:0.2.1": *
#show: equate.with(breakable: true, sub-numbering: true)
#set math.equation(numbering: "(1.1)")
#import "../format.typ": *

= Math
Formatting math equations is probably the reason you are here.
Unlike LaTex, math in Typst is simple.
#(
  (
    "E = m c^2",
    "e^(i pi) = -1",
    "cal(l) = (-b plus.minus sqrt(b^2 - 4a c))\n\t / (2a)",
  )
    .map(eq => [
      #showcode(raw("$" + eq + "$", lang: "typst", block: true))
    ])
    .join()
)

Most of the time, you have to leave a space between single letters to show consecutive letters.
The template has you covered on some common multi-letter operators, like
#showcode(```typst
$lim, inf$
```)

For "block" or "display" math, leave a space or newline between _both_ dollar signs and the equations.
#showcode(```typst
$ E = m c^2 $
```)

Documented are the built-in #link("https://staging.typst.app/docs/reference/math/")[math functions] and #link("https://staging.typst.app/docs/reference/symbols/sym/")[symbols]

== Texts In Math
To display normal text in math mode, surround the text with double quotes function.
#showcode(```typst
$x = "We are going to find out!"$
```)

If you need normal single-letter text, fist see if it is a lone unit.
If so, use the ```typc unit()``` function.
#showcode(```typst
$unit(N) = unit(kg m s^(-2))$
```)
A unit with a value is called a quantity, ```typc qty()```.
#showcode(```typst
$qty(1, m) = qty(100, cm)$
```)

More about these in #link(<sc:metro>)[Units and Quantities].

Otherwise, use ```typc upright()```.
#showcode(```typst
$U space upright(U) space U$
```)

There are other text styles available in math mode.
#showcode(```typst
$serif("Serif") sans("Sans-serif") frak("Fraktur") \
mono("Monospace") bb("Blackboard bold") cal("Calligraphic")$
```)

== Language Syntax in Math
In (at least) MATH 100 group projects, math equations is a part of your English (or whatever) writings. Make sure to use proper grammar and *punctuations*. Yes, you will add periods after finishing equations.

== Numbering and Referencing Equations
Note that you must enable equation numbering to reference equations, which is set by this template. Add a ```typst #<label-name>``` right after the equation you wish to reference.
#showcode(```typst
$
  e^(i pi) = -1 #<eq:ex:euler>
$
@eq:ex:euler is Euler's identity. \
#link(<eq:ex:euler>)[The same reference].
```)

== Extra Math Symbols and Functions
The `physica` package provides additional math symbols and functions.
#showcode(```typst
$A^T, curl vb(E) = - pdv(vb(B), t)$
```)

#showcode(```typst
$tensor(Lambda,+mu,-nu) = dmat(1,RR)$
```)

#showcode(```typst
$f(x,y) dd(x,y)$
```)

It is imported in this template.

== Units and Quantities
<sc:metro>
Although no as common as in physics, we do sometimes need to use units and quantities.
Directly typing the 'units' will not result in correct output.
#showcode(```typst
$1 m = 100 cm$
```)
#showcode(```typst
$N = kg m s^(-2)$
```)

This template uses the `metro` package for this purpose.
If you prefer, you can also import and use the `unify` package.
#showcode(```typst
$qty(1, m) = qty(100, cm)$
```)
#showcode(```typst
$unit(N) = unit(kg m s^(-2))$
```)

As you see, the ```typc qty()``` and ```typc unit()``` functions correct the numbers, units and spacing.
