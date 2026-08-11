// utility functions
// no imports

#let show-set(
  text-args: (:),
  par-args: (:),
) = {
  it => {
    set text(..text-args)
    set par(..par-args)
    it
  }
}

// #import "@preview/t4t:0.4.3": get
// borrowed code for portability
#let all-of-type(t, ..values) = values.pos().all(v => std.type(v) == t)
#let dict-merge(..dicts) = {
  if all-of-type(dictionary, ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

#let crop-marks(
  distance: 9.5pt,
  length: 8pt,
  offset: 6pt,
  stroke: 0.2pt + black,
) = {
  place(bottom + left, dx: 0pt, dy: 0pt)[#line(
      start: (distance, -length + offset),
      end: (distance, -offset),
      stroke: stroke,
    )]
  place(bottom + left, dx: 0pt, dy: 0pt)[#line(
      start: (0pt + offset, -distance),
      end: (length - offset, -distance),
      stroke: stroke,
    )]
  place(top + left, dx: 0pt, dy: 0pt)[#line(
      start: (distance, 0pt + offset),
      end: (distance, length - offset),
      stroke: stroke,
    )]
  place(top + left, dx: 0pt, dy: 0pt)[#line(
      start: (0pt + offset, distance),
      end: (length - offset, distance),
      stroke: stroke,
    )]

  place(bottom + right, dx: 0pt, dy: 0pt)[#line(
      start: (-distance, -length + offset),
      end: (-distance, -offset),
      stroke: stroke,
    )]
  place(bottom + right, dx: 0pt, dy: 0pt)[#line(
      start: (-length + offset, -distance),
      end: (-offset, -distance),
      stroke: stroke,
    )]
  place(top + right, dx: 0pt, dy: 0pt)[#line(
      start: (-distance, length - offset),
      end: (-distance, offset),
      stroke: stroke,
    )]
  place(top + right, dx: 0pt, dy: 0pt)[#line(
      start: (-length + offset, distance),
      end: (-offset, distance),
      stroke: stroke,
    )]
}


#let figma-layout(j) = {
  let content = j.document.children.at(0).children.at(0)
  (
    container: content.absoluteBoundingBox,
    frames: content
      .children
      .filter(c => not "visible" in c.keys())
      .map(c => {
        ((c.name): c.absoluteBoundingBox)
      })
      .join(),
  )
}


