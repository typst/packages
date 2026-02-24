
// This theme is inspired by touying.metropolis 
// and the coloured boxes by cosmos.fancy
#import "@preview/touying:0.6.1": *
#import "@preview/theorion:0.3.2": *
// #import cosmos.fancy: *
#import "colours.typ": tuhi-palette
#import "boxes.typ": * // customised boxes

// helper macros
#import "helpers.typ": *

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
    show: components.cell.with(fill: self.colors.neutral-light, inset: 1em, stroke: (bottom:0.8pt + self.colors.primary-darker))
    set std.align(horizon)
    set text(fill: self.colors.primary, weight: "semibold", size: 1.1em)
    show text: smcps
    components.left-and-right(
      {
        if title != auto {
          utils.fit-to-width(grow: false, 100%,  title)
        } else {
          utils.call-or-display(self, self.store.header)
        }
      },
      utils.call-or-display(self, self.store.header-right),
    )
  }
  let footer(self) = {
    set std.align(bottom)
    set text(size: 0.8em)
    pad(
      .5em,
      components.left-and-right(
        text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer)),
        text(fill: self.colors.neutral-dark, utils.call-or-display(self, self.store.footer-right)),
      ),
    )
    if self.store.footer-progress {
      place(bottom, components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light))
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lighter,
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
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
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
    config-page(fill: self.colors.neutral-lighter),
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    block(
      width: 100%,
      inset: 2em,
      {
        components.left-and-right(
          {
            text(size: 1.4em, text(weight: "medium", info.title))
            if info.subtitle != none {
              v(1em, weak:true)
              text(size: 1em, info.subtitle)
            }
          },
           text(2em, utils.call-or-display(self, info.logo)),
        )
        line(length: 100%, stroke: .05em + self.colors.secondary)
        set text(size: 0.9em)
        if info.author != none {
          v(1.2em, weak:true)
          block(spacing: 1em, info.author)
        }
        if info.date != none {
          block(spacing: 1em, utils.display-info-date(self))
        }
        set text(size: 1em)
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
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
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    set text(size: 1.2em)
    stack(
      dir: ttb,
      spacing: 0.5em,
      text(self.colors.primary, utils.display-current-heading(level: level, numbered: numbered, style: auto)),
      block(
        height: 10pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 1.8pt, self.colors.secondary-dark, self.colors.primary-light),
      ),
    )
    set text(size: 0.8em)
    v(1em,weak: true)
    text(self.colors.neutral, body)
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lighter),
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
#let focus-slide(config: (:), style: "w", align: horizon + center, body) = touying-slide-wrapper(self => {

  if style == "primary" {
    self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true, show-strong-with-alert: false),
    config-page(fill: self.colors.primary-lighter, margin: 2em),
  )
  set text(fill: self.colors.primary, size: 1.8em, weight: "semibold")
  touying-slide(self: self, config: config, std.align(align, body))
  } else if style == "secondary" {
    self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true, show-strong-with-alert: false),
    config-page(fill: self.colors.secondary-lighter, margin: 2em),
  )
  set text(fill: self.colors.secondary, size: 1.8em, weight: "semibold")
  touying-slide(self: self, config: config, std.align(align, body))
  } else if style == "tertiary" {
    self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true, show-strong-with-alert: false),
    config-page(fill: self.colors.tertiary-lightest, margin: 2em),
  )
  set text(fill: self.colors.tertiary-darker, size: 1.8em, weight: "semibold")
  touying-slide(self: self, config: config, std.align(align, body))
  } else {
    self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true, show-strong-with-alert: false),
    config-page(fill: self.colors.neutral-lightest, margin: 2em),
  )
  set text(fill: self.colors.neutral, size: 1.8em, weight: "semibold")
  touying-slide(self: self, config: config, std.align(align, body))
  }

  
})


#let image-slide(body,background:none, fill:none) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: background,
      margin: 2em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  set image(width: 100%,height: auto)
  touying-slide(self: self, align(horizon + center, body))
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
#let tuhi-vuw-theme(
  lang: "en",
  aspect-ratio: "4-3",
  align: horizon,
  base-size: 22pt,
  font: ("Fira Sans",),
  math-font: ("Fira Math","Garamond-Math","New Computer Modern Math"),
  math-scale: 1,
  mono-font: "Fira Mono",
  code-font: "Fira Code",
  mode: "light",
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  header-right: self => self.info.logo,
  footer: none,
  footer-right: context utils.slide-counter.display() ,//+ " / " + utils.last-slide-number
  footer-progress: true,
  ..args,
  body,
) = {
  
  set text(font: font, weight: 400, size: base-size, lang: lang)
  show math.equation: set text(font: math-font,  size: base-size*math-scale, fallback: true) 
  show raw: set text(font: code-font)
  show link: set text(font: mono-font)
  set strong(delta: 100)
  set par(justify: true)
  // no Figure 1 etc. in captions
  set figure(supplement: none, numbering: none)
  // show figure.caption.where(kind: image): set text(size: 0.8em) 
  show figure.caption.where(kind: "theorem"): none
  show figure.caption.where(kind: "definition"): none
  show figure.caption.where(kind: "warning"): none
  show figure.caption.where(kind: "neutral"): none
  show figure.caption.where(kind: image): set text(size: 0.8em)
  // show figure.caption.where(kind: theorem): set text(size: 1.8em)
  // show image: {x => { align(center, x) }}
  show image: it => {
  std.align(center, it)
  }
  
  let alert-with-secondary-color(self: none, body) = text(fill: self.colors.secondary, weight:"semibold", body)

  show heading.where(level:3): set text(fill: tuhi-palette.primary-darker, weight: "medium")

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent:40%,
      footer-descent: 10%,
      margin: (top: 5em, bottom: 1.0em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false,
    ),
    config-methods(
      alert: alert-with-secondary-color,//utils.alert-with-primary-color
    ),
    config-colors(
      ..tuhi-palette
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
