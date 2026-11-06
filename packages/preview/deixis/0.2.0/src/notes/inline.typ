#import "../core/internal.typ": *
#import "../marks/inline.typ": *
#import "../marks/region.typ": deixis-region-mark
#import "../routing/frames.typ": _deixis-single-body-frame
#import "../core/native.typ": *

/// A standalone body content of an inline note.
///
/// Body content is preserved. Built-in single renderers fold source indentation
/// with native weak marker spacing and retain explicit paragraph/line breaks.
///
/// ```example
/// The garden was filled with the
/// #deixis-inline-mark(id: <apricity>)[apricity]
/// of a pale winter sun.
///
/// #deixis-inline-note-body(
///   of: <apricity>,
///   stroke: maroon,
///   fill: maroon.transparentize(95%),
/// )[
///   *Apricity:* The warmth of the sun in winter.
/// ]
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): Names a standalone body. Use of to attach this body to an original mark.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - target (auto, int, label, str): Body rendering scope. Auto inherits the original mark's exact instance, or uses the current scope for standalone bodies.
/// - series (auto, str): Collection series for a standalone body. Omit with of; attachments inherit the original's series.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the number/marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`. Only used when `inline: true`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - inline (bool): If `true`, the body is rendered as if it is ```ref #deixis-inline-mark```.
/// Inline-decoration bodies wrap within the current paragraph and can paginate,
/// whether standalone or attached. `breakable: false` deliberately keeps one frame.
///
/// - breakable (bool): Native flow by default. False keeps the rendered body in one frame, selectable by explicit connections.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, str, function): A custom container wrapper for the body block, or a preset name ("plain", "rect", "alert", "stripe", "tinted").
/// - ..args (arguments): Additional arguments are rejected; put custom container options in `container-args`.
///
/// -> content
#let deixis-inline-note-body(
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
  /// A custom styling function `(string) => content` for the number/marker.
  /// -> auto | function
  marker-style: auto,
  /// Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  /// -> auto | bool | str
  backlink: auto,
  /// The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`. Only used when `inline: true`.
  /// -> auto | str
  inline-mode: auto,
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
  /// If `true`, the body is rendered as if it is `deixis-inline-mark`.
  ///
  /// ```example
  /// The city streets were filled with the psithurism #deixis-inline-mark(id: <psithurism>) of swaying trees.
  /// It was a comforting melody, #deixis-inline-note-body(of: <psithurism>, inline: true)[the sound of wind whispering through leaves].
  /// ```
  ///
  /// -> bool
  inline: false,
  /// False puts the complete rendered body in one native nonbreaking frame:
  /// an inline box with inline: true, otherwise a block. Its live bounds supply
  /// explicit connection ports. True preserves the existing rendering path.
  /// -> bool
  breakable: true,
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
    assert(type(breakable) == bool, message: "deixis: Inline-body breakable must be a boolean.")
    let frame(rendered, identity) = if breakable { rendered } else {
      _deixis-single-body-frame(rendered, identity, inline: inline)
    }
    let prepared = _deixis-body-declarations(body)
    let body = prepared.body
    if args.pos().len() > 0 { panic("deixis: #deixis-inline-note-body accepts at most 1 positional argument [body].") }
    _deixis-check-container-options(container-args, extra: args.named())
    assert(not inline or container-args.len() == 0,
      message: "deixis: Inline-decoration bodies bypass containers; container-args requires inline: false.")
    let styles = (stroke: stroke, fill: fill, radius: radius)

    let series = _deixis-body-series(of, series, fallback: "default")

    let render-celibate(sys, celibate-id) = {
      let accent = _deixis-registry(sys).notes.at(str(celibate-id), default: (:)).at("accent", default: sys.at("annotation-accent", default: none))
      let sys = _deixis-accent-context(sys, accent)
      let resolved = _deixis-resolve-target(sys, target)

      let m-styles = _deixis-resolve-mark-styles(sys, "inline-mark", inline-mode: inline-mode, ..styles)
      let b-styles = _deixis-resolve-body-styles(sys, "inline-note", ..styles)

      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "inline-note")
      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "inline-note")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "inline-note")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inline-note")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inline-note")

      let note-data = (
        body-type: "inline-note",
          z-index: _deixis-resolve-z-index(sys, z-index, "inline-note", "body"),
        render-context: _deixis-render-context(),
        internal-id: celibate-id,
        accent: accent,
        id: id,
        data: data,
        target-id: resolved.render-id,
        inst-id: resolved.inst-id,
        mark-lbl: none,
        body-lbl: none,
        series: series,
        count: none,
        marker-str: none,
        body: body,
        mark-marker-style: auto,
        body-marker-style: auto,
        body-style: c-body-style,
        backlink: _deixis-resolve-typed-param(sys, backlink, "backlink", "inline-note"),
        indent: c-indent,
        marker-gap: c-marker-gap,
        styles: b-styles,
        render-single: active-renderer,
        container-func: active-container,
        container-args: container-args,
        breakable: breakable,
      )

      let meta = [#_deixis-metadata(note-data, <deixis-inline-note>)]

      if inline {
        let backlinks = if _deixis-should-render-backlinks(note-data) { deixis-generate-backlinks(note-data) }
        let rendered = [#deixis-generate-body-meta(note-data)#_deixis-inline-mark(
          [#deixis-generate-body-content(note-data)#backlinks], ..m-styles)]
        [#meta#frame(rendered, celibate-id)]
      } else {
        [#meta#frame(_deixis-render-single(note-data), celibate-id)]
      }
    }

    if of == none {
      return {
        prepared.declarations
        if id != none { deixis-system.update(sys => _deixis-register-standalone(sys, id, body, "inline-note", data: data)) }
        _std-counter("deixis-celibate-note").step()
        _deixis-setup-context(() => {
          let uid = if id == none { "celibate-" + str(_std-counter("deixis-celibate-note").get().first()) } else { "id-" + str(id) }
          if id == none { _deixis-palette-anonymous(deixis-system.get(), sys => render-celibate(sys, uid)) }
          else { render-celibate(deixis-system.get(), uid) }
        })
      }
    }

    prepared.declarations
    deixis-system.update(sys => _deixis-register-body(sys, of, body, "inline-note"))
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
      let merged-styles = _deixis-merge-styles(saved-styles, styles)

      let local-mode = if inline-mode != auto { inline-mode } else { reg.at("inline-mode", default: auto) }
      let m-styles = _deixis-resolve-mark-styles(
        sys,
        "inline-mark",
        inline-mode: local-mode,
        ..merged-styles,
      )
      let b-styles = _deixis-resolve-body-styles(
        sys,
        "inline-note",
        ..merged-styles,
      )

      let local-marker-style = if marker-style != auto { marker-style } else if reg != none {
        reg.at("marker-style", default: auto)
      } else { auto }

      let mark-marker-style = _deixis-resolve-typed-param(
        sys,
        local-marker-style,
        "marker-style",
        "inline-mark",
        component: "mark",
      )
      let body-marker-style = _deixis-resolve-typed-param(
        sys,
        // The original's resolved callback belongs to its mark. Resolve the
        // body's branch at this declaration, as the other body adapters do.
        marker-style,
        "marker-style",
        "inline-note",
        component: "body",
      )
      let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "inline-note")
      let c-backlink = _deixis-resolve-typed-param(sys, backlink, "backlink", "inline-note")

      let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "inline-note")
      let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "inline-note")

      let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inline-note")
      let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inline-note")

      let note-data = (
        body-type: "inline-note",
          z-index: _deixis-resolve-z-index(sys, _deixis-inherited-z-index(reg, z-index), "inline-note", "body"),
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
        styles: b-styles,
        render-single: active-renderer,
        container-func: active-container,
        container-args: container-args,
        breakable: breakable,
      )

      let meta = [#_deixis-metadata(note-data, <deixis-inline-note>)]

      if inline {
        let rendered-body = (note-data.body-style)(_deixis-native-body-content(note-data))

        [#meta#frame(_deixis-inline-mark(
            rendered-body,
            marker-style: mark-marker-style,
            ..m-styles,
          ), internal-id)]
      } else {
        [#meta#frame(_deixis-render-single(note-data), internal-id)]
      }
    })
  }
  _deixis-replayable(none, [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}

/// A wrapper for inline notes: a mark and its explanation in the same paragraph.
///
/// By default the explanation follows the marked passage as an inline aside,
/// decorated like the passage, so the sentence continues. `inline: false`
/// places a callout block after the line instead, which ends the paragraph.
/// This delegates to ```ref #deixis-inline-note-body```.
///
/// ```example
/// The garden was full of
/// #deixis-inline-note[apricity][the warmth of the sun in winter]
/// on that pale afternoon.
/// ```
///
/// - ..args (arguments): Accepts up to two positional arguments: `[mark][body]`.
/// - mark-type (auto, str): The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
/// - id (none, str, label): Names the original annotation created by this wrapper. Without id, its identity is private.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - numbering (auto, none, str, function, dictionary): The numbering style for the marker.
/// - marker (auto, none, content): A hardcoded marker, or none to hide it; numbering still controls counter allocation.
/// - target (auto, int, label, str): Creation uses the current scope; of inherits the original's rendering instance.
/// - series (auto, str): Original counter series, defaulting to `"default"`. Omit with of; attachments inherit.
/// - marker-style (auto, function, dictionary): Marker styling; component dictionaries style mark and body separately.
/// - inline-mode (auto, str): Decoration of the passage; an inline aside reuses it.
/// - inline (bool): Inline aside (default) or a callout block after the line.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning to the mark.
///
/// -> content
#let deixis-inline-note(
  /// Accepts up to two positional arguments: `[mark][body]`. With one,
  /// a solo marker precedes the explanation. With of, accepts only [body].
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
  /// A hardcoded marker override; `none` hides the marker but still counts
  /// unless `numbering` resolves to `none`.
  /// -> auto | none | content
  marker: auto,
  /// Auto uses the current scope for creation and inherits the original's
  /// exact rendering instance with of.
  /// -> auto | int | label | str
  target: auto,
  /// Original counter series, defaulting to `"default"` for creation.
  /// Omit with of; an attachment inherits and cannot redefine the series.
  /// -> auto | str
  series: auto,
  /// A custom styling function for the marker, or a mark/body component dictionary.
  /// -> auto | function | dictionary
  marker-style: auto,
  /// Mark marker placement.
  /// -> auto | alignment | dictionary
  marker-position: auto,
  /// The decoration stroke, shared by passage and aside unless split by component.
  /// -> auto | stroke | none | dictionary
  stroke: auto,
  /// The decoration fill.
  /// -> auto | color | none | dictionary
  fill: auto,
  /// The decoration radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Overlay paint priority; higher integers paint later within a layer.
  /// -> auto | int | dictionary
  z-index: auto,
  /// The visual decoration applied to the marked passage; an inline aside
  /// reuses it. Choices: `"highlight"` | `"box"` | `"parentheses"` |
  /// `"underline"` | `"text-fill"` | `"none"`.
  /// -> auto | str
  inline-mode: auto,
  /// Array of pin names for a region mark.
  /// -> array
  pins: (),
  /// Internal padding for a region mark.
  /// -> auto | length | str | dictionary
  padding: auto,
  /// Shape drawing function for a region mark.
  /// -> auto | function
  region-shape: auto,
  /// Rendering layer for a region mark. Choices: `"flow"` | `"foreground"` | `"background"`.
  /// -> auto | str
  layer: auto,
  /// True places the explanation inline after the passage, in the same
  /// paragraph (a region passage is boxed inline too). False places a callout
  /// block after the line, which ends the paragraph.
  /// -> bool
  inline: true,
  /// False keeps the rendered explanation in one native frame, selectable by
  /// explicit connections.
  /// -> bool
  breakable: true,
  /// Whether to generate a clickable backlink returning to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  /// -> auto | bool | str
  backlink: auto,
  /// A custom render function for a callout body (inline: false).
  /// -> auto | function
  render-single: auto,
  /// A custom container for a callout body (inline: false).
  /// -> auto | str | function
  container-func: auto,
  /// Native/custom options forwarded only to a callout body container.
  /// -> dictionary
  container-args: (:),
) = {
  let render-with-order-hints() = {
    _deixis-check-identities(id, of)
    _deixis-check-note-data(data, of: of)
    assert(type(inline) == bool, message: "deixis: inline-note inline must be a boolean.")
    let pos = args.pos()
    if pos.len() > 2 { panic("deixis: #deixis-inline-note accepts at most 2 positional arguments: [mark][body]") }
    _deixis-check-attached-wrapper(of, pos, mark-options: (
      numbering: numbering, series: series, marker: marker, mark-type: mark-type,
      marker-position: marker-position, pins: if pins == () { auto } else { pins },
      padding: padding, region-shape: region-shape, layer: layer,
    ))
    _deixis-check-container-options(container-args, extra: args.named())
    let mark-content = if pos.len() > 1 { pos.first() } else { none }
    let body = if pos.len() > 0 { pos.last() } else { none }
    let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)
    let render-body(owner) = deixis-inline-note-body(body, of: owner,
      target: if of == none { auto } else { target },
      marker-style: marker-style, backlink: backlink, inline-mode: if of == none { auto } else { inline-mode },
      stroke: stroke, fill: fill, radius: radius, z-index: z-index, inline: inline, breakable: breakable,
      render-single: render-single, container-func: container-func, container-args: container-args)

    if of != none { return render-body(of) }

    // Creation uses the current scope and series. The aside inherits the
    // passage's decoration through its original, like any attached body.
    let target = if target == auto { 0 } else { target }
    let series = if series == auto { "default" } else { series }
    let render-mark(owner) = {
      if mark-type == "region" {
        deixis-region-mark(mark-content, id: owner, _family: "inline-note", data: data, pins: pins, numbering: numbering,
          marker: marker, target: target, series: series, marker-style: marker-style,
          marker-position: marker-position, stroke: stroke, fill: fill, radius: radius,
          z-index: z-index, padding: padding, region-shape: region-shape, layer: layer, inline: inline)
      } else if mark-type == "phantom" {
        deixis-phantom-mark(id: owner, _family: "inline-note", data: data, z-index: z-index, numbering: numbering,
          marker: marker, target: target, series: series)
      } else {
        deixis-inline-mark(mark-content, id: owner, _family: "inline-note", data: data, numbering: numbering, marker: marker,
          target: target, series: series, marker-style: marker-style, marker-position: marker-position,
          inline-mode: inline-mode, stroke: stroke, fill: fill, radius: radius, z-index: z-index)
      }
    }
    // An inline aside reads as part of the sentence: separate it with a space.
    let emit(owner) = if inline { [#render-mark(owner) #render-body(owner)] } else { [#render-mark(owner)#render-body(owner)] }
    if id == none { _deixis-with-auto-id(emit) } else { context emit(id) }
  }
  _deixis-replayable(if args.pos().len() > 1 { args.pos().first() },
    [#_deixis-scope-target-hint(target)#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: if series == auto { "default" } else { series })
}
