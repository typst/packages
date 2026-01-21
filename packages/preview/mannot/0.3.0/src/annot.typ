#import "util.typ": default-stroke, copy-stroke

#import "@preview/tiptoe:0.3.0"


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
///     let m = markers.first()
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

  sym.wj
  context {
    let markers = tag.map(tag => query(selector(tag).before(here())).last().value)

    let hpos = here().position()
    box(place(dx: -hpos.x, dy: -hpos.y, float: false, left + top, overlay(markers)))
    sym.wj
  }
}


/// Places an annotation on content (or contents) within a math block that was previously marked.
///
/// *Example*
/// ```example
/// #v(2em)
/// $
/// markhl(x, tag: #<e>)
/// #annot(<e>)[Annotation]
/// #annot(<e>, pos: top + right, dy: -1em)[Another annotation]
/// $
/// #v(1em)
/// ```
///
/// #example(```typ
/// $
/// markrect(integral x dif x, tag: #<0>, color: #blue)
/// + markul(x, tag: #<1>, color: #blue)
///
/// #annot((<0>, <1>), pos: top, dx: 4em)[Multi]
/// #annot((<0>, <1>), pos: bottom + left, dx: -1em, dy: 1em, leader-connect: "elbow")[Elbow]
/// $
/// #v(1em)
/// ```, preview-inset: 20pt)
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
  leader-stroke: .048em,
  /// How to end the leader line.
  /// See #link("https://typst.app/universe/package/tiptoe")[tiptoe].
  leader-tip: none,
  /// How to start the leader line.
  /// See #link("https://typst.app/universe/package/tiptoe")[tiptoe].
  leader-toe: tiptoe.straight.with(length: 600%),
  /// How to connect the leader line. This can be:
  /// - A pair of alignments describing the start anchor of the marked content
  ///   and the end anchor of the annotation.
  /// - "elbow" for an elbow-shaped leader line
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

    let overlay(markers) = {
      let x = markers.first().x
      let y = markers.first().y
      let w = markers.first().width
      let h = markers.first().height
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
        for info in markers {
          let x = info.x
          let y = info.y
          let w = info.width
          let h = info.height

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


/// Places a CeTZ canvas annotation on content (or contecnts) within a math block that was previously marked.
///
/// Within the CeTZ canvas code block, you can refer to the position of the marked content
/// using an anchor with the same name as the tag.
/// For multiple tags, you'll have multiple corresponding anchors.
///
/// *Example*
/// ```example
/// #import "@preview/cetz:0.3.4"
///
/// $
///   mark(x, tag: #<0>) + mark(y, tag: #<1>)
///
///   #annot-cetz((<0>, <1>), cetz, {
///     import cetz.draw: *
///     content((0, -.6), [Annotation], anchor: "north-west", name: "a")
///     set-style(stroke: .7pt, mark: (start: "straight", scale: 0.6))
///     line("0", "a")
///     line("1", "a")
///   })
/// $
/// #v(1em)
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
    let origin = markers.first()
    let preamble = markers
      .map(info => {
        cetz.draw.rect(
          (info.x - origin.x, -(info.y - origin.y)),
          (info.x + info.width - origin.x, -(info.y + info.height - origin.y)),
          name: str(info.tag),
          stroke: none,
          fill: none,
        )
      })
      .sum()
    let loc-lab = <_mannot-annot-cetz-loc>
    let loc-lab-content = cetz.draw.content((0, 0), [#none#loc-lab])

    place(hide(cetz.canvas(loc-lab-content + preamble + drawable)))

    context {
      let cpos = query(selector(loc-lab).before(here())).last().location().position()
      place(dx: origin.x - cpos.x, dy: origin.y - cpos.y, cetz.canvas(preamble + drawable))
    }
  }

  core-annot(tag, overlay)
}
