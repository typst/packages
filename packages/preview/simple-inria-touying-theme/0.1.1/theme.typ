// This theme is inspired by Touying's metropolis theme

#import "@preview/touying:0.6.1": *

/* Default slide function for the presentation.

- title (string): The title of the slide. Default is `auto`.

- config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.

- repeat (int, string): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.

  The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.

- setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.

- composer (function, array): The composer of the slide. You can use it to set the layout of the slide.

  For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.

  If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.

  The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.

  For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.

  If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.

- bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide. */
#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  let header(self) = {
    set std.align(top)
    set std.align(horizon)
    set text(
      fill: if self.store.black-title { self.colors.neutral-darkest } else { self.colors.primary},
      weight: if self.store.black-title { "black" } else { "medium" },
      size: 1.5em
    )
    pad(
      rest: .4em,
      stack(dir: ltr,
        polygon(
          fill: gradient.radial(
            self.colors.primary-light,
            self.colors.secondary,
            self.colors.primary,
            center: (0%, 0%),
            radius: 120%,
            focal-radius: 5%,
          ),
          (0pt, 0pt),
          (20pt, 0pt),
          (20pt, 7pt),
          (7pt, 7pt),
          (7pt, 20pt),
          (0pt, 20pt),
        ),
        move(dx: -2pt, dy: 22pt,
          if title != auto {
            utils.fit-to-width(grow: false, 100%, title)
          } else {
            utils.call-or-display(self, self.store.header)
          }),
      )
    )
  }
  let footer(self) = {
    set std.align(bottom)
    set text(size: 0.5em)
    pad(
      .5em,
      components.left-and-right(
        text(
          fill: self.colors.neutral-darkest.lighten(40%),
          utils.call-or-display(self, self.store.footer),
        ),
        text(fill: self.colors.neutral-darkest, utils.call-or-display(
          self,
          self.store.footer-right,
        )),
      ),
    )
    if self.store.footer-progress {
      place(top, components.progress-bar(
        height: 1pt,
        self.colors.primary,
        self.colors.primary-light,
      ))
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

/* Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.

Example:

```typst
#show: inria-theme.with(
 config-info(
 title: [Title],
 logo: emoji.city,
 ),
 )

#title-slide(subtitle: [Subtitle], extra: [Extra information])
 ```

- config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.

- extra (string, none): The extra information you want to display on the title slide. */
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
        text(size: 1.3em, text(weight: "black", info.title))
        if info.subtitle != none {
          linebreak()
          text(size: 0.9em, info.subtitle)
        }
        line(length: 20%, stroke: 7pt + gradient.linear(
          self.colors.primary-light,
          self.colors.secondary,
          self.colors.primary,
        ))
        set text(size: .8em)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        if info.date != none {
          block(spacing: 1em, utils.display-info-date(self))
        }
        if self.store.logo != none {
          box(height: 2em, self.store.logo)
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
  touying-slide(self: self, body)
})


/* New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.

Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`

- config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.

- level (int): The level of the heading.

- numbered (boolean): Indicates whether the heading is numbered.

- body (auto): The body of the section. It will be passed by touying automatically. */
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(center)
    show: pad.with(20%)
    set text(size: 1.5em)
    stack(
      dir: ttb,
      spacing: 1em,
      text(self.colors.neutral-darkest, utils.display-current-heading(
        level: level,
        numbered: numbered,
        style: auto,
      )),
      block(
        height: 7pt,
        width: 30%,
        spacing: 0pt,
        components.progress-bar(
          height: 7pt,
          self.colors.primary,
          self.colors.primary-light,
        ),
      ),
    )
    text(self.colors.neutral-dark, body)
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, config: config, slide-body)
})


/* Focus on some content.

Example: `#focus-slide[Wake up!]`

- config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.

- align (alignment): The alignment of the content. Default is `horizon + center`. */
#let focus-slide(
  config: (:),
  align: horizon + center,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-dark, margin: 2em),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})

// Inria colors
#let inria-rouge = rgb("#c9191e")
#let inria-framboise = rgb("#a60f79")
#let inria-violet = rgb("#5d4b9a")
#let inria-bleu-nuit = rgb("#27348b")
#let inria-bleu-canard = rgb("#1067a3")
#let inria-bleu-azur = rgb("#00a5cc")
#let inria-bleu-vert = rgb("#88ccca")
#let inria-gris-bleu = rgb("#384257")
#let inria-cactus = rgb("#608b37")
#let inria-vert-tendre = rgb("#95c11f")
#let inria-jaune = rgb("#ffcd1c")
#let inria-orange = rgb("#ff8300")
#let inria-sable = rgb("#d6bc86")

// Utility function when you want bold but not alert
#let bold(body) = {
  text(weight: "bold", body)
}

#let fullcite(label) = {
  set text(size: .5em)
  cite(label, form: "full")
}

#let inria-logo = image("assets/inr_logo_rouge.svg", alt: "Inria Logo")

/* Touying Inria theme.

Example:

```typst
#show: inria-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
 ```

Consider using:

```typst
#set text(lang: "en")`
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
```

- aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.

- align (alignment): The alignment of the content. Default is `horizon`.

- header (content, function): The header of the slide. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.

- footer (content, function): The footer of the slide. Default is `none`.

- footer-right (content, function): The right part of the footer. Default is `context utils.slide-counter.display()`.

- footer-progress (boolean): Whether to show the progress bar in the footer. Default is `true`.

- section-slides (boolean): Whether to consider that sections define slides directly. Default is `true`.

- black-title (boolean): Whether to use the usual text color for titles (but extra-bold), if false use the accent color instead. Default is `true`. */
#let inria-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  footer: self => self.store.logo,
  footer-right: context utils.slide-counter.display(),
  footer-progress: true,
  logo: inria-logo,
  section-slides: true,
  black-title: true,
  ..args,
  body,
) = {
  set text(font: ("Inria Sans", "Fira Sans", "Noto Sans", "DejaVu Sans Mono"), weight: "medium", size: 24pt)
  set list(marker: (text(fill: inria-framboise, [⦿]), text(fill: inria-cactus, [▶]), [–]))

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: if section-slides { none } else { new-section-slide },
      slide-level: if section-slides { 1 } else { 2 },
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: inria-rouge,               // accent
      primary-light: inria-bleu-nuit,     // progress
      secondary: inria-framboise,
      neutral-lightest: white,            // bg
      neutral-darkest: inria-gris-bleu,   // fg
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      footer: footer,
      footer-right: footer-right,
      footer-progress: footer-progress,
      black-title: black-title,
      logo: logo,
    ),
    ..args,
  )

  body
}
