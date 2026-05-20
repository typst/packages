#import "components/glossary.typ": nomenclature
#import "components/declaration.typ": declaration
#import "components/bibliography.typ": bibliography
#import "components/base.typ": (
  abstract, appendix, list-of-figures, list-of-listings, list-of-tables, render-body, table-of-contents,
)
#import "styles/emi.typ": style as emi-style
#import "styles/mv.typ": style as mv-style
#import "styles/w.typ": style as w-style
#import "locales.typ": translations
#import "utils.typ": thesis-page-numbering

// Re-export styles for convenience
#let styles = (
  emi: emi-style,
  mv: mv-style,
  w: w-style,
)

// --- Enums & Constants ---

#let faculty = (
  EMI: "Elektrotechnik, Medizintechnik und Informatik",
  W: "Wirtschaft",
  MV: "Maschinenbau & Verfahrenstechnik",
)

#let thesis-type = (
  BACHELOR: "Bachelorthesis",
  MASTER: "Masterthesis",
  SEMINAR: "Seminararbeit",
)

// --- Data Objects & Types ---

#let supervisor(name: "", institution: "", gender: "f") = {
  assert(type(name) == str, message: "Supervisor name must be a string")
  assert(gender in ("m", "f"), message: "Gender must be 'm' or 'f'")
  (
    __type: "supervisor",
    name: name,
    institution: institution,
    gender: gender,
    display: ctx => {
      let supervisor-label = if gender == "f" { ctx.strings.supervisor-f } else { ctx.strings.supervisor-m }
      (
        [#supervisor-label #institution:],
        name,
      )
    },
  )
}

#let company(name: "", logo: none) = {
  assert(type(name) == str, message: "Company name must be a string")
  (
    __type: "company",
    name: name,
    logo: logo,
  )
}

#let thesis-info(
  lang: "de",
  thesis-type: thesis-type.BACHELOR,
  title: "",
  subtitle: "",
  faculty: faculty.EMI,
  author: "",
  degree: "",
  period: [01.01.2026 -- 30.06.2026],
  supervisors: (),
  companies: (),
  location: "Musterstadt",
  ai-usage: none,
  copyright: true,
  glossary: none,
  bibliography: "",
  bibliography-style: "../assets/ieee.csl",
) = {
  // Validierungen
  assert(type(author) == str and author != "", message: "Author must be a non-empty string")
  assert(type(supervisors) == array, message: "Supervisors must be an array of supervisor() objects")
  assert(type(companies) == array, message: "Companies must be an array of company() objects")
  assert(ai-usage in (none, 1, 2, 3), message: "ai-usage must be one of none, 1, 2, or 3")

  (
    lang: lang,
    type: thesis-type,
    title: title,
    subtitle: subtitle,
    faculty: faculty,
    author: author,
    degree: degree,
    period: period,
    supervisors: supervisors,
    companies: companies,
    location: location,
    copyright: copyright,
    ai-usage: ai-usage,
    glossary: glossary,
    bibliography: bibliography,
    bibliography-style: bibliography-style,
  )
}

// Collect all possible Components and map them to a name.
// You can choose your own order of the components by simply listing the names / keys in the wanted order.
#let components = (
  abstract: abstract,
  toc: table-of-contents,
  nomenclature: nomenclature,
  declaration: declaration,
  bibliography: bibliography,
  body: render-body,
  figures: list-of-figures,
  tables: list-of-tables,
  listings: list-of-listings,
  appendix: appendix,
)

// --- Main Template Function ---

#let thesis(
  info: (:),
  style: none,
  abstract: none,
  appendix: none,
  body,
) = {
  // Initialize the style dictionary
  let style-dict = style(components: components)

  let ctx = (
    info: info,
    style: style-dict,
    strings: translations(info.lang).strings,
    abstract: abstract,
    appendix: appendix,
    body: body,
  )

  // General style (Font, etc. for everything)
  (style-dict.setup)(ctx, {
    // Add the cover without any style setup
    (style-dict.cover)(ctx)

    [#metadata(none) <roman-matter-start>]

    (style-dict.style-content)(ctx, {
      // Render chapters in the order defined by the style
      for chapter in style-dict.chapters {
        chapter(ctx)
      }
    })
  })
}
