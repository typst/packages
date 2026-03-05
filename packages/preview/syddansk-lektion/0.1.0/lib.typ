#import "@preview/touying:0.6.1": *

/// Default slide function for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
////   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function): The composer of the slide. You can use it to set the layout of the slide.
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
/// - background (string): A Touying color selection for the background.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  background: "neutral-lightest",
  ..bodies,
) = touying-slide-wrapper(self => {
  let deco-format(it) = text(size: .6em, fill: black, it)
  let header(self) = deco-format(
    components.left-and-right(
      utils.call-or-display(self, self.store.header),
      utils.call-or-display(self, self.store.header-right),
    ),
  )
  let footer(self) = {
    v(.5em)
    deco-format(
      components.left-and-right(
        utils.call-or-display(self, self.store.footer),
        utils.call-or-display(self, self.store.footer-right),
      ),
    )
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      fill: self.colors.at(background)
    ),
    config-common(subslide-preamble: self.store.subslide-preamble),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Title slide for the presentation.
///
/// Example: `#title-slide[Hello, World!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let title-slide(config: (:), body) = slide(
  config: utils.merge-dicts(
    config,
    config-common(freeze-slide-counter: true),
  ),
  background: "primary-lightest",
  body,
)

#let outline-slide(title: "Contents") = [
  #show link: x => x
  == #title
  #columns()[
  #colbreak()
  #components.adaptive-columns(outline(title: none))
  ]
]

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let new-section-slide(config: (:), body) = slide(
  background: "secondary-lightest",
  [
    #text(2.5em, weight: "bold", utils.display-current-heading(level: 1))
    #body
  ],
)

/// Touying Syyddansk Lektion theme
///
/// Example:
///
/// ```typst
/// #show: sdu-theme.with(institution: "IMADA")
/// ```
///
/// The default colors:
///
/// ```typst
/// colors: config-colors(
///   neutral-lightest: white,
///   neutral-darkest: black,
///   primary-darkest: rgb("#789d4a"),
///   primary-lightest: rgb("#aeb862"),
///   secondary-lightest: rgb("#f2c75c"),
/// )
/// ```
/// - institution (string): hosting institution (often an SDU institute/department).
///
/// - website (string): URL to a relevant website (defaults to sdu.dk).
///
/// - hashtag (string): relevant hashtag (defaults to \#sdudk).
///
/// - logo (content): institution logo (defaults to SDU's).
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - header (function): The header of the slides. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - header-right (content): The right part of the header. Default is `self.info.logo`.
///
/// - footer (content): The footer of the slides. Default is `none`.
///
/// - footer-right (content): The right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - color (dictionary): Touying colour palette.
///
/// - subslide-preamble (content): The preamble of the subslides. Default is `block(below: 1.5em, text(1.2em, weight: "bold", utils.display-current-heading(level: 2)))`.
#let sdu-theme(
  institution: "",
  website: "sdu.dk",
  hashtag: "#sdudk",
  logo: image("logo.png", alt: "Logo of Southern Denmark University"),
  date: datetime.today(),
  aspect-ratio: "16-9",
  colors: config-colors(
    neutral-lightest: white,
    neutral-darkest: black,
    primary-darkest: rgb("#789d4a"),
    primary-lightest: rgb("#aeb862"),
    secondary-lightest: rgb("#f2c75c"),
  ),
  header: institution => {
    set text(size: 1.5em)
    set strong(delta: 600)
    stack(
      spacing: 0.75em,
      [*#institution*],
      line(
        stroke: 3pt,
        length: 50pt,
      ),
    )
  },
  header-right: (website, hashtag) => {
    set text(size: 1.2em)
    set strong(delta: 600)
    move(
      rotate(90deg, origin: bottom + right, move(
        stack(dir: ltr, spacing: 6em, [*#website*], [*#hashtag*]),
        dx: 100%,
      )),
      dx: 3em,
    )
  },
  footer: logo => box(logo, height: 1.75em),
  footer-right: date => move(
    datetime.display(
      date,
      "[month repr:long] [year]",
    ),
    dx: 3em,
  ),
  subslide-preamble: block(
    below: 1.5em,
    text(2em, weight: "bold", utils.display-current-heading(level: 2)),
  ),
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      fill: colors.colors.neutral-lightest,
      paper: "presentation-" + aspect-ratio,
      margin: (left: 1.75em, right: 4.75em, top: 4.25em, bottom: 3em),
      footer-descent: 0em,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 14pt, font: ("Liberation Sans", "Arial"))
        show footnote.entry: set text(size: .6em)
        show heading.where(level: 1): set text(4em)
        show heading.where(level: 2): set text(3em)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-store(
      header: header(institution),
      header-right: header-right(website, hashtag),
      footer: footer(logo),
      footer-right: footer-right(date),
      subslide-preamble: subslide-preamble,
    ),
  colors,
  ..args,
  )
  show link: x => {
    set text(fill: colors.colors.primary-darkest)
    underline(x, offset: 2.5pt)
  }
  set list(marker: move([*🡢*], dy: -.2em))
  body
}
