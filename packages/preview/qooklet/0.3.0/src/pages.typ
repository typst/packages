#import "styles.typ": *
#import "utils.typ": chap-title, info-default, book-title

#let cover(
  title: "The Title",
  author: "The Author",
  date: datetime.today(),
  lang: "en",
) = {
  show: cover-style
  align(
    center + horizon,
    [
      #text(
        size: 36pt,
        weight: "bold",
        font: config-fonts.family.at(lang).title,
        title,
      )
      #v(1em)
      #text(24pt, font: config-fonts.family.at(lang).author, author)
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

#let preface(body, author: "", lang: "en") = {
  show: common-style
  show: front-matter-style
  heading(
    level: 1,
    text(
      config-sections.section.at(lang).preface,
      font: config-fonts.family.at(lang).preface,
    ),
  )
  body
  align(right)[#emph(author)]
  pagebreak()
}

#let label-part = <part>
#let contents = {
  show: contents-style
  outline(target: selector(heading).or(label-part).or(chap-title), depth: 3)
}

#let part-page(title) = {
  show: front-matter-style
  show figure.caption: none
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
