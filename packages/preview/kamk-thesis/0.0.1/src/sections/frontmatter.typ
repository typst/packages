#import "../core/config.typ": setup-document, setup-body-page
#import "titlepage.typ": titlepage
#import "abstract.typ": render-abstract
#import "foreword.typ": render-foreword

// Load the translations
#let lang-data = toml("../data/lang.toml")

// Orchestrates the front matter: title page, abstracts, ToC, and optional symbol list.
#let frontmatter(
  title: "",
  title-en: "",
  authors: (),
  degree-title: "",
  degree-title-en: "",
  degree-programme: "",
  degree-programme-en: "",
  keywords-fi: (),
  keywords-en: (),
  abstract-fi: none,
  abstract-en: none,
  foreword: none,
  symbols: (),
  date: datetime.today(),
  language: "fi",
  cover-image: none,
  body,
) = {
  // setup-document/setup-body-page take `body` so their set/show rules stay in scope
  // for everything nested inside, instead of being discarded at the end of the call.
  setup-document(title: title, authors: authors, language: language, {
    // Render the title page with zero margins
    page(margin: 0cm)[
      #titlepage(
        title: if language == "en" { title-en } else { title },
        authors: authors,
        degree-title: degree-title,
        degree-programme: degree-programme,
        date: date,
        language: language,
        cover-image: cover-image,
      )
    ]

    // These settings apply to all pages from now on, until told otherwise.
    setup-body-page(language: language, {
      // Finnish abstract (Tiivistelmä)
      render-abstract(
        lang-data.at("fi"),
        authors: authors,
        language: "fi",
        title: title,
        degree: degree-title + ", " + degree-programme,
        keywords: keywords-fi,
        abstract-fi
      )

      pagebreak(weak: true)

      // English abstract (Abstract)
      render-abstract(
        lang-data.at("en"),
        authors: authors,
        language: "en",
        title: title-en,
        degree: degree-title-en + ", " + degree-programme-en,
        keywords: keywords-en,
        abstract-en
      )

      pagebreak(weak: true)

      // Alkusanat / Foreword (optional)
      if foreword != none {
        render-foreword(language: language, foreword)
        pagebreak(weak: true)
      }

      // 3. Sisällys / Table of Contents
      {
        // Intercept ToC entries to format the Appendices heading specifically
        show outline.entry: it => {
          if it.element.has("label") and it.element.label == <kamk-appendices> {
            // Wrap in a block to bypass the global par(spacing: 3.0em)
            block(
              // This should follow the standard spacing within a paragraph, not between paragraphs
              above: 1.5em, 
              link(it.element.location())[#it.element.body]
            )
          } else {
            it
          }
        }

        outline(
          title: lang-data.at(language).toc,
          indent: auto,
        )
      }

      pagebreak(weak: true)

      // 4. Symboliluettelo / List of Symbols (optional)
      if symbols.len() > 0 {
        heading(level: 1, outlined: false, lang-data.at(language).symbols)
        terms(..symbols.map(pair => terms.item(pair.at(0), pair.at(1))))
        pagebreak(weak: true)
      }

      // After the ToC, we shall have numbering on the headings
      set heading(numbering: "1.1")

      // Visible page numbering only starts from the main body (e.g. "Johdanto") onwards
      set page(numbering: "1", number-align: top + right)
      counter(page).update(1)

      // Body text of the document starts here
      body
    })
  })
}

