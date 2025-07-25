#import "@preview/touying:0.6.1": *

#let upb-colors = (
  schwarz: rgb("#000000"),
  weiß: rgb("#FFFFFF"),
  ultrablau: rgb("#0025AA"),
  limettengrün: rgb("#ACEA3D"),
  granatpink: rgb("#EF3A84"),
  himmelblau-100: rgb("#0A75C4"),
  himmelblau-80: rgb("#3B91D0"),
  himmelblau-60: rgb("#6CACDC"),
  himmelblau-40: rgb("#9DC8E7"),
  himmelblau-20: rgb("#CEE3F3"),
  saphirblau-100: rgb("#181c62"),
  saphirblau-80: rgb("#464981"),
  saphirblau-60: rgb("#7477A1"),
  saphirblau-40: rgb("#A3A4C0"),
  saphirblau-20: rgb("#D1D2E0"),
  irisviolett-100: rgb("#7E3FA8"),
  irisviolett-80: rgb("#9865B9"),
  irisviolett-60: rgb("#B18CCB"),
  irisviolett-40: rgb("#CBB2DC"),
  irisviolett-20: rgb("#E5D8EE"),
  fuchsiarot-100: rgb("#C138A0"),
  fuchsiarot-80: rgb("#CD60B3"),
  fuchsiarot-60: rgb("#DA88C6"),
  fuchsiarot-40: rgb("#E6AFD9"),
  fuchsiarot-20: rgb("#F3D7EC"),
  meerblau-100: rgb("#23A9C9"),
  meerblau-80: rgb("#4FBAD4"),
  meerblau-60: rgb("#7BCBDF"),
  meerblau-40: rgb("#A7DCE9"),
  meerblau-20: rgb("#D3EEF4"),
  arktisblau-100: rgb("#50D1D1"),
  arktisblau-80: rgb("#73DADA"),
  arktisblau-60: rgb("#96E3E3"),
  arktisblau-40: rgb("#B9EDED"),
  arktisblau-20: rgb("#DCF6F6"),
)

#let slide(title: auto, ..args, content) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  let footer(self) = {
    set align(horizon)
    set text(fill: self.colors.schwarz, size: .8em)
    v(10pt)
    h(3em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    strong(context utils.slide-counter.display())
    h(3em)
  }
  self = utils.merge-dicts(
    self,
    config-page(
      background: {
        place(left+top, image("backgrounds/content.svg", height: 100%))
      },
      footer: footer,
    )
  )
  let body = {
    block(
      text(size: 20pt, weight: "bold", utils.display-current-heading(level: 2), fill: self.colors.ultrablau),
      width: 80%,
    )

    show heading: it => {
      block(
        text(size: 18pt, weight: "bold", it.body, fill: self.colors.ultrablau),
        width: 80%,
      )
      v(6pt)
    }

    content
    v(1fr)
  }
  touying-slide(self: self, ..args, body)
})

#let title-slide(background-img: image("backgrounds/title.svg", height: 100%), ..args, content) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(
    background: {
      place(left+top, background-img)
    },
    margin: (top: 168pt, bottom: 40pt, left: 85pt, right: 180pt)
  ))
  let info = self.info + args.named()
  let body = {
    set align(bottom)
    block(
      text(size: 30pt, weight: "bold", info.title, fill: self.colors.ultrablau),
      height: 57pt
    )
    v(13pt)
    set text(fill: self.colors.schwarz)
    block(content)
    v(1fr)
    block(info.author + [ \ ] + info.date.display("[ day ].[ month ].[ year ]"))
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, section) = touying-slide-wrapper(self => {
  counter(heading).step()
  let header(self) = {
    set align(center)
    set text(fill: self.colors.weiß, size: 34pt)
    h(680pt)
    context counter(heading).display()
  }
  self = utils.merge-dicts(
    self,
    config-page(
      background: {
        place(left+top, image("backgrounds/section.svg", height: 100%))
      },
      header: header,
      margin: (top: 4em, bottom: 3.5em, x: 2em)
    )
  )
  set align(center + horizon)
  let body = {
    block(
      text(size: 26pt, weight: "bold", utils.display-current-heading(level: 1), fill: self.colors.ultrablau),
      width: 65%,
    )
  }
  touying-slide(self: self, body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 2em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  touying-slide(self: self, align(horizon + center, body))
})

#let upb-theme(
  footer: none,
  lang: "de",
  ..args,
  body,
) = {
  set text(size: 16pt, font: "karla", lang: lang)
  set par(spacing: 1.8em, leading: 0.75em)
  set list(spacing: .7em)

  show: touying-slides.with(
    config-page(
      paper: "presentation-16-9",
      margin: (top: 95pt, bottom: 5em, left: 30pt, right: 20pt),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-colors(..upb-colors),
    config-store(
      title: none,
      footer: footer,
    ),
    ..args,
  )

  body
}

