# irif
A [Typst](https://typst.app/) package for Numerical Methods to find roots, gradients and areas of functions.
Graph plotting for integrals built on top of [CeTZ](https://github.com/johannes-wolf/cetz).

Examples can be found [here as a .pdf](examples/examples.pdf) and [here as .typ](examples/examples.typ).


```typ
#plot-integral(f_x:x=>calc.pow(calc.e,x)+1/(x - 2),
             x0:0.5,
             x1:1.8, 
             size-x:3,
             size-y:2,
             label-a:"0.5",
             label-b:"1.8",
             n-strips:8)

#nm-table-integrate(f_x:x=>calc.pow(calc.e,x)+1/(x - 2),
                    x0:0.5,
                    x1:1.8,
                    show-diffs:false,
                    n-rows:10)

```

Functions names are as follows: `nm-[operation type]-[method]`
Creates the following functions:
```typ
#nm-differentiate-forward()
#nm-differentiate-central()

#nm-integrate-midpoint()
#nm-integrate-trapezium()
#nm-integrate-simpsons()
#nm-integrate-simpsons-38()

#nm-iterate-FPI()
#nm-iterate-relaxed-FPI()
#nm-iterate-newton-raphson()
#nm-iterate-secant()
#nm-iterate-false-position()
#nm-iterate-bisection()

#nm-table-integrate()
#nm-table-differentiate()
#nm-table-iterate()

#plot-integral()
```

## nm-differentiation
Differentiation tools take the following inputs/defaults:
```typ
f_x:x=>x*x, x0:1, h:1, accuracy:12
```
The function will approximate $f'(x_0)$ using either the Forward Difference or Central Difference method.

## nm-integrate
Integration tools take the following inputs/defaults:
```typ
f_x:x=>x*x, x0:0, x1:1, accuracy:12, n:1
```
These will approximate $\int_{x 0}^{x 1}(f_x(x))\text{d}x $

Trapezium rule will return $T_n$, Midpoint rule will return $M_n$, Simpsons rule will return $S_{2n}$ and Simpsons-38 will return $S_{3n}$

## nm-iterate
These functions provide the root-finding methods Bisection, False Position, Secant, Newton Raphson, Fixed Point Iteration (FPI) and Relaxed Fixed Point Iteration.

All functions take the parameter `f_x`, except FPI and Relaxed FPI, which take the function `g_x`.

Bisection and False Position will return the region in which the root lies, whereas the others will return their nearest approximation.

The parameter `return-all` can be made true to see every step of the iteration, rather than just the last one requested.

*NOTE*: The Newton-Raphson method utilises the Central Difference gradient with `h = 0.0000000001` calculated to 15 decimal places. Thus it is not a true Newton-Raphson approximation.

## nm-table
These tables are useful for seeing or demonstrating convergence. They have been designed with the A Level Further Maths OCR MEI B specification in mind.

By default, they will include the changing variable ($n$ or $h$ typically), as well as the approximation they have reached.

Optionally, the differences between the estimates can be shown.

If the differences are being shown, then the ratios between the differences can also be shown, with a customizeable order for iterative methods.

*NOTE*: For exam purposes, differences and ratios are caluclated from the *table values*, which are rounded, rather than the greater precision stored values.

## plot-integral
Useful for demonstrating different types of numerical integration methods. Uses CeTZ to plot.

The number of strips is customizable, and the method should be chosen from:

`integral,mid,left,right,trapezium,simpsons,simpsons-38`

If `integral` is chosen, or any non-listed input is given for the `method` variable, the function defaults to simply highlighting the area to be found.

*NOTE*: Labels aren't in mathematical format, simply New Computer Modern Math font.

