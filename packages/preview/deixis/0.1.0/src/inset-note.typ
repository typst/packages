#import "core.typ": *
#import "inline-note.typ": *
#import "region-note.typ": *

/// A standalone body content of an inset note.
///
/// The body of inset notes are placed at precise geometric coordinates relative an anchor (its mark or a specific pin).
/// They are perfect for callouts.
///
/// ```example
/// The artist spent months wandering the dense pine forests, completely captivated by the local #deixis-inline-mark(id: <apricharity>)[apricharity].
///
/// #deixis-inset-note-body(
///   id: <apricharity>,
///   dx: 2.5em,
///   dy: 2em,
/// )[
///   warmth of the sun in winter.
/// ]
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): A unique identifier linking this body to its corresponding mark.
/// - target (auto, int, label, str): The specific block/minipage render context this note belongs to.
/// - series (auto, str): The counter series this note belongs to.
/// - label (none, label): An optional `label` to attach to the rendered body block.
/// - marker-style (auto, function): A custom styling function for the marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - link (auto, str): The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
/// - link-waypoints (none, array): An array of intermediate coordinate offsets to route the connector line through.
/// - link-ports (auto, array, dictionary): Defines the exact exit/entry ports for the connector line.
/// - link-marks (auto, str): The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
/// - width (auto, length, relative): The width of the inset note body.
/// - placement (none, function): A custom floating placement function (e.g., Typst's native `place`).
/// - dx (none, length): Absolute horizontal offset for placing the note.
/// - dy (none, length): Absolute vertical offset for placing the note.
/// - anchor (dictionary): A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
/// - anchor-pin (none, str): A specific `#deixis-pin` name to anchor the inset note to.
/// - layer (auto, str): The rendering layer context. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the body block.
/// - ..args (arguments): Only accepts named arguments, which are forwarded to `container-func`.
///
/// -> content
#let deixis-inset-note-body(
  /// The actual text or content of the note.
  /// -> content
  body,
  /// A unique identifier linking this body to its corresponding mark.
  /// -> none | str | label
  id: none,
  /// The specific block/minipage render context this note belongs to.
  /// -> auto | int | label | str
  target: auto,
  /// The counter series this note belongs to.
  /// -> auto | str
  series: auto,
  /// An optional `label` to attach to the rendered body block.
  /// -> none | label
  label: none,
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
  /// The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
  /// -> auto | str
  link: auto,
  /// An array of intermediate coordinate offsets to route the connector line through.
  /// -> none | array
  link-waypoints: none,
  /// Defines the exact exit/entry ports for the connector line.
  /// -> auto | array | dictionary
  link-ports: auto,
  /// The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
  /// -> auto | str
  link-marks: auto,
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
  /// See @deixis-inset-note.dx.
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
  ///   layer: "flow",
  ///   dx: 0pt, dy: 0pt)[Mark][Inset note anchored to a pin.]
  ///
  /// #lorem(3)#deixis-pin("anchor-pin")
  /// ```
  ///
  /// See @deixis-pin.
  ///
  /// -> none | str
  anchor-pin: none,
  /// The rendering layer context. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// ```warning
  /// Similar to @deixis-region-mark.layer, the `"flow"` layer will trigger a `#parbreak` and disrupt your paragraph.
  /// However, it is still recommended to use `layer: "flow"` whenever possible for stability.
  /// ```
  ///
  /// -> auto | str
  layer: "flow",
  /// A custom render function for the inner layout of the body.
  /// -> auto | function
  render-single: auto,
  /// A custom container wrapper for the body block.
  /// -> auto | function
  container-func: auto,
  /// Only accepts named arguments, which are forwarded to `container-func`.
  /// -> arguments
  ..args,
) = {
  if args.pos().len() > 0 { panic("deixis: #deixis-inset-note-body accepts at most 1 positional argument [body].") }
  let styles = (stroke: stroke, fill: fill, radius: radius) + args.named()

  let series = if series == auto { "default" } else { series }

  if placement != none and anchor-pin != none {
    panic("deixis: `placement` cannot be used in combination with `anchor-pin`.")
  }
  if (
    placement != none
      and layer != auto
      and (
        layer != "flow"
          or (
            type(layer) == dictionary
              and _deixis-resolve-typed-param(sys, layer, "layer", "inset-note", component: "body") != "flow"
          )
      )
  ) {
    panic("deixis: custom `placement` can only be used with layer: 'flow'.")
  }

  let render-celibate(sys, celibate-id) = {
    let body = deixis-utils._deixis-trim-content(body)
    let resolved = _deixis-resolve-target(sys, target)

    let b-styles = _deixis-resolve-body-styles(sys, "inset-note", ..styles)

    let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "inset-note")
    let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "inset-note")

    let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "inset-note")
    let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "inset-note")
    let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "inset-note")

    let c-layer = if placement == none {
      _deixis-resolve-typed-param(sys, layer, "layer", "inset-note", component: "body")
    } else {
      "flow"
    }

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inset-note")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inset-note")

    let note-data = (
      (
        internal-id: celibate-id,
        target-id: resolved.render-id,
        inst-id: resolved.inst-id,
        series: series,
        count: none,
        marker-str: none,
        body: body,
        mark-lbl: none,
        body-lbl: none,
        label: label,
        mark-marker-style: auto,
        body-marker-style: auto,
        body-style: c-body-style,
        backlink: c-backlink,
        indent: c-indent,
        marker-gap: c-marker-gap,
        container-func: active-container,
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

    if c-layer == "flow" {
      let meta = [#metadata(note-data)<deixis-inset-note>]
      let c-inner-width = if width == auto { auto } else { 100% }
      let rendered-content = active-renderer(note-data, inner-width: c-inner-width, gap: c-gap)

      let final-rendered = block(width: width, {
        place(top + left, meta)
        rendered-content
      })

      if type(placement) == function {
        placement(final-rendered)
      } else if anchor-pin != none or dx != none or dy != none {
        let dx = if dx in (none, auto) { 0pt } else { dx }
        let dy = if dy in (none, auto) { 0pt } else { dy }
        deixis-place-anchored(
          final-rendered,
          dx: dx,
          dy: dy,
          anchor: anchor,
          internal-id: none,
          pin: anchor-pin,
        )
      } else {
        final-rendered
      }
    } else {
      let dummy-lbl = std.label("deixis-mark-" + str(celibate-id))
      note-data.insert("mark-lbl", dummy-lbl)
      [#metadata(none)#dummy-lbl#metadata(note-data)<deixis-inset-note>]
    }
  }

  if id == none {
    return [
      #std.counter("deixis-celibate-note").step()
      #context {
        _deixis-check-setup-state()
        render-celibate(deixis-system.get(), "celibate-" + str(std.counter("deixis-celibate-note").get().first()))
      }
    ]
  }

  let state-updater = deixis-system.update(sys => {
    let current-target-uid = if id == deixis-auto-id { sys.at("last-auto-uid", default: none) } else {
      sys.at("id-index", default: (:)).at(str(id), default: none)
    }
    if current-target-uid == none { return sys }

    let new-notes = sys.at("notes", default: (:))
    let new-label-index = sys.at("label-index", default: (:))

    let payload = new-notes.at(current-target-uid)
    payload.insert("body-type", "inset-note")
    payload.insert("body", body)
    new-notes.insert(current-target-uid, payload)

    if label != none {
      let lbl-str = if type(label) == str { label } else { str(label) }
      if lbl-str in new-label-index and new-label-index.at(lbl-str) != current-target-uid {
        panic("deixis: Duplicate note label detected: '" + lbl-str + "'.")
      }
      new-label-index.insert(lbl-str, current-target-uid)
    }

    return (..sys, notes: new-notes, label-index: new-label-index)
  })

  state-updater
  context {
    _deixis-check-setup-state()
    let body = deixis-utils._deixis-trim-content(body)

    let sys = deixis-system.get()
    let final-sys = deixis-system.final()

    let target-uid = if id == deixis-auto-id { sys.at("last-auto-uid", default: none) } else {
      final-sys.at("id-index", default: (:)).at(str(id), default: none)
    }
    let reg = if target-uid != none { final-sys.at("notes", default: (:)).at(target-uid, default: none) } else {
      none
    }

    if reg == none {
      return [
        #std.counter("deixis-celibate-note").step()
        #render-celibate(sys, "celibate-" + str(std.counter("deixis-celibate-note").get().first()))
      ]
    }

    let internal-id = reg.internal-id
    let resolved = _deixis-resolve-target(sys, if target == auto { reg.at("target-id", default: 0) } else { target })

    let series = reg.at("series", default: series)
    let count = reg.count
    let marker-str = _deixis-query-marker-str(reg)
    let marker-position = reg.at("marker-position", default: none)

    let mark-lbl = std.label("deixis-mark-" + str(internal-id))
    let body-lbl = std.label("deixis-body-" + str(internal-id))

    let dest-top-lbl = std.label("deixis-dest-top-" + str(internal-id))
    let dest-bot-lbl = std.label("deixis-dest-bot-" + str(internal-id))
    let dest-left-lbl = std.label("deixis-dest-left-" + str(internal-id))
    let dest-right-lbl = std.label("deixis-dest-right-" + str(internal-id))

    let saved-styles = reg.at("styles", default: (:))
    let merged-styles = _deixis-merge-styles(saved-styles, styles)

    let b-styles = _deixis-resolve-body-styles(
      sys,
      "inset-note",
      ..merged-styles,
    )
    let l-styles = _deixis-resolve-link-styles(
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

    let c-link = _deixis-resolve-typed-param(sys, link, "link", "inset-note")
    let c-link-ports = deixis-utils._deixis-normalize-ports(link-ports)
    let c-link-marks = _deixis-resolve-typed-param(sys, link-marks, "link-marks", "inset-note")
    if reg.at("mark-type", default: "inline") == "phantom" {
      if link == auto { c-link = "none" }
    }

    let c-layer = if placement == none {
      _deixis-resolve-typed-param(sys, layer, "layer", "inset-note", component: "body")
    } else {
      "flow"
    }

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inset-note")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inset-note")

    let has-inline-box = if reg.mark-type == "inline" {
      reg.inline-mode == "box" and reg.at("has-mark-body", default: false)
    } else { false }

    let note-data = (
      (
        internal-id: internal-id,
        target-id: resolved.render-id,
        inst-id: resolved.inst-id,
        series: series,
        count: count,
        marker-str: marker-str,
        body: body,
        mark-lbl: mark-lbl,
        body-lbl: body-lbl,
        label: label,
        mark-marker-style: mark-marker-style,
        body-marker-style: body-marker-style,
        body-style: c-body-style,
        backlink: c-backlink,
        indent: c-indent,
        marker-gap: c-marker-gap,
        container-func: active-container,
        styles: b-styles,
      )
        + (
          dest-top-lbl: dest-top-lbl,
          dest-bot-lbl: dest-bot-lbl,
          dest-left-lbl: dest-left-lbl,
          dest-right-lbl: dest-right-lbl,
          link: c-link,
          link-stroke: l-styles.stroke,
          link-radius: l-styles.radius,
          link-waypoints: link-waypoints,
          link-ports: c-link-ports,
          link-marks: c-link-marks,
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

    let meta = [#metadata(note-data)<deixis-inset-note>]

    if c-layer == "flow" {
      let rendered-content = active-renderer(note-data, inner-width: if width == auto { auto } else { 100% })
      let final-rendered = block(width: width, {
        place(top + left, meta)
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
        deixis-place-anchored(
          final-rendered,
          dx: dx,
          dy: dy,
          anchor: anchor,
          internal-id: internal-id,
          pin: anchor-pin,
        )
      } else {
        [#final-rendered]
      }
    } else {
      [#meta]
    }
  }
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
/// - id (none, str, label): A unique identifier linking an existing mark to the body internally. If `none`, a mark will be created.
/// - numbering (auto, str, function): The numbering style for the marker.
/// - marker (auto, content): A hardcoded marker override.
/// - target (int, label, str): The specific block/minipage counter this note belongs to.
/// - series (str): The counter series this note belongs to. Defaults to `"default"`.
/// - label (none, label): An optional `label` to attach to the rendered body block.
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
/// - link (auto, str): The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
/// - link-waypoints (none, array): An array of intermediate coordinate offsets to route the connector line through.
/// - link-ports (auto, array, dictionary): Defines the exact exit/entry ports for the connector line.
/// - link-marks (auto, str): The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
/// - width (auto, length, relative): The width of the inset note body.
/// - placement (none, function): A custom floating placement function (e.g., Typst's native `#std.place`).
/// - dx (none, length): Absolute horizontal offset for placing the note.
/// - dy (none, length): Absolute vertical offset for placing the note.
/// - anchor (dictionary): A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
/// - anchor-pin (none, str): A specific `#deixis-pin` name to anchor the inset note to.
/// - layer (auto, str, dictionary): Rendering layer for the region mark and/or the body. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the body block.
///
/// -> content
#let deixis-inset-note(
  /// Accepts up to two positional arguments: `[mark][body]`.
  /// All named arguments are forwarded to ```ref #deixis-inset-note-body```.
  /// -> arguments
  ..args,
  /// The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
  /// -> auto | str
  mark-type: auto,
  /// A unique identifier linking an existing mark to the body internally. If `none`, a mark will be created.
  /// -> none | str | label
  id: none,
  /// The numbering style for the marker.
  /// -> auto | str | function
  numbering: auto,
  /// A hardcoded marker override.
  /// -> auto | content
  marker: auto,
  /// The specific block/minipage counter this note belongs to.
  /// -> int | label | str
  target: 0,
  /// The counter series this note belongs to.
  /// -> str
  series: "default",
  /// An optional `label` to attach to the rendered body block.
  /// -> none | label
  label: none,
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
  /// Mark marker placement.
  ///
  /// See @deixis-inline-mark.marker-position and @deixis-region-mark.marker-position.
  ///
  /// -> auto | alignment | dictionary
  marker-position: auto,
  /// The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
  ///
  /// See @deixis-inline-mark.inline-mode.
  ///
  /// -> auto | str
  inline-mode: auto,
  /// Array of pin names for the region mark.
  ///
  /// See @deixis-region-mark.pins.
  ///
  /// -> array
  pins: (),
  /// Internal padding for the region mark.
  ///
  /// See @deixis-region-mark.padding.
  ///
  /// -> auto | length | str | dictionary
  padding: auto,
  /// Shape drawing function for the region mark.
  ///
  /// See @deixis-region-mark.region-shape.
  ///
  /// -> auto | function
  region-shape: auto,
  /// If `true`, force the region mark into an inline box.
  ///
  /// See @deixis-region-mark.inline.
  ///
  /// -> bool
  inline: false,
  /// Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  /// -> auto | bool | str
  backlink: auto,
  /// The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
  /// -> auto | str
  link: auto,
  /// An array of intermediate coordinate offsets to route the connector line through.
  /// -> none | array
  link-waypoints: none,
  /// Defines the exact exit/entry ports for the connector line.
  /// -> auto | array | dictionary
  link-ports: auto,
  /// The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
  /// -> auto | str
  link-marks: auto,
  /// The width of the inset note body.
  /// -> auto | length | relative
  width: auto,
  /// A custom floating placement function (e.g., Typst's native `#std.place`).
  ///
  /// See @deixis-inset-note-body.placement.
  ///
  /// -> none | function
  placement: none,
  /// Absolute horizontal offset for placing the note.
  ///
  /// See @deixis-inset-note-body.dx.
  ///
  /// -> none | length
  dx: none,
  /// Absolute vertical offset for placing the note.
  ///
  /// See @deixis-inset-note-body.dy.
  ///
  /// -> none | length
  dy: none,
  /// A dictionary defining how the note aligns to its anchor point (e.g., `(mark: horizon + right, body: horizon + left)`).
  ///
  /// See @deixis-inset-note-body.anchor.
  ///
  /// -> dictionary
  anchor: (mark: horizon + right, body: horizon + left),
  /// A specific `#deixis-pin` name to anchor the inset note to.
  ///
  /// See @deixis-inset-note-body.anchor-pin.
  ///
  /// -> none | str
  anchor-pin: none,
  /// Rendering layer for the region mark and/or the body. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// See @deixis-region-mark.layer and @deixis-inset-note-body.layer.
  ///
  /// ```tip
  /// Since both @deixis-region-mark and @deixis-inset-note-body shares this parameter, you can pass `layer: (mark: "flow", body: "foreground")` to assign different layer to each component.
  /// ```
  ///
  /// -> auto | str | dictionary
  layer: auto,
  /// A custom render function for the inner layout of the body.
  /// -> auto | function
  render-single: auto,
  /// A custom container wrapper for the body block.
  /// -> auto | function
  container-func: auto,
) = {
  let pos = args.pos()
  if pos.len() > 2 { panic("deixis: #deixis-inset-note accepts at most 2 positional arguments: [mark][body]") }
  let mark-content = if pos.len() > 1 { pos.first() } else { none }
  let note-body = if pos.len() > 0 { pos.last() } else { none }

  let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

  if id != none {
    return deixis-inset-note-body(
      note-body,
      id: id,
      target: target,
      label: label,
      marker-style: marker-style,
      backlink: backlink,
      stroke: stroke,
      fill: fill,
      radius: radius,
      link: link,
      link-waypoints: link-waypoints,
      link-ports: link-ports,
      link-marks: link-marks,
      width: width,
      placement: placement,
      dx: dx,
      dy: dy,
      anchor: anchor,
      anchor-pin: anchor-pin,
      layer: layer,
      render-single: render-single,
      container-func: container-func,
      ..args.named(),
    )
  }

  let render-mark(target-id) = {
    if mark-type == "region" {
      deixis-region-mark(
        mark-content,
        id: target-id,
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
        padding: padding,
        region-shape: region-shape,
        layer: layer,
        inline: inline,
      )
    } else if mark-type == "phantom" {
      deixis-phantom-mark(
        id: target-id,
        numbering: numbering,
        marker: marker,
        target: target,
        series: series,
      )
    } else {
      deixis-inline-mark(
        mark-content,
        id: target-id,
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
      )
    }
  }

  let render-body(target-id) = {
    deixis-inset-note-body(
      note-body,
      id: target-id,
      target: target,
      label: label,
      marker-style: marker-style,
      backlink: backlink,
      stroke: stroke,
      fill: fill,
      radius: radius,
      link: link,
      link-waypoints: link-waypoints,
      link-ports: link-ports,
      link-marks: link-marks,
      width: width,
      placement: placement,
      dx: dx,
      dy: dy,
      anchor: anchor,
      anchor-pin: anchor-pin,
      layer: layer,
      render-single: render-single,
      container-func: container-func,
      ..args.named(),
    )
  }

  let m = render-mark(deixis-auto-id)
  let b = render-body(deixis-auto-id)

  let is-block-region = mark-type == "region" and inline == false
  if is-block-region {
    [#m#place(b)]
  } else {
    [#m#b]
  }
}

// Inset note overlay
#let _deixis-inset-notes-overlay(layer: "foreground") = {
  let draw-bodies = context {
    let notes = query(<deixis-inset-note>).filter(it => (
      type(it.value) == dictionary and it.value.at("mark-lbl", default: none) != none
    ))
    let paths = ()
    let current-page = here().page()
    let all-pins = query(<deixis-pin>)

    for n in notes {
      let data = n.value
      let n-layer = data.at("layer", default: "foreground")

      let target_page = n.location().page()
      if data.anchor-pin != none {
        let pin-elems = all-pins.filter(x => x.value.name == data.anchor-pin)
        if pin-elems.len() > 0 {
          target_page = pin-elems.first().location().page()
        }
      }

      if n-layer == layer and current-page == target_page {
        let active-renderer = data.render-single
        let rendered-content = active-renderer(data, inner-width: if data.width == auto { auto } else { 100% })
        let dest-top-lbl = data.at("dest-top-lbl", default: none)

        let final-rendered = block(width: data.width, {
          if dest-top-lbl != none {
            place(top + center, [#metadata(none)#dest-top-lbl])
            place(bottom + center, [#metadata(none)#data.dest-bot-lbl])
            place(horizon + left, [#metadata(none)#data.dest-left-lbl])
            place(horizon + right, [#metadata(none)#data.dest-right-lbl])
          }
          rendered-content
        })

        if type(data.placement) == function {
          paths.push(box(data.placement(final-rendered)))
        } else if data.dx != none or data.dy != none {
          paths.push(deixis-place-anchored(
            final-rendered,
            dx: if data.dx == none { 0pt } else { data.dx },
            dy: if data.dy == none { 0pt } else { data.dy },
            anchor: data.anchor,
            internal-id: data.internal-id,
            pin: data.anchor-pin,
          ))
        } else {
          paths.push(deixis-place-anchored(
            final-rendered,
            dx: 0pt,
            dy: 0pt,
            anchor: data.anchor,
            internal-id: data.internal-id,
            pin: data.anchor-pin,
          ))
        }
      }
    }
    paths.join()
  }

  let draw-links = context {
    if layer != "foreground" { return none }

    let notes = query(<deixis-inset-note>).filter(it => (
      type(it.value) == dictionary and it.value.at("mark-lbl", default: none) != none
    ))
    let paths = ()
    let sys = deixis-system.get()

    for n in notes {
      let data = n.value

      let c-link = _deixis-resolve-typed-param(sys, data.at("link", default: auto), "link", "inset-note")
      if c-link in (none, "none", false) { continue }

      let c-link-stroke = data.at("link-stroke", default: _deixis-resolve-typed-param(
        sys,
        auto,
        "stroke",
        "inset-note",
        component: "link",
      ))
      let c-link-radius = data.at("link-radius", default: _deixis-resolve-typed-param(
        sys,
        auto,
        "radius",
        "inset-note",
        component: "link",
      ))
      let c-link-marks = _deixis-resolve-typed-param(
        sys,
        data.at("link-marks", default: auto),
        "link-marks",
        "inset-note",
      )

      let start-elems = query(selector(data.mark-lbl))
      let d-top-elems = query(selector(data.at("dest-top-lbl", default: data.body-lbl)))

      if start-elems.len() > 0 and d-top-elems.len() > 0 {
        let current-page = here().page()
        let S_page = start-elems.last().location().page()
        let E_page = d-top-elems.last().location().page()

        let region-elems = query(<deixis-region-mark>).filter(r => (
          type(r.value) == dictionary
            and r.value.at("internal-id", default: none) != none
            and str(r.value.internal-id) == str(data.internal-id)
        ))
        let is-region = region-elems.len() > 0
        let reg = if is-region { region-elems.first().value } else { none }
        let all-pins = if is-region { query(<deixis-pin>) } else { () }

        let r-pins = ()
        if is-region {
          for pin-name in reg.pins {
            for p in all-pins.filter(x => x.value.name == pin-name) { r-pins.push(p) }
          }
          if r-pins.len() > 0 {
            let sorted-pins = r-pins.sorted(key: p => (p.location().page(), p.location().position().y))
            let first_region_page = sorted-pins.first().location().page()
            let last_region_page = sorted-pins.last().location().page()

            if E_page >= first_region_page and E_page <= last_region_page {
              S_page = E_page
            } else if E_page < first_region_page {
              S_page = first_region_page
            } else {
              S_page = last_region_page
            }
          }
        }

        if current-page != S_page and current-page != E_page { continue }

        let S = start-elems.last().location().position()
        let D_top = d-top-elems.last().location().position()

        let link-paths = _deixis-render-inset-link(
          data,
          current-page,
          S_page,
          E_page,
          S,
          D_top,
          reg: reg,
          r-pins: r-pins,
          c-link: c-link,
          c-link-stroke: c-link-stroke,
          c-link-radius: c-link-radius,
          c-link-marks: c-link-marks,
        )

        for el in link-paths { paths.push(el) }
      }
    }
    paths.join()
  }

  [#draw-bodies#draw-links]
}
