#set page("a5", flipped:true, margin: (x:5pt, y:5pt))
#set text(size:14pt)
#import "../plotsy-3d.typ": *


#let xfunc(u,v) = u*calc.sin(v) 
#let yfunc(u,v) = u*calc.cos(v) 
#let zfunc(u,v) = u
#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return purple.transparentize(20%).lighten((z/(z_hi - z_lo)) * 80%)

}
#let scale_factor = 0.25
#let (xscale,yscale,zscale) = (0.3,0.2,0.3)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  

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
    scale_dim: scale_dim,
    udomain:(0, calc.pi+1),
    vdomain:(0, 2*calc.pi+1),
    axis_step: (5,5,5),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.04, 0.04),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
  )
)

#pagebreak()

#let xfunc(u,v) = 6*calc.cos(u) * calc.sin(v)
#let yfunc(u,v) = 6*calc.sin(u) * calc.sin(v)
#let zfunc(u,v) = 6*calc.cos(v)
#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return green.transparentize(20%).darken((z/(z_hi - z_lo)) * 175%)
}

#let scale_factor = 0.12
#let (xscale,yscale,zscale) = (0.3,0.3,0.3)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  

== Parametric Surface
$ x(u,v) = 6 cos(u) sin(v), space y(u,v)= 6 sin(u) sin(v), space z(u,v)= 6 cos(v) $
#figure(
  plot-3d-parametric-surface(
    xfunc,
    yfunc,
    zfunc,
    color-func: color-func,
    render_order: 7,
    subdivisions:10,
    scale_dim: scale_dim,
    udomain:(1*calc.pi, 3*calc.pi+1),
    vdomain:(0, calc.pi+1),
    axis_step: (5,5,5),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.04, 0.04),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
   // rotation_matrix: ((1,0,0), (-1,1,1)),
    axis_label_size: 1.5em,
  )
)

#pagebreak()

== 3D Surface 
$ z=y sin(x) - x cos(y) $

#let size = 5
#let scale_factor = 0.3
#let (xscale,yscale,zscale) = (0.3,0.3,0.05)

#let func(x,y) = y*calc.sin(x) -x*calc.cos(y) 
#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return purple.transparentize(20%).darken((z/(z_hi - z_lo)) * 300%)
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 5,
    subdivision_mode: "increase",
    scale_dim: (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor),
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad_high: (0,0,2),
    pad_low: (0,0,0),
    axis_label_offset: (0.2,0.1,0.1),
    axis_text_offset: 0.045,
  )
)

#pagebreak()


== 3D Surface
$ z= x^2 + y^2 $
#let size = 10
#let scale_factor = 0.11
#let (xscale,yscale,zscale) = (0.3,0.3,0.02)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  
#let func(x,y) = x*x + y*y
#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return blue.transparentize(20%).darken((y/(y_hi - y_lo))*100%).lighten((x/(x_hi - x_lo)) * 50%)
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 2,
    subdivision_mode: "decrease",
    scale_dim: scale_dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad_high: (0,0,0),
    pad_low: (0,0,5),
    axis_step: (3,3,75),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.05,0.05),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
  )
)
#let size = 10
#let scale_factor = 0.09
#let (xscale,yscale,zscale) = (0.3,0.3,0.05)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  
#let func(x,y) = x*x

#pagebreak()

== 3D Vector Field
$ arrow(p)(x,y,z) = (x+0.5) hat(i) + (y+0.5) hat(j) + (z+1) hat(k) $

#let size = 10
#let scale_factor = 0.12
#let (xscale,yscale,zscale) = (0.3,0.3,0.3)

#let i_func(x,y,z) = x + 0.5
#let j_func(x,y,z) = y + 0.5
#let k_func(x,y,z) = z + 1


#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return purple.darken(z/(z_hi - z_lo) * 100%) 
}

#figure(
  plot-3d-vector-field(
    i_func,
    j_func,
    k_func,
    color-func: color-func,
    subdivisions: 3,
    subdivision_mode: "decrease",
    scale_dim: (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor),
    xdomain: (-size,size),
    ydomain:  (-size,size),
    zdomain: (0,size),
    // pad_high: (0,0,2),
    rotation_matrix: ((-1.5, 1.2, 4), (0, -1, 0)),
    axis_label_offset: (0.4,0.2,0.2),
    axis_text_offset: 0.08,
    vector_size: 0.1em,
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
    scale_dim: (0.03,0.05,0.05),
    tdomain:(0,10),
    axis_step: (5,5,5),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.04, 0.04),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
    rotation_matrix: ((-2, 2, 4), (0, -1, 0)) 
  )
)
#pagebreak()


== 3D Surface
$ z= x^2 $
#let size = 10
#let scale_factor = 0.10
#let (xscale,yscale,zscale) = (0.3,0.3,0.03)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  

#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return olive.transparentize(20%).darken(10%).lighten((z/(z_lo - z_hi)) * 100%) 
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 1,
    subdivision_mode: "increase",
    scale_dim: scale_dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad_high: (0,0,0),
    pad_low: (0,0,5),
    axis_step: (3,3,75),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.05,0.05),
    rear_axis_dot_scale: (0.08,0.2),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
  )
)
#pagebreak()
== 3D Surface
$ z= x^2 $

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    scale_dim: scale_dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad_high: (0,0,10),
    pad_low: (0,0,0),
    axis_step: (3,3,10),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.05,0.05),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
    rotation_matrix: ((1,0,0), (-1,1,1)),
    axis_label_offset: (0.3,0.2,0.4),
    axis_text_offset: 0.075,
  )
)
#pagebreak()
== 3D Surface
$ z = - e^x + 20 cos(y) $
#let size = 5
#let scale_factor = 0.32
#let (xscale,yscale,zscale) = (0.3,0.3,0.005)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  
#let func(x,y) = -calc.exp(x) + 20*calc.cos(y)

#let color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return teal.transparentize(20%).darken(50%).lighten((z/(z_lo - z_hi)) * 90%)
}

#figure(
  plot-3d-surface(
    func,
    color-func: color-func,
    subdivisions: 2,
    subdivision_mode: "increase",
    scale_dim: scale_dim,
    xdomain: (1,size),
    ydomain:  (-size,size),
    pad_high: (0,0,24),
    pad_low: (0,0,5),
    axis_step: (3,3,20),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.05,0.05),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
    axis_text_offset: 0.04,
    axis_label_offset: (0.1,0.1,0.1),
  )
)

#pagebreak()
== 3D Surface
$ z = 10x $

#let size = 10
#let scale_factor = 0.15
#let (xscale,yscale,zscale) = (0.3,0.3,0.005)
#let scale_dim = (xscale*scale_factor,yscale*scale_factor, zscale*scale_factor)  
#let func(x,y) = 10*x 

#figure(
  plot-3d-surface(
    func,
    subdivisions: 1,
    subdivision_mode: "increase",
    scale_dim: scale_dim,
    xdomain: (-size,size),
    ydomain:  (-size,size),
    pad_high: (0,0,0),
    pad_low: (0,0,5),
    axis_step: (3,3,75),
    dot_thickness: 0.05em,
    front_axis_thickness: 0.1em,
    front_axis_dot_scale: (0.05,0.05),
    rear_axis_dot_scale: (0.08,0.08),
    rear_axis_text_size: 0.5em,
    axis_label_size: 1.5em,
  )
)


