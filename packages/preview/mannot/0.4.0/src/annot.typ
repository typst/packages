#import "util.typ": coerce-outset, copy-stroke, default-stroke

#import "@preview/tiptoe:0.4.0"


#let _coerce-anchor(anchor) = {
  assert(type(anchor) == alignment, message: "`anchor` must be `alignment`")
  if anchor.x == none {
    anchor += center
  }
  if anchor.y == none {
    anchor += horizon
  }
  return anchor
}

#let _coerce-pos(pos) = {
  if type(pos) == alignment {
    pos = _coerce-anchor(pos)
    pos = if pos.y == horizon {
      (pos, pos.inv())
    } else {
      (pos.y + center, pos.inv())
    }
  } else if type(pos) == array {
    assert(pos.len() == 2, message: "`pos` must be `anchor` or `(anchor, anchor)`")
    pos = (_coerce-anchor(pos.at(0)), _coerce-anchor(pos.at(1)))
  } else {
    panic("`pos` must be alignment or array")
  }

  return pos
}

#let _coerce-connect(connect) = {
  if type(connect) == array {
    assert(connect.len() == 2, message: "`connect` must be `(anchor, anchor)` or \"elbow\"")

    connect = (
      _coerce-anchor(connect.at(0)),
      _coerce-anchor(connect.at(1)),
    )
  } else if connect != "elbow" {
    panic("`connect` must be `(anchor, anchor)` or \"elbow\"")
  }

  return connect
}


/// Places a custom annotation on content (or contents) within a math block that was previously marked.
///
/// This function generates a custom annotation by applying an overlay based on
/// metadata associated with content marked with a specific tag using a marking function.
///
/// Use this function as a foundation for defining custom annotation functions.
///
/// *Example*
/// #example(```typ
/// #let myannot(tag, annotation) = {
///   let a = rect(annotation)
///   let overlay(markers) = {
///     let m = markers.first().anchor-bounds
///     place(dx: m.x, dy: m.y + m.height, a)
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
  /// The tag (or an array of tags) associated with the content to annotate.
  /// This tag must match the tag previously used in a marking function.
  /// -> label | array
  tag,
  /// The function to create the custom annotation overlay.
  /// This function receives a list of metadata for the marked contents,
  /// and should return content to be placed relative to the top-left corner of the page.
  /// -> function
  overlay,
) = {
  if type(tag) == label {
    tag = (tag,)
  }

  context {
    let markers = tag.map(tag => query(selector(tag).before(here())).last().value)
    let hpos = here().position()
    // sym.wj
    math.equation(
      place(
        dx: -hpos.x,
        dy: -hpos.y,
        float: false,
        left + top,
        overlay(markers),
      ),
      block: false,
    )
  }
}


/// Places an annotation on content (or contents) within a math block that was previously marked.
///
/// *CAUTION:*
/// This function must be called within the same math block as the marked content.
/// Using it outside the math block triggers unnecessary layout updates,
/// which may result in a layout non-convergence error.
///
/// *Example*
/// ```example
/// $
/// markhl(x, #<e>)
/// #annot(<e>)[Annotation]
/// #annot(<e>, pos: top + right, dy: -1em)[Another annotation]
/// $
/// ```
///
/// ```example
/// $
/// markrect(integral x dif x, #<0>, #blue)
/// + markul(x, #<1>, #red)
///
/// #annot((<0>, <1>), pos: top, dx: 4em)[Multi]
/// #annot((<0>, <1>), pos: bottom + left, dx: -1em, dy: 1em, leader-connect: "elbow")[Elbow]
/// $
/// ```
///
/// -> content
#let annot(
  /// The tag (or an array of tags) associated with the content to annotate.
  /// This tag must match the tag previously used in a marking function.
  /// -> label | array
  tag,
  /// Content of the annotation. -> content
  annotation,
  /// Where to place the annotation relative to the marked content.
  /// This can be:
  /// - A single alignment for the relative position to the marked content.
  /// - A pair of alignments. The first one describes the anchor of the marked content,
  ///   and the second is the anchor of the annotation.
  /// -> alignment | (alignment, alignment)
  pos: bottom,
  /// The horizontal displacement of the annotation.
  /// -> auto | length
  dx: auto,
  /// The vertical displacement of the annotation.
  /// -> auto | length
  dy: auto,
  /// Whether to draw a leader line from the marked content to the annotation.
  /// If set to `auto`, it depends on the distance between the marked content and the annotation.
  /// -> auto | bool
  leader: auto,
  /// How to stroke the leader line.
  /// If its `paint` is set to `auto`, it will be set to the marking color.
  /// If its `thickness` is set to `auto`, it defaults to `.048em`.
  /// -> length | color | gradient | stroke | pattern | dictionary
  leader-stroke: .048em,
  /// How to end the leader line.
  /// See #link("https://typst.app/universe/package/tiptoe")[tiptoe].
  /// -> none | tiptoe
  leader-tip: none,
  /// How to start the leader line.
  /// See #link("https://typst.app/universe/package/tiptoe")[tiptoe].
  /// -> none | tiptoe
  leader-toe: tiptoe.straight.with(length: 600%),
  /// How to connect the leader line. This can be:
  /// - A pair of alignments describing the start anchor of the marked content
  ///   and the end anchor of the annotation.
  /// - "elbow" for an elbow-shaped leader line
  /// -> array | string
  leader-connect: (center + horizon, center + horizon),
  /// How much to pad the annotation content.
  /// -> length | dictionary
  annot-inset: (x: .08em, y: .16em),
  /// How to align the annotation text.
  /// -> auto | alignment
  annot-alignment: auto,
  /// Properties for the annotation text.
  /// If the `fill` property is not specified, it defaults to the marking's color.
  /// -> dictionary
  annot-text-props: (size: .7em),
  /// Properties for the annotation paragraph.
  /// -> dictionary
  annot-par-props: (leading: .4em),
  /// How much to pad the marked content.
  /// This can be specified as a single `length` value, which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  anchor-inset: 0pt,
) = {
  pos = _coerce-pos(pos)

  if dx == auto {
    dx = if pos.at(0).x == left and pos.at(1).x == right {
      -.2em
    } else if pos.at(0).x == right and pos.at(1).x == left {
      .2em
    } else {
      0em
    }
  }
  if dy == auto {
    dy = if pos.at(0).y == top and pos.at(1).y == bottom {
      -.2em
    } else if pos.at(0).y == bottom and pos.at(1).y == top {
      .2em
    } else {
      0em
    }
  }

  if type(annot-inset) != dictionary {
    annot-inset = (annot-inset,)
  }

  annotation = {
    show: pad.with(..annot-inset)
    set par(..annot-par-props)
    text(..annot-text-props, annotation)
  }

  context {
    let dx = dx.to-absolute()
    let dy = dy.to-absolute()
    let annot-size = measure(annotation)
    let aw = annot-size.width
    let ah = annot-size.height
    let anchor-inset = coerce-outset(anchor-inset)

    let overlay(markers) = {
      let bounds = markers.first().anchor-bounds
      let x = bounds.x - anchor-inset.left
      let y = bounds.y - anchor-inset.top
      let w = bounds.width + anchor-inset.left + anchor-inset.right
      let h = bounds.height + anchor-inset.top + anchor-inset.bottom
      let c = markers.first().color

      let leader-stroke = default-stroke(leader-stroke, paint: c, thickness: .048em)
      leader-stroke = copy-stroke(leader-stroke, thickness: leader-stroke.thickness.to-absolute())

      let ax = if pos.at(0).x == left { x } else if pos.at(0).x == right { x + w } else { x + w / 2 }
      ax -= if pos.at(1).x == left { 0pt } else if pos.at(1).x == right { aw } else { aw / 2 }
      ax += dx

      let ay = if pos.at(0).y == top { y } else if pos.at(0).y == bottom { y + h } else { y + h / 2 }
      ay -= if pos.at(1).y == top { 0pt } else if pos.at(1).y == bottom { ah } else { ah / 2 }
      ay += dy

      let annot-text-fill = annot-text-props.at("fill", default: c)
      let annot-alignment = if annot-alignment == auto {
        if ax + aw / 2 < x + w / 2 { right } else { left }
      } else {
        annot-alignment
      }
      let annotation = {
        show: box.with(width: aw, height: ah)
        set align(annot-alignment)
        set text(annot-text-fill)
        annotation
      }

      place(dx: ax, dy: ay, float: false, left + top, annotation)

      if leader != false {
        for data in markers {
          let bounds = data.anchor-bounds
          let x = bounds.x - anchor-inset.left
          let y = bounds.y - anchor-inset.top
          let w = bounds.width + anchor-inset.left + anchor-inset.right
          let h = bounds.height + anchor-inset.top + anchor-inset.bottom

          if leader == auto {
            let dst = calc.max(
              ax - x - w,
              x - ax - aw,
              ay - y - h,
              y - ay - ah,
            )
            if dst <= .3em.to-absolute() {
              continue
            }
          }

          if type(leader-connect) == array {
            let c0x = if leader-connect.at(0).x == left {
              x
            } else if leader-connect.at(0).x == right {
              x + w
            } else {
              x + w / 2
            }
            let c0y = if leader-connect.at(0).y == top {
              y
            } else if leader-connect.at(0).y == bottom {
              y + h
            } else {
              y + h / 2
            }
            let c1x = if leader-connect.at(1).x == left {
              ax
            } else if leader-connect.at(1).x == right {
              ax + aw
            } else {
              ax + aw / 2
            }
            let c1y = if leader-connect.at(1).y == top {
              ay
            } else if leader-connect.at(1).y == bottom {
              ay + ah
            } else {
              ay + ah / 2
            }
            let cdx = c1x - c0x
            let cdy = c1y - c0y

            let l0x = c0x
            let l0y = c0y
            let l1x = c1x
            let l1y = c1y

            if leader-connect.at(0) == center + horizon {
              if calc.abs(cdx.pt()) * h < calc.abs(cdy.pt()) * w {
                if cdy > 0pt {
                  l0x = c0x + h / 2 / cdy * cdx
                  l0y = y + h
                } else {
                  l0x = c0x - h / 2 / cdy * cdx
                  l0y = y
                }
              } else {
                if cdx > 0pt {
                  l0x = x + w
                  l0y = c0y + w / 2 / cdx * cdy
                } else {
                  l0x = x
                  l0y = c0y - w / 2 / cdx * cdy
                }
              }
            }

            if leader-connect.at(1) == center + horizon {
              if calc.abs(cdx.pt()) * ah < calc.abs(cdy.pt()) * aw {
                if cdy > 0pt {
                  l1x = c1x - ah / 2 / cdy * cdx
                  l1y = ay
                } else {
                  l1x = c1x + ah / 2 / cdy * cdx
                  l1y = ay + ah
                }
              } else {
                if cdx > 0pt {
                  l1x = ax
                  l1y = c1y - aw / 2 / cdx * cdy
                } else {
                  l1x = ax + aw
                  l1y = c1y + aw / 2 / cdx * cdy
                }
              }
            }

            // if leader == auto {
            //   let leader-len = calc.norm((l1x - l0x).pt(), (l1y - l0y).pt())
            //   if leader-len <= .4em.to-absolute().pt() {
            //     continue
            //   }
            // }

            {
              set place(left + top, float: false) // For RTL document.
              tiptoe.curve(
                stroke: leader-stroke,
                tip: leader-tip,
                toe: leader-toe,
                curve.move((l0x, l0y)),
                curve.line((l1x, l1y)),
              )
            }
          } else {
            let corner = .2em.to-absolute()
            let components = if ax > x + corner or ax + aw < x + w - corner {
              if ax + aw / 2 < x + w / 2 {
                if ay + ah < y or ay + ah > y + h {
                  let l0x = calc.max(x + corner, ax + aw)
                  let l0y = if ay + ah < y { y } else if y + h < ay + ah { y + h }
                  (
                    curve.move((l0x, l0y)),
                    curve.line((l0x, ay + ah)),
                    curve.line((ax, ay + ah)),
                  )
                } else {
                  (
                    curve.move((x, ay + ah)),
                    curve.line((ax, ay + ah)),
                  )
                }
              } else {
                if ay + ah < y or ay + ah > y + h {
                  let l0x = calc.min(x + w - corner, ax)
                  let l0y = if ay + ah < y { y } else if y + h < ay + ah { y + h }
                  (
                    curve.move((l0x, l0y)),
                    curve.line((l0x, ay + ah)),
                    curve.line((ax + aw, ay + ah)),
                  )
                } else {
                  (
                    curve.move((x + w, ay + ah)),
                    curve.line((ax + aw, ay + ah)),
                  )
                }
              }
            } else {
              if ay > y + h {
                (
                  curve.move((x + w / 2, y + h)),
                  curve.line((x + w / 2, ay)),
                )
              } else {
                (
                  curve.move((x + w / 2, y)),
                  curve.line((x + w / 2, ay + ah)),
                )
              }
            }

            {
              set place(left + top, float: false) // For RTL document.
              tiptoe.curve(
                stroke: leader-stroke,
                tip: leader-tip,
                toe: leader-toe,
                ..components,
              )
            }
          }
        }
      }
    }

    return core-annot(tag, overlay)
  }
}


/// Places a CeTZ canvas annotation on content (or contents) within a math block that was previously marked.
///
/// Within the CeTZ canvas code block, you can refer to the position of the marked content
/// using an anchor with the same name as the tag.
/// For multiple tags, you'll have multiple corresponding anchors.
///
/// *CAUTION:*
/// This function must be called within the same math block as the marked content.
/// Using it outside the math block triggers unnecessary layout updates,
/// which may result in a layout non-convergence error.
///
/// *Example*
/// ```example
/// #import "@preview/cetz:0.5.2"
///
/// $
///   mark(x, #<0>) + mark(y, #<1>)
///
///   #annot-cetz((<0>, <1>), cetz, {
///     import cetz.draw: *
///     content((0, -1), [Annotation], anchor: "north-west", name: "a")
///     set-style(stroke: .7pt, mark: (start: ">", scale: 0.6))
///     line("0", "a")
///     bezier-through("1.south-east", (rel: (0.2, -0.1)), "a.north")
///   })
/// $
/// ```
///
/// -> content
#let annot-cetz(
  /// The tag (or an array of tags) associated with the content to annotate.
  /// This tag must match the tag previously used in a marking function.
  /// -> label | array
  tag,
  /// A CeTZ module.
  /// -> module
  cetz,
  /// A code block containing CeTZ drawing commands.
  /// -> array
  drawable,
) = {
  let overlay(markers) = {
    let origin = markers.first().anchor-bounds
    let preamble = markers
      .map(data => {
        let bounds = data.anchor-bounds
        cetz.draw.rect(
          (bounds.x - origin.x, -(bounds.y - origin.y)),
          (bounds.x + bounds.width - origin.x, -(bounds.y + bounds.height - origin.y)),
          name: str(data.tag),
          stroke: none,
          fill: none,
        )
      })
      .sum()

    let ref-lab = <_mannot-annot-cetz-ref>
    let ref-lab-content = cetz.draw.content((0, 0), [#none#ref-lab])
    place([#none#ref-lab])

    place(hide(cetz.canvas(ref-lab-content + preamble + drawable)))

    context {
      let ref-pos-array = query(selector(ref-lab).before(here())).map(e => e.location().position())
      let ref-pos1 = ref-pos-array.at(ref-pos-array.len() - 2)
      let ref-pos2 = ref-pos-array.last()
      place(
        dx: origin.x + ref-pos1.x - ref-pos2.x,
        dy: origin.y + ref-pos1.y - ref-pos2.y,
        cetz.canvas(preamble + drawable),
      )
    }
  }

  core-annot(tag, overlay)
}
