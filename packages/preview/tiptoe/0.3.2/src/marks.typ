#import "arc-impl.typ": arc-impl
#import "utility.typ"



#let bar(
  width: 2.4pt + 360%,
  stroke: auto, 
  align: center,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width,) = utility.process-dims(
    line, width: width,
  )
  
  assert(align in (center, end))
  let offset = if align == end { stroke.thickness / 2 } else { 0pt }

  (
    mark: place(std.line(
      start: (-offset, -width / 2),
      end: (-offset, width / 2),
      stroke: stroke
    )),
    end: offset
  )
}


#let bracket(
  width: 2.4pt + 360%,
  length: auto,
  stroke: auto, 
  rev: false,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: width, width: length,
    default-ratio: .3
  )
  (width, length) = (length, width)
  let s = stroke.thickness / 2
  let y = width / 2 - s
  let mark = place(curve(
    curve.move((-length, -y)),
    curve.line((-s, -y), relative: false),
    curve.line((-s, y), relative: false),
    curve.line((-length, y), relative: false),
    stroke: stroke
  ))
  if rev {
    mark = scale(x: -100%, place(mark, dx: length))
  }
  (
    mark: mark,
    end: if rev { length } else { s }
  )
}


#let stealth(
  length: 3pt + 450%,
  width: auto,
  inset: 40%,
  fill: auto,
  rev: false,
  stroke: auto,
  line: stroke()
) = {
  let is-auto-stroke = stroke == auto
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: length, width: width,
    default-ratio: .8
  )
  
  let linewidth = stroke.thickness
  let Δl = length * inset
  let dhalf = 0.5 * width
  let tip-length

  let path = if fill == auto and is-auto-stroke {
    // very common optimization for filled arrows
    polygon(
      (0pt, 0pt),
      (-length, dhalf), 
      (-length + Δl, 0pt), 
      (-length, -dhalf), 
      stroke: none, 
      fill: utility.if-auto(stroke.paint, black)
    )
    tip-length = length / 2
  } else {
    let tanα = dhalf / length
    let α = calc.atan(tanα)
    let sinα  = calc.sin(α)
    let x3 = 0.5 * linewidth / sinα
    
    let (x, x4, y) = if inset == 0% {
      let x = length - linewidth/2
      (x, x, tanα * (x - x3))
    } else {
      let tanβ = dhalf / Δl
      let β = calc.atan(tanβ)
      let x1 = 0.5 * linewidth / calc.sin(β)
      let x2 = length - Δl - x1 - x3
      let b = -x2 * tanα
      let x = b / (tanβ - tanα)
      let y = tanβ * x
      let x4 = length - Δl - x1
      (length - Δl - x1 - x, x4, y)
    }
    tip-length = x3
    polygon(
      (-x3, 0pt), 
      (-x, y), 
      (-x4, 0pt), 
      (-x, -y), 
      stroke: std.stroke(
        thickness: linewidth, 
        paint: utility.if-auto(stroke.paint, black), 
        dash: stroke.dash,
        miter-limit: 7, 
        join: "miter"
      ), 
      fill: utility.chained-if-auto(fill, stroke.paint, black)
    )
  }

  
  let mark = place(path)
  if rev {
    mark = scale(x: -100%, place(mark, dx: length))
  }
  (
    mark: mark,
    end: if rev { length - tip-length } else { length - Δl}
  )
}


#let triangle = stealth.with(inset: 0%)

#let round(
  length: 3pt + 450%,
  width: auto,
  inset: 40%,
  rev: false,
  stroke: auto,
  fill: auto,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: length, width: width,
    default-ratio: .8
  )

  let s = 0.5 * stroke.thickness

  if inset >= 100% {
    inset = length - stroke.thickness
  } else {
    inset = length * inset
  }

  let mark = place(polygon(
    (-s, 0pt),
    (-length + s, 0.5 * width - s),
    (-length + inset + s, 0pt),
    (-length + s, -0.5 * width + s),
    fill: utility.chained-if-auto(fill, stroke.paint, black),
    stroke: std.stroke(
      thickness: stroke.thickness, 
      paint: utility.if-auto(stroke.paint, black), 
      dash: stroke.dash,
      miter-limit: 7, 
      join: "round"
    )
  ))
  
  let end = length - inset - s
  
  if rev {
    mark = scale(x: -100%, place(mark, dx: length))
    end = length - s
  }

  (
    mark: mark,
    end: end
  )
}


#let straight(
  length: 3pt + 450%,
  width: auto,
  rev: false,
  stroke: auto,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: length, width: width,
    default-ratio: .8
  )

  let s = stroke.thickness / 2
  let α = calc.atan(0.5 * width / length)
  let tip-length = 0.5 * stroke.thickness / calc.sin(α)

  let mark = place(curve(
    curve.move((-length + s, 0.5 * width - s)),
    curve.line((-tip-length, 0pt), relative: false),
    curve.line((-length + s, -0.5 * width + s), relative: false),
    stroke: std.stroke(
      thickness: stroke.thickness, 
      paint: utility.if-auto(stroke.paint, black), 
      dash: stroke.dash,
      miter-limit: 7, 
      cap: "round"
    )
  ))

  
  if rev {
    mark = scale(x: -100%, place(mark, dx: length))
  }

  (
    mark: mark,
    end: if rev { length - tip-length } else { tip-length }
  )
}

#let diamond(
  length: 565.69%, 
  width: auto,
  fill: auto,
  stroke: auto,
  align: center,
  line: stroke()
) = { 
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: length, width: width,
    default-ratio: 1
  )
  let dhalf = 0.5 * width
  let tip-length
  
  let tanα = dhalf / length * 2
  let α = calc.atan(tanα)
  let tip-length = 0.5 * stroke.thickness / calc.sin(α)
  let top-length = 0.5 * stroke.thickness / calc.cos(α)

  assert(align in (center, end))
  let offset = if align == center { length / 2 } else { 0pt }

  let mark = place(dx: offset, polygon(
    (-length / 2, dhalf - top-length),
    (-tip-length, 0pt),
    (-length / 2, -dhalf + top-length),
    (-length + tip-length, 0pt),
    stroke: stroke,
    fill: utility.chained-if-auto(fill, stroke.paint, black)
  ))
  
  (
    mark: mark,
    end: length - tip-length - offset
  )
}

#let square(
  length: 400%,
  width: auto,
  fill: auto,
  stroke: auto,
  align: center,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: length, width: width,
    default-ratio: 1
  )
  assert(align in (center, end))
  let offset = if align == center { length / 2 } else { 0pt }
  let s = stroke.thickness / 2
  let y = width/2 - s
  let mark = place(dx: offset,
    polygon(
      (-s, y),
      (-length + s, y),
      (-length + s, -y),
      (-s, -y),
      stroke: stroke, 
      fill: utility.chained-if-auto(fill, stroke.paint, black),
    )
  )

  (
    mark: mark, 
    end: length - s - offset
  )
}



#let circle(
  length: 400%,
  width: auto,
  fill: auto,
  stroke: auto,
  align: center,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width, length) = utility.process-dims(
    line, length: length, width: width,
    default-ratio: 1
  )
  let s = stroke.thickness / 2
  let y = width / 2 - s
  
  assert(align in (center, end))
  let offset = if align == center { length / 2 } else { 0pt }
  
  let mark = place(dx: -length + s + offset, dy: -y,
    ellipse(
      width: length - 2 * s,
      height: width - 2 * s,
      stroke: stroke, 
      fill: utility.chained-if-auto(fill, stroke.paint, black),
    )
  )

  (
    mark: mark, 
    end: length - s - offset
  )
}


#let rays(
  n: 4,
  length: 280%,
  phase: auto,
  stroke: auto,
  align: center,
  line: stroke()
) = {
  stroke = utility.process-stroke(line, stroke)
  let (length,) = utility.process-dims(
    line, length: length
  )
  if phase == auto {
    if n == 4 { phase = 45deg }
    else { phase = -90deg }
  }
  
  assert(align in (center, end))
  let offset = if align == end { -length } else { 0pt }

  let mark = for i in range(n) {
    place(dx: offset, std.line(length: length, angle: phase + 360deg*i/n, stroke: stroke))
  }

  (
    mark: mark,
    end: -offset
  )
}



#let barb(
  width: 3pt + 450%,
  arc: 180deg,
  stroke: auto,
  rev: false,
  line: stroke(),
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width,) = utility.process-dims(
    line, width: width
  )

  let s = stroke.thickness / 2
  let radius = width / 2 - s

  let mark = place(
    arc-impl(
      origin: (-width / 2, 0pt),
      angle: -arc / 2,
      arc: arc,
      radius: radius,
      stroke: stroke
    )
  )
  let end = s
  
  if rev {
    mark = scale(x: -100%, place(mark, dx: width / 2))
    end = radius
  }

  (
    mark: mark,
    end: end
  )
}


#let hooks(
  width: 3pt + 450%,
  arc: 180deg,
  stroke: auto,
  rev: false,
  line: stroke(),
) = {
  stroke = utility.process-stroke(line, stroke)
  let (width,) = utility.process-dims(
    line, width: width
  )

  let s = stroke.thickness / 2
  let r = (width / 2 - s) / 2

  let mark = {
    place(
      arc-impl(
        origin: (-r - s, r),
        angle: -90deg,
        arc: arc,
        radius: r,
        stroke: stroke
      )
    )
    place(
      arc-impl(
        origin: (-r - s, -r),
        angle: 90deg,
        arc: -arc,
        radius: r,
        stroke: stroke
      )
    )
  }
  let end = r - s
  
  if rev {
    mark = scale(x: -100%, place(mark, dx: r + s))
    end = 0pt
  }

  (
    mark: mark,
    end: end + s
  )
}



#let tikz(
  width: 3pt + 450%,
  arc: 180deg,
  stroke: auto,
  line: stroke(),
) = {
  let sharp = false
  stroke = utility.process-stroke(line, stroke)
  let (width,) = utility.process-dims(
    line, width: width
  )
  
  let s = stroke.thickness / 2
  stroke = if sharp {
    (thickness: stroke.thickness, paint: stroke.paint, join: "bevel", cap: "butt")
  } else {
    (thickness: stroke.thickness, paint: stroke.paint, join: "round", cap: "round")
  }
  let x0 = if sharp { stroke.thickness/width*10pt } else { -s }
  let mark = place(
    curve(
      curve.move((-width * 0.42, -width / 2 + s)),
      curve.cubic(
        (-width * 0.32, -width * 0.1 + s), 
        none, 
        (x0, 0pt),
        relative: false
      ),
      curve.cubic(
        none, 
        (-width * 0.32, width * 0.1 - s), 
        (-width * 0.42, width / 2 - s),
        relative: false
      ),
      stroke: stroke
    )
  )
  
  (
    mark: mark,
    end: stroke.thickness
  )
}


#let combine(
  line: stroke(), 
  ..marks
) = (line: stroke()) => {
  let marks = marks.pos()
  let linewidth = utility.if-auto(line.thickness, 1pt)
  
  let combined-mark
  let pos = 0pt
  let end

  for mark in marks {
    if mark == std.end {
      end = pos
    } else if type(mark) == length {
      pos += mark
    } else if type(mark) == ratio {
      pos += mark * linewidth
    } else if type(mark) == function {
      mark = mark(line: line)
      combined-mark += place(dx: -pos, mark.mark)
      pos += mark.end
    }
  }
  if end == none {
    end = pos
  }

  (
    mark: combined-mark, 
    end: end
  )
}

