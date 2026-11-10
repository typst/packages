// Metropolyst Theme - A highly configurable variant of the Metropolis theme
// Inspired by https://github.com/matze/mtheme and the Touying Metropolis theme
// Unlike Metropolis, this theme exposes all font properties as configuration options

#import "@preview/touying:0.6.1": *

/// Built-in brand presets for organizational styling.
/// Usage: `#show: metropolyst-theme.with(..brands.EPI)`
/// Users can also define their own brands as dictionaries.
#let brands = (
  EPI: (
    accent-color: rgb("#C01F41"),
    header-background-color: rgb("#063957"),
    progress-bar-background: auto,
    footer-right: none,
    font: ("Roboto",),
  ),
)

/// Default slide function for the presentation.
///
/// - title (string): The title of the slide. Default is `auto`.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, string): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
/// The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function, array): The composer of the slide. You can use it to set the layout of the slide.
///
/// For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
/// If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
/// The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
/// For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
/// If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
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
    show: components.cell.with(fill: self.store.header-background-color, inset: (top: 1.2em, bottom: 1.2em, x: 1em))
    set std.align(horizon)
    set text(
      fill: self.store.header-text-color,
      weight: self.store.header-weight,
      size: self.store.header-size,
      font: self.store.header-font,
    )
    components.left-and-right(
      {
        if title != auto {
          utils.fit-to-width(grow: false, 100%, title)
        } else {
          utils.call-or-display(self, self.store.header)
        }
      },
      utils.call-or-display(self, self.store.header-right),
    )
  }
  let footer(self) = {
    set std.align(bottom)
    set text(
      size: self.store.footer-size,
      font: self.store.footer-font,
      weight: self.store.footer-weight,
    )
    pad(
      .5em,
      components.left-and-right(
        text(
          fill: self.store.footer-text-color.lighten(40%),
          utils.call-or-display(self, self.store.footer),
        ),
        text(fill: self.store.footer-text-color, utils.call-or-display(
          self,
          self.store.footer-right,
        )),
      ),
    )
    if self.store.footer-progress {
      place(bottom, components.progress-bar(
        height: 2pt,
        self.store.progress-bar-color,
        self.store.progress-bar-background,
      ))
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.store.main-background-color,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    set text(fill: self.store.main-text-color)
    // Hide slide title headings in body (they appear in the header)
    show heading.where(level: 1): none
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


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: metropolyst-theme.with(
/// config-info(
/// title: [Title],
/// logo: emoji.city,
/// ),
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
    config-page(fill: self.store.main-background-color),
  )
  let info = self.info + args.named()
  let body = {
    set text(
      fill: self.store.main-text-color,
      font: self.store.title-font,
    )
    set std.align(horizon)
    block(
      width: 100%,
      inset: 2em,
      {
        components.left-and-right(
          {
            text(
              size: self.store.title-size,
              weight: self.store.title-weight,
              info.title,
            )
            if info.subtitle != none {
              // Tight spacing between title and subtitle (like original Metropolis)
              v(-0.4em)
              text(
                size: self.store.subtitle-size,
                weight: self.store.subtitle-weight,
                info.subtitle,
              )
            }
          },
          text(
            size: self.store.logo-size,
            utils.call-or-display(self, info.logo),
          ),
        )
        // Spacing before separator line
        v(0.8em)
        line(length: 100%, stroke: 0.4pt + self.store.line-separator-color)
        set text(
          size: self.store.author-size,
          weight: self.store.author-weight,
        )
        // Spacing matched to original Metropolis
        if info.author != none {
          block(above: 2.5em, below: 0em, info.author)
        }
        if info.date != none {
          block(
            above: 1.0em,
            below: 0em,
            text(
              size: self.store.date-size,
              weight: self.store.date-weight,
              utils.display-info-date(self),
            ),
          )
        }
        if info.institution != none {
          block(
            above: 1.4em,
            below: 0em,
            text(
              size: self.store.institution-size,
              weight: self.store.institution-weight,
              info.institution,
            ),
          )
        }
        if extra != none {
          block(
            above: 1.0em,
            below: 0em,
            text(
              size: self.store.extra-size,
              weight: self.store.extra-weight,
              extra,
            ),
          )
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
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    set text(
      size: self.store.section-size,
      font: self.store.section-font,
      weight: self.store.section-weight,
    )
    set text(fill: self.store.main-text-color)
    stack(
      dir: ttb,
      spacing: 1em,
      utils.display-current-heading(level: level, numbered: numbered),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(
          height: 2pt,
          self.store.progress-bar-color,
          self.store.progress-bar-background,
        ),
      ),
    )
    body
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.store.main-background-color),
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
    config-page(fill: self.store.focus-background-color, margin: 2em),
  )
  set text(
    fill: self.store.focus-text-color,
    size: self.store.focus-size,
    font: self.store.focus-font,
    weight: self.store.focus-weight,
  )
  touying-slide(self: self, config: config, std.align(align, body))
})


/// Touying metropolyst theme - A highly configurable variant of Metropolis.
///
/// Example:
///
/// ```typst
/// #show: metropolyst-theme.with(
///   aspect-ratio: "16-9",
///   header-size: 1.5em,
///   header-weight: "bold",
///   // Change the accent color for the whole theme
///   accent-color: rgb("#0077b6"),
/// )
/// ```
///
/// Example with individual accent color overrides:
///
/// ```typst
/// #show: metropolyst-theme.with(
///   aspect-ratio: "16-9",
///   // Set main accent color (affects all accent elements by default)
///   accent-color: rgb("#e63946"),
///   // Override specific accent color uses
///   hyperlink-color: rgb("#0077b6"),  // Blue links
///   line-separator-color: rgb("#2a9d8f"),  // Teal separator
/// )
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
///
/// The default colors (can be overridden with config-colors):
///
/// ```typ
/// config-colors(
///   primary: rgb("#eb811b"),       // Set by accent-color
///   primary-light: rgb("#d6c6b7"), // Set by progress-bar-background
///   secondary: rgb("#23373b"),
///   neutral-lightest: rgb("#fafafa"),
///   neutral-dark: rgb("#23373b"),
///   neutral-darkest: rgb("#23373b"),
/// )
/// ```
///
/// Font configuration parameters:
/// - font: Main font used throughout the theme (default: "Fira Sans")
///   This serves as the default for all other font options below
/// - header-font, header-size, header-weight: Controls slide header appearance (defaults to font)
/// - footer-font, footer-size, footer-weight: Controls footer appearance (defaults to font)
/// - title-font, title-size, title-weight: Controls main title on title slide (defaults to font)
/// - subtitle-size, subtitle-weight: Controls subtitle on title slide
/// - author-size, author-weight: Controls author text
/// - date-size, date-weight: Controls date text
/// - institution-size, institution-weight: Controls institution text
/// - extra-size, extra-weight: Controls extra text on title slide
/// - logo-size: Controls logo size on title slide
/// - section-font, section-size, section-weight: Controls section slide text (defaults to font)
/// - focus-font, focus-size, focus-weight: Controls focus slide text (defaults to font)
///
/// Accent color configuration:
/// - accent-color: Main accent color used throughout the theme (default: orange #eb811b)
///   This serves as the default for all other accent color options below.
///   Used for alert text (#alert[...]). Bold text (*...*) inherits normal text color.
/// - hyperlink-color: Color for hyperlinks (defaults to accent-color)
/// - line-separator-color: Color for line separators like on the title slide (defaults to accent-color)
/// - progress-bar-color: Color for progress bars in footer and section slides (defaults to accent-color)
/// - progress-bar-background: Background color for progress bars (default: #d6c6b7). Set to `auto` to derive from accent-color.
/// - header-background-color: Background color for the slide header containing titles (defaults to #23373b)
/// - focus-background-color: Background color for focus slides (defaults to header-background-color when auto)
/// - main-background-color: Background color for slides, title slides, and section slides (default: #fafafa)
/// - main-text-color: Text color for body text, title slides, and section slides (default: #23373b)
/// - header-text-color: Text color for slide headers (defaults to main-background-color when auto)
/// - focus-text-color: Text color for focus slides (defaults to main-background-color when auto)
/// - footer-text-color: Text color for slide footers (defaults to main-text-color when auto)
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
#let metropolyst-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  header-right: self => self.info.logo,
  footer: none,
  footer-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  footer-progress: false,
  // Font configuration options - matched to original Metropolis beamer theme
  // Main font that cascades to all elements (can be overridden individually)
  font: ("Fira Sans",),
  // Frame titles use \large size (1.2x \normalsize), regular weight
  header-font: auto,
  header-size: 1.2em,
  header-weight: "regular",
  // Footer uses \scriptsize
  footer-font: auto,
  footer-size: 0.6em,
  footer-weight: "regular",
  // Title slide uses \Large for title, \large for subtitle
  title-font: auto,
  title-size: 1.4em,
  title-weight: "regular",
  subtitle-size: 1.0em,
  subtitle-weight: "light",
  // Author/date/institution use \small with light weight
  author-size: 0.8em,
  author-weight: "light",
  date-size: 0.8em,
  date-weight: "light",
  institution-size: 0.8em,
  institution-weight: "light",
  extra-size: 0.8em,
  extra-weight: "light",
  logo-size: 2em,
  // Section pages use \Large
  section-font: auto,
  section-size: 1.4em,
  section-weight: "regular",
  // Focus/standout slides use \Large
  focus-font: auto,
  focus-size: 1.4em,
  focus-weight: "regular",
  // Accent color configuration
  accent-color: rgb("#eb811b"),
  hyperlink-color: auto,
  line-separator-color: auto,
  progress-bar-color: auto,
  progress-bar-background: rgb("#d6c6b7"),
  header-background-color: auto,
  focus-background-color: auto,
  // Background and text color configuration
  main-background-color: rgb("#fafafa"),
  main-text-color: rgb("#23373b"),
  header-text-color: auto,
  focus-text-color: auto,
  footer-text-color: auto,
  ..args,
  body,
) = {
  // Resolve auto values for fonts (cascade from main font)
  let resolved-header-font = if header-font == auto { font } else { header-font }
  let resolved-footer-font = if footer-font == auto { font } else { footer-font }
  let resolved-title-font = if title-font == auto { font } else { title-font }
  let resolved-section-font = if section-font == auto { font } else { section-font }
  let resolved-focus-font = if focus-font == auto { font } else { focus-font }
  // Resolve auto values for accent colors
  let resolved-hyperlink-color = if hyperlink-color == auto { accent-color } else { hyperlink-color }
  let resolved-line-separator-color = if line-separator-color == auto { accent-color } else { line-separator-color }
  let resolved-progress-bar-color = if progress-bar-color == auto { accent-color } else { progress-bar-color }
  // Derive progress bar background from accent color: desaturate heavily and lighten
  // This mimics the original Metropolis relationship between orange #eb811b and tan #d6c6b7
  let resolved-progress-bar-background = if progress-bar-background == auto {
    accent-color.desaturate(70%).lighten(55%)
  } else { progress-bar-background }
  let resolved-header-background-color = if header-background-color == auto { rgb("#23373b") } else {
    header-background-color
  }
  let resolved-focus-background-color = if focus-background-color == auto { resolved-header-background-color } else {
    focus-background-color
  }
  // Resolve background and text colors
  let resolved-header-text-color = if header-text-color == auto { main-background-color } else { header-text-color }
  let resolved-focus-text-color = if focus-text-color == auto { main-background-color } else { focus-text-color }
  let resolved-footer-text-color = if footer-text-color == auto { main-text-color } else { footer-text-color }
  set text(size: 20pt, font: font, weight: "light", stretch: 100%)
  set strong(delta: 100)

  // Style hyperlinks with configurable color
  show link: it => text(fill: resolved-hyperlink-color, it)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3.8em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      // Match original Metropolis: bold text inherits normal color, only alert uses accent
      show-strong-with-alert: false,
    ),
    config-methods(
      alert: (self: none, it) => text(fill: self.colors.primary, it),
    ),
    config-colors(
      primary: accent-color,
      primary-light: resolved-progress-bar-background,
      secondary: rgb("#23373b"),
      neutral-lightest: rgb("#fafafa"),
      neutral-dark: rgb("#23373b"),
      neutral-darkest: rgb("#23373b"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      header-right: header-right,
      footer: footer,
      footer-right: footer-right,
      footer-progress: footer-progress,
      // Accent color configuration
      hyperlink-color: resolved-hyperlink-color,
      line-separator-color: resolved-line-separator-color,
      progress-bar-color: resolved-progress-bar-color,
      progress-bar-background: resolved-progress-bar-background,
      header-background-color: resolved-header-background-color,
      focus-background-color: resolved-focus-background-color,
      // Background and text colors
      main-background-color: main-background-color,
      main-text-color: main-text-color,
      header-text-color: resolved-header-text-color,
      focus-text-color: resolved-focus-text-color,
      footer-text-color: resolved-footer-text-color,
      // Store font configuration (using resolved values)
      header-font: resolved-header-font,
      header-size: header-size,
      header-weight: header-weight,
      footer-font: resolved-footer-font,
      footer-size: footer-size,
      footer-weight: footer-weight,
      title-font: resolved-title-font,
      title-size: title-size,
      title-weight: title-weight,
      subtitle-size: subtitle-size,
      subtitle-weight: subtitle-weight,
      author-size: author-size,
      author-weight: author-weight,
      date-size: date-size,
      date-weight: date-weight,
      institution-size: institution-size,
      institution-weight: institution-weight,
      extra-size: extra-size,
      extra-weight: extra-weight,
      logo-size: logo-size,
      section-font: resolved-section-font,
      section-size: section-size,
      section-weight: section-weight,
      focus-font: resolved-focus-font,
      focus-size: focus-size,
      focus-weight: focus-weight,
    ),
    ..args,
  )

  body
}
