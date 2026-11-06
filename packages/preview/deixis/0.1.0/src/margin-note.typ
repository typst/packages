#import "core.typ": *
#import "inline-note.typ": *
#import "region-note.typ": *

/// A standalone body content of a margin note.
///
/// ```example
/// //| sandbox-mode: "page"
/// The old manor was a labyrinth of
/// #deixis-inline-mark(id: <crepuscular>)[crepuscular]
/// corridors, where the shadows seemed to stretch and breathe with the setting sun.
///
/// #deixis-margin-note-body(id: <crepuscular>)[Relating to or resembling twilight.]
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): A unique identifier linking this body to its corresponding mark.
/// - target (auto, int, label, str): The specific block/minipage render context this note belongs to.
/// - series (auto, str): The counter series this note belongs to.
/// - label (none, label): An optional `label` to attach to the rendered body.
/// - marker-style (auto, function): A custom styling function for the marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - link (auto, str): The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
/// - link-waypoints (none, auto, array): An array of intermediate coordinate offsets to route the connector line through.
/// - link-ports (auto, array, dictionary): Defines the exact exit/entry ports on the mark and body for the connector line.
/// - link-marks (auto, str): The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
/// - width (auto, length, relative): The width of the margin note body. Defaults to `90%` of the margin width.
/// - dx (auto, length): Horizontal offset adjustment for the body.
/// - dy (length): Vertical offset adjustment for the body. Defaults to `0pt`.
/// - side (auto, alignment): Which margin to place the note in (`left` or `right`). If `auto`, uses the side nearest the mark.
/// - side-strategy (auto, str): Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
/// - mark-align (auto, alignment, dictionary): How the note aligns vertically relative to its mark.
/// - mark-align-strictness (auto, str): How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
/// - spillover (auto, bool): Allow this note to spill over page boundary.
/// - anchor-pin (none, str): A specific `#deixis-pin` name to anchor the body to, instead of the default layout logic.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the body block.
/// - ..args (arguments): Only accepts named arguments, which are forwarded to `container-func`.
///
/// -> content
#let deixis-margin-note-body(
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
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-margin-note(link: "right-angle")[A linked note.]
  /// ```
  ///
  /// -> auto | str
  link: auto,
  /// An array of intermediate coordinate offsets to route the connector line through.
  /// -> none | auto | array
  link-waypoints: auto,
  /// Defines the exact exit/entry ports on the mark and body for the connector line.
  /// -> auto | array | dictionary
  link-ports: auto,
  /// The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
  /// -> auto | str
  link-marks: auto,
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
  ///   link: "right-angle",
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
  ///   link: "right-angle",
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
  /// -> none | str
  anchor-pin: none,
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
  if args.pos().len() > 0 { panic("deixis: #deixis-margin-note-body accepts at most 1 positional argument [body].") }
  let container-args = (stroke: stroke, fill: fill, radius: radius) + args.named()

  let series = if series == auto { "default" } else { series }

  let render-celibate(sys, celibate-id) = {
    let body = deixis-utils._deixis-trim-content(body)
    let resolved = _deixis-resolve-target(sys, target)

    let b-styles = _deixis-resolve-body-styles(sys, "margin-note", ..container-args)

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

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "margin-note")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "margin-note")

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
        gap: c-gap,
        marker-gap: c-marker-gap,
        styles: b-styles,
        render-single: active-renderer,
        container-func: active-container,
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
          anchor-pin: anchor-pin,
          depth: sys.stack.len(),
          has-inline-box: false,
          mark-type: none,
          text-size: text.size,
          marker-width: 0pt,
        )
    )

    [#metadata(note-data)<deixis-margin-note>]
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
    let current-target-uid = if id == deixis-auto-id {
      sys.at("last-auto-uid", default: none)
    } else {
      sys.at("id-index", default: (:)).at(str(id), default: none)
    }

    if current-target-uid == none { return sys }

    let new-notes = sys.at("notes", default: (:))
    let new-label-index = sys.at("label-index", default: (:))

    let payload = new-notes.at(current-target-uid)
    payload.insert("body-type", "margin-note")
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
    let reg = if target-uid != none { final-sys.at("notes", default: (:)).at(target-uid, default: none) } else { none }

    if reg == none {
      return [
        #std.counter("deixis-celibate-note").step()
        #render-celibate(sys, "celibate-" + str(std.counter("deixis-celibate-note").get().first()))
      ]
    }

    let internal-id = reg.internal-id
    let resolved = _deixis-resolve-target(sys, if target == auto { reg.at("target-id", default: 0) } else { target })
    let depth = sys.stack.len()

    let series = reg.at("series", default: series)
    let count = reg.count
    let marker-str = _deixis-query-marker-str(reg)

    let mark-lbl = std.label("deixis-mark-" + str(internal-id))
    let body-lbl = std.label("deixis-body-" + str(internal-id))

    let saved-styles = reg.at("styles", default: (:))
    let merged-styles = _deixis-merge-styles(saved-styles, container-args)

    let b-styles = _deixis-resolve-body-styles(sys, "margin-note", ..merged-styles)
    let l-styles = _deixis-resolve-link-styles(
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

    let c-link = _deixis-resolve-typed-param(sys, link, "link", "margin-note")
    let c-link-ports = deixis-utils._deixis-normalize-ports(link-ports)
    let c-link-marks = _deixis-resolve-typed-param(sys, link-marks, "link-marks", "margin-note")
    if reg.at("mark-type", default: "inline") == "phantom" {
      if link == auto { c-link = "none" }
    }

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "margin-note")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "margin-note")

    let has-inline-box = if reg.at("mark-type", default: "inline") == "inline" {
      reg.at("inline-mode", default: auto) == "box" and reg.at("has-mark-body", default: false)
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
        gap: c-gap,
        marker-gap: c-marker-gap,
        styles: b-styles,
        render-single: active-renderer,
        container-func: active-container,
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
          link: c-link,
          link-stroke: l-styles.stroke,
          link-radius: l-styles.radius,
          link-waypoints: link-waypoints,
          link-ports: c-link-ports,
          link-marks: c-link-marks,
          anchor-pin: anchor-pin,
          depth: depth,
          has-inline-box: has-inline-box,
          mark-type: reg.at("mark-type", default: "inline"),
          text-size: text.size,
          marker-width: if marker-str != none { measure(mark-marker-style(marker-str)).width } else { 0pt },
        )
    )

    [#metadata(note-data)<deixis-margin-note>]
  }
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
/// - layer (auto, str): Rendering layer for the region mark. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - inline (bool): If `true`, force the region mark into an inline box.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - link (auto, str): The type of connector line, Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
/// - link-waypoints (none, auto, array): An array of intermediate coordinate offsets to route the connector line through.
/// - link-ports (auto, array, dictionary): Defines the exact exit/entry ports on the mark and body for the connector line.
/// - link-marks (auto, str): The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
/// - width (auto, length, relative): The width of the margin note body. Defaults to `90%` of the margin width.
/// - dx (auto, length): Horizontal offset adjustment for the body.
/// - dy (length): Vertical offset adjustment for the body. Defaults to `0pt`.
/// - side (auto, alignment): Which margin to place the note in (`left` or `right`). If `auto`, uses the side nearest the mark.
/// - side-strategy (auto, str): Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
/// - mark-align (auto, alignment, dictionary): How the note aligns vertically relative to its mark.
/// - mark-align-strictness (auto, str): How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
/// - spillover (auto, bool): Allow this note to spill over page boundary.
/// - anchor-pin (none, str): A specific `#deixis-pin` name to anchor the body to, instead of the default layout logic.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the body block.
///
/// -> content
#let deixis-margin-note(
  /// Accepts up to two positional arguments: `[mark][body]`.
  /// All named arguments are forwarded to ```ref #deixis-margin-note-body```.
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
  /// Mark marker placement.
  ///
  /// See @deixis-inline-mark.marker-position and @deixis-region-mark.marker-position.
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
  /// Rendering layer for the region mark. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// See @deixis-region-mark.layer.
  ///
  /// -> auto | str
  layer: auto,
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
  ///
  /// See @deixis-margin-note-body.link.
  ///
  /// -> auto | str
  link: auto,
  /// An array of intermediate coordinate offsets to route the connector line through.
  /// -> none | auto | array
  link-waypoints: auto,
  /// Defines the exact exit/entry ports on the mark and body for the connector line.
  /// -> auto | array | dictionary
  link-ports: auto,
  /// The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
  /// -> auto | str
  link-marks: auto,
  /// The width of the margin note body.
  ///
  /// See @deixis-margin-note-body.width.
  ///
  /// -> auto | length | relative
  width: 90%,
  /// Horizontal offset adjustment for the body.
  ///
  /// See @deixis-margin-note-body.dx.
  ///
  /// -> auto | length
  dx: auto,
  /// Vertical offset adjustment for the body.
  ///
  /// See @deixis-margin-note-body.dy.
  ///
  /// -> length
  dy: 0pt,
  /// Which margin to place the note in (`left` or `right`).
  ///
  /// See @deixis-margin-note-body.side.
  ///
  /// -> auto | alignment
  side: auto,
  /// Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
  ///
  /// See @deixis-margin-note-body.side-strategy.
  ///
  /// -> auto | str
  side-strategy: auto,
  /// How the note aligns vertically relative to its mark.
  ///
  /// See @deixis-margin-note-body.mark-align.
  ///
  /// -> auto | alignment | dictionary
  mark-align: auto,
  /// How strictly the engine attempts to keep the note exactly aligned with its mark. Choices: `"strict"` | `"loose"` | `"none"`.
  ///
  /// See @deixis-margin-note-body.mark-align-strictness.
  ///
  /// -> auto | str
  mark-align-strictness: auto,
  /// Allow this note to spill over page boundary.
  ///
  /// See @deixis-margin-note-body.spillover.
  ///
  /// -> auto | bool
  spillover: auto,
  /// A specific `#deixis-pin` name to anchor the body to, instead of the default layout logic.
  ///
  /// See @deixis-margin-note-body.anchor-pin.
  ///
  /// -> none | str
  anchor-pin: none,
  /// A custom render function for the inner layout of the body.
  /// -> auto | function
  render-single: auto,
  /// A custom container wrapper for the body block.
  /// -> auto | function
  container-func: auto,
) = {
  let pos = args.pos()
  if pos.len() > 2 { panic("deixis: #deixis-margin-note accepts at most 2 positional arguments: [mark][body]") }
  let mark-content = if pos.len() > 1 { pos.first() } else { none }
  let body = if pos.len() > 0 { pos.last() } else { none }

  let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

  if id != none {
    return deixis-margin-note-body(
      body,
      id: id,
      target: target,
      label: label,
      marker-style: marker-style,
      backlink: backlink,
      stroke: stroke,
      fill: fill,
      radius: radius,
      link: link,
      link-marks: link-marks,
      link-waypoints: link-waypoints,
      link-ports: link-ports,
      width: width,
      dx: dx,
      dy: dy,
      side: side,
      side-strategy: side-strategy,
      mark-align: mark-align,
      mark-align-strictness: mark-align-strictness,
      spillover: spillover,
      anchor-pin: anchor-pin,
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
    deixis-margin-note-body(
      body,
      id: target-id,
      target: target,
      label: label,
      marker-style: marker-style,
      backlink: backlink,
      stroke: stroke,
      fill: fill,
      radius: radius,
      link: link,
      link-marks: link-marks,
      link-waypoints: link-waypoints,
      link-ports: link-ports,
      width: width,
      dx: dx,
      dy: dy,
      side: side,
      side-strategy: side-strategy,
      mark-align: mark-align,
      mark-align-strictness: mark-align-strictness,
      spillover: spillover,
      anchor-pin: anchor-pin,
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

// Margin note overlay
#let _deixis-margin-notes-overlay() = context {
  let current-page = here().page()
  let total-pages = counter(page).final().first()

  let notes = query(<deixis-margin-note>)
  if notes.len() == 0 { return }

  let sys = deixis-system.get()
  let all-pins = query(<deixis-pin>)
  let processed-notes = ()

  // pre-processor
  for n in notes {
    let note-data = n.value

    let is-celibate = note-data.at("mark-lbl", default: none) == none

    let mark-page = n.location().page()
    let mark-x = n.location().position().x
    let mark-y = n.location().position().y
    let marker-width = note-data.at("marker-width", default: 0pt)

    let is-region = false
    let reg = none
    let r-pins = ()

    let anchor-pin = note-data.at("anchor-pin", default: none)

    if not is-celibate {
      let internal-id = str(note-data.mark-lbl).replace("deixis-mark-", "")

      let region-elems = query(<deixis-region-mark>).filter(r => (
        r.value.internal-id != none and str(r.value.internal-id) == internal-id
      ))
      is-region = region-elems.len() > 0
      reg = if is-region { region-elems.first().value } else { none }

      if is-region {
        for pin-name in reg.pins {
          for p in all-pins.filter(x => x.value.name == pin-name) { r-pins.push(p) }
        }
      } else {
        // Pre-calculate marker width for inline/phantom marks
        let mm-elems = query(selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>))).filter(
          m => (
            type(m.value) == dictionary
              and m.value.at("internal-id", default: none) != none
              and str(m.value.internal-id) == str(internal-id)
          ),
        )
        if mm-elems.len() > 0 {
          marker-width = mm-elems.first().value.at("marker-width", default: 0pt)
        }
      }
    }

    if type(anchor-pin) == str {
      let spec-pins = all-pins.filter(p => p.value.name == anchor-pin)
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

          // FIXME: hack for 2nd level notes and above
          if note-data.at("depth", default: 0) >= 2 {
            mark-x -= marker-width
          }
        }
      }
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
  let page-w = r-len(page.width, 21cm)
  let page-h = r-len(page.height, 29.7cm)

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
        let p-m = deixis-utils.get-page-margins(p)
        pages-info.push((
          idx: p - 1,
          page: p,
          top: deixis-utils.resolve-len(p-m.top),
          bottom: deixis-utils.resolve-len(r-len(page.height, 29.7cm)) - deixis-utils.resolve-len(p-m.bottom),
          l-space: deixis-utils.resolve-len(p-m.left),
          r-space: deixis-utils.resolve-len(p-m.right),
        ))
      }

      let predicted-notes = _deixis-predict-cascade(
        all-page-notes,
        pages-info,
        deixis-utils.text-direction(text.dir, text.lang),
        c-margin-layout,
        min-margin-width: c-min-margin-width,
        cascade-breaker: true,
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
        page-layout = first-note.at("margin-layout", default: c-margin-layout)
        page-min-width = first-note.at("min-margin-width", default: c-min-margin-width)
      }

      let layout-func = if type(page-layout) == function {
        page-layout
      } else if page-layout == "flow" {
        deixis-margin-note-flow-layout
      } else if page-layout == "exact" {
        deixis-margin-note-exact-layout
      } else if page-layout == "adaptive" {
        deixis-margin-note-adaptive-layout
      } else {
        panic("deixis: margin-layout='" + repr(page-layout) + "' not supported.")
      }

      layout-func(
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
    }
  }

  // block level
  let all-block-notes = processed-notes.filter(n => n.note-data.target-id != "page")
  if all-block-notes.len() > 0 {
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
      for (i, b) in sorted-blocks.enumerate() {
        if b.end == none or b.right == none {
          valid = false
          break
        }
        blocks-info.push((
          idx: i,
          page: b.start.location().page(),
          top: b.start.location().position().y,
          bottom: b.end.location().position().y,
          l-space: b.start.value.l-space,
          r-space: b.start.value.r-space,
        ))
      }
      if not valid { continue }

      let predicted-notes = _deixis-predict-cascade(
        notes,
        blocks-info,
        deixis-utils.text-direction(text.dir, text.lang),
        b-margin-layout,
        min-margin-width: b-min-margin-width,
        cascade-breaker: false,
      )

      for (i, b-info) in blocks-info.enumerate() {
        if b-info.page != current-page { continue }
        let b = sorted-blocks.at(i)
        let active-notes = predicted-notes.filter(x => x.block-idx == i)
        let pushed-notes = predicted-notes.filter(x => (
          x.mark-block == i and blocks-info.at(x.block-idx).page > current-page
        ))

        if active-notes.len() > 0 or pushed-notes.len() > 0 {
          let layout-func = if type(b-margin-layout) == function { b-margin-layout } else if b-margin-layout == "flow" {
            deixis-margin-note-flow-layout
          } else { deixis-margin-note-adaptive-layout }
          layout-func(
            active-notes,
            b.start.location().position().y,
            b.end.location().position().y,
            b.start.location().position().x,
            b.right.location().position().x - b.start.location().position().x,
            b.end.location().position().y,
            b-info.l-space,
            b-info.r-space,
            current-page,
            min-margin-width: b-min-margin-width,
            pushed-notes: pushed-notes,
          )
        }
      }
    }
  }
}

/// A ```ref #deixis-margin-note-body``` with default `side: "outside", mark-align-strictness: "loose"`.
#let deixis-sidenote-body = deixis-margin-note-body.with(side: "outside", mark-align-strictness: "loose")

/// A ```ref #deixis-margin-note``` with default `side: "outside", mark-align-strictness: "loose"`.
#let deixis-sidenote = deixis-margin-note.with(side: "outside", mark-align-strictness: "loose")
