#import "core.typ": *
#import "inline-note.typ": *
#import "region-note.typ": *

/// A standalone body content of a footnote.
///
/// The body of the footnote is rendered at the bottom of the page or minipage.
///
/// ```info
/// Since footnotes can interfere with the main layout, there is no easy way to implement a non-native footnote function.
/// This _hacky_ function internally calls `#std.footnote` if the note is page-lavel.
/// ```
///
/// ```example
/// The evening sky was painted in a deep, haunting
/// #deixis-inline-mark(id: <smalt>)[smalt]
/// that made the first stars appear like diamonds on velvet.
///
/// #deixis-footnote-body(id: <smalt>)[A deep blue pigment made from powdered glass colored with cobalt oxide.]
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
/// - render-single (auto, function): A custom render function for the inner layout of the body.
/// - container-func (auto, function): A custom container wrapper for the body block.
/// - ..args (arguments): Only accepts named arguments, which are forwarded to `container-func`.
///
/// -> content
#let deixis-footnote-body(
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
  if args.pos().len() > 0 { panic("deixis: #deixis-footnote-body accepts at most 1 positional argument [body].") }
  let container-args = (stroke: stroke, fill: fill, radius: radius) + args.named()

  let series = if series == auto { "default" } else { series }

  let render-celibate(sys, celibate-id) = {
    let body = deixis-utils._deixis-trim-content(body)
    let resolved = _deixis-resolve-target(sys, target)

    let b-styles = _deixis-resolve-body-styles(sys, "footnote", ..container-args)
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

    let note-data = (
      internal-id: celibate-id,
      target-id: resolved.render-id,
      inst-id: resolved.inst-id,
      series: series,
      count: none,
      marker-str: none,
      mark-lbl: none,
      body-lbl: none,
      label: label,
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
      styles: b-styles,
      render-group: active-group-renderer,
    )

    let target-is-page = resolved.render-id == "page"
    let page-engine-active = sys.at("override-page-footnotes", default: true)
    let use-reserver = target-is-page and page-engine-active

    let c-size = text.size
    let c-font = text.font
    let c-weight = text.weight
    let c-style = text.style
    let c-leading = par.leading
    let c-spacing = par.spacing
    let c-justify = par.justify

    let meta = [#metadata(note-data)<deixis-footnote>]
    if target-is-page {
      let exact-rendered = active-renderer(note-data + (disable-links: use-reserver), gap: c-gap)

      let reserver = {
        let freeze = counter(std.footnote).update(n => n - 1)
        set footnote.entry(clearance: 0pt, separator: none)

        let r-body = block(width: 100%, above: 0pt, below: 0pt, spacing: 0pt)[
          #if use-reserver {
            place(left, [#metadata(note-data)<deixis-reserver-left>])
          }
          #if use-reserver {
            place(right, [#metadata(none)<deixis-reserver-right>])
          }
          #set text(size: c-size, font: c-font, weight: c-weight, style: c-style)
          #set par(leading: c-leading, spacing: c-spacing, justify: c-justify)
          #if use-reserver { hide(exact-rendered) } else { exact-rendered }
        ]
        box(width: 0pt, hide(std.footnote(r-body, numbering: _ => none)) + freeze)
      }
      [#meta#reserver]
    } else {
      [#meta]
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
    let current-target-uid = if id == deixis-auto-id {
      sys.at("last-auto-uid", default: none)
    } else {
      sys.at("id-index", default: (:)).at(str(id), default: none)
    }

    if current-target-uid == none { return sys }

    let new-notes = sys.at("notes", default: (:))
    let new-label-index = sys.at("label-index", default: (:))

    let payload = new-notes.at(current-target-uid)
    payload.insert("body-type", "footnote")
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

    let page-engine-active = sys.at("override-page-footnotes", default: true)
    let target-is-page = resolved.render-id == "page"
    let use-reserver = target-is-page and page-engine-active

    let saved-styles = reg.at("styles", default: (:))
    let merged-styles = _deixis-merge-styles(saved-styles, container-args)

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

    let note-data = (
      internal-id: internal-id,
      target-id: resolved.render-id,
      inst-id: resolved.inst-id,
      series: series,
      count: count,
      marker-str: marker-str,
      mark-lbl: mark-lbl,
      body-lbl: body-lbl,
      label: label,
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
      styles: b-styles,
      render-group: active-group-renderer,
    )

    let meta = [#metadata(note-data)<deixis-footnote>]
    if target-is-page {
      let c-size = text.size
      let c-leading = par.leading
      let c-spacing = par.spacing
      let c-justify = par.justify

      let exact-rendered = active-renderer(note-data + (disable-links: use-reserver), gap: c-gap)

      let reserver = {
        let freeze = counter(std.footnote).update(n => n - 1)
        set footnote.entry(clearance: 0pt, separator: none)

        let r-body = block(width: 100%, above: 0pt, below: 0pt, spacing: 0pt)[
          #if use-reserver { place(left, [#metadata(note-data)<deixis-reserver-left>]) }
          #if use-reserver { place(right, [#metadata(none)<deixis-reserver-right>]) }
          #set text(size: c-size)
          #set par(leading: c-leading, spacing: c-spacing, justify: c-justify)
          #if use-reserver { hide(exact-rendered) } else { exact-rendered }
        ]

        box(width: 0pt, hide(std.footnote(r-body, numbering: _ => none)) + freeze)
      }

      [#meta#reserver]
    } else {
      [#meta]
    }
  }
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
/// - id (none, str, label): A unique identifier linking an existing mark to the body internally. If `none`, a mark will be created.
/// - numbering (auto, str, function): The numbering style for the footnote marker.
/// - marker (auto, content): A hardcoded marker to use instead of the automatic counter.
/// - target (int, label, str): The specific block/minipage counter this note belongs to.
/// - series (str): The counter series this note belongs to. Defaults to `"default"`.
/// - label (none, label): An optional `label` to attach to the rendered body.
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
/// - container-func (auto, function): A custom container wrapper for the body block.
///
/// -> content
#let deixis-footnote(
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
  /// A custom render function for the inner layout of the body.
  /// -> auto | function
  render-single: auto,
  /// A custom container wrapper for the body block.
  /// -> auto | function
  container-func: auto,
) = {
  let pos = args.pos()
  if pos.len() > 2 { panic("deixis: #deixis-footnote accepts at most 2 positional arguments: [mark][body]") }
  let mark-content = if pos.len() > 1 { pos.first() } else { none }
  let body = if pos.len() > 0 { pos.last() } else { none }

  let mark-type = _deixis-resolve-mark-type(mark-type, pins: pins)

  if id != none {
    return deixis-footnote-body(
      body,
      id: id,
      target: target,
      label: label,
      marker-style: marker-style,
      backlink: backlink,
      stroke: stroke,
      fill: fill,
      radius: radius,
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
    deixis-footnote-body(
      body,
      id: target-id,
      target: target,
      label: label,
      marker-style: marker-style,
      backlink: backlink,
      stroke: stroke,
      fill: fill,
      radius: radius,
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

// Footnote overlay
#let _deixis-page-footnotes-overlay() = context {
  let current-page = here().page()
  let left-probes = query(<deixis-reserver-left>).filter(n => n.location().page() == current-page)
  let right-probes = query(<deixis-reserver-right>).filter(n => n.location().page() == current-page)

  if left-probes.len() == 0 { return }

  let columns = (:)
  for (i, probe) in left-probes.enumerate() {
    let x-key = str(calc.round(probe.location().position().x.pt(), digits: 1))
    let arr = columns.at(x-key, default: ())
    arr.push((left: probe, right: right-probes.at(i)))
    columns.insert(x-key, arr)
  }

  for (x-key, probes-in-col) in columns {
    let first-probe = probes-in-col.first().left
    let start-x = first-probe.location().position().x
    let start-y = first-probe.location().position().y

    let col-width = probes-in-col.first().right.location().position().x - start-x

    let col-notes-data = ()
    let seen = ()
    for p in probes-in-col {
      let k = str(p.left.value.internal-id)
      if k not in seen {
        seen.push(k)
        col-notes-data.push(p.left.value)
      }
    }

    let first-note = col-notes-data.first()
    let active-group-renderer = first-note.render-group
    let c-gap = first-note.gap
    let c-clearance = first-note.clearance
    let c-separator = first-note.separator

    place(
      top + left,
      dx: start-x,
      dy: start-y,
      block(width: col-width, {
        if c-separator != none {
          let sep-block = block(width: col-width, c-separator)
          let sep-h = measure(sep-block).height
          place(top + left, dy: -c-gap - sep-h, sep-block)
        }

        let unique-series = ()
        for data in col-notes-data {
          let s = data.at("series", default: "default")
          if s not in unique-series { unique-series.push(s) }
        }

        for (i, current-series) in unique-series.enumerate() {
          let series-notes = col-notes-data.filter(n => n.at("series", default: "default") == current-series)
          // For now, page-level footnotes can/should only use the gap of the first note
          active-group-renderer(series-notes, gap: c-gap)
        }
      }),
    )
  }
}
