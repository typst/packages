#import "core.typ": *
#import "inline-note.typ": *
#import "region-note.typ": *

/// A standalone body content of an endnote.
///
/// The body of the endnote is completely invisible when declared.
/// It is stored as metadata and will only be rendered when you explicitly call ```ref #deixis-print-endnotes()```.
///
/// ```example
/// //| sandbox-mode: "page"
/// The abandoned cathedral was a monument to #deixis-inline-mark(id: <sciamachy>, series: "endnote")[sciamachy], its crumbling walls silent witnesses to a forgotten struggle.
/// Within its hallowed nave, a single #deixis-inline-mark(id: <glabella>, series: "endnote")[glabella] on a marble statue caught the moonlight, the only smooth surface left untouched by the decay of time.
///
/// #deixis-endnote-body(id: <sciamachy>)[*Sciamachy:* A battle against an imaginary enemy; literally _shadow-fighting_.]
/// #deixis-endnote-body(id: <glabella>)[*Glabella:* The smooth part of the forehead between the eyebrows and just above the nose.]
/// ```
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-print-endnotes()
/// ```
///
/// ```memo
/// It is noted that endnotes default to `series: "endnote"`.
/// Hence, you should pass `series: "endnote"` to the decoupled mark or the body, or mind @deixis-print-endnotes.series when you print them.
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): A unique identifier linking this body to its corresponding mark.
/// - target (auto, int, label, str): The specific block/minipage render context this note belongs to.
/// - series (auto, str): The counter series this note belongs to.
/// - label (none, label): An optional `label` to attach to the note.
/// - marker-style (auto, function): A custom styling function for the marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning to the mark.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the endnote when printed.
/// - ..args (arguments): Only accepts named arguments, which are forwarded to `container-func`.
///
/// -> content
#let deixis-endnote-body(
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
  if args.pos().len() > 0 { panic("deixis: #deixis-endnote-body accepts at most 1 positional argument [body].") }
  let container-args = (stroke: stroke, fill: fill, radius: radius) + args.named()

  let series = if series == auto { "endnote" } else { series }

  let render-celibate(sys, celibate-id) = {
    let body = deixis-utils._deixis-trim-content(body)
    let resolved = _deixis-resolve-target(sys, target)

    let b-styles = _deixis-resolve-body-styles(sys, "endnote", ..container-args)

    let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "endnote")
    let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "endnote")

    let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "endnote")
    let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "endnote")
    let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "endnote")
    let c-clearance = _deixis-resolve-typed-param(sys, auto, "clearance", "endnote")
    let c-separator = _deixis-resolve-typed-param(sys, auto, "separator", "endnote")

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "endnote")
    let active-group-renderer = _deixis-resolve-typed-param(sys, auto, "render-group", "endnote")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "endnote")

    let note-data = (
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
      clearance: c-clearance,
      separator: c-separator,
      styles: b-styles,
      render-single: active-renderer,
      render-group: active-group-renderer,
      container-func: active-container,
    )

    [#metadata(note-data)<deixis-endnote>]
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
    payload.insert("body-type", "endnote")
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

    let series = reg.at("series", default: series)
    let count = reg.count
    let marker-str = _deixis-query-marker-str(reg)

    let mark-lbl = std.label("deixis-mark-" + str(internal-id))
    let body-lbl = std.label("deixis-body-" + str(internal-id))

    let saved-styles = reg.at("styles", default: (:))
    let merged-styles = _deixis-merge-styles(saved-styles, container-args)

    let b-styles = _deixis-resolve-body-styles(sys, "endnote", ..merged-styles)

    let mark-marker-style = _deixis-resolve-typed-param(sys, marker-style, "marker-style", "endnote", component: "mark")
    let body-marker-style = _deixis-resolve-typed-param(sys, marker-style, "marker-style", "endnote", component: "body")
    let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "endnote")
    let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "endnote")

    let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "endnote")
    let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "endnote")
    let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "endnote")
    let c-clearance = _deixis-resolve-typed-param(sys, auto, "clearance", "endnote")
    let c-separator = _deixis-resolve-typed-param(sys, auto, "separator", "endnote")

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "endnote")
    let active-group-renderer = _deixis-resolve-typed-param(sys, auto, "render-group", "endnote")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "endnote")

    let note-data = (
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
      clearance: c-clearance,
      separator: c-separator,
      container-func: active-container,
      styles: b-styles,
      render-single: active-renderer,
      render-group: active-group-renderer,
    )

    [#metadata(note-data)<deixis-endnote>]
  }
}

/// A wrapper for generating endnotes.
///
/// This function creates a mark in the text and delegates the body to ```ref #deixis-endnote-body```.
///
/// ```example
/// //| sandbox-mode: "page"
/// The botanist spent years searching for the idiosyncratic
/// #deixis-endnote[*Idiosyncratic:* Something peculiar or individual to a specific person, place, or thing.]
/// wildflower that only bloomed in the valley’s deepest shadows.
/// As the sun dipped below the horizon, the forest floor began to glow with a soft bioluminescence
/// #deixis-endnote[*Bioluminescence:* The production and emission of light by a living organism.]
/// that guided her back to camp.
/// ```
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-print-endnotes()
/// ```
///
/// See ```ref #deixis-print-endnotes```.
///
/// - ..args (arguments): Accepts up to two positional arguments: `[mark][body]`. All named arguments are forwarded to `container-func`.
/// - mark-type (auto, str): The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
/// - id (none, str, label): A unique identifier linking an existing mark to the body internally. If `none`, a mark will be created.
/// - numbering (auto, str, function): The numbering style for the endnote marker.
/// - marker (auto, content): A hardcoded marker override.
/// - target (int, label, str): The specific block/minipage counter this note belongs to.
/// - series (str): The counter series this note belongs to. Defaults to `"endnote"`.
/// - label (none, label): An optional `label` to attach to the note.
/// - marker-style (auto, function): A custom styling function for the marker.
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
/// - container-func (auto, function): A custom container wrapper for the endnote when printed.
///
/// -> content
#let deixis-endnote(
  /// Accepts up to two positional arguments: `[mark][body]`.
  /// All named arguments are forwarded to ```ref #deixis-footnote-body```.
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
  ///
  /// ```info
  /// Note that endnotes belong to the `"endnote"` series by default, while all other note functions belong to the `"default"` series.
  /// ```
  ///
  /// -> str
  series: "endnote",
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
  /// A custom container wrapper for the body block.
  /// -> auto | function
  container-func: auto,
) = {
  let pos = args.pos()
  if pos.len() > 2 { panic("deixis: #deixis-endnote accepts at most 2 positional arguments: [mark][body]") }
  let mark-content = if pos.len() > 1 { pos.first() } else { none }
  let body = if pos.len() > 0 { pos.last() } else { none }

  let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

  if id != none {
    return deixis-endnote-body(
      body,
      id: id,
      target: target,
      label: label,
      marker-style: marker-style,
      stroke: stroke,
      fill: fill,
      radius: radius,
      backlink: backlink,
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
    deixis-endnote-body(
      body,
      id: target-id,
      target: target,
      label: label,
      marker-style: marker-style,
      stroke: stroke,
      fill: fill,
      radius: radius,
      backlink: backlink,
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

#let deixis-printed-endnotes-state = std.state("deixis-printed-endnotes", (:))

/// Renders a collected list of endnote bodies at the current location in the document.
///
/// This function queries the `deixis` state engine for all endnotes matching the specified target
/// and series, and prints them in a formatted list. It supports extensive spatial filtering, allowing
/// you to print endnotes specifically for a single chapter or section.
///
/// ````info
/// Note bodies cannot be printed twice.
/// `deixis-print-endnotes` keeps track of what was printed to avoid duplication.
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-print-endnotes()
/// ```
/// ````
///
/// - target (int, label, str): The specific block/minipage target to pull notes from.
/// - series (auto, str, array): Filters to notes belonging to a specific series or array of series.
/// - after (none, location, label, str): Only prints notes that appear *after* this location, label, or `<deixis-pin>` name.
/// - before (none, location, label, str): Only prints notes that appear *before* this location, label, or `<deixis-pin>` name.
/// - marker-style (auto, function): Overrides the marker style for the printed list.
/// - body-style (auto, function): Overrides the text styling of the printed bodies.
/// - backlink (auto, bool, str): Overrides the backlink generation setting for these notes. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - separator (auto, content, none): An optional separator to draw between the list of notes (e.g., a line).
/// - clearance (auto, length): The spacing before the list of endnotes begins.
/// - gap (auto, length): The vertical spacing between individual endnotes.
/// - marker-gap (auto, length): The horizontal spacing between the endnote number and its text body.
/// - indent (auto, length): Overrides the indentation applied to the note body.
/// - render-single (auto, function): A custom rendering function `(note-data) => content` to override the local `render-single`.
/// - render-group (auto, function): A custom rendering function `(notes-array) => content` to override the local `render-group`.
/// - container-func (auto, function): A custom container wrapper for the entire printed block.
///
/// -> content
#let deixis-print-endnotes(
  /// The specific block/minipage target to pull notes from.
  /// -> int | label | str
  target: 0,
  /// Filters to notes belonging to a specific series or array of series.
  /// -> auto | str | array
  series: auto,
  /// Only prints notes that appear *after* this location, label, or `<deixis-pin>` name.
  /// -> none | location | label | str
  after: none,
  /// Only prints notes that appear *before* this location, label, or `<deixis-pin>` name.
  /// -> none | location | label | str
  before: none,
  /// Overrides the marker style for the printed list.
  /// -> auto | function
  marker-style: auto,
  /// Overrides the text styling of the printed bodies.
  /// -> auto | function
  body-style: auto,
  /// Overrides the backlink generation setting for these notes. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  /// -> auto | bool | str
  backlink: auto,
  /// An optional separator to draw between the list of notes (e.g., a line).
  /// -> auto | content | none
  separator: auto,
  /// The spacing before the list of endnotes begins.
  /// -> auto | length
  clearance: auto,
  /// The vertical spacing between individual endnotes.
  /// -> auto | length
  gap: auto,
  /// The horizontal spacing between the endnote number and its text body.
  /// -> auto | length
  marker-gap: auto,
  /// Overrides the indentation applied to the note body.
  /// -> auto | length
  indent: auto,
  /// A custom rendering function `(note-data) => content` to override the local `render-single`.
  /// -> auto | function
  render-single: auto,
  /// A custom rendering function `(notes-array) => content` to override the local `render-group`.
  /// -> auto | function
  render-group: auto,
  /// A custom container wrapper for the entire printed block.
  /// -> auto | function
  container-func: auto,
) = context {
  _deixis-check-setup-state()

  let sys = deixis-system.get()
  let resolved = _deixis-resolve-target(sys, target)

  let printed-dict = deixis-printed-endnotes-state.get()
  let already-printed = printed-dict.at(resolved.render-id, default: ())

  let resolve-bound(b-val, b-name) = {
    if b-val == none { return none }
    if type(b-val) == location { return b-val }

    if type(b-val) == str {
      let pins = query(<deixis-pin>).filter(p => p.value.at("name", default: "") == b-val)
      if pins.len() == 0 {
        panic("deixis: Could not find pin named '" + b-val + "' for parameter '" + b-name + "'. Check your spelling!")
      }
      return pins.first().location()
    } else {
      let elems = query(b-val)
      if elems.len() == 0 {
        panic(
          "deixis: Could not find target matching '"
            + repr(b-val)
            + "' for parameter '"
            + b-name
            + "'. Make sure the label/selector exists in the document.",
        )
      }
      return elems.first().location()
    }
  }

  let loc-after = resolve-bound(after, "after")
  let loc-before = resolve-bound(before, "before")

  let q-sel = selector(<deixis-endnote>)
  if loc-after != none { q-sel = q-sel.after(loc-after) }

  let actual-before = if loc-before != none { loc-before } else { here() }
  q-sel = q-sel.before(actual-before)

  let notes = query(q-sel)
    .map(x => x.value)
    .filter(x => x.target-id == resolved.render-id and x.internal-id not in already-printed)
    .filter(x => {
      if series == auto { return true }
      if type(series) == array { return x.series in series }
      return x.series == series
    })

  if notes.len() > 0 {
    let first-note = notes.first()

    let overrides = (:)
    if marker-style != auto {
      let body-marker-style = _deixis-resolve-typed-param(
        sys,
        marker-style,
        "body-marker-style",
        "endnote",
        component: "body",
      )
      if body-marker-style != auto { overrides.insert("body-marker-style", body-marker-style) }
    }
    if body-style != auto { overrides.insert("body-style", body-style) }
    if backlink != auto { overrides.insert("backlink", backlink) }
    if indent != auto { overrides.insert("indent", indent) }
    if marker-gap != auto { overrides.insert("marker-gap", marker-gap) }
    if render-single != auto { overrides.insert("render-single", render-single) }
    if container-func != auto { overrides.insert("container-func", container-func) }

    let final-notes = notes.map(n => {
      let original-body = n.body
      n.insert("body-type", "endnote")
      n.body = [#metadata(n)<deixis-rendered-start>#original-body#metadata(n)<deixis-rendered-end>]

      for (k, v) in overrides { n.insert(k, v) }
      n
    })

    let final-gap = if gap != auto { gap } else { first-note.at("gap", default: 0.5em) }
    let final-separator = if separator != auto { separator } else { first-note.at("separator", default: none) }
    let final-clearance = if clearance != auto { clearance } else { first-note.at("clearance", default: 1em) }
    let final-render-group = if render-group != auto { render-group } else {
      first-note.at("render-group", default: auto)
    }
    if final-render-group == auto {
      final-render-group = _deixis-resolve-typed-param(sys, auto, "render-group", "endnote")
    }

    deixis-group-layout(
      final-notes,
      separator: final-separator,
      clearance: final-clearance,
      gap: final-gap,
      render-group: final-render-group,
    )

    deixis-printed-endnotes-state.update(old => {
      let cur = old.at(resolved.render-id, default: ())
      for n in notes { cur.push(n.internal-id) }
      old.insert(resolved.render-id, cur)
      old
    })
  }
}
