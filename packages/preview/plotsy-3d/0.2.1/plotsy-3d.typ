// plotsy-3d
// Author: misskacie
// License: LGPL-3.0-or-later
#import "@preview/cetz:0.4.1": canvas, draw, matrix

#let render-rear-axis(
  axis-low: (0,0,0),
  axis-high: (10,10,10),
  axis-step: (5,5,5),
  axis-dot-scale: (0.08,0.08),
  dot-thickness: 0.05em,
  axis-text-size: 1em,
  axis-text-offset: 0.07,
  ) = {
    import draw: *
    let (xaxis-low,yaxis-low,zaxis-low) = axis-low
    let (xaxis-high,yaxis-high,zaxis-high) = axis-high
    let (xaxis-step,yaxis-step,zaxis-step) = axis-step

    let xaxis-stroke = (paint:black, dash: (axis-dot-scale.at(0) *1em, axis-dot-scale.at(1) *1em))
    let yaxis-stroke = (paint:black, dash: (axis-dot-scale.at(0) *1em, axis-dot-scale.at(1) *1em))
    let zaxis-stroke = (paint:black, dash: (axis-dot-scale.at(0) *1em, axis-dot-scale.at(1) *1em))

    set-style(
      stroke:(thickness: dot-thickness)
    )
    let text-offset = axis-text-offset * text.size.pt()

    for xoffset in range(xaxis-high - xaxis-low, step:xaxis-step) {
      let xcoord = xaxis-low + xoffset
      line(
        (xcoord,yaxis-low,zaxis-low),
        (xcoord,yaxis-high,zaxis-low),
        stroke: yaxis-stroke
      )
      content((xcoord,yaxis-high + text-offset, zaxis-low), text(size:axis-text-size)[#xcoord])
      line(
        (xcoord,yaxis-low,zaxis-low),
        (xcoord,yaxis-low,zaxis-high),
        stroke:zaxis-stroke
      )
    }
    content((xaxis-high,yaxis-high + text-offset,zaxis-low), text(size:axis-text-size)[#xaxis-high])

    for yoffset in range(yaxis-high - yaxis-low, step:yaxis-step) {
      let ycoord = yaxis-low + yoffset
      line(
        (xaxis-low,ycoord,zaxis-low),
        (xaxis-high,ycoord,zaxis-low),
        stroke: xaxis-stroke
      )
      content((xaxis-high + text-offset,ycoord,zaxis-low), text(size:axis-text-size)[#ycoord])
      line(
        (xaxis-low,ycoord,zaxis-low),
        (xaxis-low,ycoord,zaxis-high),
        stroke:zaxis-stroke
      )
    }
    content((xaxis-high + text-offset,yaxis-high,zaxis-low), text(size:axis-text-size)[#yaxis-high])

    for zoffset in range(zaxis-high - zaxis-low, step:zaxis-step) {
      let zcoord = zaxis-low + zoffset
      line(
        (xaxis-low,yaxis-low,zcoord),
        (xaxis-low,yaxis-high,zcoord),
        stroke:yaxis-stroke
      )
      content((xaxis-low - text-offset,yaxis-high,zcoord), text(size:axis-text-size)[#zcoord])
      line(
        (xaxis-low,yaxis-low,zcoord),
        (xaxis-high,yaxis-low,zcoord),
        stroke:xaxis-stroke
      )
    }
    content((xaxis-low - text-offset,yaxis-high,zaxis-high), text(size:axis-text-size)[#zaxis-high])


    line(
      (xaxis-high,yaxis-low,zaxis-low),
      (xaxis-high,yaxis-low,zaxis-high),
      stroke: zaxis-stroke
    )
   // content((), [], anchor: "east", padding: 2em)
    

    line(
      (xaxis-low,yaxis-low,zaxis-high),
      (xaxis-high,yaxis-low,zaxis-high),
      stroke: xaxis-stroke
    )
    content((), [], anchor: "west", padding: 2em)

    line(
      (xaxis-low,yaxis-low,zaxis-high),
      (xaxis-low,yaxis-high,zaxis-high),
      stroke: yaxis-stroke
    )
}

#let render-front-axis(
  axis-low:(0,0,0),
  axis-high: (10,10,10),
  front-axis-dot-scale: (0.05,0.05),
  front-axis-thickness: 0.04em,
  xyz-colors: (red,green,blue),
  axis-label-size:1.5em,
  axis-label-offset: (0.3,0.2,0.15),
  axis-labels: ($x$, $y$, $z$),
  ) = {
    import draw: *

    let (xaxis-low, yaxis-low, zaxis-low) = axis-low
    let (xaxis-high, yaxis-high, zaxis-high) = axis-high
    let axis-stroke = (paint:black, dash: (front-axis-dot-scale.at(0) *1em, front-axis-dot-scale.at(1) *1em))
    set-style(
      stroke:(thickness: front-axis-thickness),
    )
    line(
      (xaxis-low, yaxis-high, zaxis-low),
      (xaxis-low, yaxis-high, zaxis-high),
      stroke: (paint:xyz-colors.at(0), cap: "square"), name: "zaxis"
    ) //z

    line(
      (xaxis-low, yaxis-high, zaxis-low),
      (xaxis-high, yaxis-high, zaxis-low),
      stroke:(paint:xyz-colors.at(1), cap: "square"), name: "xaxis"
    ) //x

    line(
      (xaxis-high, yaxis-low, zaxis-low),
      (xaxis-high, yaxis-high, zaxis-low),
      stroke:(paint:xyz-colors.at(2), cap: "square"), name: "yaxis"
    ) //y

    line(
      (xaxis-high, yaxis-high, zaxis-low),
      (xaxis-high, yaxis-high, zaxis-high),
      stroke: axis-stroke
    ) //z

    line(
      (xaxis-low, yaxis-high, zaxis-high),
      (xaxis-high, yaxis-high, zaxis-high),
      stroke: axis-stroke
    ) //x

    line(
      (xaxis-high,yaxis-low,zaxis-high),
      (xaxis-high,yaxis-high,zaxis-high),
      stroke:axis-stroke
    ) //y

    content((
      xaxis-low + (xaxis-high - xaxis-low)/2, 
      yaxis-high + axis-label-offset.at(0) * text.size.pt(),
      zaxis-low
      ), 
      anchor: "north",
      text(size:axis-label-size)[#axis-labels.at(0)]
    )

    content((
      xaxis-high + axis-label-offset.at(1) * text.size.pt(),
      yaxis-low + (yaxis-high - yaxis-low)/2, 
      zaxis-low
      ), 
      anchor: "north-west",
      text(size:axis-label-size)[#axis-labels.at(1)]
      )

    content((
      xaxis-low - axis-label-offset.at(2) * text.size.pt(),
      yaxis-high,
      zaxis-low + (zaxis-high - zaxis-low)/2
      ), 
      anchor: "east",
      text(size:axis-label-size)[#axis-labels.at(2)]
    )

}

#let get-surface-zpoints(
  func, 
  render-step: 1,
  samples: 1,
  xdomain:(0,10),
  ydomain: (0,10),
  axis-step: (5,5,5)
  ) = {
    import draw: *
    let (xaxis-low,xaxis-high) = xdomain
    let (yaxis-low,yaxis-high) = ydomain
    let (zaxis-low, zaxis-high) = (0,0)
    let zpoints = ()
    let step = 1/samples

    for xregion in range(xaxis-low * samples, xaxis-high * samples + render-step, step: render-step) {
      let zpoints-temp = ()
      for yregion in range(yaxis-low * samples, yaxis-high * samples + render-step, step: render-step) {
        let x = xregion * step
        let y = yregion * step
        zpoints-temp.push(func(x,y))
      }
      zpoints.push(zpoints-temp)
      let possible-min = calc.min(..zpoints-temp)
      let possible-max = calc.max(..zpoints-temp)
      if (possible-min < zaxis-low) {
        zaxis-low = calc.floor(possible-min)
      }
      if (possible-max > zaxis-high) {
        zaxis-high = calc.ceil(possible-max)
      }
    }
    return (zdomain: (zaxis-low,zaxis-high), zpoints: zpoints)
}

#let render-surface(
  func,
  color-func,
  samples: 1,
  render-step:1,
  xdomain:(0,10),
  ydomain: (0,10),
  zdomain: (0,10),
  zpoints: (),
  axis-step: (5,5,5),
  dot-thickness:0.05em,
  ) = {
    import draw: *


    let (xaxis-low,xaxis-high) = xdomain
    let (yaxis-low,yaxis-high) = ydomain
    let (zaxis-low,zaxis-high) = zdomain

    let step = 1/samples

    let i = 0
    let j = 0 
    for xregion in range(xaxis-low * samples, xaxis-high * samples, step:render-step) {
      for yregion in range(yaxis-low * samples, yaxis-high * samples, step: render-step) {
        let x = xregion * step
        let y = yregion * step
        let offset = step * render-step
        line(
          (x, y, zpoints.at(i).at(j)),
          (x, y + offset, zpoints.at(i).at(j+1)),
          (x + offset, y + offset, zpoints.at(i+1).at(j+1)), 
          (x + offset, y, zpoints.at(i+1).at(j)), 
          stroke:0.02em,
          fill: color-func(x, y, zpoints.at(i).at(j), xaxis-low, xaxis-high, yaxis-low, yaxis-high, zaxis-low,zaxis-high)
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
    
    let (u-low, u-high) = udomain
    let (v-low, v-high) = vdomain
    let xsurf-lo = 0
    let ysurf-lo = 0
    let zsurf-lo = 0
    let xsurf-hi = 0
    let ysurf-hi = 0
    let zsurf-hi = 0
    let scale-factor = 1/subdivisions
    
    let surface-points = ()
    for uregion in range(int(u-low * subdivisions), int(u-high * subdivisions)) {
      let surface-points-temp = ()
      for vregion in range(int(v-low * subdivisions), int(v-high * subdivisions)) {
        let u = uregion * scale-factor
        let v= vregion * scale-factor

        let point = (x-func(u,v), y-func(u,v), z-func(u,v))
        surface-points-temp.push(point)

        if (point.at(0) > xsurf-hi) {
          xsurf-hi = calc.ceil(point.at(0))
        }
        if (point.at(0) < xsurf-lo) {
          xsurf-lo = calc.floor(point.at(0))
        }
        if (point.at(1) > ysurf-hi) {
          ysurf-hi = calc.ceil(point.at(1))
        }
        if (point.at(1) < zsurf-lo) {
          ysurf-lo = calc.floor(point.at(1))
        }
        if (point.at(2) > zsurf-hi) {
          zsurf-hi = calc.ceil(point.at(2))
        }
        if (point.at(2) < zsurf-lo) {
          zsurf-lo = calc.floor(point.at(2))
        }
      }
      surface-points.push(surface-points-temp)
    }

    return (surface-points, (xsurf-lo, xsurf-hi), (ysurf-lo, ysurf-hi), (zsurf-lo, zsurf-hi))
}



#let get-parametric-curve-points(
  x-func,
  y-func,
  z-func, 
  subdivisions: 10,
  tdomain: (0,1),
  ) = {
    import draw: *
    
    let (t-low, t-high) = tdomain
    let xcurve-lo = 0
    let ycurve-lo = 0
    let zcurve-lo = 0
    let xcurve-hi = 0
    let ycurve-hi = 0
    let zcurve-hi = 0

    let scale-factor = 1/subdivisions
    let curve-points = ()
    for tregion in range(t-low * subdivisions, t-high * subdivisions) {
      let t = tregion * scale-factor
      let point = (x-func(t), y-func(t), z-func(t))
      curve-points.push(point)

      if (point.at(0) > xcurve-hi) {
        xcurve-hi = calc.ceil(point.at(0))
      }
      if (point.at(0) < xcurve-lo) {
        xcurve-lo = calc.floor(point.at(0))
      }
      if (point.at(1) > ycurve-hi) {
        ycurve-hi = calc.ceil(point.at(1))
      }
      if (point.at(1) < ycurve-lo) {
        ycurve-lo = calc.floor(point.at(1))
      }
      if (point.at(2) > zcurve-hi) {
        zcurve-hi = calc.ceil(point.at(2))
      }
      if (point.at(2) < zcurve-lo) {
        zcurve-lo = calc.floor(point.at(2))
      }
    }

    return (curve-points, (xcurve-lo, xcurve-hi), (ycurve-lo, ycurve-hi), (zcurve-lo, zcurve-hi))
}

#let default-color-func(x, y, z, x-lo,x-hi,y-lo,y-hi,z-lo,z-hi) = {
  return purple.transparentize(20%).darken(50%).lighten((z/(z-lo - z-hi)) * 90%)
}

#let plot-3d-surface(
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
  ) = {
    let samples = 1
    let render-step = 1

    if (subdivision-mode == "increase"){
      samples = subdivisions
    } else if (subdivision-mode == "decrease") {
      render-step = subdivisions
    }

    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale-dim
      
      set-transform(matrix.transform-rotate-dir(rotation-matrix.at(0),rotation-matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis-low,xaxis-high) = xdomain
      let (yaxis-low,yaxis-high) = ydomain
      let (xpad-low,ypad-low,zpad-low) = pad-low
      let (xpad-high,ypad-high,zpad-high) = pad-high
      let step = 1/samples

      let (zdomain, zpoints) = get-surface-zpoints(func, samples: samples,render-step:render-step, xdomain: xdomain, ydomain: ydomain, axis-step:axis-step)

      let (zaxis-low,zaxis-high) = zdomain

      render-rear-axis(
        axis-low: (xaxis-low - xpad-low,yaxis-low - ypad-low, zaxis-low - zpad-low), 
        axis-high: (xaxis-high + xpad-high,yaxis-high + ypad-high, zaxis-high +zpad-high), 
        axis-step: axis-step, 
        dot-thickness: dot-thickness, 
        axis-dot-scale: rear-axis-dot-scale, 
        axis-text-size: rear-axis-text-size,
        axis-text-offset: axis-text-offset
      )

      render-surface(
        func, 
        color-func, 
        samples: samples,
        render-step:render-step, 
        xdomain: xdomain,
        ydomain: ydomain, 
        zdomain:zdomain, 
        axis-step:axis-step, 
        zpoints: zpoints,
      )

      if (func2 != none) {
        let (zdomain, zpoints) = get-surface-zpoints(func, samples: samples,render-step:render-step, xdomain: xdomain, ydomain: ydomain, axis-step:axis-step)

        render-surface(
        func2, 
        color-func, 
        samples: samples,
        render-step:render-step, 
        xdomain: xdomain,
        ydomain: ydomain, 
        zdomain:zdomain, 
        axis-step:axis-step, 
        zpoints: zpoints,
      )

      }

      render-front-axis(
        axis-low: (xaxis-low - xpad-low,yaxis-low - ypad-low,zaxis-low - zpad-low), 
        axis-high: (xaxis-high + xpad-high,yaxis-high + ypad-high,zaxis-high + zpad-high),
        axis-label-size: axis-label-size,
        front-axis-dot-scale: front-axis-dot-scale,
        front-axis-thickness: front-axis-thickness,
        axis-label-offset: axis-label-offset,
        xyz-colors: xyz-colors,
        axis-labels: axis-labels,
      )

      })
    ]
}

#let default-line-color-func(i,imax) = {
  return purple.transparentize(20%).darken((i/imax) * 100%)
}

#let render-parametric-curve(
  curve-points:(), 
  color-func: default-line-color-func
  ) = {
  import draw: *
  let npoints = curve-points.len()
  for i in range(curve-points.len() - 1) {
    line(curve-points.at(i), curve-points.at(i+1), stroke: color-func(i,npoints) + 0.2em)
  }
}

#let plot-3d-parametric-curve(
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
  ) = {
    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale-dim
      set-transform(matrix.transform-rotate-dir(rotation-matrix.at(0),rotation-matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis-low,xaxis-high) = xaxis
      let (yaxis-low,yaxis-high) = yaxis
      let (zaxis-low,zaxis-high) = zaxis


      let (curve-points, (xcurve-lo, xcurve-hi), (ycurve-lo, ycurve-hi), (zcurve-lo, zcurve-hi)) = get-parametric-curve-points(
        x-func,
        y-func,
        z-func, 
        subdivisions: subdivisions,
        tdomain: tdomain,
      )

      render-rear-axis(
        axis-low: (calc.min(xcurve-lo, xaxis-low),calc.min(ycurve-lo, yaxis-low), calc.min(zcurve-lo, zaxis-low)), 
        axis-high: (calc.max(xcurve-hi, xaxis-high),calc.max(ycurve-hi, yaxis-high), calc.max(zcurve-hi, zaxis-high)), 
        axis-step: axis-step, 
        dot-thickness: dot-thickness, 
        axis-dot-scale: rear-axis-dot-scale, 
        axis-text-size: rear-axis-text-size,
        axis-text-offset: axis-text-offset,
      )

      render-parametric-curve(curve-points: curve-points, color-func: color-func)
      

      render-front-axis(
        axis-low: (calc.min(xcurve-lo, xaxis-low),calc.min(ycurve-lo, yaxis-low), calc.min(zcurve-lo, zaxis-low)), 
        axis-high: (calc.max(xcurve-hi, xaxis-high),calc.max(ycurve-hi, yaxis-high), calc.max(zcurve-hi, zaxis-high)), 
        axis-label-size: axis-label-size,
        front-axis-dot-scale: front-axis-dot-scale,
        front-axis-thickness: front-axis-thickness,
        axis-label-offset: axis-label-offset,
        xyz-colors: xyz-colors,
        axis-labels: axis-labels,
      )

      })
    ]
  }


#let render-parametric-surface(
  surface-points:(), 
  color-func: default-color-func,
  xdomain: (0,10), 
  ydomain: (0,10), 
  zdomain: (0,10),
  order: 0,
  ) = {
  import draw: *
  let npoints = surface-points.len() * surface-points.at(0).len()

  if (0 == order) {
      for i in range(surface-points.len() - 1) {
        for j in range(surface-points.at(0).len() - 1) {
          line(surface-points.at(i).at(j), surface-points.at(i).at(j+1), surface-points.at(i+1).at(j+1), surface-points.at(i+1).at(j), stroke: 0.02em, 
          fill: color-func(
            surface-points.at(i).at(j).at(0), 
            surface-points.at(i).at(j).at(1), 
            surface-points.at(i).at(j).at(2), 
            xdomain.at(0), xdomain.at(1), 
            ydomain.at(0), ydomain.at(1),
            zdomain.at(0), zdomain.at(1))
          )
        }
      }
  } else if (1 == order) {
    for j in range(surface-points.at(0).len() - 1) {
      for i in range(surface-points.len() - 1) {
        line(surface-points.at(i).at(j), surface-points.at(i).at(j+1), surface-points.at(i+1).at(j+1), surface-points.at(i+1).at(j), stroke: 0.02em, 
        fill: color-func(
          surface-points.at(i).at(j).at(0), 
          surface-points.at(i).at(j).at(1), 
          surface-points.at(i).at(j).at(2), 
          xdomain.at(0), xdomain.at(1), 
          ydomain.at(0), ydomain.at(1),
          zdomain.at(0), zdomain.at(1))
        )
      }
    }
  }
}


#let plot-3d-parametric-surface(
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
  ) = {
    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale-dim
      set-transform(matrix.transform-rotate-dir(rotation-matrix.at(0),rotation-matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis-low,xaxis-high) = xaxis
      let (yaxis-low,yaxis-high) = yaxis
      let (zaxis-low,zaxis-high) = zaxis


      let (surface-points, (xsurf-lo, xsurf-hi), (ysurf-lo, ysurf-hi), (zsurf-lo, zsurf-hi)) = get-parametric-surface-points(
        x-func,
        y-func,
        z-func, 
        subdivisions: subdivisions,
        udomain: udomain,
        vdomain: vdomain
      )

      let xdomain = (xsurf-lo, xsurf-hi)
      let ydomain = (ysurf-lo, ysurf-hi)
      let zdomain = (zsurf-lo, zsurf-hi)

      render-rear-axis(
        axis-low: (calc.min(xsurf-lo, xaxis-low),calc.min(ysurf-lo, yaxis-low), calc.min(zsurf-lo, zaxis-low)), 
        axis-high: (calc.max(xsurf-hi, xaxis-high),calc.max(ysurf-hi, yaxis-high), calc.max(zsurf-hi, zaxis-high)), 
        axis-step: axis-step, 
        dot-thickness: dot-thickness, 
        axis-dot-scale: rear-axis-dot-scale, 
        axis-text-size: rear-axis-text-size,
        axis-text-offset: axis-text-offset,
      )

      let order = 0
      if (1 == render-order) {
        surface-points = surface-points.rev()
      } else if (2 == render-order) {
        for i in range(surface-points.len()) {
          surface-points.at(i) = surface-points.at(i).rev()
        }
      } else if (3 == render-order) {
        surface-points = surface-points.rev()
        for i in range(surface-points.len()) {
          surface-points.at(i) = surface-points.at(i).rev()
        }
      } else if (4 == render-order) {
        order = 1
      } else if (5 == render-order) {
        surface-points = surface-points.rev()
        order = 1
      } else if (6 == render-order) {
        for i in range(surface-points.len()) {
          surface-points.at(i) = surface-points.at(i).rev()
        }
        order = 1
      } else if (7 == render-order) {
        order = 1
        surface-points = surface-points.rev()
        for i in range(surface-points.len()) {
          surface-points.at(i) = surface-points.at(i).rev()
        }
      } 
      render-parametric-surface(surface-points:surface-points, color-func: color-func, xdomain: xdomain, ydomain: ydomain, zdomain: zdomain, order: order)

      render-front-axis(
        axis-low: (calc.min(xsurf-lo, xaxis-low),calc.min(ysurf-lo, yaxis-low), calc.min(zsurf-lo, zaxis-low)), 
        axis-high: (calc.max(xsurf-hi, xaxis-high),calc.max(ysurf-hi, yaxis-high), calc.max(zsurf-hi, zaxis-high)), 
        axis-label-size: axis-label-size,
        front-axis-dot-scale: front-axis-dot-scale,
        front-axis-thickness: front-axis-thickness,
        axis-label-offset: axis-label-offset,
        xyz-colors: xyz-colors,
        axis-labels: axis-labels,
      )

      })
    ]
}

#let get-vector-field-vectors(
  i-func,
  j-func, 
  k-func,  
  render-step: 1,
  samples: 1,
  xdomain:(0,10),
  ydomain: (0,10),
  zdomain: (0,10),
  vector-length-scale: 1,
) = {

  let (xaxis-low,xaxis-high) = xdomain
  let (yaxis-low,yaxis-high) = ydomain
  let (zaxis-low,zaxis-high) = zdomain

    let xcurve-lo = 0
    let ycurve-lo = 0
    let zcurve-lo = 0
    let xcurve-hi = 0
    let ycurve-hi = 0
    let zcurve-hi = 0
  let step = 1/samples
  let vectors = ()
  for xregion in range(xaxis-low * samples, xaxis-high * samples, step:render-step) {
    for yregion in range(yaxis-low * samples, yaxis-high * samples, step: render-step) {
      for zregion in range(zaxis-low * samples, zaxis-high * samples, step: render-step) {
        let x = xregion * step
        let y = yregion * step
        let z = zregion * step
        let end-x = i-func(x,y,z)
        let end-y = j-func(x,y,z)
        let end-z = k-func(x,y,z)
        vectors.push( (
          (x, y, z), 
          ( (end-x - x)*vector-length-scale + x, (end-y - y)*vector-length-scale + y, (end-z - z)*vector-length-scale +z)
          )
        )
        if (end-x > xcurve-hi) {
        xcurve-hi = calc.ceil(end-x)
        }
        if (end-x < xcurve-lo) {
          xcurve-lo = calc.floor(end-x)
        }
        if (end-y > ycurve-hi) {
          ycurve-hi = calc.ceil(end-y)
        }
        if (end-y < ycurve-lo) {
          ycurve-lo = calc.floor(end-y)
        }
        if (end-z > zcurve-hi) {
          zcurve-hi = calc.ceil(end-z)
        }
        if (end-z< zcurve-lo) {
          zcurve-lo = calc.floor(end-z)
        }
      }
    }
  }
   return (vectors, (xcurve-lo, xcurve-hi), (ycurve-lo, ycurve-hi), (zcurve-lo, zcurve-hi))
}


#let render-3d-vector-field(
  vectors,
  color-func,
  xdomain:(0,10),
  ydomain:(0,10),
  zdomain:(0,10),
  vector-size: 0.02em,
) = {
  import draw: *

  for i in range(vectors.len()) {
    if (vectors.at(i).at(0) != vectors.at(i).at(1)) {
      line(vectors.at(i).at(0),vectors.at(i).at(1),stroke: (vector-size + color-func(
            vectors.at(i).at(0).at(0), 
            vectors.at(i).at(0).at(1), 
            vectors.at(i).at(0).at(2), 
            xdomain.at(0), xdomain.at(1), 
            ydomain.at(0), ydomain.at(1),
            zdomain.at(0), zdomain.at(1)
          )), mark: (end: "straight"))
    }
  }
}

#let plot-3d-vector-field(
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
  vector-length-scale: 1,
  xyz-colors: (red, green, blue),
  ) = {
    context[#canvas({
      import draw: *
      let (xscale, yscale, zscale) = scale-dim
      set-transform(matrix.transform-rotate-dir(rotation-matrix.at(0),rotation-matrix.at(1)))
      scale(x: xscale*text.size.pt(), y: yscale*text.size.pt(), z: zscale*text.size.pt())
      

      let (xaxis-low,xaxis-high) = xdomain
      let (yaxis-low,yaxis-high) = ydomain
      let (zaxis-low,zaxis-high) = zdomain

        let samples = 1
      let render-step = 1
      if(subdivision-mode == "increase"){
        samples = subdivisions
      } else if (subdivision-mode == "decrease") {
        render-step = subdivisions
      }


      let (vectors, (xsurf-lo, xsurf-hi), (ysurf-lo, ysurf-hi), (zsurf-lo, zsurf-hi)) = get-vector-field-vectors(
        i-func,
        j-func, 
        k-func,  
        render-step: render-step,
        samples: samples,
        xdomain:xdomain,
        ydomain: ydomain,
        zdomain: zdomain,
        vector-length-scale: vector-length-scale,
      )

      let xdomain = (xsurf-lo, xsurf-hi)
      let ydomain = (ysurf-lo, ysurf-hi)
      let zdomain = (zsurf-lo, zsurf-hi)

      render-rear-axis(
        axis-low: (calc.min(xsurf-lo, xaxis-low),calc.min(ysurf-lo, yaxis-low), calc.min(zsurf-lo, zaxis-low)), 
        axis-high: (calc.max(xsurf-hi, xaxis-high),calc.max(ysurf-hi, yaxis-high), calc.max(zsurf-hi, zaxis-high)), 
        axis-step: axis-step, 
        dot-thickness: dot-thickness, 
        axis-dot-scale: rear-axis-dot-scale, 
        axis-text-size: rear-axis-text-size,
        axis-text-offset: axis-text-offset,
      )

      render-3d-vector-field(
        vectors,
        color-func,
        xdomain: xdomain,
        ydomain: ydomain,
        zdomain: zdomain,
        vector-size: vector-size,
      ) 

      render-front-axis(
        axis-low: (calc.min(xsurf-lo, xaxis-low),calc.min(ysurf-lo, yaxis-low), calc.min(zsurf-lo, zaxis-low)), 
        axis-high: (calc.max(xsurf-hi, xaxis-high),calc.max(ysurf-hi, yaxis-high), calc.max(zsurf-hi, zaxis-high)), 
        axis-label-size: axis-label-size,
        front-axis-dot-scale: front-axis-dot-scale,
        front-axis-thickness: front-axis-thickness,
        axis-label-offset: axis-label-offset,
        xyz-colors: xyz-colors,
        axis-labels: axis-labels,
      )

      })
    ]
}