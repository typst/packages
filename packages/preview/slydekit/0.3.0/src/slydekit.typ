#import "slydekit-animation.typ": *
#import "slydekit-deps.typ": *
#import "slydekit-defaults.typ": *
#import "slydekit-outline.typ": *
#import "slydekit-themes.typ": *
#import "slydekit-utils.typ": *

#let slydekit(
  title: "Title",
  subtitle: "Subtitle",
  short-title: "Short title",
  author: "Author",
  date: "Date",
  institution: "Institution",
  contact: none,
  theme: simple,
  fonts: (:),
  colors: (:),
  lang: "en",
  aspect-ratio: "16-9",
  navigation-style: "topbar",
  title-logo: (),
  slide-logo: none,
  section-numbering: false,
  numbering-pattern: (:),
  handout: false,
  body
) = context {
  // Page setup
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: margins,
  )

  // Section numbering
  sk-states.section-numbering.update(section-numbering)

  // Numbering
  let sk-numbering-pattern = default-numbering-pattern + numbering-pattern

  set heading(numbering: if numbering != none {
    (..nums) => {
      if sk-states.appendix.get() {
        std.numbering(sk-numbering-pattern.appendix, ..nums)
      } else {
        std.numbering(sk-numbering-pattern.section, ..nums)
      }
    }
  })
  sk-states.numbering-pattern.update(sk-numbering-pattern)

  // Localization
  let sk-lang = if default-language.contains(lang) {lang} else {"en"}

  // Theme
  let sk-theme = simple + theme
  let sk-colors =  sk-theme.colors + colors
  let sk-fonts = default-fonts + sk-theme.fonts + fonts

  sk-states.colors.update(sk-colors)
  sk-states.fonts.update(sk-fonts)
  show: sk-theme.theme

  // Rules common to all themes

  // Level 1 heading
  show heading.where(level: 1): it => context {
    sk-states.slide-index.update(0)
    it
  }
  // Level 2 headings are slides, defined with == Title
  show heading.where(level: 2): it => slide(it.body)[]

  // Paragraph styles
  set par(justify: true)

  // Page alignment
  set align(horizon)

  // Footnote style
  set footnote.entry(separator: none, clearance: 0.25em)
  show footnote.entry: it => context {
    set text(size: 0.75em)
    if sk-states.is-footcite.at(it.note.location()) {
      it.note.body
    } else {
      it
    }
  }

  // References
  show ref: show-ref

  // Bibliography style
  set bibliography(title: none)
  show bibliography: set text(size: 0.85em)

  // Title page
  let sk-pres-info = (title: title, subtitle: subtitle, short-title: short-title, author: author, date: date, institution: institution, contact: contact, logo: title-logo)

  // Update states
  sk-states.navigation-style.update(navigation-style)
  sk-states.pres-info.update(sk-pres-info)
  sk-states.localization.update(json("resources/i18n/" + sk-lang + ".json"))
  sk-states.theme.update(sk-theme)
  sk-states.logo.update(slide-logo)
  sk-states.handout.update(handout)

  // Hide short titles by default
  show metadata.where(label: <sk-title>): it => it.value.long

  // Hide section titles from toc
  show selector(<hide-toc>): set heading(outlined: false)

  // Fonts
  show: set-text.with(lang: sk-lang, fonts: sk-fonts)

  body
}