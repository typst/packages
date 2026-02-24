#import "dependencies.typ": *
#import "common.typ": *
#import "blocks.typ": *
#import "front-matters.typ": part-page
#import "chapters.typ": align-odd-even, chapter-title, heading-size-style

#let appendix-style(
  body,
  title: "",
  info: default-info,
  styles: default-styles,
  names: default-names,
) = {
  let lang = info.lang
  show: book-style.with(styles: styles)

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

  show math.equation: equation-numbering-style.with(prefix: "appendix")
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show ref: ref-supplement-style.with(lang: lang)
  show ref: ref-numbering-style.with(lang: lang, names: names, prefix: "appendix")
  show figure: figure-supplement-style
  show figure.where(kind: table): set figure.caption(position: top)
  show raw.where(block: true): code-block-style

  set-theorion-numbering("A.1")
  body
}
