#Numerical-Methods
A [Typst](https://typst.app/) package for finding roots, gradients and areas of functions.
Graph plotting for integrals built on top of [CeTZ](https://github.com/johannes-wolf/cetz).

```typ
#PlotIntegral(f_x:x=>calc.pow(calc.e,x)+1/(x - 2),
             start-x:0.5,
             end-x:1.8, 
             size_x:3,
             size_y:2,
             labelA:"0.5",
             labelB:"1.8",
             n-strips:8)

#NM-Table-Integrate(f_x:x=>calc.pow(calc.e,x)+1/(x - 2),
                    start-x:0.5,
                    end-x:1.8,
                    show-diffs:false,
                    n-rows:10)

```

Creates the following functions:
```typ
#PlotIntegral()

#NM-Differentiate-Forward()
#NM-Differentiate-Central()

#NM-Integrate-Midpoint()
#NM-Integrate-Trapezium()
#NM-Integrate-Simpsons()

#NM-Iterate-FPI()
#NM-Iterate-RelaxedFPI()
#NM-Iterate-NRaphson()
#NM-Iterate-Secant()
#NM-Iterate-FalsePosition()
#NM-Iterate-Bisection

#NM-Table-Integrate()
#NM-Table-Differentiate()
#NM-Table-Iterate()
```

##Differentiation
Differentiation tools take the following inputs/defaults:
```typ
f_x:x=>x*x, x0:1, h:1, accuracy:12
```
The two differentiation methods are Forward Difference and Central Difference.

##Integrate
Integration tools take the following inputs/defaults:
```typ
f_x:x=>x*x, start-x:0, end-x:1, accuracy:12, n:1
```
Trapezium rule will return $T_n$, Midpoint rule will return $M_n$ and Simpsons ule will return $S_(2n)$

##Iterate
These functions provide the root-finding methods Bisection, False Position, Secant, Newton Raphson, Fixed Point Iteration (FPI) and Relaxed Fixed Point Iteration.
All functions take a `f_x`, except FPI and Relaxed FPI, which take the function `g_x`.
Bisection and False Position will return the region in which the root lies, whereas the others will return their nearest approximation.
The variable `return-all` can be made true to see every step of the iteration, rather than just the last one requested.
*NOTE*: The Newton-Raphson method utilises the Central Difference gradient with `h = 0.0000000001` calculated to 15 decimal places. Thus it is not a true Newton-Raphson approximation.

##Table
These tables are useful for seeing or demonstrating convergence. They have been designed with the A Level Further Maths OCR MEI B specification in mind.
By default, they will include the changing variable ($n$ or $h$ typically), as well as the approximation they have reached.
Optionally, the differences between the estimates can be shown.
If the differences are being shown, then the ratios between the differences can also be shown, with a customizeable order for iterative methods.
For exam purposes, differences and ratios are caluclated from the *table values*, which are rounded, rather than the greater precision stored values.

##PlotIntegral
Useful for demonstrating different types of numerical integration methods. Uses CeTZ to plot.
The number of strips is customizable, and the method should be chosen from:
`integral,mid,left,right,trapezium`
If `integral` is chosen, or any non-listed input is given for the `method` variable, the function defaults to simply highlighting the area to be found.

*NOTE*: Labels aren't in mathematical format, simply New Computer Modern Math font.
