#import "../util/utils.typ"
#import "../_deps.typ" as deps

/// Removes special characters from #arg[term] to make it
/// a valid format for the index.
/// -> string
#let idx-term(
  /// The term to sanitize.
  /// -> str | content
  term,
) = {
  utils.get-text(term).replace(regex("[#_()]"), "")
}


/// Adds #arg[term] to the index.
///
/// Each entry can be categorized by setting #arg[kind].
/// @cmd:make-index can be used to generate the index for one kind only.
/// -> none | content
#let idx(
  /// An optional term to use, if it differs from #arg[body].
  /// -> str | content
  term,
  /// A category for this term.
  /// -> str
  kind: "term",
  /// If this is the "main" entry for this #arg[term].
  /// -> bool
  main: false,
  /// An optional content element to show in the index instead of #arg[term],
  /// -> content
  display: auto,
) = [#metadata((
    term: utils.get-text(term),
    kind: kind,
    main: main,
    display: display,
  ))<mantys:index>]

/// Creates an index from previously set entries.
/// -> content
#let make-index(
  /// An optional kind of entries to show.
  /// -> str
  kind: auto,
  /// Function to format headings in the index: #lambda("str", ret: "content")
  /// -> function
  heading-format: text => heading(depth: 2, numbering: none, outlined: false, bookmarked: false, text),
  /// Function to format index entries. Receives the @type:index-entry and an array of page numbers.
  ///
  /// #lambda("content", "array", ret: "content")
  /// -> content
  entry-format: (term, pages) => [#term #box(width: 1fr, repeat[.]) #pages.join(", ")\ ],
  /// Sorting function to sort index entries.
  ///
  /// #lambda("str", ret:"str")
  /// -> function
  sort-key: it => it.term,
  /// Grouping function to group index entries by. Usually entries are grouped by the first letter of #arg[term], but this can be changed to group by other keys. See below for an example.
  ///
  /// #lambda("str", ret:"str")
  /// -> function
  grouping: it => upper(it.term.at(0)),
) = context {
  let entries = query(<mantys:index>)

  if kind != auto {
    let kinds = (kind,).flatten()
    entries = entries.filter(entry => entry.value.kind in kinds)
  }

  let register = (:)
  for entry in entries {
    if entry.value.term not in register {
      register.insert(
        entry.value.term,
        (
          term: entry.value.term,
          kind: entry.value.kind,
          display: entry.value.display,
          main: if entry.value.main {
            entry.location()
          } else {
            none
          },
          locations: (entry.location(),),
        ),
      )
    } else {
      let idx = register.at(entry.value.term)
      if idx.main == none and entry.value.main {
        idx.main = entry.location()
      }
      idx.locations.push(entry.location())
      if idx.display == auto and entry.value.display != auto {
        idx.display = entry.value.display
      }
      register.at(entry.value.term) = idx
    }
  }

  let get-page(loc) = loc.page()
  let link-page(loc) = link(loc, str(loc.page()))
  let link-term(term, loc) = {
    if loc != none {
      link(loc, term)
    } else {
      [#term]
    }
  }

  for (term, entry) in register {
    entry.locations = entry.locations.dedup(key: get-page).sorted(key: get-page)
    register.at(term) = entry
  }

  let index = (:)
  for (term, entry) in register {
    let key = grouping(entry)
    if key not in index {
      index.insert(key, ())
    }
    index.at(key).push(entry)
  }

  for group in index.keys().sorted() {
    let entries = index.at(group)

    heading-format(group)
    for entry in entries.sorted(key: sort-key) {
      entry-format(
        link-term(
          if entry.display == auto {
            entry.term
          } else {
            entry.display
          },
          entry.main,
        ),
        entry.locations.map(link-page),
      )
    }
  }
}
