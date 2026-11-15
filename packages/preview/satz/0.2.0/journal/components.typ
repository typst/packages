#import "../defaults.typ": defaults, merge

/// Record one journal entry for `journal-index`.
///
/// The metadata is attached to a `<journal-item>` label at the call location.
/// The index reads its title and date from that metadata and resolves the
/// location to obtain the page number. This helper has no customization
/// arguments and emits no visible page content.
///
/// - title (str, content): title stored for the index
/// - date (str): original date string stored for parsing and display
/// - keywords (str): keyword string stored with the entry; the index does not
///   display it
#let journal-metadata-entry(title, date, keywords) = {
  [#metadata((title: title, date: date, keywords: keywords)) <journal-item>]
}

/// Draw the date and keywords row under a journal entry heading.
///
/// The two columns are equal width. Date and keywords are aligned to the left
/// and right edges respectively. This helper uses the given configuration
/// directly and does not apply a theme or validate config keys.
///
/// - date (content, str): date shown in the left column
/// - keywords (content, str): keywords shown in the right column
/// - config (dictionary): values are merged over the shared defaults. Only
///   `journal.date-size` (length, default `10pt`),
///   `journal.keywords-size` (length, default `9pt`), and
///   `colors.text-muted` (color, default black) affect this row. All other
///   fields are ignored. A caller may pass the already resolved document
///   config to make the colors match its theme.
///   For shared field types, meanings, and baseline defaults, hover the exported
///   `defaults` dictionary (`satz.defaults` with a namespace import). This helper
///   does not validate its values. Unknown fields are merged and ignored unless
///   they supply one of the three consumed settings above.
#let journal-date-keywords(date, keywords, config: (:)) = {
  let c = merge(defaults, config)
  grid(
    columns: (1fr, 1fr),
    align(left)[#text(size: c.journal.date-size, style: "italic", fill: c.colors.text-muted)[#date]],
    align(right)[#text(size: c.journal.keywords-size, fill: c.colors.text-muted, weight: "medium")[#keywords]]
  )
}

/// A blue box for things you want to keep in mind.
///
/// The label and colors are fixed for now, so the box is not theme-aware.
///
/// ```example
/// #remember[ICA needs raw, non-interpolated data.]
/// ```
///
/// - body (content): the note to retain
#let remember(body) = block(
  fill: rgb("e1f5fe"),
  stroke: 0.5pt + rgb("0288d1"),
  inset: 8pt,
  width: 100%,
  radius: 4pt,
)[
  *📌 TO REMEMBER:* #body
]

/// An orange box for open questions.
///
/// The label and colors are fixed for now, so the box is not theme-aware. Use it
/// to keep unresolved questions visible during review.
///
/// ```example
/// #question[Why did the EOG check flag component 3?]
/// ```
///
/// - body (content): the unresolved question
#let question(body) = block(
  fill: rgb("fff3e0"),
  stroke: 0.5pt + rgb("f57c00"),
  inset: 8pt,
  width: 100%,
  radius: 4pt,
)[
  *❓ UNRESOLVED:* #body
]
