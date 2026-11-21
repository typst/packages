#import "config.typ": *
#import "state.typ": *
#import "declarations.typ": _deixis-check-omit
#import "palette.typ": _deixis-palette-setting, _deixis-check-palette
#import "order.typ": _deixis-order-hints

/// Updates defaults within the current Deixis scope.
/// Also available as `deixis-configure` and `short.configure`.
///
/// Defaults apply to subsequent declarations until the current `deixis-block`
/// ends; outside a block they are document defaults. Ordinary Typst content
/// brackets do not create a Deixis settings scope. Top-level `auto` arguments
/// leave existing settings unchanged.
///
/// ```tip
/// *Type-Specific Styling:* Style parameters accept either a global value or a `dictionary` targeting specific note types
/// (e.g., `stroke: (margin-note: red, inset-note: blue)`).
/// A dictionary whose keys are all scope keys selects note types or components.
/// Other dictionaries retain their native value shape; empty stroke/radius/position,
/// connector, and arrowhead dictionaries are literal values.
/// - Type keys: `inline-mark`, `phantom-mark`, `region-mark`, `footnote`,
///   `endnote`, `margin-note`, `inset-note`, `inline-note`, `connection`.
/// - Component keys: `mark`, `body`, `connector`.
///   - `"nodes"` indicates both `"mark"` and `"body"` (excluding `"connector"`).
/// - Wildcard key: `"rest"` indicates anything else.
/// Body-only options (including renderers and containers) select the body/nodes
/// branch automatically. Numbering/region shape select mark, and connector
/// options select connector. Arrowhead mark/body maps describe endpoints.
/// Repeated updates merge compatible dictionaries. Changing between native value
/// and scope dictionaries, or between type and component scopes, replaces the
/// old structure. An explicit empty dictionary clears it at that level.
/// Route records `(kind: ..., tension: ...)` are complete literal values and
/// replace atomically. String routes retain defaults; catmull-rom records can
/// select centripetal/uniform parameterization. B-spline uses influence controls;
/// Hobby uses global tension (minimum 0.75) and free-end curl (default 1).
/// Controls belong to the algorithm.
/// Sidenotes are margin-note presets; use margin-note settings, not sidenote keys.
/// ```
///
/// - palette (auto, none, str, array): A built-in palette name or nonempty color sequence starts a fresh cycle in this Deixis scope; none disables later allocation and auto leaves it unchanged.
/// - numbering (auto, none, str, function, dictionary): The numbering style for markers; none disables automatic markers and counter allocation.
/// - marker-style (auto, function, dictionary): The styling function `(content) => content` for note markers.
/// - body-style (auto, function, dictionary): The styling function `(content) => content` for note bodies.
/// - backlink (auto, bool, str, dictionary): Enables or disables clickable backlinks from bodies to marks. Choices: `bool` | `"always"` | `"none"` | `"never"` | `"multiple"`.
/// - marker-position (auto, alignment, dictionary): Mark marker placement.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
/// - stroke (auto, stroke, none, dictionary): The border stroke.
/// - fill (auto, color, none, dictionary): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
/// - separator (auto, content, none, dictionary): The separator line for block footnote collections and endnotes.
/// - clearance (auto, length, dictionary): Vertical spacing before block footnote collections and endnotes.
/// - gap (auto, length, dictionary): Vertical spacing between adjacent notes.
/// - marker-gap (auto, length, dictionary): Horizontal spacing between the marker and the body text.
/// - indent (auto, length, dictionary): The indentation applied to the note body.
/// - margin-layout (auto, str): The layout engine for margin notes. Choices: `"adaptive"` | `"flow"` | `"exact"`.
/// - min-margin-width (auto, length): Minimum margin width to put margin notes.
/// - side-strategy (auto, str): Strategy to select side for margin note. Choices: `"nearest"` | `"strict"`.
/// - mark-align (auto, alignment, dictionary): How margin notes align vertically relative to their marks.
/// - mark-align-strictness (auto, str): How strictly to align margin notes to their marks. Choices: `"strict"` | `"loose"` | `"none"`.
/// - spillover (auto, bool): Allow margin notes to spill over page boundaries.
/// - overflow (auto, str, dictionary): Margin frame policy: "allow" or "error" after final placement.
/// - region-shape (auto, function): Shape drawing function for region marks.
/// - layer (auto, str): The rendering layer for region marks and inset notes. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - render-single (auto, function, dictionary): Note body rendering function.
/// - render-group (auto, function, dictionary): Group rendering function for grouped notes (footnote and endnote).
/// - container-func (auto, str, function, dictionary): A named body container or function `(content, ..args) => content`.
///
/// -> content
#let deixis-set(
  /// Omit annotations created in these series, preserving marked passages.
  /// Omitted annotations have no counter, body, connector or query identity.
  /// Reused marks and attached bodies follow the original across scopes and
  /// forward declarations. References to omitted IDs are errors.
  /// Use none to include every series; auto leaves the policy unchanged.
  /// -> auto | none | dictionary
  omit: auto,
  /// Optional annotation accent cycle. A color array or a built-in name
  /// ("deixis", "okabe-ito", "tol-bright", "tol-muted", "tableau") starts a new
  /// cycle in the current Deixis scope; none disables it and auto leaves it
  /// unchanged. Reused marks/bodies keep the original accent; explicit styles win.
  /// -> auto | none | str | array
  palette: auto,
  /// The numbering style for the marker. A literal `(restart: "page", pattern: "1")`
  /// uses the original mark's physical page and restarts the displayed ordinal.
  /// Assigned counters/query counts stay unchanged; reuse and attached bodies
  /// keep the original marker, including inside multi-page blocks. HTML has no
  /// page boundaries and uses a continuous sequence. Ordinary strings/functions
  /// keep assigned numbering. Resolved `none` takes no counter value and shows no
  /// automatic marker; an explicit fixed marker may still display.
  /// Note-family keys such as `(footnote: "*", endnote: "i")` number the marks
  /// those wrappers create, ahead of mark-type keys and rest.
  ///
  /// ```example
  /// #deixis-set(numbering: "i")
  /// #deixis-footnote[A note with roman numbering.]
  /// ```
  ///
  /// -> auto | none | str | function | dictionary
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
  /// #deixis-footnote(id: <deixis-set.backlink>)[A note with backlink.]
  /// #deixis-ref(<deixis-set.backlink>)
  /// ```
  ///
  /// -> auto | bool | str | dictionary
  backlink: auto,
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
  /// Connector defaults for margin/inset notes and independent connections.
  /// A route name is shorthand for `(route: name)`; a record sets any of
  /// route, ports, via/segments, heads, stroke, radius and the other connector
  /// fields. Records merge with outer defaults field by field; none disables.
  /// Routes: `"none"`, `"straight-line"`/`"polyline"`, `"right-angle"`/`"orthogonal"`,
  /// `"chamfer"`, `"curve"`, `"ccr"`, `"ucr"`, `"b-spline"` and `"hobby"`.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-set(connector: (route: "curve", heads: "stealth"))
  /// #deixis-inset-note(dx: 4em, dy: 3em, layer: "flow")[Note mark.][Note body.]
  /// ```
  ///
  /// Scope defaults by note type: `connector: (margin-note: "curve")`.
  /// -> auto | none | str | dictionary
  connector: auto,
  /// The separator line for note groups.
  ///
  /// ```info
  /// This affects local block footnote collections and endnote printers. Page
  /// footnotes share the native footer: configure it once with a document-level
  /// `set footnote.entry(separator: ...)`, as for `std.footnote`.
  /// ```
  ///
  /// ```example
  /// #deixis-set(separator: line(length: 50%, stroke: (thickness: 0.5pt, dash: "dashed")))
  /// #deixis-endnote[An endnote separated by a dashed line.]
  /// #deixis-print-endnotes()
  /// ```
  ///
  /// -> auto | content | none | dictionary
  separator: auto,
  /// Vertical spacing before note groups.
  ///
  /// ```info
  /// This affects local block footnote collections and endnote printers. Page
  /// footnotes use the native `footnote.entry` clearance.
  /// ```
  ///
  /// ```example
  /// #deixis-set(clearance: 3em)
  /// #deixis-endnote[A note `3em`-spaced from the main content.]
  /// #deixis-print-endnotes()
  /// ```
  ///
  /// -> auto | length | dictionary
  clearance: auto,
  /// Vertical spacing between adjacent notes.
  ///
  /// ```info
  /// This affects margin notes, local block footnote collections and endnote
  /// printers. Page footnotes use the native `footnote.entry` gap.
  /// ```
  ///
  /// ```example
  /// #deixis-set(gap: 1em)
  /// #deixis-endnote[Note A.]
  /// #deixis-endnote[Note B.]
  /// #deixis-print-endnotes()
  /// ```
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
  /// -> auto | length | dictionary
  indent: auto,
  /// The layout engine for margin notes. Choices: `"adaptive"` | `"flow"` | `"exact"`.
  /// - `"adaptive"`: Apply a two-pass _rubber band algorithm_ to calculate the y-coordinates of all margin notes in the page; then use `#std.place` to put them into calculated positions.
  /// - `"flow"`: Distribute available space by fractional weights in a shared numeric plan, then place each note at its planned position.
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
  /// See `deixis-margin-note-body.side-strategy`.
  ///
  /// -> auto | str
  side-strategy: auto,
  /// How margin notes align vertically relative to their marks.
  ///
  /// See `deixis-margin-note-body.mark-align`.
  ///
  /// -> auto | alignment | dictionary
  mark-align: auto,
  /// How strictly to align margin notes to their marks. Choices: `"strict"` | `"loose"` | `"none"`.
  ///
  /// See `deixis-margin-note-body.mark-align-strictness`.
  ///
  /// -> auto | str
  mark-align-strictness: auto,
  /// Allow margin notes to spill over page boundaries.
  ///
  /// See `deixis-margin-note-body.spillover`.
  ///
  /// -> auto | bool
  spillover: auto,
  /// Margin body frame overflow: allow preserves placement; error checks final bounds.
  /// -> auto | str | dictionary
  overflow: auto,
  /// Shape drawing function for region marks.
  ///
  /// See `deixis-region-mark.region-shape`.
  ///
  /// -> auto | function
  region-shape: auto,
  /// The rendering layer for region marks and inset notes. Choices: `"flow"` | `"foreground"` | `"background"`.
  ///
  /// See `deixis-region-mark.layer`.
  ///
  /// -> auto | str
  layer: auto,
  /// Overlay paint priority. Higher integers paint later within a page layer.
  /// Native flow keeps its order; component/type dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
  /// Note body rendering function.
  ///
  /// `render-single` formats each body; `render-group` arranges collected bodies.
  /// The examples use endnotes so both settings apply. Page footnotes use the
  /// native footer group and honor only their single renderer.
  /// - `native`: _Almost_ pixel-identical to `std.footnote`.
  /// ```example
  /// #deixis-set(
  ///   render-single: deixis-native-render-single,
  ///   render-group: deixis-native-render-group,
  /// )
  /// #deixis-endnote[A normal note.]
  /// #deixis-endnote(marker: [long marker])[A note with very long marker, and also a long body.]
  /// #deixis-print-endnotes()
  /// ```
  /// - `aligned`: Body markers are aligned, but the notes are still prose-printed.
  /// ```example
  /// #deixis-set(
  ///   render-single: deixis-aligned-render-single,
  ///   render-group: deixis-aligned-render-group,
  /// )
  /// #deixis-endnote[A normal note.]
  /// #deixis-endnote(marker: [long marker])[A note with very long marker, and also a long body.]
  /// #deixis-print-endnotes()
  /// ```
  /// - `grid`: Body markers and body content are structured in a `grid`.
  /// ```example
  /// #deixis-set(
  ///   render-group: deixis-grid-render-group,
  /// )
  /// #deixis-endnote[A normal note.]
  /// #deixis-endnote(marker: [long marker])[A note with very long marker, and also a long body.]
  /// #deixis-print-endnotes()
  /// ```
  ///
  /// ```tip
  /// Custom renderers can combine `deixis-generate-body-marker`,
  /// `deixis-generate-body-content` and `deixis-generate-backlinks`. Emit the body
  /// content helper once to preserve navigation spans and nested annotations.
  /// ```
  ///
  /// ```example
  /// #let custom-render-func(note-data, ..args) = {
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
  ///     #deixis-generate-body-content(note-data)
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
  /// See `deixis-set.render-single`.
  ///
  /// -> auto | function | dictionary
  render-group: auto,
  /// A body-container name ("plain", "rect", "alert", "stripe", "tinted")
  /// or function `(content, ..args) => content`. Type/component maps are supported.
  /// "stripe" and "tinted" use the annotation accent; explicit body styles win.
  /// Forward native/custom wrapper options through `container-args` on the note.
  ///
  /// ```example
  /// #import "@preview/colorful-boxes:1.4.3": stickybox
  /// #deixis-set(container-func: (body, ..args) => stickybox(body))
  /// #deixis-margin-note(target: "page")[Yes, we can also do that.]
  /// ```
  ///
  /// ```tip
  /// `container-func` is only a wrapper around the rendered body of each note and does not have access to the raw notes' data.
  /// For more sophisticated control, you should use `deixis-set.render-single` or `deixis-set.render-group`.
  /// ```
  ///
  /// -> auto | str | function | dictionary
  container-func: auto,
) = {
  let render-with-order-hints() = {
    if palette != auto { _deixis-check-palette(palette) }
    deixis-system.update(sys => {
      // Pack only the explicitly provided updates
      let updates = (:)

      if palette != auto { sys = _deixis-palette-setting(sys, palette) }
      if numbering != auto { updates.insert("numbering", numbering) }
      if marker-style != auto { updates.insert("marker-style", marker-style) }
      if body-style != auto { updates.insert("body-style", body-style) }
      if backlink != auto { updates.insert("backlink", backlink) }
      if marker-position != auto { updates.insert("marker-position", marker-position) }
      if inline-mode != auto { updates.insert("inline-mode", inline-mode) }
      if stroke != auto { updates.insert("stroke", stroke) }
      if fill != auto { updates.insert("fill", fill) }
      if radius != auto { updates.insert("radius", radius) }
      // A route name is shorthand for a record, so repeated defaults merge
      // field by field, also inside note-type scopes.
      let connector-record(value) = if type(value) == str { (route: value) }
        else if type(value) == dictionary and value.len() > 0 and value.keys().all(k => k in deixis-scoping-keys) {
          value.pairs().fold((:), (out, pair) => out + ((pair.first()): connector-record(pair.last())))
        } else { value }
      if connector != auto { updates.insert("connector", connector-record(connector)) }
      if separator != auto { updates.insert("separator", separator) }
      if clearance != auto { updates.insert("clearance", clearance) }
      if gap != auto { updates.insert("gap", gap) }
      if marker-gap != auto { updates.insert("marker-gap", marker-gap) }
      if indent != auto { updates.insert("indent", indent) }
      if margin-layout != auto { updates.insert("margin-layout", margin-layout) }
      if spillover != auto { updates.insert("spillover", spillover) }
      if overflow != auto { updates.insert("overflow", overflow) }
      if mark-align != auto { updates.insert("mark-align", mark-align) }
      if mark-align-strictness != auto { updates.insert("mark-align-strictness", mark-align-strictness) }
      if min-margin-width != auto { updates.insert("min-margin-width", min-margin-width) }
      if side-strategy != auto { updates.insert("side-strategy", side-strategy) }
      if region-shape != auto { updates.insert("region-shape", region-shape) }
      if layer != auto { updates.insert("layer", layer) }
      if z-index != auto { updates.insert("z-index", z-index) }
      if render-single != auto { updates.insert("render-single", render-single) }
      if render-group != auto { updates.insert("render-group", render-group) }
      if container-func != auto { updates.insert("container-func", container-func) }

      if updates.len() == 0 { return sys }

      if sys.stack.len() > 0 {
        let last-idx = sys.stack.len() - 1
        let current-level = sys.stack.at(last-idx)
        for (k, v) in updates {
          let old-val = current-level.at(k, default: auto)
          current-level.insert(k, _deixis-merge-config(old-val, v))
        }
        sys.stack.last() = current-level
      } else {
        for (k, v) in updates {
          let old-val = sys.at(k, default: auto)
          sys.insert(k, _deixis-merge-config(old-val, v))
        }
      }

      return sys
    })
  }
  if omit != auto {
    _deixis-check-omit(omit)
    _deixis-omission-policy.update(values => { values.last() = omit; values })
  }
  [#_deixis-order-hints(z-index, connector: connector)#render-with-order-hints()]
}

/// Alias of `deixis-set`: updates defaults within the current Deixis scope.
/// Both prefixed names are the same function. The short module exports
/// `configure`, since `set` is a Typst keyword.
#let deixis-configure = deixis-set
