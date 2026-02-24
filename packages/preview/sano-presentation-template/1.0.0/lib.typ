#import "@preview/touying:0.6.1": *

#let sano-colors = (
  dark: rgb("#000000"),
  white: rgb("#FFFFFF"),
  blue: rgb("#0025AA"),
)

#let slide(title: auto, ..args, content) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (top: 70pt, left: 70pt, right: 70pt)
    )
  )
  let body = {
    block(
      text(size: 20pt, weight: "bold", utils.display-current-heading(level: 2), fill: self.colors.blue),
      width: 60%,
    )

    show heading: it => {
      block(
        text(size: 18pt, weight: "bold", it.body, fill: self.colors.blue),
        width: 65%,
      )
      v(6pt)
    }

    content
    v(1fr)
  }
  touying-slide(self: self, ..args, body)
})

#let title-slide(height: 100%, ..args, content) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(
    margin: (top: 168pt, bottom: 40pt, left: 85pt, right: 180pt)
  ))
  let info = self.info + args.named()
  let body = {
    set align(bottom)
    block(
      text(size: 30pt, weight: "bold", info.title, fill: self.colors.blue),
      height: 57pt
    )
    v(13pt)
    set text(fill: self.colors.dark)
    block(content)
    v(1fr)
    block("By " + info.author)
    v(0.5fr)
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, section) = touying-slide-wrapper(self => {
  counter(heading).step()
  let header(self) = {
    set align(center)
    set text(fill: self.colors.white, size: 34pt)
    h(680pt)
    context counter(heading).display()
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      margin: (top: 4em, bottom: 3.5em, x: 2em)
    )
  )
  set align(center + horizon)
  let body = {
    block(
      text(size: 26pt, weight: "bold", utils.display-current-heading(level: 1), fill: self.colors.blue),
      width: 65%,
    )
  }
  touying-slide(self: self, body)
})

#let sano(footer: none, lang: "en", ..args, body) = {
  set text(size: 16pt, font: "New Computer Modern", lang: lang)
  set par(spacing: 1.8em, leading: 0.75em)
  set list(spacing: .7em)

  show: touying-slides.with(
    config-page(paper: "presentation-16-9", margin: (top: 95pt, bottom: 5em, left: 30pt, right: 20pt)),

    config-common(slide-fn: slide, new-section-slide-fn: new-section-slide),
    config-colors(..sano-colors),
    config-store(title: none),
    ..args,
  )

  body
}