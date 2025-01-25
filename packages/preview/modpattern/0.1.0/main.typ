/// currently the only function which creates the corresponding pattern
/// - size is the as size for patterns
/// - body is the inside/body/content of the pattern
/// - dx, dy allow for translations
/// - background allows any type allowed in the box fill argument. It gets applied first
#let modpattern(size, body, dx: 0pt, dy: 0pt, background: none) = pattern(
  size: size,
  {
    if background != none {
      place(box(width: 100%, height: 100%, fill: background))
    }
    move(dx: -size.at(0) + dx, dy: -size.at(1) + dy, grid(
      columns: 3*(size.at(0),),
      rows: 3*(size.at(1),),
      body, body, body,
      body, body, body,
      body, body, body
    ))
  }
)