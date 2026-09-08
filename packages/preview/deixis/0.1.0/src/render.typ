#import "states.typ": deixis-system

// A default style that resembles that of native `std.footnote`.
#let deixis-default-footnote-style(it) = {
  set text(size: 0.85em)
  it
}

/// --------------------
/// Containers
/// --------------------

/// A simple container that renders the note body as a plain block.
/// - body (content): The rendered note content.
/// - ..args (arguments): Ignored formatting arguments.
///
/// -> content
#let deixis-plain-container(body, ..args) = body

/// An alias of the standard Typst `#std.rect`.
/// - body (content): The rendered note content.
/// - ..args (arguments): Forwarded to `rect`.
#let deixis-rect-container = rect

/// A simple alert (admonition) container.
/// - body (content): The rendered note content.
/// - ..args (arguments): Formatting arguments.
///
/// -> content
#let deixis-alert-container(body, ..args) = {
  let stroke = args.at("stroke", default: none)
  if stroke != none {
    let s-obj = std.stroke(stroke)
    stroke = std.stroke(
      cap: s-obj.cap,
      dash: s-obj.dash,
      join: s-obj.join,
      miter-limit: s-obj.miter-limit,
      paint: s-obj.paint,
      thickness: 2 * s-obj.thickness,
    )
  }
  rect(
    width: 100%,
    fill: args.at("fill", default: none),
    stroke: (left: stroke),
    inset: args.at("inset", default: 5pt),
    outset: args.at("outset", default: 0pt),
    body,
  )
}

/// --------------------
/// Region Shapes
/// --------------------

/// A rectangular region mark.
///
/// -> content
#let deixis-rect-region(..args) = {
  rect(
    width: args.at("width"),
    height: args.at("height"),
    fill: args.at("fill", default: none),
    stroke: args.at("stroke", default: none),
    radius: args.at("radius", default: 0pt),
  )
}

/// A rectangular region mark without stroke.
///
/// -> content
#let deixis-highlight-rect-region(..args) = {
  rect(
    width: args.at("width"),
    height: args.at("height"),
    fill: args.at("fill", default: none),
    radius: args.at("radius", default: 0pt),
  )
}

/// An elliptical region mark.
///
/// -> content
#let deixis-ellipse-region(..args) = {
  ellipse(
    width: args.at("width"),
    height: args.at("height"),
    fill: args.at("fill", default: none),
    stroke: args.at("stroke", default: none),
  )
}

/// An elliptical region mark without stroke.
///
/// -> content
#let deixis-highlight-ellipse-region(..args) = {
  ellipse(
    width: args.at("width"),
    height: args.at("height"),
    fill: args.at("fill", default: none),
  )
}

/// --------------------
/// Render
/// --------------------

#let _deixis-should-render-backlinks(data) = {
  let b = data.at("backlink", default: false)
  if b == auto { b = false }

  if b in (false, "none", "never") { return false }
  if b in (true, "always") { return true }
  if b == "multiple" {
    if data.at("mark-lbl", default: none) == none { return false }

    let label = data.at("label", default: none)
    if label == none { return false }

    return query(<deixis-ref-marker>).filter(m => m.value.target == str(label)).len() > 0
  }
  return true
}

/// Returns the backlink buttons linking to the mark and anywhere the body is referenced.
/// - data (dictionary): Note data.
///
/// -> content
#let deixis-generate-backlinks(data) = {
  let base-lbl = data.at("mark-lbl", default: none)
  let backlink-hook = emoji.arrow.l.hook

  let internal-id = data.at("internal-id", default: none)
  if internal-id == none { return [] }

  let aliases = ()
  if data.at("body-lbl", default: none) != none { aliases.push(str(data.body-lbl)) }
  if data.at("mark-lbl", default: none) != none { aliases.push(str(data.mark-lbl)) }
  if data.at("label", default: none) != none { aliases.push(str(data.label)) }

  let sys = deixis-system.final()
  let id-idx = sys.at("id-index", default: (:))
  let lbl-idx = sys.at("label-index", default: (:))

  let is-celibate = str(internal-id).starts-with("celibate-")

  if not is-celibate {
    for (k, v) in id-idx {
      if str(v) == str(internal-id) { aliases.push(k) }
    }
    for (k, v) in lbl-idx {
      if str(v) == str(internal-id) { aliases.push(k) }
    }
  }

  let extra-refs = query(<deixis-ref-marker>).filter(m => m.value.target in aliases)

  if base-lbl == none and extra-refs.len() == 0 {
    return []
  }

  let links = ()
  let counter = 1

  // mark link
  if base-lbl != none {
    if extra-refs.len() == 0 {
      return [#h(0.05em)#std.link(base-lbl)[#backlink-hook]]
    } else {
      links.push(std.link(base-lbl)[#backlink-hook#super(str(counter))])
      counter += 1
    }
  }

  // reference links
  for m in extra-refs {
    if base-lbl == none and extra-refs.len() == 1 {
      links.push(std.link(m.location())[#backlink-hook])
    } else {
      links.push(std.link(m.location())[#backlink-hook#super(str(counter))])
      counter += 1
    }
  }

  [#h(0.05em)#links.join(" ")]
}

/// Returns the invisible metadata allowing other components to link to the note body, usually put before the body marker.
/// - data (dictionary): Note data.
///
/// -> content
#let deixis-generate-body-meta(data) = {
  let disable-links = data.at("disable-links", default: false)
  let body-lbl = if not disable-links { data.at("body-lbl", default: none) } else { none }

  let meta = metadata(data)
  let custom-lbl = data.at("label", default: none)
  let c-lbl = if not disable-links and custom-lbl != none {
    if type(custom-lbl) == str { std.label(custom-lbl) } else { custom-lbl }
  } else { none }

  let ref-meta = if c-lbl != none { [#metadata(meta.value)#c-lbl] } else { none }

  return [#meta#body-lbl#ref-meta]
}

/// Returns the visual marker for the note body, attaching metadata from ```ref #deixis-generate-body-meta```.
/// - data (dictionary): Note data.
///
/// -> content
#let deixis-generate-body-marker(data) = {
  let body-marker-style = data.at("body-marker-style", default: it => super(it))

  let meta = deixis-generate-body-meta(data)
  let body-marker = if data.marker-str == none {
    meta
  } else if data.at("mark-lbl", default: none) == none {
    [#meta#body-marker-style(data.marker-str)]
  } else {
    [#meta#std.link(data.mark-lbl, body-marker-style(data.marker-str))]
  }
  return body-marker
}

/// --------------------
/// Render Single
/// --------------------

/// A rendering function that formats the note body closely matching Typst's native footnote style.
///
/// -> content
#let deixis-native-render-single(data, inner-width: auto, ..args) = {
  let body-style = data.at("body-style", default: it => it)

  let body-marker = deixis-generate-body-marker(data)

  let active-body = data.body
  let note-cap-ht = measure(body-style("T")).height

  if _deixis-should-render-backlinks(data) {
    let formatted-backlink = box(height: note-cap-ht, align(top, super(deixis-generate-backlinks(data))))
    active-body = [#active-body#formatted-backlink]
  }

  let formatted-marker = box(height: note-cap-ht, align(top, body-marker))
  let container = data.at("container-func", default: deixis-plain-container)

  let m-indent = data.at("indent", default: 0pt)
  let marker-gap = data.at("marker-gap", default: 0.05em)
  let inner-space = if data.marker-str != none and data.marker-str != "" { h(marker-gap) } else { none }

  let final-note = body-style(block(width: inner-width, above: 0pt, below: 0pt, {
    set par(leading: 0.65em)
    [#h(m-indent)#formatted-marker#inner-space#active-body]
  }))

  container(final-note, ..data.at("styles", default: (:)))
}

/// The default rendering function, formatting the note body with the marker aligned to the side.
///
/// -> content
#let deixis-default-render-single(
  data,
  inner-width: auto,
  max-marker-width: auto,
  max-marker-gap: auto,
  ..args,
) = {
  let body-style = data.at("body-style", default: it => it)

  let indent = data.at("indent", default: 0pt)
  let marker-gap = data.at("marker-gap", default: 0.05em)

  let body-marker = deixis-generate-body-marker(data)

  let note-cap-ht = measure(body-style("T")).height

  let l-w = if max-marker-width != auto { max-marker-width } else {
    measure(body-style([#h(indent)#body-marker])).width
  }
  let formatted-marker = box(width: l-w, height: note-cap-ht, align(bottom + right, body-marker))

  let g-w = if max-marker-gap != auto { max-marker-gap } else {
    if data.marker-str != none and data.marker-str != "" { measure(body-style([#h(marker-gap)])).width } else { 0pt }
  }

  let final-body = if g-w > 0pt { [#h(g-w)#data.body] } else { data.body }

  if _deixis-should-render-backlinks(data) {
    let formatted-backlink = box(height: note-cap-ht, align(top, super(deixis-generate-backlinks(data))))
    final-body = [#final-body#formatted-backlink]
  }

  let container = data.at("container-func", default: deixis-plain-container)

  let final-note = body-style(block(width: inner-width, above: 0pt, below: 0pt, {
    set par(leading: 0.65em)
    [#formatted-marker#final-body]
  }))

  container(final-note, ..data.at("styles", default: (:)))
}

/// --------------------
/// Render Group
/// --------------------

/// Render a group of notes by vertical stacking, similar to Typst's native footnote stacking.
///
/// -> content
#let deixis-native-render-group(notes-data, gap: auto, ..args) = {
  for (i, data) in notes-data.enumerate() {
    let local-gap = data.at("gap", default: 0.5em)
    let active-single = data.at("render-single", default: deixis-native-render-single)

    v(if gap == auto { local-gap } else { gap }, weak: true)

    active-single(data)
  }
}

/// Render a group of notes by vertical stacking while aligning body markers.
/// Should be used in combination with ```ref #deixis-default-render-single```.
///
/// -> content
#let deixis-default-render-group(notes-data, gap: auto, ..args) = {
  let max-marker-width = 0pt
  let max-marker-gap = 0pt

  for data in notes-data {
    let body-marker-style = data.at("body-marker-style", default: it => super(it))
    let body-style = data.at("body-style", default: it => it)

    let indent = data.at("indent", default: 0pt)
    let marker-gap = data.at("marker-gap", default: 0.05em)

    let body-marker = if data.marker-str == none {
      []
    } else {
      [#body-marker-style(data.marker-str)]
    }

    let w = measure(body-style([#h(indent)#body-marker])).width
    if w > max-marker-width { max-marker-width = w }

    let g-width = if data.marker-str != none and data.marker-str != "" {
      measure(body-style([#h(marker-gap)])).width
    } else { 0pt }
    if g-width > max-marker-gap { max-marker-gap = g-width }
  }

  for (i, data) in notes-data.enumerate() {
    let local-gap = data.at("gap", default: 0.5em)
    let active-single = data.at("render-single", default: deixis-default-render-single)

    v(if gap == auto { local-gap } else { gap }, weak: true)

    active-single(data, max-marker-width: max-marker-width, max-marker-gap: max-marker-gap)
  }
}

/// Render a group of notes by putting them into a `grid` layout.
///
/// ```info
/// Unlike other group renderers, this function does not forward call to individual `render-single` of each note.
/// ```
///
/// -> content
#let deixis-grid-render-group(notes-data, gap: auto, ..args) = {
  let gap = if gap == auto { notes-data.first().at("gap", default: 0.5em) } else { gap }

  let max-gap-w = 0pt
  for data in notes-data {
    let body-style = data.at("body-style", default: it => it)
    let marker-gap = data.at("marker-gap", default: 0.75em)

    let g-width = if data.marker-str != none and data.marker-str != "" {
      measure(body-style([#h(marker-gap)])).width
    } else { 0pt }

    if g-width > max-gap-w { max-gap-w = g-width }
  }

  let grid-cells = ()

  for data in notes-data {
    let mark-marker-style = data.at("mark-marker-style", default: it => super(it))
    let body-style = data.at("body-style", default: it => it)

    let m-indent = data.at("indent", default: 0pt)

    let body-marker = deixis-generate-body-marker(data)

    let note-cap-ht = measure(body-style("T")).height

    let backlink-content = if _deixis-should-render-backlinks(data) {
      let raw-bl = mark-marker-style(super(deixis-generate-backlinks(data)))
      box(height: note-cap-ht, align(top, raw-bl))
    } else { none }

    let formatted-marker = box(height: note-cap-ht, align(top + right, body-marker))

    grid-cells.push(
      body-style([#h(m-indent)#formatted-marker]),
    )

    grid-cells.push(
      body-style([#data.body#backlink-content]),
    )
  }

  grid(
    columns: (auto, 1fr),
    column-gutter: max-gap-w,
    row-gutter: gap,
    ..grid-cells
  )
}
