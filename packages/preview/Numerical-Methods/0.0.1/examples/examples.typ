#import "NumMeth.typ" : *
#set page(margin: (top:2cm,x:1cm,bottom:1cm))
== NM-Integrate
#table(columns:5,inset:8pt,
table.header([Target],$n$,[\#Midpoint],[\#Trapezium],[\#Simpsons]),
table.cell(rowspan:4,[$pi approx $ #calc.round(calc.pi,digits:8)]),
[1],[#NM-Integrate-Midpoint(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:1,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:1,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:1,accuracy:6)],
[2],[#NM-Integrate-Midpoint(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:2,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:2,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:2,accuracy:6)],
[4],[#NM-Integrate-Midpoint(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:4,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:4,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:4,accuracy:6)],
[8],[#NM-Integrate-Midpoint(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:8,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:8,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>4 / (1 + x*x),start-x:0,end-x:1,n:8,accuracy:6)],
table.cell(rowspan:4,[$ln 2 approx $#calc.round(calc.ln(2),digits:8)]),
[1],[#NM-Integrate-Midpoint(f_x:x=>1/x,start-x:1,end-x:2,n:1,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>1/x,start-x:1,end-x:2,n:1,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>1/x,start-x:1,end-x:2,n:1,accuracy:6)],
[2],[#NM-Integrate-Midpoint(f_x:x=>1/x,start-x:1,end-x:2,n:2,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>1/x,start-x:1,end-x:2,n:2,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>1/x,start-x:1,end-x:2,n:2,accuracy:6)],
[4],[#NM-Integrate-Midpoint(f_x:x=>1/x,start-x:1,end-x:2,n:4,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>1/x,start-x:1,end-x:2,n:4,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>1/x,start-x:1,end-x:2,n:4,accuracy:6)],
[8],[#NM-Integrate-Midpoint(f_x:x=>1/x,start-x:1,end-x:2,n:8,accuracy:6)],
  [#NM-Integrate-Trapezium(f_x:x=>1/x,start-x:1,end-x:2,n:8,accuracy:6)],
  [#NM-Integrate-Simpsons(f_x:x=>1/x,start-x:1,end-x:2,n:8,accuracy:6)])

== NM-Differentiate
#table(columns:4,inset:8pt,
table.header([Target],$h$,[\#Forward],[\#Central]),
table.cell(rowspan:3,[$f(x)=cos x, quad f`(pi/2)=-1$]),
$1$,[#NM-Differentiate-Forward(f_x:x=>calc.cos(x),x0:calc.pi/2,h:1,accuracy:6)],
      [#NM-Differentiate-Central(f_x:x=>calc.cos(x),x0:calc.pi/2,h:1,accuracy:6)],
$0.1$,[#NM-Differentiate-Forward(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.1,accuracy:6)],
      [#NM-Differentiate-Central(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.1,accuracy:6)],
$0.01$,[#NM-Differentiate-Forward(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.01,accuracy:6)],
      [#NM-Differentiate-Central(f_x:x=>calc.cos(x),x0:calc.pi/2,h:0.01,accuracy:6)],
table.cell(rowspan:3,[$f(x)=1/(1+ln x),quad f`(2) approx -0.174414$]),
$1$,[#NM-Differentiate-Forward(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:1,accuracy:6)],
  [#NM-Differentiate-Central(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:1,accuracy:6)],
$0.1$,[#NM-Differentiate-Forward(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.1,accuracy:6)],
  [#NM-Differentiate-Central(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.1,accuracy:6)],
$0.01$,[#NM-Differentiate-Forward(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.01,accuracy:6)],
  [#NM-Differentiate-Central(f_x:x=>1 / (1 + calc.ln(x)),x0:2,h:0.01,accuracy:6)])

#pagebreak()
== NM-Iterate
=== FPI
#table(columns:4, inset:8pt,
table.header([Target],[\#Fixed],[\#Relaxed $lambda=0.5$],[\#Relaxed $lambda=1.4$]),
[$g(x)=2sin x + 2 cos x \ x approx -2.68075641016$],
  [#NM-Iterate-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,nMax:8)],
  [#NM-Iterate-RelaxedFPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,nMax:8,lambda:0.5)],
  [#NM-Iterate-RelaxedFPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,nMax:8,lambda:1.4)])
All Values:
#let FPI = NM-Iterate-FPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,nMax:5,return-all:true)
#let RFPI1 = NM-Iterate-RelaxedFPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,nMax:5,lambda:0.5,return-all:true)
#let RFPI2 = NM-Iterate-RelaxedFPI(g_x:x=>2 * calc.sin(x) + 2 * calc.cos(x),accuracy:6,x0:-1.5,nMax:5,lambda:1.4,return-all:true)

#let tableRows = ()
#for i in range(FPI.len()) {
  tableRows.push([#i])
  tableRows.push([#FPI.at(i)])
  tableRows.push([#RFPI1.at(i)])
  tableRows.push([#RFPI2.at(i)])
}

  #table(columns:4,inset:5pt,
  table.header($n$,[FPI $x_n$],[RFPI,$lambda=0.5$],[RFPI,$lambda=1.4$],
  ..tableRows
  )
)
=== Newton-Raphson
#table(columns:2,inset:8pt,
table.header([Target],[\#NRaphson]),
[$f(x)=e^x-x-2 \ f(1.14619) approx 0 \ f(-1.84141) approx 9$],
[#NM-Iterate-NRaphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:1,accuracy:6) \ \
  #NM-Iterate-NRaphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:-1,accuracy:6)])
All Values:
#let NR1 = NM-Iterate-NRaphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:1,accuracy:6,return-all:true)
#let NR2 = NM-Iterate-NRaphson(f_x:x=>calc.pow(calc.e,x) - x - 2,x0:-1,accuracy:6,return-all:true)
#let tableRows = ()
#for i in range(NR1.len()) {
  tableRows.push([#i])
  tableRows.push([#NR1.at(i)])
  tableRows.push([#NR2.at(i)])
}
#table(columns:3,inset:5pt,
table.header([$n$],[NR:$x_0 = 1$],[NR:$x_0 = -1$]),
..tableRows
)

=== Secant, False Position, Bisection for $sin(x)=0$
#table(columns:(0.2fr,1fr,1fr,1fr),inset:5pt,
table.header($x$,[Secant],[False Position],[Bisection]),
text(size:8pt)[$[-1,1]$],
  [#NM-Iterate-Secant(x0:-1,x1:1,return-all:true,accuracy:8)],
  [#NM-Iterate-FalsePosition(x0:-1,x1:1,return-all:true,accuracy:8)],
  [#NM-Iterate-Bisection(x0:-1,x1:1,return-all:true,accuracy:8)],
text(size:8pt)[$[0.5,1]$],
[#NM-Iterate-Secant(x0:0.5,x1:1,return-all:true,accuracy:8)],
  [#NM-Iterate-FalsePosition(x0:0.5,x1:1,return-all:true,accuracy:8)],
  [#NM-Iterate-Bisection(x0:0.5,x1:1,return-all:true,accuracy:8)],
text(size:8pt)[$[-1.5,1]$],
  [#NM-Iterate-Secant(x0:-1.5,x1:1,return-all:true,accuracy:8)],
  [#NM-Iterate-FalsePosition(x0:-1.5,x1:1,return-all:true,accuracy:8)],
  [#NM-Iterate-Bisection(x0:-1.5,x1:1,return-all:true,accuracy:8)],
)

#pagebreak()
== NM-PlotIntegral
=== Types: Left, Right, Midpoint, Trapezium, Integral, 'asfsf'
Alternatively including 'points'
#grid(columns:3, inset:10pt,
PlotIntegral(size_x:3,size_y:2,method:"left",includePoints:true), 
PlotIntegral(size_x:3,size_y:2,method:"right"),
PlotIntegral(size_x:3,size_y:2,method:"mid",includePoints:true), 
PlotIntegral(size_x:3,size_y:2,method:"trapezium"),
PlotIntegral(size_x:3,size_y:2,method:"integral",includePoints:true), 
PlotIntegral(size_x:3,size_y:2,method:"asfsf"), 
)
=== Limits: inc_x0, no x0
#grid(columns:3,inset:10pt,
PlotIntegral(size_x:3,size_y:2,method:"integral",start-x:2,end-x:3), 
PlotIntegral(size_x:3,size_y:2,method:"integral",start-x:2,end-x:3,inc_x0:false),
)
=== Strips: 1, 2, 4, 8, 16, 32
#grid(columns:3, inset:10pt,
PlotIntegral(size_x:3,size_y:2,n-strips:1), 
PlotIntegral(size_x:3,size_y:2,n-strips:2), 
PlotIntegral(size_x:3,size_y:2,n-strips:4), 
PlotIntegral(size_x:3,size_y:2,n-strips:8), 
PlotIntegral(size_x:3,size_y:2,n-strips:16), 
PlotIntegral(size_x:3,size_y:2,n-strips:32)
)

#pagebreak()
== NM-Table
=== Integral Table
#grid(columns:3,inset: 5pt,
NM-Table-Integrate(),
NM-Table-Integrate(method:"Trapezium"),
NM-Table-Integrate(method:"Simpsons",n-rows:4)
)

=== Differential Table
#grid(columns:2,inset: 5pt,
NM-Table-Differentiate(),
NM-Table-Differentiate(method:"FD"),
)

=== Iteration Table
#grid(columns:2,inset: 5pt,
[FPI: #NM-Table-Iterate(method:"FPI",ratio-order:1)],
[RFPI: #NM-Table-Iterate(method:"RFPI",ratio-order:1)],
[NRaphson: #NM-Table-Iterate(method:"Newton-Raphson",ratio-order:2)],
[Secant: #NM-Table-Iterate(method:"Secant",ratio-order:1.6)]
)