
#let draw-arrow(start, end, length: 5pt, width: 2.5pt) = context layout(size => {
  let convert-ratio(x, y) = {
    if type(x) == ratio { x *=size.width }
    if type(y) == ratio { y *= size.height }
    (x, y)
  }
  let start = convert-ratio(..start)
  let end = convert-ratio(..end)
  let stroke = line.stroke
  let arrow-color = stroke.paint
  if arrow-color == auto { arrow-color = black }
  place(line(start: start, end: end))
  let dir = (end.at(0) - start.at(0), end.at(1) - start.at(1))
  dir = dir.map(x => float(repr(x).slice(0,-2)))
  // let angle = calc.atan2(dir.at(0), dir.at(1))
  
  let len = calc.norm(..dir)
  dir = dir.map(x => x / len)
  let normal = (-dir.at(1), dir.at(0))

  let arrow-start = end
  let arrow-end = (end.at(0) + length*dir.at(0), end.at(1) + length*dir.at(1))
  let w = width/2
  let v1 = (arrow-start.at(0) - w*normal.at(0), arrow-start.at(1) - w*normal.at(1))
  let v2 = (arrow-start.at(0) + w*normal.at(0), arrow-start.at(1) + w*normal.at(1))
  polygon(arrow-end, v1, v2, fill: arrow-color)
})

#let test-arrow() = {
  draw-arrow((0%, 0%), (50%, 10%))
}


#test-arrow()