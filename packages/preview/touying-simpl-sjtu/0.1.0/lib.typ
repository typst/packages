// This theme is inspired by https://github.com/zbowang/BeamerTheme and https://github.com/touying-typ/touying/blob/main/themes/dewdrop.typ

#import "@preview/touying:0.6.1": *

#let _typst-builtin-repeat = repeat

#let mini-slides(
  self: none,
  fill: rgb("000000"),
  alpha: 60%,
  display-section: false,
  display-subsection: true,
  linebreaks: true,
  short-heading: true,
) = (
  context {
    let headings = query(heading.where(level: 1).or(heading.where(level: 2)))
    let sections = headings.filter(it => it.level == 1)
    if sections == () {
      return
    }
    let first-page = sections.at(0).location().page()
    headings = headings.filter(it => it.location().page() >= first-page)
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
    ))
    let current-page = here().page()
    let current-index = sections.filter(it => it.location().page() <= current-page).len() - 1
    let cols = ()
    let col = ()
    for (hd, next-hd) in headings.zip(headings.slice(1) + (none,)) {
      if hd.outlined == false {
        continue
      }

      let next-page = if next-hd != none {
        next-hd.location().page()
      } else {
        calc.inf
      }
      if hd.level == 1 {
        if col != () {
          cols.push(align(left, col.sum()))
          col = ()
        }
        col.push({
          let body = if short-heading {
            utils.short-heading(self: self, hd)
          } else {
            hd.body
          }
          [#link(hd.location(), body)<touying-link>]
          linebreak()
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-section {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-section and display-subsection and linebreaks {
            linebreak()
          }
        })
      } else {
        col.push({
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-subsection {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-subsection and linebreaks {
            linebreak()
          }
        })
      }
    }
    if col != () {
      cols.push(align(left, col.sum()))
      col = ()
    }
    if current-index < 0 or current-index >= cols.len() {
      cols = cols.map(body => text(fill: fill, body))
    } else {
      cols = cols
        .enumerate()
        .map(pair => {
          let (idx, body) = pair
          if idx == current-index {
            text(fill: fill, body)
          } else {
            text(fill: utils.update-alpha(fill, alpha), body)
          }
        })
    }
    set align(top)
    show: block.with(inset: (top: .5em, x: 2em))
    show linebreak: it => it + v(-1em)
    set text(size: .7em)
    grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
  }
)

#let sjtu-header(self) = {
  if self.store.navigation == "sidebar" {
    place(right + top, {
      v(4em)
      show: block.with(width: self.store.sidebar.width, inset: (x: 1em))
      set align(left)
      set par(justify: false)
      set text(size: .9em)
      components.custom-progressive-outline(
        self: self,
        level: auto,
        alpha: self.store.alpha,
        text-fill: (self.colors.primary, self.colors.neutral-darkest),
        text-size: (1em, .9em),
        vspace: (-.2em,),
        indent: (0em, self.store.sidebar.at("indent", default: .5em)),
        fill: (self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),),
        filled: (self.store.sidebar.at("filled", default: false),),
        paged: (self.store.sidebar.at("paged", default: false),),
        short-heading: self.store.sidebar.at("short-heading", default: true),
      )
    })
  } else if self.store.navigation == "mini-slides" {
    mini-slides(
      self: self,
      fill: self.colors.primary,
      alpha: self.store.alpha,
      display-section: self.store.mini-slides.at("display-section", default: false),
      display-subsection: self.store.mini-slides.at("display-subsection", default: true),
      linebreaks: self.store.mini-slides.at("linebreaks", default: true),
      short-heading: self.store.mini-slides.at("short-heading", default: true),
    )
    grid(
      inset: (x: 1.9em),
      rows: (auto, auto, auto),
      row-gutter: 15%,
      grid(
        columns: (75%, 25%),
        align(left + horizon, utils.display-current-heading(depth: self.slide-level, style: auto)),
        align(right + horizon, image("vi/sjtu-vi-sjtugate.png", height: 0.9cm)),
      ),
      align(center + horizon, line(length: 100%, stroke: (paint: self.colors.primary, thickness: 1.5pt))),
    )
  } else {
    grid(
      inset: (x: 1.9em),
      rows: (auto, auto),
      row-gutter: 15%,
      grid(
        columns: (75%, 25%),
        align(left + horizon, utils.display-current-heading(depth: self.slide-level, style: auto)),
        align(right + horizon, image("vi/sjtu-vi-sjtugate.png")),
      ),
      align(center + horizon, line(length: 100%, stroke: (paint: self.colors.primary, thickness: 1.5pt))),
    )
  }
}

#let sjtu-footer(self) = {
  set align(bottom)
  set text(size: if self.appendix { 0em } else { 0.8em })
  show: pad.with(.5em)
  components.left-and-right(
    block(inset: (left: 0.5em, bottom: 0.5em), text(
      fill: self.colors.neutral-darkest.lighten(40%),
      size: 0.7em,
      utils.call-or-display(self, self.store.footer),
    )),
    block(inset: (right: 0.5em, bottom: 0.5em), text(
      fill: self.colors.neutral-darkest.lighten(20%),
      utils.call-or-display(self, self.store.footer-right),
    )),
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
    config-page(header: sjtu-header, footer: sjtu-footer, margin: (x: 2.5cm)),
    config-common(subslide-preamble: self.store.subslide-preamble),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: sjtu-theme.with(
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
  self = utils.merge-dicts(self, config, config-common(freeze-slide-counter: true), config-page(
    header: align(right + horizon, block(inset: (right: 0.3em, top: 0.3em), image("vi/sjtu-vi-logo.png"))),
    margin: (top: 3.5em, bottom: 1.5em, x: 2em),
  ))
  let info = self.info + args.named()
  let body = {
    set par(leading: 1.6em)
    set align(center + horizon)
    set page(background: align(left + bottom, image("vi/sjtu-vi-sjtubg.png", width: if self.show-notes-on-second-screen
      == right { 50% } else { 100% })))
    block(width: 100%, inset: 3em, {
      block(
        if info.subtitle == none {
          linebreak()
        }
          + text(
            size: if info.subtitle == none { 2em } else { 1.7em },
            fill: self.colors.primary,
            weight: "bold",
            info.title,
          )
          + (
            if info.subtitle != none {
              linebreak()
              text(
                size: 1.3em,
                fill: self.colors.primary,
                weight: "bold",
                info.subtitle,
              )
            }
          ),
      )
      v(1fr)
      set text(size: 1.1em, fill: self.colors.neutral-dark, weight: "medium")
      if info.author != none {
        block(spacing: 1em, info.author)
      }
      v(1em)
      if info.date != none {
        block(spacing: 1em, utils.display-info-date(self))
      }
      set text(size: .8em)
      if info.institution != none {
        block(spacing: 1em, info.institution)
      }
      if extra != none {
        block(spacing: 1em, extra)
      }
      v(0.2fr)
    })
  }
  touying-slide(self: self, body)
})

#let title-slide-red(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config, config-common(freeze-slide-counter: true), config-page(margin: (
    top: 3.5em,
    bottom: 0em,
    x: 0em,
  )))
  let info = self.info + args.named()
  let body = {
    set par(leading: 1.6em)
    set align(left + bottom)
    set page(background: align(left, image("vi/sjtu-vi-sjtuphoto.jpg")))
    line(length: 100%, stroke: (paint: self.colors.neutral-light, thickness: 1.5pt))
    v(-1.15em)
    block(fill: self.colors.primary, width: 100%, {
      block(
        inset: (y: 1.6em, x: 3em),
        text(
          size: 1.6em,
          fill: self.colors.neutral-light,
          weight: "bold",
          info.title,
        )
          + (
            if info.subtitle != none {
              linebreak()
              text(
                size: 1.2em,
                fill: self.colors.neutral-light,
                weight: "bold",
                info.subtitle,
              )
            }
          ),
      )
      grid(
        columns: (65%, 35%),
        block({
          set text(size: 1.1em, fill: self.colors.neutral-light, weight: "semibold")
          if info.author != none {
            block(inset: (x: 2.8em), spacing: 0.8em, info.author)
          }
          if info.date != none {
            block(inset: (x: 2.8em), spacing: 0.8em, utils.display-info-date(self))
          }
          set text(size: .8em)
          if info.institution != none {
            block(inset: (x: 3.4em), spacing: 0.8em, info.institution)
          }
          v(0.5em)
        }),
        align(right, block(inset: (x: 2em), image("vi/sjtu-vi-logo-white.png"))),
      )
      v(2em)
    })
  }
  touying-slide(self: self, body)
})


/// Outline slide for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): The title of the slide. Default is `utils.i18n-outline-title`.
#let outline-slide(config: (:), title: utils.i18n-outline-title, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(footer: sjtu-footer, margin: (
    top: 3em,
  )))
  touying-slide(self: self, config: config, components.adaptive-columns(
    start: text(1.7em, fill: self.colors.primary, weight: "bold", utils.call-or-display(self, title)),
    text(fill: self.colors.neutral-darkest, outline(title: none, indent: 1em, depth: self.slide-level, ..args)),
  ))
})


#let new-section-mini-slides(
  self: none,
  fill: rgb("000000"),
  alpha: 60%,
  display-section: false,
  display-subsection: true,
  linebreaks: true,
  short-heading: true,
) = (
  context {
    let headings = query(heading.where(level: 1).or(heading.where(level: 2)))
    let sections = headings.filter(it => it.level == 1)
    if sections == () {
      return
    }
    let first-page = sections.at(0).location().page()
    headings = headings.filter(it => it.location().page() >= first-page)
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
    ))
    let current-page = here().page()
    let current-index = sections.filter(it => it.location().page() <= current-page).len() - 1
    let cols = ()
    let col = ()
    for (hd, next-hd) in headings.zip(headings.slice(1) + (none,)) {
      if hd.outlined == false {
        continue
      }

      let next-page = if next-hd != none {
        next-hd.location().page()
      } else {
        calc.inf
      }
      if hd.level == 1 {
        if col != () {
          cols.push(align(left, col.sum()))
          col = ()
        }
        col.push({
          let body = if short-heading {
            utils.short-heading(self: self, hd) + linebreak()
          } else {
            hd.body + linebreak()
          }
          [#link(hd.location(), body)<touying-link>]
          linebreak()
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-section {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-section and display-subsection and linebreaks {
            linebreak()
          }
        })
      } else {
        col.push({
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-subsection {
              if hd.level == 2 {
                let next-slide-page = if slides.len() > 0 {
                  slides.at(0).location().page()
                } else {
                  calc.inf
                }
                if slide.location().page() <= current-page {
                  [#link(slide.location(), text(
                      size: .7em,
                      v(0em) + box(height: 0.8em, sym.circle.filled) + "  " + hd.body,
                    ))]
                } else {
                  [#link(slide.location(), text(size: .7em, v(0em) + box(height: 0.8em, sym.circle) + "  " + hd.body))]
                }
              }
            }
          }
          if display-subsection and linebreaks {
            linebreak()
          }
        })
      }
    }
    if col != () {
      cols.push(align(left, col.sum()))
      col = ()
    }
    if current-index < 0 or current-index >= cols.len() {
      cols = cols.map(body => text(fill: fill, body))
    } else {
      cols = cols
        .enumerate()
        .map(pair => {
          let (idx, body) = pair
          if idx == current-index {
            text(fill: fill, size: 1.1em, body)
          } else {
            text(fill: utils.update-alpha(fill, alpha), body)
          }
        })
    }
    set align(top)
    show: block.with(inset: (top: .5em, x: 2em))
    show linebreak: it => it + v(-1em)
    set text(size: .7em)
    grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
  }
)

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): The title of the slide. Default is `utils.i18n-outline-title`.
///
/// - body (array): The contents of the slide.
#let new-section-slide(config: (:), title: utils.i18n-outline-title, ..args, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(
    header: grid(
      inset: (x: 1.9em),
      rows: (auto, auto),
      row-gutter: 15%,
      grid(
        columns: (1fr, 35%),
        align(left + horizon, text(size: 1.9em, utils.display-current-heading(depth: self.slide-level, style: auto))),
        align(right + horizon, image("vi/sjtu-vi-sjtugate.png", height: 1.5cm)),
      ),
      v(-2cm),
      align(center + horizon, line(length: 100%, stroke: (paint: self.colors.primary, thickness: 1.5pt))),
    ),
    footer: sjtu-footer,
    margin: (top: 8cm, left: 0cm),
  ))
  touying-slide(self: self, config: config, components.adaptive-columns(text(
    hyphenate: false,
    size: 1.2em,
    fill: self.colors.neutral-darkest,
    new-section-mini-slides(
      self: self,
      fill: self.colors.primary,
      alpha: self.store.alpha,
      display-section: false,
      display-subsection: true,
      linebreaks: false,
      short-heading: true,
    ),
    // components.progressive-outline(
    //   alpha: self.store.alpha,
    //   title: none,
    //   indent: 1em,
    //   depth: self.slide-level,
    //   transform: (cover: false, alpha: 60%, ..args, it) => if cover {
    //     if it.level == 1 {
    //       text(utils.update-alpha(text.fill, alpha), h(2em) + it.element.body + v(0em))
    //     }
    //   } else {
    //     if it.level == 1 {
    //       text(weight: "semibold", fill: self.colors.primary, h(1.8em) + it.element.body + v(0em))
    //     } else {
    //       text(
    //         size: 0.8em,
    //         weight: "semibold",
    //         fill: self.colors.primary,
    //         h(3em) + "-  " + it.element.body + v(0em),
    //       )
    //     }
    //   },
    //   ..args,
    // ),
  )))
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(
    fill: self.colors.primary,
    margin: 2em,
  ))
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, config: config, align(horizon + center, body))
})


#let end-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true, new-section-slide-fn: none), config-page(
    margin: 2em,
  ))
  set text(fill: self.colors.primary, size: 1.65em, weight: "bold")
  let body = {
    set page(background: align(left + bottom, image("vi/sjtu-vi-sjtubg.png", width: if self.show-notes-on-second-screen
      == right { 50% } else { 100% })))
    block(width: 80%, grid(
      columns: (40%, 1fr),
      column-gutter: 0pt,
      image("vi/sjtu-vi-logo-ud.png"), body,
    ))
  }
  touying-slide(self: self, config: config, align(horizon + center, body))
})


#let end-slide-red(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(
    fill: self.colors.primary,
    margin: 2em,
  ))
  set text(fill: self.colors.primary, size: 1.75em, weight: "bold")
  let body = {
    set page(background: align(left, image("vi/sjtu-vi-end.png")))
    v(3.6em)
    body
  }
  touying-slide(self: self, config: config, align(top + center, body))
})

/// Touying sjtu theme.
///
/// Example:
///
/// ```typst
/// #show: sjtu-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   neutral-darkest: rgb("#000000"),
///   neutral-dark: rgb("#202020"),
///   neutral-light: rgb("#f3f3f3"),
///   neutral-lightest: rgb("#ffffff"),
///   primary: rgb("#0c4842"),
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
#let sjtu-theme(
  aspect-ratio: "16-9",
  navigation: "mini-slides",
  font: ("Libertinus Serif", "Noto Serif CJK SC"),
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
    linebreaks: false,
    short-heading: true,
  ),
  footer: none,
  footer-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  primary: rgb("#C9141E"), //#A51F38
  alpha: 40%,
  subslide-preamble: none,
  ..args,
  body,
) = {
  sidebar = utils.merge-dicts(
    (width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true),
    sidebar,
  )
  mini-slides = utils.merge-dicts(
    (height: 4em, x: 2em, display-section: false, display-subsection: true, linebreaks: true, short-heading: true),
    mini-slides,
  )
  set text(size: 18pt)
  set par(justify: true)

  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio, header-ascent: 1.5em, footer-descent: 0em, margin: if navigation
      == "sidebar" {
      (top: 2em, bottom: 1em, x: sidebar.width)
    } else if navigation == "mini-slides" {
      (top: if mini-slides.linebreaks { mini-slides.height } else { 5.5em }, bottom: 3em, x: mini-slides.x)
    } else {
      (top: 5em, bottom: 2em, x: mini-slides.x)
    }),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: font)
        show heading: set text(self.colors.primary)
        show outline.entry: set block(above: 1em)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-darkest: rgb("#000000"),
      neutral-dark: rgb("#202020"),
      neutral-light: rgb("#f3f3f3"),
      neutral-lightest: rgb("#ffffff"),
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
    ),
    ..args,
  )

  body
}
