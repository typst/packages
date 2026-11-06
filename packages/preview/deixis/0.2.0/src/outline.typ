#import "query.typ": deixis-query-notes
#import "core/html.typ": _deixis-html-link
#import "core/declarations.typ": _deixis-replay
#import "core/native.typ": *

/// Shows content again without its annotations.
///
/// Marked passages remain; marks, markers, note bodies and connections inside
/// the content are not created a second time. Native outlines already apply
/// this to heading and figure-caption entries. Use it wherever a document
/// repeats content, such as a running header that shows the current heading.
///
/// ```example
/// #set page(header: context {
///   let previous = query(selector(heading).before(here()))
///   if previous.len() > 0 { deixis-plain(previous.last().body) }
/// })
/// ```
///
/// -> content
#let deixis-plain(
  /// Content that may contain annotations, such as a heading body.
  /// -> content
  body,
) = _deixis-replay(body)


/// A dynamically styled outline (Table of Contents) for your annotations.
///
/// The outline extracts static text from note bodies without executing them again.
/// Each entry features a dynamic visual badge that inherits
/// the styling of the specific note it represents.
/// They act as clickable hyperlinks, returning the reader to the mark's location.
/// Entries follow original mark order, or body declaration order for standalone
/// bodies. Bounds select those source locations; scope filters use body rendering
/// ownership when a body exists. Target and thread filters combine.
/// Reused marks stay in the same entry. Page links list distinct physical pages
/// in mark source order and use native page numbering at each painted destination.
/// Standalone bodies link to their live destination, or declaration if unprinted.
/// For custom layouts or one row per occurrence, use deixis-query-notes.
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
/// - thread (auto, str, label): Filters the outline to only show notes belonging to a specific thread of minipages.
/// - include-types (auto, str, array): One note type or a union of types. Auto includes all; an empty array includes none.
/// - exclude-types (str, array): One note type or a union of types to exclude.
/// - series (auto, str, array): Filters the outline to notes belonging to a specific series or array of series.
/// - include-unpaired (bool, str): Also include marks without bodies, standalone bodies, or both. Values: false, true, "mark", "body".
/// - after (none, location, label, str, dictionary, selector, function): Exclusive source boundary: a native location/label/selector or a pin name/target.
/// - before (none, location, label, str, dictionary, selector, function): Exclusive source boundary, with the same selection rules as after.
/// - group-by (none, str, function): Categorizes the notes under sub-headings. Accepts `"type"` (e.g., "Margin Notes"), `"series"`, or a custom `function(note) => string`.
/// - fill (none, content): Fills the space between the excerpt and the page number. Commonly set to `repeat[.]` for standard TOC styling.
/// - gap (auto, length): The vertical spacing between individual note rows in the outline.
/// - summary (auto, function): A callback `(note) => content` for each excerpt. By default, extracts up to 160 characters of static text without executing contextual content.
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
  /// Filters by rendering scope (body scope when attached, original scope for
  /// marks without bodies). Combines with thread if both are supplied.
  /// -> auto | label | str | int
  target: auto,
  /// Filters the outline to only show notes belonging to a specific thread of minipages.
  /// -> auto | str | label
  thread: auto,
  /// One note type or an array of types to include. Auto includes all; an empty
  /// array includes none. Unknown names select no matching records.
  /// -> auto | str | array
  include-types: auto,
  /// One note type or an array of types to exclude. An empty array excludes none.
  /// -> str | array
  exclude-types: (),
  /// Filters the outline to notes belonging to a specific series or array of series.
  /// -> auto | str | array
  series: auto,
  /// Also include unpaired marks or bodies. False includes paired notes only;
  /// true includes both unpaired kinds; mark or body adds that kind.
  /// -> bool | str
  include-unpaired: false,
  /// Only includes notes after this location, label, pin name, or structured
  /// name/scope/select/page pin target. A pin boundary needs one occurrence.
  /// Native selectors use their first match, as native labels do.
  /// -> none | location | label | str | dictionary | selector | function
  after: none,
  /// Only includes notes before this location, label, pin name, or structured
  /// name/scope/select/page pin target. Forward pin declarations work.
  /// Native selectors use their first match, as native labels do.
  /// -> none | location | label | str | dictionary | selector | function
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
  /// A callback `(note) => content` for each excerpt. The default extracts static
  /// text without running the body; contextual-only notes get a placeholder.
  /// Receives the structured query record plus its presentation badge. Use
  /// note.summary for the safe default excerpt; note.body is a location record.
  /// -> auto | function
  summary: auto,
  /// Unknown options are rejected; include-celibates was renamed to include-unpaired.
  /// -> arguments
  ..args,
) = context {
  assert(args.pos().len() == 0, message: "deixis: The note outline accepts named options only.")
  assert("include-celibates" not in args.named(),
    message: "deixis: include-celibates was renamed to include-unpaired. Use false, true, mark, or body.")
  assert(args.named().len() == 0, message: "deixis: Unknown outline option(s) " + repr(args.named().keys()) + ".")
  assert(summary == auto or type(summary) == function, message: "deixis: Outline summary must be auto or a function.")
  assert(group-by == none or group-by in ("type", "series") or type(group-by) == function,
    message: "deixis: Outline group-by must be none, type, series, or a function.")
  let notes = deixis-query-notes(target: target, thread: thread, include-types: include-types,
    exclude-types: exclude-types, series: series, include-unpaired: include-unpaired, after: after, before: before)
  let pretty-types = (
    "inline-mark": "Inline Marks", "phantom-mark": "Phantom Marks", "region-mark": "Region Marks",
    "inline-note": "Inline Notes", "footnote": "Footnotes", "endnote": "Endnotes",
    "margin-note": "Margin Notes", "inset-note": "Inset Notes",
  )
  let grouped = (:)
  for entry in notes {
    let styles = entry.styles
    let badge = if entry.marker != none and entry.marker != "" {
      box(fill: styles.at("fill", default: none), stroke: styles.at("stroke", default: 0.5pt + luma(200)),
        radius: styles.at("radius", default: 2pt), inset: (x: 0.3em, y: 0.2em), outset: (y: 0.1em),
        baseline: 15%, clip: true, text(size: 0.8em, weight: "bold", entry.marker))
    } else {
      box(fill: styles.at("fill", default: none), stroke: styles.at("stroke", default: 0.5pt + luma(200)),
        radius: styles.at("radius", default: 2pt), width: 0.8em, height: 0.8em, baseline: 10%)
    }
    let note = entry + (badge: badge)
    let key = if group-by == "type" { pretty-types.at(note.type, default: note.type) }
      else if group-by == "series" { note.series }
      else if type(group-by) == function { group-by(note) } else { "Notes" }
    assert(type(key) == str, message: "deixis: Outline group-by callback must return a string.")
    if key not in grouped { grouped.insert(key, ()) }
    grouped.at(key).push(note)
  }
  if title != none { heading(level: heading-level, title) }
  let c-gap = if gap == auto { 0.6em } else { gap }
  for (g-key, g-notes) in grouped {
    if grouped.len() > 1 and group-by != none { heading(level: heading-level + 1, g-key) }
    // HTML has no pages: list each badge with its linked excerpt. Mark and
    // body destinations link through their internal labels' explicit ids.
    if _std-target() == "html" {
      let anchors = query(selector(<deixis-mark-destination>).or(<deixis-body-destination>)).map(elem => (
        loc: elem.location(),
        lbl: label((if elem.label == <deixis-body-destination> { "deixis-body-" } else { "deixis-mark-" })
          + str(elem.value.internal-id)),
      ))
      html.elem("ul", attrs: (class: "deixis-outline", style: "list-style-type: none"), for note in g-notes {
        let anchor = anchors.find(a => a.loc == note.dest)
        let linked(body) = if anchor == none { link(note.dest, body) } else { _deixis-html-link(anchor.lbl, body) }
        html.elem("li", [#linked(note.badge) #linked(if summary == auto { note.summary } else { summary(note) })])
      })
      continue
    }
    let items = ()
    for note in g-notes {
      let excerpt = link(note.dest, if summary == auto { note.summary } else { summary(note) })
      let destinations = if note.marks.len() > 0 { note.marks.map(m => m.dest) }
        else { (note.dest,) }
      let seen-pages = ()
      let pages = ()
      for dest in destinations {
        let physical-page = dest.page()
        if physical-page in seen-pages { continue }
        seen-pages.push(physical-page)
        let pattern = dest.page-numbering()
        let formatted = _std-numbering(if pattern == none { "1" } else { pattern }, ..counter(page).at(dest))
        pages.push(link(dest, formatted))
      }
      let content-and-page = grid(columns: (1fr, auto), column-gutter: 0.5em,
        align: (left + top, right + bottom), {
          set text(size: 0.95em)
          set par(justify: false)
          if fill != none { [#excerpt #box(width: 1fr, fill)] } else { [#excerpt #h(1fr)] }
        }, text(size: 0.95em, pages.join([, ])))
      items.push(link(note.dest, note.badge))
      // Page links have their own mark destinations; do not wrap the whole row
      // in the original's link and accidentally override those nested targets.
      items.push(content-and-page)
    }
    grid(columns: (auto, 1fr), column-gutter: 0.75em, row-gutter: c-gap,
      align: (center + top, left + top), ..items)
  }
}
