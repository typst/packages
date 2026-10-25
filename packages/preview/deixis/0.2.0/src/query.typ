#import "core/catalogue.typ": _deixis-note-catalogue

/// Returns one structured record per selected annotation without rendering it.
/// Call inside context. Use the records for tables, cards, or occurrence indexes;
/// deixis-note-outline is the ready-made outline presentation of the same data.
///
/// Each record has id, data, accent, type, series, count, marker, styles, loc, dest, order,
/// summary, marks, and body. Summary content is extracted statically. Marks is
/// an array of original/reused locations with destinations, types, occurrence
/// names, source orders, and safe summaries. Body is none or a declaration record
/// with declaration loc/order, render-order (none without a unique live start),
/// dest (none until painted), complete start/end
/// locations, and summary.
/// Accent is the saved palette color or none; explicit component styles may
/// override its appearance without changing that semantic color.
/// Executable note bodies and marked passages are never returned or replayed.
/// Data is the author's opaque dictionary, inherited from the original or
/// supplied by a standalone body. It is returned unchanged, never traversed or
/// rendered by the query; custom content/callbacks in data remain the caller's.
/// Optional page selects complete live body spans on one physical page, including
/// continuations. Page queries default to native body order and include standalone
/// bodies. Without page, defaults retain source order and paired annotations,
/// including unprinted bodies. Explicit order/include-unpaired override those
/// defaults. Incomplete/duplicate spans cannot supply page coverage.
///
/// -> array
#let deixis-query-notes(
  /// Rendering domain to select. Auto selects all; 0 selects the current scope.
  /// For attached notes, filtering uses the body domain, preserving mark ownership.
  /// -> auto | str | label | int
  target: auto,
  /// Optional thread filter. Combines with target.
  /// -> auto | str | label
  thread: auto,
  /// A literal type or union of types; auto includes all, an empty array none.
  /// -> auto | str | array
  include-types: auto,
  /// A literal type or union of types to exclude.
  /// -> str | array
  exclude-types: (),
  /// A literal series or union of series; auto includes all, an empty array none.
  /// -> auto | str | array
  series: auto,
  /// Auto includes standalone bodies in a page query, otherwise paired notes only.
  /// False includes only paired notes; true also includes both unpaired kinds.
  /// Mark or body includes that unpaired kind in addition to paired notes.
  /// -> auto | bool | str
  include-unpaired: auto,
  /// Exclusive original-source boundary, or body declaration for standalone
  /// bodies. Reused marks do not move originals into a range. All selected
  /// notes retain their complete marks array, including marks outside the range.
  /// -> none | location | label | str | dictionary | selector | function
  after: none,
  /// Exclusive upper source boundary with the same rules as after. Native
  /// labels/selectors choose their first match; strings/records choose pins.
  /// -> none | location | label | str | dictionary | selector | function
  before: none,
  /// Physical body page to select; positive integer, independently of displayed
  /// numbering/resets. Auto does not filter. Unprinted/incomplete spans do not
  /// match a page. Marks on that page alone do not make a body match.
  /// -> auto | int
  page: auto,
  /// Auto selects body order with page, source order without page. Source follows
  /// original declarations; body follows unique live start spans, retaining
  /// continuations before later starts. Unprinted/missing/ambiguous starts sort
  /// last in source order. Neither mode sorts marker values or visual coordinates.
  /// -> auto | str
  order: auto,
) = {
  assert(page == auto or (type(page) == int and page > 0),
    message: "deixis: Query page must be auto or a positive physical page integer.")
  assert(order in (auto, "source", "body"),
    message: "deixis: Query order must be auto, source, or body.")
  let unpaired = if include-unpaired == auto { if page == auto { false } else { "body" } } else { include-unpaired }
  let order = if order == auto { if page == auto { "source" } else { "body" } } else { order }
  let notes = _deixis-note-catalogue(target, thread, include-types, exclude-types, series, unpaired, after, before)
  if page != auto {
    notes = notes.filter(n => n.body != none and n.body.start != none and n.body.end != none
      and n.body.start.page() <= page and page <= n.body.end.page())
  }
  if order == "source" { return notes }
  notes.sorted(key: n => {
    let rendered = if n.body == none { none } else { n.body.render-order }
    (if rendered == none { 1 } else { 0 }, if rendered == none { n.order } else { rendered })
  })
}
