#import "core.typ": *

/// A dynamically styled outline (Table of Contents) for your annotations.
///
/// The outline extracts the content from note bodies and clips it to a single line.
/// Each entry features a dynamic visual badge that inherits
/// the styling of the specific note it represents.
/// They act as clickable hyperlinks, returning the reader to the mark's location.
///
/// ```example
/// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: red)[This is a note!]
///
/// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: green)[This is another note!]
///
/// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: blue)[This is yet another note!]
/// // `target: 0` restricts the search to notes inside this example block.
/// #deixis-note-outline(target: 0)
/// ```
///
/// - title (content, none): The heading content to display above the outline. Set to `none` to disable the heading.
/// - heading-level (int): The heading level for the outline's main title. Any dynamically generated group sub-headings will be rendered at `heading-level + 1`.
/// - target (auto, label, str, int): Filters the outline to notes belonging to a specific target block or minipage.
/// - threat (auto, label, str): Filters the outline to only show notes belonging to a specific thread of minipages.
/// - include-types (auto, array): A list of note types to explicitly include (e.g., `("margin-note", "endnote")`). If `auto`, includes all types.
/// - exclude-types (array): A list of note types to explicitly exclude.
/// - series (auto, str, array): Filters the outline to notes belonging to a specific series or array of series.
/// - include-celibates (bool, str): Determines if decoupled, standalone marks or bodies should be included. Choices: `bool` | `"both"` | `"none"` | `"mark"` | `"body"`.
/// - after (none, location, label, str): Only includes notes that appear *after* this location, label, or `<deixis-pin>` name.
/// - before (none, location, label, str): Only includes notes that appear *before* this location, label, or `<deixis-pin>` name.
/// - group-by (none, str, function): Categorizes the notes under sub-headings. Accepts `"type"` (e.g., "Margin Notes"), `"series"`, or a custom `function(note) => string`.
/// - fill (none, content): Fills the space between the excerpt and the page number. Commonly set to `repeat[.]` for standard TOC styling.
/// - gap (auto, length): The vertical spacing between individual note rows in the outline.
///
/// -> content
#let deixis-note-outline(
  /// The heading content to display above the outline. Set to `none` to disable the heading.
  ///
  /// ```example
  /// #deixis-note-outline(target: 0, title: [Liste des Notes])
  /// ```
  ///
  /// -> content | none
  title: [List of Notes],
  /// The heading level for the outline's main title. Any dynamically generated group sub-headings will be rendered at `heading-level + 1`.
  ///
  /// ```example
  /// #deixis-note-outline(target: 0, heading-level: 3)
  /// ```
  ///
  /// -> int
  heading-level: 1,
  /// Filters the outline to notes belonging to a specific target block or minipage.
  /// -> auto | label | str | int
  target: auto,
  /// Filters the outline to only show notes belonging to a specific thread of minipages.
  /// -> auto | str
  thread: auto,
  /// A list of note types to explicitly include (e.g., `("margin-note", "endnote")`). If `auto`, includes all types.
  /// -> auto | array
  include-types: auto,
  /// A list of note types to explicitly exclude.
  /// -> array
  exclude-types: (),
  /// Filters the outline to notes belonging to a specific series or array of series.
  /// -> auto | str | array
  series: auto,
  /// Determines if decoupled, standalone marks or bodies should be included. Choices: `bool` | `"both"` | `"none"` | `"mark"` | `"body"`.
  /// -> bool | str
  include-celibates: false,
  /// Only includes notes that appear *after* this location, label, or `<deixis-pin>` name.
  /// -> none | location | label | str
  after: none,
  /// Only includes notes that appear *before* this location, label, or `<deixis-pin>` name.
  /// -> none | location | label | str
  before: none,
  /// Categorizes the notes under sub-headings. Accepts `"type"`, `"series"`, or a custom `function(note) => string`.
  ///
  /// ```example
  /// //| margin: (right: 0.6in, rest: 0.05in)
  /// #deixis-footnote(stroke: red)[This is a footnote!]
  /// #deixis-margin-note(stroke: green)[This is a margin note!]
  /// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: blue)[This is an inset note!]
  ///
  /// #deixis-note-outline(target: 0, group-by: "type")
  /// ```
  ///
  /// -> none | str | function
  group-by: none,
  /// Fills the space between the excerpt and the page number. Commonly set to `repeat[.]` for standard TOC styling.
  ///
  /// ```example
  /// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: red)[This is a note!]
  ///
  /// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: green)[This is another note!]
  ///
  /// #deixis-inset-note(dx: 10pt, dy: 0pt, stroke: blue)[This is yet another note!]
  ///
  /// #deixis-note-outline(target: 0, fill: repeat[.])
  /// ```
  ///
  /// -> none | content
  fill: none,
  /// The vertical spacing between individual note rows in the outline.
  /// -> auto | length
  gap: auto,
) = context {
  _deixis-check-setup-state()
  let active-sys = deixis-system.get()

  let resolve-bound(b-val, b-name) = {
    if b-val == none { return none }
    if type(b-val) == location { return b-val }
    if type(b-val) == str {
      let pins = query(<deixis-pin>).filter(p => p.value.at("name", default: "") == b-val)
      if pins.len() == 0 { panic("deixis: Could not find pin named '" + b-val + "'.") }
      return pins.first().location()
    } else {
      let elems = query(b-val)
      if elems.len() == 0 { panic("deixis: Could not find target matching '" + repr(b-val) + "'.") }
      return elems.first().location()
    }
  }

  let loc-after = resolve-bound(after, "after")
  let loc-before = resolve-bound(before, "before")

  let is-in-bounds(loc) = {
    if loc == none { return false }
    if loc-after != none {
      if loc.page() < loc-after.page() { return false }
      if loc.page() == loc-after.page() and loc.position().y < loc-after.position().y { return false }
    }
    if loc-before != none {
      if loc.page() > loc-before.page() { return false }
      if loc.page() == loc-before.page() and loc.position().y > loc-before.position().y { return false }
    }
    return true
  }

  let extract-id(val) = {
    if type(val) != dictionary { return none }

    let raw-id = val.at("internal-id", default: none)

    if raw-id == none {
      let b-lbl = val.at("body-lbl", default: none)
      if b-lbl == none and "note-data" in val { b-lbl = val.note-data.at("body-lbl", default: none) }
      if b-lbl != none and str(b-lbl).starts-with("deixis-body-") { raw-id = str(b-lbl).replace("deixis-body-", "") }
    }

    if raw-id == none {
      let m-lbl = val.at("mark-lbl", default: none)
      if m-lbl == none and "note-data" in val { m-lbl = val.note-data.at("mark-lbl", default: none) }
      if m-lbl != none and str(m-lbl).starts-with("deixis-mark-") { raw-id = str(m-lbl).replace("deixis-mark-", "") }
    }

    if raw-id != none {
      let sid = str(raw-id)
      if sid.starts-with("celibate-") { return none }
      return sid
    }
    return none
  }

  let extract-field(val, key, default-val) = {
    if key in val { return val.at(key) }
    if "note-data" in val and key in val.note-data { return val.note-data.at(key) }
    return default-val
  }

  let m-tag-map = (
    (<deixis-inline-mark>, "inline-mark"),
    (<deixis-region-mark>, "region-mark"),
    (<deixis-phantom-mark>, "phantom-mark"),
  )
  let b-tag-map = (
    (<deixis-inline-note>, "inline-note"),
    (<deixis-footnote>, "footnote"),
    (<deixis-endnote>, "endnote"),
    (<deixis-margin-note>, "margin-note"),
    (<deixis-inset-note>, "inset-note"),
  )

  // ✨ Collect and Merge Metadata
  let combined = (:)
  let raw-celibates = ()

  for (tag, type-str) in m-tag-map {
    for m in query(selector(tag)) {
      let val = m.value
      let i-id = extract-id(val)
      if i-id == none {
        raw-celibates.push((loc: m.location(), mark-meta: val, body-meta: none, m-type: type-str, b-type: none))
      } else {
        let entry = combined.at(i-id, default: (
          loc: m.location(),
          mark-meta: none,
          body-meta: none,
          m-type: none,
          b-type: none,
        ))
        entry.mark-meta = val
        entry.m-type = type-str
        entry.loc = m.location() // Mark loc takes priority
        combined.insert(i-id, entry)
      }
    }
  }

  for (tag, type-str) in b-tag-map {
    for b in query(selector(tag)) {
      let val = b.value
      let i-id = extract-id(val)
      if i-id == none {
        raw-celibates.push((loc: b.location(), mark-meta: none, body-meta: val, m-type: none, b-type: type-str))
      } else {
        let entry = combined.at(i-id, default: (
          loc: b.location(),
          mark-meta: none,
          body-meta: none,
          m-type: none,
          b-type: none,
        ))
        entry.body-meta = val
        entry.b-type = type-str
        if entry.mark-meta == none { entry.loc = b.location() } // Fallback to body loc
        combined.insert(i-id, entry)
      }
    }
  }

  // ✨ Filter and Extract Data
  let c-inc-marks = (
    include-celibates == true
      or include-celibates == "both"
      or include-celibates in ("mark", "marks")
      or (type(include-celibates) == array and ("mark" in include-celibates or "marks" in include-celibates))
  )

  let c-inc-bodies = (
    include-celibates == true
      or include-celibates == "both"
      or include-celibates in ("body", "bodies")
      or (type(include-celibates) == array and ("body" in include-celibates or "bodies" in include-celibates))
  )

  let all-raw = combined.values() + raw-celibates
  let valid-notes = ()

  for n in all-raw {
    let is-celibate-mark = n.body-meta == none and n.mark-meta != none
    let is-celibate-body = n.mark-meta == none and n.body-meta != none

    if is-celibate-mark and not c-inc-marks { continue }
    if is-celibate-body and not c-inc-bodies { continue }

    if not is-in-bounds(n.loc) { continue }

    let actual-type = if n.b-type != none { n.b-type } else { n.m-type }
    if include-types != auto and actual-type not in include-types { continue }
    if actual-type in exclude-types { continue }

    let meta-to-use = if n.body-meta != none { n.body-meta } else { n.mark-meta }

    let c-series = extract-field(meta-to-use, "series", "default")
    if series != auto {
      if type(series) == array and c-series not in series { continue }
      if type(series) == str and c-series != series { continue }
    }

    let note-target-id = extract-field(meta-to-use, "target-id", "page")
    if thread != auto {
      if note-target-id != ("thread-" + str(thread)) { continue }
    } else if target != auto {
      let resolved-outline-target = _deixis-resolve-target(active-sys, target)
      if note-target-id != resolved-outline-target.render-id { continue }
    }

    let num = extract-field(meta-to-use, "marker-str", none)
    if num == none and n.mark-meta != none { num = extract-field(n.mark-meta, "marker-str", none) }

    let styles = extract-field(meta-to-use, "styles", (:))
    let s-obj = if styles.at("stroke", default: auto) != none { styles.at("stroke", default: 0.5pt + luma(200)) } else {
      none
    }
    let f-obj = if styles.at("fill", default: auto) != auto { styles.fill } else { none }
    let r-obj = if styles.at("radius", default: auto) != auto { styles.radius } else { 2pt }

    let badge = if num != none and num != "" {
      box(
        fill: f-obj,
        stroke: s-obj,
        radius: r-obj,
        inset: (x: 0.3em, y: 0.2em),
        outset: (y: 0.1em),
        baseline: 15%,
        clip: true,
        text(size: 0.8em, weight: "bold", num),
      )
    } else {
      box(fill: f-obj, stroke: s-obj, radius: r-obj, width: 0.8em, height: 0.8em, baseline: 10%)
    }

    valid-notes.push((
      loc: n.loc,
      body: extract-field(meta-to-use, "body", none),
      badge: badge,
      type: actual-type,
      series: c-series,
    ))
  }

  // ✨ Group and Render
  let grouped = (:)
  let pretty-types = (
    "inline-mark": "Inline Marks",
    "phantom-mark": "Phantom Marks",
    "region-mark": "Region Marks",
    "inline-note": "Inline Notes",
    "footnote": "Footnotes",
    "endnote": "Endnotes",
    "margin-note": "Margin Notes",
    "inset-note": "Inset Notes",
  )

  for note in valid-notes.sorted(key: n => n.loc.page()) {
    let key = "Notes"
    if type(group-by) == str {
      if group-by == "type" {
        key = pretty-types.at(note.type, default: note.type)
      } else if group-by == "series" { key = note.series }
    } else if type(group-by) == function {
      key = group-by(note)
    }
    let arr = grouped.at(str(key), default: ())
    arr.push(note)
    grouped.insert(str(key), arr)
  }

  if title != none { heading(level: heading-level, title) }

  let c-gap = if gap == auto { 0.6em } else { gap }
  for (g-key, g-notes) in grouped {
    if grouped.keys().len() > 1 and group-by != none {
      heading(level: heading-level + 1, g-key)
    }

    for note in g-notes {
      let c-body = if note.body != none {
        note.body
      } else {
        text(fill: luma(150), style: "italic", size: 0.9em)[No body text]
      }

      let excerpt = block(width: 100%, height: 1.1em, clip: true, {
        set text(size: 0.95em)
        set par(justify: false, leading: 2em, spacing: 0pt)
        if fill != none { [#c-body #box(width: 1fr, fill)] } else { c-body }
      })

      let row = grid(
        columns: (2em, 1fr, auto),
        column-gutter: 0.75em,
        align: (center + horizon, left + horizon, right + horizon),
        note.badge, excerpt, [#note.loc.page()],
      )

      link(note.loc, row)
      v(c-gap, weak: true)
    }
  }
}
