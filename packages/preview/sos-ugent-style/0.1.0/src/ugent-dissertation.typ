#import "ugent-doc.typ": ugent-doc-template
#import "styling/elements.typ": (
  ugent-caption,
  ugent-heading-rules,
  ugent-heading-numbering,
  ugent-bibliography-theme,
  ugent-heading-title-text,
)
#import "styling/cover.typ": (
  ugent-cover-layout-page,
  ugent-dissertation-box,
)
#import "i18n.typ"
#import "utils/smart-referencing.typ": (
  math-ref-to-eq-number,
  heading-ref,
  default-contextual-ref-supplement-handlers,
  unnumbered-subheading-ref,
)
#import "utils/util.typ": dissertation-info-to-full-sentences
#import "/utils/util.typ": flex-caption

/* - ugent-dissertation (entry point              - show-rule)
 * - ugent-section      (enter preface/body/annex - show-rule)
 */

// Entry point of the ugent theme
#let ugent-dissertation-template(
  // DUAL USE
  title: "Your dissertation title",
  author: "Your Name",
  faculty: "ea", // just to show something
  secondary-faculty: none,
  // FRONT-PAGE INFO
  subtitle: none,
  wordcount: 0,
  student-number: none,
  supervisors: (),
  commissaris: none,
  submitted-for: none,
  academic-year: none,
  front-page: ugent-cover-layout-page,
  // DISSERTATION OPTIONS
  /// Capitalize heading references? From 'see chapter 3 and annex A' to 'see Chapter 3 and Annex A'
  /// Remark you can always use `:cap` and `:nocap` modifiers.
  default-capitalize-heading-refs: false,
  reference-unnumbered-subheadings: false,
  language: "nl",
  ..kwargs,
  body,
) = {
  let dissertation-info = (
    title: title,
    subtitle: subtitle,
    wordcount: wordcount,
    student-number: student-number,
    author: author,
    supervisors: supervisors,
    commissaris: commissaris,
    submitted-for: submitted-for,
    academic-year: academic-year,
  )
  let info-full = dissertation-info-to-full-sentences(..dissertation-info)
  [#metadata(dissertation-info) <ugent-dissertation-info>]
  [#metadata(info-full)         <ugent-dissertation-info-full>]
  show: ugent-doc-template.with(
    title: info-full.title,
    authors: info-full.author,
    faculty: faculty,
    language: language,
    front-page: if front-page != none {
      front-page(
        faculty: faculty,
        secondary-faculty: secondary-faculty,
        background-color: none,
        logos-left-margin: 2,
        ugent-dissertation-box.with(
          info: info-full,
        )
      )
    },
    ..kwargs
  )
  show: ugent-bibliography-theme
  show ref: unnumbered-subheading-ref.with(
    behaviour: if reference-unnumbered-subheadings { "ref-superheading" }
               else { "panic" })
  show ref: heading-ref.with(
    contextual-supplement-handlers: default-contextual-ref-supplement-handlers(capitalize: default-capitalize-heading-refs),
  )  // Nice formatting for heading references
  body
}

// These are the set/show-rules of the UGent preface
#let ugent-preface-rules(body) = {
  // Pages in the preface are numbered using roman numerals.
  set page(numbering: "I")

  // Titles in the preface are not numbered and are only outlined for level 1.
  set heading(numbering: none, outlined: false)
  show heading.where(level: 1): set heading(outlined: true)

  // Show titled without numbering
  show: ugent-heading-rules

  body
}

// Sets up the styling of the main body of your thesis.
#let ugent-body-rules(body) = {
  // Set the pages to show as "# of #" and reset page counter.
  // "# of #" is localized, see i18n
  // Glossy and outlines interacts with this! They only give 1 number (first case).
  set page(numbering: (pg, ..total) =>
    if total.pos().len() == 0 [#pg] // No spaces! Keep layout thight.
    else { i18n.page-numbering-function.at(text.lang)(pg, total.at(0)) }
  )
  context if state("section").get() == "body-activate" {
    counter(page).update(1)
  }

  // Titles in the body are numbered and outlined.
  set heading(numbering: ugent-heading-numbering.with("1.1.1"), outlined: true, supplement: `body-heading`)

  // Show titled with numbering
  show: ugent-heading-rules.with(big-chap-num: true)

  // Number equations and references to equations.
  set math.equation(numbering: "(1)")
  // Create the automatic references WITH parentheses, like "Vergelijking (15)"
  show ref: math-ref-to-eq-number

  // Set caption styling.
  show figure.caption: ugent-caption.with(align: "center")

  // Make figure breakable.
  show figure: set block(breakable: true)

  // Set figure styling: aligned at the center.
  show figure: align.with(center)

  body
}

// Set up the styling of the appendix.
#let ugent-appendix-rules(body) = {
  // Reset the title numbering.
  context if state("section").get() == "annex-activate" {
    counter(heading).update(0)
  }

  // Number headings using letters.
  set heading(numbering: ugent-heading-numbering.with("A.1", cut-off: 2), outlined: true, supplement: `annex-heading`)

  // Show titled with numbering.
  show heading: ugent-heading-rules.with(prefix: i18n.ref-Annex + [ ], postfix: ": ", underline-all: true)

  // Set the numbering of the figures.
  set figure(numbering: (x) => locate(loc => {
    let idx = numbering("A", counter(heading).at(loc).first())
    [#idx.#numbering("1", x)]
  }))

  // Additional heading styling to update sub-counters.
  show heading.where(level: 1): it => {
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)

    it
  }

  [#metadata("") <ugent-section-appendix>]
  body
}

/// Usage: `#show: ugent-section.with("body")` before entering the specified section
/// Idempotent if already in the specified section. For projects using
/// the 'subfile' structure.
// *REMARK FOR DEVELOPERS*: this is done by taking care that these rules are
// themselves idempotent. show-set rules should normally be idempotent, but e.g.
// counter updates are guarded by context expressions!
#let ugent-section(section, body) = {
  let idempotent-trapdoor(next) = {
    // return the update function
    (current) => {
      let next-act = next + "-activate"
      if current == next-act or current == next {
        next
      } else {
        next-act // Active phase, only entered once, even with multiple ugent-section calls
      }
    }
  }
  let section-rules = (
    // These should be idempotent!!
    // Use `state("section").get() == "...-activate"` as guard when needed.
    preface: ugent-preface-rules,
    body: ugent-body-rules,
    annex: ugent-appendix-rules,
  )
  state("section").update(idempotent-trapdoor(section))
  show: section-rules.at(section, default: (_) => panic(
    "Section " + section + " not recognized! " +
    "Should be 1 of: " + repr(section-rules.keys())
  ))
  state("section").update(idempotent-trapdoor(section))
  body
}

#let ugent-dissertation-info()      = query(<ugent-dissertation-info>).first().value
#let ugent-dissertation-info-full() = query(<ugent-dissertation-info-full>).first().value
#let ugent-abstract-info = context [
  #let info = ugent-dissertation-info-full()
  #show heading: set par(leading: 0.45em)
  #show heading.where(level: 1): set text(size: 18pt) // TODO: ugent-panno: 23pt
  #show heading.where(level: 2): set text(size: 15pt, weight: "regular") // TODO: ugent-panno: 18pt
  // Destructive
  #show heading.where(level: 1): h => {
    pagebreak(weak: true)
    block(
      ugent-heading-title-text(underlined: false, h),
      below: 20pt,
    )
  }
  #show heading.where(level: 2): h => block(
    ugent-heading-title-text(underlined: false, h),
  )
  = #flex-caption(long: info.title, short: i18n.Abstract)
  == #info.subtitle
  //#info.wordcount
  #text(info.author, size: text.size+2pt) \
  #info.student-number

  #info.supervisors \
  #info.commissaris

  #info.submitted-for \
  #info.academic-year \
  #i18n.ugent \
  \
]
