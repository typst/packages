// ============ ALGOL INTERNALS ============ //

#let _algol-line-nb = counter("_algol-line-nb")
#let _algol-depth = counter("_algol-depth")
#let _algol-numbering-enabled = state("_algol-numbering-enabled", true)

#let _algol-list-marker(
  line-numbering, line-number-fmt, indent-length, line-number-spacing
) = _algol-line-nb.step() + context {
    if line-numbering == none { return }
    if not _algol-numbering-enabled.get() {
      _algol-numbering-enabled.update(true)
      _algol-line-nb.update(n => n - 1)
      return
    }
    let depth = _algol-depth.get().at(0)
    place(left, dx: -indent-length * (depth - 1) - line-number-spacing,
      line-number-fmt(_algol-line-nb.display(line-numbering))
    )
  }
}

#let _algol-list(
  it, guide-stroke, hook-length, line-spacing, block-bottom-spacing,
  guide-left-offset, guide-top-offset, guide-bottom-offset
) = context {
  _algol-depth.step()
  
  let outset = (left: -guide-left-offset, top: guide-top-offset, bottom: guide-bottom-offset)
  let inset = (bottom: block-bottom-spacing)
  
  let stroke = if _algol-depth.get().at(0) > 0 { guide-stroke } else { 0pt }
  
  block(stroke: (left: stroke), spacing: line-spacing, outset: outset, inset: inset, {
    it
    place(line(length: hook-length, stroke: stroke), dx: -outset.left,
      dy: inset.bottom + outset.bottom - guide-stroke.thickness/2
    )
  })

  _algol-depth.update(n => n - 1)
}

// ============ ALGOL INTERFACE ============ //

#let no-next-line-nb = context _algol-numbering-enabled.update(false)

#let enable-line-refs(body,
  line-numbering: "1",
  line-supplement: [line],
  label-pattern: regex("^line:.*"),
) = {
  show ref: it => {
    let lb = it.target
    // if the label matches the pattern -> algol line reference
    if str(lb).match(label-pattern) != none {
      let line-nb = _algol-line-nb.at(lb).first()
      let line-nb-fmt = link(lb, numbering(line-numbering, line-nb))
      // if the supplement is empty content
      if line-supplement == [] [#line-nb]
      // else, if a nonempty supplement is provided
      else [#line-supplement~#line-nb]
    }
    // else -> other type of reference
    else { it }
  }

  body
}

#let algol(body,
  // box parameters
  box-stroke: .5pt + black,
  box-inset: .4em,
  // line parameters
  indent-length: 1.5em,
  line-spacing: .6em,
  // line number parameters
  line-numbering: "1",
  line-number-fmt: n-str => box(width: .8em, baseline: .65em,
    align(horizon + right, text(size: .8em)[*#n-str*])
  ),
  line-number-spacing: 1.5em,
  // guides parameters
  guide-stroke: .5pt + black,
  hook-length: .4em,
  guide-left-offset: .5em,
  guide-top-offset: .4em,
  finished-guide-bottom-offset: .1em,
  unfinished-guide-bottom-offset: .4em,
  finished-block-bottom-spacing: .3em,
) = context block(box(inset: box-inset, stroke: box-stroke, {
  
  set align(left)
  _algol-line-nb.update(0)
  _algol-depth.update(0)

  // ==== PARAGRAPH SETTINGS ==== //

  set par(justify: true, leading: line-spacing, spacing: 1.2em)
  
  // ==== BULLET LIST RULES (FINISHED BLOCKS) ==== //
  
  set list(indent: indent-length, body-indent: 0pt, marker: _algol-list-marker(
    line-numbering, line-number-fmt, indent-length, line-number-spacing
  ))
  show list: it => _algol-list(
    it, guide-stroke, hook-length, line-spacing, finished-block-bottom-spacing,
    guide-left-offset, guide-top-offset, finished-guide-bottom-offset
  )

  // ==== ENUM LIST RULES (UNFINISHED BLOCKS) ==== //
  
  set enum(indent: indent-length, body-indent: 0pt,
    numbering: it => _algol-list-marker(
      line-numbering, line-number-fmt, indent-length, line-number-spacing
    )
  )
  show enum: it => _algol-list(
    it, guide-stroke, 0pt, line-spacing, 0pt,
    guide-left-offset, guide-top-offset, unfinished-guide-bottom-offset
  )

  // ==== BODY ==== //

  body
}))
