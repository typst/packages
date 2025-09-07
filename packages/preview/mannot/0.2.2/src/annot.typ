#import "util.typ": copy-stroke

#let _place-path-arrow(
  stroke: 1pt,
  tail-length: 5pt,
  tail-angle: 30deg,
  ..vertices,
) = {
  place(path(stroke: stroke, ..vertices))

  let stroke = copy-stroke(stroke, (dash: "solid"))

  context {
    let vertices = vertices.pos()
    let tail-length = tail-length.to-absolute()

    let p1 = vertices.last()
    let p1x = p1.at(0).to-absolute()
    let p1y = p1.at(1).to-absolute()
    let p2 = vertices.at(vertices.len() - 2)
    let p2x = p2.at(0).to-absolute()
    let p2y = p2.at(1).to-absolute()

    let p12x = p2x - p1x
    let p12y = p2y - p1y
    let p12len = 1pt * calc.sqrt(p12x.pt() * p12x.pt() + p12y.pt() * p12y.pt())
    p12x = p12x / p12len * tail-length
    p12y = p12y / p12len * tail-length

    let angle = 30deg
    let sin = calc.sin(angle)
    let cos = calc.cos(angle)
    let t1x = p1x + p12x * cos - p12y * sin
    let t1y = p1y + p12x * sin + p12y * cos
    let t2x = p1x + p12x * cos + p12y * sin
    let t2y = p1y - p12x * sin + p12y * cos

    place(path(stroke: stroke, (t1x, t1y), (p1x, p1y), (t2x, t2y)))
  }
}


/// Places a custom annotation on previously marked content within a math block.
///
/// This function creates a custom annotation by applying an overlay to content
/// that was previously marked with a specific tag using `core-mark`.
/// It must be used within the same math block as the marked content.
///
/// Use this function as a foundation for defining custom annotation functions.
///
/// *Example*
/// #example(```typ
/// #let myannot(tag, annotation) = {
///   let overlay(width, height, color) = {
///     set text(white, .8em)
///     let annot-block = box(fill: color, inset: .4em, annotation)
///     place(annot-block, dy: height)
///   }
///   return core-annot(tag, overlay)
/// }
///
/// $
/// mark(x, tag: #<e>)
/// #myannot(<e>)[This is x.]
/// $
/// ```, preview-inset: 20pt)
///
/// -> content
#let core-annot(
  /// The tag associated with the content to annotate.
  /// This tag must match a tag previously used in a `core-mark` call.
  /// -> label
  tag,
  /// The function to create the custom annotation overlay.
  /// This function receives the width, height, and color of the marked content (including padding)
  /// and should return content to be placed *over* the marked content.
  /// The signature is `overlay(width, height, color)`.
  /// -> function
  overlay,
) = {
  context {
    let info = query(selector(tag).before(here())).last()
    info = info.value

    let hpos = here().position()
    let dx = info.x - hpos.x
    let dy = info.y - hpos.y
    let width = info.width
    let height = info.height
    let color = info.color
    sym.wj
    box(place(dx: dx, dy: dy, overlay(width, height, color)))
    sym.wj
  }
}


/// Places an annotation on previously marked content within a math block.
///
/// This function must be used within the same math block as the marked content.
///
/// *Example*
/// ```example
/// $
/// mark(x, tag: #<e>)
/// #annot(<e>)[Annotation]
/// $
/// ```
///
/// #example(```typ
/// $
/// markrect(integral x dif x, tag: #<x>, color: #blue)
/// + markul(y, tag: #<y>, color: #red)
///
/// #annot(<x>, pos: left)[Left]
/// #annot(<x>, pos: top + left)[Top left]
/// #annot(<y>, pos: left, yshift: 2em)[Left arrow]
/// #annot(<y>, pos: top + right, yshift: 1em)[Top right arrow]
/// $
/// ```, preview-inset: 20pt)
///
/// -> content
#let annot(
  /// The tag associated with the content to annotate.
  /// This tag must match a tag previously used in marking.
  /// -> label
  tag,
  /// The content of the annotation. -> content
  annotation,
  /// The position of the annotation relative to the marked content.
  /// Possible values are (`top` or `bottom`) + (`left`, `center` or `right`).
  /// -> alignment
  pos: center + bottom,
  /// The vertical offset between the annotation and the marked content.
  /// -> length
  yshift: .2em,
  /// Properties for the annotation text.
  /// If the `fill` property is not specified, it defaults to the marking's color.
  /// -> dictionary
  text-props: (size: .6em, bottom-edge: "descender"),
  /// Properties for the annotation paragraph.
  /// -> dictionary
  par-props: (leading: .3em),
  /// The alignment of the annotation text within its box.
  /// -> auto | alignment
  alignment: auto,
  /// Whether to display an arrow connecting the annotation to the marked content.
  /// If set to `auto`, an arrow is shown when `yshift` is greater than `0.4em`.
  /// -> auto | bool
  show-arrow: auto,
  /// The stroke style for the arrow.
  /// If the `paint` property is not specified, it defaults to the marking's color.
  /// -> auto | none | color | length | dictionary | stroke
  arrow-stroke: .08em,
  /// The spacing between the arrow and the annotation box.
  /// -> length
  arrow-padding: .2em,
) = {
  assert(
    pos.x == left or pos.x == center or pos.x == right or pos.x == none,
    message: "The field `x` of the argument `alignment` of the function
        `annot` must be `left`, `center`, `right` or `none`.",
  )
  assert(
    pos.y == top or pos.y == bottom or pos.y == none,
    message: "The field `y` of the argument `alignment` of the function
        `annot` must be `top`, `bottom` or `none`.",
  )
  let pos = (
    if pos.x == none {
      center
    } else {
      pos.x
    }
      + if pos.y == none {
        bottom
      } else {
        pos.y
      }
  )
  if alignment == auto {
    alignment = pos.x.inv()
  }


  context {
    let text-props = text-props
    let annot-tsize = text-props.remove("size", default: 1em).to-absolute()
    set text(size: annot-tsize)

    context {
      let annot-content = {
        show: par.with(..par-props)
        show: align.with(alignment)
        text(..text-props, annotation)
      }
      let annot-size = measure(annot-content)

      let overlay(width, height, color) = text(
        size: annot-tsize,
        {
          let annot-content = text(annot-content)
          if text-props.at("fill", default: auto) == auto {
            annot-content = text(color, annot-content)
          }

          let draw-arrow = show-arrow
          if draw-arrow == auto {
            draw-arrow = if yshift > .4em {
              true
            } else {
              false
            }
          }

          if not draw-arrow {
            // Place annotation.

            let dx = (
              width / 2
                + if pos.x == center {
                  -annot-size.width / 2
                } else if pos.x == left {
                  -annot-size.width
                }
            )
            let dy = if pos.y == bottom {
              height + yshift
            } else {
              -annot-size.height - yshift
            }

            place(annot-content, dx: dx, dy: dy)
          } else {
            // Place arrow and annotation.

            let arrow-stroke = stroke(arrow-stroke)
            if arrow-stroke.paint == auto {
              arrow-stroke = copy-stroke(arrow-stroke, (paint: color))
            }

            let p3x = width / 2
            let p3y = if pos.y == bottom {
              height + arrow-stroke.thickness
            } else {
              -arrow-stroke.thickness
            }

            let p2x = p3x
            let p2y = if pos.y == bottom {
              if pos.x == center {
                p3y + yshift
              } else {
                p3y + annot-size.height + arrow-padding * 2 + yshift
              }
            } else {
              p3y - yshift
            }

            let p1x = if pos.x == right {
              p2x + annot-size.width + arrow-padding
            } else if pos.x == left {
              p2x - annot-size.width - arrow-padding
            }
            let p1y = p2y

            if arrow-stroke.thickness > 0pt {
              // Place the arrow.
              if pos.x == center {
                _place-path-arrow(stroke: arrow-stroke, tail-length: .3em, (p2x, p2y), (p3x, p3y))
              } else {
                _place-path-arrow(stroke: arrow-stroke, tail-length: .3em, (p1x, p1y), (p2x, p2y), (p3x, p3y))
              }
            }

            // Place the annotation.
            if pos.x == right {
              place(annot-content, dx: p2x + arrow-padding, dy: p2y - annot-size.height - arrow-padding)
            } else if pos.x == left {
              place(
                annot-content,
                dx: p2x - annot-size.width - arrow-padding,
                dy: p2y - annot-size.height - arrow-padding,
              )
            } else {
              if pos.y == bottom {
                place(annot-content, dx: p2x - annot-size.width / 2, dy: p2y + arrow-padding)
              } else {
                place(annot-content, dx: p2x - annot-size.width / 2, dy: p2y - annot-size.height - arrow-padding)
              }
            }
          }
        },
      )

      return core-annot(tag, overlay)
    }
  }
}
