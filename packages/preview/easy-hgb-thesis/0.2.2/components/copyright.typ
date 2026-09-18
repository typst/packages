#import "i18n.typ": i18n, i18n-translation
#import "constants.typ": LICENSE_TYPES

/// Displays an optional copyright page, typically placed after the title page.
/// - license (int, content): The license to display. Use `LICENSE_TYPES.cc-by-nc-nd` or `LICENSE_TYPES.all-rights-reserved` or custom content.
/// - submission-date (datetime): The submission date used for the copyright year. Defaults to document.date.
#let copyright-page(
  license,
  submission-date: auto,
) = context {
  let submission-date = if submission-date == auto {
    if document.date == auto { datetime.today() } else { document.date }
  } else {
    submission-date
  }
  let author-text = document.author.join(", ")
  let year = submission-date.year()

  set text(size: 10pt)
  set page(header: none, footer: none)

  v(80mm)
  align(center)[
    #sym.copyright Copyright #year #author-text
  ]
  v(8mm)

  if license == LICENSE_TYPES.cc-by-nc-nd {
    i18n("license-cc")
  } else if license == LICENSE_TYPES.all-rights-reserved {
    align(center)[#i18n("license-strict")]
  } else if type(license) == content or type(license) == str {
    license
  }
}
