#import "./tabs.typ": draw
#let native-scale = scale
#import draw: *

#let draw-lines(s-num, colors, y, x) = {
  {
    on-layer(-2, {
      for i in range(s-num) {
        line((0, -(y + i)), (x, -(y + i)), stroke: colors.lines)
      }
    })
  }
}

#let draw-bar(s-num, scale-length, colors, x, y, width: 1.0) = {
  on-layer(-1,
    line((x, -y + 0.06), (x, -y - s-num + 1 - 0.06), stroke: width * scale-length/0.3cm * 1.1pt + colors.bars)
  )
}

#let draw-column(s-num, colors, x, y) = {
  circle((x, -y - (s-num - 1)/2 + 1), radius: 0.2, fill: colors.bars, stroke: colors.bars)
  circle((x, -y - (s-num - 1)/2 - 1), radius: 0.2, fill: colors.bars, stroke: colors.bars)
}

#let draw-slur(colors, x, y, n-y, last-string-x) = {
  let y = - (y + n-y - 1)
  bezier-through(
    (last-string-x.at(n-y - 1) + 0.3, y - 0.5),
    ((x + last-string-x.at(n-y - 1)) / 2 + 0.3, y - 1.0),
    (x + 0.3, y - 0.5),
    stroke: colors.connects,
  )
}

#let sign(x) = if x > 0 { 1 } else if x == 0 { 0 } else { -1 }
#let draw-slide(colors, x, y, n-y, last-string-x, fret, last-tab-x) = {
  let y = - (y + n-y - 1)
  let dy = fret.fret - last-tab-x.at(n-y - 1)
  dy = sign(dy) * 0.2

  on-layer(-1, line(
    (last-string-x.at(n-y - 1) + 0.6, y - dy),
    (x, y + dy),
    stroke: colors.connects,
  ))
}

#let scale-fret-numbers(
  scale-length, one-beat-length, colors, 
  fret, duration, alpha
  ) = {
  let nlen = str(fret).len()
  let available = (scale-length/0.3cm) * (one-beat-length/8) * calc.pow(2, -duration) * alpha
  let given = nlen * 0.09
  
  let size = if given > available {
    available/given
  } else {1}
  native-scale(raw(str(fret)), x: size * 100%, origin: left)
}


#let draw-bend(colors, x, y, n-y, dx, bend-return, bend-text) = {
  let alpha = if bend-return {0.4} else {0.8}
          
  on-layer(-1, bezier(
    (x + 0.5, - (y + n-y - 1)),
    (x+alpha*dx, - (y - 1.2)),
    (x+alpha*dx*0.8, - (y + n-y - 1)),
    (x+alpha*dx, - (y + n-y - 1)),
    stroke: colors.connects,
    mark: (
      length: 0.7,
        end: (symbol: ">",
        fill: colors.connects,
        length: 0.5, 
        angle: 30deg, 
        flex: false))
  ))
  content(
    (x + alpha*dx, -y + 1.2),
    raw(str(bend-text)),
    anchor: "south"
  )
  if bend-return {
    bezier(
      (x+alpha*dx, - (y - 1)),
      (x+0.8*dx, - (y + n-y - 1)), 
      (x+0.64*dx, -y+1), 
      (x+0.8*dx, -y+1),
      stroke: colors.connects,
      mark: (
        length: 0.7, 
        end: (symbol: ">", 
          fill: colors.connects, 
          length: 0.5, 
          angle: 30deg, flex: false))
    )
  }
}

#let draw-vibrato(colors, x, y, n-y, dx) = {
  let n = int(dx/0.8)
  let points = for i in range(n) {
    ((x + 0.8 * i, - (y  - 0.9)),
    (x + 0.15 + 0.8 * i, - (y - 1.05)),
    (x + 0.3 + 0.8 * i, - (y  - 0.9)),
    (x + 0.45 + 0.8 * i, - (y - 0.7)),)
  }
  
  merge-path( {
    hobby(
      ..points, fill: black)
    hobby(
      ..points.rev().map(el => (el.at(0) + 0.04, el.at(1) - 0.2)), fill: black)
    },
    stroke: none,
    fill: colors.connects
  )
}
