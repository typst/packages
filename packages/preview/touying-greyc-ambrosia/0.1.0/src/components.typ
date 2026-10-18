#import "@preview/touying:0.6.2": components, touying-fn-wrapper, utils
#import "utils.typ" as greyc-utils
#import "shadowed.typ": frame, shadow

#let _current-heading(level: auto, outlined: true) = {
  let here = here()
  query(heading.where(outlined: outlined).before(inclusive: false, here)).at(-1, default: none)
}

#let _headings-context(target: heading.where(outlined: true)) = {
  let current-heading = _current-heading()

  let headings = query(target)
  let path = ()
  let level = 0
  let current-heading-idx = none

  let result = ()

  for hd in headings {
    let diff = hd.level - level
    if diff > 0 {
      for _ in range(diff) {
        path.push(1)
      }
    } else {
      for _ in range(-diff) {
        let _ = path.pop()
      }
      path.at(-1) = path.at(-1) + 1
    }

    result.push((
      path: path,
      heading: hd,
    ))

    if current-heading != none and hd.location() == current-heading.location() {
      // matching on location, otherwise this will be `true` for an identical heading at another location
      current-heading-idx = result.len() - 1
    }

    level = hd.level
  }

  return (
    current-heading: current-heading,
    current-heading-idx: current-heading-idx,
    headings: result,
  )
}

/// Create an outline that allows you to filter entries and style them based on context.
/// Modified from https://github.com/zeroeightysix/tt-lectures
///
/// - filter (function): A boolean function that accepts a single argument `hd` which is a dict of:
///   - `here-path`: array = the unique 'path' for the most recently defined heading at the current location in the document.
///   - `here-level`: integer = `here-path.len()`, the depth of the aforementioned heading.
///   - `level`: integer = the depth of the being filtered heading
///   - `path`: array = the path, as previously described, of the being filtered heading
///   - `relation`: dict of booleans describing how this heading relates to the 'here' heading
///     - `same` = this heading IS the 'here' heading
///     - `parent` = this heading is a direct parent of the 'here' heading
///     - `child` = this heading is a direct child of the 'here' heading
///     - `sibling` = this heading is at the same level of, and shares the parent of the 'here' heading
///     - `unrelated` = `true` if none of the other relations are `true`.
///   - loc: location = `heading.location()`
///   - heading: element = the actual heading element `hd` was created from
///
/// - selector-filter (function): Filter applied to the heading query selector. Default to identity.
///
/// - transform (function): A function taking two arguments `hd` and `it`, used to define a custom show-rule for `outline.entry`:
///   - `hd` is a heading dict with the same structure as in `filter`
///   - `it` is the `outline.entry` element being shown
#let custom-outline(
  self: none,
  filter: hd => true,
  selector-filter: sel => sel,
  transform: (_, it) => it,
  target: heading.where(outlined: true),
  spacing: auto,
  label: none,
  ..args,
) = context {
  let cx = _headings-context(target: target)
  let idx = cx.at("current-heading-idx", default: none)
  let scope-path = if idx != none {
    cx.headings.at(idx).path
  }

  let headings = cx
    .headings
    .map(hd => {
      let level = hd.path.len()

      let relation = if scope-path != none {
        let path-len = calc.min(level, scope-path.len())
        let common-path = hd.path.slice(0, path-len) == scope-path.slice(0, path-len)

        let same = hd.path == scope-path
        let parent = not same and common-path and level < scope-path.len()
        let child = not same and common-path and level > scope-path.len()
        let sibling = (
          not same and level == scope-path.len() and hd.path.slice(0, path-len - 1) == scope-path.slice(0, path-len - 1)
        )

        (
          same: same,
          parent: parent,
          child: child,
          sibling: sibling,
          unrelated: not same and not parent and not child and not sibling,
        )
      }

      (
        here-path: scope-path,
        here-level: if scope-path != none { scope-path.len() },
        level: level,
        path: hd.path,
        relation: relation,
        loc: hd.heading.location(),
        heading: hd.heading,
      )
    })
    .filter(filter)

  if headings == () {
    let nonsense-target = selector(<P>).and(<NP>)
    outline(target: nonsense-target, ..args)
    return
  }

  let find-heading(location) = {
    for x in headings {
      // forgive me :(
      if x.loc == location {
        return x
      }
    }
  }

  let spacings = if spacing != auto {
    if type(spacing) == array { spacing } else { (spacing,) }
  } else { none }
  show outline.entry: it => {
    let hd = find-heading(it.element.location())

    // apply spacing
    let lvl = it.element.level
    set block(above: spacings.at(lvl - 1)) if type(spacings) == array and lvl <= spacings.len()

    transform(hd, it)
  }

  let selection = selector(headings.at(0).loc)
  let prev-h = none
  let prev-slide-num = none
  for idx in range(1, headings.len()) {
    let h = headings.at(idx).heading
    // let num = numbering(if h.numbering != none {h.numbering} else {"1."}, ..counter(heading).at(h.location()))
    // slide number is more reliable
    let slide-num = utils.slide-counter.at(h.location())
    if h == prev-h and slide-num == prev-slide-num {
      // avoid duplication for subslides.
      continue
    }
    prev-h = h
    prev-slide-num = slide-num
    selection = selection.or(headings.at(idx).loc)
  }

  let toc = outline(target: selector-filter(selection), ..args)
  if label != none {
    [#toc#greyc-utils.call-or-return(self, label)]
  } else {
    toc
  }
}


/// Show mini slides. It is usually used to show the navigation of the presentation in header.
///
/// - self (none): The self context, which is used to get the short heading of the headings.
///
/// - fill (color): The fill color of the headings. Default is `rgb("000000")`.
///
/// - alpha (ratio): The transparency of the headings. Default is `60%`.
///
/// - display-section (boolean): Indicates whether the sections should be displayed. Default is `false`.
///
/// - display-subsection (boolean): Indicates whether the subsections should be displayed. Default is `true`.
///
/// - linebreaks (boolean): Indicates whether or not to insert linebreaks between links for sections and subsections.
///
/// - display-subsection (boolean): Indicates whether the subsections should be displayed. Default is `true`.
///
/// - short-heading (boolean): Indicates whether the headings should be shortened. Default is `true`.
///
/// - inline (boolean): Indicates whether the bullets are displayed right after the text, instead of breaking the line. Default is `false`.
///
/// - selector-filter (function): Filter applied to the heading query selector. Default to identity.
///
/// -> content
#let mini-slides(
  self: none,
  primary: white,
  secondary: gray,
  background: black,
  display-section: false,
  display-subsection: true,
  linebreaks: true,
  short-heading: true,
  inline: false,
  selector-filter: sel => sel,
) = (
  context {
    let headings = query(selector-filter(heading.where(level: 1).or(heading.where(level: 2))))
    let sections = headings.filter(it => it.level == 1)
    let visible-headings = headings.filter(h => h.at("outlined", default: true))
    let visible-sections = sections.filter(h => h.at("outlined", default: true))
    if sections == () {
      return
    }
    let first-page = sections.at(0).location().page()
    headings = headings.filter(it => it.location().page() >= first-page)
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
    ))
    let current-page = here().page()
    let real-current-index = sections.filter(it => it.location().page() <= current-page).len() - 1
    let current-index = visible-sections.filter(it => it.location().page() <= current-page).len() - 1
    let focus-index = -1
    let cols = ()
    let col = ()
    for (hd, next-hd) in headings.zip(headings.slice(1) + (none,)) {
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
        let new-col = {
          let body = if short-heading {
            utils.short-heading(self: self, hd)
          } else {
            hd.body
          }
          if hd in visible-headings {
            [#link(hd.location(), body)<touying-link>]
            if inline {
              h(.5em)
            } else {
              linebreak()
            }
          }
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-section {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                focus-index = cols.len()
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-section and display-subsection and linebreaks {
            linebreak()
          }
        }
        if hd in visible-headings {
          col.push(new-col)
        }
      } else {
        let new-col = {
          while slides.len() > 0 and slides.at(0).location().page() < next-page {
            let slide = slides.remove(0)
            if display-subsection {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if slide.location().page() <= current-page and current-page < next-slide-page {
                focus-index = cols.len()
                [#link(slide.location(), sym.circle.filled)<touying-link>]
              } else {
                [#link(slide.location(), sym.circle)<touying-link>]
              }
            }
          }
          if display-subsection {
            if linebreaks {
              linebreak()
            } else {
              h(0.1em)
            }
          }
        }
        if hd in visible-headings {
          col.push(new-col)
        }
      }
    }
    if col != () {
      cols.push(align(left, col.sum()))
      col = ()
    }
    if (
      focus-index < 0
        and (
          current-index < 0
            or current-index >= cols.len()
            or sections.at(real-current-index) != visible-sections.at(current-index)
        )
    ) {
      cols = cols.map(body => text(fill: secondary, body))
    } else {
      cols = cols
        .enumerate()
        .map(pair => {
          let (idx, body) = pair
          if (idx == current-index and focus-index < 0) or idx == focus-index {
            text(fill: primary, body)
          } else {
            text(fill: secondary, body)
          }
        })
    }
    block(
      width: 100%,
      inset: (bottom: 0.2em),
      outset: 0pt,
      fill: background,
      {
        set align(top + center)
        show: block.with(inset: (top: .5em, x: if inline { 1em } else { 2em }))
        show linebreak: it => it + v(-1em)
        set text(size: .7em)
        grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
      },
    )
  }
)


/// Simple navigation.
///
/// - self (none): The self context, which is used to get the short heading of the headings.
///
/// - short-heading (boolean): Indicates whether the headings should be shortened. Default is `true`.
///
/// - primary (color): The color of the current section. Default is `white`.
///
/// - secondary (color): The color of the other sections. Default is `gray`.
///
/// - background (color): The background color of the navigation. Default is `black`.
///
/// - logo (none): The logo of the navigation. Default is `none`.
///
/// - selector-filter (function): Filter applied to the heading query selector. Default to identity.
///
/// -> content
#let simple-navigation(
  self: none,
  short-heading: true,
  primary: white,
  secondary: gray,
  background: black,
  logo: none,
  selector-filter: sel => sel,
) = (
  context {
    let body() = {
      let sections = query(selector-filter(heading.where(level: 1)))
      let visible-sections = sections.filter(h => h.at("outlined", default: true))
      if sections.len() == 0 {
        return
      }
      let current-page = here().page()
      set text(size: 0.5em)
      for (section, next-section) in sections.zip(sections.slice(1) + (none,)) {
        set text(fill: if section.location().page() <= current-page
          and (
            next-section == none or current-page < next-section.location().page()
          ) {
          primary
        } else {
          secondary
        })
        if section in visible-sections {
          box(inset: 0.5em)[#link(
            section.location(),
            if short-heading {
              utils.short-heading(self: self, section)
            } else {
              section.body
            },
          )<touying-link>]
        }
      }
    }
    block(
      fill: background,
      inset: 0pt,
      outset: 0pt,
      grid(
        align: center + horizon,
        columns: (1fr, auto),
        rows: 1.8em,
        gutter: 0em,
        components.cell(
          fill: background,
          body(),
        ),
        block(fill: background, inset: 4pt, height: 100%, text(fill: primary, logo)),
      ),
    )
  }
)


/// LaTeX-like knob marker for list
///
/// Example: `#set list(marker: components.knob-marker(primary: rgb("005bac")))`
///
/// - primary (color): The color of the marker.
///
/// -> content
#let knob-marker(primary: rgb("#005bac"), scaling: 100%) = box(
  width: 0.5em,
)[
  #let default-radius = 0.25em
  #let radius = scaling * default-radius
  #place(
    dy: 0.35em - radius,
    circle(
      fill: gradient.radial(
        primary.lighten(100%),
        primary.darken(40%),
        focal-center: (30%, 30%),
      ),
      radius: radius,
    ),
  )
]


#let apply-marker-style(color: none, body) = context {
  if color == none {
    color = text.fill
  }
  set list(marker: it => {
    let default-markers = (
      knob-marker(primary: color, scaling: 80%),
      sym.bullet,
      sym.bullet.tri,
      sym.dash,
    )
    text(fill: color, default-markers.at(calc.min(it, default-markers.len() - 1)))
  })
  show enum: set text(fill: color)
  show enum.item: set text(fill: text.fill)
  show terms.item: it => {
    text(weight: "semibold", fill: color, it.term)
    h(0.6em)
    it.description
    linebreak()
  }

  body
}


#let apply-alert-style(color: none, body) = context {
  if color == none {
    color = text.fill
  }
  show <touying-greyc-alert>: it => {
    set text(fill: color)
    it.value
  }

  body
}


#let _tblock(self: none, title: none, fill: auto, background: auto, framed: true, shadowed: true, it) = layout(size => {
  let fill-color = if fill == auto { self.colors.primary-dark } else { fill }
  let background-color = if background == auto {
    if framed { fill-color.lighten(90%) } else { none }
  } else { background }

  show: apply-marker-style.with(color: fill-color)
  show: apply-alert-style.with(color: fill-color)

  let content = if framed {
    if title != none {
      grid(
        columns: 1,
        row-gutter: 0pt,
        block(
          fill: fill-color,
          width: 100%,
          radius: (top: 6pt),
          inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
          {
            show heading: set text(fill: self.colors.neutral-lightest)
            text(fill: self.colors.neutral-lightest, weight: "bold", title)
          },
        ),
        rect(
          fill: gradient.linear(fill-color, background-color, angle: 90deg),
          width: 100%,
          height: 4pt,
        ),
        block(
          fill: background-color,
          width: 100%,
          radius: (bottom: 6pt),
          inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
          it,
        ),
      )
    } else {
      block(
        fill: background-color,
        width: 100%,
        radius: 6pt,
        inset: 0.5em,
        it,
      )
    }
  } else {
    if title != none {
      let ctn = grid(
        columns: 1,
        row-gutter: 0pt,
        block(
          fill: background-color,
          width: 100%,
          radius: (top: 6pt),
          inset: (top: 0.4em, bottom: 0.3em + 4pt, left: 0.5em, right: 0.5em),
          {
            show heading: set text(fill: fill-color)
            if title.func() == heading {
              heading(depth: title.depth, text(fill: fill-color, title.body))
            } else {
              text(fill: fill-color, weight: "bold", title)
            }
          },
        ),
        block(
          fill: background-color,
          width: 100%,
          radius: (bottom: 6pt),
          inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
          it,
        ),
      )

      let (width, height) = measure(width: size.width, height: size.height, ctn)
      block(breakable: false)[
        #place(center + horizon)[  // avoid seam effect
          #box(
            fill: self.colors.neutral-lightest,
            width: width,
            height: height,
            radius: 6pt,
          )
        ]

        #ctn
      ]
    } else {
      block(
        fill: self.colors.neutral-lightest,
        width: 100%,
        radius: 6pt,
        inset: 0.5em,
        it,
      )
    }
  }
  if shadowed {
    shadow(
      content,
      blur: 8pt,
      dx: 3pt,
      dy: 3pt,
      fill: self.colors.neutral-dark.transparentize(50%),
      radius: 6pt,
    )
  } else {
    frame(
      content,
      radius: 6pt,
      stroke: 1pt + self.colors.neutral-dark.transparentize(50%),
    )
  }
})


/// Content block for the presentation.
///
/// - title (string): The title of the block. Default is `none`.
///
/// - fill (color): The primary color of the block. Default is `auto`.
///
/// - background (color): The background color of the block. Default is `auto`.
///
/// - shadowed (boolean): Whether to show a shadow under the block. Default is `true`.
///
/// - it (content): The content of the block.
///
/// -> content
#let tblock(title: none, fill: auto, background: auto, shadowed: true, it) = touying-fn-wrapper(_tblock.with(
  title: title,
  fill: fill,
  background: background,
  framed: false,
  shadowed: shadowed,
  it,
))


/// Framed content block for the presentation.
///
/// - title (string): The title of the block. Default is `none`.
///
/// - fill (color): The primary color of the block. Default is `auto`.
///
/// - background (color): The background color of the block. Default is `auto`.
///
/// - shadowed (boolean): Whether to show a shadow under the block. Default is `true`.
///
/// - it (content): The content of the block.
///
/// -> content
#let framed-tblock(title: none, fill: auto, background: auto, shadowed: true, it) = touying-fn-wrapper(_tblock.with(
  title: title,
  fill: fill,
  background: background,
  framed: true,
  shadowed: shadowed,
  it,
))
