// This file contains helper functions to process and normalize special 
// arguments to functions, especially where multiple formats and types 
// are allowed.

#import "layout.typ"


#let process-padding-arg(padding) = {
  let type = type(padding)
  if type == "length" { 
    return (left: padding, top: padding, right: padding, bottom: padding)
  }
  if type == "dictionary" {
    let rest = padding.at("rest", default: 0pt)
    let x = padding.at("x", default: rest)
    let y = padding.at("y", default: rest)
    return (
      left: padding.at("left", default: x), 
      right: padding.at("right", default: x), 
      top: padding.at("top", default: y), 
      bottom: padding.at("bottom", default: y), 
    )
  }
  assert(false, message: "Unsupported type \"" + type + "\" as argument for padding")
}


/// Process the label argument to `gate`. Allowed input formats are none, array of dictionaries
/// or a single dictionary/string/content (for just one label). 
/// 
/// Each dictionary needs to contain the key content and may optionally have values 
/// for the  keys `pos` (specifying a 1d or 2d alignment) and `dx` as well as `dy`
#let process-label-arg(
  labels, 
  default-pos: right,
  default-dx: .4em, 
  default-dy: .4em
) = {
  if labels == none {  return () }
  let type = type(labels)
  if type == "dictionary" { labels = (labels,) } 
  else if type in ("content", "string") { labels = ((content: labels),) } 
  else if type == "dictionary" { labels = ((content: labels),) } 
  let processed-labels = ()
  for label in labels {
    let alignment = layout.make-2d-alignment(label.at("pos", default: default-pos))
    let (x, y) = layout.make-2d-alignment-factor(alignment)
    processed-labels.push((
      content: label.content,
      pos: alignment,
      dx: label.at("dx", default: default-dx * x),
      dy: label.at("dy", default: default-dy * y)
    ))
  }
  processed-labels
}