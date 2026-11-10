#import "tiling.typ"
#import "threading.typ"
#import "elems.typ"
#import "opt.typ"

/// Deprecated in favor of @cmd:meander:reflow with ```typc opt.debug.pre-thread()```.
/// #property(until: version(0, 2, 4))
#let regions(..args) = {
  panic("`regions` is deprecated. Use instead `meander.reflow` and set `opt.debug.pre-thread()`")
}

/// Segment the input sequence according to the tiling algorithm,
/// then thread the flowing text through it.
/// -> content
#let reflow(
  /// See @elem-doc for how to format this content.
  /// -> array(elem)
  seq,
  /// Deprecated in favor of ```typc opt.debug.post-thread()```.
  /// See @anatomy and @debug for more information.
  /// #property(until: version(0, 2, 4))
  debug: none,
  /// #property(since: version(0, 2, 1))
  /// Deprecated in favor of ```typc opt.overflow``` options.
  /// #property(until: version(0, 2, 5))
  overflow: none,
  /// #property(since: version(0, 2, 2))
  /// Deprecated in favor of ```typc opt.placement``` options.
  /// #property(until: version(0, 2, 5))
  placement: none,
) = {
  if debug != none {
    panic("Option `debug` was removed. Use instead `opt.debug.post-thread()`")
  }
  if placement != none {
    panic("Option `placement` was removed. Use instead `opt.placement.{cfg}()`")
  }
  if overflow != none {
    panic("Option `overflow` was removed. Use instead `opt.overflow.{cfg}()`")
  }
  if seq == none { seq = () }
  assert(type(seq) == array, message: "Cannot interpret this object as a layout.")
  let (flow, pages, opts) = tiling.separate(seq)
  let wrapper = tiling.placement-mode(opts)

  let fill-page(elems, flow, size: (), page-offset: (x: 0pt, y: 0pt)) = {
    let output = []
    let maximum-height = 0pt
    let data = tiling.create-data(size: size, elems: elems, page-offset: page-offset)
    while true {
      // Compute
      let (elem, _data) = tiling.next-elem(data)
      if elem == none { break }
      data = _data

      if elem.type == place {
        if opts.debug.objects { output += elem.display }
        //output += elem.display
        //if debug { output += elem.debug }
        data = tiling.push-elem(data, elem)
        for block in elem.contour {
          output += place(dx: block.x, dy: block.y, {
            box(width: block.width, height: block.height, ..opts.debug.obstacle-contours)
          })
          //maximum-height = calc.max(maximum-height, block.y + block.height)
          maximum-height = calc.max(maximum-height, block.y + block.height)
        }
        continue
      }
      assert(elem.type == box)
      if opts.debug.content {
        let (full, overflow) = threading.smart-fill-boxes(
          size: size,
          avoid: data.obstacles,
          boxes: elem.contour,
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
          output += place(dx: container.x, dy: container.y, {
            box(width: container.width, height: container.height, ..opts.debug.container-contours, {
              content
            })
          })
          data = tiling.push-elem(data, (contour: (tiling.add-self-margin(container),)))
          maximum-height = calc.max(maximum-height, container.y + container.height)
        }
      } else {
        for container in elem.contour {
          output += place(dx: container.x, dy: container.y, {
            box(width: container.width, height: container.height, ..opts.debug.container-contours, {})
          })
          data = tiling.push-elem(data, (contour: (tiling.add-self-margin(container),)))
          maximum-height = calc.max(maximum-height, container.y + container.height)
        }
      }
    }
    // This box fills the space occupied by the meander canvas,
    // and thus fills the same vertical space, allowing surrounding text
    // to fit before and after.
    let virtual-space = if opts.virtual-spacing {
      let height = calc.min(maximum-height, size.height - page-offset.y)
      block(width: 100%, height: height)
    }
    (content: output, overflow: flow, vspace: virtual-space)
  }

  wrapper(size => {
    let first-page-offset = tiling.get-page-offset()
    let flow = flow

    for (idx, elems) in pages.enumerate() {
      let page-offset = if idx == 0 {
        first-page-offset
      } else {
        (x: 0pt, y: 0pt)
      }
      //assert(page-offset.x + page-offset.y == 0pt, message: repr(page-offset) + " at page " + str(idx))
      if idx != 0 {
        if placement == float {
          panic("Pagebreaks are only supported when the placement is 'page' or 'box'")
        }
        colbreak()
      }
      let (content, overflow, vspace) = fill-page(elems, flow, size: size, page-offset: page-offset)
      content
      vspace
      flow = overflow
    }
    // Prepare data for the overflow handler
    if opts.debug.content and flow != () {
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
      if "fun" in opts.overflow {
        (opts.overflow.fun)((
          raw: flow,
          structured: structured-overflow(),
          styled: styled-overflow(),
        ))
      } else if "repeat" in opts.overflow {
        let (count,) = opts.overflow.repeat
        let last-pages-elems = pages.slice(-count)
        let num = 1
        while flow != () {
          colbreak()
          // TODO: make sure this is synchronized with above
          let (content, overflow, vspace) = fill-page(last-pages-elems.at(calc.rem(num - 1, count)), flow, size: size)
          content
          vspace
          flow = overflow
          num += 1
        }
      } else if "alert" in opts.overflow {
        place(top + left)[
          #box(fill: red, stroke: black, inset: 2mm)[
            #align(center)[
              *Warning* \
              This container is insufficient to hold the full text. \
              Consider adding more containers or a `pagebreak`.
            ]
          ]
        ]
      } else if "state" in opts.overflow {
        opts.overflow.state.update(_ => (
          raw: flow,
          structured: structured-overflow(),
          styled: styled-overflow(),
        ))
      } else {
        panic(opts.overflow)
      }
    }
  })
}

