#import "@preview/cetz:0.4.2": canvas, draw

// Draw a neural network from layer specifications
#let draw-network(
  layers,
  connections: (),
  palette: "warm",
  show-legend: false,
  scale: 100%,
  stroke-thickness: 1,
  depth-multiplier: 0.3,
  show-relu: false,
) = {


let colors-warm = (
  conv: rgb("#ffe0a1"),
  conv-relu: rgb("#ffa947"),  
  pool: rgb("#e04227"),
  unpool: rgb("#2E7D7D"),
  deconv: rgb("#88C1D0"),
  concat: rgb("#B39DDB"),
  softmax: rgb("#6A0066"),
  gap: rgb("#FF69B4"),
  fc: rgb("#B39DDB"),
  fc-relu: rgb("#9575CD"),
  sum: rgb("#70cf9b"),
  convres: rgb("#e681a8"),
  convres-relu: rgb("#ad507e"),
  convsoftmax: rgb("#6A0066"),
  input: rgb("#f7f1ed"),
  output: rgb("#6A0066"),
  custom: rgb("#dad9d7"),
  custom-relu: rgb("#a8a7a4"),
  arrow: rgb("#0f4d52"),
  connection: rgb("#0f4d52"),
)

// Cold palette
let colors-cold = (
  conv: rgb("#CDEDFE"),
  conv-relu: rgb("#89C7E8"),
  pool: rgb("#af78e6"),
  unpool: rgb("#B8A3E8"),
  deconv: rgb("#96e7c8"),
  concat: rgb("#7EC8E3"),
  softmax: rgb("#4A148C"),
  gap: rgb("#E91E63"),
  fc: rgb("#9FA8DA"),
  fc-relu: rgb("#7986CB"),
  sum: rgb("#70cf9b"),
  convres: rgb("#8edbd5"),
  convres-relu: rgb("#54adac"),
  convsoftmax: rgb("#4A148C"),
  input: rgb("#ecebf5"),
  output: rgb("#4A148C"),
  custom: rgb("#d7d9da"),
  custom-relu: rgb("#a1a4ad"),
  arrow: rgb("#0f4d52"),
  connection: rgb("#0f4d52"),
)

let strokes = (
  solid: (paint: black.lighten(20%), thickness: 0.65pt * stroke-thickness),
  hidden: (paint: gray.darken(50%).transparentize(50%), thickness: 0.45pt * stroke-thickness, dash: (1pt, 0.8pt)),
  arrow: (thickness: 0pt),
  connection: (thickness: 1pt * stroke-thickness),
)

let dynamic-color-strokes(fill) = {
  (
    solid: (paint: fill.darken(50%).saturate(80%), thickness: strokes.solid.thickness),
    hidden: (paint: fill.darken(60%).saturate(80%).transparentize(60%), thickness: strokes.hidden.thickness, dash: strokes.hidden.dash),
  )
}

let font-sizes = (
  label: 9pt,
  channel-number: 7pt,
  layer-label: 7pt,
  output-number: 8pt,
  legend-title: 10pt,
  legend-item: 8pt,
)

let opacity-values = (
  front-face: 30%,
  top-face: 30%,
  right-face: 30%,
  band: 60%,
  ball: 10%,
  edge: 70%,
)

let darken-amounts = (
  top: 0%,
  right: 0%,
)

let arrow-config = (
  triangle-size: 0.2,
  axis-y: 2.5
)

let depth-angle-deg = 45deg //calc.atan(depth-multiplier) * 180 / calc.pi

let get-depth-offsets(d) = {
  (d * depth-multiplier, d * depth-multiplier)
}

let get-y-offset-for-center-on-axis(h, d, axis-y) = {
  let (_, oy) = get-depth-offsets(d)
  axis-y - h / 2 - oy / 2
}

let get-perspective-center-y(y-offset, h, oy) = {
  y-offset + h / 2 + oy / 2
}

let get-layer-anchors(x, y, w, h, ox, oy) = {
  let center-x = x + w/2 + ox/2
  let center-y = y + h/2 + oy/2
  (
    west: (x, center-y),
    east: (x + w + ox, center-y),
    // True west/east are the geometric centers of the 3D west/east faces
    // West face center: halfway through depth, centered vertically
    true_west: (x + ox/2, center-y),
    // East face center: at right edge minus half depth, centered vertically  
    true_east: (x + w + ox/2, center-y),
    north: (center-x, y + h + oy),
    south: (center-x, y),
    anchor: (center-x, center-y),
    near: (center-x, center-y),
    northeast: (x + w + ox, y + h + oy),
    southeast: (x + w + ox, y),
    northwest: (x, y + h + oy),
    southwest: (x, y),
  )
}

let coord-along-path(start, end, pos: 1.0) = {
  (start.at(0) + (end.at(0) - start.at(0)) * pos,
   start.at(1) + (end.at(1) - start.at(1)) * pos)
}

let get-circle-boundary-point(from-pt, center-pt, radius) = {
  let dx = center-pt.at(0) - from-pt.at(0)
  let dy = center-pt.at(1) - from-pt.at(1)
  let dist = calc.sqrt(dx * dx + dy * dy)
  if dist > 0 {
    let ux = dx / dist
    let uy = dy / dist
    (center-pt.at(0) - ux * radius, center-pt.at(1) - uy * radius)
  } else {
    (center-pt.at(0) + radius, center-pt.at(1))
  }
}

let colors = if palette == "cold" { colors-cold } else { colors-warm }
let scale-factor = scale / 100%


canvas(length: 1cm * scale-factor, {
  import draw: *
  
  let scaled-font = (size) => size * scale-factor
  
  // Helper function: Draw isometric image on right face
  let draw-isometric-image(x, y, w, h, ox, oy, image) = {
    let img-height = (h) * 28.25pt * scale-factor
    let img-width = (oy / depth-multiplier) * 28.25pt * scale-factor

    let actual-img-width() = measure(image).width
    let actual-img-height() = measure(image).height

    content((x+w+ox/2,y+h/2+oy/2),
      context {
        pad(
          x: -((1+depth-multiplier) * img-height - img-width)/2,
          y: +(img-height/2 - img-width)/2
        )[ 
        #std.rotate(90deg)[
        #std.skew(ax: 45deg)[ 
        #std.rotate(-90deg)[
        #pad(
          x: -(actual-img-width() - img-width * depth-multiplier)/2,
          y: -(actual-img-height() - img-height)/2
        )[ 
        #std.scale(x: img-width * depth-multiplier, y: img-height)[ 
        #image]
        ]]]]]
      }
    )
  }
  
  let box-3d(x, y, w, h, d, fill, opacity: 1, show-left: true, show-right: true, ylabel: none, zlabel: none, is-input: false, image: none) = {
    let (ox, oy) = get-depth-offsets(d)
    let alpha = 100% - opacity * 100%
    
    let dyn-strokes = dynamic-color-strokes(fill)

    line((x, y), (x + ox, y + oy), stroke: dyn-strokes.hidden)
    line((x + ox, y + oy), (x + w + ox, y + oy), stroke: dyn-strokes.hidden)
    line((x + ox, y + oy), (x + ox, y + h + oy), stroke: dyn-strokes.hidden)
    
    rect((x, y), (x + w, y + h), fill: fill.transparentize(alpha), stroke: none)
    
    if show-left {
      line((x, y), (x, y + h), stroke: dyn-strokes.solid)
    }
    if show-right {
      line((x + w, y), (x + w, y + h), stroke: dyn-strokes.solid)
    }
    line((x, y + h), (x + w, y + h), stroke: dyn-strokes.solid)
    line((x, y), (x + w, y), stroke: dyn-strokes.solid)
    
    line((x, y + h), (x + ox, y + h + oy), (x + w + ox, y + h + oy), (x + w, y + h),
      close: true, fill: fill.darken(darken-amounts.top).transparentize(alpha), stroke: dyn-strokes.solid)
    
    // Draw right face normally
    line((x + w, y), (x + w + ox, y + oy), (x + w + ox, y + h + oy), (x + w, y + h),
      close: true, fill: fill.darken(darken-amounts.right).transparentize(alpha), stroke: dyn-strokes.solid)
    
    // DRAW IMAGE ON TOP OF RIGHT FACE WITH ISOMETRIC PERSPECTIVE
    if image != none {
      draw-isometric-image(x, y, w, h, ox, oy, image)
    }
    
    if is-input {
      if ylabel != none {
        content((x - 0.2, y + h/2), anchor: "east",
          [#text(size: scaled-font(font-sizes.layer-label), weight: "bold", str(ylabel))])
      }
      if zlabel != none {
        content((x + w/2 + ox/2, y + h + oy - 0.9), angle: depth-angle-deg,
          [#text(size: scaled-font(font-sizes.layer-label), weight: "bold", str(zlabel))])
      }
    } else {
      if ylabel != none {
        content((x - 0.3, y + h/2), anchor: "east",
          [#text(size: scaled-font(font-sizes.layer-label), str(ylabel))])
      }
      if zlabel != none {
        content((x + w/2 + ox/2, y - 0.4), angle: depth-angle-deg,
          [#text(size: scaled-font(font-sizes.layer-label), str(zlabel))])
      }
    }
  }

  // Helper function: Draw front face of a single band with optional relu split
  let draw-band-front-face(band-x, y, band-width, h, fill-color, bandfill-color, alpha, show-relu) = {
    if show-relu {
      let conv-width = band-width * 2 / 3
      rect((band-x, y), (band-x + conv-width, y + h),
        fill: fill-color.transparentize(calc.max(opacity-values.front-face, alpha)), stroke: none)
      rect((band-x + conv-width, y), (band-x + band-width, y + h),
        fill: bandfill-color.transparentize(calc.max(opacity-values.front-face, alpha)), stroke: none)
    } else {
      rect((band-x, y), (band-x + band-width, y + h),
        fill: fill-color.transparentize(calc.max(opacity-values.front-face, alpha)), stroke: none)
    }
  }
  
  // Helper function: Draw top face of a single band with optional relu split
  let draw-band-top-face(band-x, y, band-width, h, ox, oy, fill-color, bandfill-color, show-relu) = {
    if show-relu {
      let conv-width = band-width * 2 / 3
      line((band-x, y + h), (band-x + ox, y + h + oy),
        (band-x + conv-width + ox, y + h + oy), (band-x + conv-width, y + h),
        close: true,
        fill: fill-color.darken(darken-amounts.top).transparentize(opacity-values.top-face),
        stroke: none)
      line((band-x + conv-width, y + h), (band-x + conv-width + ox, y + h + oy),
        (band-x + band-width + ox, y + h + oy), (band-x + band-width, y + h),
        close: true,
        fill: bandfill-color.darken(darken-amounts.top).transparentize(opacity-values.top-face),
        stroke: none)
    } else {
      line((band-x, y + h), (band-x + ox, y + h + oy),
        (band-x + band-width + ox, y + h + oy), (band-x + band-width, y + h),
        close: true,
        fill: fill-color.darken(darken-amounts.top).transparentize(opacity-values.top-face),
        stroke: none)
    }
  }
  
  // Helper function: Draw band separator edges
  let draw-band-separator-edges(band-x, y, h, ox, oy, band-width, is-first, fill-color) = {

    let dyn-strokes = dynamic-color-strokes(fill-color)

    if is-first {
      // First band: draw the three hidden back edges
      line((band-x, y), (band-x + ox, y + oy), stroke: dyn-strokes.hidden)
      line((band-x + ox, y + oy), (band-x + ox, y + h + oy), stroke: dyn-strokes.hidden)
      line((band-x + ox, y + oy), (band-x + band-width + ox, y + oy), stroke: dyn-strokes.hidden)
    } else {
      // Front vertical separator (solid)
      line((band-x, y), (band-x, y + h), stroke: dyn-strokes.solid)
      // Diagonal connector from front top to back top (solid)
      line((band-x, y + h), (band-x + ox, y + h + oy), stroke: dyn-strokes.solid)
      // Diagonal connector from front bottom to back bottom (dashed)
      line((band-x, y), (band-x + ox, y + oy), stroke: dyn-strokes.hidden)
      // Back vertical edge (dashed)
      line((band-x + ox, y + oy), (band-x + ox, y + h + oy), stroke: dyn-strokes.hidden)
      // Back horizontal edge (dashed)
      line((band-x + ox, y + oy), (band-x + band-width + ox, y + oy), stroke: dyn-strokes.hidden)
    }
  }
  
  // Helper function: Display channels labels (single label below, second label on diagonal if provided)
  let draw-channels-labels(channels, center-x, right-x, y, ox, oy) = {
    if channels != none and channels.len() > 0 {
      // First element: display below the layer
      content((center-x, y - 0.15), 
        [#text(size: scaled-font(font-sizes.channel-number), str(channels.at(0)))])
      
      // Second element (if exists): display along depth diagonal
      if channels.len() > 1 {
        let diag-mid-x = right-x + ox / 2.5
        let diag-mid-y = y + oy / 2.5
        content((diag-mid-x, diag-mid-y - 0.23), angle: depth-angle-deg,
          [#text(size: scaled-font(font-sizes.channel-number), str(channels.at(1)))])
      }
    }
  }
  
  let draw-arrow-icon(x1, y1, x2, y2, opacity: 0.7) = {
    let dx = x2 - x1
    let dy = y2 - y1
    let len = calc.sqrt(dx * dx + dy * dy)

    if len > 0 {
      let mid-x = (x1 + x2) / 2
      let mid-y = (y1 + y2) / 2
      let ux = dx / len
      let uy = dy / len
      let px = -uy
      let py = ux

      let size = arrow-config.triangle-size
      let tip = size * 0.9
      let back = size * 0.9
      let wing = size * 0.45

      let tip-pt = (mid-x + ux * tip, mid-y + uy * tip)
      let back-mid = (mid-x - ux * back, mid-y - uy * back)
      let right-pt = (back-mid.at(0) + px * wing, back-mid.at(1) + py * wing)
      let left-pt = (back-mid.at(0) - px * wing, back-mid.at(1) - py * wing)
      let back-tip = (back-mid.at(0) + ux * back * 0.5, back-mid.at(1) + uy * back * 0.5)

      let arrow-color = if opacity < 1.0 {
        colors.arrow.transparentize(100% - opacity * 100%)
      } else {
        colors.arrow
      }
      
      line(tip-pt, right-pt, back-tip, left-pt, close: true,
        fill: arrow-color, stroke: (paint: arrow-color, thickness: strokes.arrow.thickness))
    }
  }
  
  let draw-segment-with-arrow(x1, y1, x2, y2, opacity: 0.7) = {
    let paint = if opacity < 1.0 {
      colors.connection.transparentize(100% - opacity * 100%)
    } else {
      colors.connection
    }
    line((x1, y1), (x2, y2), stroke: (paint: paint, thickness: strokes.connection.thickness))
    draw-arrow-icon(x1, y1, x2, y2, opacity: opacity)
  }
  
  let draw-connection-path(segments, opacity: 0.7, layers: none, layer-positions-ref: (:), show-relu: false) = {
    // If there are layers to draw on segment idx==1, we need to split that segment
    if layers != none and layers.len() > 0 {
      // Draw first segment (idx==0) normally
      if segments.len() > 0 {
        let seg = segments.at(0)
        draw-segment-with-arrow(seg.at(0).at(0), seg.at(0).at(1), seg.at(1).at(0), seg.at(1).at(1), opacity: opacity)
      }
      
      // Process segment idx==1 with layers
      if segments.len() > 1 {
        let seg = segments.at(1)
        let seg-start = seg.at(0)
        let seg-end = seg.at(1)
        
        // Calculate positions for all layers along the segment
        let layer-infos = ()
        for layer-spec in layers {
          let layer-type = layer-spec.at("type")
          
          if layer-type == "conv" {
            let widths = layer-spec.at("widths", default: (0.5,))
            let total-width = widths.fold(0, (acc, w) => acc + w)
            let layer-h = layer-spec.at("height", default: 2)
            let layer-d = layer-spec.at("depth", default: 2)
            let (lox, loy) = get-depth-offsets(layer-d)
            
            layer-infos.push((
              spec: layer-spec,
              width: total-width,
              height: layer-h,
              depth: layer-d,
              ox: lox,
              oy: loy,
            ))
          }
        }
        
        // Calculate positions along the segment for each layer
        let num-layers = layer-infos.len()
        let positions = ()
        for (i, info) in layer-infos.enumerate() {
          let t = (i + 1) / (num-layers + 1)
          let center-x = seg-start.at(0) + (seg-end.at(0) - seg-start.at(0)) * t
          let center-y = seg-start.at(1) + (seg-end.at(1) - seg-start.at(1)) * t
          let layer-x = center-x - info.width / 2
          let layer-y = center-y - info.height / 2 - info.oy / 2
          
          // Use true_west (depth-adjusted) for connections
          let west-x = layer-x + info.ox / 2
          let east-x = layer-x + info.width + info.ox / 2
          
          positions.push((
            x: layer-x,
            y: layer-y,
            center-x: center-x,
            center-y: center-y,
            west: (west-x, center-y),
            east: (east-x, center-y),
          ))
        }
        
        // Draw connection segments and layers in proper order (interleaved)
        // First arrow: from seg-start to first layer
        if positions.len() > 0 {
          draw-segment-with-arrow(seg-start.at(0), seg-start.at(1), positions.at(0).west.at(0), positions.at(0).west.at(1), opacity: opacity)
        }
        
        // Interleave layers and arrows in propagation order
        for (i, info) in layer-infos.enumerate() {
          let pos = positions.at(i)
          let layer-spec = info.spec
          let layer-name = layer-spec.at("name", default: none)

          let mid-x = pos.x
          let mid-y = pos.y
          let total-width = info.width
          let layer-h = info.height
          let lox = info.ox
          let loy = info.oy

          let fill-color = layer-spec.at("fill", default: colors.conv)
          let bandfill-color = layer-spec.at("bandfill", default: colors.at("conv-relu"))
          let layer-opacity = layer-spec.at("opacity", default: 1.0)
          let alpha-front = 100% - layer-opacity * 100%
          let widths = layer-spec.at("widths", default: (0.5,))
          let channels = layer-spec.at("channels", default: none)
          let layer-show-relu = layer-spec.at("show-relu", default: show-relu)

          // Use dynamic color strokes for fill-color and bandfill-color
          let dyn-strokes = dynamic-color-strokes(fill-color)
          let dyn-band-strokes = dynamic-color-strokes(bandfill-color)

          // Determine if we have a diagonal label
          let has-diagonal-label = channels != none and channels.len() == widths.len() + 1
          let diagonal-label = if has-diagonal-label { channels.at(widths.len()) } else { none }

          let cumulative-x = mid-x
          for (j, w) in widths.enumerate() {
            let band-width = w
            let band-x = cumulative-x

            draw-band-front-face(band-x, mid-y, band-width, layer-h, fill-color, bandfill-color, alpha-front, layer-show-relu)

            if channels != none and j < channels.len() {
              content((band-x + band-width / 2, mid-y - 0.15), 
          [#text(size: scaled-font(font-sizes.channel-number), str(channels.at(j)))])
            }

            cumulative-x += band-width
          }

          line((mid-x, mid-y), (mid-x, mid-y + layer-h), stroke: dyn-strokes.solid)
          line((mid-x + total-width, mid-y), (mid-x + total-width, mid-y + layer-h), stroke: dyn-strokes.solid)
          line((mid-x, mid-y + layer-h), (mid-x + total-width, mid-y + layer-h), stroke: dyn-strokes.solid)
          line((mid-x, mid-y), (mid-x + total-width, mid-y), stroke: dyn-strokes.solid)

          cumulative-x = mid-x
          for (j, w) in widths.enumerate() {
            let band-width = w
            let band-x = cumulative-x

            draw-band-top-face(band-x, mid-y, band-width, layer-h, lox, loy, fill-color, bandfill-color, layer-show-relu)

            cumulative-x += band-width
          }

          let right-face-color = if layer-show-relu { bandfill-color } else { fill-color }
          let right-face-strokes = if layer-show-relu { dyn-band-strokes } else { dyn-strokes }
          line((mid-x + total-width, mid-y), (mid-x + total-width + lox, mid-y + loy),
            (mid-x + total-width + lox, mid-y + layer-h + loy), (mid-x + total-width, mid-y + layer-h),
            close: true, fill: right-face-color.darken(darken-amounts.right).transparentize(opacity-values.right-face),
            stroke: right-face-strokes.solid)

          cumulative-x = mid-x
          for (j, w) in widths.enumerate() {
            let band-width = w
            let band-x = cumulative-x
            // Use bandfill-color for band separator edges if relu, else fill-color
            let edge-strokes = if layer-show-relu { dyn-band-strokes } else { dyn-strokes }
            draw-band-separator-edges(band-x, mid-y, layer-h, lox, loy, band-width, j == 0, fill-color)
            cumulative-x += band-width
          }

          line((mid-x, mid-y + layer-h), (mid-x + lox, mid-y + layer-h + loy), stroke: dyn-strokes.solid)
          line((mid-x + lox, mid-y + layer-h + loy), (mid-x + total-width + lox, mid-y + layer-h + loy), stroke: dyn-strokes.solid)
          line((mid-x + total-width, mid-y + layer-h), (mid-x + total-width + lox, mid-y + layer-h + loy), stroke: dyn-strokes.solid)
          line((mid-x + total-width + lox, mid-y + loy), (mid-x + total-width + lox, mid-y + layer-h + loy), stroke: dyn-strokes.solid)
          line((mid-x + total-width, mid-y), (mid-x + total-width + lox, mid-y + loy), stroke: dyn-strokes.solid)
          
          let label = layer-spec.at("label", default: none)
          if label != none {
            content((mid-x + total-width / 2, mid-y - 0.5), 
              [#text(size: scaled-font(font-sizes.layer-label), weight: "bold", label)])
          }
          
          // Display diagonal label if provided
          if diagonal-label != none {
            let diag-start-x = mid-x + total-width
            let diag-start-y = mid-y
            let diag-mid-x = diag-start-x + lox / 2.5
            let diag-mid-y = diag-start-y + loy / 2.5
            content((diag-mid-x, diag-mid-y - 0.23), angle: depth-angle-deg,
              [#text(size: scaled-font(font-sizes.channel-number), str(diagonal-label))])
          }
          
          if layer-name != none {
            layer-positions-ref.insert(layer-name, (
              x: mid-x, y: mid-y, w: total-width, h: layer-h, ox: lox, oy: loy,
              anchors: get-layer-anchors(mid-x, mid-y, total-width, layer-h, lox, loy)
            ))
          }
          
          // Draw arrow to next layer (or to seg-end if this is the last layer)
          if i < layer-infos.len() - 1 {
            // Arrow to next layer
            let from-east = positions.at(i).east
            let to-west = positions.at(i + 1).west
            draw-segment-with-arrow(from-east.at(0), from-east.at(1), to-west.at(0), to-west.at(1), opacity: opacity)
          } else {
            // Last layer: arrow to seg-end
            draw-segment-with-arrow(positions.at(-1).east.at(0), positions.at(-1).east.at(1), seg-end.at(0), seg-end.at(1), opacity: opacity)
          }
        }
      }
      
      // Draw remaining segments (idx >= 2) normally
      for idx in range(2, segments.len()) {
        let seg = segments.at(idx)
        draw-segment-with-arrow(seg.at(0).at(0), seg.at(0).at(1), seg.at(1).at(0), seg.at(1).at(1), opacity: opacity)
      }
    } else {
      // No layers, draw all segments normally
      for seg in segments {
        draw-segment-with-arrow(seg.at(0).at(0), seg.at(0).at(1), seg.at(1).at(0), seg.at(1).at(1), opacity: opacity)
      }
    }
  }
  
  let x = 0
  let arrow-axis-y = arrow-config.axis-y
  let prev-center-y = arrow-axis-y
  let prev-x = 0
  let prev-depth-offset = 0
  let prev-pool-width = 0
  let used-layer-types = (:)
  let layer-positions = (:)
  let arrow-segments = (:)
  let legend-entries = (:)  // Collect legend entries: key -> (label, color)
  
  // Default legend labels for each layer type
  let default-legend-labels = (
    input: "Input",
    conv: "Convolution",
    convres: "Conv Residual",
    pool: "Pooling",
    unpool: "Unpooling",
    deconv: "Deconvolution",
    concat: "Concatenation",
    sum: "Element-wise Sum",
    gap: "Global Avg Pool",
    fc: "Fully Connected",
    convsoftmax: "Conv Softmax",
    softmax: "Softmax",
    output: "Output",
  )
  
  for (i, l) in layers.enumerate() {
    used-layer-types.insert(l.type, true)
    
    let gap = if i == 0 {
      0
    } else if l.type == "pool" or l.type == "unpool" {
      0
    } else {
      l.at("offset", default: 1.2)
    }
    
    x += gap
    
    // Calculate and store arrow segment positions for ALL layers (for skip connections)
    // But only draw arrows for non-pool/unpool/input targets
    if i > 0 and l.type != "input" {
      let prev-layer = layers.at(i - 1)
      if prev-layer.type != "input" {
        // Arrow starts from true_east of previous layer (depth-adjusted)
        let start-x = prev-x + prev-pool-width + prev-depth-offset / 2
        let start-y = prev-center-y
        
        let curr-h = l.at("height", default: 5)
        let curr-d = l.at("depth", default: 5)
        let (curr-ox, curr-oy) = get-depth-offsets(curr-d)
        let curr-y-offset = get-y-offset-for-center-on-axis(curr-h, curr-d, arrow-axis-y)
        let end-y = get-perspective-center-y(curr-y-offset, curr-h, curr-oy)
        // Arrow ends at true_west of current layer (depth-adjusted)
        // For pool/unpool with offset, calculate actual layer position first
        let is-curr-pool-or-unpool = l.type == "pool" or l.type == "unpool"
        let curr-offset = if is-curr-pool-or-unpool { l.at("offset", default: none) } else { none }
        let curr-layer-x = if curr-offset != none { x + curr-offset } else if is-curr-pool-or-unpool { x + prev-depth-offset / 2 - curr-ox / 2 } else { x }
        let end-x = curr-layer-x + curr-ox / 2
        
        let prev-name = prev-layer.at("name", default: none)
        let curr-name = l.at("name", default: none)
        
        // Store true arrow endpoints (with depth) and midpoint
        let mid-arrow-x = (start-x + end-x) / 2
        let mid-arrow-y = (start-y + end-y) / 2
        
        // Store as outgoing arrow for previous layer (includes start point and midpoint)
        if prev-name != none {
          arrow-segments.insert(prev-name + "-out", (
            start: (start-x, start-y),
            mid: (mid-arrow-x, mid-arrow-y),
            x: mid-arrow-x, 
            y: mid-arrow-y
          ))
        }
        // Store as incoming arrow for current layer (includes end point and midpoint)
        if curr-name != none {
          arrow-segments.insert(curr-name + "-in", (
            end: (end-x, end-y),
            mid: (mid-arrow-x, mid-arrow-y),
            x: mid-arrow-x,
            y: mid-arrow-y
          ))
        }
        
        // Draw arrow for non-pool/unpool layers, or pool/unpool with offset
        let is-pool-or-unpool = l.type == "pool" or l.type == "unpool"
        let has-offset = l.at("offset", default: none) != none
        if not is-pool-or-unpool or has-offset {
          draw-segment-with-arrow(start-x, start-y, end-x, end-y, opacity: 0.7)
        }
      }
    }
    
    // CUSTOM LAYER (Universal layer type with full flexibility)
    if l.type == "custom" {
      let h = l.at("height", default: 5)
      let d = l.at("depth", default: 5)
      let w = l.at("width", default: none)
      let widths = l.at("widths", default: none)
      let label = l.at("label", default: none)
      let xlabel = l.at("xlabel", default: none)
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.custom)
      let bandfill-color = l.at("bandfill", default: colors.at("custom-relu"))
      let layer-opacity = l.at("opacity", default: 0.7)
      let channels = l.at("channels", default: none)
      let ylabel-val = l.at("ylabel", default: none)
      let zlabel-val = l.at("zlabel", default: none)
      let layer-show-relu = l.at("show-relu", default: show-relu)
      let img = l.at("image", default: none)
      let is-input-style = l.at("input-style", default: false)
      
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      // Determine rendering mode: simple box or multi-band
      let use-simple-box = widths == none
      
      if use-simple-box {
        // Simple box rendering (like input, pool, fc, etc.)
        let actual-w = if w == none { 0.2 } else { w }
        
        if img == "default" {
          img = image("bird.jpg")
        }
        
        box-3d(x, y-offset, actual-w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
        
        // Display channels labels
        draw-channels-labels(channels, x + actual-w/2, x + actual-w, y-offset, ox, oy)
        
        // Track position if named
        if name != none {
          layer-positions.insert(name, (
            x: x, y: y-offset, w: actual-w, h: h, ox: ox, oy: oy, type: "custom",
            anchors: get-layer-anchors(x, y-offset, actual-w, h, ox, oy),
            pool-offset: 0
          ))
        }
        
        if label != none {
          content((x + actual-w/2, y-offset - 0.5), 
            [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
        }
        
        prev-x = x + actual-w
        prev-depth-offset = ox
        x += actual-w
        prev-center-y = get-perspective-center-y(y-offset, h, oy)
        prev-pool-width = 0
      } else {
        // Multi-band rendering (like conv, convres)
        let dyn-strokes = dynamic-color-strokes(fill-color)
        let dyn-band-strokes = dynamic-color-strokes(bandfill-color)
        
        let has-diagonal-label = channels != none and channels.len() == widths.len() + 1
        let diagonal-label = if has-diagonal-label { channels.at(widths.len()) } else { none }
        let channel-labels = if channels != none {
          if has-diagonal-label { channels.slice(0, widths.len()) } else { channels }
        } else {
          (widths.map(w => ""))
        }
        
        let start-x = x
        let total-width = widths.fold(0, (acc, w) => acc + w)
        
        // Draw front face as colored bands
        let cumulative-x = start-x
        let alpha-front = 100% - layer-opacity * 100%
        for (j, ch) in channel-labels.enumerate() {
          let band-width = widths.at(j)
          let band-x = cumulative-x
          
          draw-band-front-face(band-x, y-offset, band-width, h, fill-color, bandfill-color, alpha-front, layer-show-relu)
          
          // Display channel label under each band
          let band-center-x = band-x + band-width / 2
          content((band-center-x, y-offset - 0.15), 
            [#text(size: scaled-font(font-sizes.channel-number), str(ch))])
          
          cumulative-x += band-width
        }
        
        // Draw front face outer edges
        line((start-x, y-offset), (start-x, y-offset + h), stroke: dyn-strokes.solid)
        line((start-x + total-width, y-offset), (start-x + total-width, y-offset + h), stroke: dyn-strokes.solid)
        line((start-x, y-offset + h), (start-x + total-width, y-offset + h), stroke: dyn-strokes.solid)
        line((start-x, y-offset), (start-x + total-width, y-offset), stroke: dyn-strokes.solid)
        
        // Draw top face segmented by band
        cumulative-x = start-x
        for (j, ch) in channel-labels.enumerate() {
          let band-width = widths.at(j)
          let band-x = cumulative-x
          
          draw-band-top-face(band-x, y-offset, band-width, h, ox, oy, fill-color, bandfill-color, layer-show-relu)
          
          cumulative-x += band-width
        }
        
        // Draw right face
        let right-face-color = if layer-show-relu { bandfill-color } else { fill-color }
        line((start-x + total-width, y-offset), (start-x + total-width + ox, y-offset + oy),
          (start-x + total-width + ox, y-offset + h + oy), (start-x + total-width, y-offset + h),
          close: true,
          fill: right-face-color.darken(darken-amounts.right).transparentize(opacity-values.right-face),
          stroke: dyn-strokes.solid)
        
        // Draw image on top of right face if provided
        if img != none {
          draw-isometric-image(start-x, y-offset, total-width, h, ox, oy, img)
        }
        
        // Draw all edges for band divisions
        cumulative-x = start-x
        for (j, ch) in channel-labels.enumerate() {
          let band-width = widths.at(j)
          let band-x = cumulative-x
          
          draw-band-separator-edges(band-x, y-offset, h, ox, oy, band-width, j == 0, fill-color)
          
        cumulative-x += band-width
      }
      
      // Draw outer edges (excluding right face edges which are already drawn)
      line((start-x, y-offset + h), (start-x + ox, y-offset + h + oy), stroke: dyn-strokes.solid)
      line((start-x + ox, y-offset + h + oy), (start-x + total-width + ox, y-offset + h + oy), stroke: dyn-strokes.solid)
      line((start-x + total-width, y-offset + h), (start-x + total-width + ox, y-offset + h + oy), stroke: dyn-strokes.solid)
      
      prev-x = start-x + total-width
        prev-depth-offset = ox
        x = start-x + total-width
        let center-x = start-x + total-width / 2
        
        // Display label below channel numbers
        if label != none {
          content((center-x, y-offset - 0.5), 
            [#text(size: scaled-font(font-sizes.layer-label), weight: "bold", label)])
        }
        
        // Display xlabel if provided
        if xlabel != none {
          content((center-x, y-offset - 0.8), 
            [#text(size: scaled-font(font-sizes.layer-label), xlabel)])
        }
        
        // Display ylabel and zlabel if provided
        if ylabel-val != none {
          content((start-x - 0.4, y-offset + h/2), anchor: "east",
            [#text(size: scaled-font(font-sizes.layer-label), str(ylabel-val))])
        }
        if zlabel-val != none {
          content((start-x + total-width + ox + 0.4, y-offset + h/2 + oy/2), anchor: "west",
            [#text(size: scaled-font(font-sizes.layer-label), str(zlabel-val))])
        }
        
        // Display diagonal label if provided
        if diagonal-label != none {
          let diag-start-x = start-x + total-width
          let diag-start-y = y-offset
          let diag-mid-x = diag-start-x + ox / 2.5
          let diag-mid-y = diag-start-y + oy / 2.5
          content((diag-mid-x, diag-mid-y - 0.23), angle: depth-angle-deg,
            [#text(size: scaled-font(font-sizes.channel-number), str(diagonal-label))])
        }
        
        // Track position if named
        if name != none {
          layer-positions.insert(name, (
            x: start-x, y: y-offset, w: total-width, h: h, ox: ox, oy: oy, type: "custom",
            anchors: get-layer-anchors(start-x, y-offset, total-width, h, ox, oy),
            pool-offset: 0
          ))
        }
        
        prev-center-y = get-perspective-center-y(y-offset, h, oy)
        prev-pool-width = 0
      }
      
      // Register legend entry for custom layers (only if legend parameter is provided)
      let custom-legend = l.at("legend", default: none)
      if custom-legend != none {
        // Use a unique key for each custom legend entry (legend text + color)
        let legend-key = "custom-" + str(custom-legend) + "-" + str(fill-color.to-hex())
        if legend-key not in legend-entries {
          legend-entries.insert(legend-key, (label: custom-legend, color: fill-color, bandfill: bandfill-color, show-relu: layer-show-relu, opacity: layer-opacity))
        }
      }
    }
    
    // INPUT IMAGE - uses custom type with input-specific defaults
    else if l.type == "input" {
      // Re-route to custom handler with input defaults
      l.insert("type", "custom")
      if not l.keys().contains("width") { l.insert("width", 0) }
      if not l.keys().contains("fill") { l.insert("fill", colors.input) }
      if not l.keys().contains("opacity") { l.insert("opacity", 0.9) }
      if not l.keys().contains("input-style") { l.insert("input-style", true) }
      
      // Fall through to process as custom (handled by previous if block)
      // But since we're in else-if, we need to inline the custom logic
      let h = l.at("height", default: 5)
      let d = l.at("depth", default: 5)
      let w = l.at("width", default: 0)
      let label = l.at("label", default: none)
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.input)
      let layer-opacity = l.at("opacity", default: 0.9)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }

      // Special rendering for INPUT: draw image first, then highly transparent face on top
      if img != none {
        // Draw isometric image first
        draw-isometric-image(x, y-offset, w, h, ox, oy, img)
        
        // Then draw highly transparent right face on top
        let alpha-right = layer-opacity * 100%
        line((x + w, y-offset), (x + w + ox, y-offset + oy),
          (x + w + ox, y-offset + h + oy), (x + w, y-offset + h),
          close: true,
          fill: fill-color.darken(darken-amounts.right).transparentize(alpha-right),
          stroke: dynamic-color-strokes(fill-color).solid)
      } else {
        // No image: use standard box-3d rendering
        box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      }
      
      draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "input",
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy),
          pool-offset: 0
        ))
      }
      
      if label != none {
        content((x + w/2, y-offset - 0.8), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry (check for legend parameter override)
      let layer-legend = l.at("legend", default: default-legend-labels.at("input"))
      if "input" not in legend-entries {
        legend-entries.insert("input", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // CONVOLUTIONAL BLOCK types - delegates to custom with conv-specific defaults
    else if l.type == "conv" or l.type == "convres"{
      let fill-color = if l.type == "conv" {
        l.at("fill", default: colors.conv)
        } else if l.type == "convres" {
        l.at("fill", default: colors.convres)
      }
      let bandfill-color = if l.type == "conv" {
        l.at("bandfill", default: colors.at("conv-relu"))
        } else if l.type == "convres" {
        l.at("bandfill", default: colors.at("convres-relu"))
      }
      
      // Set up parameters for custom handler with conv defaults
      if not l.keys().contains("fill") { l.insert("fill", fill-color) }
      if not l.keys().contains("bandfill") { l.insert("bandfill", bandfill-color) }
      if not l.keys().contains("widths") { l.insert("widths", (1,)) }
      let channels = l.at("channels", default: none)
      let widths = l.at("widths", default: (1,))
      let h = l.at("height", default: 5)
      let d = l.at("depth", default: 5)
      let label = l.at("label", default: none)
      let xlabel = l.at("xlabel", default: none)
      let name = l.at("name", default: none)
      let layer-opacity = l.at("opacity", default: 1.0)
      let ylabel-val = l.at("ylabel", default: none)
      let zlabel-val = l.at("zlabel", default: none)
      let layer-show-relu = l.at("show-relu", default: show-relu)
      let img = l.at("image", default: none)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      // Use dynamic color strokes for fill-color and bandfill-color
      let dyn-strokes = dynamic-color-strokes(fill-color)
      let dyn-band-strokes = dynamic-color-strokes(bandfill-color)

      // Determine if we have a diagonal label (channels has one extra element)
      let has-diagonal-label = channels != none and channels.len() == widths.len() + 1
      let diagonal-label = if has-diagonal-label { channels.at(widths.len()) } else { none }
      let channel-labels = if channels != none {
        if has-diagonal-label { channels.slice(0, widths.len()) } else { channels }
      } else {
        (widths.map(w => ""))
      }
      
      // Use actual widths values to determine band sizes
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      let start-x = x
      let total-width = widths.fold(0, (acc, w) => acc + w)
      
      // Draw front face as colored bands
      let cumulative-x = start-x
      let alpha-front = 100% - layer-opacity * 100%
      for (j, ch) in channel-labels.enumerate() {
        let band-width = widths.at(j)
        let band-x = cumulative-x
        
        draw-band-front-face(band-x, y-offset, band-width, h, fill-color, bandfill-color, alpha-front, layer-show-relu)
        
        // Display channel label under each band
        let band-center-x = band-x + band-width / 2
        content((band-center-x, y-offset - 0.15), 
          [#text(size: scaled-font(font-sizes.channel-number), str(ch))])
        
        cumulative-x += band-width
      }
      
      // Draw front face outer edges (only the perimeter)
      line((start-x, y-offset), (start-x, y-offset + h), stroke: dyn-strokes.solid)
      line((start-x + total-width, y-offset), (start-x + total-width, y-offset + h), stroke: dyn-strokes.solid)
      line((start-x, y-offset + h), (start-x + total-width, y-offset + h), stroke: dyn-strokes.solid)
      line((start-x, y-offset), (start-x + total-width, y-offset), stroke: dyn-strokes.solid)
      
      // Draw top face segmented by band
      cumulative-x = start-x
      for (j, ch) in channel-labels.enumerate() {
        let band-width = widths.at(j)
        let band-x = cumulative-x
        
        draw-band-top-face(band-x, y-offset, band-width, h, ox, oy, fill-color, bandfill-color, layer-show-relu)
        
        cumulative-x += band-width
      }

      // Draw right face
      let right-face-color = if layer-show-relu { bandfill-color } else { fill-color }
      line((start-x + total-width, y-offset), (start-x + total-width + ox, y-offset + oy),
        (start-x + total-width + ox, y-offset + h + oy), (start-x + total-width, y-offset + h),
        close: true,
        fill: right-face-color.darken(darken-amounts.right).transparentize(opacity-values.right-face),
        stroke: dyn-strokes.solid)
      
      // Draw image on top of right face if provided
      if img != none {
        draw-isometric-image(start-x, y-offset, total-width, h, ox, oy, img)
      }

      // Draw all edges for band divisions (once each)
      cumulative-x = start-x
      for (j, ch) in channel-labels.enumerate() {
        let band-width = widths.at(j)
        let band-x = cumulative-x
        
        draw-band-separator-edges(band-x, y-offset, h, ox, oy, band-width, j == 0, fill-color)
        
        cumulative-x += band-width
      }
      
      // Draw outer edges of the block (excluding right face edges which are already drawn)
      line((start-x, y-offset + h), (start-x + ox, y-offset + h + oy), stroke: dyn-strokes.solid)
      line((start-x + ox, y-offset + h + oy), (start-x + total-width + ox, y-offset + h + oy), stroke: dyn-strokes.solid)
      line((start-x + total-width, y-offset + h), (start-x + total-width + ox, y-offset + h + oy), stroke: dyn-strokes.solid)
      
      prev-x = start-x + total-width
      prev-depth-offset = ox
      x = start-x + total-width
      let center-x = start-x + total-width / 2
      
      // Display label below channel numbers
      if label != none {
        content((center-x, y-offset - 0.5), 
          [#text(size: scaled-font(font-sizes.layer-label), weight: "bold", label)])
      }
      
      // Display xlabel if provided
      if xlabel != none {
        content((center-x, y-offset - 0.8), 
          [#text(size: scaled-font(font-sizes.layer-label), xlabel)])
      }
      
      // Display ylabel and zlabel if provided
      if ylabel-val != none {
        content((start-x - 0.4, y-offset + h/2), anchor: "east",
          [#text(size: scaled-font(font-sizes.layer-label), str(ylabel-val))])
      }
      if zlabel-val != none {
        content((start-x + total-width + ox + 0.4, y-offset + h/2 + oy/2), anchor: "west",
          [#text(size: scaled-font(font-sizes.layer-label), str(zlabel-val))])
      }
      
      // Display diagonal label if provided (along bottom-right depth edge)
      if diagonal-label != none {
        let diag-start-x = start-x + total-width
        let diag-start-y = y-offset
        let diag-mid-x = diag-start-x + ox / 2.5
        let diag-mid-y = diag-start-y + oy / 2.5
        content((diag-mid-x, diag-mid-y - 0.23), angle: depth-angle-deg,
          [#text(size: scaled-font(font-sizes.channel-number), str(diagonal-label))])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: start-x, y: y-offset, w: total-width, h: h, ox: ox, oy: oy, type: "conv",
          anchors: get-layer-anchors(start-x, y-offset, total-width, h, ox, oy),
          pool-offset: 0  // Will be updated if next layer is a pool
        ))
      }
      
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at(l.type))
      if l.type not in legend-entries {
        legend-entries.insert(l.type, (label: layer-legend, color: fill-color, bandfill: bandfill-color, show-relu: layer-show-relu, opacity: layer-opacity))
      }
    }
    
    // POOLING LAYER - delegates to custom with pool-specific positioning
    else if l.type == "pool" {
      let h = l.at("height", default: 4)
      let d = l.at("depth", default: 4)
      let w = 0.1
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.pool)
      let layer-opacity = l.at("opacity", default: 0.75)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let layer-offset = l.at("offset", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = prev-center-y - h / 2 - oy / 2
      let pool-x = if layer-offset != none { x + layer-offset } else { x + prev-depth-offset / 2 - ox / 2 }
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(pool-x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      draw-channels-labels(channels, pool-x + w/2, pool-x + w, y-offset, ox, oy)
      
      if i > 0 {
        let prev-layer = layers.at(i - 1)
        let prev-name = prev-layer.at("name", default: none)
        if prev-name != none and prev-name in layer-positions {
          let prev-pos = layer-positions.at(prev-name)
          layer-positions.insert(prev-name, (
            ..prev-pos,
            pool-offset: w
          ))
        }
      }
      
      if name != none {
        layer-positions.insert(name, (
          x: pool-x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "pool",
          anchors: get-layer-anchors(pool-x, y-offset, w, h, ox, oy),
          pool-offset: 0
        ))
      }
      
      prev-x = pool-x + w
      prev-depth-offset = ox
      if layer-offset != none {
        x += layer-offset + w
      } else {
        x = pool-x + w
      }
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("pool"))
      if "pool" not in legend-entries {
        legend-entries.insert("pool", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // UNPOOLING LAYER - delegates to custom with unpool-specific positioning
    else if l.type == "unpool" {
      let h = l.at("height", default: 4)
      let d = l.at("depth", default: 4)
      let w = 0.1
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.unpool)
      let layer-opacity = l.at("opacity", default: 0.75)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let layer-offset = l.at("offset", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = prev-center-y - h / 2 - oy / 2
      let unpool-x = if layer-offset != none { x + layer-offset } else { x + prev-depth-offset / 2 - ox / 2 }
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(unpool-x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels
      draw-channels-labels(channels, unpool-x + w/2, unpool-x + w, y-offset, ox, oy)
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: unpool-x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "unpool",
          anchors: get-layer-anchors(unpool-x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = unpool-x + w
      prev-depth-offset = ox
      if layer-offset != none {
        x += layer-offset + w
      } else {
        x = unpool-x + w
      }
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("unpool"))
      if "unpool" not in legend-entries {
        legend-entries.insert("unpool", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // DECONVOLUTIONAL LAYER - delegates to custom with deconv-specific defaults
    else if l.type == "deconv" {
      let h = l.at("height", default: 5)
      let d = l.at("depth", default: 5)
      let w = l.at("width", default: 0.3)
      let label = l.at("label", default: "")
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.deconv)
      let layer-opacity = l.at("opacity", default: 0.7)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels
      draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      
      if label != none {
        content((x + w/2, y-offset - 0.5), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "deconv",
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("deconv"))
      if "deconv" not in legend-entries {
        legend-entries.insert("deconv", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // CONCATENATION LAYER - delegates to custom with concat-specific defaults
    else if l.type == "concat" {
      let h = l.at("height", default: 3)
      let d = l.at("depth", default: 3)
      let w = l.at("width", default: 0.15)
      let label = l.at("label", default: "")
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.concat)
      let layer-opacity = l.at("opacity", default: 0.7)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels
      draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      
      if label != none {
        content((x + w/2, y-offset - 0.5), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "concat",
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("concat"))
      if "concat" not in legend-entries {
        legend-entries.insert("concat", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // GLOBAL AVERAGE POOLING - delegates to custom with gap-specific defaults
    else if l.type == "gap" {
      let h = l.at("height", default: 1.5)
      let d = l.at("depth", default: 1.5)
      let w = 0.3
      let label = l.at("label", default: "")
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.gap)
      let layer-opacity = l.at("opacity", default: 0.7)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels
      draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      
      if label != none {
        content((x + w/2, y-offset - 0.5), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "gap",
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("gap"))
      if "gap" not in legend-entries {
        legend-entries.insert("gap", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // FULLY CONNECTED - delegates to custom with fc-specific defaults
    else if l.type == "fc" {
      let h = l.at("height", default: 1.2)
      let d = l.at("depth", default: 1.2)
      let w = 0.2
      let label = l.at("label", default: "")
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.fc)
      let layer-opacity = l.at("opacity", default: 0.7)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels
      draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      
      if label != none {
        content((x + w/2, y-offset - 0.5), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: "fc",
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("fc"))
      if "fc" not in legend-entries {
        legend-entries.insert("fc", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // SUM NODE - uses unique circle rendering (not box-based like custom)
    else if l.type == "sum" {
      let radius = l.at("radius", default: 0.4)
      let label = l.at("label", default: "+")
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.sum)
      let layer-opacity = l.at("opacity", default: 1.0)
      let channels = l.at("channels", default: none)
      
      // Center x accounts for depth offset of previous arrow
      let center-x = x + radius + prev-depth-offset / 2
      let center-y = arrow-axis-y

      let dyn-stroke = dynamic-color-strokes(fill-color)
      dyn-stroke.solid.paint = dyn-stroke.solid.paint.darken(10%) // slightly darker stroke than for other layers
      dyn-stroke.solid.thickness = dyn-stroke.solid.thickness * 1.5  // slightly thicker stroke than for other layers
      fill-color = fill-color.transparentize((1-layer-opacity)*100%)

      circle((center-x, center-y), radius: radius,
        fill: gradient.radial(
          fill-color.lighten(50%), fill-color, fill-color.darken(30%),
          center: (50%, 50%), radius: 50%,
          focal-center: (35%, 35%), focal-radius: 5%
        ),
        stroke: dyn-stroke.solid)
      
      if label != none {
        let symbole-size = scaled-font(font-sizes.label * 2.5)
        content((center-x, center-y), 
          [#v(-0.185 * symbole-size)#text(size: symbole-size, weight: "bold", fill: dyn-stroke.solid.paint, label)])
      }
      
      // Display channels labels (below and optionally on diagonal)
      if channels != none {
        let (ox, oy) = get-depth-offsets(radius * 2)
        draw-channels-labels(channels, center-x, center-x + radius, center-y - radius, ox, oy)
      }
      
      prev-x = center-x + radius
      prev-depth-offset = 0
      x += radius * 3
      
      if name != none {
        let (ox, oy) = get-depth-offsets(radius * 2)
        layer-positions.insert(name, (
          x: x - radius * 2, y: center-y - radius, w: radius * 2, h: radius * 2, ox: ox, oy: oy,
          type: "sum", radius: radius, center-x: center-x,
          anchors: get-layer-anchors(x - radius * 2, center-y - radius, radius * 2, radius * 2, ox, oy),
          pool-offset: 0
        ))
      }
      
      prev-center-y = center-y
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("sum"))
      if "sum" not in legend-entries {
        legend-entries.insert("sum", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // CONVOLUTIONAL SOFTMAX (Combined layer)
    else if l.type == "convsoftmax" {
      let h = l.at("height", default: 4)
      let d = l.at("depth", default: 4)
      let w = l.at("width", default: 0.1)
      let label = l.at("label", default: "")
      let name = l.at("name", default: none)
      let fill-color = l.at("fill", default: colors.convsoftmax)
      let layer-opacity = l.at("opacity", default: 0.5)
      let channels = l.at("channels", default: none)
      let img = l.at("image", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels
      draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      
      if label != none {
        content((x + w/2, y-offset - 0.5), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy,
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at("convsoftmax"))
      if "convsoftmax" not in legend-entries {
        legend-entries.insert("convsoftmax", (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
    
    // SOFTMAX / OUTPUT - delegates to custom with softmax/output-specific defaults
    else if l.type == "softmax" or l.type == "output" {
      let h = l.at("height", default: 0.8)
      let d = l.at("depth", default: 0.8)
      let w = 0.2
      let label = l.at("label", default: if l.type == "softmax" { "Softmax" } else { "Output" })
      let name = l.at("name", default: none)
      let classes = l.at("classes", default: none)
      let channels = l.at("channels", default: none)
      let fill-color = l.at("fill", default: if l.type == "softmax" { colors.softmax } else { colors.output })
      let layer-opacity = l.at("opacity", default: 0.5)
      let img = l.at("image", default: none)
      let (ox, oy) = get-depth-offsets(d)
      let y-offset = get-y-offset-for-center-on-axis(h, d, arrow-axis-y)
      
      if img == "default" {
        img = image("bird.jpg")
      }
      
      box-3d(x, y-offset, w, h, d, fill-color, opacity: layer-opacity, show-left: true, show-right: true, image: img)
      
      // Display channels labels (preferred over classes)
      if channels != none {
        draw-channels-labels(channels, x + w/2, x + w, y-offset, ox, oy)
      } else if classes != none {
        content((x + w/2, y-offset - 0.3), 
          [#text(size: scaled-font(font-sizes.output-number), str(classes))])
      }
      if label != none {
        content((x + w/2, y-offset - 0.6), 
          [#text(size: scaled-font(font-sizes.label), weight: "bold", label)])
      }
      
      // Track position if named
      if name != none {
        layer-positions.insert(name, (
          x: x, y: y-offset, w: w, h: h, ox: ox, oy: oy, type: l.type,
          anchors: get-layer-anchors(x, y-offset, w, h, ox, oy)
        ))
      }
      
      prev-x = x + w
      prev-depth-offset = ox
      x += w
      prev-center-y = get-perspective-center-y(y-offset, h, oy)
      prev-pool-width = 0
      
      // Register legend entry
      let layer-legend = l.at("legend", default: default-legend-labels.at(l.type))
      if l.type not in legend-entries {
        legend-entries.insert(l.type, (label: layer-legend, color: fill-color, bandfill: fill-color, show-relu: false, opacity: layer-opacity))
      }
    }
  }
  
  // After all layers are drawn, calculate arrow segment midpoints for ALL named layer pairs
  // This ensures skip connections between non-consecutive layers can find their anchor points
  for (i, l) in layers.enumerate() {
    let curr-name = l.at("name", default: none)
    if curr-name != none and curr-name in layer-positions {
      // Find the previous named layer (skip over unnamed layers like pool/unpool)
      let prev-name = none
      for j in range(i - 1, -1, step: -1) {
        let candidate-name = layers.at(j).at("name", default: none)
        if candidate-name != none and candidate-name in layer-positions {
          prev-name = candidate-name
          break
        }
      }
      
      // If we found a previous named layer, calculate the arrow segment
      if prev-name != none {
        let prev-pos = layer-positions.at(prev-name)
        let curr-pos = layer-positions.at(curr-name)
        
        // Use true_east and add pool-offset if there's a pool after the previous layer
        let pool-offset = prev-pos.at("pool-offset", default: 0)
        let arrow-start = (prev-pos.anchors.true_east.at(0) + pool-offset, prev-pos.anchors.true_east.at(1))
        let arrow-end = curr-pos.anchors.true_west
        
        // Calculate midpoint of the arrow segment
        let mid-x = (arrow-start.at(0) + arrow-end.at(0)) / 2
        let mid-y = arrow-start.at(1)
        
        // Store for skip connections - these will override any stored during drawing
        arrow-segments.insert(prev-name + "-out", (
          start: arrow-start,
          mid: (mid-x, mid-y),
          x: mid-x,
          y: mid-y
        ))
        arrow-segments.insert(curr-name + "-in", (
          end: arrow-end,
          mid: (mid-x, mid-y),
          x: mid-x,
          y: mid-y
        ))
      }
    }
  }
  
  for conn in connections {
    let from-name = conn.at("from")
    let to-name = conn.at("to")
    let conn-type = conn.at("type", default: "skip")
    let conn-mode = conn.at("mode", default: "flat")
    let conn-pos = conn.at("pos", default: 1.25)
    let conn-label = conn.at("label", default: none)
    let conn-opacity = conn.at("opacity", default: 0.7)
    let touch-layer = conn.at("touch-layer", default: false)
    
    if from-name in layer-positions and to-name in layer-positions {
      let from-pos = layer-positions.at(from-name)
      let to-pos = layer-positions.at(to-name)
      
      // Use arrow segment midpoints if available, otherwise fall back to layer edges
      let from-anchor-key = from-name + "-out"
      let to-anchor-key = to-name + "-in"
      
      // Check if the from layer has a pool attached but we're not departing from the pool itself
      let from-has-pool = from-pos.at("pool-offset", default: 0) > 0
      let from-type = from-pos.at("type", default: none)
      let departing-from-layer-with-pool = from-has-pool and from-type != "pool"
      
      // Use true midpoint of arrow segment after from layer (uses stored start point)
      let from-anchor = if departing-from-layer-with-pool {
        // Special case: departing from a layer with attached pool (but not the pool itself)
        // Use specific edges of the east side based on connection mode
        let base-x = from-pos.x + from-pos.w
        let base-y = from-pos.y
        let h = from-pos.h
        let ox = from-pos.ox
        let oy = from-pos.oy
        
        if conn-mode == "air" {
          // Middle of top diagonal edge of east side
          (base-x + ox/2, base-y + h + oy/2)
        } else if conn-mode == "depth" {
          // Middle of left edge of east side
          (base-x, base-y + h/2 + oy/2)
        } else {
          // "flat" - Middle of bottom edge of east side
          (base-x + ox/2, base-y + oy/2)
        }
      } else if from-anchor-key in arrow-segments {
        let seg = arrow-segments.at(from-anchor-key)
        // Use the arrow's actual start point for x (depth-adjusted)
        (seg.mid.at(0), seg.mid.at(1))
      } else {
        from-pos.anchors.true_east
      }
      
      // Determine target anchor point
      let to-type = to-pos.at("type", default: none)
      let to-anchor = if touch-layer {
        // Special case: arrive at specific edge of west side of destination layer
        let base-x = to-pos.x
        let base-y = to-pos.y
        let h = to-pos.h
        let ox = to-pos.ox
        let oy = to-pos.oy
        
        if conn-mode == "air" {
          // Middle of top diagonal edge of west side
          (base-x + ox/2, base-y + h + oy/2)
        } else if conn-mode == "depth" {
          // Middle of left edge of west side
          (base-x, base-y + h/2 + oy/2)
        } else {
          // "flat" - Middle of bottom edge of west side
          (base-x + ox/2, base-y + oy/2)
        }
      } else if to-type == "sum" {
        // For sum layers, use the stored center-x (which already accounts for depth offset)
        let center-x = to-pos.center-x
        let center-y = to-pos.y + to-pos.radius
        let center = (center-x, center-y)
        let radius = to-pos.at("radius", default: 0.4)
        if conn-mode == "flat" {
          (center.at(0), center.at(1) - radius)
        } else if conn-mode == "air" {
          (center.at(0), center.at(1) + radius)
        } else if conn-mode == "depth" {
          let angle = 225 * calc.pi / 180
          (center.at(0) + radius * calc.cos(angle), center.at(1) + radius * calc.sin(angle))
        } else {
          (center.at(0), center.at(1) - radius)
        }
      } else if to-anchor-key in arrow-segments {
        let seg = arrow-segments.at(to-anchor-key)
        // Use the arrow's midpoint (both x and y)
        seg.mid
      } else {
        to-pos.anchors.true_west
      }
      
      if conn-type == "skip" {
        let conn-layers = conn.at("layers", default: none)
        
        if conn-mode == "flat" {
          let down-y = from-anchor.at(1) - conn-pos
          let waypoint1 = (from-anchor.at(0), down-y)
          let waypoint2 = (to-anchor.at(0), down-y)
          
          draw-connection-path(((from-anchor, waypoint1), (waypoint1, waypoint2), (waypoint2, to-anchor)), opacity: conn-opacity, layers: conn-layers, layer-positions-ref: layer-positions, show-relu: show-relu)
          
          if conn-label != none {
            content(((waypoint1.at(0) + waypoint2.at(0)) / 2, down-y - 0.2), 
              [#text(size: scaled-font(font-sizes.layer-label), conn-label)])
          }
        } else if conn-mode == "depth" {
          let (ox, oy) = get-depth-offsets(conn-pos * 2.5)
          let waypoint1 = (from-anchor.at(0) - ox, from-anchor.at(1) - oy)
          // For sum circles, adjust waypoint2 x-coordinate to account for south-west arrival
          let waypoint2-x = if to-type == "sum" {
            // Compensate for the south-west arrival offset (radius * cos(225°))
            let radius = to-pos.at("radius", default: 0.4)
            let angle = 225 * calc.pi / 180
            to-anchor.at(0) - ox - radius * calc.cos(angle)
          } else {
            to-anchor.at(0) - ox
          }
          let waypoint2 = (waypoint2-x, from-anchor.at(1) - oy)
          
          draw-connection-path(((from-anchor, waypoint1), (waypoint1, waypoint2), (waypoint2, to-anchor)), opacity: conn-opacity, layers: conn-layers, layer-positions-ref: layer-positions, show-relu: show-relu)
          
          if conn-label != none {
            content(((waypoint1.at(0) + waypoint2.at(0)) / 2, waypoint1.at(1) - 0.2), 
              [#text(size: scaled-font(font-sizes.layer-label), conn-label)])
          }
        } else if conn-mode == "air" {
          let up-y = arrow-axis-y + conn-pos
          let down-y = from-anchor.at(1) - conn-pos
          let waypoint1 = (from-anchor.at(0), up-y)
          let waypoint2 = (to-anchor.at(0), up-y)
          
          draw-connection-path(((from-anchor, waypoint1), (waypoint1, waypoint2), (waypoint2, to-anchor)), opacity: conn-opacity, layers: conn-layers, layer-positions-ref: layer-positions, show-relu: show-relu)
          
          if conn-label != none {
            content(((waypoint1.at(0) + waypoint2.at(0)) / 2, up-y + 0.2), 
              [#text(size: scaled-font(font-sizes.layer-label), conn-label)])
          }
        }
      }
    }
  }
  
  if show-legend {
    // Position legend after the last layer, accounting for its width and depth
    let legend-x = prev-x + prev-depth-offset + 1.5
    let legend-item-height = 0.4
    let legend-box-size = 0.3
    
    // Count total legend entries to calculate vertical centering
    let ordered-types = ("input", "conv", "convres", "pool", "unpool", "deconv", "concat", "sum", "gap", "fc", "convsoftmax", "softmax", "output")
    let entry-count = 0
    for layer-type in ordered-types {
      if layer-type in legend-entries {
        entry-count += 1
      }
    }
    for (key, entry) in legend-entries {
      if key.starts-with("custom-") {
        entry-count += 1
      }
    }
    
    // Calculate total legend height: title + spacing + (entries * item-height)
    let legend-total-height = 0.6 + entry-count * legend-item-height
    
    // Center legend vertically around arrow-axis-y
    let legend-y = arrow-axis-y + legend-total-height / 2
    
    content((legend-x, legend-y), 
      [#h(20pt)#text(size: scaled-font(font-sizes.legend-title), weight: "bold", "Layer Types")])
    
    legend-y -= 0.6
    
    for layer-type in ordered-types {
      if layer-type in legend-entries {
        let entry = legend-entries.at(layer-type)
        let item-stroke = dynamic-color-strokes(entry.color)
        let alpha = 100% - entry.at("opacity", default: 1.0) * 100%
        
        if entry.at("show-relu", default: false) {
          // Draw split rectangle: 2/3 fill color (left), 1/3 bandfill color (right)
          let split-x = legend-x + legend-box-size * 2 / 3
          rect((legend-x, legend-y), (split-x, legend-y + legend-box-size),
            fill: entry.color.transparentize(alpha), stroke: none)
          rect((split-x, legend-y), (legend-x + legend-box-size, legend-y + legend-box-size),
            fill: entry.bandfill.transparentize(alpha), stroke: none)
          // Draw outline
          rect((legend-x, legend-y), (legend-x + legend-box-size, legend-y + legend-box-size),
            fill: none, stroke: item-stroke.solid)
        } else {
          // Draw solid rectangle
          rect((legend-x, legend-y), (legend-x + legend-box-size, legend-y + legend-box-size),
            fill: entry.color.transparentize(alpha), stroke: item-stroke.solid)
        }
        
        content((legend-x + legend-box-size + 0.2, legend-y + legend-box-size / 2), anchor: "west",
          [#text(size: scaled-font(font-sizes.legend-item), entry.label)])
        
        legend-y -= legend-item-height
      }
    }
    
    // Render custom legend entries
    for (key, entry) in legend-entries {
      if key.starts-with("custom-") {
        let item-stroke = dynamic-color-strokes(entry.color)
        let alpha = 100% - entry.at("opacity", default: 1.0) * 100%
        
        if entry.at("show-relu", default: false) {
          // Draw split rectangle: 2/3 fill color (left), 1/3 bandfill color (right)
          let split-x = legend-x + legend-box-size * 2 / 3
          rect((legend-x, legend-y), (split-x, legend-y + legend-box-size),
            fill: entry.color.transparentize(alpha), stroke: none)
          rect((split-x, legend-y), (legend-x + legend-box-size, legend-y + legend-box-size),
            fill: entry.bandfill.transparentize(alpha), stroke: none)
          // Draw outline
          rect((legend-x, legend-y), (legend-x + legend-box-size, legend-y + legend-box-size),
            fill: none, stroke: item-stroke.solid)
        } else {
          // Draw solid rectangle
          rect((legend-x, legend-y), (legend-x + legend-box-size, legend-y + legend-box-size),
            fill: entry.color.transparentize(alpha), stroke: item-stroke.solid)
        }
        
        content((legend-x + legend-box-size + 0.2, legend-y + legend-box-size / 2), anchor: "west",
          [#text(size: scaled-font(font-sizes.legend-item), entry.label)])
        
        legend-y -= legend-item-height
      }
    }
  }
})}