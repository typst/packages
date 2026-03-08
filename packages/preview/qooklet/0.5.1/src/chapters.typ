#import "dependencies.typ": *
#import "common.typ": *
#import "referable.typ": *

#let align-odd-even(odd-left, odd-right, hide: false) = {
  let chapter-page = query(selector(fig-chapter).or(fig-appendix))
    .filter(h => h.location().page() == here().page())
    .len()

  if chapter-page != 1 or hide == false {
    if calc.odd(here().page()) {
      align(right, [#odd-left #h(6fr) #odd-right])
    } else {
      align(right, [#odd-right #h(6fr) #odd-left])
    }
  }
}

#let chapter-title(
  title,
  book: false,
  lang: "en",
  appendix: false,
  styles: default-styles,
) = {
  let the-title = text(
    24pt,
    title,
    font: styles.fonts.at(lang).title,
    style: "italic",
    weight: "bold",
  )

  let the-counter = if appendix == true { counter-appendix } else { counter-chapter }
  let the-kind = if appendix == true { "appendix" } else { "chapter" }
  let heading-prefix = if appendix == true { "A" } else { "1" }

  if book != true {
    the-title
    v(2em)
  } else {
    pagebreak(weak: true, to: "odd")
    show figure.caption: none
    let chapter-index = context the-counter.display(heading-prefix)

    let bottom-pad = 10%
    block(
      height: 50%,
      grid(
        columns: (10fr, 1fr, 2fr),
        rows: (2fr, 12fr),
        align: (right + bottom, center, left + bottom),
        place(
          right + bottom,
          dx: -1%,
          pad(
            figure(
              the-title,
              kind: the-kind,
              supplement: none,
              numbering: _ => none,
              caption: title,
            ),
            bottom: bottom-pad,
          ),
        ),
        line(angle: 90deg, length: 100%),
        pad(text(50pt, chapter-index, font: styles.fonts.at(lang).title, weight: "bold")),
      ),
    )
  }
}

#let chapter-img(img, title: "") = {
  block(
    place(
      right + bottom,
      dx: 1%,
      figure(
        img,
        placement: top,
        kind: "chapimg",
        supplement: none,
        numbering: _ => none,
        caption: title,
      ),
    ),
  )
}

#let heading-size-style(x) = {
  show heading.where(level: 1): set text(size: 16pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)
  show heading.where(level: 4): set text(size: 10.5pt)
  x
  v(1em, weak: true)
}

#let chapter-style(
  body,
  title: "",
  info: default-info,
  styles: default-styles,
  names: default-names,
  outline-on: false,
) = {
  show: common-style
  show: book-style.with(styles: styles)

  let header = info.header
  let footer = info.footer
  let lang = info.lang

  set par(
    first-line-indent: (
      amount: if lang == "zh" { 2em } else { 0em },
      all: if lang == "zh" { true } else { false },
    ),
    justify: true,
    leading: 1em,
    spacing: 1em,
  )

  set text(
    font: styles.fonts.at(lang).context,
    size: 10.5pt,
    lang: lang,
  )

  set page(
    header: context {
      set text(size: 8pt)
      align-odd-even(header, emph(hydra(1)), hide: true)
      line(length: 100%)
    },
    footer: context {
      set text(size: 8pt)
      let page_num = here().page()
      align-odd-even(footer, page_num)
    },
  )

  context {
    if book-state.get() {
      align(center, chapter-title(title, book: true, lang: lang))
    } else {
      align(center, chapter-title(title, lang: lang))
    }
  }

  show heading: heading-size-style
  set heading(
    numbering: (..numbers) => {
      let chapter-index = if book-state.get() { context counter-chapter.display("1.") }
      let level = numbers.pos().len()
      if (level == 1) {
        chapter-index + numbering("1.", numbers.at(0))
      } else if (level == 2) {
        chapter-index + numbering("1.", numbers.at(0)) + numbering("1", numbers.at(1))
      } else {
        h(-0.3em)
      }
    },
  )

  show pagebreak.where(weak: true): it => {
    counter(heading).update(0)
    it
  }

  if outline-on == true {
    outline(depth: 2)
    pagebreak()
  }

  context if book-state.get() {
    set-inherited-levels(0)
  } else {
    set-inherited-levels(1)
  }

  show math.equation: equation-numbering-style
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show ref: ref-style.with(lang: lang, names: names)
  show figure: figure-supplement-style
  show figure.where(kind: table): set figure.caption(position: top)
  show raw.where(block: true): code-block-style

  show: show-theorion
  body
}
