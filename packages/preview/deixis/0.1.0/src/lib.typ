#import "core.typ": *
#import "counter.typ": *
#import "minipage.typ": *

#import "inline-note.typ": *
#import "region-note.typ": *
#import "footnote.typ": *
#import "endnote.typ": *
#import "margin-note.typ": *
#import "inset-note.typ": *

#import "outline.typ": *
#import "reference.typ": *

/// Initializes the `deixis` state engine and layout overlays.
///
/// This function *must* wrap your document `#show: deixis-setup-notes.with(...)` before any other `deixis` functionality can be used.
///
/// ```warning
/// `deixis` uses the page foreground and background to display some notes.
/// Any attempt to modify the foreground or background after `#show: deixis-setup-notes` will completely overwrite the setup.
/// Thus, you must always put `#set page(background: ..., foreground: ...)` before `#show: deixis-setup-notes`.
/// ```
///
/// - body (content): The main document content to wrap.
/// - foreground (none, content): Custom content to inject into the foreground overlay layer.
/// - background (none, content): Custom content to inject into the background overlay layer.
/// - override-page-footnotes (bool): If `true`, page-level footnotes will be rendered on the foreground.
///
/// -> content
#let deixis-setup-notes(
  /// The main document content to wrap.
  /// -> content
  body,
  /// Custom content to inject into the foreground overlay layer.
  /// -> none | content
  foreground: none,
  /// Custom content to inject into the background overlay layer.
  /// -> none | content
  background: none,
  /// If `true`, page-level footnotes will be rendered on the foreground.
  ///
  /// ```info
  /// Foreground overlay allows some behaviors like grouping footnotes by series or aligned marker.
  /// ```
  ///
  /// -> bool
  override-page-footnotes: true,
) = context {
  let native-bg = page.background
  let native-fg = page.foreground

  deixis-setup-state.update(true)

  // override page footnotes
  let fn-sep = if override-page-footnotes { none } else {
    _deixis-resolve-typed-param(none, auto, "separator", "footnote")
  }
  let fn-clearance = _deixis-resolve-typed-param(none, auto, "clearance", "footnote")
  let fn-gap = _deixis-resolve-typed-param(none, auto, "gap", "footnote")
  let fn-indent = _deixis-resolve-typed-param(none, auto, "indent", "footnote")

  show: it => if fn-sep != auto {
    set footnote.entry(separator: fn-sep)
    it
  } else { it }
  show: it => if fn-clearance != auto {
    set footnote.entry(clearance: fn-clearance)
    it
  } else { it }
  show: it => if fn-gap != auto {
    set footnote.entry(gap: fn-gap)
    it
  } else { it }
  show: it => if fn-indent != auto {
    set footnote.entry(indent: fn-indent)
    it
  } else { it }

  deixis-system.update(sys => {
    let fg-layers = sys.at("fg-layers", default: (:))
    let bg-layers = sys.at("bg-layers", default: (:))

    // region-mark
    bg-layers.insert("region-marks", place(top + left, context { _deixis-region-marks-overlay(layer: "background") }))
    fg-layers.insert("region-marks", place(top + left, context { _deixis-region-marks-overlay(layer: "foreground") }))
    // footnote
    sys.insert("override-page-footnotes", override-page-footnotes)
    if override-page-footnotes {
      fg-layers.insert("footnotes", context { _deixis-page-footnotes-overlay() })
    }
    // inset-note
    bg-layers.insert("inset-notes", place(top + left, context { _deixis-inset-notes-overlay(layer: "background") }))
    fg-layers.insert("inset-notes", place(top + left, context { _deixis-inset-notes-overlay(layer: "foreground") }))
    // margin-note
    fg-layers.insert("margin-notes", place(top + left, context { _deixis-margin-notes-overlay() }))

    if native-fg != none { fg-layers.insert("native-fg", native-fg) }
    if native-bg != none { bg-layers.insert("native-bg", native-bg) }

    if foreground not in (auto, none) { fg-layers.insert("user-fg", place(top + left, foreground)) }
    if background not in (auto, none) { bg-layers.insert("user-bg", place(top + left, background)) }
    sys.insert("fg-layers", fg-layers)
    sys.insert("bg-layers", bg-layers)

    return sys
  })

  set page(
    background: context {
      let layers = deixis-system.get().at("bg-layers", default: (:))
      if "native-bg" in layers { layers.at("native-bg") }
      if "user-bg" in layers { layers.at("user-bg") }

      for (name, content) in layers {
        if name != "user-bg" { content }
      }
    },
    foreground: context {
      let layers = deixis-system.get().at("fg-layers", default: (:))
      for (name, content) in layers {
        if name != "user-fg" { content }
      }

      if "user-fg" in layers { layers.at("user-fg") }
      if "native-fg" in layers { layers.at("native-fg") }
    },
  )

  show: deixis-show-refs
  body
}

/// Dynamically updates the global `deixis` configuration mid-document.
///
/// This function acts like a standard Typst `#set` rule for the internal `deixis` state. It applies
/// your new configuration to all subsequent notes within the current scope.
///
/// ```tip
/// *Type-Specific Styling:* All parameters accept either a global value or a `dictionary` targeting specific note types
/// (e.g., `stroke: (margin-note: red, inset-note: blue)`).
/// The `dictionary` will be interpreted as scope specific and not a global value if it contains either note-scope keys or component-scope keys.
/// - Note-scope keys: #(deixis-mark-types + deixis-note-types).
/// - Component-scope keys: #(deixis-note-components).
///   - `"nodes"` indicates both `"mark"` and `"body"` (excluding `"link"`).
/// - Wildcard key: `"rest"` indicates anything else.
/// ```
///
/// - numbering (auto, str, function, dictionary): The numbering style for markers.
/// - marker-style (auto, function, dictionary): The styling function `(content) => content` for note markers.
/// - body-style (auto, function, dictionary): The styling function `(content) => content` for note bodies.
/// - backlink (auto, bool, str, dictionary): Enables or disables clickable backlinks from bodies to marks. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - marker-position (auto, alignment, dictionary): Mark marker placement.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
/// - stroke (auto, stroke, none, dictionary): The border stroke.
/// - fill (auto, color, none, dictionary): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - link (auto, str, dictionary): The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
/// - link-marks (auto, str, dictionary): The connector arrowhead style. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
/// - separator (auto, content, none, dictionary): The separator line for note groups.
/// - clearance (auto, length, dictionary): Vertical spacing before note groups.
/// - gap (auto, length, dictionary): Vertical spacing between adjacent notes.
/// - marker-gap (auto, length, dictionary): Horizontal spacing between the marker and the body text.
/// - indent (auto, length, dictionary): The indentation applied to the note body.
/// - margin-layout (auto, str): The layout engine for margin notes. Choices: `"adaptive"` | `"flow"` | `"exact"`.
/// - min-margin-width (auto, length): Minimum margin width to put margin notes.
/// - side-strategy (auto, str): Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
/// - mark-align (auto, alignment, dictionary): How margin notes align vertically relative to their marks.
/// - mark-align-strictness (auto, str): How strictly to align margin notes to their marks. Choices: `"strict"` | `"loose"` | `"none"`.
/// - spillover (auto, bool): Allow margin notes to spill over page boundaries.
/// - region-shape (auto, function): Shape drawing function for region marks.
/// - layer (auto, str): The rendering layer for region marks and inset notes. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - render-single (auto, function, dictionary): Note body rendering function.
/// - render-group (auto, function, dictionary): Group rendering function for grouped notes (footnote and endnote).
/// - container-func (auto, function, dictionary): Note body container function with signature `(content, ..args) => content`.
///
/// -> content
#let deixis-set(
  /// The numbering style for the marker.
  ///
  /// ```example
  /// #deixis-set(numbering: "i")
  /// #deixis-footnote[A note with roman numbering.]
  /// ```
  ///
  /// -> auto | str | function | dictionary
  numbering: auto,
  /// The styling function `(content) => content` for note markers.
  ///
  /// ```example
  /// #deixis-set(marker-style: (
  ///   mark: it => text(super(it), fill: red),
  ///   body: it => text([#it.], fill: blue, weight: "bold"))
  /// )
  /// #deixis-footnote[A note with custom mark marker style and body marker style.]
  /// ```
  ///
  /// -> auto | function | dictionary
  marker-style: auto,
  /// The styling function `(content) => content` for note bodies.
  ///
  /// ```example
  /// #deixis-set(body-style: it => text(it, fill: blue, weight: "semibold"))
  /// #deixis-footnote[A note with custom body style.]
  /// ```
  ///
  /// ```info
  /// Setting `body-style` will override the default styling, i.e. `it => text(size: 0.85em, it)`.
  /// Instead, applying custom styling directly to the body content does not.
  /// ```
  ///
  /// ```example
  /// #deixis-footnote[#text(fill: blue, weight: "semibold")[Another note with custom body style.]]
  /// ```
  ///
  /// -> auto | function | dictionary
  body-style: auto,
  /// Enables or disables clickable backlinks from bodies to marks. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
  ///
  /// ```example
  /// #deixis-set(backlink: true)
  /// #deixis-footnote(label: <deixis-set.backlink>)[A note with backlink.]
  /// #deixis-ref(<deixis-set.backlink>)
  /// ```
  ///
  /// -> auto | bool | str | dictionary
  backlink: auto,
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
  /// The border stroke.
  ///
  /// ```example
  /// #deixis-inset-note(
  ///   stroke: (mark: red, body: blue),
  ///   layer: "flow",
  /// )[A note with red mark stroke.][And blue body stroke.]
  /// ```
  ///
  /// -> auto | stroke | none | dictionary
  stroke: auto,
  /// The background fill color.
  ///
  /// ```example
  /// #deixis-inset-note(
  ///   stroke: none,
  ///   fill: (mark: red, body: blue),
  ///   layer: "flow",
  /// )[A note with red mark fill.][And blue body fill.]
  /// ```
  ///
  /// -> auto | color | none | dictionary
  fill: auto,
  /// The border radius.
  ///
  /// ```example
  /// #deixis-inset-note(
  ///   stroke: yellow,
  ///   fill: yellow.transparentize(95%),
  ///   radius: (mark: 0pt, body: 1em),
  ///   layer: "flow",
  /// )[A note with `0pt` mark radius.][And `1em` body radius.]
  /// ```
  ///
  /// -> auto | length | dictionary
  radius: auto,
  /// The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
  ///
  /// - `"none"`: The link is completely invisible.
  /// - `"straight-line"`: A direct, shortest-path line from the start to the end point.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "straight-line",
  ///   dx: 4em, dy: 3em,
  ///   layer: "flow",
  /// )[Note mark.][Note body.]
  /// ```
  /// - `"right-angle"`: Routes the link orthogonally (moving only horizontally and vertically) and smooths the turns with rounded corners (fillets).
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "right-angle",
  ///   dx: 4em, dy: 3em,
  ///   layer: "flow",
  /// )[Note mark.][Note body.]
  /// ```
  /// - `"chamfer"`: Similar to `"right-angle"`, but cuts the corners with diagonal straight lines (bevels) instead of rounding them.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "chamfer",
  ///   dx: 4em, dy: 3em,
  ///   layer: "flow",
  /// )[Note mark.][Note body.]
  /// ```
  /// - `"curve"`: Draws a smooth *Weighted Bessel Spline*.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "curve",
  ///   dx: 4em, dy: 3em,
  ///   layer: "flow",
  /// )[Note mark.][Note body.]
  /// ```
  /// - `"ccr"`: Draws a *Centripetal Catmull-Rom* spline, which is more stable compared to other curves and less prone to unnatural loops or aggressive bulges.
  /// - `"ucr"`: Draws a standard *Uniform Catmull-Rom* spline.
  ///
  /// ```tip
  /// Link type can be changed dynamically mid-path by declaring them in the `link-waypoints` parameters of the note functions.
  /// See @deixis-common-note-args.link-waypoints.
  /// ```
  ///
  /// -> auto | str | dictionary
  link: auto,
  /// The connector arrowhead style. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "straight-line",
  ///   link-marks: "both",
  ///   dx: 4em, dy: 3em,
  ///   layer: "flow",
  /// )[Note mark.][Note body.]
  /// ```
  ///
  /// -> auto | str | dictionary
  link-marks: auto,
  /// The separator line for note groups.
  ///
  /// ```info
  /// This only has effect on grouped notes (footnote and endnote).
  /// ```
  ///
  /// ```example
  /// #deixis-set(separator: line(length: 50%, stroke: (thickness: 0.5pt, dash: "dashed")))
  /// #deixis-footnote[A footnote separated by a dashed line.]
  /// ```
  ///
  /// See also #link("https://typst.app/docs/reference/model/footnote/#definitions-entry-separator")[std.footnote.entry.separator].
  ///
  /// -> auto | content | none | dictionary
  separator: auto,
  /// Vertical spacing before note groups.
  ///
  /// ```info
  /// This only has effect on grouped notes (footnote and endnote).
  /// ```
  ///
  /// ```example
  /// #deixis-set(clearance: 3em)
  /// #deixis-footnote[A note `3em`-spaced from the main content.]
  /// ```
  ///
  /// See also #link("https://typst.app/docs/reference/model/footnote/#definitions-entry-clearance")[std.footnote.entry.clearance].
  ///
  /// -> auto | length | dictionary
  clearance: auto,
  /// Vertical spacing between adjacent notes.
  ///
  /// ```info
  /// This only has effect on grouped notes (footnote and endnote) and margin note.
  /// ```
  ///
  /// ```example
  /// #deixis-set(gap: 1em)
  /// #deixis-footnote[Note A.]
  /// #deixis-footnote[Note B.]
  /// ```
  ///
  /// See also #link("https://typst.app/docs/reference/model/footnote/#definitions-entry-gap")[std.footnote.entry.gap].
  ///
  /// -> auto | length | dictionary
  gap: auto,
  /// Horizontal spacing between the marker and the body text.
  ///
  /// ```example
  /// #deixis-set(marker-gap: 1em)
  /// #deixis-footnote[A note with `marker-gap=1em`.]
  /// ```
  ///
  /// -> auto | length | dictionary
  marker-gap: auto,
  /// The indentation applied to the note body.
  ///
  /// ```example
  /// #deixis-set(indent: 3em)
  /// #deixis-footnote[A note with `indent=3em`.]
  /// ```
  ///
  /// See also #link("https://typst.app/docs/reference/model/footnote/#definitions-entry-indent")[std.footnote.entry.indent].
  ///
  /// -> auto | length | dictionary
  indent: auto,
  /// The layout engine for margin notes. Choices: `"adaptive"` | `"flow"` | `"exact"`.
  /// - `"adaptive"`: Apply a two-pass _rubber band algorithm_ to calculate the y-coordinates of all margin notes in the page; then use `#std.place` to put them into calculated positions.
  /// - `"flow"`: Put margin notes in a block container with interleaved `#v(space)`, where `space` is provisional inter-note gap converted to `fraction`; and let the Typst engine calculates their final positions.
  /// - `"exact"`: Put margin notes exactly where the marker is, ignore if they overlap or not.
  ///
  /// -> auto | str
  margin-layout: auto,
  /// Minimum margin width to put margin notes.
  ///
  /// ```example
  /// //| margin: (left: 1.2in, right: 0.5in, y: 0.05in)
  /// The margin of the minipage is set to `(left: 1.2in, right: 0.5in)`.
  /// #deixis-set(min-margin-width: 1in)
  /// #deixis-margin-note[This note prefers the left margin.]
  /// ```
  ///
  /// -> auto | length
  min-margin-width: auto,
  /// Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
  ///
  /// See @deixis-margin-note-body.side-strategy.
  ///
  /// -> auto | str
  side-strategy: auto,
  /// How margin notes align vertically relative to their marks.
  ///
  /// See @deixis-margin-note-body.mark-align.
  ///
  /// -> auto | alignment | dictionary
  mark-align: auto,
  /// How strictly to align margin notes to their marks. Choices: `"strict"` | `"loose"` | `"none"`.
  ///
  /// See @deixis-margin-note-body.mark-align-strictness.
  ///
  /// -> auto | str
  mark-align-strictness: auto,
  /// Allow margin notes to spill over page boundaries.
  ///
  /// See @deixis-margin-note-body.spillover.
  ///
  /// -> auto | bool
  spillover: auto,
  /// Shape drawing function for region marks.
  ///
  /// See @deixis-region-mark.region-shape.
  ///
  /// -> auto | function
  region-shape: auto,
  /// The rendering layer for region marks and inset notes. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// See @deixis-region-mark.layer.
  ///
  /// -> auto | str
  layer: auto,
  /// Note body rendering function.
  ///
  /// `render-single` is used in combination with `render-group`. `deixis` provides a few basic render functions:
  /// - `native`: _Almost_ pixel-identical to `std.footnote`.
  /// ```example
  /// #deixis-set(
  ///   render-single: deixis-native-render-single,
  ///   render-group: deixis-native-render-group,
  /// )
  /// #deixis-footnote[A normal note.]
  /// #deixis-footnote(marker: [long marker])[A note with very long marker, and also a long body.]
  /// ```
  /// - `default`: Body markers are aligned, but the notes are still prose-printed.
  /// ```example
  /// #deixis-set(
  ///   render-single: deixis-default-render-single,
  ///   render-group: deixis-default-render-group,
  /// )
  /// #deixis-footnote[A normal note.]
  /// #deixis-footnote(marker: [long marker])[A note with very long marker, and also a long body.]
  /// ```
  /// - `grid`: Body markers and body content are structured in a `grid`.
  /// ```example
  /// #deixis-set(
  ///   render-group: deixis-grid-render-group,
  /// )
  /// #deixis-footnote[A normal note.]
  /// #deixis-footnote(marker: [long marker])[A note with very long marker, and also a long body.]
  /// ```
  ///
  /// ```tip
  /// For full control, you can (and should) draft your own render function.
  /// `deixis` provides some handy helper functions for this purpose.
  /// See @deixis-generate-backlinks, @deixis-generate-body-meta, and @deixis-generate-body-marker.
  /// ```
  ///
  /// ```example
  /// #let custom-render-func(note-data, ..args) = {
  ///   let backlink = note-data.backlink
  ///   let body-marker = deixis-generate-body-marker(note-data + (body-marker-style: it => it))
  ///   rect(
  ///     ..note-data.styles,
  ///     inset: (top: 10pt, rest: 5pt)
  ///   )[
  ///     #place(center + top, dy: -20pt, rect(
  ///       stroke: note-data.styles.stroke,
  ///       fill: white,
  ///       radius: 1em,
  ///       body-marker))
  ///     #note-data.body
  ///   ]
  /// }
  ///
  /// #deixis-set(
  ///   render-single: custom-render-func,
  ///   render-group: deixis-native-render-group,
  /// )
  /// #deixis-footnote[A note with custom render function.]
  /// ```
  ///
  /// -> auto | function | dictionary
  render-single: auto,
  /// Group rendering function for grouped notes (footnote and endnote).
  ///
  /// See @deixis-set.render-single.
  ///
  /// -> auto | function | dictionary
  render-group: auto,
  /// Note body container function with signature `(content, ..args) => content`.
  ///
  /// ```example
  /// #import "@preview/colorful-boxes:1.4.3": stickybox
  /// #deixis-set(container-func: (body, ..args) => stickybox(body))
  /// #deixis-margin-note(target: "page")[Yes, we can also do that.]
  /// ```
  ///
  /// ```tip
  /// `container-func` is only a wrapper around the rendered body of each note and does not have access to the raw notes' data.
  /// For more sophisticated control, you should use @deixis-set.render-single or @deixis-set.render-group.
  /// ```
  ///
  /// -> auto | function | dictionary
  container-func: auto,
) = {
  deixis-system.update(sys => {
    // Pack only the explicitly provided updates
    let updates = (:)
    if numbering != auto { updates.insert("numbering", numbering) }
    if marker-style != auto { updates.insert("marker-style", marker-style) }
    if body-style != auto { updates.insert("body-style", body-style) }
    if backlink != auto { updates.insert("backlink", backlink) }
    if marker-position != auto { updates.insert("marker-position", marker-position) }
    if inline-mode != auto { updates.insert("inline-mode", inline-mode) }
    if stroke != auto { updates.insert("stroke", stroke) }
    if fill != auto { updates.insert("fill", fill) }
    if radius != auto { updates.insert("radius", radius) }
    if link != auto { updates.insert("link", link) }
    if link-marks != auto { updates.insert("link-marks", link-marks) }
    if separator != auto { updates.insert("separator", separator) }
    if clearance != auto { updates.insert("clearance", clearance) }
    if gap != auto { updates.insert("gap", gap) }
    if marker-gap != auto { updates.insert("marker-gap", marker-gap) }
    if indent != auto { updates.insert("indent", indent) }
    if margin-layout != auto { updates.insert("margin-layout", margin-layout) }
    if spillover != auto { updates.insert("spillover", spillover) }
    if mark-align != auto { updates.insert("mark-align", mark-align) }
    if mark-align-strictness != auto { updates.insert("mark-align-strictness", mark-align-strictness) }
    if min-margin-width != auto { updates.insert("min-margin-width", min-margin-width) }
    if side-strategy != auto { updates.insert("side-strategy", side-strategy) }
    if region-shape != auto { updates.insert("region-shape", region-shape) }
    if layer != auto { updates.insert("layer", layer) }
    if render-single != auto { updates.insert("render-single", render-single) }
    if render-group != auto { updates.insert("render-group", render-group) }
    if container-func != auto { updates.insert("container-func", container-func) }

    if updates.len() == 0 { return sys }

    let _deep-merge(old, new) = {
      if type(old) == dictionary and type(new) == dictionary {
        let old-has-note = old.keys().any(k => k in deixis-note-types)
        let old-has-comp = old.keys().any(k => k in deixis-note-components)
        let new-has-note = new.keys().any(k => k in deixis-note-types)
        let new-has-comp = new.keys().any(k => k in deixis-note-components)

        // If the new dictionary introduces a conflicting scope level
        // override the old structure to prevent ambiguous nesting
        if (old-has-note and new-has-comp) or (old-has-comp and new-has-note) {
          return new
        }

        let res = old
        for (k, v) in new {
          res.insert(k, _deep-merge(old.at(k, default: auto), v))
        }
        return res
      }
      return new
    }

    if sys.stack.len() > 0 {
      let last-idx = sys.stack.len() - 1
      let current-level = sys.stack.at(last-idx)
      for (k, v) in updates {
        let old-val = current-level.at(k, default: auto)
        current-level.insert(k, _deep-merge(old-val, v))
      }
      sys.stack.last() = current-level
    } else {
      for (k, v) in updates {
        let old-val = sys.at(k, default: auto)
        sys.insert(k, _deep-merge(old-val, v))
      }
    }

    return sys
  })
}

/// Fetches all rendered `deixis` notes that exist on or visually intersect the current page.
///
/// This is an useful introspection tool and can be used, for example, to set page headings based on what endnote is being displayed.
///
/// ```info
/// Since it relies on spatial queries, it must be called within a `context` block.
/// ```
///
/// ```example
/// //| layout: "vertical"
/// #let adaptive-header = context {
///   let notes = deixis-page-notes(note-type: "endnote")
///
///   if notes.len() == 0 {
///     align(center)[_My Book Title_]
///   } else {
///     let first-note = notes.first()
///     let last-note = notes.last()
///     // Helper to find the page number of the mark in the main text
///     let _find-mark-page(lbl) = {
///       let elems = query(selector(lbl))
///       if elems.len() > 0 { elems.first().location().page() } else { 0 }
///     }
///     let p-start = _find-mark-page(first-note.mark-lbl)
///     let p-end = _find-mark-page(last-note.mark-lbl)
///     // pages
///     let left-text = if p-start == p-end { [_Notes for page #p-start _] } else { [_Notes for pages #p-start -- #p-end _] }
///     // note numbers
///     let right-text = if notes.len() == 1 { [_Note #first-note.marker-str _] } else { [_Notes #first-note.marker-str -- #last-note.marker-str _] }
///     grid(
///       columns: (1fr, 1fr),
///       align(left)[#left-text],
///       align(right)[#right-text]
///     )
///   }
/// }
///
/// #adaptive-header
/// // Real usage: (cannot be used in example environment)
/// // #set page(header: adaptive-header)
///
/// We can do that, Rik
/// #deixis-endnote[Test note 1 #lorem(10)]
/// #deixis-endnote[Test note 2 #lorem(10)]
/// #deixis-endnote[Test note 3 #lorem(10)].
///
/// #deixis-print-endnotes()
/// ```
///
/// - note-type (auto, str, array): Filter the results to a specific note type (e.g., `"margin-note"`) or an array of types. If `auto`, returns all intersecting notes.
///
/// -> array
#let deixis-page-notes(
  note-type: auto,
) = {
  let p = here().page()

  let starts = query(<deixis-rendered-start>).filter(e => e.location().page() == p).map(e => e.value)
  let ends = query(<deixis-rendered-end>).filter(e => e.location().page() == p).map(e => e.value)

  let combined = starts + ends

  if combined.len() == 0 {
    let prevs = query(selector(<deixis-rendered-start>).before(here()))
    let nexts = query(selector(<deixis-rendered-end>).after(here()))
    if prevs.len() > 0 and nexts.len() > 0 {
      let last-prev = prevs.last().value
      let first-next = nexts.first().value

      let k-prev = str(last-prev.at("body-lbl", default: "prev"))
      let k-next = str(first-next.at("body-lbl", default: "next"))

      if k-prev == k-next {
        combined.push(last-prev)
      }
    }
  }

  if note-type != auto {
    combined = combined.filter(val => val.at("body-type", default: none) == note-type)
  }

  let active-notes = ()
  let seen-ids = ()

  for val in combined {
    let count = val.at("count", default: none)
    if count == none {
      continue
    }
    let k = str(val.at("internal-id", default: count))
    if k not in seen-ids {
      seen-ids.push(k)

      let resolved-num = _deixis-query-marker-str(val)
      let final-val = val
      final-val.insert("marker-str", resolved-num)

      active-notes.push(final-val)
    }
  }

  active-notes.sorted(key: n => n.count)
}
