#import "@preview/cetz:0.3.3"
#import "@preview/suiji:0.3.0"

#let s(start) = {
  let end = (rel: start, to: (0, 2.0))
  (start, end)
}

#let l(start) = {(start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (-0.3,1.0)),
  (rel: start, to: (0.0,1.5)),
  (rel: start, to: (0.0, 2.0)),
)}

#let r(start) = {(
  start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (0.3,1.0)),
  (rel: start, to: (0.0,1.5)),
  (rel: start, to: (0.0,2.0)),
)}

#let lr(start) = {(
  start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (0.3,1.5)),
  (rel: start, to: (0.3,2.0)),
)}

#let rl(start) = {(
  start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (-0.3,1.5)),
  (rel: start, to: (-0.3,2.0)),
)}

#let ll(start) = {(
  start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (0.6,1.5)),
  (rel: start, to: (0.6,2.0)),
)}

#let rr(start) = {(
  start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (-0.6,1.5)),
  (rel: start, to: (-0.6,2.0)),
)}

#let rrl(start) = { (
  start,
  (rel: start, to: (0.0,0.5)),
  (rel: start, to: (0.6,1.5)),
  (rel: start, to: (0.6,2.0)),
)}

#let knots = (at => (
  s((rel: (-0.3,0), to: at)),
  s(at),
  s((rel: (0.3,0), to: at)),
),at => (
  lr((rel: (-0.3,0), to: at)),
  rl(at),
  s((rel: (0.3,0), to: at)),
),at => (
  rl(at),
  lr((rel: (-0.3,0), to: at)),
  s((rel: (0.3,0), to: at)),
),at =>(
  s((rel: (-0.3,0), to: at)),
  rl((rel: (0.3,0), to: at)),
  lr(at),
),at =>(
  s((rel: (-0.3,0), to: at)),
  lr(at),
  rl((rel: (0.3,0), to: at)),
),at => (
  ll((rel: (-0.3,0), to: at)),
  rl(at),
  rl((rel: (0.3,0), to: at)),
),at => (
  rr((rel: (0.3,0), to: at)),
  lr((rel: (-0.3,0), to: at)),
  lr(at),
),at => (
  rl(at),
  ll((rel: (-0.3,0), to: at)),
  rl((rel: (0.3,0), to: at)),
),at => (
  lr((rel: (-0.3,0), to: at)),
  rr((rel: (0.3,0), to: at)),
  lr(at),
),at => (
  lr(at),
  rr((rel: (0.3,0), to: at)),
  lr((rel: (-0.3,0), to: at)),
),at => (
  lr(at),
  rr((rel: (0.3,0), to: at)),
  lr((rel: (-0.3,0), to: at)),
),at => (
  ll((rel: (-0.3,0), to: at)),
  r(at),
  rr((rel: (0.3,0), to: at)),
),at => (
  rr((rel: (0.3,0), to: at)),
  r(at),
  ll((rel: (-0.3,0), to: at)),
),at => (
  r(at),
  ll((rel: (-0.3,0), to: at)),
  rr((rel: (0.3,0), to: at)),
),at => (
  r(at),
  rr((rel: (0.3,0), to: at)),
  ll((rel: (-0.3,0), to: at)),
),at => (
  rr((rel: (0.3,0), to: at)),
  ll((rel: (-0.3,0), to: at)),
  r(at),
),at => (
  rr((rel: (0.3,0), to: at)),
  ll((rel: (-0.3,0), to: at)),
  r(at),
),at => (
  ll((rel: (-0.3,0), to: at)),
  l(at),
  rr((rel: (0.3,0), to: at)),
),at => (
  rr((rel: (0.3,0), to: at)),
  l(at),
  ll((rel: (-0.3,0), to: at)),
),at => (
  l(at),
  ll((rel: (-0.3,0), to: at)),
  rr((rel: (0.3,0), to: at)),
),at => (
  l(at),
  rr((rel: (0.3,0), to: at)),
  ll((rel: (-0.3,0), to: at)),
),at => (
  rr((rel: (0.3,0), to: at)),
  ll((rel: (-0.3,0), to: at)),
  l(at),
),at => (
  rr((rel: (0.3,0), to: at)),
  ll((rel: (-0.3,0), to: at)),
  l(at),
))

#let seed-from-author(author) = author.codepoints().fold(0, (acc,x) => 31 * x.to-unicode() + acc)

#let rnd-braid(seed) = suiji.choice-f(
    suiji.gen-rng-f(seed),
    knots,
    size: 7
  ).at(1)

#let braid(author, colors: (bg: white, fg: yellow, outline: black)) = cetz.canvas({
  import cetz.draw: *
  let braidline(coords) = {
    let start = coords.first()
    let end = coords.last()
    line(..coords, stroke: 0.24cm + colors.outline)
    line(..coords, stroke: 0.14cm + colors.fg)
    // cover the small gaps at the beginning & end
    line(
      (rel: start, to: (0.07,0)),
      (rel: start, to: (-0.07,0)),
      stroke: 0.005cm + colors.fg,
    )
    line(
      (rel: end, to: (0.07,0)),
      (rel: end, to: (-0.07,0)),
      stroke: 0.005cm + colors.fg,
    )
  }

  for (idx, gen) in rnd-braid(seed-from-author(author)).enumerate() {
    for x in gen((0,idx*2)) + gen((0,26 - idx*2)) {
      braidline(x)
    }
  }
}, background: colors.bg)

