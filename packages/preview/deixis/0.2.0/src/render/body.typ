#import "../core/palette.typ": _deixis-live-palette-output
#import "../core/html.typ": _deixis-html-anchor, _deixis-html-link
#import "../core/references.typ": _deixis-reference-sites
#import "../core/styles.typ": _deixis-edge-stroke, _deixis-normalize-stroke
#import "../core/visibility.typ": _deixis-body-visibility
#import "../core/native.typ": *

// Overlay bodies are evaluated away from their declaration. Preserve the
// declaration's font/paragraph context for both custom and built-in renderers.
#let _deixis-render-context() = (
  text: (size: text.size, font: text.font, weight: text.weight, style: text.style,
    fill: text.fill, lang: text.lang, dir: text.dir),
  par: (leading: par.leading, spacing: par.spacing, justify: par.justify),
)

#let _deixis-inherited-content(data, body) = {
  let inherited = data.at("render-context", default: none)
  if inherited == none { return body }
  set text(..inherited.text)
  set par(..inherited.par)
  body
}

// Native-style footnotes retain their tight superscript spacing. Other
// annotation bodies give the detached marker more room; explicit values win.
#let _deixis-body-marker-gap(data) = data.at("marker-gap", default:
  if data.at("body-type", default: none) == "footnote" { 0.05em } else { 0.25em })

/// A body-style callback that scales inherited text to 0.85em.
/// - it (content): Content to style.
/// -> content
#let _deixis-default-footnote-style(it) = {
  set text(size: 0.85em)
  it
}

/// --------------------
/// Containers
/// --------------------

#let _deixis-default-accent = rgb("496579")

/// Returns the supplied body content without a wrapper.
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
  let edges = _deixis-edge-stroke(stroke)
  if not edges and stroke not in (none, auto) {
    let s-obj = _deixis-normalize-stroke(stroke)
    stroke = _std-stroke(
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
    stroke: if edges { _deixis-normalize-stroke(stroke) } else { (left: stroke) },
    inset: args.at("inset", default: 5pt),
    outset: args.at("outset", default: 0pt),
    body,
  )
}

// Named-only frames use native rect, retaining the same atomic layout as the
// existing rect/alert presets. Explicit native options replace their defaults.
#let _deixis-stripe-container(body, ..args) = rect(
  ..((width: 100%, inset: 5pt, radius: 0pt, fill: _deixis-default-accent.transparentize(94%),
    stroke: (left: 2pt + _deixis-default-accent, rest: none)) + args.named()), body)

#let _deixis-tinted-container(body, ..args) = rect(
  ..((width: 100%, inset: 5pt, radius: 0.2em, stroke: none,
    fill: _deixis-default-accent.transparentize(90%)) + args.named()), body)

#let _deixis-containers = (
  plain: deixis-plain-container,
  rect: deixis-rect-container,
  alert: deixis-alert-container,
  stripe: _deixis-stripe-container,
  tinted: _deixis-tinted-container,
)

/// Resolve container-func names after type/component selection. Keep the
/// named-only presets private; existing names preserve function identity.
#let _deixis-resolve-container(value) = {
  if type(value) != str { return value }
  assert(value in _deixis-containers,
    message: "deixis: Unknown container name " + repr(value)
      + ". Valid names: " + _deixis-containers.keys().join(", ") + ".")
  _deixis-containers.at(value)
}

// Resolve printer overrides too, and keep private style provenance out of the
// callback's native styles. Defaults never replace an explicit none or radius.
#let _deixis-container-data(data) = {
  let container = _deixis-resolve-container(data.at("container-func", default: deixis-plain-container))
  let styles = data.at("styles", default: (:))
  let origins = styles.remove("_deixis-origins", default: (:))
  if container in (_deixis-stripe-container, _deixis-tinted-container) {
    let factory(key) = origins.at(key, default: if key in styles { "local" } else { "factory" }) == "factory"
    let stroke = styles.at("stroke", default: none)
    let paint = if _deixis-edge-stroke(stroke) {
      stroke.values().find(s => s not in (none, auto))
    } else { stroke }
    let paint = if paint in (none, auto) { _deixis-default-accent }
      else { _deixis-normalize-stroke(paint).paint }
    let accent = data.at("accent", default: none)
    if accent == none { accent = paint }
    if accent == auto { accent = _deixis-default-accent }
    // Stripe is a callout: an accent rule over a lighter tint. Tinted keeps
    // only the tint. Native stroke paints can be gradients or tilings too.
    let tint = if type(accent) == gradient { accent.sample(50%) }
      else if type(accent) == color { accent } else { _deixis-default-accent }
    if container == _deixis-stripe-container {
      if factory("stroke") { styles.insert("stroke", (left: 2pt + accent, rest: none)) }
      else if not _deixis-edge-stroke(stroke) { styles.insert("stroke", (left: stroke, rest: none)) }
      if factory("radius") { styles.insert("radius", 0pt) }
      if factory("fill") { styles.insert("fill", tint.transparentize(94%)) }
    } else {
      if factory("stroke") { styles.insert("stroke", none) }
      if factory("fill") { styles.insert("fill", tint.transparentize(90%)) }
    }
  }
  data + (container-func: container, styles: styles)
}

/// --------------------
/// Region Shapes
/// --------------------

/// A rectangular region mark. Use `deixis-region-mark(stroke: none)` for a
/// fill-only highlight.
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

/// An elliptical region mark. Select with `region-shape: deixis-ellipse-region`
/// on `deixis-region-mark`; add `stroke: none` for a fill-only highlight.
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

/// --------------------
/// Render
/// --------------------

#let _deixis-backlink-mark(data) = data.at("backlink-mark-lbl", default: data.at("mark-lbl", default: none))

#let _deixis-should-render-backlinks(data) = {
  if data.at("disable-links", default: false) and not data.at("measure-backlinks", default: false) { return false }
  let b = data.at("backlink", default: false)
  if b == auto { b = false }

  if b in (false, "none", "never") { return false }
  if b in (true, "always") { return true }
  if b == "multiple" {
    let uid = str(data.at("internal-id", default: none))
    let refs = _deixis-reference-sites().at(uid, default: ())
    let mark-count = if _deixis-backlink-mark(data) == none { 0 } else { 1 }
    return mark-count + refs.len() > 1
  }
  return true
}

/// Returns backlink buttons for the original mark, reused marks and references.
/// This is explicit generation: it does not apply the data.backlink policy.
/// Built-in renderers apply that policy before calling it. It emits no body
/// destination or live body span. Live origins require setup and context.
/// Detached measurement suppresses links, and normally the buttons too; internal
/// measure-backlinks requests retain their dimensions without active links.
/// - data (dictionary): Note data.
///
/// -> content
#let deixis-generate-backlinks(
  /// Supplied body-renderer record, including internal-id and original return label.
  /// -> dictionary
  data,
) = {
  let disabled = data.at("disable-links", default: false)
  if disabled and not data.at("measure-backlinks", default: false) { return [] }
  // Measurement needs the hook's dimensions, without active links/identities.
  let linked(dest, body) = if disabled { body } else if type(dest) == label { _deixis-html-link(dest, body) } else { _std-link(dest, body) }
  let base-lbl = _deixis-backlink-mark(data)
  let backlink-hook = emoji.arrow.l.hook

  let internal-id = data.at("internal-id", default: none)
  if internal-id == none { return [] }

  let extra-refs = _deixis-reference-sites(destinations: not disabled).at(str(internal-id), default: ())

  if base-lbl == none and extra-refs.len() == 0 {
    return []
  }

  let links = ()
  let counter = 1
  // HTML has no horizontal spacing primitive; the hook follows the body text.
  let lead = if _std-target() == "html" { none } else { h(0.05em) }

  // mark link
  if base-lbl != none {
    if extra-refs.len() == 0 {
      return [#lead#linked(base-lbl)[#backlink-hook]]
    } else {
      links.push(linked(base-lbl)[#backlink-hook#super(str(counter))])
      counter += 1
    }
  }

  // Additional origins: references and repeated marks, in source order.
  for m in extra-refs {
    if base-lbl == none and extra-refs.len() == 1 {
      links.push(linked(m)[#backlink-hook])
    } else {
      links.push(linked(m)[#backlink-hook#super(str(counter))])
      counter += 1
    }
  }

  [#lead#links.join(" ")]
}

/// Publishes the invisible body destination, without a marker or content span.
/// Emit this OR deixis-generate-body-marker once in live custom output, not both.
/// Measurement records with disable-links suppress destination metadata.
/// - data (dictionary): Note data.
///
/// -> content
#let deixis-generate-body-meta(
  /// Supplied renderer record; preserves public/private body destinations and measurement flags.
  /// -> dictionary
  data,
) = {
  let disable-links = data.at("disable-links", default: false)
  if disable-links { return [] }
  let body-lbl = data.at("body-lbl", default: none)
  if body-lbl == none and data.at("internal-id", default: none) != none {
    body-lbl = _std-label("deixis-body-" + str(data.internal-id))
  }

  let meta = metadata(data)
  let public-id = data.at("id", default: none)
  let c-lbl = if not disable-links and public-id != none {
    if type(public-id) == str { _std-label(public-id) } else { public-id }
  } else { none }

  let ref-meta = if c-lbl != none { [#metadata(meta.value)#c-lbl] } else { none }

  return [#metadata(data)<deixis-body-destination>#meta#body-lbl#ref-meta#_deixis-html-anchor(body-lbl)]
}

/// Formats the body marker and publishes its destination through
/// deixis-generate-body-meta. Marker-less bodies still publish the destination.
/// Use once together with deixis-generate-body-content; do not also emit meta.
/// - data (dictionary): Note data.
///
/// -> content
#let deixis-generate-body-marker(
  /// Supplied renderer record, with marker-str and optional body-marker-style.
  /// -> dictionary
  data,
) = {
  let body-marker-style = data.at("body-marker-style", default: it => super(it))

  let meta = deixis-generate-body-meta(data)
  let body-marker = if data.marker-str == none {
    meta
  } else if data.at("disable-links", default: false) or data.at("mark-lbl", default: none) == none {
    [#meta#body-marker-style(data.marker-str)]
  } else {
    [#meta#_deixis-html-link(data.mark-lbl, body-marker-style(data.marker-str))]
  }
  return body-marker
}

/// Returns the note's body content with live start/end metadata.
///
/// Pair with `deixis-generate-body-marker` or `deixis-generate-body-meta` once in
/// a custom renderer to retain navigation, catalogue spans, page-note queries,
/// and body-point connections. This helper does not add a marker, destination,
/// text styling, or backlinks. It preserves anonymous palette decoration belonging
/// to this annotation. Pass the renderer's data record unchanged, or replace
/// its body field with the content you actually render.
///
/// With `disable-links: true`, returns the body without live metadata, matching
/// the built-in measurement path. Do not render a second copy of the body.
///
/// - data (dictionary): The supplied body-renderer record, including body and internal-id.
///
/// -> content
#let deixis-generate-body-content(
  /// Supplied renderer record, including body and internal-id; preserve measurement flags.
  /// -> dictionary
  data,
) = {
  // Capture only the accent. A rule closing over the whole record would change
  // nested native locations whenever per-pass renderer fields change.
  let accent = data.at("accent", default: none)
  let body = {
    show metadata.where(label: <deixis-palette-output>): it => _deixis-live-palette-output(it, accent: accent)
    data.body
  }
  if data.at("disable-links", default: false) { return body }
  [#metadata(data)<deixis-rendered-start>#body#metadata(data)<deixis-rendered-end>]
}

/// --------------------
/// Render Single
/// --------------------

// HTML export has no page layers or native layout primitives (box, align, h,
// grid). Built-in renderers emit the same live marker, span and backlinks as
// inline text; the body's metadata destinations become HTML anchors.
#let _deixis-html-body-content(data) = {
  let backlinks = if _deixis-should-render-backlinks(data) { deixis-generate-backlinks(data) }
  let backlinks = if backlinks not in (none, []) { super(backlinks) }
  let space = if data.at("marker-str", default: none) not in (none, "") [ ]
  [#deixis-generate-body-marker(data)#space#deixis-generate-body-content(data)#backlinks]
}

#let _deixis-html-render-single(data) = {
  let body-style = data.at("body-style", default: it => it)
  let container = data.at("container-func", default: deixis-plain-container)
  let body = body-style(_deixis-html-body-content(data))
  // Built-in containers only draw frames. Custom containers own their output.
  if container in _deixis-containers.values() { body }
  else { container(body, ..(data.at("styles", default: (:)) + data.at("container-args", default: (:)))) }
}

// The shared native inline run must remain unboxed: decorated inline bodies
// need to wrap in their caller's paragraph and across native pages too.
#let _deixis-native-body-content(data) = {
  if _std-target() == "html" { return _deixis-html-body-content(data) }
  let body-style = data.at("body-style", default: it => it)

  let body-marker = deixis-generate-body-marker(data)

  let active-body = deixis-generate-body-content(data)
  let note-cap-ht = measure(body-style("T")).height

  if _deixis-should-render-backlinks(data) {
    let formatted-backlink = box(height: note-cap-ht, align(top, super(deixis-generate-backlinks(data))))
    active-body = [#active-body#formatted-backlink]
  }

  let formatted-marker = box(height: note-cap-ht, align(top, body-marker))
  let m-indent = data.at("indent", default: 0pt)
  let marker-gap = _deixis-body-marker-gap(data)
  let inner-space = if data.marker-str != none and data.marker-str != "" { h(marker-gap, weak: true) } else { none }

  [#h(m-indent)#formatted-marker#inner-space#active-body]
}

/// A rendering function that formats the note body closely matching Typst's native footnote style.
/// Native weak marker spacing folds source indentation without trimming content.
/// Explicit paragraph/line breaks are preserved; pagination needs a breakable container.
///
/// -> content
#let deixis-native-render-single(data, inner-width: auto, ..args) = {
  let data = _deixis-container-data(data)
  if _std-target() == "html" { return _deixis-html-render-single(data) }
  let body-style = data.at("body-style", default: it => it)
  let container = data.at("container-func", default: deixis-plain-container)
  let final-note = body-style(block(width: inner-width, above: 0pt, below: 0pt, {
    set par(leading: 0.65em)
    _deixis-native-body-content(data)
  }))
  container(final-note, ..(data.at("styles", default: (:)) + data.at("container-args", default: (:))))
}

/// The default rendering function, formatting the note body with the marker aligned to the side.
/// Weak marker spacing folds indentation through native layout; authored breaks survive.
///
/// -> content
#let deixis-aligned-render-single(
  data,
  inner-width: auto,
  max-marker-width: auto,
  max-marker-gap: auto,
  ..args,
) = {
  let data = _deixis-container-data(data)
  if _std-target() == "html" { return _deixis-html-render-single(data) }
  let body-style = data.at("body-style", default: it => it)

  let indent = data.at("indent", default: 0pt)
  let marker-gap = _deixis-body-marker-gap(data)

  let body-marker = deixis-generate-body-marker(data)

  let note-cap-ht = measure(body-style("T")).height

  let body-marker-style = data.at("body-marker-style", default: it => super(it))
  let raw-marker = if data.marker-str == none { [] } else { body-marker-style(data.marker-str) }
  let l-w = if max-marker-width != auto { max-marker-width } else {
    measure(body-style([#h(indent)#raw-marker])).width
  }
  let formatted-marker = box(width: l-w, height: note-cap-ht, align(bottom + right, body-marker))

  let g-w = if max-marker-gap != auto { max-marker-gap } else {
    if data.marker-str != none and data.marker-str != "" { measure(body-style([#h(marker-gap)])).width } else { 0pt }
  }

  let content = deixis-generate-body-content(data)
  let final-body = if g-w > 0pt or data.marker-str not in (none, "") {
    [#h(g-w, weak: true)#content]
  } else { content }

  if _deixis-should-render-backlinks(data) {
    let formatted-backlink = box(height: note-cap-ht, align(top, super(deixis-generate-backlinks(data))))
    final-body = [#final-body#formatted-backlink]
  }

  let container = data.at("container-func", default: deixis-plain-container)

  let final-note = body-style(block(width: inner-width, above: 0pt, below: 0pt, {
    set par(leading: 0.65em)
    [#formatted-marker#final-body]
  }))

  container(final-note, ..(data.at("styles", default: (:)) + data.at("container-args", default: (:))))
}

#let _deixis-render-single(data, renderer: auto, ..args) = {
  let data = _deixis-container-data(data)
  let data = if data.at("disable-links", default: false) { data + (measure-backlinks: true) } else { data }
  let renderer = if renderer == auto { data.at("render-single", default: deixis-native-render-single) } else { renderer }
  let inherited = data.at("render-context", default: none)
  let render() = {
    if inherited == none { return renderer(data, ..args.named()) }
    set text(..inherited.text)
    set par(..inherited.par)
    context renderer(data, ..args.named())
  }
  if data.at("disable-links", default: false) {
    // Match before deferred geometry runs. Preserve the native zero box/place
    // footprint, including place's paragraph break, but omit painter queries.
    show metadata.where(label: <deixis-inline-mark-output>): it => (it.value)(true)
    show box.where(label: <deixis-immediate-region>): _ => box(width: 0pt, height: 0pt)
    show place.where(label: <deixis-immediate-region>): _ => place([])
    render()
  } else {
    _deixis-body-visibility(data)
    render()
  }
}

/// --------------------
/// Render Group
/// --------------------

// Preserve first-seen series order without repeatedly filtering the full list.
#let _deixis-series-groups(notes-data) = {
  let groups = (:)
  for data in notes-data {
    let series = data.at("series", default: "default")
    if series not in groups { groups.insert(series, ()) }
    groups.at(series).push(data)
  }
  groups.values()
}

// One HTML list per group. Each item keeps its note's renderer unless a
// group renderer, like the grid, formats bodies itself.
#let _deixis-html-render-group(notes-data, renderer: auto) = html.elem("ol",
  attrs: (class: "deixis-notes", style: "list-style-type: none"),
  for data in notes-data {
    html.elem("li", _deixis-render-single(data, renderer: if renderer == auto {
      data.at("render-single", default: deixis-native-render-single)
    } else { renderer }))
  })

#let _deixis-note-length(data, value) = measure(_deixis-inherited-content(data, box(width: value))).width

/// Render a group of notes by vertical stacking, similar to Typst's native footnote stacking.
///
/// -> content
#let deixis-native-render-group(notes-data, gap: auto, ..args) = {
  if _std-target() == "html" { return _deixis-html-render-group(notes-data) }
  for (i, data) in notes-data.enumerate() {
    let local-gap = data.at("gap", default: 0.5em)
    let active-single = data.at("render-single", default: deixis-native-render-single)

    v(if gap == auto { _deixis-note-length(data, local-gap) } else { gap }, weak: true)

    _deixis-render-single(data, renderer: active-single)
  }
}

/// Render a group of notes by vertical stacking while aligning body markers.
/// Should be used in combination with ```ref #deixis-aligned-render-single```.
///
/// -> content
#let deixis-aligned-render-group(notes-data, gap: auto, ..args) = {
  if _std-target() == "html" { return _deixis-html-render-group(notes-data) }
  let max-marker-width = 0pt
  let max-marker-gap = 0pt

  for data in notes-data {
    let body-marker-style = data.at("body-marker-style", default: it => super(it))
    let body-style = data.at("body-style", default: it => it)

    let indent = data.at("indent", default: 0pt)
    let marker-gap = _deixis-body-marker-gap(data)

    let w = measure(_deixis-inherited-content(data, context {
      let body-marker = if data.marker-str == none { [] } else { body-marker-style(data.marker-str) }
      body-style([#h(indent)#body-marker])
    })).width
    if w > max-marker-width { max-marker-width = w }

    let g-width = if data.marker-str != none and data.marker-str != "" {
      measure(_deixis-inherited-content(data, context body-style(h(marker-gap)))).width
    } else { 0pt }
    if g-width > max-marker-gap { max-marker-gap = g-width }
  }

  for (i, data) in notes-data.enumerate() {
    let local-gap = data.at("gap", default: 0.5em)
    let active-single = data.at("render-single", default: deixis-aligned-render-single)

    v(if gap == auto { _deixis-note-length(data, local-gap) } else { gap }, weak: true)

    _deixis-render-single(data, renderer: active-single,
      max-marker-width: max-marker-width, max-marker-gap: max-marker-gap)
  }
}

/// Render a group of notes by putting them into a `grid` layout.
///
/// ```info
/// Factory single renderers use aligned marker/body cells. A group containing
/// a custom single renderer delegates to native stacking, preserving each
/// note's renderer, container and gap.
/// ```
///
/// -> content
#let deixis-grid-render-group(notes-data, gap: auto, ..args) = {
  if notes-data.len() == 0 { return [] }
  // The grid owns marker/body cells only for the factory aligned renderer.
  // Custom singles own their complete layout; keep mixed groups in source order.
  if notes-data.any(data => data.at("render-single", default: deixis-aligned-render-single) != deixis-aligned-render-single) {
    return deixis-native-render-group(notes-data, gap: gap, ..args.named())
  }
  if _std-target() == "html" { return _deixis-html-render-group(notes-data, renderer: _deixis-html-render-single) }
  let gap = if gap == auto {
    let gaps = notes-data.slice(1).map(data => _deixis-note-length(data, data.at("gap", default: 0.5em)))
    if gaps.len() == 0 { 0pt } else { gaps }
  } else { gap }

  let max-gap-w = 0pt
  for data in notes-data {
    let body-style = data.at("body-style", default: it => it)
    let marker-gap = data.at("marker-gap", default: 0.75em)
    let g-width = if data.marker-str != none and data.marker-str != "" {
      measure(_deixis-inherited-content(data, context body-style(h(marker-gap)))).width
    } else { 0pt }
    if g-width > max-gap-w { max-gap-w = g-width }
  }

  let grid-cells = ()
  for data in notes-data {
    grid-cells.push(_deixis-inherited-content(data, context {
      let body-style = data.at("body-style", default: it => it)
      let m-indent = data.at("indent", default: 0pt)
      let note-cap-ht = measure(body-style("T")).height
      let body-marker = deixis-generate-body-marker(data)
      let formatted-marker = box(height: note-cap-ht, align(top + right, body-marker))
      body-style([#h(m-indent)#formatted-marker])
    }))
    grid-cells.push(_deixis-inherited-content(data, context {
      let body-style = data.at("body-style", default: it => it)
      let note-cap-ht = measure(body-style("T")).height
      let backlink-content = if _deixis-should-render-backlinks(data) {
        box(height: note-cap-ht, align(top, super(deixis-generate-backlinks(data))))
      } else { none }
      body-style([#deixis-generate-body-content(data)#backlink-content])
    }))
  }

  grid(
    columns: (auto, 1fr),
    column-gutter: max-gap-w,
    row-gutter: gap,
    ..grid-cells,
  )
}
