#import "deps.typ": *
#import "common.typ": *
#import "referable.typ": *

#let prefixed-counter(prefix, chapter-format, appendix-format) = {
  if prefix == "chapter" {
    counter-chapter.display(chapter-format)
  } else if prefix == "appendix" {
    counter-appendix.display(appendix-format)
  }
}

#let page-has-book-first-heading() = {
  (
    book-state.get()
      and query(heading.where(level: 1))
        .filter(h => (
          h.location().page() == here().page() and counter(heading).at(h.location()).first() == 1
        ))
        .len()
        > 0
  )
}

#let chapter-title(
  title,
  lang: "en",
  prefix: "chapter",
  styles: default-styles,
  chapter-break: () => pagebreak(weak: true, to: "odd"),
) = {
  let the-title = cjk-latin-style(
    title,
    size: styles.sizes.chapter * 1pt,
    styles: styles,
    lang: lang,
    role: "chapter",
    style: "italic",
    weight: "bold",
  )

  context if not book-state.get() {
    the-title
    v(2em)
  } else {
    chapter-break()
    context if not book-page-count-started.get() {
      counter(page).update(1)
      book-page-count-started.update(true)
    }
    show figure.caption: none
    let chapter-idx = context prefixed-counter(prefix, "1", "A")

    let bottom-pad = 10%
    block(height: 50%, grid(
      columns: (24fr, 1fr, 2fr),
      rows: (2fr, 12fr),
      align: (right + bottom, center, left + bottom),
      place(right + bottom, dx: -1%, pad(
        figure(
          the-title,
          kind: prefix,
          supplement: none,
          numbering: _ => none,
          caption: title,
        ),
        bottom: bottom-pad,
      )),
      line(angle: 90deg, length: 100%),
      pad(cjk-latin-style(
        chapter-idx,
        size: styles.sizes.chapter-index * 1pt,
        styles: styles,
        lang: lang,
        role: "chapter-index",
        weight: "bold",
      )),
    ))
  }
}

#let chapter-odd-pagebreak(.._ignored) = {
  context if calc.odd(here().page()) {
    pagebreak(weak: true)
    {
      set page(header: none, footer: none)
      pagebreak(weak: true, to: "odd")
    }
  } else {
    pagebreak(weak: true, to: "odd")
  }
}

#let chapter-img(img, title: "") = {
  block(place(right + bottom, dx: 1%, figure(
    img,
    placement: top,
    kind: "chapter-img",
    supplement: none,
    numbering: _ => none,
    caption: title,
  )))
}

#let heading-size-style(
  x,
  lang: "en",
  styles: default-styles,
) = {
  let apply-heading-sizes = range(1, 5).fold(
    it => it,
    (style-it, level) => it => {
      show heading.where(level: level): it => {
        set text(
          size: styles.sizes.at("heading-" + str(level)) * 1pt,
          weight: if level <= 3 { "bold" } else { "regular" },
        )
        if lang == "zh" {
          show: cjk-latin-style.with(
            styles: styles,
            lang: lang,
            role: "context",
            as-style: true,
            weight: if level <= 3 { "bold" } else { "regular" },
          )
        }
        it
      }
      style-it(it)
    },
  )
  apply-heading-sizes(x)
  v(1em, weak: true)
}

#let heading-numbering(
  ..numbers,
  prefix: "chapter",
  heading-depth: 3,
) = {
  let is-book = book-state.get()
  let the-prefix = if is-book { prefixed-counter(prefix, "1.", "A.") } else { "" }
  let level = numbers.pos().len()
  let max-depth = if is-book and heading-depth > 2 { 2 } else { heading-depth }
  if level <= max-depth {
    the-prefix + numbering("1.", ..numbers)
  } else {
    h(-0.33em)
  }
}

#let align-odd-even(odd-left, odd-right) = {
  let slots = if calc.odd(here().page()) {
    (odd-left, odd-right)
  } else {
    (odd-right, odd-left)
  }
  align(right, [#slots.at(0) #h(6fr) #slots.at(1)])
}

#let with-ref-style(
  body,
  enabled: false,
  lang: "en",
  names: default-names,
  prefix: "chapter",
) = {
  if enabled {
    show ref: ref-style.with(lang: lang, names: names).with(prefix: prefix)
    body
  } else {
    body
  }
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
  format-refs: false,
  full-style: false,
) = {
  assert(
    heading-depth in (1, 2, 3),
    message: "depth can only be either 1, 2 or 3",
  )
  assert(
    prefix in ("chapter", "appendix"),
    message: "prefix can only be either \"chapter\" or \"appendix\"",
  )

  let header = info.header
  let footer = info.footer
  let lang = info.lang

  show: common-style
  show: book-style.with(styles: styles)

  set par(
    first-line-indent: (
      amount: styles.spaces.par-indent * 1em,
      all: lang == "zh",
    ),
    justify: true,
    leading: styles.spaces.par-leading * 1em,
    spacing: styles.spaces.par-spacing * 1em,
  )

  set text(
    size: styles.sizes.context * 1pt,
    ..font-role-options(styles, lang, "context"),
    lang: lang,
  )
  show: cjk-latin-style.with(styles: styles, lang: lang, role: "context", as-style: true)

  set page(
    header: context {
      if not page-has-book-first-heading() {
        set text(size: styles.sizes.header * 1pt)
        align-odd-even(header, emph(hydra(1)))
        line(length: 100%)
      }
    },
    footer: context {
      set text(size: styles.sizes.footer * 1pt)
      let page_num = counter(page).display()
      align-odd-even(footer, page_num)
    },
  )

  show pagebreak.where(weak: true): it => {
    counter(heading).update(0)
    it
  }

  align(center, chapter-title(
    title,
    lang: lang,
    styles: styles,
    prefix: prefix,
    chapter-break: chapter-odd-pagebreak,
  ))

  set math.cases(gap: .85em)
  set math.equation(numbering: equation-numbering(prefix: prefix))
  set heading(numbering: (..numbers) => heading-numbering(
    ..numbers,
    prefix: prefix,
    heading-depth: heading-depth,
  ))

  if full-style {
    show heading: heading-size-style.with(lang: lang, styles: styles)

    if outline-on {
      outline(depth: 2)
      pagebreak()
    }

    show math.equation: equation-numbering-style.with(prefix: prefix)
    show heading.where(level: 1): it => {
      counter(math.equation).update(0)
      it
    }

    show figure: figure-supplement-style.with(lang: lang, names: names)
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

    with-ref-style(
      body,
      enabled: format-refs,
      lang: lang,
      names: names,
      prefix: prefix,
    )
  } else {
    body
  }
}

#let appendix-style = chapter-style.with(prefix: "appendix")
#let chapter = chapter-style.with(full-style: true, format-refs: true)
#let appendix = appendix-style.with(full-style: true, format-refs: true)
