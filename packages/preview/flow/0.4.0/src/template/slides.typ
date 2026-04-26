// mostly based on:
// https://touying-typ.github.io/docs/build-your-own-theme
// https://touying-typ.github.io/docs/sections

#import "@preview/touying:0.6.3": *

#import "common.typ": *
#import "modern.typ": modern

#let no-deco = (header: none, footer: none)
#let pseudo-heading(it, scale: 1) = text(
  1.25em * scale,
  strong(it),
)
#let sidebar-outline(highlight: "current") = {
  assert(highlight in ("all", "current"))

  set align(right)
  set outline(depth: 1, title: none)

  // the idea for this selective sizing + weighting was taken from lineal by ellsphillips
  // https://typst.app/universe/package/lineal (licensed under MIT)
  // thanks for sharing it with the world!!
  let transform(it, cover: false, ..args) = {
    let body = it.element.body
    let body = if highlight == "current" {
      if cover {
        text(0.75em, slides-scheme.neutral-lightest, body)
      } else {
        text(1.5em, fg, strong(body))
      }
    } else {
      text(fg, strong(body))
    }

    link(it.element.location(), body)
    [\ ]
  }

  components.progressive-outline(
    alpha: if highlight == "all" { 100% } else { 30% },
    transform: transform,
  )
}

#let slide(
  header: self => pseudo-heading(
    utils.display-current-short-heading(),
  ),
  footer: self => context fade({
    h(1fr)
    utils.slide-counter.display()
    [ #sym.slash ]
    utils.last-slide-number
  }),
  ..args,
) = touying-slide-wrapper(self => {
  // yes, this is intentional. even the example does this,
  // so i assume this is an example of "exposed" internals? /j
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (rest: 0.5em, top: 3.5em),
      header: header,
      footer: footer,
    ),
  )

  touying-slide(self: self, ..args)
})

#let split-slide(
  west,
  east,
  main: right,
  ..args,
) = {
  assert(
    main in (left, right),
    message: "say which side should be larger",
  )

  let sizes = (golden-ratio * 1fr, 1fr)
  let sizes = if main == right {
    sizes.rev()
  } else {
    sizes
  }

  slide(
    composer: sizes,
    align(mid, box(height: 100%, west)),
    align(left + horizon, box(height: 100%, east)),
    ..args,
  )
}

#let title-slide(
  body,
  title: "Untitled",
  subtitle: none,
  ..data,
) = split-slide(
  body,
  (
    text(2em, strong(title)),
    subtitle,
    info.render(forget-keys(data.named(), ("keywords",))),
  )
    .filter(part => part != none)
    .join[\ ],
  ..no-deco,
)

#let center-slide(body, ..args) = slide(
  align(mid, body),
  ..args,
)

/// Semi-outline. Actually more of an outlook on what to expect.
#let overview(body, ..args) = {
  set align(mid)
  set heading(outlined: false, numbering: none)

  split-slide(
    sidebar-outline(highlight: "all"),
    body,
    ..no-deco,
  )
}

#let _new-section-slide(section) = split-slide(
  sidebar-outline(),
  {
    pseudo-heading(
      scale: 2,
      utils.display-current-short-heading(),
    )
    [\ ]
    section
  },
  ..no-deco,
)

#let flow-theme(
  body,
  aspect-ratio: "16-9",
  prefix-title-slide: true,
  banner: none,
  ..args,
) = {
  show: modern.with(..args)
  let (data, title) = _shared(args)

  set text(24pt)
  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-colors(..slides-scheme),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: _new-section-slide,
    ),
  )

  if prefix-title-slide {
    title-slide(
      banner,
      title: title,
      ..data,
    )
  }

  body
}
