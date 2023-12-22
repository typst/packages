#import "@preview/cetz:0.1.1": canvas, draw

#let new(
  tabs,
  extra: none,
  eval-scope: none,
  scale: 0.3cm,
  s-num: 6,
  one-beat-length: 8,
  line-spacing: 2,
) = {
  let sign(x) = if x > 0 { 1 } else if x == 0 { 0 } else { -1 }
  layout(
    size => {
      let width = size.width / scale * 0.95

      canvas(
        length: scale,
        {
          import draw: *

          let draw-lines(y, x: width) = {
            // TODO: use on-layer
            {
              for i in range(s-num) {
                line((0, -(y + i)), (x, -(y + i)), stroke: rgb(1, 1, 1, 20%))
              }
            }
          }

          let draw-bar(x, y, width: 1.0) = {
            line((x, -y), (x, -y - s-num + 1), stroke: width * 1.2pt + gray)
          }

          let x = 0
          let y = 0

          draw-bar(0, 0)
          let last-string-x = (-1.5,) * 6
          let last-tab-x = (0,) * 6
          let last-sign = none

          for bar in tabs {
            if bar.len() > 0 {
              if (last-sign == "\\" or last-sign == none) {
                if bar.at(0) != "||" { x += 1. } else { x -= 0.5 }
              }
              
            }
            for n in bar {
              let frets = n.at(0)

              if x >= width {
                draw-lines(y)
                draw-bar(x, y)
                last-string-x = (-1.5,) * 6
                x = 1.0
                y += s-num + line-spacing
                last-sign = "\\"
              }

              if n == "\\" {
                if last-sign != "||" and last-sign != "|" {
                    draw-bar(x, y)
                    x += 0.5
                }
                else {
                    x -= 0.5
                }

                draw-lines(y, x: x - 0.5)
                last-string-x = (-1.5,) * 6
                y += s-num + line-spacing
                x = 0.0
                draw-bar(x, y)
                x -= 0.5
                last-sign = "\\"
                continue
              }

              if n == "<" {
                x -= 0.5
                continue
              }
              if n == ">" {
                x += 0.5
                continue
              }

              if n == ":" {
                if last-sign == none { x -= 1 / 1 }
                circle((x, -y - 1.5), radius: 0.2, fill: gray, stroke: gray)
                circle((x, -y - 3.5), radius: 0.2, fill: gray, stroke: gray)
                last-sign = ":"
                x += 0.5
                continue
              }

              if n == "||" {
                x += 0.5
                draw-bar(x, y, width: 4)
                x += 0.5
                last-sign = "||"
                continue
              }

              if n == "|" {
                if last-sign == "|" {x -= 0.5}
                draw-bar(x, y)
                x += 0.5
                last-sign = "|"
                continue
              }

              if n.at(0) == "##" {
                content((x, -y + 1), eval(n.at(1), scope: eval-scope))
                continue
              }

              let last-x = x

              if n.len() == 1 {
                panic(n)
              }

              x += one-beat-length * calc.pow(2, -n.at(1))

              // pause
              if frets.len() == 0 {
                continue
              }

              for fret in frets {
                let n-y = fret.at(1)
                if fret.len() == 3 {
                  if fret.at(2) == "^" {
                    let y = - (y + n-y - 1)
                    bezier-through(
                      (last-string-x.at(n-y - 1), y - 0.5),
                      ((last-x + last-string-x.at(n-y - 1)) / 2, y - 1.0),
                      (last-x, y - 0.5),
                      stroke: rgb(1, 1, 1, 50%),
                    )
                  } else if fret.at(2) == "`" {
                    let y = - (y + n-y - 1)
                    let dy = fret.at(0) - last-tab-x.at(n-y - 1)
                    dy = sign(dy) * 0.2

                    line(
                      (last-string-x.at(n-y - 1) + 0.3, y - dy),
                      (last-x, y + dy),
                      stroke: rgb(1, 1, 1, 50%),
                    )
                  }
                }
                content(
                  (last-x, - (y + n-y - 1)),
                  highlight(fill: white, bottom-edge: "bounds", raw(str(fret.at(0)))),
                )
                last-string-x.at(n-y - 1) = last-x
                last-tab-x.at(n-y - 1) = fret.at(0)
                last-sign = "n"
              }
            }
            x += 0.5
          }

          if last-sign == "||" {x -= 1.0}
          else if last-sign == "|" {x -= 0.5}

          draw-lines(y, x: x)
          draw-bar(x, y)
          extra
        },
      )
    },
  )
}

#let to-int(s) = {
  if s.matches(regex("^\d+$")).len() != 0 { int(s) } else { panic("Bad number: " + s) }
}

#let parse-note(n, s-num: 6) = {
  if n == "p" {
    return ()
  }

  return n.split("+").map(
    n => {
      let cont = if n.starts-with("^") { "^" } else if n.starts-with("`") { "`" } else { none }
      if cont != none { n = n.slice(1) }
      let coords = n.split("/").map(to-int)
      if coords.len() != 2 {
        panic("Specify fret and string numbers separated by `/`: " + n)
      }
      if coords.at(1) > s-num {
        panic("Too large string number: " + n.at(1))
      }
      if cont != none { coords.push(cont) }
      return coords
    },
  )
}

#let gen(s, s-num: 6) = {
  if type(s) == "content" {
    s = s.text
  }

  let bars = ()
  let cur-bar = ()
  let cur-dur = 2
  let code-mode = false
  let code = ()

  for (n, s,) in s.split(regex("\s+")).zip(s.matches(regex("\s+")) + ("",)) {
    if n == "##" and not code-mode {
      code-mode = true
      continue
    }

    if code-mode {
      if n == "##" {
        code-mode = false
        cur-bar.push(("##", code.join()))
        code = ()
        continue
      }

      code.push(n)
      code.push(s.text)
      continue
    }

    if n == "<" {
      cur-bar.push(n)
      continue
    }

    if n == ":|" {
      cur-bar.push(":")
      cur-bar.push("|")
      cur-bar.push("<")
      cur-bar.push("||")
      bars.push(cur-bar)
      cur-bar = ()
      n = n.slice(2)
      continue
    }

    if n == "|:" {
      cur-bar.push("||")
      cur-bar.push("|")
      cur-bar.push(":")
      bars.push(cur-bar)
      cur-bar = ()
      n = n.slice(2)
      continue
    }

    if n == "||" {
      cur-bar.push("|")
      cur-bar.push("<")
      cur-bar.push("||")
      bars.push(cur-bar)
      cur-bar = ()
      continue
    }

    if n == "|" {
      cur-bar.push("|")
      bars.push(cur-bar)
      cur-bar = ()
      continue
    }

    if n == "\\" {
      //cur-bar.push("|")
      cur-bar.push("\\")
      bars.push(cur-bar)
      cur-bar = ()
      continue
    }

    if n == "" {
      continue
    }

    let note-and-dur = n.split("-")
    if note-and-dur.len() > 2 or note-and-dur == 0 {
      panic("Specify one duration per note")
    }

    if note-and-dur.len() == 2 {
      let dur = note-and-dur.at(1)
      let mul = 1.0
      while dur.ends-with(".") {
        mul += calc.log(1.5) / calc.log(2)
        dur = dur.slice(0, -1)
      }
      cur-dur = to-int(dur) / mul
    }

    cur-bar.push((parse-note(note-and-dur.at(0), s-num: s-num), cur-dur))
  }

  if cur-bar.len() > 0 {bars.push(cur-bar)}
  return bars
}

