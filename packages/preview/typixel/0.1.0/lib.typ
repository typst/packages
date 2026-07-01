#let p = plugin("typixel_plugin.wasm")

// ==============================================
// Shapes
// ==============================================

// Square
#let square-shape(width: 0pt, height: 0pt, fill: black) = {
  box(width: width, height: height, fill: fill)
}

// Circle
#let circle-shape(width: 0pt, height: 0pt, fill: black) = {
  circle(width: width, height: height, fill: fill)
}

// Rounded Square
#let rounded-shape(width: 0pt, height: 0pt, fill: black, radius: 20%) = {
  box(width: width, height: height, fill: fill, radius: radius)
}

// Diamond
#let diamond-shape(width: 0pt, height: 0pt, fill: black) = {
  let s = width / 1.4142
  align(center + horizon, rotate(45deg, box(width: s, height: s, fill: fill)))
}

// Star
#let star-shape(width: 0pt, height: 0pt, fill: black) = {
  let r_out = width / 2
  let r_in = r_out * 0.4 
  let cx = width / 2
  let cy = height / 2
  
  let points = range(10).map(i => {
    let r = if calc.even(i) { r_out } else { r_in }
    let theta = -90deg + i * 36deg 
    (
      cx + r * calc.cos(theta),
      cy + r * calc.sin(theta)
    )
  })

  box(width: width, height: height, 
    polygon(fill: fill, stroke: none, ..points)
  )
}

// Cross
#let cross-shape(width: 0pt, height: 0pt, fill: black, thickness: 15%) = {
  let stroke-w = width * thickness
  let line-opts = (stroke: (paint: fill, cap: "round", thickness: stroke-w))
  box(width: width, height: height, {
    place(line(start: (0%, 0%), end: (100%, 100%), ..line-opts))
    place(line(start: (0%, 100%), end: (100%, 0%), ..line-opts))
  })
}

// Heart
#let heart-shape(width: 0pt, height: 0pt, fill: black) = {
  box(width: width, height: height,
    curve(
      fill: fill,
      stroke: none,
      fill-rule: "even-odd",
      curve.move((50%, 100%)),
      curve.cubic((50%, 75%), (100%, 60%), (100%, 30%)),
      curve.cubic((100%, 0%), (60%, 0%), (50%, 25%)),
      curve.cubic((40%, 0%), (0%, 0%), (0%, 30%)),
      curve.cubic((0%, 60%), (50%, 75%), (50%, 100%)),
      curve.close()
    )
  )
}

// ==============================================
// Render
// ==============================================

#let pixel-render(
  rows,           
  palette,        
  pixel-size: 5pt,
  width: auto,    
  shape: square-shape,
  gap: 0pt,
  default-color: black,
) = {
  if rows.len() == 0 { return box() }

  let grid-w = rows.map(r => r.clusters().len()).fold(0, calc.max)
  let grid-h = rows.len()

  let final-pixel-size = if width != auto {
    if grid-w == 0 { 0pt } else {
      (width - (gap * (grid-w - 1))) / grid-w
    }
  } else {
    pixel-size
  }

  let pixels = ()
  for row in rows {
    let chars = row.clusters()
    let row-len = chars.len()
    
    for char in chars {
      let cell-color = palette.at(char, default: default-color)
      
      if cell-color == none {
        pixels.push(hide(box(width: final-pixel-size, height: final-pixel-size)))
      } else {
        let cell-shape = if type(shape) == dictionary {
          shape.at(char, default: square-shape)
        } else {
          shape
        }
        
        pixels.push(cell-shape(
          width: final-pixel-size, 
          height: final-pixel-size, 
          fill: cell-color
        ))
      }
    }
    
    if row-len < grid-w {
      for _ in range(grid-w - row-len) {
        pixels.push(hide(box(width: final-pixel-size, height: final-pixel-size)))
      }
    }
  }

  box(grid(
    columns: (final-pixel-size,) * grid-w,
    rows: (final-pixel-size,) * grid-h,
    gutter: gap,
    ..pixels
  ))
}

// ==============================================
// User Functions
// ==============================================

#let pixel-image(
  image-data,
  columns: auto,
  rows: auto,
  scale: auto,
  colors: 64,
  transparency-char: ".",
  pixel-size: 5pt,
  width: auto,
  shape: square-shape,
  gap: 0pt,
  ..args
) = {
  let config = (
    width: if columns == auto { none } else { columns },
    height: if rows == auto { none } else { rows },
    scale: if scale == auto { none } else { scale },
    colors: colors
  )

  let json-bytes = p.rgba_to_grid(image-data, bytes(json.encode(config)))
  let result = json(json-bytes)

  if "error" in result {
    panic("Pixel Art Plugin Error: " + result.error)
  }

  let final-palette = (:)
  final-palette.insert(transparency-char, none)
  
  for (char_key, hex_val) in result.palette {
    if hex_val == none {
      final-palette.insert(char_key, none)
    } else {
      final-palette.insert(char_key, rgb(hex_val))
    }
  }

  pixel-render(
    result.art.split("\n"),
    final-palette,
    pixel-size: pixel-size,
    width: width,
    shape: shape,
    gap: gap,
    default-color: none
  )
}

#let pixel-map(
  map,
  palette: (:),
  pixel-size: 10pt,
  width: auto,
  shape: square-shape,
  gap: 0pt,
) = {
  let rows = map
    .split("\n")
    .map(s => s.trim())
    .filter(s => s.len() > 0)
    
  pixel-render(
    rows,
    palette,
    pixel-size: pixel-size,
    width: width,
    shape: shape,
    gap: gap,
    default-color: black
  )
}