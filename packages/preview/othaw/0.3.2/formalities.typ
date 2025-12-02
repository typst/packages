#import "locale.typ": *
#import "confidentiality-statement.typ": *
#import "declaration-of-authorship.typ": *
#import "abstract.typ": *

#let formalities(
  authors,
  title,
  date,
  language,
  many-authors,
  at-university,
  university,
  date-format,
  type-of-thesis,
  course-of-studies,
  abstract-text,
  abstract-content,
  show-abstract,
  supervisor,
  keywords,
  show-declaration-of-authorship,
  declaration-of-authorship-content,
  show-confidentiality-statement,
  confidentiality-statement-content,
  university-location,
  city,
  formalities-in-frontmatter,
) = {
    // ---------- Declaration Of Authorship ---------------------------------------

   if (show-declaration-of-authorship) {
    declaration-of-authorship(
      authors,
      title,
      declaration-of-authorship-content,
      date,
      language,
      many-authors,
      at-university,
      city,
      date-format,
      type-of-thesis,
      course-of-studies,
      formalities-in-frontmatter,
    )
    if formalities-in-frontmatter {pagebreak()}
  }


  // ---------- Abstract ---------------------------------------

  if (show-abstract and abstract-text != none) {
    abstract(
      authors,
      title,
      date,
      language,
      many-authors,
      at-university,
      university,
      date-format,
      type-of-thesis,
      course-of-studies,
      abstract-text,
      abstract-content,
      supervisor,
      keywords,
      formalities-in-frontmatter,
    )
    if formalities-in-frontmatter {pagebreak()}
  }
   // ---------- Confidentiality Statement ---------------------------------------

  if (not at-university and show-confidentiality-statement) {
    confidentiality-statement(
      authors,
      title,
      confidentiality-statement-content,
      university,
      university-location,
      date,
      language,
      many-authors,
      date-format,
      formalities-in-frontmatter,
    )
    if formalities-in-frontmatter {pagebreak()}
  }
}
