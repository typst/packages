// CREDITS: Inspired by the 'cheq' package (https://typst.app/universe/package/cheq/)
#let checktion(
  doc,
  unchecked-stroke-color: rgb("#373530"), // Notion default text color
  checked-fill-color: blue,
  checkmark-stroke-color: white,
  checked-stroke-color: blue,
  checked-stroke-thickness: 0.08em, 
) = {

  let cb-size = 0.8em
  let cb-radius = 0.12em
  let cb-stroke = 0.08em

  let cb-baseline = 0.0em // Baseline anchor (does nothing betweeen 0.0 and 0.6em)
  let cb-offset = -0.04em // Vertical offset between checkbox and text

  let cb-unchecked() = move(
  dy: cb-offset,
  box(
    width: cb-size,
    height: cb-size,
    baseline: cb-baseline,
    box(
      width: cb-size,
      height: cb-size,
      radius: cb-radius,
      stroke: cb-stroke + unchecked-stroke-color,
      fill: none,
    )
  )
  )
  
  let cb-checked() = move(
    dy: cb-offset,
    box(
    width: 0.8em,
    height: 0.8em,
    radius: 0.12em,
    fill: checked-fill-color,
    stroke: checked-stroke-thickness + checked-stroke-color,
  )[
      // Overlay checkmark strokes (relative to the checkbox) using `place`
      #place(center, dx: -0.13em, dy: 0.54em)[
        #rotate(40deg, reflow: false,
          line(
            length: 0.19em,
            stroke: (paint: checkmark-stroke-color, thickness: 0.08em, cap: "round"),
          )
        )
      ]
    
      #place(center, dx: 0.09em, dy: 0.40em)[
        #rotate(-56deg, reflow: false,
          line(
            length: 0.50em,
            stroke: (paint: checkmark-stroke-color, thickness: 0.08em, cap: "round"),
          )
        )
      ]
    ]
  )

  show list: it => {
    let marker-default = if type(it.marker) == array { it.marker.at(0) } else { it.marker }
  
    let out-items = ()
    let out-markers = ()
    let is-checklist = false
  
    for child in it.children {
      // Only handle items whose body is a content block ("[...]")
      if not (type(child.body) == content and child.body.func() == [].func()) {
        out-markers.push(marker-default)
        out-items.push(child.body)
      } else {
        let c = child.body.children
  
        // Expect: "[", (marker), "]", space, rest...
        if c.len() >= 5 and c.at(0) == [#"["] and c.at(2) == [#"]"] and c.at(3) == [ ] {
          let m = {
            if c.at(1) == [ ] { " " }
            else if c.at(1).has("text") { c.at(1).text }
            else { none }
          }
  
          if m == " " {
            is-checklist = true
            out-markers.push(cb-unchecked())
            out-items.push(c.slice(4).sum())
          } else if m == "X" or m == "x" {
            is-checklist = true
            out-markers.push(cb-checked())
            out-items.push(c.slice(4).sum())
          } else {
            out-markers.push(marker-default)
            out-items.push(child.body)
          }
        } else {
          out-markers.push(marker-default)
          out-items.push(child.body)
        }
      }
    }
  
    if is-checklist {
      // Render as an enum
      enum(
        numbering: (.., n) => out-markers.at(n - 1),
        tight: it.tight,
        indent: it.indent,
        body-indent: it.body-indent,
        spacing: it.spacing,
        ..out-items,
      )
    } else {
      it
    }
  }

  doc
}

