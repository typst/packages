#import "../core/internal.typ": *
#import "../marks/inline.typ": *
#import "../marks/region.typ": *
#import "../layout/geometry.typ": _deixis-block-segments
#import "../routing/document-policy.typ": _deixis-capture-routing
#import "../core/native.typ": *

// Immediate notes are painted once at their declaration, on that physical page.
// HTML export lists margin bodies after the document instead.
#let _deixis-immediate-margin(data) = context {
  if _std-target() == "html" { return }
  let origin = here().position()
  let p = here().page()
  let page-size = deixis-utils.get-page-size(p)
  let margins = deixis-utils.get-page-margins(p)
  let start-x = deixis-utils.resolve-len(margins.left)
  let end-x = deixis-utils.resolve-len(page-size.width) - deixis-utils.resolve-len(margins.right)
  let top-y = deixis-utils.resolve-len(margins.top)
  let bottom-y = deixis-utils.resolve-len(page-size.height) - deixis-utils.resolve-len(margins.bottom)
  let l-space = start-x
  let r-space = deixis-utils.resolve-len(margins.right)
  if data.target-id != "page" {
    let start = query(<deixis-block-start>).find(b => b.value.id == data.inst-id and b.value.render-id == data.target-id)
    let end = query(<deixis-block-end>).find(b => b.value.id == data.inst-id)
    let right-edge = query(<deixis-block-right>).find(b => b.value.id == data.inst-id)
    let frames = (:)
    for f in query(<deixis-page-frame>) { frames.insert(str(f.value.page), f.value) }
    let segments = if start == none or end == none or right-edge == none { () } else {
      _deixis-block-segments(start, end, right-edge, frames)
    }
    let segment = segments.find(s => s.page == p)
    if segment == none {
      panic("deixis: An immediate margin note needs its target block on the declaration page. Use an overlay for another page.")
    }
    start-x = segment.start-x
    end-x = start-x + segment.text-width
    l-space = segment.l-space
    r-space = segment.r-space
    top-y = segment.top
    bottom-y = segment.bottom
  }
  let pos = origin
  if data.mark-lbl != none {
    let marks = query(data.mark-lbl).filter(m => m.location().page() == p)
    if marks.len() > 0 { pos = marks.first().location().position() }
  }
  if data.anchor-pin != none {
    let pins = _deixis-select-pins(_deixis-pin-index(), data.anchor-pin,
      default: "first", page: p, single: true)
    if pins.len() > 0 { pos = pins.first().location().position() }
  }
  let normalized = data + (y: pos.y, mark-x: pos.x, mark-y: pos.y)
  // A page-sized container establishes an actual page coordinate frame. Nested
  // place calls alone still inherit the scope's origin on continuation pages.
  let frame = _deixis-margin-frame(top-y, bottom-y, bottom-y, l-space, r-space, p, deixis-utils.get-page-binding())
  let side = _deixis-margin-side(normalized, frame, deixis-utils.text-direction(text.dir, text.lang), "exact",
    deixis-utils.resolve-len(data.min-margin-width), top-y, top-y)
  let prepared = _deixis-prepare-margin(normalized, side, frame, "exact")
  prepared.insert("final-y", prepared.y)
  deixis-absolute-place(_deixis-paint-margin("exact",
    ((note-data: normalized, mark-page: p, _margin-placement: prepared),), frame, start-x, end-x - start-x, p))
}

/// A standalone body content of a margin note.
///
/// Body content is preserved. Built-in single renderers fold source indentation
/// with native weak marker spacing and retain explicit paragraph/line breaks.
///
/// ```example
/// //| sandbox-mode: "page"
/// The old manor was a labyrinth of
/// #deixis-inline-mark(id: <crepuscular>)[crepuscular]
/// corridors, where the shadows seemed to stretch and breathe with the setting sun.
///
/// #deixis-margin-note-body(of: <crepuscular>)[Relating to or resembling twilight.]
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
/// - width (auto, length, relative): The width of the margin note body. Defaults to `90%` of the margin width.
/// - dx (auto, length): Horizontal offset adjustment for the body.
/// - dy (length): Vertical offset adjustment for the body. Defaults to `0pt`.
/// - side (auto, alignment): Which margin to place the note in (`left` or `right`). If `auto`, uses the side nearest the mark.
/// - side-strategy (auto, str): Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
/// - mark-align (auto, alignment, dictionary): How the note aligns vertically relative to its mark.
/// - mark-align-strictness (auto, str): How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
/// - spillover (auto, bool): Allow this note to spill over page boundary.
/// - overflow (auto, str, dictionary): Final margin-frame policy: "allow" or "error".
/// - anchor-pin (none, str, dictionary): Pin name or `(name:, scope:, select:, page:)` target; one selected occurrence anchors the body.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
/// - ..args (arguments): Additional arguments are rejected; put custom container options in `container-args`.
///
/// -> content
#let deixis-margin-note-body(
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
  /// Connector from the original mark to this body. A route name such as
  /// `"curve"` is shorthand for `(route: "curve")`; a record also sets ports,
  /// via/segments, heads, stroke, radius, layer and painters. It merges with
  /// `deixis-set(connector: ...)` defaults field by field; none disables it.
  /// Routes also accept settings records such as `(kind: "curve", tension: 2)`.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(connector: (route: "right-angle", heads: "stealth"))[A connected note.]
  /// ```
  ///
  /// -> auto | none | str | dictionary
  connector: auto,
  /// The width of the margin note body. Defaults to `90%` of the margin width.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #lorem(3)
  /// #deixis-margin-note(width: 50%)[A narrow 50% note.]
  /// ```
  ///
  /// -> auto | length | relative
  width: 90%,
  /// Horizontal offset adjustment for the body.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(dx: -30pt)[A horizontally shifted note.]
  /// ```
  ///
  /// -> auto | length
  dx: auto,
  /// Vertical offset adjustment for the body.
  ///
  /// ```info
  /// `dy` is applied pre-layout, meaning that the final coordinates of the note can change after the rubber band pass.
  /// ```
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(dy: -50pt)[A vertically shifted note.]
  /// ```
  ///
  /// -> length
  dy: 0pt,
  /// Which margin to place the note in (`left` or `right`). If `auto`, uses the side nearest the mark.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(side: left)[This is a left side note.]
  /// #deixis-margin-note(side: right)[This is a right side note.]
  /// ```
  ///
  /// -> auto | alignment
  side: auto,
  /// Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
  ///
  /// - With `side-strategy: "nearest"`, notes will prefer the side that minimizes the vertical distance from the mark to the body.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(side-strategy: "nearest")[Note A body.]
  /// #deixis-margin-note(side-strategy: "nearest")[Note B body.]
  /// ```
  ///
  /// - With `side-strategy: "strict"`, notes will prefer the more visually favorable side until it is overflow.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(side-strategy: "strict")[Note A body.]
  /// #deixis-margin-note(side-strategy: "strict")[Note B body.]
  /// ```
  ///
  /// -> auto | str
  side-strategy: auto,
  /// How the note aligns vertically relative to its mark.
  /// - It can be an `alignment` or an equivalent `str`.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #lorem(8)
  /// #deixis-margin-note(
  ///   mark-align: bottom,
  ///   connector: "right-angle",
  ///   stroke: red,
  ///   container-func: deixis-rect-container)[Top-aligned note body]
  /// ```
  /// - Or a component-scope `dictionary`, only useful with `mark-type: "region"`.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(
  ///   mark-type: "region",
  ///   padding: "text",
  ///   mark-align: (mark: horizon, body: horizon),
  ///   connector: "right-angle",
  ///   stroke: red,
  ///   container-func: deixis-rect-container)[#lorem(8)][Horizon-aligned note body.]
  /// ```
  ///
  /// -> auto | alignment | dictionary
  mark-align: auto,
  /// How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
  /// -> auto | str
  mark-align-strictness: auto,
  /// Allow this note to spill over page boundary.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(spillover: false)[This is a very long note. #lorem(120)]
  /// #deixis-margin-note(spillover: false)[This is another extremely long note. #lorem(120)]
  /// #deixis-margin-note(spillover: true)[This is a spilled note.]
  /// ```
  ///
  /// -> auto | bool
  spillover: auto,
  /// Keep out-of-frame placement ("allow") or diagnose final margin bounds ("error").
  /// The default is inherited; factory behavior is "allow".
  /// -> auto | str | dictionary
  overflow: auto,
  /// A specific `#deixis-pin` name to anchor the body to, instead of the default layout logic.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(
  ///   anchor-pin: "pin0")[A note anchored to a pin.]
  /// #lorem(20)
  /// #deixis-pin("pin0")
  /// ```
  ///
  /// Structured pin targets accept scope, select (first/last/unique), and page.
  /// Flow placement filters to the declaration page before selecting.
  /// -> none | str | dictionary
  anchor-pin: none,
  /// Body layer; flow is immediate placement with no spillover or collision pass.
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
    if args.pos().len() > 0 { panic("deixis: #deixis-margin-note-body accepts at most 1 positional argument [body].") }
    _deixis-check-container-options(container-args, extra: args.named())
    let local-styles = (stroke: stroke, fill: fill, radius: radius)

    let series = _deixis-body-series(of, series, fallback: "default")

    let render-celibate(sys, celibate-id) = {
      let accent = _deixis-registry(sys).notes.at(str(celibate-id), default: (:)).at("accent", default: sys.at("annotation-accent", default: none))
      let sys = _deixis-accent-context(sys, accent)
      let resolved = _deixis-resolve-target(sys, target)

      let b-styles = _deixis-resolve-body-styles(sys, "margin-note", ..local-styles)

      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "margin-note")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "margin-note")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "margin-note")
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "margin-note")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "margin-note")

      let c-margin-layout = _deixis-resolve-typed-param(sys, auto, "margin-layout", "margin-note")
      let c-min-margin-width = _deixis-resolve-typed-param(sys, auto, "min-margin-width", "margin-note")
      let c-mark-align = _deixis-resolve-typed-param(sys, mark-align, "mark-align", "margin-note")
      let c-mark-align-strictness = _deixis-resolve-typed-param(
        sys,
        mark-align-strictness,
        "mark-align-strictness",
        "margin-note",
      )
      let c-side-strategy = _deixis-resolve-typed-param(sys, side-strategy, "side-strategy", "margin-note")
      let c-spillover = _deixis-resolve-typed-param(sys, spillover, "spillover", "margin-note")
      let c-overflow = _deixis-resolve-typed-param(sys, overflow, "overflow", "margin-note")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "margin-note")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "margin-note")

      let c-layer = _deixis-resolve-typed-param(sys, layer, "layer", "margin-note", component: "body")
      let note-data = (
        (
          layer: c-layer,
          body-type: "margin-note",
          z-index: _deixis-resolve-z-index(sys, z-index, "margin-note", "body"),
          render-context: _deixis-render-context(),
          internal-id: celibate-id,
          accent: accent,
          id: id,
          data: data,
          target-id: resolved.render-id,
          inst-id: resolved.inst-id,
          series: series,
          count: none,
          marker-str: none,
          body: body,
          mark-lbl: none,
          body-lbl: none,
          mark-marker-style: auto,
          body-marker-style: auto,
          body-style: c-body-style,
          backlink: c-backlink,
          indent: c-indent,
          gap: c-gap,
          marker-gap: c-marker-gap,
          styles: b-styles,
          render-single: active-renderer,
          container-func: active-container,
          container-args: container-args,
        )
          + (
            width: width,
            dx: dx,
            dy: dy,
            margin-layout: c-margin-layout,
            min-margin-width: c-min-margin-width,
            side: side,
            side-strategy: c-side-strategy,
            mark-align: c-mark-align,
            mark-align-strictness: c-mark-align-strictness,
            spillover: c-spillover,
            overflow: c-overflow,
            anchor-pin: anchor-pin,
            depth: sys.stack.len(),
            has-inline-box: false,
            mark-type: none,
            text-size: text.size,
            marker-width: 0pt,
          )
      )

      [#_deixis-metadata(note-data, <deixis-margin-note>)]
      if c-layer == "flow" { _deixis-immediate-margin(note-data) }
    }

    if of == none {
      return {
        prepared.declarations
        if id != none { deixis-system.update(sys => _deixis-register-standalone(sys, id, body, "margin-note", data: data)) }
        _std-counter("deixis-celibate-note").step()
        _deixis-setup-context(() => {
          let uid = if id == none { "celibate-" + str(_std-counter("deixis-celibate-note").get().first()) } else { "id-" + str(id) }
          if id == none { _deixis-palette-anonymous(deixis-system.get(), sys => render-celibate(sys, uid)) }
          else { render-celibate(deixis-system.get(), uid) }
        })
      }
    }

    prepared.declarations
    deixis-system.update(sys => _deixis-register-body(sys, of, body, "margin-note"))
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
      let depth = sys.stack.len()

      let series = reg.at("series", default: series)
      let count = reg.count
      let marker-str = _deixis-evaluate-marker-str(reg)

      let mark-lbl = _std-label("deixis-mark-" + str(internal-id))
      let body-lbl = _std-label("deixis-body-" + str(internal-id))

      let saved-styles = reg.at("styles", default: (:))
      let merged-styles = _deixis-merge-styles(saved-styles, local-styles)

      let b-styles = _deixis-resolve-body-styles(sys, "margin-note", ..merged-styles)
      let l-styles = _deixis-resolve-connector-styles(
        sys,
        "margin-note",
        stroke: merged-styles.at("stroke", default: auto),
        radius: merged-styles.at("radius", default: auto),
      )

      let mark-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "marker-style",
        "margin-note",
        component: "mark",
      )
      let body-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "marker-style",
        "margin-note",
        component: "body",
      )
      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "margin-note")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "margin-note")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "margin-note")
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "margin-note")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "margin-note")

      let c-margin-layout = _deixis-resolve-typed-param(sys, auto, "margin-layout", "margin-note")
      let c-min-margin-width = _deixis-resolve-typed-param(sys, auto, "min-margin-width", "margin-note")
      let c-side-strategy = _deixis-resolve-typed-param(sys, side-strategy, "side-strategy", "margin-note")
      let c-mark-align = _deixis-resolve-typed-param(sys, mark-align, "mark-align", "margin-note")
      let c-mark-align-strictness = _deixis-resolve-typed-param(
        sys,
        mark-align-strictness,
        "mark-align-strictness",
        "margin-note",
      )
      let c-spillover = _deixis-resolve-typed-param(sys, spillover, "spillover", "margin-note")
      let c-overflow = _deixis-resolve-typed-param(sys, overflow, "overflow", "margin-note")

      let connector-data = _deixis-connector-options(sys, "margin-note", connector,
        via: auto,
        stroke: l-styles.stroke, radius: l-styles.radius,
        z-index: _deixis-inherited-z-index(reg, z-index))
      let c-link = connector-data.route
      let c-link-ports = connector-data.ports
      let c-link-marks = connector-data.marks
      if reg.at("mark-type", default: "inline") == "phantom" {
        if connector == auto { c-link = "none" }
      }

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "margin-note")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "margin-note")

      let has-inline-box = if reg.at("mark-type", default: "inline") == "inline" {
        reg.at("inline-mode", default: auto) == "box" and reg.at("has-mark-body", default: false)
      } else { false }

      let c-layer = _deixis-resolve-typed-param(sys, layer, "layer", "margin-note", component: "body")
      let note-data = (
        (
          layer: c-layer,
          body-type: "margin-note",
          z-index: _deixis-resolve-z-index(sys, _deixis-inherited-z-index(reg, z-index), "margin-note", "body"),
          render-context: _deixis-render-context(),
          internal-id: internal-id,
          accent: reg.at("accent", default: none),
          id: reg.id,
          data: reg.at("data", default: (:)),
          target-id: resolved.render-id,
          inst-id: resolved.inst-id,
          series: series,
          count: count,
          marker-str: marker-str,
          body: body,
          mark-lbl: mark-lbl,
          body-lbl: body-lbl,
          mark-marker-style: mark-marker-style,
          body-marker-style: body-marker-style,
          body-style: c-body-style,
          backlink: c-backlink,
          indent: c-indent,
          gap: c-gap,
          marker-gap: c-marker-gap,
          styles: b-styles,
          render-single: active-renderer,
          container-func: active-container,
          container-args: container-args,
        )
          + (
            width: width,
            dx: dx,
            dy: dy,
            margin-layout: c-margin-layout,
            min-margin-width: c-min-margin-width,
            side: side,
            side-strategy: c-side-strategy,
            mark-align: c-mark-align,
            mark-align-strictness: c-mark-align-strictness,
            spillover: c-spillover,
            overflow: c-overflow,
            link: c-link,
            link-stroke: connector-data.stroke,
            link-radius: connector-data.radius,
            link-waypoints: connector-data.via,
            link-ports: c-link-ports,
            link-marks: c-link-marks,
            link-heads: connector-data.heads,
            link-render: connector-data.render,
            link-gap-marks: connector-data.gap-marks,
            link-cuts: connector-data.cuts,
            link-crossings: connector-data.crossings,
            link-continuation: connector-data.continuation,
            link-spill: connector-data.spill,
            link-scene: connector-data.scene,
            link-layer: connector-data.layer,
            link-z-index: connector-data.z-index,
            anchor-pin: anchor-pin,
            depth: depth,
            has-inline-box: has-inline-box,
            mark-type: reg.at("mark-type", default: "inline"),
            text-size: text.size,
            marker-width: if marker-str != none { measure(mark-marker-style(marker-str)).width } else { 0pt },
          )
      )

      note-data += _deixis-capture-routing(connector-data + (route: c-link))
      [#_deixis-metadata(note-data, <deixis-margin-note>)]
      if c-layer == "flow" { _deixis-immediate-margin(note-data) }
    })
  }
  _deixis-replayable(none, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index, connector: connector)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}

/// A wrapper for generating margin notes.
///
/// This function creates a mark in the text and delegates the body to ```ref #deixis-margin-note-body```.
///
/// ```example
/// //| sandbox-mode: "page"
/// The traveler felt a sudden sense of
/// #deixis-margin-note[fernweh][A deep, aching longing for far-off places; literally _farsickness_.]
/// as he watched the ships disappear beyond the horizon, bound for lands he had never seen.
/// ```
///
/// - ..args (arguments): Accepts up to two positional arguments: `[mark][body]`. All named arguments are forwarded to ```ref #deixis-margin-note-body```.
/// - mark-type (auto, str): The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
/// - id (none, str, label): Names the original annotation created by this wrapper. Without id, its identity is private.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - numbering (auto, none, str, function, dictionary): The numbering style for the marker.
/// - marker (auto, content): A hardcoded marker override.
/// - target (auto, int, label, str): Creation uses the current scope; of inherits the original's rendering instance. Explicit values override the body scope.
/// - series (auto, str): Original counter series, defaulting to `"default"`. Omit with of; attachments inherit.
/// - marker-style (auto, function): A custom styling function for the marker.
/// - marker-position (auto, alignment, dictionary): Mark marker placement.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
/// - pins (array): Array of pin names for the region mark.
/// - padding (auto, length, str, dictionary): Internal padding for the region mark.
/// - region-shape (auto, function): Shape drawing function for the region mark.
/// - layer (auto, str): Rendering layer for the region mark. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - inline (bool): If `true`, force the region mark into an inline box.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - width (auto, length, relative): The width of the margin note body. Defaults to `90%` of the margin width.
/// - dx (auto, length): Horizontal offset adjustment for the body.
/// - dy (length): Vertical offset adjustment for the body. Defaults to `0pt`.
/// - side (auto, alignment): Which margin to place the note in (`left` or `right`). If `auto`, uses the side nearest the mark.
/// - side-strategy (auto, str): Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
/// - mark-align (auto, alignment, dictionary): How the note aligns vertically relative to its mark.
/// - mark-align-strictness (auto, str): How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
/// - spillover (auto, bool): Allow this note to spill over page boundary.
/// - overflow (auto, str, dictionary): Final margin-frame policy: "allow" or "error".
/// - anchor-pin (none, str, dictionary): Pin name or structured target selecting one anchor occurrence.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
///
/// -> content
#let deixis-margin-note(
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
  /// Connector from the original mark to this body. A route name such as
  /// `"curve"` is shorthand for `(route: "curve")`; a record also sets ports,
  /// via/segments, heads, stroke, radius, layer and painters. It merges with
  /// `deixis-set(connector: ...)` defaults field by field; none disables it.
  /// Routes also accept settings records such as `(kind: "curve", tension: 2)`.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(connector: (route: "right-angle", heads: "stealth"))[A connected note.]
  /// ```
  ///
  /// -> auto | none | str | dictionary
  connector: auto,
  /// The width of the margin note body.
  ///
  /// See `deixis-margin-note-body.width`.
  ///
  /// -> auto | length | relative
  width: 90%,
  /// Horizontal offset adjustment for the body.
  ///
  /// See `deixis-margin-note-body.dx`.
  ///
  /// -> auto | length
  dx: auto,
  /// Vertical offset adjustment for the body.
  ///
  /// See `deixis-margin-note-body.dy`.
  ///
  /// -> length
  dy: 0pt,
  /// Which margin to place the note in (`left` or `right`).
  ///
  /// See `deixis-margin-note-body.side`.
  ///
  /// -> auto | alignment
  side: auto,
  /// Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
  ///
  /// See `deixis-margin-note-body.side-strategy`.
  ///
  /// -> auto | str
  side-strategy: auto,
  /// How the note aligns vertically relative to its mark.
  ///
  /// See `deixis-margin-note-body.mark-align`.
  ///
  /// -> auto | alignment | dictionary
  mark-align: auto,
  /// How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
  ///
  /// See `deixis-margin-note-body.mark-align-strictness`.
  ///
  /// -> auto | str
  mark-align-strictness: auto,
  /// Allow this note to spill over page boundary.
  ///
  /// See `deixis-margin-note-body.spillover`.
  ///
  /// -> auto | bool
  spillover: auto,
  /// Keep out-of-frame placement ("allow") or diagnose final margin bounds ("error").
  /// The default is inherited; factory behavior is "allow".
  /// -> auto | str | dictionary
  overflow: auto,
  /// A specific `#deixis-pin` name to anchor the body to, instead of the default layout logic.
  ///
  /// See `deixis-margin-note-body.anchor-pin`.
  ///
  /// -> none | str | dictionary
  anchor-pin: none,
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
    if pos.len() > 2 { panic("deixis: #deixis-margin-note accepts at most 2 positional arguments: [mark][body]") }
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
      return deixis-margin-note-body(
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
        connector: connector,
        width: width,
        dx: dx,
        dy: dy,
        side: side,
        side-strategy: side-strategy,
        mark-align: mark-align,
        mark-align-strictness: mark-align-strictness,
        spillover: spillover,
        overflow: overflow,
        anchor-pin: anchor-pin,
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
          id: target-id, _family: "margin-note",
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
          id: target-id, _family: "margin-note",
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
          id: target-id, _family: "margin-note",
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
      deixis-margin-note-body(
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
        connector: connector,
        width: width,
        dx: dx,
        dy: dy,
        side: side,
        side-strategy: side-strategy,
        mark-align: mark-align,
        mark-align-strictness: mark-align-strictness,
        spillover: spillover,
        overflow: overflow,
        anchor-pin: anchor-pin,
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
  _deixis-replayable(if args.pos().len() > 1 { args.pos().first() }, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index, connector: connector)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}

// Margin note overlay
#let _deixis-margin-paint-output(layer: "foreground") = {
  let notes = query(<deixis-margin-note>).filter(n => n.value.layer == layer and not _deixis-is-hidden(n.value))
  if notes.len() == 0 { return (evidence: [], commands: ()) }
  // Inactive margin layers need no document-wide frame dependency. Reading it
  // here can consume the last native layout pass of a paginated collection.
  let current-page = here().page()
  let frames = query(<deixis-page-frame>)
  let total-pages = if frames.len() > 0 { calc.max(..frames.map(f => f.value.page)) } else { current-page }

  let evidence = []
  let commands = ()

  let anchors = _deixis-anchor-index()
  let processed-notes = ()
  let measure-anchors = (:)
  for n in notes {
    let uid = n.value.at("internal-id", default: none)
    if uid != none { measure-anchors.insert(str(uid), n) }
  }

  // pre-processor
  for n in notes {
    let note-data = n.value

    let is-celibate = note-data.at("mark-lbl", default: none) == none

    let mark-page = none
    let mark-x = none
    let mark-y = none
    let marker-width = note-data.at("marker-width", default: 0pt)

    let is-region = false
    let reg = none
    let r-pins = ()

    let anchor-pin = note-data.at("anchor-pin", default: none)

    if not is-celibate {
      let internal-id = str(note-data.mark-lbl).slice("deixis-mark-".len())

      let region = anchors.regions.at(internal-id, default: none)
      is-region = region != none
      reg = if is-region { region.value } else { none }

      if is-region {
        if _deixis-is-hidden(reg) { note-data.insert("link", "none") }
        r-pins = _deixis-pins-for(anchors.pin-index, reg.pins)
      } else {
        // Pre-calculate marker width for inline/phantom marks
        let mark = anchors.marks.at(internal-id, default: none)
        if mark != none {
          if _deixis-is-hidden(mark.value) { note-data.insert("link", "none") }
          marker-width = mark.value.at("marker-width", default: 0pt)
        }
      }
    }

    if anchor-pin != none {
      let spec-pins = _deixis-select-pins(anchors.pin-index, anchor-pin, default: "first", single: true)
      if spec-pins.len() > 0 {
        let p = spec-pins.first()
        mark-page = p.location().page()
        mark-x = p.location().position().x
        mark-y = p.location().position().y
      }
    } else if not is-celibate {
      if is-region and r-pins.len() > 0 {
        // Region bbox align
        let sorted-pins = r-pins.sorted(key: p => (p.location().page(), p.location().position().y))
        let c-align = note-data.at("mark-align", default: "top")

        let align-str = if type(c-align) == dictionary { repr(c-align.mark) } else { repr(c-align) }

        if "bottom" in align-str {
          let target-pin = sorted-pins.last()
          mark-page = target-pin.location().page()
          mark-x = target-pin.location().position().x
          mark-y = target-pin.location().position().y
        } else if "horizon" in align-str {
          let p-first = sorted-pins.first()
          let p-last = sorted-pins.last()

          mark-page = p-first.location().page()
          mark-x = p-first.location().position().x

          if p-first.location().page() == p-last.location().page() {
            mark-y = (p-first.location().position().y + p-last.location().position().y) / 2
          } else {
            mark-y = p-first.location().position().y
          }
        } else {
          let target-pin = sorted-pins.first()
          mark-page = target-pin.location().page()
          mark-x = target-pin.location().position().x
          mark-y = target-pin.location().position().y
        }
      } else {
        // Inline & Phantom mark align
        let text-elems = query(selector(note-data.mark-lbl))
        if text-elems.len() > 0 {
          let tel = text-elems.first()
          mark-page = tel.location().page()
          mark-x = tel.location().position().x
          mark-y = tel.location().position().y

        }
      }
    }

    // Only unanchored standalone bodies need the declaration's geometry.
    // Reading it for every attached body creates an unnecessary layout dependency.
    if mark-page == none {
      mark-page = n.location().page()
      mark-x = n.location().position().x
      mark-y = n.location().position().y
    }
    processed-notes.push((
      note-data: note-data,
      mark-page: mark-page,
      mark-x: mark-x,
      mark-y: mark-y,
      marker-width: marker-width,
      mark-type: note-data.at("mark-type", default: "inline"),
      reg: reg,
      r-pins: r-pins,
    ))
  }

  let sys = deixis-system.get()

  let c-margin-layout = _deixis-resolve-typed-param(sys, auto, "margin-layout", "margin-note")
  let c-min-margin-width = _deixis-resolve-typed-param(sys, auto, "min-margin-width", "margin-note")

  let p-margins = deixis-utils.get-page-margins(current-page)
  let r-len(val, def) = if val == auto { def } else { val }
  let page-size = deixis-utils.get-page-size(current-page)
  let page-w = page-size.width
  let page-h = page-size.height

  let top-bound = deixis-utils.resolve-len(p-margins.top)
  let bottom-bound = deixis-utils.resolve-len(page-h) - deixis-utils.resolve-len(p-margins.bottom)
  let l-space-abs = deixis-utils.resolve-len(p-margins.left)
  let r-space-abs = deixis-utils.resolve-len(p-margins.right)

  let start-x = l-space-abs
  let width-val = deixis-utils.resolve-len(page-w) - l-space-abs - r-space-abs

  // calculate stranded notes
  let all-block-notes = processed-notes.filter(n => n.note-data.target-id != "page")
  let stranded-notes = all-block-notes.filter(n => n.mark-page == current-page)
  let stranded-pushed = ()

  for n in stranded-notes {
    let rid = n.note-data.target-id
    let starts = query(<deixis-block-start>).filter(x => x.value.at("render-id", default: none) == rid)
    if starts.len() > 0 and starts.first().location().page() > current-page {
      let new-note-data = n.note-data
      new-note-data.insert("mark-x", n.mark-x)
      new-note-data.insert("mark-y", n.mark-y)
      new-note-data.insert("marker-width", n.marker-width)
      stranded-pushed.push((note-data: new-note-data, mark-page: current-page, mark-block: 0, block-idx: 1))
    }
  }

  // page level
  let all-page-notes = processed-notes.filter(n => n.note-data.target-id == "page")

  if all-page-notes.len() > 0 or stranded-pushed.len() > 0 {
    let active-notes = ()
    let pushed-notes = stranded-pushed

    if all-page-notes.len() > 0 {
      let pages-info = ()
      for p in range(1, total-pages + 1) {
        let frame = frames.find(f => f.value.page == p)
        let p-m = if frame == none { deixis-utils.get-page-margins(p) } else { frame.value.margins }
        let p-height = if frame == none { page.height } else { frame.value.height }
        pages-info.push((
          idx: p - 1,
          page: p,
          binding: if frame == none { deixis-utils.get-page-binding() } else { frame.value.binding },
          top: deixis-utils.resolve-len(p-m.top),
          bottom: deixis-utils.resolve-len(r-len(p-height, deixis-utils.default-page-size.height))
            - deixis-utils.resolve-len(p-m.bottom),
          l-space: deixis-utils.resolve-len(p-m.left),
          r-space: deixis-utils.resolve-len(p-m.right),
        ))
      }

      let predicted-notes = _deixis-predict-cascade(
        // A later page's marks cannot affect this page's accepted notes or
        // outgoing sides: queued spill candidates precede that page's marks.
        // Keep future frames for real spill destinations, but avoid planning
        // future originals again on every preceding page.
        all-page-notes.filter(n => n.mark-page <= current-page),
        pages-info,
        deixis-utils.text-direction(text.dir, text.lang),
        c-margin-layout,
        min-margin-width: c-min-margin-width,
        cascade-breaker: true,
        measure-anchors: measure-anchors,
      )

      active-notes = predicted-notes.filter(x => x.block-idx == current-page - 1)
      pushed-notes += predicted-notes.filter(x => x.mark-page == current-page and x.block-idx > current-page - 1)
    }

    if active-notes.len() > 0 or pushed-notes.len() > 0 {
      // Default to global stack
      let page-layout = c-margin-layout
      let page-min-width = c-min-margin-width

      if active-notes.len() > 0 {
        let first-note = active-notes.first().note-data
        page-layout = active-notes.first().at("_margin-layout", default: first-note.at("margin-layout", default: c-margin-layout))
        page-min-width = first-note.at("min-margin-width", default: c-min-margin-width)
      }

      let output = _deixis-margin-batch-output(
        page-layout,
        active-notes,
        top-bound,
        bottom-bound,
        start-x,
        width-val,
        bottom-bound,
        l-space-abs,
        r-space-abs,
        current-page,
        min-margin-width: page-min-width,
        pushed-notes: pushed-notes,
      )
      evidence += output.evidence
      commands += output.commands
    }
  }

  // block level
  let all-block-notes = processed-notes.filter(n => n.note-data.target-id != "page")
  if all-block-notes.len() > 0 {
    let page-frames = (:)
    for f in frames { page-frames.insert(str(f.value.page), f.value) }
    let starts-dict = (:)
    for s in query(<deixis-block-start>) { starts-dict.insert(s.value.id, s) }
    let ends-dict = (:)
    for e in query(<deixis-block-end>) { ends-dict.insert(e.value.id, e) }
    let rights-dict = (:)
    for r in query(<deixis-block-right>) { rights-dict.insert(r.value.id, r) }

    let target-groups = (:)
    for (id, s) in starts-dict {
      let rid = s.value.at("render-id", default: none)
      if rid != none {
        if rid not in target-groups { target-groups.insert(rid, ()) }
        target-groups
          .at(rid)
          .push((id: id, start: s, end: ends-dict.at(id, default: none), right: rights-dict.at(id, default: none)))
      }
    }

    for (rid, blocks) in target-groups {
      let notes = all-block-notes.filter(n => n.note-data.target-id == rid)
      if notes.len() == 0 { continue }
      let sorted-blocks = blocks.sorted(key: b => (b.start.location().page(), b.start.location().position().y))

      let first-note-data = notes.first().note-data
      let b-margin-layout = first-note-data.at("margin-layout", default: c-margin-layout)
      let b-min-margin-width = first-note-data.at("min-margin-width", default: c-min-margin-width)

      let blocks-info = ()
      let valid = true
      for b in sorted-blocks {
        if b.end == none or b.right == none {
          valid = false
          break
        }
        blocks-info += _deixis-block-segments(b.start, b.end, b.right, page-frames)
      }
      if not valid { continue }

      let predicted-notes = _deixis-predict-cascade(
        notes,
        blocks-info,
        deixis-utils.text-direction(text.dir, text.lang),
        b-margin-layout,
        min-margin-width: b-min-margin-width,
        cascade-breaker: false,
        measure-anchors: measure-anchors,
      )

      for (i, b-info) in blocks-info.enumerate() {
        if b-info.page != current-page { continue }
        let active-notes = predicted-notes.filter(x => x.block-idx == i)
        let pushed-notes = predicted-notes.filter(x => (
          x.mark-block == i and blocks-info.at(x.block-idx).page > current-page
        ))

        if active-notes.len() > 0 or pushed-notes.len() > 0 {
          let layout = if active-notes.len() > 0 { active-notes.first().at("_margin-layout", default: b-margin-layout) } else { b-margin-layout }
          let output = _deixis-margin-batch-output(
            layout,
            active-notes,
            b-info.top,
            b-info.bottom,
            b-info.start-x,
            b-info.text-width,
            b-info.bottom,
            b-info.l-space,
            b-info.r-space,
            current-page,
            min-margin-width: b-min-margin-width,
            pushed-notes: pushed-notes,
          )
          evidence += output.evidence
          commands += output.commands
        }
      }
    }
  }
  (evidence: evidence, commands: commands)
}

/// A ```ref #deixis-margin-note-body``` with default `side: "outside", mark-align-strictness: "loose"`.
/// Uses margin-note configuration and query type. Explicit arguments override
/// the preset; mark-align-strictness: auto inherits configured strictness.
#let deixis-sidenote-body = deixis-margin-note-body.with(side: "outside", mark-align-strictness: "loose")

/// A ```ref #deixis-margin-note``` with default `side: "outside", mark-align-strictness: "loose"`.
/// Uses margin-note configuration and query type, without a separate sidenote
/// engine. Set mark-align-strictness: auto to inherit configured strictness.
#let deixis-sidenote = deixis-margin-note.with(side: "outside", mark-align-strictness: "loose")

/// A review comment: a ```ref #deixis-margin-note``` in the `"review"` series
/// with lettered markers and `author`/`status` fields. Remove these comments
/// from a final copy with `deixis-set(omit: (series: ("review",)))`.
///
/// ```example
/// The #deixis-comment(author: "Ada", status: "open")[proposed method][
///   State the conditions under which this claim holds.]
/// preserves the argument.
/// ```
///
/// - author (none, str, content): Stored as `note.data.author`; shown in the header.
/// - status (none, str, content): Stored as `note.data.status`; shown in the header.
/// - data (dictionary): Further annotation fields, merged with author/status.
/// - series (str): The counter/omission series. Defaults to `"review"`.
/// - numbering (auto, none, str, function, dictionary): Marker numbering; letters by default.
/// - header (auto, none, function): Body heading. auto shows the present fields in bold, joined by " · ";
///   a function receives the merged data dictionary.
/// - ..args (arguments): `[comment]` or `[passage][comment]` and other margin-note options. Creates an original; of is rejected.
///
/// -> content
#let deixis-comment(
  /// Stored as `note.data.author`; shown in the header.
  /// -> none | str | content
  author: none,
  /// Stored as `note.data.status`; shown in the header.
  /// -> none | str | content
  status: none,
  /// Further annotation fields, merged with author/status.
  /// -> dictionary
  data: (:),
  /// The counter/omission series.
  /// -> str
  series: "review",
  /// Marker numbering; letters keep comments apart from source notes.
  /// `none` disables automatic markers and counter allocation.
  /// -> auto | none | str | function | dictionary
  numbering: "A",
  /// Body heading: auto, none, or a function of the merged data.
  /// -> auto | none | function
  header: auto,
  ..args,
) = {
  assert("of" not in args.named(),
    message: "deixis: deixis-comment creates an original; attach a body with deixis-margin-note-body(of: ...).")
  let pos = args.pos()
  assert(pos.len() in (1, 2), message: "deixis: deixis-comment expects [passage][comment] or [comment].")
  // Every comment carries both fields so queries can filter without defaults.
  let fields = data + (author: author, status: status)
  let heading = if header == auto {
    let parts = (author, status).filter(it => it != none)
    if parts.len() > 0 { [#strong(parts.join[ · ]) \ ] }
  } else if header != none { [#header(fields) \ ] }
  deixis-margin-note(..args.named(), data: fields, series: series, numbering: numbering,
    ..pos.slice(0, -1), [#heading#pos.last()])
}
