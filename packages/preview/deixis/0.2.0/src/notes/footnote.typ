#import "../core/internal.typ": *
#import "../render/commands.typ": _deixis-paint-command
#import "../marks/inline.typ": *
#import "../marks/region.typ": *
#import "../core/native.typ": *

// Native layout owns pagination. Overlays reserve numeric geometry and emit no
// second live copy of a body, so nested notes/labels are registered only once.
#let _deixis-footnote-layer(sys, local, target-id) = {
  // Validate the request even when the scope selects collected native flow.
  let requested = _deixis-resolve-typed-param(sys, local, "layer", "footnote", component: "body")
  if target-id != "page" { return "flow" }
  // Native flow is the page default. The setup option restores the overlay
  // default for unspecified layers; explicit deixis-set layers still apply.
  let resolved = _deixis-resolve-typed-param(sys, local, "layer", "footnote", component: "body", with-origin: true)
  if resolved.origin in ("factory", "fallback") and sys.at("override-page-footnotes", default: false) { return "foreground" }
  requested
}

#let _deixis-visible-page-footnote-entry(data) = {
  let overlay = data.layer != "flow"
  // Like std.footnote entries, page bodies use the native footer typography,
  // not the declaration's (a note in a heading must not become a bold heading).
  // Render inside the entry, where only page-level styles apply. Overlays carry
  // that captured context to the painter, so paint matches the reservation.
  // The native footer already sets footnote-size text; the default footnote
  // style would scale it a second time. Custom body styles still apply.
  let footer-style(n) = if n.body-style == _deixis-default-footnote-style { n + (body-style: it => it) } else { n }
  let entry = block(width: 100%, above: 0pt, below: 0pt, spacing: 0pt, _deixis-visible-root(context {
    // HTML export has no page layers: overlay bodies print like flow bodies
    // in the native footnote section.
    let overlay = overlay and _std-target() != "html"
    let data = footer-style(data) + (render-context: _deixis-render-context())
    let rendered = if overlay and data.render-single == deixis-aligned-render-single and data.render-group == deixis-aligned-render-group {
      // Reserve with a shared marker column. Measuring each short marker alone
      // underestimates wrapping when the overlay later aligns it with a long one.
      // A document-wide maximum is conservative and independent of pagination.
      let peers = query(<deixis-footnote>).map(n => n.value).filter(n => (
        n.target-id == "page" and n.series == data.series and n.layer == data.layer and not _deixis-is-hidden(n)
      )).map(footer-style) + (data,)
      let marker-width = calc.max(..peers.map(n => {
        measure({
          let marker = if n.marker-str == none { [] } else { (n.body-marker-style)(n.marker-str) }
          (n.body-style)([#h(n.indent)#marker])
        }).width
      }))
      let marker-gap = calc.max(..peers.map(n => {
        if n.marker-str in (none, "") { 0pt } else { measure((n.body-style)(h(n.marker-gap))).width }
      }))
      _deixis-render-single(data + (disable-links: true), gap: data.gap,
        max-marker-width: marker-width, max-marker-gap: marker-gap)
    } else {
      _deixis-render-single(data + (disable-links: overlay), gap: data.gap)
    }
    // Native allocation evidence must not depend on a user body renderer
    // retaining our live-span hooks. Metadata adds no inline box or paragraph.
    [#metadata(data.internal-id)<deixis-footnote-entry>]
    if overlay {
      layout(size => {
        let height = measure(block(width: size.width, rendered)).height
        let margins = deixis-utils.get-page-margins(here().page())
        if type(page.height) == length and height > page.height - margins.top - margins.bottom {
          panic("deixis: This overlay footnote is taller than a page. Use layer: \"flow\" for native pagination.")
        }
        // An explicit zero baseline makes native layout account for the entire
        // phantom height, including content that would descend below the marker.
        box(width: 100%, height: height, baseline: 0pt, {
          place(top + left, [#metadata(data + (reserved-height: height, reserved-width: size.width))<deixis-reserver-left>])
          place(top + right, [#metadata(data)<deixis-reserver-right>])
        })
      })
    } else { rendered }
  }))
  // Native separator, clearance, gap and indent are page-level `footnote.entry`
  // settings; a local set rule here would be ignored. Setup renders labelled
  // entries without the native indent/number prefix, so the entry cannot leave
  // a prefix fragment and separator behind on the marker's page.
  let restore-counter = counter(_std-footnote).update(n => n - 1)
  // Overlay declarations must not create an empty paragraph. Native layout can
  // drop an empty marker at a paragraph boundary; setup diagnoses missing slots
  // rather than silently omitting the body. A zero-size inline box retains flow
  // allocation at trailing boundaries without collapsing neighboring spaces.
  show _std-footnote: it => if overlay or _std-target() == "html" { [] } else { box(width: 0pt, height: 0pt, baseline: 0pt) }
  [#_std-footnote(entry, numbering: _ => none)<deixis-native-footnote>]
  restore-counter
}

#let _deixis-page-footnote-entry(data) = _deixis-visibility-probe(hidden => {
  if not hidden and not _deixis-is-hidden(data) { _deixis-visible-page-footnote-entry(data) }
})

// Check native allocation in both paths. Empty overlay markers can disappear at
// boundaries; parent-scope floats drop even ordinary native/flow entries.
#let _deixis-validate-page-footnotes() = {
  let reserved = (:)
  for probe in query(<deixis-footnote-entry>) {
    reserved.insert(str(probe.value), true)
  }
  for note in query(<deixis-footnote>) {
    let data = note.value
    if data.target-id == "page" and not _deixis-is-hidden(data) {
      let advice = "Native Typst does not allocate page footnotes inside parent-scope floats or page headers/footers. Move the body declaration into main flow, keeping its mark in the float. A running header that repeats a heading body also repeats its notes; display the heading without them."
      if data.layer != "flow" {
        advice += " Outside those floats, an empty overlay marker can be dropped at a paragraph boundary: put the body declaration before visible text in the same paragraph, or use layer: \"flow\"."
      }
      assert(str(data.internal-id) in reserved,
        message: "deixis: A page footnote has no native footer allocation. " + advice)
    }
  }
}

/// A standalone body content of a footnote.
///
/// Page-targeted bodies use the native page footer. Block-targeted bodies collect
/// after all main content of their owning block, including a multi-page block.
/// The collection can paginate; every valid layer resolves to native flow there.
/// Use an explicit `target: "page"` to allocate a page footer from inside a block.
///
/// ```info
/// Native `#std.footnote` owns page allocation. The `flow` body layer uses native
/// pagination; overlay layers reserve geometry and paint short complete bodies.
/// Empty overlay markers need a following visible layout anchor. A dropped
/// native allocation is diagnosed: put the declaration before visible text in
/// the same paragraph, or use `layer: "flow"`. Flow calls within prose preserve
/// the surrounding paragraph and spaces. An isolated body-only declaration can still create a native empty paragraph.
/// Source indentation is folded by native layout; explicit initial paragraph
/// breaks and line breaks are preserved. Breakable containers are required for
/// long bodies: use `block` with `container-args: (breakable: true)`; `rect` and
/// the alert container are unbreakable, just as in native Typst.
/// Parent-scope floats cannot allocate page footnotes in any layer. Keep the
/// mark in that float and declare its body in main flow. Ordinary column-scope
/// floats support native allocation.
/// ```
///
/// ```example
/// The evening sky was painted in a deep, haunting
/// #deixis-inline-mark(id: <smalt>)[smalt]
/// that made the first stars appear like diamonds on velvet.
///
/// #deixis-footnote-body(of: <smalt>)[A deep blue pigment made from powdered glass colored with cobalt oxide.]
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): Names a standalone body. Use of to attach this body to an original mark.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - target (auto, int, label, str): Body rendering scope. Auto inherits the original mark's exact instance, or uses the current scope for standalone bodies.
/// - series (auto, str): Collection series for a standalone body. Omit with of; attachments inherit the original's series.
/// - marker-style (auto, function): A custom styling function for the marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
/// - ..args (arguments): Additional arguments are rejected; put custom container options in `container-args`.
///
/// -> content
#let deixis-footnote-body(
  /// The actual text or content of the note.
  /// -> content
  body,
  /// Names a standalone body. Use of to attach this body to an original mark.
  /// -> none | str | label
  id: none,
  /// Custom annotation fields for creation or a standalone body. Omit with of.
  /// -> dictionary
  data: (:),
  /// Existing original annotation to attach this body to, instead of declaring a new note.
  /// -> none | str | label
  of: none,
  /// Body rendering scope. Auto inherits the original mark's exact instance,
  /// or uses the current scope for a standalone body. An explicit override
  /// changes body rendering without moving the original counter.
  /// -> auto | int | label | str
  target: auto,
  /// Collection series for a standalone body. Omit with of; attachments
  /// inherit their original's series and reject explicit series arguments.
  /// -> auto | str
  series: auto,
  /// A custom styling function for the marker.
  /// -> auto | function
  marker-style: auto,
  /// Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  /// -> auto | bool | str
  backlink: auto,
  /// The border stroke.
  /// -> auto | stroke | none
  stroke: auto,
  /// The background fill color.
  /// -> auto | color | none
  fill: auto,
  /// The border radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Overlay paint priority; higher integers paint later within a layer.
  /// Native flow retains its order. Component dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
  /// Page bodies: flow uses native pagination; overlays reserve space.
  /// Block bodies collect in native flow for every valid layer request.
  /// -> auto | str | dictionary
  layer: auto,
  /// A custom render function for the inner layout of the body.
  /// -> auto | function
  render-single: auto,
  /// A body wrapper function or preset name: "plain", "rect", "alert",
  /// "stripe" or "tinted". Forward wrapper options through container-args.
  /// -> auto | str | function
  container-func: auto,
  /// Native/custom options forwarded only to the body container.
  /// -> dictionary
  container-args: (:),
  /// Additional arguments are rejected; put custom container options in `container-args`.
  /// -> arguments
  ..args,
) = {
  let render-with-order-hints() = {
    _deixis-check-identities(id, of)
    _deixis-check-note-data(data, of: of)
    let prepared = _deixis-body-declarations(body)
    let body = prepared.body
    if args.pos().len() > 0 { panic("deixis: #deixis-footnote-body accepts at most 1 positional argument [body].") }
    _deixis-check-container-options(container-args, extra: args.named())
    let local-styles = (stroke: stroke, fill: fill, radius: radius)

    let series = _deixis-body-series(of, series, fallback: "default")

    let render-celibate(sys, celibate-id) = {
      let accent = _deixis-registry(sys).notes.at(str(celibate-id), default: (:)).at("accent", default: sys.at("annotation-accent", default: none))
      let sys = _deixis-accent-context(sys, accent)
      let resolved = _deixis-resolve-target(sys, target)

      let b-styles = _deixis-resolve-body-styles(sys, "footnote", ..local-styles)
      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "footnote")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "footnote")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "footnote")
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "footnote")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "footnote")
      let c-separator = _deixis-resolve-typed-param(sys, auto, "separator", "footnote")
      let c-clearance = _deixis-resolve-typed-param(sys, auto, "clearance", "footnote")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "footnote")
      let active-group-renderer = _deixis-resolve-typed-param(sys, auto, "render-group", "footnote")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "footnote")

      let c-layer = _deixis-footnote-layer(sys, layer, resolved.render-id)
      let note-data = (
        layer: c-layer,
        body-type: "footnote",
          z-index: _deixis-resolve-z-index(sys, z-index, "footnote", "body"),
        render-context: if resolved.render-id == "page" { none } else { _deixis-render-context() },
        internal-id: celibate-id,
        accent: accent,
        id: id,
        data: data,
        target-id: resolved.render-id,
        inst-id: resolved.inst-id,
        series: series,
        count: none,
        marker-str: none,
        mark-lbl: none,
        body-lbl: none,
        body: body,
        mark-marker-style: auto,
        body-marker-style: auto,
        body-style: c-body-style,
        backlink: c-backlink,
        indent: c-indent,
        gap: c-gap,
        marker-gap: c-marker-gap,
        separator: c-separator,
        clearance: c-clearance,
        render-single: active-renderer,
        container-func: active-container,
        container-args: container-args,
        styles: b-styles,
        render-group: active-group-renderer,
      )

      let meta = [#_deixis-metadata(note-data, <deixis-footnote>)]
      if resolved.render-id == "page" { [#meta#_deixis-page-footnote-entry(note-data)] } else { meta }
    }

    if of == none {
      return {
        prepared.declarations
        if id != none { deixis-system.update(sys => _deixis-register-standalone(sys, id, body, "footnote", data: data)) }
        _std-counter("deixis-celibate-note").step()
        _deixis-setup-context(() => {
          let uid = if id == none { "celibate-" + str(_std-counter("deixis-celibate-note").get().first()) } else { "id-" + str(id) }
          if id == none { _deixis-palette-anonymous(deixis-system.get(), sys => render-celibate(sys, uid)) }
          else { render-celibate(deixis-system.get(), uid) }
        })
      }
    }

    prepared.declarations
    deixis-system.update(sys => _deixis-register-body(sys, of, body, "footnote"))
    // Step at the declaration, before final mark association is known. A missing
    // mark must not introduce another counter update during a later layout pass.
    _std-counter("deixis-celibate-note").step()
    _deixis-setup-context(() => {
      let sys = deixis-system.get()
      let final-sys = deixis-system.final()

      let reg = _deixis-resolve-note(final-sys, of)

      if reg == none {
        return render-celibate(sys, "celibate-" + str(_std-counter("deixis-celibate-note").get().first()))
      }

      sys = _deixis-accent-context(sys, reg.at("accent", default: none))
      let internal-id = reg.internal-id
      let resolved = _deixis-resolve-body-target(sys, reg, target)

      let series = reg.at("series", default: series)
      let count = reg.count
      let marker-str = _deixis-evaluate-marker-str(reg)

      let mark-lbl = _std-label("deixis-mark-" + str(internal-id))
      let body-lbl = _std-label("deixis-body-" + str(internal-id))

      let saved-styles = reg.at("styles", default: (:))
      let merged-styles = _deixis-merge-styles(saved-styles, local-styles)

      let b-styles = _deixis-resolve-body-styles(sys, "footnote", ..merged-styles)

      let mark-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "marker-style",
        "footnote",
        component: "mark",
      )
      let body-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "marker-style",
        "footnote",
        component: "body",
      )
      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "footnote")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "footnote")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "footnote")
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "footnote")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "footnote")
      let c-separator = _deixis-resolve-typed-param(sys, auto, "separator", "footnote")
      let c-clearance = _deixis-resolve-typed-param(sys, auto, "clearance", "footnote")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "footnote")
      let active-group-renderer = _deixis-resolve-typed-param(sys, auto, "render-group", "footnote")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "footnote")

      let c-layer = _deixis-footnote-layer(sys, layer, resolved.render-id)
      let note-data = (
        layer: c-layer,
        body-type: "footnote",
          z-index: _deixis-resolve-z-index(sys, _deixis-inherited-z-index(reg, z-index), "footnote", "body"),
        render-context: if resolved.render-id == "page" { none } else { _deixis-render-context() },
        internal-id: internal-id,
        accent: reg.at("accent", default: none),
        id: reg.id,
        data: reg.at("data", default: (:)),
        target-id: resolved.render-id,
        inst-id: resolved.inst-id,
        series: series,
        count: count,
        marker-str: marker-str,
        mark-lbl: mark-lbl,
        body-lbl: body-lbl,
        body: body,
        mark-marker-style: mark-marker-style,
        body-marker-style: body-marker-style,
        body-style: c-body-style,
        backlink: c-backlink,
        indent: c-indent,
        gap: c-gap,
        marker-gap: c-marker-gap,
        separator: c-separator,
        clearance: c-clearance,
        render-single: active-renderer,
        container-func: active-container,
        container-args: container-args,
        styles: b-styles,
        render-group: active-group-renderer,
      )

      let meta = [#_deixis-metadata(note-data, <deixis-footnote>)]
      if resolved.render-id == "page" { [#meta#_deixis-page-footnote-entry(note-data)] } else { meta }
    })
  }
  _deixis-replayable(none, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}

/// A wrapper for generating footnotes.
///
/// This function creates a mark in the text and delegates the body to ```ref #deixis-footnote-body```.
///
/// ```example
/// The library’s atmosphere was defined by a subtle
/// #deixis-footnote[bibliosmia][The smell of old books.]
/// that seemed to settle on the skin like a light dust.
/// ```
///
/// - ..args (arguments): Accepts up to two positional arguments: `[mark][body]`. All named arguments are forwarded to ```ref #deixis-footnote-body```.
/// - mark-type (auto, str): The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
/// - id (none, str, label): Names the original annotation created by this wrapper. Without id, its identity is private.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - numbering (auto, none, str, function, dictionary): The numbering style for the footnote marker.
/// - marker (auto, content): A hardcoded marker to use instead of the automatic counter.
/// - target (auto, int, label, str): Creation uses the current scope; of inherits the original's rendering instance. Explicit values override the body scope.
/// - series (auto, str): Original counter series, defaulting to `"default"`. Omit with of; attachments inherit.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the footnote marker.
/// - marker-position (auto, alignment, dictionary): Mark marker placement.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
/// - pins (array): Array of pin names for the region mark.
/// - padding (auto, length, str): Internal padding for the region mark.
/// - region-shape (auto, function): Shape drawing function for the region mark.
/// - layer (auto, str): Rendering layer for the region mark. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - inline (bool): If `true`, force the region mark into an inline box.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
///
/// -> content
#let deixis-footnote(
  /// Accepts up to two positional arguments: `[mark][body]`.
  /// With of, accepts only [body] and body options. Configure the original
  /// mark separately; non-default mark-only options are rejected.
  /// -> arguments
  ..args,
  /// The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
  /// -> auto | str
  mark-type: auto,
  /// Names the original annotation created by this wrapper. Without id, its identity is private.
  /// -> none | str | label
  id: none,
  /// Custom annotation fields for creation or a standalone body. Omit with of.
  /// -> dictionary
  data: (:),
  /// Existing original annotation to attach this body to, instead of declaring a new note.
  /// -> none | str | label
  of: none,
  /// The numbering style for the marker.
  /// A record `(restart: "page", pattern: "1")` restarts displayed markers per original page; assigned counters stay unchanged.
  /// `none` disables automatic markers and counter allocation.
  /// -> auto | none | str | function | dictionary
  numbering: auto,
  /// A hardcoded marker override.
  /// -> auto | content
  marker: auto,
  /// Auto uses the current scope for creation and inherits the original's
  /// exact rendering instance with of. Explicit values override the body scope
  /// when attached, without moving the original counter.
  /// -> auto | int | label | str
  target: auto,
  /// Original counter series, defaulting to `"default"` for creation.
  /// Omit with of; an attachment inherits and cannot redefine the series.
  /// -> auto | str
  series: auto,
  /// A custom styling function for the marker.
  /// -> auto | function
  marker-style: auto,
  /// Mark marker placement.
  ///
  /// See `deixis-inline-mark.marker-position` and `deixis-region-mark.marker-position`.
  ///
  /// -> auto | alignment | dictionary
  marker-position: auto,
  /// The border stroke.
  /// -> auto | stroke | none
  stroke: auto,
  /// The background fill color.
  /// -> auto | color | none
  fill: auto,
  /// The border radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Overlay paint priority; higher integers paint later within a layer.
  /// Native flow retains its order. Component dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
  /// The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
  ///
  /// See `deixis-inline-mark.inline-mode`.
  ///
  /// -> auto | str
  inline-mode: auto,
  /// Array of pin names for the region mark.
  ///
  /// See `deixis-region-mark.pins`.
  ///
  /// -> array
  pins: (),
  /// Internal padding for the region mark.
  ///
  /// See `deixis-region-mark.padding`.
  ///
  /// -> auto | length | str | dictionary
  padding: auto,
  /// Shape drawing function for the region mark.
  ///
  /// See `deixis-region-mark.region-shape`.
  ///
  /// -> auto | function
  region-shape: auto,
  /// Rendering layer for the region mark. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// See `deixis-region-mark.layer`.
  ///
  /// -> auto | str
  layer: auto,
  /// If `true`, force the region mark into an inline box.
  ///
  /// See `deixis-region-mark.inline`.
  ///
  /// -> bool
  inline: false,
  /// Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  /// -> auto | bool | str
  backlink: auto,
  /// A custom render function for the inner layout of the body.
  /// -> auto | function
  render-single: auto,
  /// A body wrapper function or preset name: "plain", "rect", "alert",
  /// "stripe" or "tinted". Forward wrapper options through container-args.
  /// -> auto | str | function
  container-func: auto,
  /// Native/custom options forwarded only to the body container.
  /// -> dictionary
  container-args: (:),
) = {
  let render-with-order-hints() = {
    _deixis-check-identities(id, of)
    _deixis-check-note-data(data, of: of)
    let pos = args.pos()
    if pos.len() > 2 { panic("deixis: #deixis-footnote accepts at most 2 positional arguments: [mark][body]") }
    _deixis-check-attached-wrapper(of, pos, mark-options: (
      numbering: numbering, series: series, marker: marker, mark-type: mark-type,
      marker-position: marker-position, inline-mode: inline-mode,
      pins: if pins == () { auto } else { pins },
      padding: padding, region-shape: region-shape,
      inline: if inline == false { auto } else { inline },
    ))
    _deixis-check-container-options(container-args, extra: args.named())
    let mark-content = if pos.len() > 1 { pos.first() } else { none }
    let body = if pos.len() > 0 { pos.last() } else { none }

    let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

    if of != none {
      return deixis-footnote-body(
        body,
        layer: layer,
        of: of,
        target: target,
        marker-style: marker-style,
        backlink: backlink,
        stroke: stroke,
        fill: fill,
        radius: radius,
        z-index: z-index,
        render-single: render-single,
        container-func: container-func,
        container-args: container-args,
      )
    }

    // Creation uses the current scope and adapter series; attachments above
    // inherit the original's exact rendering instance and counter series.
    let target = if target == auto { 0 } else { target }
    let series = if series == auto { "default" } else { series }

    let render-mark(target-id) = {
      if mark-type == "region" {
        deixis-region-mark(
          mark-content,
          id: target-id, _family: "footnote",
          data: data,
          pins: pins,
          numbering: numbering,
          marker: marker,
          target: target,
          series: series,
          marker-style: marker-style,
          marker-position: marker-position,
          stroke: stroke,
          fill: fill,
          radius: radius,
          z-index: z-index,
          padding: padding,
          region-shape: region-shape,
          layer: layer,
          inline: inline,
        )
      } else if mark-type == "phantom" {
        deixis-phantom-mark(
          id: target-id, _family: "footnote",
          data: data,
          z-index: z-index,
          numbering: numbering,
          marker: marker,
          target: target,
          series: series,
        )
      } else {
        deixis-inline-mark(
          mark-content,
          id: target-id, _family: "footnote",
          data: data,
          numbering: numbering,
          marker: marker,
          target: target,
          series: series,
          marker-style: marker-style,
          marker-position: marker-position,
          inline-mode: inline-mode,
          stroke: stroke,
          fill: fill,
          radius: radius,
          z-index: z-index,
        )
      }
    }

    let render-body(target-id) = {
      deixis-footnote-body(
        body,
        layer: layer,
        of: target-id,
        target: target,
        marker-style: marker-style,
        backlink: backlink,
        stroke: stroke,
        fill: fill,
        radius: radius,
        z-index: z-index,
        render-single: render-single,
        container-func: container-func,
        container-args: container-args,
      )
    }

    let emit(owner) = {
      let m = render-mark(owner)
      let b = render-body(owner)
      // HTML export has no floating placement; the body lists after the document.
      if mark-type == "region" and inline == false and _std-target() != "html" { [#m#place(b)] } else { [#m#b] }
    }
    if id == none { _deixis-with-auto-id(emit) } else { context emit(id) }
  }
  _deixis-replayable(if args.pos().len() > 1 { args.pos().first() }, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}

// Footnote overlay
#let _deixis-footnote-paint-commands(layer: "foreground") = {
  let current-page = here().page()
  let left-probes = query(<deixis-reserver-left>).filter(n => n.location().page() == current-page and n.value.layer == layer)

  if left-probes.len() == 0 { return () }
  let right-probes = (:)
  for probe in query(<deixis-reserver-right>).filter(n => n.location().page() == current-page) {
    let key = str(probe.value.internal-id)
    if key not in right-probes { right-probes.insert(key, probe) }
  }
  let page-entries = query(footnote.entry).filter(entry => entry.location().page() == current-page)

  let columns = (:)
  for (i, probe) in left-probes.enumerate() {
    let x-key = str(calc.round(probe.location().position().x.pt(), digits: 1))
    let arr = columns.at(x-key, default: ())
    arr.push((left: probe, right: right-probes.at(str(probe.value.internal-id))))
    columns.insert(x-key, arr)
  }

  let commands = ()
  for (x-key, probes-in-col) in columns {
    let first-probe = probes-in-col.first().left
    let start-x = first-probe.location().position().x
    let start-y = first-probe.location().position().y

    let col-width = probes-in-col.first().right.location().position().x - start-x

    let col-notes-data = ()
    let seen = (:)
    for p in probes-in-col {
      let k = str(p.left.value.internal-id)
      if k not in seen {
        seen.insert(k, true)
        col-notes-data.push(p.left.value)
      }
    }

    let first-note = col-notes-data.first()
    let active-group-renderer = first-note.render-group
    // Native layout owns the separator, clearance and gap between reserved
    // slots. Paint a group with the measured native gap so it fills exactly
    // those slots; a configured body gap would drift from the reservations.
    let slots = probes-in-col.map(p => (y: p.left.location().position().y,
      height: p.left.value.at("reserved-height", default: 0pt))).sorted(key: s => s.y)
    let c-gap = if slots.len() > 1 { slots.at(1).y - slots.first().y - slots.first().height } else { first-note.gap }
    let native-entries = page-entries.filter(entry => calc.abs(entry.location().position().x - start-x) < 1pt)
    // A shared group is safe only when every reservation uses its group policy.
    // Otherwise retain native slots and each note's own renderer.
    let homogeneous = native-entries.len() == probes-in-col.len() and col-notes-data.all(n => (
      n.render-group == active-group-renderer
        and n.at("render-context", default: none) == first-note.at("render-context", default: none)
    ))

    commands.push(_deixis-paint-command("footnote-column", x-key, () => place(
      top + left,
      dx: start-x,
      dy: start-y,
      block(width: col-width, {
        if homogeneous {
          for series-notes in _deixis-series-groups(col-notes-data) {
            _deixis-render-single(series-notes.first(),
              renderer: (_, ..options) => active-group-renderer(series-notes, ..options.named()), gap: c-gap)
          }
        } else {
          // Preserve the native reserved slots when layers or native notes mix.
          // Regrouping only one subset would paint over intervening entries.
          for probe in probes-in-col {
            let data = probe.left.value
            place(top + left, dy: probe.left.location().position().y - start-y,
              _deixis-render-single(data, inner-width: 100%))
          }
        }
      }),
    ), members: col-notes-data.map(n => n.internal-id),
      priority: _deixis-group-z-index("footnote column", col-notes-data)))
  }
  commands
}
