// Touying Endfield Theme
// This theme is based on touying theme Dewdrop and inspired by the art style of Arknights: Endfield, a video game by Hypergryph. 
// By Leo Li <https://github.com/leostudiooo>

#import "@preview/touying:0.6.1": *

#let _typst-builtin-repeat = repeat

#let endfield-header(self) = {
  if self.store.navigation == "sidebar" {
    place(
      left + top,
      {
        show: block.with(
          width: self.store.sidebar.width - 1em,
          inset: (1em),
          fill: self.colors.neutral-dark.darken(50%),
          height: 24em, // hack to make it just above footer: 24em - 0.5em x 2 (padding) - 0.8em (footer height) = 22.2em
        )
        // v(4em)
        set align(left)
        set par(justify: false)
        set text(size: .9em)
        components.custom-progressive-outline(
          self: self,
          level: auto,
          alpha: self.store.alpha,
          text-fill: (self.colors.primary, self.colors.neutral-lightest),
          text-size: (1em, .9em),
          vspace: (- .2em,),
          indent: (0em, self.store.sidebar.at("indent", default: .5em)),
          fill: (
            self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),
          ),
          filled: (self.store.sidebar.at("filled", default: false),),
          paged: (self.store.sidebar.at("paged", default: false),),
          short-heading: self.store.sidebar.at("short-heading", default: true),
        )
      },
    )
  } else if self.store.navigation == "mini-slides" {
    block(
      fill: self.colors.neutral-dark.darken(50%),
      height: self.store.mini-slides.height - 1em,
      components.mini-slides(
        self: self,
        fill: self.colors.primary,
        alpha: self.store.alpha,
        display-section: self.store.mini-slides.at(
          "display-section",
          default: false,
        ),
        display-subsection: self.store.mini-slides.at(
          "display-subsection",
          default: true,
        ),
        linebreaks: self.store.mini-slides.at("linebreaks", default: true),
        short-heading: self.store.mini-slides.at("short-heading", default: true),
      ),
    )
    v(1em)
  }
}
}

#let endfield-footer(self) = {
  set align(bottom)
  set text(size: 0.8em)
  stack(
    dir: ttb,
    if self.store.navigation == "sidebar" {
        line(stroke: .2em + self.colors.primary, length: 100%)
    } else {
      stack(
        dir: ltr,
        line(stroke: .2em + self.colors.neutral-dark.darken(50%), length: 2em),
        line(stroke: .2em + cmyk(100%, 0%, 0%, 0%), length: 2em),
        line(stroke: .2em + cmyk(0%, 100%, 0%, 0%), length: 2em),
        line(stroke: .2em + self.colors.primary, length: 100% - 2em * 3), // to fill the rest
      )
    },
    block(
      fill: self.colors.neutral-dark.darken(50%),
      width: 100%,
      inset: .5em,
      components.left-and-right(
        text(
          // fill: if self.store.navigation == "sidebar" { self.colors.neutral-light } else { self.colors.neutral-darker },
          fill: self.colors.neutral-light,
          utils.call-or-display(
            self,
            self.store.footer,
          ),
        ),
        block(fill: self.colors.neutral-dark.darken(20%), outset: .5em, text(
          fill: self.colors.neutral-light,
          utils.call-or-display(
            self,
            self.store.footer-right,
          ),
        )),
      ),
    ),
  )
}

/// Default slide function for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
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
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(
      header: endfield-header,
      footer: endfield-footer,
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


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: endfield-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
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
    config-page(margin: 0em),
  )
  let info = self.info + args.named()
  let body = {
    set page(margin: 2em)
    set text(fill: self.colors.neutral-darker)
    set align(left + horizon)
    block(
      width: 100%,
      inset: 1em, // and page margin total 3em, basically a trick to make the footnote align well
      {
        block(
          fill: self.colors.neutral-dark.darken(50%),
          width: 100%,
          // inset: (y: 1em,),
          stack(
            dir: ltr,
            spacing: 1em,
            block(
              fill: self.colors.primary,
              inset: 0em,
              outset: 0em,
              width: 0.5em,
              height: self.store.title-height,
            ),
            text(size: 1.3em, fill: self.colors.neutral-lightest.lighten(40%), text(
              weight: "black",
              info.title,
            ))
              + (
                if info.subtitle != none {
                  linebreak()
                  text(size: 0.9em, fill: self.colors.neutral-lightest, info.subtitle)
                }
              ),
          ),
        )
        set text(size: .8em)

        if info.author != none {
          block(spacing: 1em, info.author)
        }
        v(1em)
        if info.date != none {
          block(spacing: 1em, text(utils.display-info-date(self)))
        }
        set text(size: .8em)
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


/// Outline slide for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): The title of the slide. Default is `utils.i18n-outline-title`.
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      footer: endfield-footer,
      header: endfield-header,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.neutral-darkest,
        weight: "bold",
        utils.call-or-display(self, title),
      ),
      text(
        fill: self.colors.neutral-darkest,
        outline(title: none, indent: 1em, depth: self.slide-level, ..args),
      ),
    ),
  )
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): The title of the slide. Default is `utils.i18n-outline-title`.
///
/// - body (array): The contents of the slide.
#let new-section-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      header: endfield-header,
      footer: endfield-footer,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.neutral-darkest,
        weight: "bold",
        utils.call-or-display(self, title),
      ),
      text(
        fill: self.colors.neutral-darkest,
        components.progressive-outline(
          alpha: self.store.alpha,
          title: none,
          indent: 1em,
          depth: self.slide-level,
          ..args,
        ),
      ),
    ),
  )
})

/// Font configuration helper that can be passed to the theme
///
/// Example:
/// ```typst
/// #show: endfield-theme.with(
///   config-fonts(
///     cjk-font-family: ("Source Han Sans", "Noto Sans CJK"),
///     lang: "zh",
///     region: "cn",
///   ),
/// )
/// ```
#let config-fonts(
  cjk-font-family: (
    "HarmonyOS Sans",
  ),
  latin-font-family: (
    "HarmonyOS Sans",
  ),
  lang: "en",
  region: "us",
) = config-store(
  fonts: (
    cjk: cjk-font-family,
    latin: latin-font-family,
    combined: latin-font-family + cjk-font-family,
  ),
  text-lang: lang,
  text-region: region,
)

/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 2em),
  )
  set text(fill: self.colors.neutral-darker, size: 2em, weight: "bold")
  touying-slide(self: self, config: config, align(horizon + center, body))
})


/// Touying endfield theme.
///
/// Example:
///
/// ```typst
/// #show: endfield-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   neutral-darkest: rgb("#191919"),
///   neutral-dark: rgb("#7C7C7C"),
///   neutral: rgb("#828282"),
///   neutral-light: rgb("#D9D9D9"),
///   neutral-lightest: rgb("#E6E6E6"),
///   primary: rgb("FFFA01"),
/// )
/// ```
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - navigation (string): The navigation of the slides. You can choose from `"sidebar"`, `"mini-slides"`, and `none`. Default is `"sidebar"`.
///
/// - sidebar (dictionary): The configuration of the sidebar. You can set the width, filled, numbered, indent, and short-heading of the sidebar. Default is `(width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true)`.
///   - width (string): The width of the sidebar.
///   - filled (boolean): Whether the outline in the sidebar is filled.
///   - numbered (boolean): Whether the outline in the sidebar is numbered.
///   - indent (length): The indent of the outline in the sidebar.
///   - short-heading (boolean): Whether the outline in the sidebar is short.
///
/// - mini-slides (dictionary): The configuration of the mini-slides. You can set the height, x, display-section, display-subsection, and short-heading of the mini-slides. Default is `(height: 4em, x: 2em, display-section: false, display-subsection: true, linebreaks: true, short-heading: true)`.
///   - height (length): The height of the mini-slides.
///   - x (length): The x position of the mini-slides.
///   - display-section (boolean): Whether the slides of sections are displayed in the mini-slides.
///   - display-subsection (boolean): Whether the slides of subsections are displayed in the mini-slides.
///   - linebreaks (boolean): Whether line breaks are in between links for sections and subsections in the mini-slides.
///   - short-heading (boolean): Whether the mini-slides are short. Default is `true`.
///
/// - footer (content, function): The footer of the slides. Default is `none`.
///
/// - footer-right (content, function): The right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - primary (color): The primary color of the slides. Default is `rgb("#0c4842")`.
///
/// - alpha (fraction, float): The alpha of transparency. Default is `60%`.
///
/// - outline-title (content, function): The title of the outline. Default is `utils.i18n-outline-title`.
///
/// - subslide-preamble (content, function): The preamble of the subslide. Default is `self => block(text(1.2em, weight: "bold", fill: self.colors.primary, utils.display-current-heading(depth: self.slide-level)))`.
#let endfield-theme(
  aspect-ratio: "16-9",
  navigation: "none",
  sidebar: (
    width: 10em,
    filled: false,
    numbered: false,
    indent: .5em,
    short-heading: true,
  ),
  mini-slides: (
    height: 4em,
    x: 2em,
    display-section: false,
    display-subsection: true,
    linebreaks: true,
    short-heading: true,
  ),
  footer: none,
  footer-right: context text(utils.slide-counter.display(), fill: rgb("#FFFA01"), weight: "black")
    + text(" / " + utils.last-slide-number, size: 0.618em),
  primary: rgb("#FFFA01"),
  alpha: 40%,
  subslide-preamble: self => block(
    text(
      1.2em,
      weight: "bold",
      fill: self.colors.primary,
      utils.display-current-heading(depth: self.slide-level, style: auto),
    ),
  ),
  ..args,
  body,
) = {
  sidebar = utils.merge-dicts(
    (
      width: 10em,
      filled: false,
      numbered: false,
      indent: .5em,
      short-heading: true,
    ),
    sidebar,
  )
  mini-slides = utils.merge-dicts(
    (
      height: 3em,
      x: 2em,
      display-section: false,
      display-subsection: true,
      linebreaks: true,
      short-heading: true,
    ),
    mini-slides,
  )
  
  // Extract font configuration from config-fonts if provided
  // config-fonts returns config-store which is in args.pos()
  let font-config = args.pos().find(item => {
    type(item) == dictionary and "fonts" in item
  })
  
  let fonts = if font-config != none {
    font-config.fonts
  } else {
    (
      cjk: ("HarmonyOS Sans",),
      latin: ("HarmonyOS Sans",),
      combined: ("HarmonyOS Sans",),
    )
  }
  
  let text-lang = if font-config != none {
    font-config.at("text-lang", default: "en")
  } else {
    "en"
  }
  
  let text-region = if font-config != none {
    font-config.at("text-region", default: "us")
  } else {
    "us"
  }
  
  set text(size: 20pt, font: fonts.combined, lang: text-lang, region: text-region)
  set par(justify: false)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      fill: gradient.linear(angle: 90deg, rgb("#e6e6e6").lighten(20%), rgb("#e6e6e6").darken(20%)),
      // fill: rgb("#E6E6E6"),
      background: place(bottom, image("contour_map.svg", width: 100%)),
      header-ascent: 0em,
      footer-descent: 0em,
      margin: if navigation == "sidebar" {
        (top: 2em, bottom: 2em, left: sidebar.width)
      } else if navigation == "mini-slides" {
        (top: mini-slides.height, bottom: 2em, x: mini-slides.x)
      } else {
        (top: 2em, bottom: 2em, x: mini-slides.x)
      },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          fill: self.colors.neutral-darkest,
          font: self.store.fonts.combined,
          lang: self.store.text-lang,
          region: self.store.text-region,
        )
        show heading: set text(fill: self.colors.neutral-darkest)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-darkest: rgb("#191919"),
      neutral-dark: rgb("#7C7C7C"),
      neutral: rgb("#828282"),
      neutral-light: rgb("#D9D9D9"),
      neutral-lightest: rgb("#E6E6E6"),
      primary: primary,
    ),
    // save the variables for later use
    config-store(
      navigation: navigation,
      sidebar: sidebar,
      mini-slides: mini-slides,
      footer: footer,
      footer-right: footer-right,
      alpha: alpha,
      subslide-preamble: subslide-preamble,
      title-height: 4em,
      fonts: fonts,
      text-lang: text-lang,
      text-region: text-region,
    ),
    ..args,
  )

  body
}
