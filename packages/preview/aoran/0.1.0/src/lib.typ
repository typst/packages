//! aoran Typst package entry point.
//!
//! Provides helpers for determining whether a word should be prefixed with
//! `a` or `an`.

#import "./article.typ" as article-core

#let package-version = "0.1.0"

/// Returns the current package version as a string.
#let version() = package-version

/// Determine the indefinite article (`"a"` or `"an"`) for `word`.
///
/// Set `capitalized` to true to receive the article with leading capital,
/// suitable for sentence starts. Returns `none` when the input is empty or
/// consists solely of whitespace.
#let article(word, capitalized: false) = {
  let result = article-core.determine(word)
  if result == none {
    return none
  }

  if capitalized {
    if result == "an" {
      "An"
    } else {
      "A"
    }
  } else {
    result
  }
}
