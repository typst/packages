#import "@preview/cetz:0.5.3" : draw
#import draw: *

// finds wether a variable is "active" for a range of given rows/columns
// positions that are right after another, like (1, 2, 3) will be combined to (1,3) for a continuous line
#let value-in-line(lines, order) = {
  let arr = ()

  order = lines - order - 1

  lines = calc.pow(2, lines)

  let first = 1
  let last = 0
  let been-on = false

  for n in range(lines){
    let c = n.bit-xor(n.bit-rshift(1))
    let c = c.bit-rshift(order).bit-and(1)
    if c == 1 {
      if n != last + 1 {
        if been-on {
          arr.push((first + 1, last +1))
        }
        first = n
      }
      been-on = true
      last = n
    }

  }
  arr.push((first+1, last+1))
  arr
}

// find out, which variables cover which rows / columns
#let calculate-bar-positions((arrangement)) = {
  let row-dict = (:)
  let col-dict = (:)

  for (i, row) in arrangement.at(0).enumerate() {
    let arr = value-in-line(arrangement.at(0).len(), i)
    row-dict.insert(row, arr)
  }
  for (i, col) in arrangement.at(1).enumerate() {
    let arr = value-in-line(arrangement.at(1).len(), i)
    col-dict.insert(col, arr)
  }

  (row-dict, col-dict)
}

// creates the bar based on the previously calculated positions
#let draw-bar(name, start, end, offset, is-horizontal, height, small-bar-len, bar-letter-distance, stroke) = {
  let content-position = (0, 0)
  let main-line = (0, 0)
  let small-line-1 = (0, 0)
  let small-line-2 = (0, 0)
  let anchor = ""

  if is-horizontal{
    let length = end - start

    content-position = ((start + length/2, offset + bar-letter-distance))
    main-line = ((start, offset), (end, offset))
    small-line-1 = ((end, offset - small-bar-len),(end, offset + small-bar-len))
    small-line-2 = ((start, offset - small-bar-len),(start, offset + small-bar-len))

    anchor = "south"

  }else{
    start = (height - 1) - start
    end = (height - 1) - end

    let length = end - start

    content-position = (offset - bar-letter-distance, start + length/2)
    main-line = ((offset, start), (offset, end))
    small-line-1 = ((offset - small-bar-len, end),(offset + small-bar-len, end))
    small-line-2 = ((offset - small-bar-len, start),(offset + small-bar-len, start))

    anchor = "east"
  }

  content(content-position, (name), anchor: anchor)
  line(main-line.at(0), main-line.at(1), stroke: stroke)
  line(small-line-1.at(0), small-line-1.at(1), stroke: stroke)
  line(small-line-2.at(0), small-line-2.at(1), stroke: stroke)
}

#let draw-all-bars(bar-positions, abs-offset, distance-bar-grid, distance-bar-bar, distance-bar-letter, row-count, var-disp, small-bar-len, stroke) = {
  let offset = (-abs-offset -distance-bar-grid, row-count - abs-offset + distance-bar-grid)

  for (i, el) in bar-positions.enumerate() {
    for (n, (_, lines)) in el.pairs().enumerate().rev() {
      for line in lines {
        draw-bar(
          var-disp.at(i).at(n),
          line.at(0) - (1 + abs-offset),
          line.at(1) - abs-offset,
          offset.at(i),
          i != 0,
          row-count,
          small-bar-len,
          distance-bar-letter,
          stroke
        )
      }

      //update the offset for the next bar
      offset.at(i) += if i == 1 {distance-bar-bar} else {-distance-bar-bar}
    }
  }
}
