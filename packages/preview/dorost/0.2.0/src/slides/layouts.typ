#import "../config.typ": default-colors, default-text
#import "../layout/cover.typ": cover-page
#import "../components/frames.typ": section-title
#import "../components/blocks.typ": quote-frame

// Each layout occupies one available page body. Weak breaks avoid blank slides.
#let slide-frame(body, title: none) = {
  pagebreak(weak: true)
  block(width: 100%, height: 100%)[
    #if title == none { body } else {
      grid(
        columns: (1fr,), rows: (auto, 1fr), row-gutter: default-text.paragraph-spacing,
        text(size: 1.4em, fill: default-colors.accent, section-title(title)),
        body,
      )
    }
  ]
}

#let slide-cover(title, subtitle: none, author: none, date: none) = slide-frame(
  align(horizon, cover-page(title, subtitle: subtitle, author: author, date: date)),
)

#let slide-section(title, subtitle: none) = slide-frame(
  align(horizon, cover-page(title, subtitle: subtitle)),
)

#let slide-content(body, title: none) = slide-frame(body, title: title)

#let slide-columns(left, right, title: none, ratio: (1fr, 1fr)) = slide-frame(
  grid(columns: ratio, column-gutter: 1em, left, right), title: title,
)

#let check-fit(fit) = {
  if fit not in ("contain", "cover") {
    panic("dorost: slide image fit must be \"contain\" or \"cover\"")
  }
}

#let slide-image(path, fit: "contain", background: none) = {
  check-fit(fit)
  slide-frame(block(width: 100%, height: 100%, fill: background,
    image(path, width: 100%, height: 100%, fit: fit),
  ))
}

#let slide-image-text(path, body, title: none, fit: "contain", image-side: "end") = {
  check-fit(fit)
  if image-side not in ("start", "end") {
    panic("dorost: image-side must be \"start\" or \"end\"")
  }
  let picture = image(path, width: 100%, height: 100%, fit: fit)
  let cells = if image-side == "start" { (picture, body) } else { (body, picture) }
  slide-frame(grid(columns: (1fr, 1fr), column-gutter: 1em, ..cells), title: title)
}

#let slide-statement(body, attribution: none) = slide-frame(
  align(horizon, quote-frame(text(size: 1.4em, body), attribution: attribution)),
)
