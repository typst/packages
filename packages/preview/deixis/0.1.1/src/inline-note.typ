#import "core.typ": *

// Internal inline mark renderer
#let _deixis-inline-mark(
  body,
  marker-style: it => super(it),
  marker-position: auto,
  inline-mode: auto,
  stroke: auto,
  fill: auto,
  radius: auto,
  marker-str: none,
  mark-lbl: none,
  body-lbl: none,
) = context {
  _deixis-check-setup-state()

  let render-formatting(content) = {
    if content == none { return none }

    if inline-mode == "text-fill" {
      return text(fill: stroke.paint, content)
    }

    let _underline(it, stroke: auto, ..args) = if stroke != none { std.underline(it, stroke: stroke, ..args) } else {
      it
    }

    let new-body = content
    if inline-mode not in ("none", none) {
      let padding = text-padding
      padding.x *= 2
      if inline-mode in ("box", "underline") { new-body = _underline(stroke: stroke, offset: padding.bottom, new-body) }
      if fill not in (auto, none) {
        new-body = highlight(new-body, fill: fill, radius: if inline-mode not in ("box", "parentheses") {
          radius
        } else { 0pt })
      }
      let cap-line(side) = box(
        height: 0pt,
        width: padding.x,
        outset: (bottom: padding.bottom, top: padding.top),
        stroke: (rest: stroke, (if side == left { "right" } else { "left" }): none),
        fill: fill,
        radius: (repr(side): radius),
      )
      if inline-mode == "box" {
        new-body = _underline(stroke: stroke, offset: -padding.top, [#cap-line(left)#new-body#cap-line(right)])
      } else if inline-mode == "parentheses" {
        new-body = [#cap-line(left)#new-body#cap-line(right)]
      }
    }
    return new-body
  }

  let safe-lbl = if mark-lbl != none { [#metadata(none)#mark-lbl] } else { none }

  let inline-marker = if mark-lbl != none and body-lbl != none {
    if marker-str == none {
      [#safe-lbl]
    } else {
      let body-exists = query(selector(body-lbl)).len() > 0
      let raw-m = marker-style(marker-str)
      if body-exists {
        [#safe-lbl#std.link(body-lbl, raw-m)]
      } else {
        [#safe-lbl#raw-m]
      }
    }
  } else {
    none
  }

  let is-left = marker-position in ("left", left)
  if body == none {
    let glue = [#h(0pt, weak: true)#sym.wj]
    if inline-marker != none {
      return [#glue#inline-marker]
    } else {
      return [#glue]
    }
  } else {
    let combined-body = if inline-marker != none {
      if is-left { [#inline-marker#body] } else { [#body#inline-marker] }
    } else { body }

    return render-formatting(combined-body)
  }
}

/// A standalone body content of an inline note.
///
/// ```example
/// The garden was filled with the
/// #deixis-inline-mark(id: <apricity>)[apricity]
/// of a pale winter sun.
///
/// #deixis-inline-note-body(
///   id: <apricity>,
///   stroke: maroon,
///   fill: maroon.transparentize(95%),
/// )[
///   *Apricity:* The warmth of the sun in winter.
/// ]
/// ```
///
/// - body (content): The actual text or content of the note.
/// - id (none, str, label): A unique identifier linking this body to its corresponding mark.
/// - target (auto, int, label, str): The specific block/minipage render context this note belongs to.
/// - series (auto, str): The counter series this note belongs to.
/// - label (none, label): An optional `label` to attach to the rendered body block.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the number/marker.
/// - backlink (auto, bool, str): Whether to generate a clickable backlink returning the reader to the mark. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`. Only used when `inline: true`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - inline (bool): If `true`, the body is rendered as if it is ```ref #deixis-inline-mark```.
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the body block.
/// - ..args (arguments): Only accepts named arguments, which are forwarded to `container-func`.
///
/// -> content
#let deixis-inline-note-body(
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
  /// If `true`, the body is rendered as if it is @deixis-inline-mark.
  ///
  /// ```example
  /// The city streets were filled with the psithurism #deixis-inline-mark(id: <psithurism>) of swaying trees.
  /// It was a comforting melody, #deixis-inline-note-body(id: <psithurism>, inline: true)[the sound of wind whispering through leaves].
  /// ```
  ///
  /// -> bool
  inline: false,
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
  if args.pos().len() > 0 { panic("deixis: #deixis-inline-note-body accepts at most 1 positional argument [body].") }
  let styles = (stroke: stroke, fill: fill, radius: radius) + args.named()

  let series = if series == auto { "default" } else { series }

  let render-celibate(sys, celibate-id) = {
    let body = deixis-utils._deixis-trim-content(body)
    let resolved = _deixis-resolve-target(sys, target)

    let m-styles = _deixis-resolve-mark-styles(sys, "inline-mark", inline-mode: inline-mode, ..styles)
    let b-styles = _deixis-resolve-body-styles(sys, "inline-note", ..styles)

    let c-body-style = _deixis-resolve-typed-param(sys, auto, "body-style", "inline-note")
    let c-indent = _deixis-resolve-typed-param(sys, auto, "indent", "inline-note")
    let c-marker-gap = _deixis-resolve-typed-param(sys, auto, "marker-gap", "inline-note")

    let active-renderer = _deixis-resolve-typed-param(sys, render-single, "render-single", "inline-note")
    let active-container = _deixis-resolve-typed-param(sys, container-func, "container-func", "inline-note")

    let note-data = (
      internal-id: celibate-id,
      target-id: resolved.render-id,
      inst-id: resolved.inst-id,
      mark-lbl: none,
      body-lbl: none,
      label: label,
      series: series,
      count: none,
      marker-str: none,
      body: body,
      mark-marker-style: auto,
      body-marker-style: auto,
      body-style: c-body-style,
      backlink: false,
      indent: c-indent,
      marker-gap: c-marker-gap,
      styles: b-styles,
      container-func: active-container,
    )

    let meta = [#metadata(note-data)<deixis-inline-note>]

    if inline {
      [#meta#_deixis-inline-mark(body, ..m-styles)]
    } else {
      [#meta#active-renderer(note-data)]
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
    payload.insert("body-type", "inline-note")
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
      local-marker-style,
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
      styles: b-styles,
      render-single: active-renderer,
      container-func: active-container,
    )

    let meta = [#metadata(note-data)<deixis-inline-note>]

    if inline {
      let rendered-body = deixis-native-render-single(note-data + (container-func: (body, ..args) => box(body)))

      [#meta#_deixis-inline-mark(
          rendered-body,
          marker-style: mark-marker-style,
          ..m-styles,
        )]
    } else {
      [#meta#active-renderer(note-data)]
    }
  }
}

/// An inline text mark with a visual marker.
///
/// This function drops a numbered (or custom) marker into the text and registers its location in the
/// state engine.
///
/// ```example
/// Inline note is usually just a single marker#deixis-inline-mark(id: <celibate-inline-note1>).
/// Alternatively, it can wrap #deixis-inline-mark(id: <celibate-inline-note2>)[a text content of arbitrary length with it].
/// ```
///
/// - ..args (arguments): Accepts up to one positional arguments: `[body]`.
/// - numbering (auto, str, function): The numbering style (e.g., `"1"`, `"a"`) for the generated marker.
/// - marker (auto, content): A hardcoded marker (like a symbol) to use instead of the automatic counter.
/// - target (int, label, str): The specific block/minipage counter context this mark belongs to.
/// - series (str): The counter series this mark belongs to. Defaults to `"default"`.
/// - id (none, str, label): A unique identifier linking this mark to its corresponding body.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the generated marker.
/// - marker-position (auto, alignment): The alignment/positioning of the marker relative to its anchor.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
///
/// -> content
#let deixis-inline-mark(
  /// Accepts up to one positional arguments: `[body]`.
  /// -> arguments
  ..args,
  /// The numbering style (e.g., `"1"`, `"a"`) for the generated marker.
  /// -> auto | str | function
  numbering: auto,
  /// A hardcoded marker (like a symbol) to use instead of the automatic counter.
  /// -> auto | content
  marker: auto,
  /// The specific block/minipage counter context this mark belongs to.
  /// -> int | label | str
  target: 0,
  /// The counter series this mark belongs to.
  /// -> str
  series: "default",
  /// A unique identifier linking this mark to its corresponding body.
  /// -> none | str | label
  id: none,
  /// A custom styling function `(string) => content` for the generated marker.
  /// -> auto | function
  marker-style: auto,
  /// The alignment/positioning of the marker relative to its anchor.
  ///
  /// ```example
  /// #deixis-inline-mark(marker-position: left, id: <celibate-inline-note3>)[
  ///   This noted content has its mark placed on the left side.
  /// ]
  /// ```
  ///
  /// -> auto | alignment
  marker-position: auto,
  /// The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
  ///
  /// ```example
  /// #deixis-inline-mark(inline-mode: "highlight")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "box")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "parentheses")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "underline")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "text-fill")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "none")[Marked content]
  /// ```
  ///
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
) = {
  let named = args.named()
  if named.len() > 0 {
    panic(
      "deixis: Unknown named argument(s) "
        + repr(args.named().keys())
        + ". Styling arguments are not allowed in mark-only note functions.",
    )
  }

  let styles = (stroke: stroke, fill: fill, radius: radius)

  let pos = args.pos()
  if pos.len() > 1 { panic("#deixis-inline-mark accepts at most 1 positional argument [body].") }
  let body = if pos.len() == 1 { deixis-utils._deixis-trim-content(pos.first()) } else { none }

  if id == none {
    return context {
      let sys = deixis-system.get()
      let m-styles = _deixis-resolve-mark-styles(
        sys,
        "inline-mark",
        marker-position: marker-position,
        inline-mode: inline-mode,
        stroke: stroke,
        fill: fill,
        radius: radius,
      )

      let visual-mark = _deixis-inline-mark(
        body,
        marker-position: m-styles.marker-position,
        inline-mode: m-styles.inline-mode,
        fill: m-styles.fill,
        stroke: m-styles.stroke,
        radius: m-styles.radius,
      )

      let meta-payload = (
        internal-id: none,
        mark-lbl: none,
        body-lbl: none,
        marker-str: none,
        marker-width: 0pt,
        text-size: text.size,
        styles: m-styles,
      )

      [#visual-mark#metadata(meta-payload)<deixis-inline-mark>]
    }
  }

  _deixis-validate-target(target)

  deixis-system.update(sys => {
    if id != none and str(id) in sys.at("id-index", default: (:)) { return sys }

    let new-note-uid = sys.at("note-uid", default: 0) + 1
    let uid-str = str(new-note-uid)

    let resolved = _deixis-resolve-target(sys, target)
    let full-c-id = resolved.count-id + ":" + series

    let new-counters = sys.counters
    let current-count = new-counters.at(full-c-id, default: 0) + 1
    new-counters.insert(full-c-id, current-count)

    let new-blocks = sys.blocks
    if resolved.render-id != "page" and type(target) in (str, label) and str(target) not in new-blocks {
      new-blocks.insert(str(target), (
        render-id: resolved.render-id,
        count-id: resolved.count-id,
        inst-id: resolved.inst-id,
      ))
    }

    let c-numbering = _deixis-resolve-typed-param(sys, numbering, "numbering", "inline-mark")
    let m-styles = _deixis-resolve-mark-styles(
      sys,
      "inline-mark",
      marker-position: marker-position,
      inline-mode: inline-mode,
    )

    let trimmed-mark = deixis-utils._deixis-trim-content(body)

    let payload = (
      internal-id: new-note-uid,
      target-id: resolved.render-id,
      inst-id: resolved.inst-id,
      series: series,
      count: current-count,
      numbering: c-numbering,
      marker: marker,
      mark-type: "inline",
      marker-style: marker-style,
      marker-position: m-styles.marker-position,
      inline-mode: m-styles.inline-mode,
      styles: styles,
      has-mark-body: trimmed-mark != none,
    )

    let new-notes = sys.at("notes", default: (:))
    let new-id-index = sys.at("id-index", default: (:))

    new-notes.insert(uid-str, payload)

    if id == deixis-auto-id {
      sys.insert("last-auto-uid", uid-str)
    } else if id != none {
      let id-str = str(id)
      if id-str in new-id-index and not id-str.starts-with("deixis-auto-") {
        panic("deixis: Duplicate note ID detected: '" + id-str + "'.\nNote IDs must be unique across the document.")
      }
      new-id-index.insert(id-str, uid-str)
    }

    return (
      ..sys,
      note-uid: new-note-uid,
      blocks: new-blocks,
      counters: new-counters,
      notes: new-notes,
      id-index: new-id-index,
    )
  })

  context {
    let sys = deixis-system.get()

    let target-uid = if id == deixis-auto-id { sys.at("last-auto-uid", default: none) } else if id != none {
      sys.id-index.at(str(id), default: none)
    } else { none }
    let reg = if target-uid != none { sys.notes.at(target-uid, default: none) } else { none }

    let saved-styles = if reg != none { reg.at("styles", default: (:)) } else { styles }
    let c-styles = _deixis-merge-styles(saved-styles, styles, allowed-keys: ("stroke", "fill", "radius"))

    let m-styles = _deixis-resolve-mark-styles(
      sys,
      "inline-mark",
      marker-position: marker-position,
      inline-mode: inline-mode,
      ..c-styles,
    )

    if reg == none {
      return _deixis-inline-mark(
        body,
        marker-position: m-styles.marker-position,
        inline-mode: m-styles.inline-mode,
        fill: m-styles.fill,
        stroke: m-styles.stroke,
        radius: m-styles.radius,
      )
    }

    let internal-id = reg.internal-id
    let count = reg.count
    let c-numbering = reg.at("numbering", default: "1")
    let c-marker = reg.at("marker", default: auto)

    let marker-str = if c-marker != auto {
      c-marker
    } else if c-numbering != none {
      std.numbering(c-numbering, count)
    } else {
      none
    }

    let mark-lbl = std.label("deixis-mark-" + str(internal-id))
    let body-lbl = std.label("deixis-body-" + str(internal-id))

    let mark-marker-style = _deixis-resolve-typed-param(
      sys,
      marker-style,
      "marker-style",
      "inline-mark",
      component: "mark",
    )

    let visual-mark = _deixis-inline-mark(
      body,
      marker-style: mark-marker-style,
      marker-position: m-styles.marker-position,
      inline-mode: m-styles.inline-mode,
      fill: m-styles.fill,
      stroke: m-styles.stroke,
      radius: m-styles.radius,
      marker-str: marker-str,
      mark-lbl: mark-lbl,
      body-lbl: body-lbl,
    )

    let meta-payload = (
      internal-id: internal-id,
      mark-lbl: mark-lbl,
      body-lbl: body-lbl,
      marker-str: marker-str,
      marker-width: if marker-str != none { measure(mark-marker-style(marker-str)).width } else { 0pt },
      text-size: text.size,
      styles: m-styles,
    )

    [#visual-mark#metadata(meta-payload)<deixis-inline-mark>]
  }
}

/// A semantic mark that is registered without leaving _any_ visible trace in the text.
///
/// Phantom marks do increment the counter and register their position in the state engine, but leave
/// no visual footprint in the paragraph.
/// This is useful for creating semantic anchors or side-channel annotations that shouldn't disrupt the reading flow.
///
/// ```example
/// //| sandbox-mode: "page"
/// The library was constructed with massive stone walls to regulate the indoor climate naturally across the changing seasons.
/// #deixis-phantom-mark(id: <phantom>, marker: none)
/// This architectural choice ensured that centuries of fragile manuscripts remained perfectly preserved without the need for artificial climate control.
///
/// #deixis-margin-note-body(id: <phantom>)[Thick stone absorbs daytime heat and releases it at night.]
/// ```
///
/// - id (none, str, label): A unique identifier for linking this mark to a decoupled body.
/// - numbering (auto, str, function): The numbering style (used for the body and outline, though invisible here).
/// - target (int, label, str): The specific block/minipage counter context this mark belongs to.
/// - series (str): The counter series this mark belongs to. Defaults to `"default"`.
/// - marker (auto, content): A hardcoded marker override (used for the body and outline, though invisible here).
///
/// -> content
#let deixis-phantom-mark(
  /// A unique identifier for linking this mark to a decoupled body.
  /// -> none | str | label
  id: none,
  /// The numbering style (used for the body and outline, though invisible here).
  /// -> auto | str | function
  numbering: auto,
  /// The specific block/minipage counter context this mark belongs to.
  /// -> int | label | str
  target: 0,
  /// The counter series this mark belongs to.
  /// -> str
  series: "default",
  /// A hardcoded marker override (used for the body and outline, though invisible here).
  /// -> auto | content
  marker: auto,
) = {
  if id == none {
    return
  }

  _deixis-validate-target(target)

  deixis-system.update(sys => {
    if str(id) in sys.at("id-index", default: (:)) { return sys }

    let new-note-uid = sys.at("note-uid", default: 0) + 1
    let uid-str = str(new-note-uid)
    let resolved = _deixis-resolve-target(sys, target)
    let full-c-id = resolved.count-id + ":" + series

    let new-counters = sys.counters
    let current-count = new-counters.at(full-c-id, default: 0) + 1
    new-counters.insert(full-c-id, current-count)

    let c-numbering = _deixis-resolve-typed-param(sys, numbering, "numbering", "inline-mark")

    let payload = (
      internal-id: new-note-uid,
      target-id: resolved.render-id,
      inst-id: resolved.inst-id,
      series: series,
      count: current-count,
      numbering: c-numbering,
      marker: marker,
      mark-type: "phantom",
      styles: (:),
      has-mark-body: false,
    )

    let new-notes = sys.at("notes", default: (:))
    let new-id-index = sys.at("id-index", default: (:))

    new-notes.insert(uid-str, payload)
    if id == deixis-auto-id {
      sys.insert("last-auto-uid", uid-str)
    } else if id != none {
      new-id-index.insert(str(id), uid-str)
    }

    return (
      ..sys,
      note-uid: new-note-uid,
      counters: new-counters,
      notes: new-notes,
      id-index: new-id-index,
    )
  })

  context {
    let sys = deixis-system.get()

    let target-uid = if id == deixis-auto-id { sys.at("last-auto-uid", default: none) } else {
      sys.id-index.at(str(id), default: none)
    }
    if target-uid == none { return none }
    let reg = sys.notes.at(target-uid)

    if reg == none {
      return
    }

    let internal-id = str(reg.internal-id)

    let mark-lbl = std.label("deixis-mark-" + internal-id)
    let body-lbl = std.label("deixis-body-" + internal-id)

    let meta-payload = (
      internal-id: internal-id,
      mark-lbl: mark-lbl,
      body-lbl: body-lbl,
      marker-str: none,
      marker-width: 0pt,
      text-size: text.size,
      styles: (:),
    )

    [#metadata(meta-payload)<deixis-phantom-mark>#metadata(none)#mark-lbl]
  }
}
