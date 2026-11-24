/// Returns the appropriate Hungarian definite article for a numeric prefix.
///
/// The function chooses between `"a "` and `"az "` according to the
/// pronunciation of the leading number. For values above 999, only the
/// highest-order group is considered.
///
/// Examples:
/// - `1` -> `"az "`
/// - `4` -> `"a "`
/// - `51` -> `"az "`
/// - `400` -> `"a "`
/// - `500` -> `"az "`
///
/// - `i`: Numeric prefix used to determine the article.
#let _aaz(i) = {
  if i > 999 {
    return _aaz(i / 1000)
  }

  if i == 1 or i == 5 or (i > 49 and i < 60) or (i > 499 and i < 600) {
    "az "
  } else {
    "a "
  }
}

/// Returns the appropriate Hungarian definite article for an appendix letter.
///
/// Appendix letters are represented internally by their alphabetic counter
/// values (`1` = A, `2` = B, ..., `6` = F). The article is selected according
/// to the Hungarian pronunciation of the corresponding letter.
///
/// Letters pronounced with an initial vowel sound:
/// A, E, F, I, L, M, N, O, R, S, U, X, Y.
///
/// - `i`: Alphabetic counter value of the appendix prefix.
#let _appendix-aaz(i) = {
  if i in (1, 5, 6, 9, 12, 13, 14, 15, 18, 19, 21, 24, 25) {
    "az "
  } else {
    "a "
  }
}

/// Creates a reference function that prepends the appropriate Hungarian article.
///
/// The function resolves the supplied label, determines the heading prefix at
/// the referenced element's location, and selects the appropriate article.
/// Appendix references use the pronunciation of their alphabetic prefix.
///
/// - `capitalized`: Whether the article should begin with a capital letter.
/// - `doc-part`: State indicating the current document part, such as `"main"`
///   or `"appendix"`.
///
/// Returns a function accepting:
/// - `label`: Label of the referenced element.
/// - `supplement`: Optional supplement forwarded to `ref`. Defaults to `auto`.
#let _make-aref(capitalized: false, doc-part) = (label, supplement: auto) => context {

    let matches = query(label)

    if matches.len() == 0 {
      panic("Label not found: " + repr(label))
    }

    let element = matches.first()
    let location = element.location()

    let headings = counter(heading).at(location)

    if headings.len() == 0 {
      panic("No heading found for label: " + repr(label))
    }

    let first = headings.first()

    let article = if doc-part.at(location) == "appendix" {
      _appendix-aaz(first)
    } else {
      _aaz(first)
    }

    if capitalized {
      article = upper(article.first()) + article.slice(1)
    }

    article + ref(label, supplement: supplement)
  }