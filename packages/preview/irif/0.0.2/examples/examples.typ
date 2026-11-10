#import "irif.typ" : *
#set page(margin: (top:2cm,x:1cm,bottom:1cm))
== \#nm-integrate
#let test-params-1 = (f_x:x=>4 / (1 + x*x),x0:0,x1:1,accuracy:6)
#let test-params-2 = (f_x:x=>1/x,x0:1,x1:2,accuracy:6)
#table(columns:6,inset:8pt,
table.header([Target],$n$,[-midpoint],[-trapezium],[-simpsons], [-simpsons-38]),
table.cell(rowspan:4,[$pi approx $ #calc.round(calc.pi,digits:8)]),
[1],[#nm-integrate-midpoint(..test-params-1,n:1)],
  [#nm-integrate-trapezium(..test-params-1,n:1)],
  [#nm-integrate-simpsons(..test-params-1,n:1)],
  [#nm-integrate-simpsons-38(..test-params-1,n:1)],
[2],[#nm-integrate-midpoint(..test-params-1,n:2)],
  [#nm-integrate-trapezium(..test-params-1,n:2)],
  [#nm-integrate-simpsons(..test-params-1,n:2)],
  [#nm-integrate-simpsons-38(..test-params-1,n:2)],
[4],[#nm-integrate-midpoint(..test-params-1,n:4)],
  [#nm-integrate-trapezium(..test-params-1,n:4)],
  [#nm-integrate-simpsons(..test-params-1,n:4)],
  [#nm-integrate-simpsons-38(..test-params-1,n:4)],
[8],[#nm-integrate-midpoint(..test-params-1,n:8)],
  [#nm-integrate-trapezium(..test-params-1,n:8)],
  [#nm-integrate-simpsons(..test-params-1,n:8)],
  [#nm-integrate-simpsons-38(..test-params-1,n:8)],
table.cell(rowspan:4,[$ln 2 approx $#calc.round(calc.ln(2),digits:8)]),
[1],[#nm-integrate-midpoint(..test-params-2,n:1)],
  [#nm-integrate-trapezium(..test-params-2,n:1)],
  [#nm-integrate-simpsons(..test-params-2,n:1)],
  [#nm-integrate-simpsons-38(..test-params-2,n:1)],
[2],[#nm-integrate-midpoint(..test-params-2,n:2)],
  [#nm-integrate-trapezium(..test-params-2,n:2)],
  [#nm-integrate-simpsons(..test-params-2,n:2)],
  [#nm-integrate-simpsons-38(..test-params-2,n:2)],
[4],[#nm-integrate-midpoint(..test-params-2,n:4)],
  [#nm-integrate-trapezium(..test-params-2,n:4)],
  [#nm-integrate-simpsons(..test-params-2,n:4)],
  [#nm-integrate-simpsons-38(..test-params-2,n:4)],
[8],[#nm-integrate-midpoint(..test-params-2,n:8)],
  [#nm-integrate-trapezium(..test-params-2,n:8)],
  [#nm-integrate-simpsons(..test-params-2,n:8)],
  [#nm-integrate-simpsons-38(..test-params-2,n:8)],)

== \#nm-differentiate
#let test-params-cos = (f_x:x=>calc.cos(x),x0:calc.pi/2,accuracy:6)
#let test-params-ln = (f_x:x=>1 / (1 + calc.ln(x)),x0:2,accuracy:6)
#table(columns:4,inset:8pt,
table.header([Target],$h$,[-forward],[-central]),
table.cell(rowspan:3,[$f(x)=cos x, quad f`(pi/2)=-1$]),
$1$,[#nm-differentiate-forward(..test-params-cos, h:1)],
      [#nm-differentiate-central(..test-params-cos, h:1)],
$0.1$,[#nm-differentiate-forward(..test-params-cos, h:0.1)],
      [#nm-differentiate-central(..test-params-cos, h:0.1)],
$0.01$,[#nm-differentiate-forward(..test-params-cos, h:0.01)],
      [#nm-differentiate-central(..test-params-cos, h:0.01)],
table.cell(rowspan:3,[$f(x)=1/(1+ln x),quad f`(2) approx -0.174414$]),
$1$,[#nm-differentiate-forward(..test-params-ln, h:1)],
  [#nm-differentiate-central(..test-params-ln, h:1)],
$0.1$,[#nm-differentiate-forward(..test-params-ln, h:0.1)],
  [#nm-differentiate-central(..test-params-ln, h:0.1)],
$0.01$,[#nm-differentiate-forward(..test-params-ln, h:0.01)],
  [#nm-differentiate-central(..test-params-ln, h:0.01)])

#pagebreak()
== \#nm-iterate
=== -FPI and -relaxed-FPI
#let test-params-gx = (g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,n-max:8)
#table(columns:4, inset:8pt,
table.header([Target],[-FPI],[-relaxed-FPI $lambda=0.5$],[-relaxed-FPI $lambda=1.4$]),
[$g(x)=2sin x + 2 cos x \ x approx -2.68075641016$],
  [#nm-iterate-FPI(..test-params-gx)],
  [#nm-iterate-relaxed-FPI(..test-params-gx, lambda:0.5)],
  [#nm-iterate-relaxed-FPI(..test-params-gx, lambda:1.4)])
All Values:
#let FPI = nm-iterate-FPI(..test-params-gx,return-all:true)
#let RFPI1 = nm-iterate-relaxed-FPI(..test-params-gx, return-all:true, lambda:0.5)
#let RFPI2 = nm-iterate-relaxed-FPI(..test-params-gx, return-all:true)

#let table-rows = ()
#for i in range(FPI.len()) {
  table-rows.push([#i])
  table-rows.push([#FPI.at(i)])
  table-rows.push([#RFPI1.at(i)])
  table-rows.push([#RFPI2.at(i)])
}

  #table(columns:4,inset:5pt,
  table.header($n$,[-FPI $x_n$],[-relaxed-FPI, $lambda=0.5$],[-relaxed-FPI, $lambda=1.4$],
  ..table-rows
  )
)
=== -newton-raphson
#let test-params-nr = (f_x:x=>calc.pow(calc.e,x) - x - 2,accuracy:6)
#grid(columns:2,column-gutter: 20pt,[
  Finding Roots:
  #table(columns:2,inset:8pt,
table.header([Target],[-newton-raphson]),
[$f(x)=e^x-x-2 \ f(1.14619) approx 0 \ f(-1.84141) approx 9$],
[
  #nm-iterate-newton-raphson(..test-params-nr,x0:1) \ \
  #nm-iterate-newton-raphson(..test-params-nr,x0:-1)])
],
[
  All Values:
#let NR1 = nm-iterate-newton-raphson(..test-params-nr,x0:1, return-all: true)
#let NR2 = nm-iterate-newton-raphson(..test-params-nr,x0:-1, return-all: true)
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
]
)

=== -secant, -false-position, -bisection for $sin(x)=0$
#table(columns:(0.2fr,1fr,1fr,1fr),inset:5pt,
table.header($x$,[-secant],[-false-position],[-bisection]),
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
Alternatively including 'points'
#grid(columns:4, inset:10pt,
["left": #plot-integral(size-x:3,size-y:2,method:"left",show-points:true)], 
["right": #plot-integral(size-x:3,size-y:2,method:"right")],
["mid": #plot-integral(size-x:3,size-y:2,method:"mid",show-points:true)], 
["trapezium": #plot-integral(size-x:3,size-y:2,method:"trapezium")],
["integral":#plot-integral(size-x:3,size-y:2,method:"integral",show-points:true)],
["asfsf":#plot-integral(size-x:3,size-y:2,method:"asfsf")],  
["simpsons":#plot-integral(size-x:3,size-y:2,method:"simpsons",n-strips:2,show-points:true)],
["simpsons-38":#plot-integral(size-x:3,size-y:2,method:"simpsons-38",n-strips:2)]
)

=== Limits: inc-0: true, inc-0: false
#grid(columns:3,inset:10pt,
plot-integral(size-x:3,size-y:2,method:"integral",x0:2,x1:3), 
plot-integral(size-x:3,size-y:2,method:"integral",x0:2,x1:3,inc-0:false),
)
=== n-strips: 1, 2, 4, 8, 16, 32
#grid(columns:3, inset:10pt,
..range(6).map(n=>
plot-integral(size-x:3,size-y:2,n-strips:calc.pow(2,n)))
)

#pagebreak()
== \#nm-table
=== Integral Table, -integrate
#grid(columns:3,inset: 5pt,
[method: "Midpoint" #nm-table-integrate()],
[method: "Trapezium" #nm-table-integrate(method:"Trapezium")],
[method: Simpsons" #nm-table-integrate(method:"Simpsons",n-rows:4)],
[method: "Simpsons-38" #nm-table-integrate(method:"Simpsons-38")]
)

=== Differential Table, -differentiate
#grid(columns:2,inset: 5pt,
[method:"CD" #nm-table-differentiate()],
[method:"FD" #nm-table-differentiate(method:"FD")],
)

=== Iteration Table, -iterate
#grid(columns:2,inset: 5pt,
[method: "FPI" #nm-table-iterate(method:"FPI",ratio-order:1)],
[method: "RFPI" #nm-table-iterate(method:"RFPI",ratio-order:1)],
[method: "Newton-Raphson" #nm-table-iterate(method:"Newton-Raphson",ratio-order:2)],
[method: "Secant" #nm-table-iterate(method:"Secant",ratio-order:1.6)]
)