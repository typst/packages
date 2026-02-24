# The `plotsy-3d` Package
<div align="center">Version 0.2.0</div>


**plotsy-3d** is a [Typst](https://github.com/typst/typst) package for rendering 3D objects built on top of [CeTZ](https://github.com/cetz-package/cetz). Similar functionality to pgfplots for LaTeX but currently less developed.


<p>
    <img src="examples/examples1.png" style="width:49%" >
    <img src="examples/examples2.png" style="width:49%"  >
</p>

<p>
    <img src="examples/examples3.png" style="width:49%" >
    <img src="examples/examples4.png" style="width:49%"  >
</p>

<p>
    <img src="examples/examples5.png" style="width:49%" >
    <img src="examples/examples6.png" style="width:49%"  >
</p>

## Features:

* 3D Function plotting of the form  `z = f(x,y)`
* Parametric curve plotting of the form `x(t), y(t), z(t)`
* Parametric surface plotting of the form `x(u,v), y(u,v), z(u,v)`
* Plots autoscale with font size for consistent style

See **Usage** or [`examples/examples.typ`](examples/examples.typ) for the code

## Future Plans (contributors welcome):
- [ ] Nicer way to draw vectors
- [ ] Better way to handle render order
- [ ] Function to generate 2D plots for XZ XY YZ projections of any 3d render
- [ ] User Manual
- [ ] Make the code and api nicer

## Usage

### Parametric Function Plotting
```typ
#import "@preview/plotsy-3d:0.2.0": plot-3d-parametric-curve

#let xfunc(t) = 15*calc.cos(t)
#let yfunc(t) = calc.sin(t)
#let zfunc(t) = t

== Parametric Curve
$ x(t) = 15 cos(t), space y(t)= sin(t), space z(t)= t $
#plot-3d-parametric-curve(
  xfunc,
  yfunc,
  zfunc,
  subdivisions:30, //number of line segments per unit
  scale-dim: (0.03,0.05,0.05), // relative and global scaling
  tdomain:(0,10), 
  axis-step: (5,5,5), // adjust distance between x, y, z number labels
  dot-thickness: 0.05em, 
  front-axis-thickness: 0.1em,
  front-axis-dot-scale: (0.04, 0.04),
  rear-axis-dot-scale: (0.08,0.08),
  rear-axis-text-size: 0.5em,
  axis-label-size: 1.5em,
  rotation-matrix: ((-2, 2, 4), (0, -1, 0)) // matrix.transform-rotate-dir() from cetz
  xyz-colors: (red,green,blue),
)
```

### 3D Surface Plotting
```typ
#import "@preview/plotsy-3d:0.2.0": plot-3d-surface

#let size = 10
#let scale-factor = 0.11
#let (xscale,yscale,zscale) = (0.3,0.3,0.02)
#let scale-dim = (xscale*scale-factor,yscale*scale-factor, zscale*scale-factor)  
#let func(x,y) = x*x + y*y
#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return blue.transparentize(20%).darken((y/(y-hi - y-lo))*100%).lighten((x/(x-hi - x-lo)) * 50%)
}

== 3D Surface
$ z= x^2 + y^2 $
#plot-3d-surface(
  func,
  color-func: color-func,
  subdivisions: 2,
  subdivision-mode: "decrease",
  scale-dim: scale-dim,
  xdomain: (-size,size),
  ydomain:  (-size,size),
  pad-high: (0,0,0), // padding around the domain with no function displayed
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
```

### Parametric Surface Plotting
```typ
#import "@preview/plotsy-3d:0.2.0": plot-3d-parametric-surface

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
#plot-3d-parametric-surface(
  xfunc,
  yfunc,
  zfunc,
  xaxis: (-5,5), // set the minimum axis size, scales with function if needed
  yaxis: (-5,5),
  zaxis: (0,5),
  color-func: color-func,
  subdivisions:5, 
  scale-dim: scale-dim,
  udomain:(0, calc.pi+1), // note this gets truncated to an integer
  vdomain:(0, 2*calc.pi+1), // note this gets truncated to an integer
  axis-step: (5,5,5),
  dot-thickness: 0.05em,
  front-axis-thickness: 0.1em,
  front-axis-dot-scale: (0.04, 0.04),
  rear-axis-dot-scale: (0.08,0.08),
  rear-axis-text-size: 0.5em,
  axis-label-size: 1.5em,
  xyz-colors: (red,green,blue),
)
```

### Vector Field Plotting
```typ
#import "@preview/plotsy-3d:0.2.0": plot-3d-vector-field

#let size = 10
#let scale-factor = 0.12
#let (xscale,yscale,zscale) = (0.3,0.3,0.3)
#let i-func(x,y,z) = x + 0.5
#let j-func(x,y,z) = y + 0.5
#let k-func(x,y,z) = z + 1
#let color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return purple.darken(z/(z-hi - z-lo) * 100%) 
}

== 3D Vector Field
$ arrow(p)(x,y,z) = (x+0.5) hat(i) + (y+0.5) hat(j) + (z+1) hat(k) $
#plot-3d-vector-field(
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
```

## Plotting Function Default Parameters
```typ
plot-3d-vector-field(
  i-func,
  j-func,
  k-func,
  color-func: default-color-func,
  subdivisions:1,
  subdivision-mode: "increase",
  scale-dim: (1,1,0.5),
  xdomain:(0,10),
  ydomain:(0,10),
  zdomain:(0,10),
  axis-step: (5,5,5),
  dot-thickness: 0.05em,
  front-axis-thickness: 0.1em,
  front-axis-dot-scale: (0.05, 0.05),
  rear-axis-dot-scale: (0.08,0.08),
  rear-axis-text-size: 0.5em,
  axis-labels: ($x$, $y$, $z$),
  axis-label-size: 1.5em,
  axis-label-offset: (0.3,0.2,0.15),
  axis-text-offset: 0.075,
  rotation-matrix: ((-2, 2, 4), (0, -1, 0)),
  vector-size: 0.02em,
  xyz-colors: (red, green, blue),
)
```

```typ
plot-3d-parametric-surface(
  x-func,
  y-func,
  z-func,
  color-func: default-color-func,
  subdivisions:1,
  render-order: 0,
  scale-dim: (1,1,0.5),
  udomain:(0,1),
  vdomain:(0,1),
  xaxis:(0,10),
  yaxis:(0,10),
  zaxis:(0,10),
  axis-step: (5,5,5),
  dot-thickness: 0.05em,
  front-axis-thickness: 0.1em,
  front-axis-dot-scale: (0.05, 0.05),
  rear-axis-dot-scale: (0.08,0.08),
  rear-axis-text-size: 0.5em,
  axis-labels: ($x$, $y$, $z$),
  axis-label-size: 1.5em,
  axis-label-offset: (0.3,0.2,0.15),
  axis-text-offset: 0.075,
  rotation-matrix: ((-2, 2, 4), (0, -1, 0)),
  xyz-colors: (red,green,blue),
)
```

```typ
plot-3d-parametric-curve(
  x-func,
  y-func,
  z-func,
  color-func: default-line-color-func,
  subdivisions:1,
  scale-dim: (1,1,0.5),
  tdomain:(0,1),
  xaxis:(0,10),
  yaxis:(0,10),
  zaxis:(0,10),
  axis-step: (5,5,5),
  dot-thickness: 0.05em,
  front-axis-thickness: 0.1em,
  front-axis-dot-scale: (0.05, 0.05),
  rear-axis-dot-scale: (0.08,0.08),
  rear-axis-text-size: 0.5em,
  axis-labels: ($x$, $y$, $z$),
  axis-label-size: 1.5em,
  axis-label-offset: (0.3,0.2,0.15),
  axis-text-offset: 0.075,
  rotation-matrix: ((-2, 2, 4), (0, -1, 0)),
  xyz-colors: (red,green,blue),
)
```

```typ
plot-3d-surface(
  func,
  func2: none,
  color-func: default-color-func,
  subdivision-mode: "increase",
  subdivisions: 1,
  scale-dim: (1,1,0.5),
  xdomain:(0,10),
  ydomain: (0,10),
  pad-high: (0,0,0),
  pad-low: (0,0,0),
  axis-step: (5,5,5),
  dot-thickness: 0.05em,
  front-axis-thickness: 0.1em,
  front-axis-dot-scale: (0.5, 1),
  rear-axis-dot-scale: (0.08,0.08),
  rear-axis-text-size: 0.5em,
  axis-labels: ($x$, $y$, $z$),
  axis-label-size: 1.5em,
  axis-label-offset: (0.3,0.2,0.15),
  axis-text-offset: 0.075,
  rotation-matrix: ((-2, 2, 4), (0, -1, 0)),
  xyz-colors: (red,green,blue)
)
```


### Custom Plotting
For custom combinations of plots and lines, you can make a copy of the relevant plot function from `plotsy-3d.typ` and add multiple plots onto the same axis in the same cetz canvas using the backend render functions.

## More Examples

<!-- <p>
    <img src="examples/examples5.png" style="width:49%" >
    <img src="examples/examples6.png" style="width:49%"  >
</p> -->

<p>
    <img src="examples/examples7.png" style="width:49%" >
    <img src="examples/examples8.png" style="width:49%"  >
</p>

<p>
    <img src="examples/examples9.png" style="width:49%" >

</p>

## Build Examples
From project root:
`typst compile examples/examples.typ --root .`
`typst compile examples/examples.typ --root . examples/examples{p}.png`


## Star History

<a href="https://star-history.com/#misskacie/plotsy-3d&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=misskacie/plotsy-3d&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=misskacie/plotsy-3d&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=misskacie/plotsy-3d&type=Date" />
 </picture>
</a>

## Changelog

### V0.2.0
* Changed all code to use kebab-case
* Fixed missing parameters from functions 
### V0.1.0
* 3D Function plotting of the form z = f(x,y)
* 3D Parametric curve plotting of the form x(t), y(t), z(t)
* 3D Parametric function plotting of the form x(u,v), y(u,v), z(u,v)
* 3D Vector Field Plotting of the form r(x,y,z) = (x) i + (y) j + (z) k

