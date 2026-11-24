// Exemption notes: the legal notes below the line items that give the reason
// for an exemption (exemption grounds, reverse charge, small business
// scheme), and the markers that link each note to the VAT line of its
// category in the totals and, if a category has items exempt for different
// reasons, to these items.
//
// `line-items` prepares them for the theme: its view lists the notes as
// `exemption-notes`, and every VAT group and the tax of every item carry
// their `marker`. The theme only prints them.

#import "../data/tax.typ" as m-tax

// The markers of the first distinct grounds; later grounds are numbered.
#let _symbols = ("*", "**", "***", "****")

/// Assigns a marker to every distinct exemption ground of the VAT groups
/// (compared by text, see `tax.grounds-key`), in the order of the groups:
/// `"*"`, `"**"`, `"***"`, `"****"`, then `"*5"`, `"*6"`, ...
///
/// Returns `(grounds: .., itemized: ..)`: the marker of every ground by its
/// key, and the keys of the VAT groups with several grounds. The items of
/// these groups are marked with the marker of their own ground.
///
/// -> dictionary
#let assign-markers(
  /// The VAT groups of the tax applicator by their key (`tax.to-tax-key`).
  /// -> dictionary
  taxes,
) = {
  let markers = (:)
  let itemized = (:)
  for (tax-key, tax) in taxes {
    let list = m-tax.grounds-of(tax)
    for grounds in list {
      let key = m-tax.grounds-key(grounds)
      if key not in markers {
        let index = markers.len()
        markers.insert(key, if index < _symbols.len() {
          _symbols.at(index)
        } else { "*" + str(index + 1) })
      }
    }
    if list.len() > 1 { itemized.insert(tax-key, true) }
  }
  (grounds: markers, itemized: itemized)
}

/// The markers of the exemption grounds of a VAT group, in the order of its
/// grounds (`tax.grounds-of`).
///
/// -> array
#let group-markers(
  /// A VAT group of the tax applicator.
  /// -> dictionary
  tax,
  /// The markers, see `assign-markers`.
  /// -> dictionary
  markers,
) = {
  let result = ()
  for grounds in m-tax.grounds-of(tax) {
    result.push(markers.grounds.at(m-tax.grounds-key(grounds), default: none))
  }
  result
}

/// The marker of the exemption grounds of an item if its VAT group has
/// several grounds (the tax column then shows which one applies to the
/// item), `none` otherwise.
///
/// -> none | str
#let item-marker(
  /// The tax of the item.
  /// -> dictionary
  tax,
  /// The markers, see `assign-markers`.
  /// -> dictionary
  markers,
) = {
  if m-tax.to-tax-key(tax) not in markers.itemized { return none }
  let result = ()
  for grounds in m-tax.grounds-of(tax) {
    result.push(markers.grounds.at(m-tax.grounds-key(grounds), default: none))
  }
  if result.len() == 0 { none } else { result.join(",") }
}

// Whether a VAT group of the view is zero rated, also if its rate only prints
// as 0%. The totals leave out its VAT line, so no marker can point to it.
#let _zero-rated(tax) = (
  tax.raw-rate == 0
    or tax.rate == [0%]
    or tax.rate == [0,0%]
    or tax.rate == [0.0%]
)

/// The exemption notes below the line items, in the order to print them:
/// the clause of the small business scheme (with `tax-exempt-small-biz`),
/// then every distinct exemption ground of the VAT groups, each once.
///
/// Every note is `(kind: .., marker: .., body: ..)`:
/// - `kind`: `"small-business"` or `"grounds"`,
/// - `marker`: the marker that links the note to the VAT line of its
///   category or to its items, `none` if neither shows the marker,
/// - `body`: the text of the note.
///
/// -> array
#let exemption-notes(
  /// The VAT groups as the view of `line-items` lists them, with `grounds`,
  /// `grounds-list`, `grounds-markers`, `itemized-grounds`, `marker`,
  /// `raw-rate` and `rate`.
  /// -> array
  taxes,
  /// Whether the totals, with a VAT line per category, are shown.
  /// -> bool
  show-total: true,
  /// Whether the tax column, with the markers of the items, is shown.
  /// -> bool
  show-tax-rates: false,
  /// With `tax-exempt-small-biz`, the small business scheme as
  /// `(clause: .., grounds: .., same-language: ..)`: the legal clause in the
  /// language of the document, the legal grounds of the region (`none` if
  /// it has none) and whether both are in the same language.
  /// -> none | dictionary
  small-business: none,
) = {
  let notes = ()
  // The keys of the grounds printed so far.
  let printed = ()

  if small-business != none {
    let (clause, grounds, same-language) = small-business
    // The clause is linked to the VAT line of the scheme's category.
    let scheme-tax = none
    for tax in taxes {
      if tax.grounds == grounds {
        scheme-tax = tax
        break
      }
    }
    let marker = if (
      scheme-tax != none and not _zero-rated(scheme-tax) and show-total
    ) { scheme-tax.marker }
    // Without regional grounds, the clause is printed on its own, so the
    // notice is never dropped (e.g. `tax.outside-scope()` overrides).
    let body = if grounds == none { clause } else if same-language {
      grounds
    } else [#clause (#grounds)]
    notes.push((kind: "small-business", marker: marker, body: body))
    if grounds != none { printed.push(m-tax.grounds-key(grounds)) }
  }

  // Every distinct ground of every VAT category, each on its own line (a
  // category can have items exempt for different reasons).
  for tax in taxes {
    // The marker links a note to the VAT line of its category (not shown
    // for 0%) or, with several grounds in one category, to its items (tax
    // column).
    let show-marker = (
      (not _zero-rated(tax) and show-total)
        or (tax.itemized-grounds and show-tax-rates)
    )
    for (grounds, marker) in tax.grounds-list.zip(tax.grounds-markers) {
      if not m-tax.has-grounds(grounds) { continue }
      let key = m-tax.grounds-key(grounds)
      if key in printed { continue }
      printed.push(key)
      notes.push((
        kind: "grounds",
        marker: if show-marker { marker },
        body: grounds,
      ))
    }
  }
  notes
}
