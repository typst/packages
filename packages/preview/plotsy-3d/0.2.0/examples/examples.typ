#set page("a5", flipped:true, margin: (x:5pt, y:5pt))
#set text(size:14pt)
#import "@preview/plotsy-3d:0.2.0"


#let xfunc(u,v) = u*calc.sin(v) 
#let yfunc(u,v) = u*calc.cos(v) 
#let zfunc(u,v) = u
#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return purple.transparentize(20%).lighten((z/(z-hi - z-lo)) * 80%)

}
#let scale-factor = 0.25
#let (xscale,yscale,zscale) = (0.3,0.2,0.3)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  

== Parametric Surface
$ x(u,v) = u sin(v), space y(u,v)= u cos(v), space z(u,v)= u $
#figure(
  plot-3d-parametric-surface(
    xfunc,
    yfunc,
    zfunc,
    xaxis: (-5,5),
    yaxis: (-5,5),
    zaxis: (0,5),
    color-func: color-func,
    subdivisions:5,
    scale-dim: scale-dim,
    udomain:(0, calc.pi+1),
    vdomain:(0, 2*calc.pi+1),
    axis-step: (5,5,5),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.04, 0.04),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    xyz-colors: (red,green,blue),
  )
)

#pagebreak()

#let xfunc(u,v) = 6*calc.cos(u) * calc.sin(v)
#let yfunc(u,v) = 6*calc.sin(u) * calc.sin(v)
#let zfunc(u,v) = 6*calc.cos(v)
#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return green.transparentize(20%).darken((z/(z-hi - z-lo)) * 175%)
}

#let scale-factor = 0.12
#let (xscale,yscale,zscale) = (0.3,0.3,0.3)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  

== Parametric Surface
$ x(u,v) = 6 cos(u) sin(v), space y(u,v)= 6 sin(u) sin(v), space z(u,v)= 6 cos(v) $
#figure(
  plot-3d-parametric-surface(
    xfunc,
    yfunc,
    zfunc,
    color-func: color-func,
    render-order: 7,
    subdivisions:10,
    scale-dim: scale-dim,
    udomain:(1*calc.pi, 3*calc.pi+1),
    vdomain:(0, calc.pi+1),
    axis-step: (5,5,5),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.04, 0.04),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
   // rotation-matrix: ((1,0,0), (-1,1,1)),
    axis-label-size: 1.5em,
    xyz-colors: (black, black, black),
  )
)

#pagebreak()

== 3D Surface 
$ z=y sin(x) - x cos(y) $

#let size = 5
#let scale-factor = 0.3
#let (xscale,yscale,zscale) = (0.3,0.3,0.05)

#let func(x,y) = y*calc.sin(x) -x*calc.cos(y) 
#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return purple.transparentize(20%).darken((z/(z-hi - z-lo)) * 300%)
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 5,
    subdivision-mode: "increase",
    scale-dim: (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor),
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad-high: (0,0,2),
    pad-low: (0,0,0),
    axis-label-offset: (0.2,0.1,0.1),
    axis-text-offset: 0.045,
    xyz-colors: (red,green,blue),
  )
)

#pagebreak()


== 3D Surface
$ z= x^2 + y^2 $
#let size = 10
#let scale-factor = 0.11
#let (xscale,yscale,zscale) = (0.3,0.3,0.02)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  
#let func(x,y) = x*x + y*y
#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return blue.transparentize(20%).darken((y/(y-hi - y-lo))*100%).lighten((x/(x-hi - x-lo)) * 50%)
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 2,
    subdivision-mode: "decrease",
    scale-dim: scale-dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad-high: (0,0,0),
    pad-low: (0,0,5),
    axis-step: (3,3,75),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.05,0.05),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    axis-labels: ($x$, $y$, $x^2 + y^2$),
    xyz-colors: (red,green,blue),
  )
)
#let size = 10
#let scale-factor = 0.09
#let (xscale,yscale,zscale) = (0.3,0.3,0.05)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  
#let func(x,y) = x*x

#pagebreak()

== 3D Vector Field
$ arrow(p)(x,y,z) = (x+0.5) hat(i) + (y+0.5) hat(j) + (z+1) hat(k) $

#let size = 10
#let scale-factor = 0.12
#let (xscale,yscale,zscale) = (0.3,0.3,0.3)

#let i-func(x,y,z) = x + 0.5
#let j-func(x,y,z) = y + 0.5
#let k-func(x,y,z) = z + 1


#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return purple.darken(z/(z-hi - z-lo) * 100%).transparentize(0%)  
}

#figure(
  plot-3d-vector-field(
    i-func,
    j-func,
    k-func,
    color-func: color-func,
    subdivisions: 3,
    subdivision-mode: "decrease",
    scale-dim: (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor),
    xdomain: (-size,size),
    ydomain:  (-size,size),
    zdomain: (0,size),
    // pad-high: (0,0,2),
    rotation-matrix: ((-1.5, 1.2, 4), (0, -1, 0)),
    axis-label-offset: (0.4,0.2,0.2),
    axis-text-offset: 0.08,
    vector-size: 0.1em,
    xyz-colors: (red,green,blue),
  )
)

#pagebreak()
== Parametric Curve
$ x(t) = 15 cos(t), space y(t)= sin(t), space z(t)= t $

#let xfunc(t) = 15*calc.cos(t)
#let yfunc(t) = calc.sin(t)
#let zfunc(t) = t

#let size = 5

#figure(
  plot-3d-parametric-curve(
    xfunc,
    yfunc,
    zfunc,
    subdivisions:30,
    scale-dim: (0.03,0.045,0.045),
    tdomain:(0,10),
    axis-step: (5,5,5),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.04, 0.04),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    rotation-matrix: ((-2, 2, 4), (0, -1, 0)),
    xyz-colors: (red,green,blue),
  )
)
#pagebreak()


== 3D Surface
$ z= x^2 $
#let size = 10
#let scale-factor = 0.10
#let (xscale,yscale,zscale) = (0.3,0.3,0.03)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  

#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return olive.transparentize(20%).darken(10%).lighten((z/(z-lo - z-hi)) * 100%) 
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 1,
    subdivision-mode: "increase",
    scale-dim: scale-dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad-high: (0,0,0),
    pad-low: (0,0,5),
    axis-step: (3,3,75),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.05,0.05),
    rear-axis-dot-scale: (0.08,0.2),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    xyz-colors: (red,green,blue),
  )
)
#pagebreak()
== 3D Surface
$ z= x^2 $

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    scale-dim: scale-dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad-high: (0,0,10),
    pad-low: (0,0,0),
    axis-step: (3,3,10),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.05,0.05),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    rotation-matrix: ((1,0,0), (-1,1,1)),
    axis-label-offset: (0.3,0.2,0.4),
    axis-text-offset: 0.075,
    xyz-colors: (red,green,blue),
  )
)
#pagebreak()
== 3D Surface
$ z = - e^x + 20 cos(y) $
#let size = 5
#let scale-factor = 0.32
#let (xscale,yscale,zscale) = (0.3,0.3,0.005)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  
#let func(x,y) = -calc.exp(x) + 20*calc.cos(y)

#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return teal.transparentize(20%).darken(50%).lighten((z/(z-lo - z-hi)) * 90%)
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 2,
    subdivision-mode: "increase",
    scale-dim: scale-dim,
    xdomain: (1,size),
    ydomain:  (-size,size),
    pad-high: (0,0,24),
    pad-low: (0,0,5),
    axis-step: (3,3,20),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.05,0.05),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    axis-text-offset: 0.04,
    axis-label-offset: (0.1,0.1,0.1),
    xyz-colors: (red,green,blue),
  )
)

#pagebreak()
== 3D Surface
$ z = 10x $

#let size = 10
#let scale-factor = 0.15
#let (xscale,yscale,zscale) = (0.3,0.3,0.005)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  
#let func(x,y) = 10*x 

#figure(
  plot-3d-surface(
    func,
    subdivisions: 1,
    subdivision-mode: "increase",
    scale-dim: scale-dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad-high: (0,0,0),
    pad-low: (0,0,5),
    axis-step: (3,3,75),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.05,0.05),
    rear-axis-dot-scale: (0.08,0.08),
    rear-axis-text-size: 0.5em,
    axis-label-size: 1.5em,
    xyz-colors: (red,green,blue),
  )
)


