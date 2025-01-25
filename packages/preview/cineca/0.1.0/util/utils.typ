#let minutes-to-datetime(minutes) = {
  let h = calc.trunc(minutes / 60)
  let m = int(calc.round(calc.fract(minutes / 60) * 60))
  return datetime(hour: h, minute: m, second: 0)
}

#let events-to-calendar-items(events, start) = {
  let dict = (:)
  for value in events {
    if value.len() < 4 {
      continue
    }
    let kday = str(value.at(0))
    let stime = float(value.at(1))
    let etime = float(value.at(2))
    let body = value.at(3)
    if not dict.keys().contains(kday) {
      dict.insert(kday, (:))
    }
    let istart = calc.min((calc.trunc(stime) - start), 24) * 60 + calc.min(calc.round(calc.fract(stime) * 100), 60)
    let iend = calc.min((calc.trunc(etime) - start), 24) * 60 + calc.min(calc.round(calc.fract(etime) * 100), 60)
    let ilast = iend - istart
    if ilast > 0 {
      dict.at(kday).insert(str(istart), (ilast, body))
    }
  }
  dict
}

#let default-header-style(day) = {
  show: pad.with(y: 8pt)
  set align(center + horizon)
  set text(weight: "bold")
  [Day #{day+1}]
}

#let default-item-style(time, body) = {
  show: block.with(
    fill: white,
    height: 100%,
    width: 100%,
    stroke: (
      left: blue + 2pt,
      rest: blue.lighten(30%) + 0.4pt
    ),
    inset: (rest: 0.4pt, left: 2pt),
    clip: true
  )
  show: pad.with(2pt)
  set par(leading: 4pt)
  if time != none {
    terms(
      terms.item(time.display("[hour]:[minute]"), body)
    )
  } else {
    body
  }
}

#let default-time-style(time) = {
  show: pad.with(x: 2pt)
  move(dy: -4pt, time.display("[hour]:[minute]"))
}
