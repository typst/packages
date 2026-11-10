/// Updates the first stroke with the second, i.e., returns the second stroke but all 
/// fields that are auto are inherited from the first stroke. 
/// If the second stroke is none, returns none. 
#let update-stroke(stroke1, stroke2) = {
  let if-not-auto(a, b) = if b == auto {a} else {b}
  if stroke2 == none { return none }
  if stroke1 == none { stroke1 = stroke() }
  let s1 = stroke(stroke1)
  let s2 = stroke(stroke2)
  let paint = if-not-auto(s1.paint, s2.paint)
  let thickness = if-not-auto(s1.thickness, s2.thickness)
  let cap = if-not-auto(s1.cap, s2.cap)
  let join = if-not-auto(s1.join, s2.join)
  let dash = if-not-auto(s1.dash, s2.dash)
  let miter-limit = if-not-auto(s1.miter-limit, s2.miter-limit)
  return stroke(paint: paint, thickness: thickness, cap: cap, join: join, dash: dash, miter-limit: miter-limit)
}




/// Merge a series of fills sorted by descending priority. Fills exclude each other, 
/// so the first fill that is not auto is returned. If all fills are
/// `auto`, then `auto` is returned. 
///
/// -> auto | none | color | gradient | tiling
#let merge-fills(
  
  /// The fills to merge. 
  /// -> none | color | gradient | tiling
  ..fills
  
) = {
  let fills = fills.pos()
  let pos = fills.position(x => x != auto)
  if pos == none { return auto }
  return fills.at(pos)
}



/// Merge a series of strokes sorted by descending priority.
///
/// -> stroke
#let merge-strokes(
  
  /// The strokes to merge. 
  /// -> none | auto | stroke | length | color | gradient | tiling | dictionary
  ..strokes
  
) = {
  let strokes = strokes.pos().filter(x => x != auto).rev()
  return strokes.fold(stroke(), update-stroke)
}




/// Brings a margin argument into "normal" form, which is a dictionary with the 
/// (all obligatory) keys `left`, `right`, `top`, and `bottom`. 
/// The input can either be a single `ratio` or a dictionary
/// with the possible keys
///   - `left`, `right`, `top`, and `bottom`,
///   - `x` and `y` for combined `left`/`right` and `top`/`bottom`, respectively,
///   - and `rest` for all otherwise unspecified values. 
///
/// -> dictionary
#let process-margin(
  
  /// The margin argument to process. 
  /// -> ratio | dictionary
  margin
  
) = {
  if type(margin) == ratio {
    (left: margin, right: margin, top: margin, bottom: margin)
  } else if type(margin) == dictionary {
    let rest = margin.at("rest", default: 5%)
    if not "left" in margin { margin.left = margin.at("x", default: rest) }
    if not "right" in margin { margin.right = margin.at("x", default: rest) }
    if not "top" in margin { margin.top = margin.at("y", default: rest) }
    if not "bottom" in margin { margin.bottom = margin.at("y", default: rest) }
    margin
  } else {
    assert(false, message: "The type `" + str(type(margin)) + "` is not valid for margin arguments. ")
  }
}


/// Makes a 2D alignment out of a 2D or 1D alignment. If the input is already a 2D 
/// alignment, it is returned unchanged. Else, it is complemented with the respective 
/// defaults for vertical and horizontal alignment. 
///
/// -> alignment
#let twod-ify-alignment(
  
  /// Alignment to 2D-ify. 
  /// -> alignment
  alignment, 
  
  /// Default vertical alignment to apply if the input provides just a horizontal alignment. 
  /// -> alignment
  vertical: horizon, 

  /// Default horizontal alignment to apply if the input provides just a vertical alignment. 
  /// -> alignment
  horizontal: center
  
) = {
  if alignment.axis() == none { return alignment }
  if alignment.axis() == "vertical" {
    return alignment + horizontal
  }
  return alignment + vertical
}



#let process-grid-arg(grid) = {
  if grid == none { return (stroke: none, stroke-sub: none) }
  if grid == auto { return (:) }
  if type(grid) == dictionary { return grid }
  if type(grid) in (color, stroke, length) {
    return (stroke: grid)
  }
}


#let resolve-em-length(length) = {
  if type(length) == std.length {
    length.to-absolute()
  } else if type(length) == relative {
    length.ratio + length.length.to-absolute()
  } else {
    length
  }
}

// Process for example the bar or violin width and normalize it into an array 
// of data coordinates with the same number of elements as x. 
#let process-plot-item-width(

  /// The width argument. See @bar.width. 
  /// -> ratio | int | float | duration | array
  width, 

  /// The coordinates along the axis where width has meaning. 
  /// -> array
  x

) = {
  if type(width) == ratio {
    if x.len() >= 2 {
      width = width / 100% * calc.min(..x.windows(2).map(((a, b)) => calc.abs(b - a)))
    } else {
      width = width / 100%
    }
  } else if type(width) == duration {
    width = width.seconds()
  } else if type(width) == array and type(width.at(0, default: 0)) == duration {
    width = width.map(duration.seconds)
  } 
  if type(width) != array { 
    width = (width,) * x.len()
  }

  width
}