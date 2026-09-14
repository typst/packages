#import "@preview/zero:0.4.0": ztable

#let stdstroke = stroke
#let stdtable = table

#let tiling = if sys.version < version(0, 13) { std.pattern } else { std.tiling }

#let cols(spec, stroke: auto, line-distance: 1.6pt) = {
  assert(type(spec) == str, message: "expected a `str` argument, got `" + str(type(spec)) + "`")
  
  let aligns = (r: right, c: center, l: left, a: auto)
  let format = ()
  
  let align = ()
  let columns = ()
  let vline-specs = ()
  
  let i = 0
  let col = 0
  let count-vlines = 0
  
  while i < spec.len() {
    let c = spec.at(i)
    if lower(c) in "lcra" {
      align.push(aligns.at(lower(c)))
      format.push(if lower(c) == c { none } else { auto })
      columns.push(auto)
      col += 1
      count-vlines = 0
    } else if c == "|" {
      count-vlines += 1
      vline-specs.push((col, count-vlines, stroke))
      assert(count-vlines <= 2, message: "At most two consecutive `|` are supported. ")
    } else if c == "[" {
      let end = spec.slice(i).position("]")
      if end == none {
        assert(false, message: "Unmatched `[`")
      }
      let width = eval(spec.slice(i + 1, i + end))
      if count-vlines == 0 {
        assert(columns.len() > 0, message: "Unexpected width specification `" + spec.slice(i, i + end + 1) + "` at the beginning")
        assert(width == auto or type(width) in (relative, length, fraction), message: "column width expects a relative length, fraction, or auto, found " + str(type(width)))
        columns.last() = width
      } else {
        assert(width == none or type(width) in (length, color, gradient, tiling, dictionary, stdstroke), message: "vline stroke expects a length, color, gradient, tiling, dictionary, stroke, or none, found " + str(type(width)))
        vline-specs.last().last() = width
      }
      i += end
      
    } else if c == " " {
      
     } else {
      if c == "]" { assert(false, message: "Unexpected `]`") }
      assert(false, message: "Unknown column type `" + c + "`")
    }
    i += 1
  }
  let vlines = ()
  let column-gutter = (auto,) * columns.len()
  for (col, num, stroke) in vline-specs {
    let vline = table.vline
    if stroke != auto { vline = vline.with(stroke: stroke) }
    if num == 2 {
      assert(col != 0 and col != columns.len(), message: "Double lines `||` are currently not supported before the first and after the last column. ")
      vlines.push(vline(x: col - 1, position: end))
      column-gutter.at(col - 1) = line-distance
    }
    vlines.push(vline(x: col))
  }

  if auto in format { format = (format: format) }
  else { format = (:) }
  
  arguments(
    columns: columns,
    align: align,
    stroke: none,
    column-gutter: column-gutter,
    ..vlines,
    ..format
  )
}



#let table(..children) = {
  let named = children.named()
  if "cols" in named {
    let colspec = named.cols
    named.remove("cols")
    return ztable(
      ..cols(colspec),
      ..named, 
      ..children.pos()
    )
  } else { return stdtable(..children) }
}