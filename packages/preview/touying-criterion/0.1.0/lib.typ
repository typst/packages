
/// "Criterion" theme by thy0s
/// Inspired by and partially taken from:
/// - https://github.com/touying-typ/touying/blob/main/themes/university.typ
/// - https://github.com/touying-typ/touying/blob/main/themes/metropolis.typ
/// - https://github.com/JoshuaLampert/clean-math-presentation

#import "@preview/touying:0.6.1": *

/// Standard content "slide":
/// - "title" (string) sets the title if function is called directly.
/// - "footer" (string) allows for overriding the default footer for the presentation.
/// - "show-level-one" (bool) allows for toggling the level 1 heading of an individual slide.
#let slide(
  title: auto,
  footer: auto,
  show-level-one: none,
  ..args,
) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  if footer != auto {
    self.store.footer = footer
  }
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)

    if show-level-one == true or self.store.show-level-one and show-level-one != false {
      utils.display-current-heading(level: 1)
      linebreak()
    }

    set text(size: 1.8em, weight: "bold")
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .7em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

/// "title-slide":
/// - Title, subtitle, presenter, institution and date are taken directly from the "config-info"
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    block(
      width: 100%,
      inset: 2em,
      {
        text(size: 1.5em, text(weight: "bold", fill: self.colors.primary, info.title))
        if info.subtitle != none {
          linebreak()
          block(spacing: 1em, text(weight: "medium", info.subtitle))
        }
        line(length: 100%, stroke: 2pt + self.colors.primary)
        set text(size: .9em)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
        if info.date != none {
          block(spacing: 1em, info.date.display("[year]-[month]-[day]"))
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
  touying-slide(self: self, body)
})

///"outline-slide" based on the standard slide:
/// - depth: Describes the max heading level displayed in the outline
/// - title: Modify the title of the outline slide (e.g. for different languages)
#let outline-slide(
  depth: 2,
  title: "Outline",
) = slide(
  title: title,
  show-level-one: false,
)[
  #show outline.entry.where(level: 1): it => strong(it)
  #components.adaptive-columns(
    outline(
      title: none,
      indent: auto,
      depth: depth,
    ),
  )
]

/// "new-section-slide" is shown for every level one heading (i.e. section headings):
/// - numbered: Display the heading number if it exists (default: true)
#let new-section-slide(
  config: (:),
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    set text(size: 1.8em, fill: self.colors.primary, weight: "bold")
    stack(
      dir: ttb,
      spacing: .65em,
      utils.display-current-heading(level: 1, numbered: numbered),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.secondary),
      ),
    )
    body
  }
  touying-slide(self: self, config: config, slide-body)
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


/// "touying-criterion":
/// - "aspect-ratio" - Set the format of the slides (default: 16-9), (alternatively 4-3)
/// - "lang" (ISO 639-1/2/3 language code) - Set the language of the presentation (default: "en")
/// - "font" - Set the font of your choosing (default: Source Sans 3) Available at: https://api.fontsource.org/v1/download/source-sans-3
/// - "text-size" - Set font size for the text body (default: 22pt)
/// - "show-level-one" (bool) - Show the section heading on the contents slides (defualt: true)
/// - "footer" - Set the default footer for content slides (can be overridden for individual slides)
#let touying-criterion(
  aspect-ratio: "16-9",
  lang: "en",
  font: "Source Sans 3",
  text-size: 22pt,
  show-level-one: true,
  footer: none,
  ..args,
  body,
) = {
  set text(size: text-size, font: font, lang: lang)
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 3.5em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(alert: (self: none, it) => text(fill: self.colors.primary, it)),
    config-colors(
      primary: rgb("003366"),
      secondary: rgb("CCE5FF"),
      neutral-lightest: rgb("FFFFFF"),
      neutral-darkest: rgb("000000"),
    ),
    config-store(
      title: none,
      footer: footer,
      show-level-one: show-level-one,
    ),
    ..args,
  )
  body
}
