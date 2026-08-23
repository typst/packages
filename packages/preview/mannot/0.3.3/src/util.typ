#let default-stroke(
  stroke_like,
  paint: auto,
  thickness: auto,
  cap: auto,
  join: auto,
  dash: auto,
  miter-limit: auto,
) = {
  let s = stroke(stroke_like)
  return stroke(
    paint: if s.paint == auto { paint } else { s.paint },
    thickness: if s.thickness == auto { thickness } else { s.thickness },
    cap: if s.cap == auto { cap } else { s.cap },
    join: if s.join == auto { join } else { s.join },
    dash: if s.dash == auto { dash } else { s.dash },
    miter-limit: if s.miter-limit == auto { miter-limit } else { s.miter-limit },
  )
}

#let copy-stroke(
  stroke_like,
  paint: auto,
  thickness: auto,
  cap: auto,
  join: auto,
  dash: auto,
  miter-limit: auto,
) = {
  let s = stroke(stroke_like)
  return stroke(
    paint: if paint == auto { s.paint } else { paint },
    thickness: if thickness == auto { s.thickness } else { thickness },
    cap: if cap == auto { s.cap } else { cap },
    join: if join == auto { s.join } else { join },
    dash: if dash == auto { s.dash } else { dash },
    miter-limit: if miter-limit == auto { s.miter-limit } else { miter-limit },
  )
}
