#let back_colour = rgb("011227");
#let text_colour = rgb("ffffff");

#let look_good(body) = {
  set page(
    numbering: "1", 
    number-align: center,
    fill: back_colour,
    margin: (top: 8em),
  )
  set text(
    font: "New Computer Modern", 
    lang: "en",
    fill: text_colour,
  )

  set math.mat(augment: (stroke: text_colour))

  set table(
    stroke: text_colour,
  )
  show math.equation: set text(weight: 400)

  body
}

#show: look_good

#import "@preview/matset:0.1.0": *

= Example usage

You get a global namespace of definitions, into which you can insert things using the #insert function:
#insert($ x_0 := 4 $)
#insert($ y_0 := 12 $)
You can then evaluate expressions with these names:
$ evaluate(3 + x_0 dot y_0) $
You can also define functions:
#insert($ k(x) := sin(x) $)
$ evaluate(k(pi)) $
Real numbers aren't the only things supported! When possible, the evaluation engine tries to keep things rational:
$ evaluate(1/4 + 1/234) $
It also supports complex numbers and decimals (decimals which are too long get turned into floating point numbers, but otherwise are parsed into rationals):
$ evaluate(1.3 + i) $
#grid(
  columns: (1fr,) * 3, 
  $ evaluate(overline(3i)) $,
  $ evaluate(abs(3 + 4 i)) $,
  $ evaluate(exp(23 i)) $
)
Another builtin datatype is matrices (implicitly vectors are matrices of the appropriate size):
#grid(
  columns: (1fr,) * 3, 
  row-gutter: 1em,
  insert($ g(z) := vec(z, 1/2 z) $),
  $ evaluate(g(3+i)) $,
  $ evaluate(mat(1, 2; 4, 5) g(12)) $,
  $ evaluate(g(5)^T) $,
  $ evaluate((g(3 + i)^* mat(1, 2; 4, 5))^T) $,
  $ evaluate(det(mat(1, 2; 3, 4))) $,
)

The engine works fine with your builtin functions/macros:
#let ip(..a) = {
  if a.pos().len() > 0 {
    $lr(angle.l #a.pos().join($,$) angle.r)$
  } else {
    $lr(angle.l dot, dot angle.r)$
  }
}
(if you're reading the pdf, we'll have just defined an inner product function $ip$):
$ evaluate(ip(vec(1, i), vec(2, -i))) $
The final datatype that's built-in is callable objects. Callable objects are first-class citizens here:
#grid(
  columns: (1fr,) * 3, 
  row-gutter: 1em,
  insert($ f_0(z) := z^2 $),
  insert($ f_1(z) := 1/z $),
  insert($ f_2(z) := i z $),
  $ evaluate((f_0 + 2)(2)) $,
  $ evaluate((f_0 dot f_1)(5)) $,
  $ evaluate((f_1/f_2 + f_0)(3)) $,
)

#pagebreak()
You can also define closures. The syntax is as follows:
#grid(
  columns: (1fr,) * 2, 
  row-gutter: 1em,
  insert($ T := x |-> 3x + vec(1, 2) $),
  $ evaluate(T(vec(2, 4))) $
)
And these can capture variables:
#grid(
  columns: (1fr,) * 2, 
  row-gutter: 1em,
  insert($ T_0 (x) := z |-> x + z $),
  $ evaluate(T_0 (2)(6)) $
)
For the curious, you can now do (some weak form of) lambda calculus:

#let yes = "True"
#let no = "False"
#let try = "If"

#grid(
  columns: (1fr,) * 3, 
  row-gutter: 1em,
  insert($ yes := y |-> n |-> y $),
  insert($ no := y |-> n |-> n $),
  insert($ try := c |-> y |-> n |-> c(y)(n) $),
)

$ evaluate(try (yes) (3) (4)) $

Finally, there are three more functions supplied by the API:
- #debug which will dump the current context. It's hard to parse, so you can ignore it and instead report bugs on the repo.
- #floateval which will evaluate as usual but turn any rationals into floating point numbers.
- #floatexpr which lets you evaluate things and get a float directly. Since this library is built on top of `context` expressions, then trying to use `floateval` or `evaluate` will yield a context expression.

Why do we care about not getting a context expression? Because we can then use this to do graphing:

#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1": plot, chart

#floatexpr(evaluation => cetz.canvas({
  import cetz.draw: *
  
  set-style(
    axes: (stroke: .5pt + text_colour, 
    tick: (stroke: .5pt + text_colour)),
    legend: (
      stroke: text_colour, 
      orientation: ttb, 
      item: (spacing: .3), 
      scale: 80%,
      fill: back_colour,
    )
  )
            
  plot.plot(
    size: (8,8), 
    y-tick-step: 1, y-min: -2.5, y-max: 2.5,
    x-tick-step: 1, x-min: -2.5, x-max: 2.5,
    legend: "inner-north", stroke: text_colour,
  {
    let expr = $f_0(t) - 2$
    plot.add(
      domain: (-2.5, 2.5),
      label: expr,
      t => evaluation($(t |-> expr)(#t)$)
    )
  })
}))

