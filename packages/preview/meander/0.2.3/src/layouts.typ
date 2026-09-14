#import "tiling.typ"
#import "threading.typ"
#import "elems.typ"

/// Debug version of the toplevel `reflow`,
/// that only displays the partitioned layout.
/// -> content
#let regions(
  /// Input sequence to segment.
  /// -> array(elem)
  seq,
  /// Whether to show the placed objects (#typ.v.true),
  /// or only their hitbox (#typ.v.false).
  /// -> bool
  display: true,
  /// #property(since: version(0, 2, 2))
  /// Controls relation to other content on the page.
  /// See analoguous #arg[placement] option on @cmd:meander:reflow.
  /// -> any
  placement: page,
  /// #property(since: version(0, 2, 1))
  /// Ignored.
  overflow: none,
) = {
  if seq == none { seq = () }
  let (wrapper, placeholder) = tiling.placement-mode(placement)
  wrapper(size => {
    let (pages,) = tiling.separate(seq)
    for (idx, elems) in pages.enumerate() {
      let maximum-height = 0pt
      if idx != 0 {
        if placement == float {
          panic("Pagebreaks are only supported when the placement is 'page' or 'box'")
        }
        colbreak()
      }
      let data = tiling.create-data(size: size, elems: elems)
      while true {
        // Compute
        let (elem, _data) = tiling.next-elem(data)
        if elem == none { break }
        data = _data

        // Show
        if display { elem.display }
        elem.debug

        // Record
        data = tiling.push-elem(data, elem)
        for block in elem.blocks {
          maximum-height = calc.max(maximum-height, block.y + block.height)
        }
      }
      placeholder(maximum-height)
    }
  })
}

/// Segment the input sequence according to the tiling algorithm,
/// then thread the flowing text through it.
/// -> content
#let reflow(
  /// See @elem-doc for how to format this content.
  /// -> array(elem)
  seq,
  /// Whether to show the boundaries of boxes.
  /// -> bool
  debug: false,
  /// #property(since: version(0, 2, 1))
  /// Controls the behavior in case the content overflows the provided
  /// containers.
  /// - #typ.v.false $->$ adds a warning box to the document
  /// - #typ.v.true $->$ ignores any overflow
  /// - #typ.pagebreak $->$ the text that overflows is placed on the next page
  /// - #typ.text $->$ the text that overflows is placed on the same page
  /// - #typ.panic $->$ refuses to compile the document
  /// - a @type:state $->$ stores the overflow in the state.
  ///   You can then ```typc _.get()``` it later.
  /// - any function #lambda("overflow", ret:content) $->$ uses that for formatting
  /// -> any
  overflow: false,
  /// #property(since: version(0, 2, 2))
  /// Relationship with the rest of the content on the page.
  /// - #typ.page: content is not visible to the rest of the layout, and will be placed
  ///   at the current location. Supports pagebreaks.
  /// - #typ.box: meander will simulate a box of the same dimensions as its contents
  ///   so that normal text can go before and after. Supports pagebreaks.
  /// - #typ.float: similar to `page` in that it is invisible to the rest of the content,
  ///   but always placed at the top left of the page. Does not support pagebreaks.
  /// -> any
  placement: page,
) = {
  if seq == none { seq = () }
  let (wrapper, placeholder) = tiling.placement-mode(placement)
  wrapper(size => {
    let (flow, pages) = tiling.separate(seq)

    for (idx, elems) in pages.enumerate() {
      let maximum-height = 0pt
      if idx != 0 {
        if placement == float {
          panic("Pagebreaks are only supported when the placement is 'page' or 'box'")
        }
        colbreak()
      }
      let data = tiling.create-data(size: size, elems: elems)
      while true {
        // Compute
        let (elem, _data) = tiling.next-elem(data)
        if elem == none { break }
        data = _data

        if elem.type == place {
          elem.display
          if debug { elem.debug }
          data = tiling.push-elem(data, elem)
          for block in elem.blocks {
            maximum-height = calc.max(maximum-height, block.y + block.height)
          }
          continue
        }
        assert(elem.type == box)
        let (full, overflow) = threading.smart-fill-boxes(
          size: size,
          avoid: data.obstacles,
          boxes: elem.blocks,
          flow,
        )
        flow = overflow
        for (container, content) in full {
          for (key, val) in container.style {
            if key == "align" {
              content = align(val, content)
            } else if key == "text-fill" {
              content = text(fill: val, content)
            } else {
              panic("Container does not support the styling option '" + key + "'")
            }
          }
          // TODO: this needs a new push-elem, but with the actual dimensions not the original ones.
          place(dx: container.x, dy: container.y, {
            box(width: container.width, height: container.height, stroke: if debug { green } else { none }, {
              content
            })
          })
          data = tiling.push-elem(data, (blocks: (tiling.add-self-margin(container),)))
          maximum-height = calc.max(maximum-height, container.y + container.height)
        }
      }
      // This box fills the space occupied by the meander canvas,
      // and thus fills the same vertical space, allowing surrounding text
      // to fit before and after.
      placeholder(maximum-height)
    }
    // Prepare data for the overflow handler
    if flow != () {
      let styled-overflow() = {
        for ct in flow {
          ct.data
        }
      }
      let structured-overflow() = {
        for ct in flow {
          elems.content(..ct.style, ct.data)
        }
      }
      if overflow == false {
        place(top + left)[
          #box(fill: red, stroke: black, inset: 2mm)[
            #align(center)[
              *Warning* \
              This container is insufficient to hold the full text. \
              Consider adding more containers or a `pagebreak`.
            ]
          ]
        ]
      } else if overflow == true {
        // Ignore
      } else if overflow == text {
        styled-overflow()
      } else if overflow == std.pagebreak or overflow == elems.pagebreak {
        colbreak()
        styled-overflow()
      } else if overflow == panic {
        panic("The containers provided cannot hold the remaining text: " + repr(flow))
      } else if type(overflow) == state {
        overflow.update(_ => (
          raw: flow,
          structured: structured-overflow(),
          styled: styled-overflow(),
        ))
      } else if type(overflow) == function {
        overflow((
          raw: flow,
          structured: structured-overflow(),
          styled: styled-overflow(),
        ))
      } else {
        panic("Not a valid value for overflow")
      }
    }
  })
}

