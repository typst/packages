// ls3-uni-stuttgart-milestone
//
// PhD milestone (halftime) report template of LS3 at IWS, University of
// Stuttgart. Bilingual German / English. Two-sided printing.
//
// Usage. See template/main.typ.
//
// Parameters of milestone().
//   title              content, the research title
//   cover-title        content or auto, override that allows \ line breaks
//   author             string, PhD candidate name
//   language           "english" or "german"
//   presentation-date  string or none, date the milestone is presented
//   supervisor         string
//   co-supervisor      string or none
//   examiners          tuple of strings
//   institute          auto (IWS) or string, top-left next to the logo
//                      and at the foot of the title page
//   chair              auto (LS3) or string, below the institute
//   university-logo    auto (bundled logo), none, or image(...) of the
//                      official University of Stuttgart logo PDF
//   additional-logo    content or none, placed centered on the title page
//   report-type        string or auto, "Milestone Report" by default
//   abstract           none or content, optional abstract chapter
//   abbreviations      none, content, or auto. auto renders a sorted,
//                      single-column list from the abbr package state.
//                      Pass content to supply your own, or call the exported
//                      abbreviations-list(columns: 2) for the two-column form.
//   notation           none or content, optional notation chapter
//   bib                none or a pre-constructed bibliography(...) element
//   body-font          "sans" (default) or "serif"
//   heading-rule       false (default), or true for a thin mittelblau rule
//                      below every chapter-level heading

#import "src/style.typ": apply-style
#import "src/title-page.typ": title-page
#import "src/front-matter.typ": abstract-section, abbreviations-section, abbreviations-list, notation-section, toc

#let _institute-name(language) = {
  if language == "german" {
    "Institut für Wasser- und Umweltsystemmodellierung"
  } else {
    "Institute for Modelling Hydraulic and Environmental Systems"
  }
}

#let _chair-name(language) = {
  if language == "german" {
    "Lehrstuhl für Stochastische Simulation und Sicherheitsforschung für Hydrosysteme"
  } else {
    "Department of Stochastic Simulation and Safety Research for Hydrosystems"
  }
}

#let milestone(
  title: [],
  cover-title: auto,
  author: "",
  language: "english",
  presentation-date: none,
  supervisor: "",
  co-supervisor: none,
  examiners: (),
  institute: auto,
  chair: auto,
  university-logo: auto,
  additional-logo: none,
  report-type: auto,
  abstract: none,
  abbreviations: none,
  notation: none,
  bib: none,
  body-font: "sans",
  heading-rule: false,
  body,
) = {
  assert(language == "english" or language == "german", message: "language must be 'english' or 'german'")
  assert(body-font == "sans" or body-font == "serif", message: "body-font must be 'sans' or 'serif'")
  assert(type(heading-rule) == bool, message: "heading-rule must be true or false")

  let resolved-cover-title = if cover-title == auto { title } else { cover-title }
  let resolved-institute = if institute == auto { _institute-name(language) } else { institute }
  let resolved-chair = if chair == auto { _chair-name(language) } else { chair }

  set document(title: if type(title) == str { title } else { "" }, author: author)
  set text(lang: if language == "german" { "de" } else { "en" })

  // Title page. Page 1. No page number.
  title-page(
    title: resolved-cover-title,
    author: author,
    language: language,
    report-type: report-type,
    supervisor: supervisor,
    co-supervisor: co-supervisor,
    examiners: examiners,
    institute: resolved-institute,
    chair: resolved-chair,
    presentation-date: presentation-date,
    university-logo: university-logo,
    additional-logo: additional-logo,
  )

  // Apply body styling from here on.
  show: apply-style.with(body-font: body-font, heading-rule: heading-rule)

  // Front matter. Roman page numbering, restarting at "i" on the first
  // numbered page (abbreviations, notation, or TOC, whichever comes first).
  pagebreak(to: "odd")
  [
    #set page(numbering: "i")
    #counter(page).update(1)
    #if abstract != none {
      abstract-section(abstract, language: language)
    }
    #if abbreviations != none {
      abbreviations-section(abbreviations, language: language)
    }
    #if notation != none {
      notation-section(notation, language: language)
    }
    #toc(language: language)
  ]

  // Main matter. Arabic page numbering, restarting at "1" on the first
  // chapter.
  pagebreak(to: "odd")
  [
    #set page(numbering: "1")
    #counter(page).update(1)
    #body
    #if bib != none {
      bib
    }
  ]
}
