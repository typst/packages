#import "@preview/irif:0.0.1" : *
#set page(margin: (top:2cm,x:1cm,bottom:1cm))
== NM-Integrate
#table(columns:5,inset:8pt,
table.header([Target],$n$,[\#Midpoint],[\#Trapezium],[\#Simpsons]),
table.cell(rowspan:4,[$pi approx $ #calc.round(calc.pi,digits:8)]),
[1],[#nm-integrate-midpoint(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:1,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:1,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:1,accuracy:6)],
[2],[#nm-integrate-midpoint(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:2,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:2,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:2,accuracy:6)],
[4],[#nm-integrate-midpoint(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:4,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:4,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:4,accuracy:6)],
[8],[#nm-integrate-midpoint(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:8,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:8,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>4 / (1 + x*x),x0:0,x1:1,n:8,accuracy:6)],
table.cell(rowspan:4,[$ln 2 approx $#calc.round(calc.ln(2),digits:8)]),
[1],[#nm-integrate-midpoint(f_x:x=>1/x,x0:1,x1:2,n:1,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>1/x,x0:1,x1:2,n:1,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>1/x,x0:1,x1:2,n:1,accuracy:6)],
[2],[#nm-integrate-midpoint(f_x:x=>1/x,x0:1,x1:2,n:2,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>1/x,x0:1,x1:2,n:2,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>1/x,x0:1,x1:2,n:2,accuracy:6)],
[4],[#nm-integrate-midpoint(f_x:x=>1/x,x0:1,x1:2,n:4,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>1/x,x0:1,x1:2,n:4,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>1/x,x0:1,x1:2,n:4,accuracy:6)],
[8],[#nm-integrate-midpoint(f_x:x=>1/x,x0:1,x1:2,n:8,accuracy:6)],
  [#nm-integrate-trapezium(f_x:x=>1/x,x0:1,x1:2,n:8,accuracy:6)],
  [#nm-integrate-simpsons(f_x:x=>1/x,x0:1,x1:2,n:8,accuracy:6)])

== NM-Differentiate
#table(columns:4,inset:8pt,
table.header([Target],$h$,[\#Forward],[\#Central]),
table.cell(rowspan:3,[$f(x)=cos x, quad f`(pi/2)=-1$]),
$1$,[#nm-differentiate-forward(f_x:x=>calc.cos(x),x0:calc.pi/2,h:1,accuracy:6)],
      [#nm-differentiate-central(f_x:x=>calc.cos(x),x0:calc.pi/2,h:1,accuracy:6)],
$0.1$,[#nm-differentiate-forward(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.1,accuracy:6)],
      [#nm-differentiate-central(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.1,accuracy:6)],
$0.01$,[#nm-differentiate-forward(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.01,accuracy:6)],
      [#nm-differentiate-central(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.01,accuracy:6)],
table.cell(rowspan:3,[$f(x)=1/(1+ln x),quad f`(2) approx -0.174414$]),
$1$,[#nm-differentiate-forward(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:1,accuracy:6)],
  [#nm-differentiate-central(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:1,accuracy:6)],
$0.1$,[#nm-differentiate-forward(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.1,accuracy:6)],
  [#nm-differentiate-central(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.1,accuracy:6)],
$0.01$,[#nm-differentiate-forward(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.01,accuracy:6)],
  [#nm-differentiate-central(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.01,accuracy:6)])

#pagebreak()
== nm-iterate
=== FPI
#table(columns:4, inset:8pt,
table.header([Target],[\#Fixed],[\#Relaxed $lambda=0.5$],[\#Relaxed $lambda=1.4$]),
[$g(x)=2sin x + 2 cos x \ x approx -2.68075641016$],
  [#nm-iterate-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:8)],
  [#nm-iterate-relaxed-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:8,lambda:0.5)],
  [#nm-iterate-relaxed-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:8,lambda:1.4)])
All Values:
#let FPI = nm-iterate-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:5,return-all:true)
#let RFPI1 = nm-iterate-relaxed-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:5,lambda:0.5,return-all:true)
#let RFPI2 = nm-iterate-relaxed-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:5,lambda:1.4,return-all:true)

#let table-rows = ()
#for i in range(FPI.len()) {
  table-rows.push([#i])
  table-rows.push([#FPI.at(i)])
  table-rows.push([#RFPI1.at(i)])
  table-rows.push([#RFPI2.at(i)])
}

  #table(columns:4,inset:5pt,
  table.header($n$,[FPI $x_n$],[RFPI,$lambda=0.5$],[RFPI,$lambda=1.4$],
  ..table-rows
  )
)
=== Newton-Raphson
#table(columns:2,inset:8pt,
table.header([Target],[\#NRaphson]),
[$f(x)=e^x-x-2 \ f(1.14619) approx 0 \ f(-1.84141) approx 9$],
[#nm-iterate-newton-raphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:1,accuracy:6) \ \
  #nm-iterate-newton-raphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:-1,accuracy:6)])
All Values:
#let NR1 = nm-iterate-newton-raphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:1,accuracy:6,return-all:true)
#let NR2 = nm-iterate-newton-raphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:-1,accuracy:6,return-all:true)
#let table-rows = ()
#for i in range(NR1.len()) {
  table-rows.push([#i])
  table-rows.push([#NR1.at(i)])
  table-rows.push([#NR2.at(i)])
}
#table(columns:3,inset:5pt,
table.header([$n$],[NR:$x_0 = 1$],[NR:$x_0 = -1$]),
..table-rows
)

=== Secant, False Position, Bisection for $sin(x)=0$
#table(columns:(0.2fr,1fr,1fr,1fr),inset:5pt,
table.header($x$,[Secant],[False Position],[Bisection]),
text(size:8pt)[$[-1,1]$],
  [#nm-iterate-secant(x0:-1,x1:1,return-all:true,accuracy:8)],
  [#nm-iterate-false-position(x0:-1,x1:1,return-all:true,accuracy:8)],
  [#nm-iterate-bisection(x0:-1,x1:1,return-all:true,accuracy:8)],
text(size:8pt)[$[0.5,1]$],
[#nm-iterate-secant(x0:0.5,x1:1,return-all:true,accuracy:8)],
  [ False Position should panic.
  //#nm-iterate-false-position(x0:0.5,x1:1,return-all:true,accuracy:8)
],
  [ Bisection should panic.
  //#nm-iterate-bisection(x0:0.5,x1:1,return-all:true,accuracy:8)
],
text(size:8pt)[$[-1.5,1]$],
  [#nm-iterate-secant(x0:-1.5,x1:1,return-all:true,accuracy:8)],
  [#nm-iterate-false-position(x0:-1.5,x1:1,return-all:true,accuracy:8)],
  [#nm-iterate-bisection(x0:-1.5,x1:1,return-all:true,accuracy:8)],
)

#pagebreak()
== nm-plot-integral
=== Types: Left, Right, Midpoint, Trapezium, Integral, 'asfsf'
Alternatively including 'points'
#grid(columns:3, inset:10pt,
plot-integral(size-x:3,size-y:2,method:"left",show-points:true), 
plot-integral(size-x:3,size-y:2,method:"right"),
plot-integral(size-x:3,size-y:2,method:"mid",show-points:true), 
plot-integral(size-x:3,size-y:2,method:"trapezium"),
plot-integral(size-x:3,size-y:2,method:"integral",show-points:true), 
plot-integral(size-x:3,size-y:2,method:"asfsf"), 
)
=== Limits: inc_x0, no x0
#grid(columns:3,inset:10pt,
plot-integral(size-x:3,size-y:2,method:"integral",x0:2,x1:3), 
plot-integral(size-x:3,size-y:2,method:"integral",x0:2,x1:3,inc-0:false),
)
=== Strips: 1, 2, 4, 8, 16, 32
#grid(columns:3, inset:10pt,
plot-integral(size-x:3,size-y:2,n-strips:1), 
plot-integral(size-x:3,size-y:2,n-strips:2), 
plot-integral(size-x:3,size-y:2,n-strips:4), 
plot-integral(size-x:3,size-y:2,n-strips:8), 
plot-integral(size-x:3,size-y:2,n-strips:16), 
plot-integral(size-x:3,size-y:2,n-strips:32)
)

#pagebreak()
== NM-Table
=== Integral Table
#grid(columns:3,inset: 5pt,
nm-table-integrate(),
nm-table-integrate(method:"Trapezium"),
nm-table-integrate(method:"Simpsons",n-rows:4)
)

=== Differential Table
#grid(columns:2,inset: 5pt,
nm-table-differentiate(),
nm-table-differentiate(method:"FD"),
)

=== Iteration Table
#grid(columns:2,inset: 5pt,
[FPI: #nm-table-iterate(method:"FPI",ratio-order:1)],
[RFPI: #nm-table-iterate(method:"RFPI",ratio-order:1)],
[NRaphson: #nm-table-iterate(method:"Newton-Raphson",ratio-order:2)],
[Secant: #nm-table-iterate(method:"Secant",ratio-order:1.6)]
)