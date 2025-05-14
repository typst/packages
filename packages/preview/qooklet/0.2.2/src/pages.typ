#import "styles.typ": *
#import "utils.typ": label-title, info-default

#let cover(
  title: "The Title",
  author: "The Author",
  date: datetime.today(),
) = {
  show: cover-style
  align(
    center + horizon,
    {
      text(24pt, weight: "bold", title)
      v(1em)
      text(20pt, "by " + author)
      v(1em)
      text(16pt, date.display())
    },
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
  outline(target: selector(heading).or(label-part).or(label-title), depth: 3)
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
