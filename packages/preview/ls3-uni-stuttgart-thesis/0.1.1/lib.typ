// ls3-uni-stuttgart-thesis
//
// Bachelor's and Master's thesis template for LS3 at IWS, University of
// Stuttgart. Bilingual German / English. Two-sided printing. Parametric
// branding with defaults from src/common.typ.
//
// Usage. See template/main.typ.
//
// Parameters of thesis().
//   title                content, main title
//   cover-title          content, title on the cover, may use \ for line breaks (defaults to title)
//   author               string
//   matriculation-number string
//   degree               "bachelor" or "master"
//   language             "english" or "german"
//   date                 string
//   examiners            tuple of strings
//   supervisors          tuple of strings
//   institute            auto (resolves from language), or string
//   chair                auto (resolves from language), or string
//   abstract-en          content, English abstract
//   abstract-de          content, German abstract
//   abbreviations        none, or content for the optional abbreviations chapter
//   notation             none, or content for the optional notation chapter
//   bib                  none, or a pre-constructed bibliography(...) element
//   ai-tools             none, or a dict with (statements: (...), activities: (...))
//   body-font            "sans" (default, Helvetica) or "serif" (LaTeX-style
//                        Latin Modern body with sans headings)
//   sans-font            auto (TeX Gyre Heros), or a font family or stack
//                        used wherever the template sets sans text
//   university-logo      auto (bundled logo), none, or image(...) of the
//                        official University of Stuttgart logo PDF, cover
//                        top left. Cropped automatically, the institute
//                        and chair lines are set below it.
//   chair-logo           auto (bundled LS3 logo), none, or content, cover disc
//   heading-rule         false (default), or true for a thin mittelblau rule
//                        below every chapter-level heading

#import "src/common.typ": branding as default-branding

#import "src/style.typ": apply-style, two-sided-header-footer
#import "src/cover.typ": cover-page
#import "src/title-page.typ": title-page
#import "src/declaration.typ": declaration
#import "src/abstract.typ": abstract-en as _abstract-en, abstract-de as _abstract-de
#import "src/front-matter.typ": (
  abbreviations-section, notation-section, toc, lof, lot, lol,
)

// Localized strings for institutional defaults.
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

// Public thesis() show rule.
#let thesis(
  title: [],
  cover-title: auto,
  author: "",
  matriculation-number: "",
  degree: "master",
  language: "english",
  date: "",
  examiners: (),
  supervisors: (),
  institute: auto,
  chair: auto,
  abstract-en: none,
  abstract-de: none,
  abbreviations: none,
  notation: none,
  bib: none,
  ai-tools: none,
  body-font: "sans",
  sans-font: auto,
  university-logo: auto,
  chair-logo: auto,
  heading-rule: false,
  body,
) = {
  // Validate language and degree early.
  assert(language == "english" or language == "german", message: "language must be 'english' or 'german'")
  assert(degree == "bachelor" or degree == "master", message: "degree must be 'bachelor' or 'master'")
  assert(body-font == "sans" or body-font == "serif", message: "body-font must be 'sans' or 'serif'")
  assert(type(heading-rule) == bool, message: "heading-rule must be true or false")

  let resolved-sans = if sans-font == auto { default-branding.fonts.sans } else { sans-font }
  let resolved-cover-title = if cover-title == auto { title } else { cover-title }
  let resolved-institute = if institute == auto { _institute-name(language) } else { institute }
  let resolved-chair = if chair == auto { _chair-name(language) } else { chair }

  set document(title: if type(title) == str { title } else { "" }, author: author)
  set text(lang: if language == "german" { "de" } else { "en" })

  // Page 1. Cover.
  cover-page(
    author: author,
    cover-title: resolved-cover-title,
    language: language,
    university-logo: university-logo,
    institute: resolved-institute,
    chair: resolved-chair,
    chair-logo: chair-logo,
    sans-font: resolved-sans,
  )

  // Page 2. Title page.
  title-page(
    title: title,
    author: author,
    matriculation-number: matriculation-number,
    degree: degree,
    language: language,
    examiners: examiners,
    supervisors: supervisors,
    institute: resolved-institute,
    chair: resolved-chair,
    date: date,
    sans-font: resolved-sans,
  )

  // Apply body styles from here on.
  show: apply-style.with(
    body-font: body-font,
    sans-font: resolved-sans,
    heading-rule: heading-rule,
  )

  // Declaration. Unnumbered. Scoped page settings disable header, footer,
  // and numbering for declaration pages only; subsequent pages revert to the
  // apply-style settings.
  [
    #set page(header: none, footer: none, numbering: none)
    #declaration(language: language, ai-tools: ai-tools)
  ]

  // Front matter (abstracts, abbreviations, notation, TOC) with roman
  // numbering starting at "i" on the first numbered page (the abstract).
  // The pagebreak forces the next content onto an odd absolute page, then
  // the counter is reset so the visible number on that page is "i".
  pagebreak(to: "odd")
  [
    #set page(numbering: "i")
    #counter(page).update(1)
    #if language == "english" {
      if abstract-en != none { _abstract-en(abstract-en) }
      if abstract-de != none { _abstract-de(abstract-de) }
    } else {
      if abstract-de != none { _abstract-de(abstract-de) }
      if abstract-en != none { _abstract-en(abstract-en) }
    }
    #if abbreviations != none {
      abbreviations-section(abbreviations, language: language)
    }
    #if notation != none {
      notation-section(notation, language: language)
    }
    #toc(language: language)
  ]

  // Main matter (numbered chapters + back matter + bibliography). Arabic
  // numbering starting at "1" on the first chapter.
  pagebreak(to: "odd")
  [
    #set page(numbering: "1")
    #counter(page).update(1)
    #body
    #lof(language: language)
    #lot(language: language)
    #lol(language: language)
    #if bib != none {
      bib
    }
  ]
}
