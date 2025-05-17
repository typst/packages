#import "deps.typ": *
#import "common.typ": *
#import "front-matters.typ": part-page
#import "chapters.typ": chapter-title

#let appendix-style(
  body,
  title: "",
  part: false,
  info: default-info,
  styles: default-styles,
  names: default-names,
) = {
  let lang = info.lang
  show: book-style.with(styles: styles)

  if part == true {
    part-page(lang: lang, names.sections.at(lang).appendix)
  }

  set text(
    font: styles.fonts.at(lang).context,
    size: 10.5pt,
    lang: lang,
  )

  align(center, chapter-title(title, book: true, lang: lang, appendix: true))

  show heading: heading-style
  set heading(
    numbering: (..numbers) => {
      let title-index = if book-state.get() { context counter(label-appendix).display("A.") } else {
        none
      }
      let level = numbers.pos().len()
      if (level == 1) {
        title-index + numbering("1", numbers.at(0))
      } else if (level == 2) {
        title-index + numbering("1.", numbers.at(0)) + numbering("1", numbers.at(1))
      } else {
        h(-0.3em)
      }
    },
  )

  set-theorion-numbering("A.1")
  body
}
