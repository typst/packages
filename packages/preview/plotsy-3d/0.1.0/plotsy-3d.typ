// plotsy-3d
// Author: misskacie
// License: LGPL-3.0-or-later
#import "@preview/cetz:0.3.1": canvas, draw, matrix

#let render-rear-axis(
  axis_low:(0,0,0),
  axis_high: (10,10,10),
  axis_step:(5,5,5),
  axis_dot_scale: (0.08,0.08),
  dot_thickness:0.05em,
  axis_text_size: 1em,
  axis_text_offset: 0.07,
  ) = {
    import draw: *
    let (xaxis_low,yaxis_low,zaxis_low) = axis_low
    let (xaxis_high,yaxis_high,zaxis_high) = axis_high
    let (xaxis_step,yaxis_step,zaxis_step) = axis_step

    let xaxis_stroke = (paint:black, dash: (axis_dot_scale.at(0) *1em, axis_dot_scale.at(1) *1em))
    let yaxis_stroke = (paint:black, dash: (axis_dot_scale.at(0) *1em, axis_dot_scale.at(1) *1em))
    let zaxis_stroke = (paint:black, dash: (axis_dot_scale.at(0) *1em, axis_dot_scale.at(1) *1em))

    set-style(
      stroke:(thickness: dot_thickness)
    )
    let text_offset = axis_text_offset * text.size.pt()

    for xoffset in range(xaxis_high - xaxis_low, step:xaxis_step) {
      let xcoord = xaxis_low + xoffset
      line(
        (xcoord,yaxis_low,zaxis_low),
        (xcoord,yaxis_high,zaxis_low),
        stroke: yaxis_stroke
      )
      content((xcoord,yaxis_high + text_offset, zaxis_low), text(size:axis_text_size)[#xcoord])
      line(
        (xcoord,yaxis_low,zaxis_low),
        (xcoord,yaxis_low,zaxis_high),
        stroke:zaxis_stroke
      )
    }
    content((xaxis_high,yaxis_high + text_offset,zaxis_low), text(size:axis_text_size)[#xaxis_high])

    for yoffset in range(yaxis_high - yaxis_low, step:yaxis_step) {
      let ycoord = yaxis_low + yoffset
      line(
        (xaxis_low,ycoord,zaxis_low),
        (xaxis_high,ycoord,zaxis_low),
        stroke: xaxis_stroke
      )
      content((xaxis_high + text_offset,ycoord,zaxis_low), text(size:axis_text_size)[#ycoord])
      line(
        (xaxis_low,ycoord,zaxis_low),
        (xaxis_low,ycoord,zaxis_high),
        stroke:zaxis_stroke
      )
    }
    content((xaxis_high + text_offset,yaxis_high,zaxis_low), text(size:axis_text_size)[#yaxis_high])

    for zoffset in range(zaxis_high - zaxis_low, step:zaxis_step) {
      let zcoord = zaxis_low + zoffset
      line(
        (xaxis_low,yaxis_low,zcoord),
        (xaxis_low,yaxis_high,zcoord),
        stroke:yaxis_stroke
      )
      content((xaxis_low - text_offset,yaxis_high,zcoord), text(size:axis_text_size)[#zcoord])
      line(
        (xaxis_low,yaxis_low,zcoord),
        (xaxis_high,yaxis_low,zcoord),
        stroke:xaxis_stroke
      )
    }
    content((xaxis_low - text_offset,yaxis_high,zaxis_high), text(size:axis_text_size)[#zaxis_high])


    line(
      (xaxis_high,yaxis_low,zaxis_low),
      (xaxis_high,yaxis_low,zaxis_high),
      stroke: zaxis_stroke
    )
   // content((), [], anchor: "east", padding: 2em)
    

    line(
      (xaxis_low,yaxis_low,zaxis_high),
      (xaxis_high,yaxis_low,zaxis_high),
      stroke: xaxis_stroke
    )
    content((), [], anchor: "west", padding: 2em)

    line(
      (xaxis_low,yaxis_low,zaxis_high),
      (xaxis_low,yaxis_high,zaxis_high),
      stroke: yaxis_stroke
    )
}

#let render-front-axis(
  axis_low:(0,0,0),
  axis_high: (10,10,10),
  front_axis_dot_scale: (0.05,0.05),
  front_axis_thickness: 0.04em,
  xyz-colors: (red,green,blue),
  axis_label_size:1.5em,
  axis_label_offset: (0.3,0.2,0.15),
  ) = {
    import draw: *

    let (xaxis_low, yaxis_low, zaxis_low) = axis_low
    let (xaxis_high, yaxis_high, zaxis_high) = axis_high
    let axis_stroke = (paint:black, dash: (front_axis_dot_scale.at(0) *1em, front_axis_dot_scale.at(1) *1em))
    set-style(
      stroke:(thickness: front_axis_thickness),
    )
    line(
      (xaxis_low, yaxis_high, zaxis_low),
      (xaxis_low, yaxis_high, zaxis_high),
      stroke: (paint:xyz-colors.at(0), cap: "square"), name: "zaxis"
    ) //z

    line(
      (xaxis_low, yaxis_high, zaxis_low),
      (xaxis_high, yaxis_high, zaxis_low),
      stroke:(paint:xyz-colors.at(1), cap: "square"), name: "xaxis"
    ) //x

    line(
      (xaxis_high, yaxis_low, zaxis_low),
      (xaxis_high, yaxis_high, zaxis_low),
      stroke:(paint:xyz-colors.at(2), cap: "square"), name: "yaxis"
    ) //y

    line(
      (xaxis_high, yaxis_high, zaxis_low),
      (xaxis_high, yaxis_high, zaxis_high),
      stroke: axis_stroke
    ) //z

    line(
      (xaxis_low, yaxis_high, zaxis_high),
      (xaxis_high, yaxis_high, zaxis_high),
      stroke: axis_stroke
    ) //x

    line(
      (xaxis_high,yaxis_low,zaxis_high),
      (xaxis_high,yaxis_high,zaxis_high),
      stroke:axis_stroke
    ) //y

    content((
      xaxis_low + (xaxis_high - xaxis_low)/2, 
      yaxis_high + axis_label_offset.at(0) * text.size.pt(),
      zaxis_low
      ), text(size:axis_label_size)[$x$]
    )

    content((
      xaxis_high + axis_label_offset.at(1) * text.size.pt(),
      yaxis_low + (yaxis_high - yaxis_low)/2, 
      zaxis_low
      ), text(size:axis_label_size)[$y$]
      )

    content((
      xaxis_low - axis_label_offset.at(2) * text.size.pt(),
      yaxis_high,
      zaxis_low + (zaxis_high - zaxis_low)/2
      ), text(size:axis_label_size)[$z$]
    )

}

#let get-surface-zpoints(
  func, 
  render_step: 1,
  samples: 1,
  xdomain:(0,10),
  ydomain: (0,10),
  axis_step: (5,5,5)
  ) = {
    import draw: *
    let (xaxis_low,xaxis_high) = xdomain
    let (yaxis_low,yaxis_high) = ydomain
    let (zaxis_low, zaxis_high) = (0,0)
    let zpoints = ()
    let step = 1/samples

    for xregion in range(xaxis_low * samples, xaxis_high * samples + render_step, step: render_step) {
      let zpoints_temp = ()
      for yregion in range(yaxis_low * samples, yaxis_high * samples + render_step, step: render_step) {
        let x = xregion * step
        let y = yregion * step
        zpoints_temp.push(func(x,y))
      }
      zpoints.push(zpoints_temp)
      let possible_min = calc.min(..zpoints_temp)
      let possible_max = calc.max(..zpoints_temp)
      if (possible_min < zaxis_low) {
        zaxis_low = calc.floor(possible_min)
      }
      if (possible_max > zaxis_high) {
        zaxis_high = calc.ceil(possible_max)
      }
    }
    return (zdomain: (zaxis_low,zaxis_high), zpoints: zpoints)
}

#let render-surface(
  func,
  color-func,
  samples: 1,
  render_step:1,
  xdomain:(0,10),
  ydomain: (0,10),
  zdomain: (0,10),
  zpoints: (),
  axis_step: (5,5,5),
  dot_thickness:0.05em,
  ) = {
    import draw: *


    let (xaxis_low,xaxis_high) = xdomain
    let (yaxis_low,yaxis_high) = ydomain
    let (zaxis_low,zaxis_high) = zdomain

    let step = 1/samples

    let i = 0
    let j = 0 
    for xregion in range(xaxis_low * samples, xaxis_high * samples, step:render_step) {
      for yregion in range(yaxis_low * samples, yaxis_high * samples, step: render_step) {
        let x = xregion * step
        let y = yregion * step
        let offset = step * render_step
        line(
          (x, y, zpoints.at(i).at(j)),
          (x, y + offset, zpoints.at(i).at(j+1)),
          (x + offset, y + offset, zpoints.at(i+1).at(j+1)), 
          (x + offset, y, zpoints.at(i+1).at(j)), 
          stroke:0.02em,
          fill: color-func(x, y, zpoints.at(i).at(j), xaxis_low, xaxis_high, yaxis_low, yaxis_high, zaxis_low,zaxis_high)
        )
        j += 1
      }
      j = 0
      i += 1
    }
}


#let get-parametric-surface-points(
  x-func,
  y-func,
  z-func, 
  subdivisions: 10,
  udomain: (0,1),
  vdomain: (0,1),
  ) = {
    import draw: *
    
    let (u_low, u_high) = udomain
    let (v_low, v_high) = vdomain
    let xsurf_lo = 0
    let ysurf_lo = 0
    let zsurf_lo = 0
    let xsurf_hi = 0
    let ysurf_hi = 0
    let zsurf_hi = 0
    let scale_factor = 1/subdivisions
    
    let surface_points = ()
    for uregion in range(int(u_low * subdivisions), int(u_high * subdivisions)) {
      let surface_points_temp = ()
      for vregion in range(int(v_low * subdivisions), int(v_high * subdivisions)) {
        let u = uregion * scale_factor
        let v= vregion * scale_factor

        let point = (x-func(u,v), y-func(u,v), z-func(u,v))
        surface_points_temp.push(point)

        if (point.at(0) > xsurf_hi) {
          xsurf_hi = calc.ceil(point.at(0))
        }
        if (point.at(0) < xsurf_lo) {
          xsurf_lo = calc.floor(point.at(0))
        }
        if (point.at(1) > ysurf_hi) {
          ysurf_hi = calc.ceil(point.at(1))
        }
        if (point.at(1) < zsurf_lo) {
          ysurf_lo = calc.floor(point.at(1))
        }
        if (point.at(2) > zsurf_hi) {
          zsurf_hi = calc.ceil(point.at(2))
        }
        if (point.at(2) < zsurf_lo) {
          zsurf_lo = calc.floor(point.at(2))
        }
      }
      surface_points.push(surface_points_temp)
    }

    return (surface_points, (xsurf_lo, xsurf_hi), (ysurf_lo, ysurf_hi), (zsurf_lo, zsurf_hi))
}



#let get-parametric-curve-points(
  x-func,
  y-func,
  z-func, 
  subdivisions: 10,
  tdomain: (0,1),
  ) = {
    import draw: *
    
    let (t_low, t_high) = tdomain
    let xcurve_lo = 0
    let ycurve_lo = 0
    let zcurve_lo = 0
    let xcurve_hi = 0
    let ycurve_hi = 0
    let zcurve_hi = 0

    let scale_factor = 1/subdivisions
    let curve_points = ()
    for tregion in range(t_low * subdivisions, t_high * subdivisions) {
      let t = tregion * scale_factor
      let point = (x-func(t), y-func(t), z-func(t))
      curve_points.push(point)

      if (point.at(0) > xcurve_hi) {
        xcurve_hi = calc.ceil(point.at(0))
      }
      if (point.at(0) < xcurve_lo) {
        xcurve_lo = calc.floor(point.at(0))
      }
      if (point.at(1) > ycurve_hi) {
        ycurve_hi = calc.ceil(point.at(1))
      }
      if (point.at(1) < ycurve_lo) {
        ycurve_lo = calc.floor(point.at(1))
      }
      if (point.at(2) > zcurve_hi) {
        zcurve_hi = calc.ceil(point.at(2))
      }
      if (point.at(2) < zcurve_lo) {
        zcurve_lo = calc.floor(point.at(2))
      }
    }

    return (curve_points, (xcurve_lo, xcurve_hi), (ycurve_lo, ycurve_hi), (zcurve_lo, zcurve_hi))
}

#let default-color-func(x, y, z, x_lo,x_hi,y_lo,y_hi,z_lo,z_hi) = {
  return purple.transparentize(20%).darken(50%).lighten((z/(z_lo - z_hi)) * 90%)
}

#let plot-3d-surface(
  func,
  func2: none,
  color-func: default-color-func,
  subdivision_mode: "increase",
  subdivisions: 1,
  scale_dim: (1,1,0.5),
  xdomain:(0,10),
  ydomain: (0,10),
  pad_high: (0,0,0),
  pad_low: (0,0,0),
  axis_step: (5,5,5),
  dot_thickness: 0.05em,
  front_axis_thickness: 0.1em,
  front_axis_dot_scale: (0.5, 1),
  rear_axis_dot_scale: (0.08,0.08),
  rear_axis_text_size: 0.5em,
  axis_label_size: 1.5em,
  axis_label_offset: (0.3,0.2,0.15),
  axis_text_offset: 0.075,
  rotation_matrix: ((-2, 2, 4), (0, -1, 0))
  ) = {
    let samples = 1
    let render_step = 1

    if (subdivision_mode == "increase"){
      samples = subdivisions
    } else if (subdivision_mode == "decrease") {
      render_step = subdivisions
    }

    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale_dim
      
      set-transform(matrix.transform-rotate-dir(rotation_matrix.at(0),rotation_matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis_low,xaxis_high) = xdomain
      let (yaxis_low,yaxis_high) = ydomain
      let (xpad_low,ypad_low,zpad_low) = pad_low
      let (xpad_high,ypad_high,zpad_high) = pad_high
      let step = 1/samples

      let (zdomain, zpoints) = get-surface-zpoints(func, samples: samples,render_step:render_step, xdomain: xdomain, ydomain: ydomain, axis_step:axis_step)

      let (zaxis_low,zaxis_high) = zdomain

      render-rear-axis(
        axis_low: (xaxis_low - xpad_low,yaxis_low - ypad_low, zaxis_low - zpad_low), 
        axis_high: (xaxis_high + xpad_high,yaxis_high + ypad_high, zaxis_high +zpad_high), 
        axis_step: axis_step, 
        dot_thickness: dot_thickness, 
        axis_dot_scale: rear_axis_dot_scale, 
        axis_text_size: rear_axis_text_size,
        axis_text_offset: axis_text_offset
      )

      render-surface(
        func, 
        color-func, 
        samples: samples,
        render_step:render_step, 
        xdomain: xdomain,
        ydomain: ydomain, 
        zdomain:zdomain, 
        axis_step:axis_step, 
        zpoints: zpoints,
      )

      if (func2 != none) {
        let (zdomain, zpoints) = get-surface-zpoints(func, samples: samples,render_step:render_step, xdomain: xdomain, ydomain: ydomain, axis_step:axis_step)

        render-surface(
        func2, 
        color-func, 
        samples: samples,
        render_step:render_step, 
        xdomain: xdomain,
        ydomain: ydomain, 
        zdomain:zdomain, 
        axis_step:axis_step, 
        zpoints: zpoints,
      )

      }

      render-front-axis(
        axis_low: (xaxis_low - xpad_low,yaxis_low - ypad_low,zaxis_low - zpad_low), 
        axis_high: (xaxis_high + xpad_high,yaxis_high + ypad_high,zaxis_high + zpad_high),
        axis_label_size: axis_label_size,
        front_axis_dot_scale: front_axis_dot_scale,
        front_axis_thickness: front_axis_thickness,
        axis_label_offset: axis_label_offset
      )

      })
    ]
}

#let default-line-color-func(i,imax) = {
  return purple.transparentize(20%).darken((i/imax) * 100%)
}

#let render-parametric-curve(
  curve_points:(), 
  color_func: default-line-color-func
  ) = {
  import draw: *
  let npoints = curve_points.len()
  for i in range(curve_points.len() - 1) {
    line(curve_points.at(i), curve_points.at(i+1), stroke: color_func(i,npoints) + 0.2em)
  }
}

#let plot-3d-parametric-curve(
  x_func,
  y_func,
  z_func,
  color_func: default-line-color-func,
  subdivisions:1,
  scale_dim: (1,1,0.5),
  tdomain:(0,1),
  xaxis:(0,10),
  yaxis:(0,10),
  zaxis:(0,10),
  axis_step: (5,5,5),
  dot_thickness: 0.05em,
  front_axis_thickness: 0.1em,
  front_axis_dot_scale: (0.05, 0.05),
  rear_axis_dot_scale: (0.08,0.08),
  rear_axis_text_size: 0.5em,
  axis_label_size: 1.5em,
  axis_label_offset: (0.3,0.2,0.15),
  axis_text_offset: 0.075,
  rotation_matrix: ((-2, 2, 4), (0, -1, 0))
  ) = {
    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale_dim
      set-transform(matrix.transform-rotate-dir(rotation_matrix.at(0),rotation_matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis_low,xaxis_high) = xaxis
      let (yaxis_low,yaxis_high) = yaxis
      let (zaxis_low,zaxis_high) = zaxis


      let (curve_points, (xcurve_lo, xcurve_hi), (ycurve_lo, ycurve_hi), (zcurve_lo, zcurve_hi)) = get-parametric-curve-points(
        x_func,
        y_func,
        z_func, 
        subdivisions: subdivisions,
        tdomain: tdomain,
      )

      render-rear-axis(
        axis_low: (calc.min(xcurve_lo, xaxis_low),calc.min(ycurve_lo, yaxis_low), calc.min(zcurve_lo, zaxis_low)), 
        axis_high: (calc.max(xcurve_hi, xaxis_high),calc.max(ycurve_hi, yaxis_high), calc.max(zcurve_hi, zaxis_high)), 
        axis_step: axis_step, 
        dot_thickness: dot_thickness, 
        axis_dot_scale: rear_axis_dot_scale, 
        axis_text_size: rear_axis_text_size,
        axis_text_offset: axis_text_offset,
      )

      render-parametric-curve(curve_points: curve_points, color_func: color_func)
      

      render-front-axis(
        axis_low: (calc.min(xcurve_lo, xaxis_low),calc.min(ycurve_lo, yaxis_low), calc.min(zcurve_lo, zaxis_low)), 
        axis_high: (calc.max(xcurve_hi, xaxis_high),calc.max(ycurve_hi, yaxis_high), calc.max(zcurve_hi, zaxis_high)), 
        axis_label_size: axis_label_size,
        front_axis_dot_scale: front_axis_dot_scale,
        front_axis_thickness: front_axis_thickness,
        axis_label_offset: axis_label_offset
      )

      })
    ]
  }


#let render-parametric-surface(
  surface_points:(), 
  color-func: default-color-func,
  xdomain: (0,10), 
  ydomain: (0,10), 
  zdomain: (0,10),
  order: 0,
  ) = {
  import draw: *
  let npoints = surface_points.len() * surface_points.at(0).len()

  if (0 == order) {
      for i in range(surface_points.len() - 1) {
        for j in range(surface_points.at(0).len() - 1) {
          line(surface_points.at(i).at(j), surface_points.at(i).at(j+1), surface_points.at(i+1).at(j+1), surface_points.at(i+1).at(j), stroke: 0.02em, 
          fill: color-func(
            surface_points.at(i).at(j).at(0), 
            surface_points.at(i).at(j).at(1), 
            surface_points.at(i).at(j).at(2), 
            xdomain.at(0), xdomain.at(1), 
            ydomain.at(0), ydomain.at(1),
            zdomain.at(0), zdomain.at(1))
          )
        }
      }
  } else if (1 == order) {
    for j in range(surface_points.at(0).len() - 1) {
      for i in range(surface_points.len() - 1) {
        line(surface_points.at(i).at(j), surface_points.at(i).at(j+1), surface_points.at(i+1).at(j+1), surface_points.at(i+1).at(j), stroke: 0.02em, 
        fill: color-func(
          surface_points.at(i).at(j).at(0), 
          surface_points.at(i).at(j).at(1), 
          surface_points.at(i).at(j).at(2), 
          xdomain.at(0), xdomain.at(1), 
          ydomain.at(0), ydomain.at(1),
          zdomain.at(0), zdomain.at(1))
        )
      }
    }
  }
}


#let plot-3d-parametric-surface(
  x_func,
  y_func,
  z_func,
  color-func: default-color-func,
  subdivisions:1,
  render_order: 0,
  scale_dim: (1,1,0.5),
  udomain:(0,1),
  vdomain:(0,1),
  xaxis:(0,10),
  yaxis:(0,10),
  zaxis:(0,10),
  axis_step: (5,5,5),
  dot_thickness: 0.05em,
  front_axis_thickness: 0.1em,
  front_axis_dot_scale: (0.05, 0.05),
  rear_axis_dot_scale: (0.08,0.08),
  rear_axis_text_size: 0.5em,
  axis_label_size: 1.5em,
  axis_label_offset: (0.3,0.2,0.15),
  axis_text_offset: 0.075,
  rotation_matrix: ((-2, 2, 4), (0, -1, 0))
  ) = {
    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale_dim
      set-transform(matrix.transform-rotate-dir(rotation_matrix.at(0),rotation_matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis_low,xaxis_high) = xaxis
      let (yaxis_low,yaxis_high) = yaxis
      let (zaxis_low,zaxis_high) = zaxis


      let (surface_points, (xsurf_lo, xsurf_hi), (ysurf_lo, ysurf_hi), (zsurf_lo, zsurf_hi)) = get-parametric-surface-points(
        x_func,
        y_func,
        z_func, 
        subdivisions: subdivisions,
        udomain: udomain,
        vdomain: vdomain
      )

      let xdomain = (xsurf_lo, xsurf_hi)
      let ydomain = (ysurf_lo, ysurf_hi)
      let zdomain = (zsurf_lo, zsurf_hi)

      render-rear-axis(
        axis_low: (calc.min(xsurf_lo, xaxis_low),calc.min(ysurf_lo, yaxis_low), calc.min(zsurf_lo, zaxis_low)), 
        axis_high: (calc.max(xsurf_hi, xaxis_high),calc.max(ysurf_hi, yaxis_high), calc.max(zsurf_hi, zaxis_high)), 
        axis_step: axis_step, 
        dot_thickness: dot_thickness, 
        axis_dot_scale: rear_axis_dot_scale, 
        axis_text_size: rear_axis_text_size,
        axis_text_offset: axis_text_offset,
      )

      let order = 0
      if (1 == render_order) {
        surface_points = surface_points.rev()
      } else if (2 == render_order) {
        for i in range(surface_points.len()) {
          surface_points.at(i) = surface_points.at(i).rev()
        }
      } else if (3 == render_order) {
        surface_points = surface_points.rev()
        for i in range(surface_points.len()) {
          surface_points.at(i) = surface_points.at(i).rev()
        }
      } else if (4 == render_order) {
        order = 1
      } else if (5 == render_order) {
        surface_points = surface_points.rev()
        order = 1
      } else if (6 == render_order) {
        for i in range(surface_points.len()) {
          surface_points.at(i) = surface_points.at(i).rev()
        }
        order = 1
      } else if (7 == render_order) {
        order = 1
        surface_points = surface_points.rev()
        for i in range(surface_points.len()) {
          surface_points.at(i) = surface_points.at(i).rev()
        }
      } 
      render-parametric-surface(surface_points:surface_points, color-func: color-func, xdomain: xdomain, ydomain: ydomain, zdomain: zdomain, order: order)

      render-front-axis(
        axis_low: (calc.min(xsurf_lo, xaxis_low),calc.min(ysurf_lo, yaxis_low), calc.min(zsurf_lo, zaxis_low)), 
        axis_high: (calc.max(xsurf_hi, xaxis_high),calc.max(ysurf_hi, yaxis_high), calc.max(zsurf_hi, zaxis_high)), 
        axis_label_size: axis_label_size,
        front_axis_dot_scale: front_axis_dot_scale,
        front_axis_thickness: front_axis_thickness,
        axis_label_offset: axis_label_offset
      )

      })
    ]
}

#let get-vector-field-vectors(
  i_func,
  j_func, 
  k_func,  
  render_step: 1,
  samples: 1,
  xdomain:(0,10),
  ydomain: (0,10),
  zdomain: (0,10),
) = {

  let (xaxis_low,xaxis_high) = xdomain
  let (yaxis_low,yaxis_high) = ydomain
  let (zaxis_low,zaxis_high) = zdomain

    let xcurve_lo = 0
    let ycurve_lo = 0
    let zcurve_lo = 0
    let xcurve_hi = 0
    let ycurve_hi = 0
    let zcurve_hi = 0
  let step = 1/samples
  let vectors = ()
  for xregion in range(xaxis_low * samples, xaxis_high * samples, step:render_step) {
    for yregion in range(yaxis_low * samples, yaxis_high * samples, step: render_step) {
      for zregion in range(zaxis_low * samples, zaxis_high * samples, step: render_step) {
        let x = xregion * step
        let y = yregion * step
        let z = zregion * step
        let end_x = i_func(x,y,z)
        let end_y = j_func(x,y,z)
        let end_z = k_func(x,y,z)
        vectors.push( (
          (x, y, z), 
          (end_x, end_y, end_z)
          )
        )
        if (end_x > xcurve_hi) {
        xcurve_hi = calc.ceil(end_x)
        }
        if (end_x < xcurve_lo) {
          xcurve_lo = calc.floor(end_x)
        }
        if (end_y > ycurve_hi) {
          ycurve_hi = calc.ceil(end_y)
        }
        if (end_y < ycurve_lo) {
          ycurve_lo = calc.floor(end_y)
        }
        if (end_z > zcurve_hi) {
          zcurve_hi = calc.ceil(end_z)
        }
        if (end_z< zcurve_lo) {
          zcurve_lo = calc.floor(end_z)
        }
      }
    }
  }
   return (vectors, (xcurve_lo, xcurve_hi), (ycurve_lo, ycurve_hi), (zcurve_lo, zcurve_hi))
}


#let render-3d-vector-field(
  vectors,
  color-func,
  xdomain:(0,10),
  ydomain:(0,10),
  zdomain:(0,10),
  vector_size: 0.02em,
) = {
  import draw: *

  for i in range(vectors.len()) {
    line(vectors.at(i).at(0),vectors.at(i).at(1),stroke: (vector_size + color-func(
          vectors.at(i).at(0).at(0), 
          vectors.at(i).at(0).at(1), 
          vectors.at(i).at(0).at(2), 
          xdomain.at(0), xdomain.at(1), 
          ydomain.at(0), ydomain.at(1),
          zdomain.at(0), zdomain.at(1)
        )), mark: (end: "straight"))
  }
}

#let plot-3d-vector-field(
  i_func,
  j_func,
  k_func,
  color-func: default-color-func,
  subdivisions:1,
  subdivision_mode: "increase",
  scale_dim: (1,1,0.5),
  xdomain:(0,10),
  ydomain:(0,10),
  zdomain:(0,10),
  axis_step: (5,5,5),
  dot_thickness: 0.05em,
  front_axis_thickness: 0.1em,
  front_axis_dot_scale: (0.05, 0.05),
  rear_axis_dot_scale: (0.08,0.08),
  rear_axis_text_size: 0.5em,
  axis_label_size: 1.5em,
  axis_label_offset: (0.3,0.2,0.15),
  axis_text_offset: 0.075,
  rotation_matrix: ((-2, 2, 4), (0, -1, 0)),
  vector_size: 0.02em,
  ) = {
    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale_dim
      set-transform(matrix.transform-rotate-dir(rotation_matrix.at(0),rotation_matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis_low,xaxis_high) = xdomain
      let (yaxis_low,yaxis_high) = ydomain
      let (zaxis_low,zaxis_high) = zdomain

        let samples = 1
      let render_step = 1
      if(subdivision_mode == "increase"){
        samples = subdivisions
      } else if (subdivision_mode == "decrease") {
        render_step = subdivisions
      }


      let (vectors, (xsurf_lo, xsurf_hi), (ysurf_lo, ysurf_hi), (zsurf_lo, zsurf_hi)) = get-vector-field-vectors(
        i_func,
        j_func, 
        k_func,  
        render_step: render_step,
        samples: samples,
        xdomain:xdomain,
        ydomain: ydomain,
        zdomain: zdomain,
      )

      let xdomain = (xsurf_lo, xsurf_hi)
      let ydomain = (ysurf_lo, ysurf_hi)
      let zdomain = (zsurf_lo, zsurf_hi)

      render-rear-axis(
        axis_low: (calc.min(xsurf_lo, xaxis_low),calc.min(ysurf_lo, yaxis_low), calc.min(zsurf_lo, zaxis_low)), 
        axis_high: (calc.max(xsurf_hi, xaxis_high),calc.max(ysurf_hi, yaxis_high), calc.max(zsurf_hi, zaxis_high)), 
        axis_step: axis_step, 
        dot_thickness: dot_thickness, 
        axis_dot_scale: rear_axis_dot_scale, 
        axis_text_size: rear_axis_text_size,
        axis_text_offset: axis_text_offset,
      )

      render-3d-vector-field(
        vectors,
        color-func,
        xdomain: xdomain,
        ydomain: ydomain,
        zdomain: zdomain,
        vector_size: vector_size,
      ) 

      render-front-axis(
        axis_low: (calc.min(xsurf_lo, xaxis_low),calc.min(ysurf_lo, yaxis_low), calc.min(zsurf_lo, zaxis_low)), 
        axis_high: (calc.max(xsurf_hi, xaxis_high),calc.max(ysurf_hi, yaxis_high), calc.max(zsurf_hi, zaxis_high)), 
        axis_label_size: axis_label_size,
        front_axis_dot_scale: front_axis_dot_scale,
        front_axis_thickness: front_axis_thickness,
        axis_label_offset: axis_label_offset
      )

      })
    ]
}