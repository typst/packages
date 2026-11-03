#import "../core/internal.typ": *
#import "../render/commands.typ": _deixis-paint-command
#import "../marks/inline.typ": *
#import "../marks/region.typ": *
#import "../routing/frames.typ": _deixis-body-corners
#import "../routing/document-policy.typ": _deixis-capture-routing
#import "../core/native.typ": *

/// A standalone body content of an inset note.
///
/// Body content is preserved. Built-in single renderers fold source indentation
/// with native weak marker spacing and retain explicit paragraph/line breaks.
///
/// The body of inset notes are placed at precise geometric coordinates relative an anchor (its mark or a specific pin).
/// They are perfect for callouts.
///
/// ```example
/// The artist spent months wandering the dense pine forests, completely captivated by the local #deixis-inline-mark(id: <apricharity>)[apricharity].
///
/// #deixis-inset-note-body(
///   of: <apricharity>,
///   dx: 2.5em,
///   dy: 2em,
/// )[
///   warmth of the sun in winter.
/// ]
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
/// - width (auto, length, relative): The width of the inset note body.
/// - placement (none, function): A custom floating placement function (e.g., Typst's native `place`).
/// - dx (none, length): Absolute horizontal offset for placing the note.
/// - dy (none, length): Absolute vertical offset for placing the note.
/// - anchor (dictionary): A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
/// - anchor-pin (none, str, dictionary, array): Pin names or structured targets; selected matches supply bounds and the first selected pin determines the overlay page.
/// - layer (auto, str): The rendering layer context. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
/// - ..args (arguments): Additional arguments are rejected; put custom container options in `container-args`.
///
/// -> content
#let deixis-inset-note-body(
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
  /// #deixis-inset-note(dx: 4em, dy: 3em, layer: "flow", connector: (route: "right-angle", heads: "stealth"))[Marked][A connected note.]
  /// ```
  ///
  /// -> auto | none | str | dictionary
  connector: auto,
  /// The width of the inset note body.
  /// -> auto | length | relative
  width: auto,
  /// A custom floating placement function (e.g., Typst's native `place`).
  ///
  /// ```example
  /// #let place-func(it) = {
  ///   std.place(top + right, it)
  /// }
  /// #deixis-inset-note(placement: place-func)[Mark][Inset note placed by `placement`.]
  /// ```
  ///
  /// -> none | function
  placement: none,
  /// Absolute horizontal offset for placing the note.
  ///
  /// ```example
  /// #deixis-inset-note(dx: 10pt, dy: 10pt)[Mark][Inset note placed with `dx`, `dy`.]
  /// ```
  ///
  /// -> none | length
  dx: none,
  /// Absolute vertical offset for placing the note.
  ///
  /// See `deixis-inset-note.dx`.
  ///
  /// -> none | length
  dy: none,
  /// A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
  ///
  /// ```example
  /// #deixis-inset-note(
  ///   anchor: (mark: bottom + right, body: top + left),
  ///   dx: 0pt, dy: 0pt)[Mark][Inset note anchored to the mark.]
  /// ```
  ///
  /// -> dictionary
  anchor: (mark: horizon + right, body: horizon + left),
  /// A specific `#deixis-pin` name to anchor the inset note to.
  ///
  /// ```example
  /// #deixis-inset-note(
  ///   anchor-pin: "anchor-pin",
  ///   anchor: (mark: horizon, body: horizon + left),
  ///   layer: auto,
  ///   dx: 0pt, dy: 0pt)[Mark][Inset note anchored to a pin.]
  ///
  /// #lorem(3)#deixis-pin("anchor-pin")
  /// ```
  ///
  /// See `deixis-pin`.
  ///
  /// Structured targets accept name, scope, select (all/first/last/unique), and
  /// page. Flow placement filters to its declaration page before selecting.
  /// -> none | str | dictionary | array
  anchor-pin: none,
  /// The rendering layer context. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// ```warning
  /// Similar to `deixis-region-mark.layer`, the `"flow"` layer will trigger a `#parbreak` and disrupt your paragraph.
  /// However, it is still recommended to use `layer: "flow"` whenever possible for stability.
  /// ```
  ///
  /// -> auto | str
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
    if args.pos().len() > 0 { panic("deixis: #deixis-inset-note-body accepts at most 1 positional argument [body].") }
    _deixis-check-container-options(container-args, extra: args.named())
    let styles = (stroke: stroke, fill: fill, radius: radius)

    let series = _deixis-body-series(of, series, fallback: "default")

    if placement != none and anchor-pin != none {
      panic("deixis: `placement` cannot be used in combination with `anchor-pin`.")
    }

    let render-celibate(sys, celibate-id) = {
      let accent = _deixis-registry(sys).notes.at(str(celibate-id), default: (:)).at("accent", default: sys.at("annotation-accent", default: none))
      let sys = _deixis-accent-context(sys, accent)
      let resolved = _deixis-resolve-target(sys, target)

      let b-styles = _deixis-resolve-body-styles(sys, "inset-note", ..styles)

      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "inset-note")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "inset-note")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "inset-note")
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "inset-note")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "inset-note")

      let c-layer = _deixis-resolve-typed-param(sys, layer, "layer", "inset-note", component: "body")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inset-note")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inset-note")

      let note-data = (
        (
          body-type: "inset-note",
          z-index: _deixis-resolve-z-index(sys, z-index, "inset-note", "body"),
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
          marker-gap: c-marker-gap,
          container-func: active-container,
          container-args: container-args,
          styles: b-styles,
        )
          + (
            has-inline-box: false,
            mark-type: none,
            text-size: text.size,
            marker-width: 0pt,
            layer: c-layer,
            placement: placement,
            dx: dx,
            dy: dy,
            anchor: anchor,
            anchor-pin: anchor-pin,
            render-single: active-renderer,
            width: width,
          )
      )

      // HTML export lists inset bodies after the document instead.
      if c-layer == "flow" and _std-target() == "html" {
        [#_deixis-metadata(note-data, <deixis-inset-note>)]
      } else if c-layer == "flow" {
        let meta = [#_deixis-metadata(note-data, <deixis-inset-note>)]
        let c-inner-width = if width == auto { auto } else { 100% }
        let rendered-content = _deixis-render-single(note-data, inner-width: c-inner-width, gap: c-gap)

        let measured-size = measure(block(width: width,
          _deixis-render-single(note-data + (disable-links: true), inner-width: if width == auto { auto } else { 100% })))
        let final-rendered = block(width: width, {
          place(top + left, meta)
          _deixis-body-corners(celibate-id)
          rendered-content
        })

        if type(placement) == function {
          placement(final-rendered)
        } else if anchor-pin != none or dx != none or dy != none {
          let dx = if dx in (none, auto) { 0pt } else { dx }
          let dy = if dy in (none, auto) { 0pt } else { dy }
          _deixis-place-anchored(
            final-rendered,
            body-size: measured-size,
            dx: dx,
            dy: dy,
            anchor: anchor,
            internal-id: none,
            pin: anchor-pin,
            pin-page: here().page(),
          )
        } else {
          final-rendered
        }
      } else {
        let dummy-lbl = _std-label("deixis-mark-" + str(celibate-id))
        note-data.insert("mark-lbl", dummy-lbl)
        note-data.insert("backlink-mark-lbl", none)
        [#metadata(none)#dummy-lbl#_deixis-metadata(note-data, <deixis-inset-note>)]
      }
    }

    if of == none {
      return {
        prepared.declarations
        if id != none { deixis-system.update(sys => _deixis-register-standalone(sys, id, body, "inset-note", data: data)) }
        _std-counter("deixis-celibate-note").step()
        _deixis-setup-context(() => {
          let uid = if id == none { "celibate-" + str(_std-counter("deixis-celibate-note").get().first()) } else { "id-" + str(id) }
          if id == none { _deixis-palette-anonymous(deixis-system.get(), sys => render-celibate(sys, uid)) }
          else { render-celibate(deixis-system.get(), uid) }
        })
      }
    }

    prepared.declarations
    deixis-system.update(sys => _deixis-register-body(sys, of, body, "inset-note"))
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
      let marker-position = reg.at("marker-position", default: none)

      let mark-lbl = _std-label("deixis-mark-" + str(internal-id))
      let body-lbl = _std-label("deixis-body-" + str(internal-id))

      let dest-top-lbl = _std-label("deixis-dest-top-" + str(internal-id))
      let dest-bot-lbl = _std-label("deixis-dest-bot-" + str(internal-id))
      let dest-left-lbl = _std-label("deixis-dest-left-" + str(internal-id))
      let dest-right-lbl = _std-label("deixis-dest-right-" + str(internal-id))

      let saved-styles = reg.at("styles", default: (:))
      let merged-styles = _deixis-merge-styles(saved-styles, styles)

      let b-styles = _deixis-resolve-body-styles(
        sys,
        "inset-note",
        ..merged-styles,
      )
      let l-styles = _deixis-resolve-connector-styles(
        sys,
        "inset-note",
        stroke: merged-styles.at("stroke", default: auto),
        radius: merged-styles.at("radius", default: auto),
      )

      let mark-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "marker-style",
        "inset-note",
        component: "mark",
      )
      let body-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "marker-style",
        "inset-note",
        component: "body",
      )
      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "inset-note")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "inset-note")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "inset-note")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "inset-note")

      let connector-data = _deixis-connector-options(sys, "inset-note", connector,
        via: none,
        stroke: l-styles.stroke, radius: l-styles.radius,
        z-index: _deixis-inherited-z-index(reg, z-index))
      let c-link = connector-data.route
      let c-link-ports = connector-data.ports
      let c-link-marks = connector-data.marks
      if reg.at("mark-type", default: "inline") == "phantom" {
        if connector == auto { c-link = "none" }
      }

      let c-layer = _deixis-resolve-typed-param(sys, layer, "layer", "inset-note", component: "body")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inset-note")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inset-note")

      let has-inline-box = if reg.mark-type == "inline" {
        reg.inline-mode == "box" and reg.at("has-mark-body", default: false)
      } else { false }

      let note-data = (
        (
          body-type: "inset-note",
          z-index: _deixis-resolve-z-index(sys, _deixis-inherited-z-index(reg, z-index), "inset-note", "body"),
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
          marker-gap: c-marker-gap,
          container-func: active-container,
          container-args: container-args,
          styles: b-styles,
        )
          + (
            dest-top-lbl: dest-top-lbl,
            dest-bot-lbl: dest-bot-lbl,
            dest-left-lbl: dest-left-lbl,
            dest-right-lbl: dest-right-lbl,
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
            has-inline-box: has-inline-box,
            mark-type: reg.at("mark-type", default: "inline"),
            text-size: text.size,
            marker-width: if marker-str != none { measure(mark-marker-style(marker-str)).width } else { 0pt },
            marker-position: marker-position,
            layer: c-layer,
            placement: placement,
            dx: dx,
            dy: dy,
            anchor: anchor,
            anchor-pin: anchor-pin,
            render-single: active-renderer,
            width: width,
          )
      )

      note-data += _deixis-capture-routing(connector-data + (route: c-link))
      let meta = [#_deixis-metadata(note-data, <deixis-inset-note>)]

      if c-layer == "flow" and _std-target() != "html" {
        let rendered-content = _deixis-render-single(note-data, inner-width: if width == auto { auto } else { 100% })
        let measured-size = measure(block(width: width,
          _deixis-render-single(note-data + (disable-links: true), inner-width: if width == auto { auto } else { 100% })))
        let final-rendered = block(width: width, {
          place(top + left, meta)
          _deixis-body-corners(internal-id)
          place(top + center, [#metadata(none)#dest-top-lbl])
          place(bottom + center, [#metadata(none)#dest-bot-lbl])
          place(horizon + left, [#metadata(none)#dest-left-lbl])
          place(horizon + right, [#metadata(none)#dest-right-lbl])
          rendered-content
        })

        if type(placement) == function {
          placement(final-rendered)
        } else if anchor-pin != none or dx != none or dy != none {
          let dx = if dx in (none, auto) { 0pt } else { dx }
          let dy = if dy in (none, auto) { 0pt } else { dy }
          _deixis-place-anchored(
            final-rendered,
            body-size: measured-size,
            dx: dx,
            dy: dy,
            anchor: anchor,
            internal-id: internal-id,
            pin: anchor-pin,
            pin-page: here().page(),
          )
        } else {
          [#final-rendered]
        }
      } else {
        [#meta]
      }
    })
  }
  _deixis-replayable(none, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index, connector: connector)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}

/// A wrapper for generating inset notes.
///
/// This function creates a mark in the text and delegates the body to ```ref #deixis-inset-note-body```.
///
/// ```example
/// The city council has voted to pave the trail with
/// #deixis-inset-note(dx: 10pt, dy: 30pt, width: 100pt)[
///   permeable pavement
/// ][
///   A porous surface that lets rainwater filter directly into the ground.
/// ].
/// ```
///
/// - ..args (arguments): Accepts up to two positional arguments: `[mark][body]`. All named arguments are forwarded to ```ref #deixis-inset-note-body```.
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
/// - inline (bool): If `true`, force the region mark into an inline box.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - width (auto, length, relative): The width of the inset note body.
/// - placement (none, function): A custom floating placement function (e.g., Typst's native `#std.place`).
/// - dx (none, length): Absolute horizontal offset for placing the note.
/// - dy (none, length): Absolute vertical offset for placing the note.
/// - anchor (dictionary): A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
/// - anchor-pin (none, str, dictionary, array): Pin names or structured targets selecting anchor bounds.
/// - layer (auto, str, dictionary): Rendering layer for the region mark and/or the body. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
///
/// -> content
#let deixis-inset-note(
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
  /// Mark marker placement.
  ///
  /// See `deixis-inline-mark.marker-position` and `deixis-region-mark.marker-position`.
  ///
  /// -> auto | alignment | dictionary
  marker-position: auto,
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
  /// #deixis-inset-note(dx: 4em, dy: 3em, layer: "flow", connector: (route: "right-angle", heads: "stealth"))[Marked][A connected note.]
  /// ```
  ///
  /// -> auto | none | str | dictionary
  connector: auto,
  /// The width of the inset note body.
  /// -> auto | length | relative
  width: auto,
  /// A custom floating placement function (e.g., Typst's native `#std.place`).
  ///
  /// See `deixis-inset-note-body.placement`.
  ///
  /// -> none | function
  placement: none,
  /// Absolute horizontal offset for placing the note.
  ///
  /// See `deixis-inset-note-body.dx`.
  ///
  /// -> none | length
  dx: none,
  /// Absolute vertical offset for placing the note.
  ///
  /// See `deixis-inset-note-body.dy`.
  ///
  /// -> none | length
  dy: none,
  /// A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
  ///
  /// See `deixis-inset-note-body.anchor`.
  ///
  /// -> dictionary
  anchor: (mark: horizon + right, body: horizon + left),
  /// A specific `#deixis-pin` name to anchor the inset note to.
  ///
  /// See `deixis-inset-note-body.anchor-pin`.
  ///
  /// -> none | str | dictionary | array
  anchor-pin: none,
  /// Rendering layer for the region mark and/or the body. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// See `deixis-region-mark.layer` and `deixis-inset-note-body.layer`.
  ///
  /// ```tip
  /// Since both `deixis-region-mark` and `deixis-inset-note-body` shares this parameter, you can pass `layer: (mark: "flow", body: "foreground")` to assign different layer to each component.
  /// ```
  ///
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
) = {
  let render-with-order-hints() = {
    _deixis-check-identities(id, of)
    _deixis-check-note-data(data, of: of)
    let pos = args.pos()
    if pos.len() > 2 { panic("deixis: #deixis-inset-note accepts at most 2 positional arguments: [mark][body]") }
    _deixis-check-attached-wrapper(of, pos, mark-options: (
      numbering: numbering, series: series, marker: marker, mark-type: mark-type,
      marker-position: marker-position, inline-mode: inline-mode,
      pins: if pins == () { auto } else { pins },
      padding: padding, region-shape: region-shape,
      inline: if inline == false { auto } else { inline },
    ))
    _deixis-check-container-options(container-args, extra: args.named())
    let mark-content = if pos.len() > 1 { pos.first() } else { none }
    let note-body = if pos.len() > 0 { pos.last() } else { none }

    let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

    if of != none {
      return deixis-inset-note-body(
        note-body,
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
        placement: placement,
        dx: dx,
        dy: dy,
        anchor: anchor,
        anchor-pin: anchor-pin,
        layer: layer,
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
          id: target-id, _family: "inset-note",
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
          id: target-id, _family: "inset-note",
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
          id: target-id, _family: "inset-note",
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
      deixis-inset-note-body(
        note-body,
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
        placement: placement,
        dx: dx,
        dy: dy,
        anchor: anchor,
        anchor-pin: anchor-pin,
        layer: layer,
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

// Inset note overlay
#let _deixis-inset-paint-commands(layer: "foreground") = {
  let notes = query(<deixis-inset-note>).filter(it => (
    type(it.value) == dictionary and it.value.at("mark-lbl", default: none) != none
      and not _deixis-is-hidden(it.value)
  ))
  let commands = ()
  let current-page = here().page()
  let pin-index = _deixis-pin-index()

  for n in notes {
    let data = n.value
    let n-layer = data.at("layer", default: "foreground")

    let target_page = n.location().page()
    if data.anchor-pin != none {
      let targets = if type(data.anchor-pin) == array { data.anchor-pin } else { (data.anchor-pin,) }
      let pin-elems = _deixis-pins-for(pin-index, targets)
      if pin-elems.len() > 0 {
        target_page = pin-elems.first().location().page()
      }
    }

    if n-layer == layer and current-page == target_page {
      commands.push(_deixis-paint-command("inset", data.internal-id, () => {
        let rendered-content = _deixis-render-single(data, inner-width: if data.width == auto { auto } else { 100% })
        let dest-top-lbl = data.at("dest-top-lbl", default: none)

        let measured-size = measure(block(width: data.width,
          _deixis-render-single(data + (disable-links: true), inner-width: if data.width == auto { auto } else { 100% })))
        let final-rendered = block(width: data.width, {
          _deixis-body-corners(data.internal-id)
          if dest-top-lbl != none {
            place(top + center, [#metadata(none)#dest-top-lbl])
            place(bottom + center, [#metadata(none)#data.dest-bot-lbl])
            place(horizon + left, [#metadata(none)#data.dest-left-lbl])
            place(horizon + right, [#metadata(none)#data.dest-right-lbl])
          }
          rendered-content
        })

        if type(data.placement) == function {
          box((data.placement)(final-rendered))
        } else if data.dx != none or data.dy != none {
          context _deixis-place-anchored(
            final-rendered,
            body-size: measured-size,
            dx: if data.dx == none { 0pt } else { data.dx },
            dy: if data.dy == none { 0pt } else { data.dy },
            anchor: data.anchor,
            internal-id: data.internal-id,
            pin: data.anchor-pin,
          )
        } else {
          context _deixis-place-anchored(
            final-rendered,
            body-size: measured-size,
            dx: 0pt,
            dy: 0pt,
            anchor: data.anchor,
            internal-id: data.internal-id,
            pin: data.anchor-pin,
          )
        }
      }, priority: data.at("z-index", default: 0)))
    }
  }
  commands
}
