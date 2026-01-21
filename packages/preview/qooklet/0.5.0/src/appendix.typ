#import "dependencies.typ": *
#import "common.typ": *
#import "front-matters.typ": part-page
#import "chapters.typ": align-odd-even, chapter-title, heading-size-style

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

  show heading: heading-size-style
  set heading(
    numbering: (..numbers) => {
      let append-index = context counter-appendix.display("A.")
      let level = numbers.pos().len()
      if (level == 1) {
        append-index + numbering("1", numbers.at(0))
      } else if (level == 2) {
        append-index + numbering("1.", numbers.at(0)) + numbering("1", numbers.at(1))
      } else {
        h(-0.3em)
      }
    },
  )

  set page(
    header: context {
      set text(size: 8pt)
      align-odd-even("", title, hide: true)
      line(length: 100%)
    },
    footer: context {
      set text(size: 8pt)
      let page_num = here().page()
      align-odd-even(info.title, page_num)
    },
  )

  set-theorion-numbering("A.1")
  body
}
