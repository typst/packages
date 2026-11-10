// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex

#import "@preview/touying:0.6.1": *
#import "@preview/iconic-salmon-fa:1.1.0": *
#import "theme-color.typ": *
#import "callout.typ": *
#import "fontset.typ": default-fontset

#let assets = (
  wave: image("assets/wave.svg"),
  wave-dark: image("assets/wave-dark.svg"),
  logo-blue: image("assets/logo.svg"),
  logo-white: image("assets/logo-white.svg"),
  logo-title: image("assets/logo-title.svg"),
)

#let multi-columns(columns: auto, gutter: 1em, alignment: top, ..bodies) = {
  let args = bodies.named()
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  grid(columns: columns, gutter: gutter, align: alignment, ..args, ..bodies)
}

#let page-aligned(columns: auto, gutter: 1em, alignment: top, ..bodies) = {
  let args = bodies.named()
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  align(alignment, grid(columns: columns, gutter: gutter, align: alignment, ..args, ..bodies))
}

/// Default slide function for the presentation.
///
/// - title (string): The title of the slide. Default is `auto`.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, string): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function, array): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
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
    show: components.cell.with(fill: self.colors.primary-dark, inset: (left: 1.6em, rest: 4pt), height: 2.4em)
    set std.align(horizon)
    set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em)
    components.left-and-right(
      {
        if title != auto {
          utils.fit-to-width(grow: false, 100%, title)
        } else {
          utils.call-or-display(self, self.store.header)
        }
      },
      utils.call-or-display(self, move(assets.logo-white)),
    )
  }
  let footer(self) = {
    set std.align(bottom)
    set text(size: 0.8em)
    pad(
      x: .4em,
      y: .2em,
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
        height: 2pt,
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

#let slide-mc(
  ..args,
) = {
  let kwargs = args.named()
  let bodies = args.pos()
  slide(..kwargs, composer: multi-columns, ..bodies)
}

#let slide-aligned(
  ..args,
) = {
  let kwargs = args.named()
  let bodies = args.pos()
  slide(..kwargs, composer: page-aligned, ..bodies)
}

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
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - extra (string, none): The extra information you want to display on the title slide.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, footer: none),
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    place(
      scale({
        place(assets.wave)
        rect(width: 100%, height: 100%, fill: self.colors.neutral-lightest.transparentize(30%))
      }, x: 140%, y: 140%),
    )
    block(
      width: 100%,
      height: 100%,
      inset: (x: 2em, top: 3.2cm, bottom: 0.8cm),
      {
        grid(
          columns: 100%,
          rows: (2fr, 1fr, auto),
          row-gutter: 1cm,
          {
            set align(center + horizon)
            show title: set text(fill: self.colors.primary-dark)
            title(self.info.title)
          },
          if self.info.subtitle != none {
            set align(center + top)
            show title: set text(fill: self.colors.neutral-dark)
            text(size: 1.2em, weight: "bold", self.info.subtitle)
          } else { none },
          {
            set align(left)
            set text(size: 0.8em)
            terms(
              ..(
                if self.info.at("author", default: none) != none { terms.item(fa-circle-user(), self.info.author) } else { none },
                if self.info.at("institution", default: none) != none { terms.item(fa-institution(), self.info.institution) } else { none },
                if self.info.at("date", default: none) != none { 
                  terms.item(fa-calendar(), self.info.date.display(self.info.at("datetime-format", default: "[year]年[month]月[day]日"))) 
                } else { none },
              ).filter(it => it != none)
            )
          }
        )
      }
    )
    place(
      top + right,
      block(height: 1.6cm, assets.logo-title),
      dy: -1cm,
    )
  }
  touying-slide(self: self, body)
})


#let outline-slide(title: [Outline], column: 1, max-content-width: 80%, max-column-width: 40%, marker: auto, ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let header = {
    set align(center + bottom)
    block(
      fill: self.colors.neutral-lightest,
      outset: (x: 2.4em, y: .8em),
      stroke: (bottom: self.colors.primary + 3.2pt),
      text(self.colors.primary-dark, weight: "bold", size: 1.6em, title)
    )
  }
  let column-width = calc.min(max-content-width / column, max-column-width)
  let body = {
    set align(horizon + center)
    show outline.entry: it => {
      let mark = if ( marker == auto ) {
        assets.wave
      } else if type(marker) == image {
        set image(height: .8em)
        image
      } else if type(marker) == symbol {
        text(fill: self.colors.primary, marker)
      }
      show: block.with(below: 1em, width: 100%)
      // place(dx: -2em, box(width: 1.6em, mark))
      // it.body()
      // h(0.2em)
      // box(width: 1fr, repeat[.])
      // h(0.2em)
      // numbering(it.element.location().page-numbering(), it.element.location().page())
      place(dx: -2em, box(width: 1.6em, mark))
      box(it)
    }
    show: block.with(width: column-width * column)
    set align(left)
    columns(column, gutter: 3.2em, outline(title: none, indent: 1em, depth: 1))
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: none,
      margin: (top: 4cm, bottom: 2cm),
      fill: self.colors.neutral-lightest
    )
  )
  touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - level (int): The level of the heading.
///
/// - numbered (boolean): Indicates whether the heading is numbered.
///
/// - body (auto): The body of the section. It will be passed by touying automatically.
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  let slide-body = {
    place(
      top + right,
      block(
        height: 1.6cm,
        assets.logo-blue
      ),
      dx: 1.3cm,
      dy: -2cm,
    )
    set std.align(horizon)
    show: pad.with(16%)
    {
      set text(size: 1.5em)
      stack(
        dir: ttb,
        spacing: 1em,
        grid(
          columns: (auto, 1fr),
          column-gutter: 8pt,
          block(
            height: 1em,
            assets.wave
          ),
          text(self.colors.neutral-darkest, utils.display-current-heading(
            level: level,
            numbered: numbered,
            style: auto,
          ))
        ),
        block(
          height: 2pt,
          width: 100%,
          spacing: 0pt,
          components.progress-bar(
            height: 2pt,
            self.colors.primary,
            self.colors.primary-light,
          ),
        ),
      )
    }
    text(self.colors.neutral-dark, body)
  }
  let footer(self) = {
    set std.align(bottom)
    set text(size: 0.8em)
    show: components.cell.with(fill: self.colors.primary-dark)
    show: pad.with(x: 0.4em, y: 0.2em)
    components.left-and-right(
      text(
        fill: self.colors.neutral-lightest,
        utils.call-or-display(self, self.store.footer),
      ),
      text(fill: self.colors.neutral-lightest, utils.call-or-display(
        self,
        self.store.footer-right,
      )),
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - align (alignment): The alignment of the content. Default is `horizon + center`.
#let focus-slide(
  config: (:),
  align: horizon + center,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary-dark, margin: 2em, footer: none, header: none),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
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
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - align (alignment): The alignment of the content. Default is `horizon`.
///
/// - header (content, function): The header of the slide. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - header-right (content, function): The right part of the header. Default is `self => self.info.logo`.
///
/// - footer (content, function): The footer of the slide. Default is `none`.
///
/// - footer-right (content, function): The right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - footer-progress (boolean): Whether to show the progress bar in the footer. Default is `true`.
#let hhu-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  header-right: self => self.info.logo,
  footer: none,
  footer-right: context utils.slide-counter.display()
    + " / "
    + utils.last-slide-number,
  footer-progress: true,
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3.2em, bottom: 1.6em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        let kwargs = args.named()
        let math-font = kwargs.at("math-font", default: "New Computer Modern Math")
        let text-size = kwargs.at("text-size", default: 20pt)
        set text(size: text-size)
        show math.equation: set text(font: math-font)
        show heading.where(level: self.slide-level + 1): it => stack(
          dir: ltr,
          move(dx: -8pt, box(height: 0.8em, assets.wave-dark)),
          it
        )
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: theme-color.blue,
      primary-light: theme-color.blue.lighten(30%),
      primary-dark: theme-color.blue.darken(30%),
      secondary: theme-color.navy,
      neutral-lightest: theme-color.white,
      neutral-dark: theme-color.black,
      neutral-darkest: theme-color.black,
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
    ..args,
  )

  body
}