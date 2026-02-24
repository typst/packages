/// Set up front matter environment
///
/// -> content
#let frontmatter(
  /// Type of thesis
  ///
  /// -> "doctor" | "master" | "bachelor"
  doctype: "doctor",
  /// Language of the thesis
  ///
  /// -> "en" | "zh" | "pt"
  lang: "en",
  /// -> content
  body,
) = {
  set page(numbering: "i")
  counter(page).update(1)
  // Page number at first page
  set page(
    footer: context {
      if counter(page).get().first() == 1 { none } else { h(1fr) + counter(page).display() + h(1fr) }
    },
  ) if doctype == "master"
  // Omit numbering for first level headings
  set heading(numbering: none, supplement: none)
  // Outline style settings
  set outline(title: [Table of Contents])
  set outline(
    depth: 3,
    indent: n => calc.max(0, n - 1) * 2.5em,
  ) if doctype == "doctor"
  set outline(
    depth: 4,
    indent: 3em,
  ) if doctype == "master"
  // Uppercase first level headings for master thesis
  show outline.entry.where(level: 1): it => if doctype == "master" {
    upper(it)
  } else {
    it
  }

  ////////////////////////////
  // Custom format settings //
  ////////////////////////////

  show outline.entry.where(level: 1): set text(
    weight: if doctype == "doctor" { "bold" } else { "regular" },
  )

  body
}
