#import "slydekit-animation.typ": *
#import "slydekit-deps.typ": *
#import "slydekit-defaults.typ": *
#import "slydekit-outline.typ": *
#import "slydekit-themes.typ": *
#import "slydekit-slide.typ": slide, slide-parser
#import "slydekit-utils.typ": *

#let slydekit(
  title: none,
  subtitle: none,
  short-title: none,
  author: none,
  date: none,
  institution: none,
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
  frozen-counters: (),
  slide-level: 2,
  slide-align: horizon,
  extra-info: (:),
  handout: false,
  body
) = context {
  // Page setup
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: default-margins,
  )

  // Slide level: headings at this depth become slides, headings above it (depth < slide-level) are structure headings, and the heading at depth slide-level - 1 acts as the section.
  sk-states.slide-level.update(slide-level)

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

  // Frozen counters
  sk-states.frozen-counters.update(default-frozen-counters + frozen-counters)

  // Rules common to all themes
  show heading: it => context {
    sk-states.numbering-hidden.update(it.has("label") and it.label == <hide-toc>)

    it
  }
  // Level 2 headings are slides, defined with == Title
  // show heading.where(level: 2): it => slide(it.body)[]

  // Paragraph styles
  set par(justify: true)

  // Page alignment
  set align(slide-align)

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
  show ref: show-ref.with(slide-level: slide-level)

  // Bibliography style
  set bibliography(title: none)
  show bibliography: set text(size: 0.85em)

  // Title page
  let sk-pres-info = (title: title, subtitle: subtitle, short-title: short-title, author: author, date: date, institution: institution, contact: contact, logo: title-logo, extra: extra-info)

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
  show selector(<hide-toc>): set heading(numbering: none, outlined: false)

  // Fonts
  show: set-text.with(lang: sk-lang, fonts: sk-fonts)

  // slide-parser (defined in slydekit-utils.typ) groups each == heading with all content that follows it until the next heading, allowing #pause / #meanwhile to work without an explicit #slide[...].
  slide-parser(slide-level: slide-level, body)

  // body
}
