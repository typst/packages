// This theme is inspired by the brand guidelines of University of Bristol
// This theme is revised from https://github.com/touying-typ/touying/blob/main/themes/metropolis.typ
// The original theme was written by https://github.com/Enivex
// The code was revised by https://github.com/HPDell

#import "@preview/touying:0.5.2": *

/// Use to replace the default composer
#let multicolumns(columns: auto, alignment: top, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  grid(columns: columns, gutter: gutter, align: alignment, ..bodies)
}

#let _typst-builtin-align = align

/// Default slide function for the presentation.
///
/// - `title` is the title of the slide. Default is `auto`.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
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
  // restore typst builtin align function
  let align = _typst-builtin-align
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: (x: 2em))
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em)
    if title != auto {
      utils.fit-to-width.with(grow: false, 100%, title)
    } else {
      utils.call-or-display(self, self.store.header)
    }
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.8em)
    block(height: 1.5em, width: 100%, stroke: (top: self.colors.primary + 2pt), pad(
      y: .4em,
      x: 2em,
      components.left-and-right(
        text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer)),
        text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-right)),
      ),
    ))
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
    show: align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show heading.where(level: self.slide-level + 1): it => {
      stack(
        dir: ltr, spacing: .4em,
        image("uob-bullet.svg", height: .8em),
        text(fill: self.colors.primary, it.body)
      )
    }
    set enum(numbering: (nums) => {
      text(fill: self.colors.primary, weight: "bold", str(nums) + ".")
    })
    set list(marker: (level) => {
      text(fill: self.colors.primary, weight: "bold", sym.triangle.r.filled)
    })
    set table(stroke: self.colors.primary)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: multicolumns, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: metropolis-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - `extra` is the extra information you want to display on the title slide.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set align(horizon)
    grid(
      rows: (auto, 1fr),
      pad(y: 2em, x: 2em, image("./uob-logo.svg", height: 2.4em)),
      block(width: 100%, height: 100%, {
        place(bottom + right, polygon(
          stroke: none,
          fill: gray.transparentize(60%),
          (0pt, 0pt),
          (2cm, -8cm),
          (14cm, -8cm),
          (14cm, 0pt)
        ))
        place(top + left, polygon(
          fill: self.colors.primary.transparentize(10%),
          stroke: none,
          (0cm, 0cm),
          (0cm, 8cm),
          (22cm, 8cm),
          (24cm, 0cm)
        ))
        place(top + left, {
          set text(fill: self.colors.neutral-lightest)
          grid(
            rows: (4cm, 4cm),
            columns: (24cm),
            block(inset: (x: 2em, y: 1em), width: 100%, height: 100%, {
              set align(bottom + left)
              set text(size: 32pt, weight: "bold")
              info.title
            }),
            block(inset: (left: 2em, right: 8em, y: 1em), width: 100%, height: 100%, {
              set align(top + left)
              set text(size: 24pt)
              info.subtitle
            })
          )
        })
        place(bottom + left, block(
          width: 100%,
          height: 8cm,
          inset: (x: 2em, top: 4em),
          {
            set align(left + horizon)
            set text(16pt)
            stack(
              dir: ttb,
              spacing: 8pt,
              self.info.date.display(self.datetime-format),
              self.info.institution
            )
          }
        ))
      })
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.neutral-lightest, 
      margin: 0em
    ),
  )
  touying-slide(self: self, body)
})

/// Show the outline slide
///
/// - `title` is the title shown on top of the outline. Default: `Outline`
/// - `column` is the number of columns to show the outline. Default: 2.
/// - `marker` is something to mark the items before each heading. Default to the `uob-bullet.svg`.
/// - `args` are additional args passing to `touying-slide-wrapper`.
///
/// Example:
/// 
/// ```
/// #outline-slide()
/// ```
#let outline-slide(title: [Outline], column: 2, marker: auto, ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let header = {
    set align(center + bottom)
    block(
      fill: self.colors.neutral-lightest,
      outset: (x: 2.4em, y: .8em),
      stroke: (bottom: self.colors.primary + 3.2pt),
      text(self.colors.primary, weight: "bold", size: 1.6em, title)
    )
  }
  let body = {
    set align(horizon)
    show outline.entry: it => {
      let mark = if ( marker == auto ) {
        image("uob-bullet.svg", height: .8em)
      } else if type(marker) == image {
        set image(height: .8em)
        image
      } else if type(marker) == symbol {
        text(fill: self.colors.primary, marker)
      }
      block(stack(dir: ltr, spacing: .8em, mark, it.body), below: 0pt)
    }
    show: pad.with(x: 1.6em)
    columns(column, outline(title: none, indent: 1em, depth: 1))
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      margin: (top: 4.8em, bottom: 1.6em),
      fill: self.colors.neutral-lightest
    )
  )
  touying-slide(self: self, body)
})

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `level` is the level of the heading.
///
/// - `numbered` is whether the heading is numbered.
///
/// - `title` is the title of the section. It will be pass by touying automatically.
#let new-section-slide(level: 1, numbered: true, title) = touying-slide-wrapper(self => {
  let header = {
    components.progress-bar(height: 8pt, self.colors.primary, self.colors.primary.lighten(40%))
  }
  let footer = {
    set align(bottom)
    set text(size: 0.8em, fill: self.colors.neutral-lightest)
    block(height: 1.5em, width: 100%, fill: self.colors.primary, pad(
      y: .4em,
      x: 2em,
      components.left-and-right(
        text(utils.call-or-display(self, self.store.footer)),
        text(utils.call-or-display(self, self.store.footer-right)),
      ),
    ))
  }
  let body = {
    set align(horizon + center)
    show: pad.with(20%)
    set text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold")
    block(
      // outset: (right: 2pt, bottom: 2pt),
      fill: self.colors.neutral-light,
      radius: 8pt,
      move(dx: -4pt, dy: -4pt, block(
        width: 100%,
        fill: self.colors.primary,
        inset: (x: 1em, y: .8em),
        radius: 8pt,
        utils.display-current-heading(level: level, numbered: numbered)
      ))
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
      margin: 0em,
    ),
  )
  touying-slide(self: self, body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `align` is the alignment of the content. Default is `horizon + center`.
#let focus-slide(align: horizon + center, body) = touying-slide-wrapper(self => {
  let _align = align
  let align = _typst-builtin-align
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, margin: 2em),
  )
  set text(fill: self.colors.primary, size: 1.5em)
  touying-slide(self: self, align(_align, body))
})


/// Touying metropolis theme.
///
/// Example:
///
/// ```typst
/// #show: metropolis-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)`
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `align` is the alignment of the content. Default is `horizon`.
///
/// - `header` is the header of the slide. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - `header-right` is the right part of the header. Default is `self => self.info.logo`.
///
/// - `footer` is the footer of the slide. Default is `none`.
///
/// - `footer-right` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - `footer-progress` is whether to show the progress bar in the footer. Default is `true`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#eb811b"),
///   primary-light: rgb("#d6c6b7"),
///   secondary: rgb("#23373b"),
///   neutral-lightest: rgb("#fafafa"),
///   neutral-dark: rgb("#23373b"),
///   neutral-darkest: rgb("#23373b"),
/// )
/// ```
#let uobristol-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level),
  header-right: self => self.info.logo,
  footer: none,
  footer-right: context utils.slide-counter.display(),
  footer-progress: true,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt, font: "Lato")
        show highlight: body => text(fill: self.colors.primary, strong(body.body))
        body
      },
      alert: utils.alert-with-primary-color
    ),
    config-colors(
      neutral-lightest: rgb("#fafafa"),
      primary: rgb("#ab1f2d"),
      secondary: rgb("#ea6719")
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      header-right: header-right,
      footer: footer,
      footer-right: footer-right,
      footer-progress: footer-progress,
    ),
    config-info(
      datetime-format: "[day] [month repr:short] [year]"
    ),
    ..args,
  )
  body
}