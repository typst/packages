#import "../core/internal.typ": *
#import "../marks/inline.typ": *
#import "../marks/region.typ": *
#import "../core/native.typ": *

/// A standalone body content of an endnote.
///
/// Body content is preserved. Built-in single renderers fold source indentation
/// with native weak marker spacing and retain explicit paragraph/line breaks.
///
/// The body of the endnote is completely invisible when declared.
/// It is stored as metadata and will only be rendered when you explicitly call ```ref #deixis-print-endnotes()```.
///
/// ```example
/// //| sandbox-mode: "page"
/// The abandoned cathedral was a monument to #deixis-inline-mark(id: <sciamachy>, series: "endnote")[sciamachy], its crumbling walls silent witnesses to a forgotten struggle.
/// Within its hallowed nave, a single #deixis-inline-mark(id: <glabella>, series: "endnote")[glabella] on a marble statue caught the moonlight, the only smooth surface left untouched by the decay of time.
///
/// #deixis-endnote-body(of: <sciamachy>)[*Sciamachy:* A battle against an imaginary enemy; literally _shadow-fighting_.]
/// #deixis-endnote-body(of: <glabella>)[*Glabella:* The smooth part of the forehead between the eyebrows and just above the nose.]
/// ```
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-print-endnotes()
/// ```
///
/// ```memo
/// Endnote wrappers and standalone bodies default to `series: "endnote"`.
/// Attached bodies inherit their original mark's series. Set the series on the
/// original mark, or use `deixis-print-endnotes.series` to select a collection.
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): Names a standalone body. Use of to attach this body to an original mark.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - target (auto, int, label, str): Body rendering scope. Auto inherits the original mark's exact instance, or uses the current scope for standalone bodies.
/// - series (auto, str): Collection series for a standalone body. Omit with of; attachments inherit the original's series.
/// - marker-style (auto, function): A custom styling function for the marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning to the mark.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the endnote when printed, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
/// - ..args (arguments): Additional arguments are rejected; put custom container options in `container-args`.
///
/// -> content
#let deixis-endnote-body(
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
    if args.pos().len() > 0 { panic("deixis: #deixis-endnote-body accepts at most 1 positional argument [body].") }
    _deixis-check-container-options(container-args, extra: args.named())
    let local-styles = (stroke: stroke, fill: fill, radius: radius)

    let series = _deixis-body-series(of, series, fallback: "endnote")

    let render-celibate(sys, celibate-id) = {
      let accent = _deixis-registry(sys).notes.at(str(celibate-id), default: (:)).at("accent", default: sys.at("annotation-accent", default: none))
      let sys = _deixis-accent-context(sys, accent)
      let resolved = _deixis-resolve-target(sys, target)

      let b-styles = _deixis-resolve-body-styles(sys, "endnote", ..local-styles)

      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "endnote")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "endnote")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "endnote", with-origin: true)
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "endnote")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "endnote")
      let c-clearance = _deixis-resolve-typed-param(sys, auto, "clearance", "endnote")
      let c-separator = _deixis-resolve-typed-param(sys, auto, "separator", "endnote")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "endnote")
      let active-group-renderer = _deixis-resolve-typed-param(sys, auto, "render-group", "endnote")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "endnote")

      let note-data = (
        body-type: "endnote",
          z-index: _deixis-resolve-z-index(sys, z-index, "endnote", "body"),
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
        indent: c-indent.value,
        indent-origin: c-indent.origin,
        gap: c-gap,
        marker-gap: c-marker-gap,
        clearance: c-clearance,
        separator: c-separator,
        styles: b-styles,
        render-single: active-renderer,
        render-group: active-group-renderer,
        container-func: active-container,
        container-args: container-args,
      )

      [#_deixis-metadata(note-data, <deixis-endnote>)]
    }

    if of == none {
      return {
        prepared.declarations
        if id != none { deixis-system.update(sys => _deixis-register-standalone(sys, id, body, "endnote", data: data)) }
        _std-counter("deixis-celibate-note").step()
        _deixis-setup-context(() => {
          let uid = if id == none { "celibate-" + str(_std-counter("deixis-celibate-note").get().first()) } else { "id-" + str(id) }
          if id == none { _deixis-palette-anonymous(deixis-system.get(), sys => render-celibate(sys, uid)) }
          else { render-celibate(deixis-system.get(), uid) }
        })
      }
    }

    prepared.declarations
    deixis-system.update(sys => _deixis-register-body(sys, of, body, "endnote"))
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

      let b-styles = _deixis-resolve-body-styles(sys, "endnote", ..merged-styles)

      let mark-marker-style = _deixis-resolve-typed-param(sys, marker-style, "marker-style", "endnote", component: "mark")
      let body-marker-style = _deixis-resolve-typed-param(sys, marker-style, "marker-style", "endnote", component: "body")
      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "endnote")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "endnote")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "endnote", with-origin: true)
      let c-gap = _deixis-resolve-typed-param(sys, auto, "gap", "endnote")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "endnote")
      let c-clearance = _deixis-resolve-typed-param(sys, auto, "clearance", "endnote")
      let c-separator = _deixis-resolve-typed-param(sys, auto, "separator", "endnote")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "endnote")
      let active-group-renderer = _deixis-resolve-typed-param(sys, auto, "render-group", "endnote")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "endnote")

      let note-data = (
        body-type: "endnote",
          z-index: _deixis-resolve-z-index(sys, _deixis-inherited-z-index(reg, z-index), "endnote", "body"),
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
        indent: c-indent.value,
        indent-origin: c-indent.origin,
        gap: c-gap,
        marker-gap: c-marker-gap,
        clearance: c-clearance,
        separator: c-separator,
        container-func: active-container,
        container-args: container-args,
        styles: b-styles,
        render-single: active-renderer,
        render-group: active-group-renderer,
      )

      [#_deixis-metadata(note-data, <deixis-endnote>)]
    })
  }
  _deixis-replayable(none, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: if series == auto { "endnote" } else { series })
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
/// - ..args (arguments): Accepts up to two positional arguments: `[mark][body]`. Put custom container options in `container-args`.
/// - mark-type (auto, str): The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
/// - id (none, str, label): Names the original annotation created by this wrapper. Without id, its identity is private.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - numbering (auto, none, str, function, dictionary): The numbering style for the endnote marker.
/// - marker (auto, content): A hardcoded marker override.
/// - target (auto, int, label, str): Creation uses the current scope; of inherits the original's rendering instance. Explicit values override the body scope.
/// - series (auto, str): Original counter series, defaulting to `"endnote"`. Omit with of; attachments inherit.
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
/// - container-func (auto, str, function): A custom container wrapper for the endnote when printed, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
///
/// -> content
#let deixis-endnote(
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
  /// Original counter series, defaulting to `"endnote"` for creation.
  /// Omit with of; an attachment inherits and cannot redefine the series.
  ///
  /// ```info
  /// Endnotes default to the `"endnote"` series, review comments to `"review"`,
  /// and other note wrappers to `"default"`.
  /// ```
  ///
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
  /// A custom single-note body renderer, forwarded to the endnote body.
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
    if pos.len() > 2 { panic("deixis: #deixis-endnote accepts at most 2 positional arguments: [mark][body]") }
    _deixis-check-attached-wrapper(of, pos, mark-options: (
      numbering: numbering, series: series, marker: marker, mark-type: mark-type,
      marker-position: marker-position, inline-mode: inline-mode,
      pins: if pins == () { auto } else { pins },
      padding: padding, region-shape: region-shape,
      inline: if inline == false { auto } else { inline },
      layer: layer,
    ))
    _deixis-check-container-options(container-args, extra: args.named())
    let mark-content = if pos.len() > 1 { pos.first() } else { none }
    let body = if pos.len() > 0 { pos.last() } else { none }

    let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

    if of != none {
      return deixis-endnote-body(
        body,
        of: of,
        target: target,
        marker-style: marker-style,
        stroke: stroke,
        fill: fill,
        radius: radius,
        z-index: z-index,
        backlink: backlink,
        render-single: render-single,
        container-func: container-func,
        container-args: container-args,
      )
    }

    // Creation uses the current scope and adapter series; attachments above
    // inherit the original's exact rendering instance and counter series.
    let target = if target == auto { 0 } else { target }
    let series = if series == auto { "endnote" } else { series }

    let render-mark(target-id) = {
      if mark-type == "region" {
        deixis-region-mark(
          mark-content,
          id: target-id, _family: "endnote",
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
          id: target-id, _family: "endnote",
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
          id: target-id, _family: "endnote",
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
      deixis-endnote-body(
        body,
        of: target-id,
        target: target,
        marker-style: marker-style,
        stroke: stroke,
        fill: fill,
        radius: radius,
        z-index: z-index,
        backlink: backlink,
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
  _deixis-replayable(if args.pos().len() > 1 { args.pos().first() }, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: if series == auto { "endnote" } else { series })
}

/// Renders a collected list of endnote bodies at the current location in the document.
///
/// This function selects unprinted endnotes matching the specified target
/// and series, and prints them in a formatted list. Source boundaries can select
/// the notes for a chapter or section.
///
/// ````info
/// Note bodies cannot be printed twice.
/// The first matching printer owns each body, including when filtered ranges overlap.
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-print-endnotes()
/// ```
/// ````
///
/// - target (int, label, str): The specific block/minipage target to pull notes from.
/// - series (auto, str, array): Filters to notes belonging to a specific series or array of series.
/// - after (none, location, label, str, dictionary, selector, function): Only prints bodies declared after this exclusive native or pin boundary.
/// - before (none, location, label, str, dictionary, selector, function): Only prints bodies declared before this exclusive boundary. Defaults to the printer's location; an explicit future boundary can include later declarations.
/// - marker-style (auto, function): Overrides the marker style for the printed list.
/// - body-style (auto, function): Overrides the text styling of the printed bodies.
/// - backlink (auto, bool, str): Overrides the backlink generation setting for these notes. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - separator (auto, content, none): An optional separator to draw between the list of notes (e.g., a line).
/// - clearance (auto, length): The spacing before the list of endnotes begins.
/// - gap (auto, length): The vertical spacing between individual endnotes.
/// - marker-gap (auto, length): The horizontal spacing between the endnote number and its text body.
/// - indent (auto, length): Overrides the indentation applied to the note body.
/// - render-single (auto, function): A custom rendering function `(note-data, ..args) => content` to override the local `render-single`.
/// - render-group (auto, function): A custom rendering function `(notes-array, ..args) => content` to override the local `render-group`.
/// - container-func (auto, str, function): Overrides the container for each printed body.
///
/// -> content
#let deixis-print-endnotes(
  /// The specific block/minipage target to pull notes from.
  /// -> int | label | str
  target: 0,
  /// Filters to notes belonging to a specific series or array of series.
  /// -> auto | str | array
  series: auto,
  /// Only prints bodies declared *after* this location, label, or `<deixis-pin>` name.
  /// Strings select the first global pin; structured name/scope/select/page
  /// targets require one selected occurrence. Native locations/labels also work.
  /// Native selectors use their first match, as native labels do.
  /// -> none | location | label | str | dictionary | selector | function
  after: none,
  /// Only prints bodies declared *before* this boundary. Defaults to the printer's location.
  /// An explicit future boundary can include bodies declared after this printer.
  /// Strings select the first global pin; structured name/scope/select/page
  /// targets require one selected occurrence. Forward pin declarations work.
  /// Native selectors use their first match, as native labels do.
  /// -> none | location | label | str | dictionary | selector | function
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
  /// A custom rendering function `(note-data, ..args) => content` to override the local `render-single`.
  /// -> auto | function
  render-single: auto,
  /// A custom rendering function `(notes-array, ..args) => content` to override the local `render-group`.
  /// -> auto | function
  render-group: auto,
  /// Overrides the container for each printed body: a preset name or a function.
  /// -> auto | str | function
  container-func: auto,
  /// Native/custom options forwarded only to the body container.
  /// -> auto | dictionary
  container-args: auto,
) = context {
  _deixis-setup-guard()
  if container-args != auto { _deixis-check-container-options(container-args) }
  for (key, value) in (body-style: body-style, render-single: render-single,
    render-group: render-group) {
    assert(value == auto or type(value) == function,
      message: "deixis: Printer " + key + " override must be auto or a function.")
  }
  assert(container-func == auto or type(container-func) in (str, function),
    message: "deixis: Printer container-func override must be auto or a function, or a preset name.")
  if type(container-func) == str { let _ = _deixis-resolve-container(container-func) }
  let series = _deixis-selection-filter(series, "series")

  _deixis-scope-target-hint(target)
  let sys = deixis-system.get()
  let resolved = _deixis-resolve-target(sys, target)
  let printer-loc = here()
  // Publish ownership before resolving forward boundaries or painting bodies.
  // Later printers must not wait for this printer's queried output to settle.
  [#metadata((target-id: resolved.render-id, series: series, after: after, before: before))<deixis-endnote-printer>]
  context {
    let previous = query(selector(<deixis-endnote-printer>).before(printer-loc))
    let needs-pins = ((after, before).any(value => type(value) in (str, dictionary)) or
      previous.any(printer => (printer.value.after, printer.value.before).any(value => type(value) in (str, dictionary))))
    let pins = if needs-pins { _deixis-pin-index() } else { none }
    let bounds = _deixis-selection-boundaries(after, before, pins: pins)
    let loc-after = bounds.after
    let loc-before = bounds.before

    let q-sel = selector(<deixis-endnote>)
    if loc-after != none { q-sel = q-sel.after(loc-after) }

    let actual-before = if loc-before != none { loc-before } else { printer-loc }
    q-sel = q-sel.before(actual-before)

    // Printer declarations establish ownership independently. A chain of state
    // updates capturing queried note lists otherwise needs another layout pass
    // for each dependent print call, and can exceed Typst's convergence limit.
    let already-printed = (:)
    for printer in previous {
      let spec = printer.value
      if spec.target-id != resolved.render-id { continue }
      let bounds = _deixis-selection-boundaries(spec.after, spec.before, pins: pins)
      let selected = selector(<deixis-endnote>).before(if bounds.before == none { printer.location() } else { bounds.before })
      if bounds.after != none { selected = selected.after(bounds.after) }
      for n in query(selected) {
        if n.value.target-id == spec.target-id and _deixis-selection-matches(n.value.series, spec.series) {
          already-printed.insert(str(n.value.internal-id), true)
        }
      }
    }

    let notes = query(q-sel)
      .map(x => x.value)
      .filter(x => not _deixis-is-hidden(x))
      .filter(x => x.target-id == resolved.render-id and str(x.internal-id) not in already-printed)
      .filter(x => _deixis-selection-matches(x.series, series))

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
      if indent != auto {
        overrides.insert("indent", indent)
        overrides.insert("indent-origin", "local")
      }
      if marker-gap != auto { overrides.insert("marker-gap", marker-gap) }
      if render-single != auto { overrides.insert("render-single", render-single) }
      if container-func != auto { overrides.insert("container-func", container-func) }
      if container-args != auto { overrides.insert("container-args", container-args) }

      let final-notes = notes.map(n => {
        n.insert("body-type", "endnote")

        for (k, v) in overrides { n.insert(k, v) }
        n
      })

      let final-separator = if separator != auto { separator } else { first-note.at("separator", default: none) }

      _deixis-group-layout(
        final-notes,
        separator: final-separator,
        clearance: clearance,
        gap: gap,
        render-group: render-group,
      )
    }
  }
}
