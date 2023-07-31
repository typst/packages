#let node(pos, label) = (kind: "node", pos: pos, label: label)

#let arr(start, end, label, start-space: none, end-space: none, label-pos: 1em, curve: 0deg, stroke: 0.45pt, ..options) = {
  (
    kind: "arrow",
    start: start,
    end: end,
    label: label,
    start-space: start-space,
    end-space: end-space,
    label-pos: label-pos,
    curve: curve,
    stroke: stroke,
    options: options.pos(),
  )
}

#let commutative-diagram(
  node-padding: (70pt, 70pt),
  arr-clearance: 0.7em,
  padding: 1.5em,
  debug: false,
  ..entities
) = {
  style(styles => {

    // useful utility function
    let center(c) = pad(left: -100%, top: -100%, c)
  
    // get nodes and arrows from the function arguments
    let entities = entities.pos()
    let nodes = entities.filter(e => e.kind == "node")
    let arrows = entities.filter(e => e.kind == "arrow")
  
    // adjust node and arrow coordinates so that the min is (0, 0)
    let min-row = calc.min(..nodes.map(node => node.pos.at(0)))
    let min-col = calc.min(..nodes.map(node => node.pos.at(1)))
    let max-row = calc.max(..nodes.map(node => node.pos.at(0)))
    let max-col = calc.max(..nodes.map(node => node.pos.at(1)))
  
    for node in nodes {
      node.pos.at(0) -= min-row
      node.pos.at(1) -= min-col
    }
  
    for arr in arrows {
      arr.start.at(0) -= min-row
      arr.start.at(1) -= min-col
      arr.end.at(0) -= min-row
      arr.end.at(1) -= min-col
    }
  
    max-row -= min-row
    max-col -= min-col
    min-col = 0
    min-row = 0
  
    // measure the size of the various rows and columns
    let col-sizes = ()
    let row-sizes = ()
    for r in range(0, max-row+1) {
      row-sizes.push(0pt)
    }
    for c in range(0, max-col+1) {
      col-sizes.push(0pt)
    }
    for node in nodes {
      let m = measure(node.label, styles)
      if m.width > col-sizes.at(node.pos.at(1)) {
        col-sizes.at(node.pos.at(1)) = m.width
      }
      if m.height > row-sizes.at(node.pos.at(0)) {
        row-sizes.at(node.pos.at(0)) = m.height
      }
    }
    let row-pos = row-sizes
    let col-pos = col-sizes
    row-pos.at(0) /= 2
    col-pos.at(0) /= 2
    for r in range(1, max-row+1) {
      row-pos.at(r) += row-pos.at(r - 1) + node-padding.at(1)
    }
    for c in range(1, max-col+1) {
      col-pos.at(c) += col-pos.at(c - 1) + node-padding.at(0)
    }
  
    // total diagram dimensions
    let height = row-sizes.fold(-node-padding.at(1), (x, y) => x+y+node-padding.at(1))
    let width = col-sizes.fold(-node-padding.at(0), (x, y) => x+y+node-padding.at(0))

    // useful functions used many times later
    let coords(pos) = (
      col-pos.at(pos.at(1)), row-pos.at(pos.at(0))
    )
  
    let size-at(pos) = {
      for node in nodes {
        if node.pos == pos {
          return measure(node.label, styles)
        }
      }
      return (width: 0pt, height: 0pt)
    }
  
    // various vector utility functions
    let v-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
    let v-sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
    let v-mul(a, x) = (a.at(0) * x, a.at(1) * x)
    let v-add-dir(p, a, l) = v-add(p, v-mul((calc.cos(a), calc.sin(a)), l))
    let v-length(vv) = calc.sqrt(vv.at(0)/1mm*vv.at(0)/1mm + vv.at(1)/1mm*vv.at(1)/1mm)*1mm
  
    // measures the length of a segment starting in the center
    // of a rectangle and ending on one of the rectangle's edges,
    // given the angle of the segment
    let measure-at-angle(m, a, padding) = {
      if calc.sin(a) == 0 {
        m.width / 2 + padding
      } else if calc.cos(a) == 0 {
        m.height / 2 + padding
      } else {
        calc.min(
          (m.width / 2 + padding) / calc.abs(calc.cos(a)), 
          (m.height / 2 + padding) / calc.abs(calc.sin(a)),
          calc.max(m.width, m.height) / 2 + padding,
        )
      }
    }
  
    let pt-per-em = measure(rect(width: 1em), styles).width

    // the box where all the diagram's elements are
    box(
      width: width + 2*padding, height: height + 2*padding,
      stroke: if debug { 0.5pt + red } else { none },
      inset: padding,
      {
      for arr in arrows {
        let start = coords(arr.start)
        let end = coords(arr.end)
        let angle = calc.atan2((end.at(0) - start.at(0)) / 1pt, (end.at(1) - start.at(1)) / 1pt)
        let curve-angle = arr.curve
        let start-space = arr.start-space
        let end-space = arr.end-space
        if start-space == none {
          start-space = measure-at-angle(size-at(arr.start), angle - curve-angle, arr-clearance / 1em * pt-per-em) / pt-per-em * 1em
        }
        if end-space == none {
          end-space = measure-at-angle(size-at(arr.end), angle + curve-angle, arr-clearance / 1em * pt-per-em) / pt-per-em * 1em
        }
        if "inj" in arr.options {
          start-space += 0.2em
        }
        let astart = v-add-dir(start, angle - curve-angle, start-space)
        let aend = v-add-dir(end, angle + 180deg + curve-angle, end-space)
      
        // more hacky, but more beautiful
        place(dx: aend.at(0), dy: aend.at(1),
          rotate(angle + curve-angle + 90deg, origin: top+left,
            if "surj" in arr.options {
              move(dy: 0.3em, center(box[
                $arrow.t.twohead$
                #place(dy: -0.35em, dx: 0.24em, rect(width: 0.10em, height: 0.7em, fill: white))
              ]))
            } else {
              move(dy: 0.3em, center(box[
                $arrow.t$
                #place(dy: -0.50em, dx: 0.2em, rect(width: 0.10em, height: 0.7em, fill: white))
              ]))
            }
          )
        )

        place(dx: astart.at(0), dy: astart.at(1),
          rotate(angle - curve-angle - 90deg, origin: top+left, {
            if "bij" in arr.options {
              move(dy: 0.25em, center(box[
              $arrow.t$
              #place(dy: -0.50em, dx: 0.20em, rect(width: 0.10em, height: 0.7em, fill: white))
            ]))
            } else if "inj" in arr.options {
              place(pad(top: -100%, circle(stroke: arr.stroke, radius: 0.15em))) + rect(width: 0.33em, height: 0.2em, fill:white)
            } else if "def" in arr.options {
              place(dx: -0.2em, line(stroke: arr.stroke, length: 0.4em))
            }  
            })
        )
      
        let N = int(20*calc.abs(curve-angle / 1rad) + 1)
        let frac = 1
        if "dashed" in arr.options {
          N = int((v-length(v-sub(start, end)) - (start-space + end-space) / 1em * pt-per-em) / 8pt)
          frac = 0.7
        }
        let normal = (- aend.at(1) + astart.at(1), aend.at(0) - astart.at(0))
        let t = calc.tan(curve-angle)
        for i in range(-N, N) {
          place(line(
            start: v-add(v-add(v-mul(astart, (N -i)/(2*N)), v-mul(aend, (N+i)/(2*N))),
              v-mul(normal, (i - N)*(i + N)/N/N/4*t)),
            end: v-add(v-add(v-mul(astart, (N -i -frac)/(2*N)), v-mul(aend, (N+i+frac)/(2*N))),
              v-mul(normal, (i +frac - N)*(i+frac + N)/N/N/4*t)),
            stroke: arr.stroke,
          ))
        }
      
        let middle = v-add(v-mul(v-add(astart, aend), 0.5), v-mul(normal, -t/4))
      
        if arr.label-pos == 0 {
          place(dx: middle.at(0), dy: middle.at(1), center(rect(fill: white, arr.label, outset:-0.2em)))
        } else {
          let lpos = v-add-dir(middle, angle - 90deg, arr.label-pos)
          place(dx: lpos.at(0), dy: lpos.at(1), center(arr.label))
        }
      }
  
      for node in nodes {
        let coords = coords(node.pos)
        place(
          dx: coords.at(0),
          dy: coords.at(1),
          center(node.label)
        )
        if debug {
          let m = measure(node.label, styles)
          place(
            dx: coords.at(0),
            dy: coords.at(1),
            center(rect(width: m.width + 2 * arr-clearance, height: m.height + 2 * arr-clearance, stroke: 0.5pt+red)),
          )
          place(
            dx: coords.at(0),
            dy: coords.at(1),
            center(circle(radius: calc.max(m.width, m.height) / 2 + arr-clearance, stroke: 0.5pt+red)),
          )
        }
      }
    })
  })
}
