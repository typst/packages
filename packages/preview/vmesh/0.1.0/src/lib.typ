// lib.typ
// Main entry point for the Gmsh Typst package using CeTZ

#import "gmsh-parser.typ": parse-msh
#import "@preview/cetz:0.5.0"

#let default-color-map = (
  "0": blue.lighten(20%),
)

#let project-3d(pt, pitch, yaw) = {
  let (x, y, z) = pt

  let x1 = x * calc.cos(yaw) - y * calc.sin(yaw)
  let y1 = x * calc.sin(yaw) + y * calc.cos(yaw)
  let z1 = z

  let x2 = x1
  let y2 = y1 * calc.cos(pitch) - z1 * calc.sin(pitch)
  let z2 = y1 * calc.sin(pitch) + z1 * calc.cos(pitch)

  ((x2, y2), z2)
}

#let draw-mesh(
  msh-string,
  width: auto,
  height: auto,
  mesh-stroke: 0.5pt + white,
  fill-elements: true,
  color-map: default-color-map,
  edge-stroke-map: (:),
  pitch: 0deg,
  yaw: 0deg,
  use-lighting: true,
  light-direction: (-0.5, -0.5, 0.707),
  show-node-ids: false,
  show-element-ids: false,
  show-domain-ids: false,
  show-axes: false,
  id-size: 6pt,
) = layout(size => {
  let mesh-data = parse-msh(msh-string)
  let nodes = mesh-data.nodes
  let elements = mesh-data.elements

  let projected-nodes = (:)
  for (n-id, n-data) in nodes.pairs() {
    let pt = (float(n-data.at(0)), float(n-data.at(1)), float(n-data.at(2)))
    projected-nodes.insert(n-id, project-3d(pt, pitch, yaw))
  }

  let x-vals = projected-nodes.values().map(p => p.at(0).at(0))
  let y-vals = projected-nodes.values().map(p => p.at(0).at(1))

  let min-x = if x-vals.len() > 0 { calc.min(..x-vals) } else { 0.0 }
  let max-x = if x-vals.len() > 0 { calc.max(..x-vals) } else { 1.0 }
  let min-y = if y-vals.len() > 0 { calc.min(..y-vals) } else { 0.0 }
  let max-y = if y-vals.len() > 0 { calc.max(..y-vals) } else { 1.0 }

  let dx = max-x - min-x
  let dy = max-y - min-y
  if dx <= 0 { dx = 1.0 }
  if dy <= 0 { dy = 1.0 }

  let scale-len = 1cm

  // Convert relative ratios or fractions to absolute lengths based on container layout
  let resolve-len(l, ref-size) = {
    if type(l) == ratio { (l / 100%) * ref-size } else { l }
  }

  let final-width = if width == auto { resolve-len(100%, size.width) } else { resolve-len(width, size.width) }
  let final-height = if height != auto { resolve-len(height, size.height) } else { none }

  if height != auto and width != auto {
    scale-len = calc.min(final-width / dx, final-height / dy)
  } else if height != auto {
    scale-len = final-height / dy
  } else {
    // Default: Fit to width
    scale-len = final-width / dx
  }

  // To perfectly autogen boundaries relative to origin, we can also auto-center the grid
  // by calculating the bounding box offset. We'll wrap all drawing commands in a group
  // shifted by the center. But CetZ automatically tightens bounding boxes on compilation,
  // so just updating the coordinates directly using local lengths works!
  cetz.canvas(length: scale-len, {
    import cetz.draw: *

    let render-elements = ()
    let all-faces = ()

    if show-axes {
      let w-x-vals = nodes.values().map(n => float(n.at(0)))
      let w-y-vals = nodes.values().map(n => float(n.at(1)))
      let w-z-vals = nodes.values().map(n => float(n.at(2)))

      let w-min-x = if w-x-vals.len() > 0 { calc.min(..w-x-vals) } else { 0.0 }
      let w-max-x = if w-x-vals.len() > 0 { calc.max(..w-x-vals) } else { 1.0 }
      let w-min-y = if w-y-vals.len() > 0 { calc.min(..w-y-vals) } else { 0.0 }
      let w-max-y = if w-y-vals.len() > 0 { calc.max(..w-y-vals) } else { 1.0 }
      let w-min-z = if w-z-vals.len() > 0 { calc.min(..w-z-vals) } else { 0.0 }
      let w-max-z = if w-z-vals.len() > 0 { calc.max(..w-z-vals) } else { 1.0 }

      let len-x = w-max-x - w-min-x
      if len-x <= 0 { len-x = 1.0 }
      let len-y = w-max-y - w-min-y
      if len-y <= 0 { len-y = 1.0 }
      let len-z = w-max-z - w-min-z
      if len-z <= 0 { len-z = 1.0 }

      let pt-origin = (w-min-x, w-min-y, w-min-z)
      let pt-x = (w-max-x + len-x * 0.2, w-min-y, w-min-z)
      let pt-y = (w-min-x, w-max-y + len-y * 0.2, w-min-z)
      let pt-z = (w-min-x, w-min-y, w-max-z + len-z * 0.2)

      let pt-x-l = (w-max-x + len-x * 0.25, w-min-y, w-min-z)
      let pt-y-l = (w-min-x, w-max-y + len-y * 0.25, w-min-z)
      let pt-z-l = (w-min-x, w-min-y, w-max-z + len-z * 0.25)

      let p-o = project-3d(pt-origin, pitch, yaw)

      if w-max-x - w-min-x > 1e-5 {
        let p-x = project-3d(pt-x, pitch, yaw)
        let p-x-l = project-3d(pt-x-l, pitch, yaw)
        render-elements.push((
          depth: (p-o.at(1) + p-x.at(1)) / 2.0,
          pts: (p-o.at(0), p-x.at(0), p-x-l.at(0)),
          elm-type: "axis",
          domain-id: 0,
          elm-fill: red.darken(20%),
          elm-id: "X",
        ))
      }

      if w-max-y - w-min-y > 1e-5 {
        let p-y = project-3d(pt-y, pitch, yaw)
        let p-y-l = project-3d(pt-y-l, pitch, yaw)
        render-elements.push((
          depth: (p-o.at(1) + p-y.at(1)) / 2.0,
          pts: (p-o.at(0), p-y.at(0), p-y-l.at(0)),
          elm-type: "axis",
          domain-id: 0,
          elm-fill: green.darken(20%),
          elm-id: "Y",
        ))
      }

      if w-max-z - w-min-z > 1e-5 {
        let p-z = project-3d(pt-z, pitch, yaw)
        let p-z-l = project-3d(pt-z-l, pitch, yaw)
        render-elements.push((
          depth: (p-o.at(1) + p-z.at(1)) / 2.0,
          pts: (p-o.at(0), p-z.at(0), p-z-l.at(0)),
          elm-type: "axis",
          domain-id: 0,
          elm-fill: blue.darken(20%),
          elm-id: "Z",
        ))
      }
    }

    for elm in elements {
      let elm-type = elm.type
      let elm-node-ids = elm.nodes
      let domain-id = elm.physical-tag
      if domain-id == 0 {
        domain-id = elm.geometrical-tag
      }

      let elm-fill = none
      if fill-elements {
        elm-fill = color-map.at(str(domain-id), default: blue.lighten(20%))
      }

      if elm-type in (1, 2, 3) {
        all-faces.push((
          nodes: elm-node-ids,
          type: elm-type,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: false,
        ))
      } else if elm-type == 4 and elm-node-ids.len() == 4 {
        // Tetrahedron
        let n = elm-node-ids
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(2)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(0), n.at(2), n.at(3)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(0), n.at(3), n.at(1)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(1), n.at(3), n.at(2)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
      } else if elm-type == 5 and elm-node-ids.len() == 8 {
        // Hexahedron
        let n = elm-node-ids
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(5), n.at(4)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(1), n.at(2), n.at(6), n.at(5)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(2), n.at(3), n.at(7), n.at(6)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(3), n.at(0), n.at(4), n.at(7)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(2), n.at(3)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(4), n.at(5), n.at(6), n.at(7)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
      } else if elm-type == 6 and elm-node-ids.len() == 6 {
        // Prism
        let n = elm-node-ids
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(2)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(3), n.at(4), n.at(5)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(4), n.at(3)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(1), n.at(2), n.at(5), n.at(4)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(2), n.at(0), n.at(3), n.at(5)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
      } else if elm-type == 7 and elm-node-ids.len() == 5 {
        // Pyramid
        let n = elm-node-ids
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(2), n.at(3)),
          type: 3,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(0), n.at(1), n.at(4)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(1), n.at(2), n.at(4)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(2), n.at(3), n.at(4)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
        all-faces.push((
          nodes: (n.at(3), n.at(0), n.at(4)),
          type: 2,
          domain: domain-id,
          fill: elm-fill,
          id: elm.id,
          is-3d: true,
        ))
      }
    }

    let face-meta = (:)
    let face-data = (:)

    for f in all-faces {
      let sorted-n = f.nodes.sorted()
      let key = sorted-n.join("-")

      let meta = face-meta.at(key, default: (count: 0, is-explicit: false))
      if f.is-3d {
        meta.count += 1
      } else {
        meta.is-explicit = true
      }
      face-meta.insert(key, meta)

      if (not f.is-3d) or (key not in face-data) {
        face-data.insert(key, (nodes: f.nodes, type: f.type, domain: f.domain, fill: f.fill, id: f.id))
      }
    }

    for (key, meta) in face-meta.pairs() {
      if meta.is-explicit or meta.count == 1 {
        let fd = face-data.at(key)
        let elm-nodes-proj = fd.nodes.map(id => projected-nodes.at(id, default: none)).filter(c => c != none)

        if elm-nodes-proj.len() == fd.nodes.len() and elm-nodes-proj.len() > 0 {
          let depth = elm-nodes-proj.map(c => c.at(1)).sum() / elm-nodes-proj.len()

          // Nudge depth slightly so 1D lines draw on top of 2D surfaces when they are perfectly flat
          if fd.type == 1 {
            depth += 0.001
          }
          let pts = elm-nodes-proj.map(c => c.at(0))

          let final-fill = fd.fill
          if use-lighting and fd.fill != none and fd.nodes.len() >= 3 {
            let n0 = nodes.at(fd.nodes.at(0))
            let n1 = nodes.at(fd.nodes.at(1))
            let n2 = nodes.at(fd.nodes.at(2))

            let ax = float(n1.at(0)) - float(n0.at(0))
            let ay = float(n1.at(1)) - float(n0.at(1))
            let az = float(n1.at(2)) - float(n0.at(2))

            let bx = float(n2.at(0)) - float(n0.at(0))
            let by = float(n2.at(1)) - float(n0.at(1))
            let bz = float(n2.at(2)) - float(n0.at(2))

            let nx = ay * bz - az * by
            let ny = az * bx - ax * bz
            let nz = ax * by - ay * bx

            let len = calc.sqrt(nx * nx + ny * ny + nz * nz)
            if len == 0 { len = 1.0 }
            nx = nx / len
            ny = ny / len
            nz = nz / len

            // Find camera view vector
            let cam-x = calc.sin(yaw) * calc.sin(pitch)
            let cam-y = calc.cos(yaw) * calc.sin(pitch)
            let cam-z = calc.cos(pitch)

            // Flip normal to face the camera (handles arbitrary winding order)
            if (nx * cam-x + ny * cam-y + nz * cam-z) < 0 {
              nx = -nx
              ny = -ny
              nz = -nz
            }

            let lx = 0.0
            let ly = 0.0
            let lz = 1.0

            if light-direction == auto {
              // Fallback if user explicitly requests auto
              let cam-x = calc.sin(yaw) * calc.sin(pitch)
              let cam-y = calc.cos(yaw) * calc.sin(pitch)
              let cam-z = calc.cos(pitch)
              lx = cam-x
              ly = cam-y
              lz = cam-z
            } else {
              let (dir-x, dir-y, dir-z) = light-direction
              lx = dir-x
              ly = dir-y
              lz = dir-z
            }

            let llen = calc.sqrt(lx * lx + ly * ly + lz * lz)
            if llen == 0 { llen = 1.0 }
            lx = lx / llen
            ly = ly / llen
            lz = lz / llen

            let dot = nx * lx + ny * ly + nz * lz
            if dot < 0 { dot = 0.0 }

            let ambient = 0.3
            let diffuse = 0.7 * dot
            let factor = ambient + diffuse

            final-fill = final-fill.darken((1.0 - factor) * 100%)
          }

          render-elements.push((
            depth: depth,
            pts: pts,
            elm-type: fd.type,
            domain-id: fd.domain,
            elm-fill: final-fill,
            elm-id: fd.id,
          ))
        }
      }
    }

    if show-domain-ids {
      let domain-centers = (:)
      for elm in elements {
        let p-tag = elm.physical-tag
        if p-tag != 0 {
          let d = str(p-tag)
          if d not in domain-centers {
            domain-centers.insert(d, (x: 0.0, y: 0.0, z: 0.0, count: 0))
          }
          let dc = domain-centers.at(d)
          for n-id in elm.nodes {
            let pt = nodes.at(str(n-id))
            dc.x += float(pt.at(0))
            dc.y += float(pt.at(1))
            dc.z += float(pt.at(2))
            dc.count += 1
          }
          domain-centers.insert(d, dc)
        }
      }

      for (d-id, dc) in domain-centers.pairs() {
        let center-3d = (dc.x / dc.count, dc.y / dc.count, dc.z / dc.count)
        let proj = project-3d(center-3d, pitch, yaw)
        render-elements.push((
          depth: proj.at(1) + 0.05,
          pts: (proj.at(0),),
          elm-type: "domain-label",
          domain-id: int(d-id),
          elm-fill: black,
          elm-id: d-id,
        ))
      }
    }

    let sorted-elements = render-elements.sorted(key: e => e.depth)

    for re in sorted-elements {
      let pts = re.pts
      let elm-type = re.elm-type
      let domain-id = re.domain-id
      let elm-fill = re.elm-fill

      if elm-type == "domain-label" {
        content(pts.at(0), box(fill: white.transparentize(20%), inset: 2pt, radius: 2pt, text(
          size: id-size * 1.5,
          fill: elm-fill,
          weight: "bold",
        )[#re.elm-id]))
      } else if elm-type == "axis" {
        line(pts.at(0), pts.at(1), stroke: 1.5pt + elm-fill)
        content(pts.at(2), text(size: 10pt, fill: elm-fill, weight: "bold")[#re.elm-id])
      } else if elm-type == 1 and pts.len() == 2 {
        let e-stroke = edge-stroke-map.at(str(domain-id), default: mesh-stroke)
        line(..pts, stroke: e-stroke)
      } else if (elm-type == 2 and pts.len() == 3) or (elm-type == 3 and pts.len() == 4) {
        line(..pts, close: true, stroke: mesh-stroke, fill: elm-fill)
      }

      if show-element-ids {
        let cx = pts.map(c => c.at(0)).sum() / pts.len()
        let cy = pts.map(c => c.at(1)).sum() / pts.len()
        content((cx, cy), text(size: id-size, fill: luma(80), style: "italic")[#re.elm-id])
      }
    }

    if show-node-ids {
      for (n-id, n-data) in projected-nodes.pairs() {
        content(n-data.at(0), text(size: id-size, fill: black, weight: "bold")[#n-id])
      }
    }
  })
})
