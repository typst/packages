#import "styles.typ": *
#import "utils.typ": label-chapter, default-info, default-layout

#let cover(
  info,
  date: datetime.today(),
  layout: default-layout,
) = {
  show: cover-style

  let title = info.book
  let lang = info.lang
  let author = info.author

  align(
    center + horizon,
    [
      #text(
        size: 36pt,
        weight: "bold",
        font: layout.fonts.at(lang).title,
        title,
      )
      #v(1em)
      #text(24pt, font: layout.fonts.at(lang).author, author)
      #v(1em)
      #text(18pt, date.display())
    ],
  )
}

#let epigraph(
  body,
) = {
  show: cover-style
  align(
    center + horizon,
    text(16pt, body),
  )
}

#let preface(body, info: default-info, layout: default-layout, names: default-names) = {
  show: common-style
  show: front-matter-style

  let lang = info.lang
  let author = info.author

  heading(
    level: 1,
    text(
      names.sections.at(lang).preface,
      font: layout.fonts.at(lang).preface,
    ),
  )
  body
  align(right)[#emph(author)]
  pagebreak(to: "odd")
}

#let label-part = <part>
#let part-page(title) = {
  show: front-matter-style
  show figure.caption: none

  set page(header: none, footer: none)

  align(
    center + horizon,
    [
      #figure(
        text(36pt, strong(title)),
        kind: "part",
        supplement: none,
        numbering: _ => none,
        caption: title,
      ) #label-part
    ],
  )
}

#let contents(lang: "en", depth: 2) = {
  show: contents-style.with(lang: lang)
  outline(target: selector(heading).or(label-part).or(label-chapter), depth: depth)
  pagebreak(to: "odd")
}
