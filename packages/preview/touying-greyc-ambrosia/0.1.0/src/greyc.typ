// GREYC theme.
// Author: Inspiros (Hoang-Nhat TRAN)
#import "@preview/touying:0.6.2": *

#import "assets.typ"
#import "colors.typ"
#import "core.typ": *
#import "components.typ" as greyc-components
#import "utils.typ" as greyc-utils
#import "footcite.typ"


#let greyc = box[
  #box(image(
    assets.asset-paths.logo-greyc.small,
    height: .7em,
  ))#h(.1em)#text(fill: colors.primary)[#strong("GREYC", delta: 200)]
]


#let _greyc-header(self) = {
  set std.align(top)
  grid(
    rows: (auto, auto),
    greyc-utils.call-or-display(self, self.store.header-a),
    greyc-utils.call-or-display(self, self.store.header-b),
  )
}


#let _greyc-footer(self) = {
  set text(size: .5em)
  set std.align(center + bottom)
  let footer = grid(
    rows: (auto, auto),
    greyc-utils.call-or-display(self, self.store.footer-a),
    if self.store.progress-bar {
      greyc-utils.call-or-display(
        self,
        components.progress-bar(height: 2pt, self.colors.primary.lighten(30%), self.colors.neutral-lightest),
      )
    },
  )
  block(
    breakable: false,
    {
      footer
      place(center + bottom, dy: -1.5em, float: false, {
        set text(size: 2em)
        greyc-utils.call-or-display(self, self.store.footer-b)
      })
    },
  )
}


/// Default slide function for the presentation.
///
/// - title (string): The title of the slide. Default is `auto`.
///
/// - subtitle (string): The subtitle of the slide. Default is `auto`.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (dictionary): The setting of the slide. You can use it to add some set/show rules for the slide.
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
/// - bodies (content): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  title: auto,
  subtitle: auto,
  header: auto,
  footer: auto,
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
  if title != auto {
    self.store.title = title
  }
  if subtitle != auto {
    self.store.subtitle = subtitle
  }
  if header != auto {
    self.store.header = header
  }
  if footer != auto {
    self.store.footer = footer
  }
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


#let _modern-title-slide(self: none, config: (:), ..args) = {
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 2em, right: 2em, top: auto, bottom: 1em),
    ),
    config,
  )
  self.store.title = none
  let info = self.info + args.named()
  info.logos = self.store.logos
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  info.emails = {
    let emails = if "emails" in info {
      info.emails
    } else if "email" in info {
      info.email
    } else {
      ()
    }
    if type(emails) == array {
      emails
    } else {
      (emails,)
    }
  }
  let body = {
    show: std.align.with(center + horizon)
    // logos
    if info.logos != none and info.logos.len() > 0 {
      block(
        width: 50%,
        inset: 0.1em,
        radius: 0.5em,
        grid(
          columns: (auto,) * info.logos.len(),
          rows: (2.5em,),
          column-gutter: 1em,
          row-gutter: 1em,
          ..if type(info.logos) == dictionary { info.logos.values() } else { info.logos }.map(
            logo => greyc-utils.call-or-display(self, logo),
          ),
        ),
      )
    }
    // title and subtitle
    let title-block = if self.store.flavor in ("stargazer", "darmstadt") {
      block(
        width: {
          let mapping = (
            stargazer: auto,
            darmstadt: 100%,
          )
          mapping.at(self.store.flavor)
        },
        fill: self.colors.primary,
        inset: 1.5em,
        radius: 0.5em,
        breakable: false,
        {
          text(size: 1.2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
          if info.subtitle != none {
            parbreak()
            text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
          }
        },
      )
    } else {
      block(
        width: 100%,
        fill: if self.store.flavor == "simple" { none } else { self.colors.neutral-lightest },
        inset: 1.5em,
        radius: 0.5em,
        breakable: false,
        {
          text(size: 1.2em, fill: self.colors.primary, weight: "bold", info.title)
          if info.subtitle != none {
            parbreak()
            text(size: 1.0em, fill: self.colors.primary, weight: "bold", info.subtitle)
          }
        },
      )
    }
    let title-container = if self.store.flavor in ("simple", "stargazer") {
      it => it
    } else {
      greyc-components.shadow
    }
    title-container(title-block)
    // authors
    grid(
      columns: (1fr,) * calc.min(info.authors.len(), 3),
      column-gutter: 1em,
      row-gutter: 1em,
      ..info.authors.map(author => text(fill: black, author)),
    )
    // institution
    if info.institution != none {
      v(0.25em)
      text(size: 0.7em, info.institution)
    }
    // emails
    if info.emails != none and info.emails != () {
      v(0.25em)
      grid(
        columns: (1fr,) * calc.min(info.emails.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..info.emails.map(e => text(font: "New Computer Modern Mono", size: 0.7em, e)),
      )
    }
    // date
    if info.date != none {
      v(0.25em)
      text(size: 0.7em, utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
}


/// Modern title slide.
#let modern-title-slide(config: (:), ..args) = touying-slide-wrapper(_modern-title-slide.with(config: config, ..args))


#let _legacy-title-slide(self: none, config: (:), ..args) = {
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 2em, right: 30%, top: 1em, bottom: 15%),
      header: none,
      footer: none,
    ),
    config,
  )
  self.store.title = none
  let info = self.info + args.named()
  info.logos = self.store.logos
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  info.emails = {
    let emails = if "emails" in info {
      info.emails
    } else if "email" in info {
      info.email
    } else {
      ()
    }
    if type(emails) == array {
      emails
    } else {
      (emails,)
    }
  }
  let body = {
    context {
      layout(size => {
        let ml
        let mt
        let mb
        if type(page.margin) == dictionary and "top" in page.margin and "left" in page.margin {
          ml = page.margin.left
          mt = page.margin.top
          mb = page.margin.bottom
        } else if page.margin == auto {
          ml = (page.width - size.width) / 2
          mt = (page.height - size.height) / 2
          mb = mt
        } else {
          ml = page.margin
          mt = page.margin
          mb = page.margin
        }
        // cover
        place(top + left, dx: -ml, dy: -mt, float: false, block(width: page.width, height: page.height)[
          #place(right + horizon, dx: 22%, dy: -1%)[
            #image(assets.asset-paths.cover-image, height: 140%, fit: "cover")
          ]
          #place(left + horizon)[
            #box(
              fill: gradient.linear(
                ..((self.colors.primary,) * 14),
                self.colors.primary.transparentize(50%),
                self.colors.primary.transparentize(100%),
              ),
              width: 80%,
              height: 100%,
            )
          ]
          #place(right + top, dx: 5%, dy: -7.5%)[
            #image(assets.asset-paths.cover-traits, height: 35%, fit: "cover")
          ]
        ])

        // logos
        place(dx: -ml / 2, dy: page.height * 80%, float: false, block(width: 80% * page.width, height: auto, {
          show: std.align.with(horizon)
          if info.logos != none and info.logos.len() > 0 {
            let logos = if type(info.logos) == dictionary { info.logos.values() } else { info.logos }.map(
              logo => greyc-utils.call-or-display(self, logo),
            )
            logos.insert(0, [])
            logos.insert(0, [])
            logos.insert(0, greyc-utils.call-or-display(self, if self.info.keys().contains("logo-light") {
              self.info.logo-light
            } else { self.info.logo }))
            block(
              width: 100%,
              grid(
                columns: (auto,) * logos.len(),
                rows: (2.5em,),
                column-gutter: 0.6em,
                ..logos,
              ),
            )
          }
        }))
      })
    }

    show: std.align.with(left + horizon)
    set par(
      leading: 0.65em,
      spacing: 0.7em,
    )
    set text(fill: self.colors.neutral-lightest)
    // title and subtitle
    text(size: 1.4em, fill: self.colors.neutral-lightest, weight: "extrabold", upper(info.title))
    if info.subtitle != none {
      parbreak()
      text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "semibold", info.subtitle)
    }
    // authors
    v(2em)
    grid(
      columns: (1fr,) * calc.min(info.authors.len(), 3),
      column-gutter: 1em,
      row-gutter: 1em,
      ..info.authors.map(author => text(weight: "bold", author)),
    )
    // institution
    if info.institution != none {
      v(0.5em)
      text(size: 0.7em, info.institution)
    }
    // emails
    if info.emails != none and info.emails != () {
      v(0.5em)
      grid(
        columns: (1fr,) * calc.min(info.emails.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..info.emails.map(e => text(font: "New Computer Modern Mono", size: 0.7em, e)),
      )
    }
    // date
    if info.date != none {
      v(0.5em)
      text(size: 0.7em, utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
}


/// Legacy title slide.
#let legacy-title-slide(config: (:), ..args) = touying-slide-wrapper(_legacy-title-slide.with(config: config, ..args))


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: ambrosia-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let title-slide(self: none, config: (:), ..args) = touying-slide-wrapper(self => {
  let mapping = (
    legacy: _legacy-title-slide,
    simple: _modern-title-slide,
    stargazer: _modern-title-slide,
    dewdrop: _modern-title-slide,
    cambridge: _modern-title-slide,
    darmstadt: _modern-title-slide,
  )
  assert(self.store.flavor in mapping, message: "Flavor '" + self.store.flavor + "' is not supported.")
  let title-slide-impl = mapping.at(self.store.flavor)
  title-slide-impl(
    self: self,
    config: config,
    ..args,
  )
})


/// Outline slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the outline. Default is `greyc-utils.i18n-outline-title`.
///
/// - level (int, none): is the level of the outline. Default is `none`.
///
/// - numbered (boolean): is whether the outline is numbered. Default is `true`.
#let outline-slide(
  config: (:),
  title: greyc-utils.i18n-outline-title,
  numbered: true,
  level: none,
  depth: 1,
  ..args,
) = touying-slide-wrapper(self => {
  let get-label = self => {
    std.label("touying-outline:" + str(here().page()))
  }
  self.store.title = self => {
    context {
      let target = get-label(self)
      if query(target).len() == 1 {
        [#link(target, title)<touying-link>]
      } else {
        [#link((page: here().page(), x: 0pt, y: 0pt), title)<touying-link>]
      }
    }
  }
  self.store.header-aa = self.store.title
  self.store.header-ab = none
  touying-slide(
    self: self,
    config: config,
    std.align(
      horizon,
      {
        {
          set heading(numbering: none)
          show heading: none
          std.heading(utils.call-or-display(self, title), level: 1, outlined: false, bookmarked: true)
        }
        (
          components.adaptive-columns(
            greyc-components.custom-outline(
              self: self,
              title: none,
              spacing: 1.2em,
              filter: hd => true,
              selector-filter: greyc-utils.before-appendix-filter,
              depth: depth,
              transform: (hd, it) => {
                set text(fill: self.colors.primary, weight: "bold") if hd.level == 1
                set text(fill: self.colors.primary) if hd.level > 1

                it
              },
              label: get-label,
            ),
          )
            + args.pos().sum(default: none)
        )
      },
    ),
  )
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (content, function): is the title of the section. The default is `greyc-utils.i18n-outline-title`.
///
/// - level (int): is the level of the heading. The default is `1`.
///
/// - numbered (boolean): is whether the heading is numbered. The default is `true`.
///
/// - body (none): is the body of the section. It will be passed by touying automatically.
#let new-section-slide(
  config: (:),
  title: greyc-utils.i18n-outline-title,
  level: 1,
  depth: 3,
  numbered: true,
  ..args,
  body,
) = touying-slide-wrapper(self => {
  let get-label = self => {
    std.label("touying-section-outline:" + str(here().page()))
  }
  if self.store.at("subtitle", default: none) != none {
    self.store.subtitle = self => {
      context {
        let target = get-label(self)
        if query(target).len() == 1 {
          [#link(target, title)<touying-link>]
        } else {
          let heading = greyc-utils.current-heading(depth: 1, level: 1, selector-filter: greyc-utils.appendix-filter)
          [#link(heading.location(), title)<touying-link>]
        }
      }
    }
  } else {
    self.store.title = title
  }
  self.store.header-aa = self.store.title
  self.store.header-ab = self.store.subtitle
  touying-slide(
    self: self,
    config: config,
    std.align(
      horizon,
      components.adaptive-columns(
        greyc-components.custom-outline(
          self: self,
          title: none,
          spacing: (1.2em, 0.8em),
          filter: hd => hd.relation != none and not hd.relation.unrelated,
          selector-filter: greyc-utils.appendix-filter,
          depth: depth,
          transform: (hd, it) => {
            set text(size: 1.2em, fill: self.colors.primary, weight: "bold") if hd.relation != none and hd.relation.same
            set text(fill: self.colors.primary, weight: "bold") if (
              hd.relation != none and hd.relation.child and hd.level == 2
            )
            set text(fill: self.colors.primary) if hd.relation != none and hd.relation.child and hd.level > 2
            set text(fill: self.colors.primary.transparentize(60%), weight: "bold") if (
              hd.relation != none and hd.relation.sibling
            )

            it
          },
          label: get-label,
        ),
        // text(
        //   fill: self.colors.primary,
        //   weight: "bold",
        //   components.custom-progressive-outline(
        //     level: level,
        //     alpha: self.store.alpha,
        //     indent: (0em, 1em),
        //     vspace: (.0em,),
        //     numbered: (numbered,),
        //     depth: 3,
        //     ..args.named(),
        //   ),
        // ),
      )
        + args.pos().sum(default: none),
    ),
  )
})



/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - align (alignment): is the alignment of the content. The default is `horizon + center`.
#let focus-slide(
  config: (:),
  align: horizon + center,
  fill: auto,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: if fill == auto { gradient.linear(self.colors.primary, self.colors.neutral-dark, angle: 45deg) } else {
        fill
      },
      margin: 2em,
      header: none,
      footer: self => {
        place(
          right + bottom,
          box(height: 1em)[#greyc-utils.call-or-display(self, self.store.logo-focus)],
          dx: -0.1em,
          dy: -0.1em,
        )
      },
    ),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})


/// Bibliography slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the bibliography. Default is `greyc-utils.i18n-bibliography-title`. This is shown as the slide title, while the real title of the bibliography is set to `none`.
#let bibliography-slide(
  config: (:),
  title: greyc-utils.i18n-bibliography-title,
  ..args,
) = touying-slide-wrapper(self => {
  self.store.header-aa = [#link(<touying-bibliography>, title)<touying-link>]
  self.store.header-ab = none
  touying-slide(
    self: self,
    config: config,
    std.align()[
      #{
        set heading(numbering: none)
        show heading: none
        std.heading(utils.call-or-display(self, title), level: 1, outlined: false, bookmarked: true)
      }
      #set text(size: 0.7em)
      #bibliography(..args, title: none)<touying-bibliography>
    ],
  )
})


#let _hidden-bibliography(
  self: none,
  ..args,
) = {
  show bibliography: none
  footcite.bib-is-hidden.update(true)
  bibliography(..args)
}


/// Include the bibliography but not show it.
/// Very useful when you dont want a bibliography slide.
#let hidden-bibliography(
  ..args,
) = touying-fn-wrapper(_hidden-bibliography.with(..args))


/// End slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the slide. The default is `none`.
///
/// - body (array): is the content of the slide.
#let ending-slide(config: (:), title: none, body) = touying-slide-wrapper(self => {
  self.store.title = if self.store.flavor == "legacy" { "" } else { none }
  self.store.subtitle = none
  self.store.header-aa = none
  self.store.header-ab = none
  let info = self.info
  info.emails = {
    let emails = if "emails" in info {
      info.emails
    } else if "email" in info {
      info.email
    } else {
      ()
    }
    if type(emails) == array {
      emails
    } else {
      (emails,)
    }
  }
  let content = {
    {
      set heading(numbering: none)
      show heading: none
      std.heading(utils.call-or-display(self, title), level: 1, outlined: false, bookmarked: true)
    }
    set std.align(center + horizon)
    if title != none {
      let block-args = (
        width: {
          let mapping = (
            cambridge: 100%,
            darmstadt: 100%,
          )
          mapping.at(self.store.flavor, default: auto)
        },
        fill: {
          let mapping = (
            simple: none,
            cambridge: self.colors.neutral-lightest,
            darmstadt: self.colors.primary,
          )
          mapping.at(self.store.flavor, default: self.colors.primary-light)
        },
        inset: (top: 0.75em, bottom: 0.75em, left: 3em, right: 3em),
        radius: 0.5em,
      )
      let text-args = (
        size: 1.5em,
        fill: {
          let mapping = (
            simple: self.colors.primary,
            cambridge: self.colors.primary,
            darmstadt: self.colors.neutral-lightest,
          )
          mapping.at(self.store.flavor, default: self.colors.neutral-darkest)
        },
      )
      let title-block = block(..block-args, text(..text-args, title))
      let title-container = if self.store.flavor in ("cambridge", "darmstadt") {
        greyc-components.shadow
      } else {
        it => it
      }
      title-container(title-block)
    }
    body
    if info.emails != none and info.emails != () {
      v(2.5em)
      grid(
        columns: (1fr,) * calc.min(info.emails.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..info.emails.map(e => text(font: "New Computer Modern Mono", size: 0.7em, e)),
      )
    }
  }
  touying-slide(self: self, config: config, content)
})


#let backup-slide(
  title: auto,
  subtitle: auto,
  config: (:),
  ..bodies,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
  )
  if title != auto {
    self.store.title = title
  }
  if subtitle != auto {
    self.store.subtitle = subtitle
  }
  touying-slide(self: self, config: config, ..bodies)
})


/// Touying ambrosia theme.
///
/// Example:
///
/// ```typst
/// #show: ambrosia-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
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
/// The default colors:
///
///
/// ```typst
/// config-colors(
///   primary: rgb("#005bac"),
///   primary-dark: rgb("#004078"),
///   secondary: rgb("#ffffff"),
///   tertiary: rgb("#005bac"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. The default is `16-9`.
///
/// - align (alignment): is the alignment of the content. The default is `horizon`.
///
/// - title (content, function): is the title in the header of the slide. The default is `self => utils.display-current-heading(depth: self.slide-level)`.
///
/// - header-logo (content, function): is the logo usually shown in the right-most of the header. The default is `self => self.info.logo`.
///
/// - footer (content, function): is the footer of the slide. The default is `none`.
///
/// - footer-right (content, function): is the right part of the footer. The default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - progress-bar (boolean): is whether to show the progress bar in the footer. The default is `true`.
///
/// - footer-columns (array): is the columns of the footer. The default is `(25%, 25%, 1fr, 5em)`.
///
/// - footer-a (content, function): is the left part of the footer. The default is `self => self.info.author`.
///
/// - footer-b (content, function): is the second left part of the footer. The default is `self => utils.display-info-date(self)`.
///
/// - footer-c (content, function): is the second right part of the footer. The default is `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`.
///
/// - footer-d (content, function): is the right part of the footer. The default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
#let ambrosia-theme(
  flavor: "legacy",
  aspect-ratio: "16-9",
  align: top,
  alpha: 20%,
  title: self => greyc-utils.display-current-heading(
    depth: self.slide-level,
    selector-filter: greyc-utils.appendix-filter,
  ),
  subtitle: self => greyc-utils.prose-display-current-headings(
    level: self.slide-level + 1,
    depth: self.slide-level + 1,
    selector-filter: greyc-utils.appendix-filter,
    numbered: false,
    dir: ltr,
    spacing: 0.5em,
  ),
  logos: none,
  logo-focus: self => self.info.logo,
  header-logo: self => self.info.logo,
  header-a-columns: (1fr, 1fr),
  header-aa: self => greyc-utils.display-current-heading(
    depth: 1,
    level: 1,
    selector-filter: greyc-utils.appendix-filter,
  ),
  header-ab: self => greyc-utils.display-current-heading(
    depth: 2,
    level: 2,
    selector-filter: greyc-utils.appendix-filter,
    style: current-heading => current-heading.body,
  ),
  footer-a-columns: (20%, 1fr, 8em, 8em),
  footer-aa: self => self.info.author,
  footer-ab: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-ac: self => utils.display-info-date(self),
  footer-ad: self => context if utils.slide-counter.get().first() > utils.last-slide-counter.final().first() {
    numbering("i", utils.slide-counter.get().first() - utils.last-slide-counter.final().first())
  } else { utils.slide-counter.display() + " / " + utils.last-slide-number },
  progress-bar: true,
  footcite-once: true,
  ..args,
  body,
) = {
  footcite.footcite-once.update(footcite-once)

  let top-margin-mapping = (
    legacy: 2.4em,
    simple: 2.4em,
    stargazer: 4.2em,
    dewdrop: 4.2em,
    cambridge: 3.1em,
    darmstadt: 4.2em,
  )
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header: _greyc-header,
      footer: _greyc-footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: top-margin-mapping.at(flavor, default: 3em), bottom: 1em, x: 2.5em),
    ),
    config-common(
      slide-level: if flavor == "cambridge" { 3 } else { 2 },
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false,
      default-slide-preamble: self => {
        if self.at("reset-footnote-number-per-slide", default: true) {
          counter(footnote).update(0)
          // context footcite.footcited-keys.update((:))
        }
      },
      // show-bibliography-as-footnote: bibliography("bibliography.bib"),
    ),
    config-methods(
      init: (self: none, body) => {
        let flavor = self.store.flavor

        set text(size: 20pt)
        show raw: set text(size: 0.88em)
        show: greyc-components.apply-marker-style.with(color: self.colors.primary)
        show: greyc-components.apply-alert-style.with(color: self.colors.primary)

        show figure.caption: set text(size: 0.6em)
        show figure.where(kind: table): set figure.caption(position: top)
        set footnote.entry(
          separator: line(length: 30%, stroke: 0.5pt + self.colors.neutral-dark),
          gap: 0.4em,
          indent: 0em,
        )
        show footnote.entry: it => {
          set text(size: 0.6em, fill: self.colors.neutral-dark)
          emph(it)
        }
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }

        show outline.entry: set outline.entry(fill: repeat[#text(size: 0.5em)[.]])
        show heading: set text(fill: self.colors.primary)

        // for footcite
        show ref: it => context {
          if not footcite.bib-is-hidden.final() or it.element != none {
            it
            return
          }
          let p = here().page()
          let target = footcite._footcite-label-prefix + str(it.target)
          if not footcite.footcite-once.get() {
            target += "-" + str(p)
          }
          target = label(target)
          if query(target).len() > 0 {
            [#link(target, it)<touying-link>]
          } else {
            it
          }
        }
        show cite: it => context {
          if not footcite.bib-is-hidden.final() {
            it
            return
          }
          let p = here().page()
          let target = footcite._footcite-label-prefix + str(it.key)
          if not footcite.footcite-once.get() {
            target += "-" + str(p)
          }
          target = label(target)
          if query(target).len() > 0 {
            [#link(target, it)<touying-link>]
          } else {
            it
          }
        }

        body
      },
      // alert: utils.alert-with-primary-color,
      alert: greyc-utils.alert,
      tblock: greyc-components.tblock,
      framed-tblock: greyc-components.framed-tblock,
      footcite: footcite,
    ),
    config-colors(
      primary: colors.primary,
      primary-light: colors.secondary,
      primary-lightest: colors.tertiary,
      primary-dark: colors.primary.darken(20%),
      secondary: colors.white,
      tertiary: colors.primary.lighten(80%),
      neutral-light: colors.grey,
      neutral-lighter: colors.grey.mix(colors.white),
      neutral-lightest: colors.white,
      neutral-dark: colors.charcoal,
      neutral-darker: colors.charcoal.mix(colors.black),
      neutral-darkest: colors.black,
    ),
    // save the variables for later use
    config-store(
      flavor: flavor,
      align: align,
      alpha: alpha,
      title: title,
      subtitle: subtitle,
      logo-focus: logo-focus,
      logos: logos,
      header-logo: header-logo,
      header-a-columns: header-a-columns,
      header-aa: header-aa,
      header-ab: header-ab,
      footer-a-columns: footer-a-columns,
      footer-aa: footer-aa,
      footer-ab: footer-ab,
      footer-ac: footer-ac,
      footer-ad: footer-ad,
      progress-bar: progress-bar,
      header-a: self => {
        let mapping = (
          legacy: none,
          stargazer: greyc-components.simple-navigation(
            self: self,
            primary: self.colors.neutral-lightest,
            secondary: gray,
            background: self.colors.neutral-darkest,
            logo: greyc-utils.call-or-display(self, self.store.header-logo),
            selector-filter: greyc-utils.reveal-after-appendix-filter,
          ),
          dewdrop: greyc-components.mini-slides(
            self: self,
            primary: self.colors.primary,
            secondary: self.colors.primary-lighter,
            background: none,
            display-section: false,
            display-subsection: true,
            linebreaks: false,
            short-heading: true,
            selector-filter: greyc-utils.reveal-after-appendix-filter,
          ),
          cambridge: {
            set text(size: .5em)
            grid(
              columns: self.store.header-a-columns,
              rows: 1.5em,
              rect(
                width: 100%,
                height: 100%,
                inset: 1mm,
                outset: 0mm,
                fill: self.colors.primary,
                stroke: none,
                std.align(horizon + right, text(fill: self.colors.neutral-lightest, greyc-utils.call-or-display(
                  self,
                  self.store.header-aa,
                ))),
              ),
              rect(
                width: 100%,
                height: 100%,
                inset: 1mm,
                outset: 0mm,
                fill: self.colors.primary-light,
                stroke: none,
                std.align(horizon + left, text(fill: self.colors.neutral-darkest, greyc-utils.call-or-display(
                  self,
                  self.store.header-ab,
                ))),
              ),
            )
          },
          darmstadt: greyc-components.mini-slides(
            self: self,
            primary: self.colors.neutral-lightest,
            secondary: self.colors.neutral-light,
            background: self.colors.neutral-darkest,
            display-section: false,
            display-subsection: true,
            linebreaks: false,
            short-heading: true,
            selector-filter: greyc-utils.reveal-after-appendix-filter,
          ),
        )
        mapping.at(self.store.flavor, default: none)
      },
      header-b: self => if self.store.title != none {
        let block-args = (
          width: 100%,
          height: 1.8em,
          fill: {
            let mapping = (
              stargazer: gradient.linear(
                self.colors.primary,
                self.colors.primary.darken(25%),
                self.colors.primary.darken(50%),
                self.colors.neutral-darkest,
                angle: -45deg,
              ),
              cambridge: self.colors.neutral-lighter,
              darmstadt: gradient.linear(
                self.colors.neutral-darkest,
                self.colors.primary.darken(25%),
                self.colors.primary,
                self.colors.primary,
                self.colors.primary,
                self.colors.primary,
                self.colors.primary,
                self.colors.primary.lighten(25%),
                self.colors.neutral-lightest,
                angle: 90deg,
              ),
            )
            mapping.at(self.store.flavor, default: none)
          },
        )
        let title-block-args = (
          inset: (
            left: 1.5em,
            right: {
              let mapping = (
                legacy: 0em,
              )
              mapping.at(self.store.flavor, default: 1.5em)
            },
            top: 1mm,
            bottom: 1mm,
          ),
        )
        let title-color-mapping = (
          legacy: self.colors.primary,
          simple: self.colors.primary,
          stargazer: self.colors.neutral-lightest,
          dewdrop: self.colors.primary,
          cambridge: self.colors.primary,
          darmstadt: self.colors.neutral-lightest,
        )
        let subtitle-color-mapping = (
          legacy: self.colors.primary,
          simple: self.colors.primary,
          stargazer: self.colors.neutral-light,
          dewdrop: self.colors.primary,
          cambridge: self.colors.primary,
          darmstadt: self.colors.neutral-light,
        )
        let text-args = (
          title: (
            size: 1.3em,
            weight: "bold",
            fill: title-color-mapping.at(self.store.flavor, default: self.colors.neutral-darkest),
          ),
          subtitle: (
            size: 1.0em,
            weight: "semibold",
            fill: subtitle-color-mapping.at(self.store.flavor, default: self.colors.neutral-darkest),
          ),
        )

        let header-logo = if self.store.flavor in ("simple", "legacy") {
          block(
            inset: (right: 0.5em),
            grid(
              rows: block-args.height,
              greyc-utils.call-or-display(self, self.store.header-logo),
            ),
          )
        } else { none }
        let title-block = block(
          ..title-block-args,
          greyc-utils.adaptive-prose-display-title-subtitle(
            text(..text-args.title, greyc-utils.call-or-display(self, self.store.title)),
            text(..text-args.subtitle, greyc-utils.call-or-display(self, self.store.subtitle)),
          ),
        )
        block(
          ..block-args,
          std.align(horizon,
            if header-logo == none {
              title-block
            } else {
              grid(
                columns: (1fr, auto),
                gutter: 0.5em,
                align: (left + horizon, right + top),
                title-block,
                header-logo,
              )
            }
          ),
        )
      },
      footer-a: self => {
        let cell(fill: none, text-fill: self.colors.neutral-lightest, it) = rect(
          width: 100%,
          height: 100%,
          inset: 1mm,
          outset: 0mm,
          fill: fill,
          stroke: none,
          std.align(horizon, text(fill: text-fill, it)),
        )
        grid(
          columns: self.store.footer-a-columns,
          rows: (1.5em, auto),
          cell(fill: self.colors.primary, greyc-utils.call-or-display(self, self.store.footer-aa)),
          cell(fill: self.colors.primary-light, text-fill: self.colors.neutral-darkest, greyc-utils.call-or-display(
            self,
            self.store.footer-ab,
          )),
          cell(fill: self.colors.primary, greyc-utils.call-or-display(self, self.store.footer-ac)),
          cell(fill: self.colors.primary, greyc-utils.call-or-display(self, self.store.footer-ad)),
        )
      },
      footer-b: self => {
        let logo-footer = block(
          height: 1.8em,
          inset: 0pt,
          outset: 0pt,
          grid(
            align: right + horizon,
            columns: (1fr, auto),
            gutter: 0em,
            block(inset: 4pt, height: 100%, text(greyc-utils.call-or-display(self, self.info.logo))),
          ),
        )
        let mapping = (
          cambridge: logo-footer,
          darmstadt: logo-footer,
        )
        mapping.at(self.store.flavor, default: none)
      },
    ),
    ..args,
  )

  body
}


/// Touying GREYC theme.
///
/// See `ambrosia-theme` for more details and examples.
#let greyc-theme(
  flavor: "legacy",
  aspect-ratio: "16-9",
  datetime-format: "[day]/[month]/[year]",
  ..args,
  body,
) = context {
  let default-logo-path = _ => {
    let mapping = (
      en: assets.asset-paths.logo-greyc.en,
      fr: assets.asset-paths.logo-greyc.fr,
    )
    mapping.at(text.lang, default: mapping.en)
  }
  let default-logo = self => context {
    image(default-logo-path(self))
  }
  let default-logo-light = self => context {
    image(bytes(
      assets.colorize-svg(default-logo-path(self), source: colors.logo, target: self.colors.neutral-lightest),
    ))
  }
  let default-logo-focus = self => context {
    image(bytes(
      assets.transparentize-svg(
        assets.colorize-svg(default-logo-path(self), source: colors.logo, target: self.colors.neutral-lightest),
        opacity: 0.6,
      ),
    ))
  }
  let default-header-logo = self => context {
    let mapping = (
      legacy: assets.logo-greyc-with-traits(height: 100%),
      simple: assets.logo-greyc-with-traits(height: 100%),
      stargazer: greyc-utils.call-or-display(self, default-logo-light),
      darmstadt: greyc-utils.call-or-display(self, default-logo),
    )
    mapping.at(self.store.flavor, default: mapping.stargazer)
  }

  let default-logos-color = colors.icons
  let default-logos-paths = (
    nu: assets.asset-paths.logo-nu,
    unicaen: assets.asset-paths.logo-unicaen,
    ensicaen: assets.asset-paths.logo-ensicaen,
    cnrs: assets.asset-paths.logo-cnrs,
  )

  let default-logos-data = (:)
  for key in default-logos-paths.keys() {
    default-logos-data.insert(key, (
      legacy: self => image(bytes(
        assets.colorize-svg(
          default-logos-paths.at(key),
          source: default-logos-color,
          target: self.colors.neutral-lightest,
        ),
      )),
      modern: image(default-logos-paths.at(key)),
    ))
  }
  let logos = (:)
  for key in default-logos-data.keys() {
    logos.insert(key, self => {
      greyc-utils.call-or-display(
        self,
        default-logos-data.at(key).at(self.store.flavor, default: default-logos-data.at(key).at("modern")),
      )
    })
  }

  show: ambrosia-theme.with(
    flavor: flavor,
    aspect-ratio: aspect-ratio,
    header-logo: default-header-logo,
    logos: logos,
    logo-focus: default-logo-focus,
    config-common(
      datetime-format: datetime-format,
    ),
    config-info(
      logo: default-logo,
      logo-light: default-logo-light,
    ),
    ..args,
  )
  body
}
