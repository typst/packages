#import "state.typ": (
  ENTRY_CONTENT_FONT_SIZE_SCALE, ENTRY_DATE_FONT_SIZE_SCALE,
  ENTRY_LEFT_COLUMN_WIDTH, __st-theme,
)


/// Converts an author entry into a canonical `Last, First` string.
///
/// -> str
#let __author-name(
  /// Author data as a string or Hayagriva name dictionary.
  /// -> str | dictionary
  author,
  /// Publication identifier used in assertion messages.
  /// -> str
  pub_id,
) = {
  // in Hayagriva YAML, authors can be strings or dictionaries
  if (type(author) == dictionary) {
    author = (
      author.at("prefix", default: "")
        + " "
        + author.at("name", default: "")
        + ", "
        + author.at("given-name", default: "")
    ).trim()
  }

  assert(
    type(author) == str,
    message: "Author names must be strings or dictionaries.\nType:"
      + repr(type(author))
      + "\nEntry: "
      + pub_id
      + "\nFound: "
      + repr(author),
  )

  author
}

/// Formats an author name as initials plus surname.
///
/// -> content
#let __format-author(
  /// Author data as a string or Hayagriva name dictionary.
  /// -> str | dictionary
  author,
  /// Publication identifier used in assertion messages.
  /// -> str
  pub_id,
) = {
  let author = __author-name(author, pub_id)

  let author-parts = author.split(", ")
  let last-name = author-parts.at(0, default: author)
  let first-names-str = author-parts.at(1, default: "")

  if first-names-str == "" {
    return [#last-name]
  }

  let initials = first-names-str
    .split(" ")
    .filter(p => p.len() > 0)
    .map(p => [#p.at(0).])
    .join(" ")

  [#initials #last-name]
}

/// Returns true if author matches the corresponding-author string.
///
/// -> bool
#let __author-matches(
  /// Author data as a string or Hayagriva name dictionary.
  /// -> str | dictionary
  author,
  /// Canonical corresponding author name.
  /// -> str | none
  corresponding,
  /// Publication identifier used in assertion messages.
  /// -> str | none
  pub_id: none,
) = {
  if corresponding == none { return false }
  (
    __author-name(author, if pub_id == none { corresponding } else { pub_id })
      == corresponding
  )
}

/// Returns true if author is listed in highlight-authors.
///
/// -> bool
#let __author-highlighted(
  /// Author data as a string or Hayagriva name dictionary.
  /// -> str | dictionary
  author,
  /// Canonical author names that should be emphasized.
  /// -> array
  highlight-authors,
  /// Publication identifier used in assertion messages.
  /// -> str
  pub_id,
) = {
  let canonical-author = __author-name(author, pub_id)
  highlight-authors.any(highlighted => highlighted == canonical-author)
}

/// Formats a publication entry (article, conference, etc.).
///
/// -> content
#let __format-publication-entry(
  /// Publication data.
  /// -> dictionary
  pub,
  /// Canonical author names to highlight.
  /// -> array
  highlight-authors,
  /// Maximum number of author slots to display before `_et al_`.
  /// -> int
  max-authors,
) = {
  // Make sure that author is an array
  if (type(pub.author) == str) {
    pub.author = (pub.author,)
  }

  let highlighted-authors = highlight-authors.map(a => __author-name(
    a,
    pub.__id,
  ))
  let corresponding = pub.at("corresponding-author", default: none)
  let n-shown = calc.min(max-authors, pub.author.len())
  let corr-author = pub.author.find(a => __author-matches(
    a,
    corresponding,
    pub_id: pub.__id,
  ))
  let authors-truncated = pub.author.len() > n-shown
  let shown-authors = if (
    max-authors > 0
      and authors-truncated
      and corr-author != none
      and __author-highlighted(corr-author, highlighted-authors, pub.__id)
      and not pub
        .author
        .slice(0, n-shown)
        .any(a => __author-matches(a, corresponding, pub_id: pub.__id))
  ) {
    (
      ..pub.author.slice(0, max-authors - 1),
      corr-author,
    )
  } else {
    pub.author.slice(0, n-shown)
  }

  for (i, author) in shown-authors.enumerate() {
    let author-display = __format-author(author, pub.__id)
    let author-highlighted = __author-highlighted(
      author,
      highlighted-authors,
      pub.__id,
    )

    if author-highlighted {
      text(weight: "medium", author-display)
    } else {
      author-display
    }

    if (
      __author-matches(author, corresponding, pub_id: pub.__id)
        and author-highlighted
    ) {
      super[#text(weight: "bold")[†]]
    }

    if i < shown-authors.len() - 1 {
      if i == shown-authors.len() - 2 and not authors-truncated {
        [, and ]
      } else {
        [, ]
      }
    }
  }

  if authors-truncated {
    [, _et al_]
  }

  [, "#pub.title.replace(regex("[{}]"), "")",]

  // TODO: handle cases where parent is missing gracefully
  // at the moment we could assert its presence like this:
  // assert("parent" in pub,
  //     message: "Missing 'parent' field for publication:\n" +
  //     repr(pub) +
  //     "\nPlease ensure that the 'parent' field is provided.")
  // Alternative is to implement the Hayagriva spec more fully
  // Below is only a partial implementation

  if (not "parent" in pub) {
    if "publisher" in pub {
      [ _#pub.publisher.replace(regex("[{}]"), "")_]
    }
  } else {
    let parent = pub.parent

    if parent.type == "proceedings" {
      [ in ]
    }

    [ _#parent.title.replace(regex("[{}]"), "")_]

    if "volume" in parent and parent.volume != none {
      [ _#(parent.volume)_]
    }

    if "issue" in parent and parent.issue != none {
      [_(#parent.issue)_]
    }
  }

  if "page-range" in pub and pub.page-range != none {
    [_:#(pub.page-range)_]
  }

  if "date" in pub {
    [, #str(pub.date).split("-").at(0)]
  }

  if "serial-number" in pub and "doi" in pub.serial-number {
    [, doi: #link("https://doi.org/" + pub.serial-number.doi)[_#(pub.serial-number.doi)_]]
  }

  if "url" in pub and pub.url != none and type(pub.url) == str {
    [, #link(pub.url)[_#(pub.url)_]]
  }

  [.]
}

/// Displays publications for a specific year.
///
/// -> content
#let __format-publications-year(
  /// Publications belonging to one year bucket.
  /// -> array
  publications-year,
  /// Canonical author names to highlight.
  /// -> array
  highlight-authors,
  /// Maximum number of author slots to display per entry.
  /// -> int
  max-authors,
) = (
  for publication in publications-year {
    block([
      #set text(size: ENTRY_CONTENT_FONT_SIZE_SCALE * 1em)
      #__format-publication-entry(
        publication,
        highlight-authors,
        max-authors,
      )
    ])
  }
)

/// Displays publications grouped by year from a Hayagriva YAML file.
///
/// -> content
/// TODO: this should be handled by default bibliography support once it becomes more flexible,
/// so that for example different CLS citation styles can be used
#let publications(
  /// Bibliography data loaded from YAML.
  /// -> dictionary
  yaml-data,
  /// Canonical author names to highlight.
  /// -> array
  highlight-authors: (),
  /// Maximum number of author slots to display per entry.
  /// -> int
  max-authors: 10,
  /// Whether to display years in reverse order (most recent first).
  /// -> bool
  reverse-order: true,
) = (
  context {
    let theme = __st-theme.final()
    let publications-by-year = (:)

    set block(above: 0.7em, width: 100%)

    for (key, pub) in yaml-data {
      // add the ID to the publication data so we can better debug if needed
      pub.__id = key

      let year = str(pub.at("date", default: "")).split("-").at(0)

      // ignore publications without a date
      if year == "" {
        continue
      }

      if year in publications-by-year {
        publications-by-year.at(year) += (pub,)
      } else {
        publications-by-year.insert(year, (pub,))
      }
    }

    let all-years = publications-by-year.keys().sorted()

    if (reverse-order) {
      all-years = all-years.rev()
    }

    for year in all-years {
      grid(
        columns: (ENTRY_LEFT_COLUMN_WIDTH, auto),
        align: (right, left),
        column-gutter: .8em,
        text(
          size: ENTRY_DATE_FONT_SIZE_SCALE * 1em,
          fill: theme.font-color.lighten(50%),
          year,
        ),
        __format-publications-year(
          publications-by-year.at(year),
          highlight-authors,
          max-authors,
        ),
      )
    }
  }
)
