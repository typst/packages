#import "@preview/touying:0.6.1": *

// Color definition from: https://xcb.buaa.edu.cn/info/1091/2057.htm
#let buaa-blue = rgb(0, 61, 166)
#let sky-blue = rgb(0, 155, 222)
#let chinese-red = rgb(195, 13, 35)
#let quality-grey = rgb(135, 135, 135)
#let pro-gold = rgb(210, 160, 95)
#let pro-silver = rgb(209, 211, 211)

#let color-block(self: none, title: none, custom-color: none, it) = {
  let (head-color, body-color) = {
    if custom-color != none {
      let head = gradient.linear(custom-color, custom-color.lighten(80%))
      let body = custom-color.lighten(90%)
      (head, body)
    } else {
      let head = self.colors.primary-grad
      let body = self.colors.primary.lighten(90%)
      (head, body)
    }
  }
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: head-color,
      width: 100%,
      height: 1.5em,
      radius: (top: 10pt),
      inset: (left: 1em),
      align(
        horizon,
        text(fill: white, weight: "bold", title),
      ),
    ),
    block(
      fill: body-color,
      width: 100%,
      radius: (bottom: 10pt),
      inset: 1em,
      it,
    ),
  )
}

#let tblock(title: none, body) = touying-fn-wrapper(
  color-block.with(
    title: title,
    custom-color: none,
    body,
  ),
)

#let rblock(title: none, body) = color-block(
  self: none,
  title: title,
  custom-color: chinese-red,
  body,
)

#let gblock(title: none, body) = color-block(
  self: none,
  title: title,
  custom-color: pro-gold,
  body,
)

#let sblock(title: none, body) = color-block(
  self: none,
  title: title,
  custom-color: pro-silver.darken(20%),
  body,
)


#let _lblock(self: none, body) = block(
  stroke: (paint: self.colors.primary, thickness: 1pt),
  inset: (x: 0.5em, y: 1em),
  align(
    center + top,
    body,
  ),
)

#let lblock(body) = touying-fn-wrapper(
  _lblock.with(body),
)

#let _article-title(
  self: none,
  article-fig: none,
  core-research: none,
  authors: none,
  institution: none,
  journal: none,
  quartile: none,
  impf: none,
  pub-date: none,
) = {
  grid(
    rows: (1fr, auto),
    row-gutter: 0.5em,
    grid(
      columns: (auto, 1fr),
      align(
        center + horizon,
        block(
          inset: 1pt,
          article-fig,
        ),
      ),
      grid(
        rows: (1fr, 1fr, 1fr),
        columns: 1fr,
        column-gutter: 0.5em,
        inset: 0.5em,
        {
          text(fill: self.colors.primary, weight: "bold", [研究内容])
          linebreak()
          h(1em)
          core-research
        },
        {
          text(fill: self.colors.primary, weight: "bold", [作者])
          linebreak()
          h(1em)
          authors
        },
        {
          text(fill: self.colors.primary, weight: "bold", [机构])
          linebreak()
          h(1em)
          institution
        },
      ),
    ),
    block(
      stroke: (paint: self.colors.primary, thickness: 1pt),
      width: 100%,
      grid(
        inset: (x: 1em, y: 0.5em),
        columns: (auto, auto, 1fr, auto),
        column-gutter: 1em,
        text(fill: self.colors.primary, [期刊: ]) + linebreak() + journal,
        text(fill: self.colors.primary, [分区: ]) + linebreak() + quartile,
        text(fill: self.colors.primary, [影响因子: ]) + linebreak() + impf,
        text(fill: self.colors.primary, [发表时间: ]) + linebreak() + pub-date,
      ),
    ),
  )
}

#let article-title(
  article-fig: none,
  core-research: none,
  authors: none,
  institution: none,
  journal: none,
  quartile: none,
  impf: none,
  pub-date: none,
) = touying-fn-wrapper(_article-title.with(
  article-fig: article-fig,
  core-research: core-research,
  authors: authors,
  institution: institution,
  journal: journal,
  quartile: quartile,
  impf: impf,
  pub-date: pub-date,
))

#let _horz-block(self: none, ..items) = {
  let content-list = items.pos()
  grid(
    columns: (1fr,) * content-list.len(),
    align: center + horizon,
    column-gutter: 0.5em,
    inset: (x: 0.5em, y: 1em),
    stroke: (paint: self.colors.primary-light, thickness: 1pt),
    ..content-list
  )
}

#let horz-block(..items) = touying-fn-wrapper(
  _horz-block.with(..items),
)
