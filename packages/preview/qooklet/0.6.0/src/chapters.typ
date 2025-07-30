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
  lang: "en",
  prefix: "chapter",
  styles: default-styles,
) = {
  let the-title = text(
    24pt,
    title,
    font: styles.fonts.at(lang).title,
    style: "italic",
    weight: "bold",
  )

  context if not book-state.get() {
    the-title
    v(2em)
  } else {
    pagebreak(weak: true, to: "odd")
    show figure.caption: none
    let prefix-index = context if (prefix == "chapter") { counter-chapter.display("1") } else if (
      prefix == "appendix"
    ) { counter-appendix.display("A") }

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
              kind: prefix,
              supplement: none,
              numbering: _ => none,
              caption: title,
            ),
            bottom: bottom-pad,
          ),
        ),
        line(angle: 90deg, length: 100%),
        pad(
          text(
            50pt,
            prefix-index,
            font: styles.fonts.at(lang).title,
            weight: "bold",
          ),
        ),
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

#let heading-numbering(..numbers, prefix: "chapter", heading-depth: 3) = {
  let the-prefix = if book-state.get() {
    if (prefix == "chapter") { counter-chapter.display("1.") } else if (
      prefix == "appendix"
    ) { counter-appendix.display("A.") }
  }
  let heading-depth2 = if book-state.get() { heading-depth - 1 } else {
    heading-depth
  }
  let level = numbers.pos().len()
  if (level == 1) or (level == 2) {
    the-prefix + numbering("1.", ..numbers)
  } else if (level == 3) and (heading-depth2 == 3) {
    the-prefix + numbering("1.", ..numbers)
  } else {
    h(-0.3em)
  }
}

#let code-block-style(body) = {
  codly(
    languages: codly-languages,
    display-name: false,
    fill: rgb("#F2F3F4"),
    zebra-fill: none,
    inset: (x: .3em, y: .3em),
    radius: .5em,
  )
  show: codly-init.with()
  body
}

#let chapter-style(
  body,
  title: "",
  info: default-info,
  styles: default-styles,
  names: default-names,
  outline-on: false,
  prefix: "chapter",
  heading-depth: 3,
) = {
  assert(
    heading-depth in (1, 2, 3),
    message: "depth can only be either 1, 2 or 3",
  )

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

  set text(font: styles.fonts.at(lang).context, size: 10.5pt, lang: lang)

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

  align(center, chapter-title(title, lang: lang, prefix: prefix))

  show heading: heading-size-style
  set heading(
    numbering: (..numbers) => heading-numbering(
      ..numbers,
      prefix: prefix,
      heading-depth: heading-depth,
    ),
  )

  show pagebreak.where(weak: true): it => {
    counter(heading).update(0)
    it
  }

  if outline-on == true {
    outline(depth: 2)
    pagebreak()
  }

  show math.equation: equation-numbering-style.with(prefix: prefix)
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show ref: ref-style.with(lang: lang, names: names).with(prefix: prefix)
  show figure: figure-supplement-style
  show figure.where(kind: table): set figure.caption(position: top)
  show raw.where(block: true): code-block-style

  context if book-state.get() {
    set-inherited-levels(0)
  } else {
    set-inherited-levels(1)
  }

  if prefix == "appendix" {
    set-theorion-numbering("A.1")
  }
  show: show-theorion
  body
}

#let appendix-style = chapter-style.with(prefix: "appendix")
