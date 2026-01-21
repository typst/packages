#import "length-helpers.typ": *

/// Update bounds to contain the given rectangle
/// - bounds (array): Current bound coordinates x0, y0, x1, y1
/// - rect (array): Bounds rectangle x0, y0, x1, y1
#let update-bounds(bounds, rect, em) = (
  calc.min(bounds.at(0), convert-em-length(rect.at(0), em)), 
  calc.min(bounds.at(1), convert-em-length(rect.at(1), em)),
  calc.max(bounds.at(2), convert-em-length(rect.at(2), em)),
  calc.max(bounds.at(3), convert-em-length(rect.at(3), em)),
)

#let offset-bounds(bounds, offset) = (
  bounds.at(0) + offset.at(0),
  bounds.at(1) + offset.at(1),
  bounds.at(2) + offset.at(0),
  bounds.at(3) + offset.at(1),
)

#let make-bounds(x0: 0pt, y0: 0pt, width: 0pt, height: 0pt, x1: none, y1: none, em) = (
  convert-em-length(x0, em),
  convert-em-length(y0, em),
  convert-em-length(if x1 != none { x1 } else { x0 + width }, em),
  convert-em-length(if y1 != none { y1 } else { y0 + height }, em),
)


/// Take an alignment or 2d alignment and return a 2d alignment with the possibly 
/// unspecified axis set to a default value. 
#let make-2d-alignment(alignment, default-vertical: horizon, default-horizontal: center) = {
  if type(alignment) == "2d alignment" { return alignment }
  let axis = alignment.axis()
  if axis == none { return alignment }
  if alignment.axis() == "horizontal" { return alignment + default-vertical }
  if alignment.axis() == "vertical" { return alignment + default-horizontal }
}


#let make-2d-alignment-factor(alignment) = {
  let alignment = make-2d-alignment(alignment)
  let x = 0
  let y = 0
  if alignment.x == left { x = -1 }
  else if alignment.x == right { x = 1 }
  if alignment.y == top { y = -1 }
  else if alignment.y == bottom { y = 1 }
  return (x, y)
}




#let default-size-hint(item, draw-params) = {
  let func = item.draw-function
  let hint = measure(func(item, draw-params), draw-params.styles)
  hint.offset = auto
  return hint
}





#let lrstick-size-hint(gate, draw-params) = {
  let hint = measure((gate.draw-function)(gate, draw-params), draw-params.styles)
  let dx = 0pt
  if gate.data.align == "right" { dx = hint.width } 
  hint.offset = (x: dx, y: auto)
  return hint
}





/// Place some content along with optional labels while computing bounds. 
/// 
/// Returns a pair of the placed content and a bounds array. 
///
/// - content (content): The content to place. 
/// - dx (length): Horizontal displacement.
/// - dy (length): Vertical displacement.
/// - size (auto, dictionary): For computing bounds, the size of the placed content
///           is needed. If `auto` is passed, this function computes the size itself
///           but if it is already known it can be passed through this parameter. 
/// - labels (array): An array of labels which in turn are dictionaries that must 
///           specify values for the keys `content` (content), `pos` (strictly 2d 
///           alignment), `dx` and `dy` (both length, ratio or relative length).
/// - draw-params (dictionary): Drawing parameters. Must contain a styles object at 
///           the key `styles` and an absolute length at the key `em`. 
/// -> pair
#let place-with-labels(
  content, 
  dx: 0pt, 
  dy: 0pt,
  size: auto,
  labels: (),
  draw-params: none,
) = {
  if size == auto { size = measure(content, draw-params.styles) }
  let bounds = make-bounds(
    x0: dx, y0: dy, width: size.width, height: size.height, draw-params.em
  )
  if labels.len() == 0 {
    return (place(content, dx: dx, dy: dy), bounds)    
  }
  
  let offset = (dx, dy)
  let placed-labels = place(dx: dx, dy: dy, 
    box({
      for label in labels {
        let label-size = measure(label.content, draw-params.styles)
        let ldx = get-length(label.dx, size.width)
        let ldy = get-length(label.dy, size.height)
        
        if label.pos.x == left { ldx -= label-size.width }
        else if label.pos.x == center { ldx += 0.5 * (size.width - label-size.width) }
        else if label.pos.x == right { ldx += size.width }
        if label.pos.y == top { ldy -= label-size.height }
        else if label.pos.y == horizon { ldy += 0.5 * (size.height - label-size.height) }
        else if label.pos.y == bottom { ldy += size.height }
        
        
        let placed-label = place(label.content, dx: ldx, dy: ldy)
        let label-bounds = make-bounds(
          x0: ldx + dx, y0: ldy + dy, 
          width: label-size.width, height: label-size.height, 
          draw-params.em
        )
        bounds = update-bounds(bounds, label-bounds, draw-params.em)
        placed-label
      }
    })
  )
  return (place(content, dx: dx, dy: dy) + placed-labels, bounds)
}




// From a list of row heights or col widths, compute the respective
// cell center coordinates, e.g., (3pt, 3pt, 4pt) -> (1.5pt, 4.5pt, 8pt)
#let compute-center-coords(cell-lengths, gutter) = {
  let center-coords = ()
  let tmpx = 0pt
  gutter.insert(0, 0pt)
  // assert.eq(cell-lengths.len(), gutter.len())
  for (cell-length, gutter) in cell-lengths.zip(gutter) {
    center-coords.push(tmpx + cell-length / 2 + gutter)
    tmpx += cell-length + gutter
  }
  return center-coords
} 


// Given a list of n center coordinates and n cell sizes along one axis (x or y), retrieve the coordinates for a single cell or a list of cells given by index. 
// If a cell index is out of bounds, the outer last coordinate is returned
// center-coords: List of center coordinates for each index
// cell-sizes: List of cell sizes for each index
// cells: Indices of cell for which to retrieve coordinates
// These may also be floats. In this case, the integer part determines the cell index and the fractional part a percentage of the cell width. e.g., passing 2.5 would return the center coordinate of the cell
#let get-cell-coords(center-coords, cell-sizes, cells) = {
  let last = center-coords.at(-1) + cell-sizes.at(-1) / 2
  let get(x) = { 
    let integral = calc.floor(x)
    let fractional = x - integral
    let cell-width = cell-sizes.at(integral, default: 0pt)
    return center-coords.at(integral, default: last) + cell-width * (fractional - 0.5)
  }
  if type(cells) in ("integer", "float") { get(cells)  }
  else if type(cells) == "array" { cells.map(x => get(x)) }
  else { panic("Unsupported coordinate type") }
}

#let get-cell-coords1(center-coords, cell-sizes, cells) = {
  let last = center-coords.at(-1) + cell-sizes.at(-1) / 2
  let get(x) = { 
    let integral = calc.floor(x)
    let fractional = x - integral
    let cell-width = cell-sizes.at(integral, default: 0pt)
    let c1 = center-coords.at(integral, default: last)
    let c2 = center-coords.at(integral + 1, default: last)
    return c1 + (c2 - c1) * (fractional)
  }
  if type(cells) in ("integer", "float") { get(cells)  }
  else if type(cells) == "array" { cells.map(x => get(x)) }
  else { panic("Unsupported coordinate type") }
}

#let std-scale = scale
