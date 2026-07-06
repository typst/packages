/// the main function that creates the tiling
/// - named size parameter must be provided
/// - background allows any type allowed in the box fill argument. It gets applied first
/// - other tiling args are also supported
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
