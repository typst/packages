/// currently the only function which creates the corresponding pattern
/// - size is the as size for patterns
/// - body is the inside/body/content of the pattern
/// - dx, dy allow for translations
/// - background allows any type allowed in the box fill argument. It gets applied first
#let modpattern(..args, background: none) = tiling(
  ..args.named(),
  {
    let body = args.at(0)
    let (width, height) = args.at("size")
    let (dx, dy) = args.at("spacing", default: (0pt, 0pt))
    if background != none {
      place(box(width: 100%, height: 100%, fill: background))
    }
    move(dx: - dx - width, dy: - dy - height, grid(
      columns: 3*(width + dx,),
      rows: 3*(height + dy,),
      body, body, body,
      body, body, body,
      body, body, body
    ))
  }
)
