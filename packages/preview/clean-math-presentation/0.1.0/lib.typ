// clean-math-presentation theme
// Authors: Coekjan, QuadnucYard, OrangeX4, JoshuaLampert
// Inspired by https://github.com/Coekjan/touying-buaa and
// https://github.com/QuadnucYard/touying-theme-seu and
// https://github.com/typst/packages/blob/main/packages/preview/touying/0.5.3/themes/stargazer.typ

#import "@preview/touying:0.5.3": *
#import "@preview/great-theorems:0.1.1": *

// Custom colors
#let primary-color = rgb("#005bac")
#let secondary-color = rgb("#004078")
#let tertiary-color = rgb("#972828")

// align
#let _typst-builtin-align = align

// Theorems configuration by great-theorems (only for proofs) and custom block

#let proof = proofblock()

#let _tblock(self: none, blocktitle: none, title: none, it) = {
  title = {
    if title != none and blocktitle != none {
      blocktitle + " (" + title + ")"
    } else if blocktitle != none {
      blocktitle
    } else {
      title
    }
  }
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: self.colors.primary,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),

    rect(
      fill: gradient.linear(self.colors.primary, self.colors.primary.lighten(90%), angle: 90deg),
      width: 100%,
      height: 4pt,
    ),

    block(
      fill: self.colors.primary.lighten(90%),
      width: 100%,
      radius: (bottom: 6pt),
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      it,
    ),
  )
}


/// General theorem block for the presentation.
///
/// - `title` is the title of the theorem. Default is `none`.
///
/// - `blocktitle` is the title of the block (e.g. "Definition", "Theorem" etc...) Default is `none`.
///
/// - `it` is the content of the block.
#let tblock(title: none, blocktitle: none, it) = touying-fn-wrapper(_tblock.with(title: title, blocktitle: blocktitle, it))

/// Definition block for the presentation.
///
/// - `title` is the title of the definition. Default is `none`.
///
/// - `it` is the content of the definition.
#let definition = tblock.with(blocktitle: "Definition")

/// Theorem block for the presentation.
///
/// - `title` is the title of the theorem. Default is `none`.
///
/// - `it` is the content of the theorem.
#let theorem = tblock.with(blocktitle: "Theorem")

/// Lemma block for the presentation.
///
/// - `title` is the title of the lemma. Default is `none`.
///
/// - `it` is the content of the lemma.
#let lemma = tblock.with(blocktitle: "Lemma")

/// Corollary block for the presentation.
///
/// - `title` is the title of the corollary. Default is `none`.
///
/// - `it` is the content of the corollary.
#let corollary = tblock.with(blocktitle: "Corollary")

/// Example block for the presentation.
///
/// - `title` is the title of the example. Default is `none`.
///
/// - `it` is the content of the example.
#let example = tblock.with(blocktitle: "Example")

/// Mathgrid to align multiple terms in a multi-line block equation.
///
/// - `align` is the alignment of the content. This can either be an alignment or an array of alignments for each column. Default is `center`.
///
/// - `gutter` is the space between the columns. Default is `1em`.
///
/// - `eq` is the content of the mathgrid.
///
/// See https://forum.typst.app/t/how-can-i-align-multiple-terms-in-a-multi-line-block-equation/1608/4
#let mgrid(align: center, gutter: 1em, eq) = context {
  if eq.func() != [].func() {
    // Body is just a single element, so leave it as is.
    return eq
  }

  // Split body at linebreaks and alignment points.
  let lines = eq.children.split(linebreak()).map(line => line.split($&$.body).map(array.join))

  // Calculate width of each column.
  let widths = ()
  for line in lines {
    for (i, part) in line.enumerate() {
      let width = measure(math.equation(block: true, numbering: none, part)).width
      if i >= widths.len() {
        widths.push(width)
      } else {
        widths.at(i) = calc.max(widths.at(i), width)
      }
    }
  }

  // Resolve alignment for each column.
  let aligns = range(widths.len()).map(i => {
    if type(align) == alignment { align }
    else if type(align) == array { align.at(calc.rem(i, align.len())) }
    else { panic("expected alignment or array as 'align'") }
  })

  // Try to flatten sequence elements (to allow access to an underlying align
  // element for overriding the alignment of single parts).
  let flatten(seq) = {
    if type(seq) != content or seq.func() != [].func() {
      return seq
    }
    let children = seq.children.filter(c => c != [ ])
    if children.len() == 1 { children.first() } else { seq }
  }

  // Display parts centered in each column and add gutter.
  let layout-line(line) = {
    if line.len() < widths.len() {
      line += (none,) * (widths.len() - line.len())
    }

    line.zip(widths, aligns).map(((part, width, align)) => {
      let part = flatten(part)
      let part-width = measure(math.equation(block: true, numbering: none, part)).width
      let delta = width - part-width

      // Check if alignment is overridden.
      if type(part) == content and part.func() == std.align {
        align = part.alignment.x
      }

      let (start, end) = if align == center {( h(delta/2), h(delta/2) )}
                         else if align == left {( none, h(delta) )}
                         else if align == right {( h(delta), none )}

      start + part + end
    }).join(h(gutter))
  }

  lines.map(layout-line).join(linebreak())
}

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
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  title: auto,
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
  // restore typst builtin align function
  let align = _typst-builtin-align
  if title != auto {
    self.store.title = title
  }
  if header != auto {
    self.store.header = header
  }
  if footer != auto {
    self.store.footer = footer
  }
  let self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  let new-setting = body => {
    show: align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// - `logo1` is the first logo of the slide. Can be an image. Default is `none`.
///
/// - `logo2` is the second logo of the slide. Can be an image. Default is `none`.
///
/// - `background` is the background image of the slide. Can be an image. Default is `none`.
///
/// Example:
///
/// ```typst
/// #show: clean-math-presentation-theme.with(
///   config-info(
///     title: [Title],
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
#let title-slide(
  logo1: none,
  logo2: none,
  background: none,
  ..args) = touying-slide-wrapper(self => {
  set page(background: background)
  self.store.title = none
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    let authors = if type(authors) == array {
      authors
    } else {
      (authors,)
    }
    authors.map(author => if author.name == info.author {
      (name: underline(author.name), affiliation-id: author.affiliation-id)
    } else {
      author
    })
  }

  let body = {
    show: align.with(center + horizon)
    // title
    block(
      fill: self.colors.primary,
      inset: 1.4em,
      radius: 0.5em,
      breakable: false,
      {
        text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
        if info.subtitle != none {
          parbreak()
          text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
        }
      },
    )
    // authors
    info.authors.map(author => {
      text(size: 1.0em, author.name + super(str(author.affiliation-id)))
    }).join(", ")

    // institutions
    if info.affiliations != none {
      parbreak()
      for affiliation in info.affiliations {
        text(size: 0.8em, super(str(affiliation.id)) + affiliation.name)
        linebreak()
      }
    }
    // date
    if info.date != none {
      parbreak()
      text(size: 1.0em, utils.display-info-date(self))
    }
    if logo1 != none {
      logo1
    }
    if logo2 != none {
      logo2
    }
  }

  self = utils.merge-dicts(
    self,
    config-page(
      header: none,
      footer: none,
      margin: (top: 1.0em, bottom: 0.0em),
    ),
  )

  touying-slide(self: self, body)
})



/// Outline slide for the presentation.
///
/// - `title` is the title of the outline. Default is `utils.i18n-outline-title`.
///
/// - `level` is the level of the outline. Default is `none`.
///
/// - `numbered` is whether the outline is numbered. Default is `true`.
#let outline-slide(
  title: utils.i18n-outline-title,
  numbered: true,
  level: none,
  ..args,
) = touying-slide-wrapper(self => {
  self.store.title = title
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(
    self: self,
    align(
      self.store.align,
      components.adaptive-columns(
        text(
          fill: self.colors.primary,
          weight: "bold",
          components.custom-progressive-outline(
            level: level,
            alpha: self.store.alpha,
            indent: (0em, 1em),
            vspace: (.4em,),
            numbered: (numbered,),
            depth: 1,
            ..args.named(),
          ),
        ),
      ) + args.pos().sum(default: none),
    ),
  )
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `title` is the title of the section. The default is `utils.i18n-outline-title`.
///
/// - `level` is the level of the heading. The default is `1`.
///
/// - `numbered` is whether the heading is numbered. The default is `true`.
///
/// - `body` is the body of the section. It will be pass by touying automatically.
#let new-section-slide(
  title: utils.i18n-outline-title,
  level: 1,
  numbered: true,
  ..args,
  body,
) = outline-slide(title: title, level: level, numbered: numbered, ..args, body)


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `align` is the alignment of the content. Default is `horizon + center`.
#let focus-slide(align: horizon + center, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, _typst-builtin-align(align, body))
})


/// End slide for the presentation.
///
/// - `title` is the title of the slide. Default is `none`.
///
/// - `body` is the content of the slide.
#let ending-slide(title: none, body) = touying-slide-wrapper(self => {
  let content = {
    set align(center + horizon)
    if title != none {
      block(
        fill: self.colors.tertiary,
        inset: (top: 0.7em, bottom: 0.7em, left: 3em, right: 3em),
        radius: 0.5em,
        text(size: 1.5em, fill: self.colors.neutral-lightest, title),
      )
    }
    body
  }
  touying-slide(self: self, content)
})


/// Touying clean-math-presentation theme.
///
/// Example:
///
/// ```typst
/// #show: clean-math-presentation-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
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
/// - `align` is the alignment of the content. Default is `top`.
///
/// - `title` is the title in header of the slide. Default is `self => utils.display-current-heading(depth: self.slide-level)`.
///
/// - `header-right` is the right part of the header. Default is `self => self.info.logo`.
///
/// - `footer` is the footer of the slide. Default is `none`.
///
/// - `footer-right` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - `progress-bar` is whether to show the progress bar in the footer. Default is `false`.
///
/// - `footer-columns` is the columns of the footer. Default is `(25%, 50%, 15%, 10%)`.
///
/// - `footer-a` is the left part of the footer. Default is `self => self.info.author`.
///
/// - `footer-b` is the second left part of the footer. Default is `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`.
///
/// - `footer-c` is the second right part of the footer. Default is `self => utils.display-info-date(self)`.
///
/// - `footer-d` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///      primary: rgb("#005bac"),
///      secondary: rgb("#004078"),
///      tertiary: rgb("#972828"),
///      neutral-lightest: rgb("#ffffff"),
///      neutral-darkest: rgb("#000000"),
///    )
/// ```
#let clean-math-presentation-theme(
  aspect-ratio: "16-9",
  align: top + left,
  alpha: 20%,
  title: self => utils.display-current-heading(depth: self.slide-level),
  header-right: self => self.info.logo,
  progress-bar: false,
  footer-columns: (25%, 50%, 15%, 10%),
  footer-a: self => self.info.author,
  footer-b: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-c: self => utils.display-info-date(self),
  footer-d: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  ..args,
  body,
) = {
  let header(self) = {
    set _typst-builtin-align(top)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.store.navigation),
      utils.call-or-display(self, self.store.header),
    )
  }
  let footer(self) = {
    set text(size: 0.6em)
    set _typst-builtin-align(center + bottom)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.store.footer),
      if self.store.progress-bar {
        utils.call-or-display(
          self,
          components.progress-bar(height: 2pt, self.colors.primary, self.colors.neutral-lightest),
        )
      },
    )
  }

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header: header,
      footer: footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.5em, bottom: 1.0em, x: 2.5em),
    ),
    config-common(
      slide-fn: slide,
      datetime-format: "[month repr:long] [day], [year]",
    ),
    config-methods(
      init: (self: none, body) => {
        set document(title: self.info.title)
        set text(size: 20pt)
        set list(marker: (text([‣], fill: self.colors.primary, size: 25pt),
                          text([--], fill: self.colors.primary, size: 25pt)))
        show figure.caption: set text(size: 0.8em)
        show footnote.entry: set text(size: 0.6em)
        show heading: set text(fill: self.colors.primary)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }
        show figure.where(kind: table): set figure.caption(position: top)
        show figure.caption: c => {
          text(fill: self.colors.primary, weight: "bold")[
          #{
            c.supplement
          }]
          c.separator
          c.body
        }
        show: great-theorems-init
        show math.equation: box // no line breaks in inline math
        // Only number equations if they have a label
        show math.equation:it => {
          if it.has("label"){
            math.equation(block:true, numbering: "(1)", it)
          } else {
            it
          }
        }
        show ref: it => {
          let el = it.element
          if el != none and el.func() == math.equation {
           link(el.location(), numbering("(1)",
                counter(math.equation).at(el.location()).at(0) + 1
            ))
          } else {
            it
          }
        }

        body
      },
      alert: utils.alert-with-primary-color,
      tblock: _tblock,
    ),
    config-colors(
      primary: primary-color,
      secondary: secondary-color,
      tertiary: tertiary-color,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      alpha: alpha,
      title: title,
      header-right: header-right,
      progress-bar: progress-bar,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      footer-d: footer-d,
      navigation: self => {
        context {
          let current-heading = utils.current-heading(level: 1)
          let current-heading-name = if current-heading != none {
            current-heading.body
          } else {
            ""
          }

          grid(
            columns: (1fr, 1fr),
            block(
              width: 100%,
              height: 0.8em,
              fill: self.colors.secondary,
              place(right + horizon, text(current-heading-name, fill: self.colors.neutral-lightest, size: 0.7em), dx: -0.3em),
            ),
            block(
              width: 100%,
              height: 0.8em,
              fill: self.colors.primary,
            )
          )
        }
      },
      header: self => if self.store.title != none {
        block(
          width: 100%,
          height: 2.2em,
          fill: gradient.linear(self.colors.primary, self.colors.secondary),
          place(left + horizon, text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em, utils.call-or-display(self, self.store.title)), dx: 1.0em),
        )
      },
      footer: self => {
        let cell(fill: none, it) = rect(
          width: 100%,
          height: 100%,
          inset: 1mm,
          outset: 0mm,
          fill: fill,
          stroke: none,
          _typst-builtin-align(horizon, text(fill: self.colors.neutral-lightest, it)),
        )
        grid(
          columns: self.store.footer-columns,
          rows: (1.5em, auto),
          cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-a)),
          cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-b)),
          cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-c)),
          cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-d)),
        )
      }
    ),
    ..args,
  )

  body
}
