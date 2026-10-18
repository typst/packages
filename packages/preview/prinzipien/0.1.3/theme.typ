// Prinzipien: a touying theme following the design principles of
// Jean-luc Doumont's "Trees, maps, and theorems":
//
// - a (very) wide left margin, everything set flush against it
// - all sizes and positions coordinated from a few shared dimensions
// - one message per slide; the message is the slide title
// - one accent colour only, plus tints derived from it

#import "@preview/touying:0.7.4": *

/// Derive a tint from a colour: similar hue and value, (much) less
/// saturation. The default strength turns the default accent `#f9ab1a`
/// into (roughly) the reference tint `#fdd9a3`.
///
/// - saturation (ratio): Fraction of the original saturation to keep.
#let tint(color, saturation: 40%) = {
  let (h, s, v, ..) = std.color.hsv(color).components()
  std.color.hsv(h, s * (saturation / 100%), v)
}

// The square logo variant: the explicitly configured one if given,
// otherwise derived from the full logo (`config-info`'s `logo`) by
// cropping its left end into a square box (logos usually carry their
// mark there). `none` if there is no logo.
#let square-logo(self, size) = {
  let sq = self.store.logo-square
  if sq == auto {
    let logo = self.info.logo
    if logo == none {
      none
    } else {
      box(
        width: size,
        height: size,
        clip: true,
        align(left + horizon, logo),
      )
    }
  } else if sq == none {
    none
  } else {
    box(width: size, height: size, align(center + horizon, sq))
  }
}

// The full logo, fitted into the margin area, for the title and overview
// slides.
#let margin-logo(self) = {
  let logo = self.info.logo
  if logo == none {
    none
  } else {
    box(
      width: self.store.margin-width - 2 * self.store.gap,
      height: 2 * self.store.gap,
      align(left + horizon, logo),
    )
  }
}

/// Default slide function.
///
/// The slide's message (one full sentence) is its title: it is taken from
/// the current second-level heading and set at the top of the slide,
/// flush against the left edge of the margin. The title row spans the full
/// slide width — the left margin is reserved for the bodies only — so a
/// long title never competes with the margin for space.
///
/// Below the title, the margin area and the content area form one row;
/// both bodies are aligned with its horizon.
///
/// - config (dictionary): Per-slide touying configuration
///   (`config-xxx`, merge several with `utils.merge-dicts`).
///
/// - repeat (int, auto): Number of subslides. `auto` lets touying count.
///
/// - setting (function): Extra set/show rules for this slide.
///
/// - composer (function, array): Layout composer for multiple bodies.
///
/// - margin-content (content, none): Content placed *into* the reserved
///   left margin area, e.g. labels for an image sitting to the right.
///   It shares the horizon with the slide body; use `v(..)` inside
///   to push individual labels down.
///
/// - bodies (array): The contents of the slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  margin-content: none,
  ..bodies,
) = touying-slide-wrapper(self => {
  let gap = self.store.gap
  let margin-width = self.store.margin-width
  let title-row = {
    let logo = square-logo(self, 1.5 * gap)
    let heading = text(
      size: 1.15em,
      weight: "bold",
      fill: self.colors.neutral-darkest,
      utils.display-current-heading(level: self.slide-level),
    )
    // Logo and title begin at the left edge of the margin, not padded in
    // to where the bodies start.
    if logo == none {
      heading
    } else {
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.5 * gap,
        align: horizon,
        logo, heading,
      )
    }
  }
  let layout-setting = body => {
    show: setting
    grid(
      columns: (margin-width - 2 * gap, 1fr),
      column-gutter: gap,
      rows: (auto, 1fr),
      row-gutter: 1.5em,
      grid.cell(colspan: 2, title-row),
      grid.cell(align: horizon, if margin-content == none { [] } else {
        margin-content
      }),
      grid.cell(align: horizon, body),
    )
  }
  let self = utils.merge-dicts(
    self,
    // The title is rendered by the layout grid above, not as a preamble
    // inside the margin-less page body.
    config-common(subslide-preamble: none),
    config-page(
      fill: self.colors.neutral-lightest,
      margin: (left: gap, right: gap, top: gap, bottom: gap),
      footer: self.store.footer,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: layout-setting,
    composer: composer,
    ..bodies,
  )
})

/// Write a top-level heading (a main point of the presentation) with an
/// optional substatement.
///
/// The heading's text is the point's statement (what the audience should
/// take away); the substatement supports it and is shown below the
/// statement on overview slides. Since typst headings carry no extra
/// fields, the substatement travels as invisible metadata inside the
/// heading body.
///
/// ```typst
/// #point(substatement: [The message is the slide title])[
///   Effective slides carry one message each
/// ]
/// ```
///
/// A plain `= Statement` heading is a point without a substatement.
#let point(substatement: none, statement) = heading(depth: 1, {
  statement
  if substatement != none {
    metadata((prinzipien-substatement: substatement))
  }
})

// Split a point heading's body into its statement and the substatement
// attached by the `point` helper (`none` if absent).
#let point-parts(h) = {
  let body = h.body
  if body.func() == [].func() {
    let sub = body.children.find(c => (
      c.func() == metadata
        and type(c.value) == dictionary
        and "prinzipien-substatement" in c.value
    ))
    if sub != none {
      return (
        body.children.filter(c => c != sub).join(),
        sub.value.prinzipien-substatement,
      )
    }
  }
  (body, none)
}

// Shared layout for the overview slides (preview, transition, review):
// the map of the presentation's points, derived from the top-level
// headings, with each point's statement above its substatement.
//
// `emphasize` selects the points that stand out: `"all"` for all of them,
// `auto` for the upcoming point only, or a (list of) 1-based point
// number(s).  The remaining points are muted with the suppressed colour.
#let overview-slide(
  config: (:),
  emphasize: "all",
  body: none,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-common(subslide-preamble: none),
    config-page(
      fill: self.colors.neutral-lightest,
      footer: self.store.footer,
    ),
  )
  let colors = self.colors
  let map = context {
    let points = query(heading).filter(h => h.level == 1 and h.outlined)
    let emphasized = if emphasize == "all" {
      range(1, points.len() + 1)
    } else if emphasize == auto {
      let current = utils.current-heading(level: 1, depth: 1)
      let pos = if current != none {
        points.position(p => p.location() == current.location())
      }
      if pos == none { () } else { (pos + 1,) }
    } else if type(emphasize) == int {
      (emphasize,)
    } else {
      emphasize
    }
    for (i, p) in points.enumerate() {
      let stands-out = (i + 1) in emphasized
      let (statement, sub) = point-parts(p)
      block(
        above: if i == 0 { 0em } else { 1.5em },
        text(
          weight: "bold",
          fill: if stands-out { colors.primary } else { colors.neutral-light },
          statement,
        ),
      )
      if sub != none {
        block(above: .5em, text(
          size: .9em,
          fill: if stands-out { colors.neutral-darkest } else {
            colors.neutral-light
          },
          sub,
        ))
      }
    }
  }
  touying-slide(self: self, config: config, {
    // The logo lives in the margin area on overview slides.
    let logo = margin-logo(self)
    if logo != none {
      place(top + left, dx: self.store.gap - self.store.margin-width, logo)
    }
    align(horizon, map)
    body
  })
})

/// Preview slide: the map of the body, shown after the main message.
/// All points are emphasized: statement in the accent colour,
/// substatement below it in the foreground colour.
#let preview(config: (:)) = overview-slide(config: config, emphasize: "all")

/// Review slide: the same map as `preview`, recapping all points before
/// the conclusion.
#let review(config: (:)) = overview-slide(config: config, emphasize: "all")

/// Transition slide: the map with only some points emphasized and the
/// rest muted in the suppressed colour.
///
/// Used automatically for every top-level heading (touying's
/// `new-section-slide-fn`), emphasizing the upcoming point.
///
/// - emphasize (auto, int, array): Which points (1-based) to emphasize.
///   Default is `auto`: only the upcoming point.
///
/// - bodies: Content of the section before its first slide (passed by
///   touying when the transition is triggered by a heading); it is
///   rendered below the map.
#let transition(config: (:), emphasize: auto, ..bodies) = overview-slide(
  config: config,
  emphasize: emphasize,
  body: bodies.pos().sum(default: none),
)

/// Title slide.
///
/// Shows the information given to `config-info` (title, subtitle, author,
/// date, institution). Unlike content slides it reserves no left margin
/// area and carries no footer numbering.
///
/// - config (dictionary): Per-slide touying configuration.
///
/// - args: Named arguments overriding the corresponding `config-info`
///   fields, e.g. `#title-slide(subtitle: [A subtitle])`.
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true, subslide-preamble: none),
    config-page(
      fill: self.colors.neutral-lightest,
      margin: (x: 2 * self.store.gap, y: 2 * self.store.gap),
      footer: none,
    ),
  )
  let body = {
    // The logo sits at the same position as in the margin area of the
    // other slides, although the title slide reserves no margin.
    let logo = margin-logo(self)
    if logo != none {
      place(
        top + left,
        dx: -self.store.gap,
        dy: -self.store.gap,
        logo,
      )
    }
    set align(left + horizon)
    block(text(size: 1.6em, weight: "bold", info.title))
    if info.subtitle != none {
      block(text(size: 1.2em, info.subtitle))
    }
    v(1em)
    set text(size: .9em)
    if info.author != none {
      block(info.author)
    }
    if info.institution != none {
      block(info.institution)
    }
    if info.date != none {
      block(text(
        fill: self.colors.neutral-light,
        utils.display-info-date(self),
      ))
    }
  }
  touying-slide(self: self, config: config, body)
})

/// Prinzipien theme.
///
/// Apply with a show rule:
///
/// ```typst
/// #show: prinzipien-theme.with(
///   config-info(title: [One sentence to remember]),
/// )
/// ```
///
/// Fonts are set with plain `set text` / `show raw` rules, so they can be
/// overridden with your own rules after the show rule.
///
/// - aspect-ratio (string): Aspect ratio of the slides. Default is `16-9`.
///
/// - margin (ratio, length): Width of the reserved left margin area.
///   A ratio is resolved against the slide width. Default is `33%`.
///
/// - background (color): Background colour. Default is `#ffffff`.
///
/// - foreground (color): Foreground (text) colour. Default is `#221f21`.
///
/// - accent (color): The one accent colour. Default is `#f9ab1a`.
///
/// - suppressed (color): Colour for muted/suppressed content.
///   Default is `#7a7d80`.
///
/// - accent-tint (auto, color): Tint of the accent colour, used e.g. as
///   the background of `#alert[..]` emphasis. Default is `auto`: derive
///   it from the accent colour with the `tint` helper.
///
/// - logo-square (auto, none, content): Square variant of the logo, shown
///   left of the slide title on content slides. The full logo is set with
///   `config-info(logo: ..)`. Default is `auto`: derive the square
///   variant from the full logo by cropping it into a square box.
#let prinzipien-theme(
  aspect-ratio: "16-9",
  margin: 33%,
  background: rgb("#ffffff"),
  foreground: rgb("#221f21"),
  accent: rgb("#f9ab1a"),
  suppressed: rgb("#7a7d80"),
  accent-tint: auto,
  logo-square: auto,
  ..args,
  body,
) = {
  let page-args = utils.page-args-from-aspect-ratio(aspect-ratio)
  // For the known ratios touying returns a paper name only; resolve the
  // concrete dimensions of those papers so everything can be coordinated
  // from them.
  let (width: page-width, height: page-height) = {
    let papers = (
      "presentation-16-9": (width: 841.89pt, height: 473.56pt),
      "presentation-4-3": (width: 793.7pt, height: 595.28pt),
    )
    if "paper" in page-args {
      papers.at(page-args.paper)
    } else {
      page-args
    }
  }
  // The shared dimensions everything else is coordinated from:
  // the reserved left margin and one spacing unit.
  let margin-width = if type(margin) == ratio {
    margin * page-width
  } else {
    margin
  }
  let gap = 0.05 * page-height

  show: touying-slides.with(
    config-page(
      ..page-args,
      margin: (left: margin-width, right: gap, top: gap, bottom: gap),
      // Zero descent makes the footer area exactly the bottom gap strip,
      // so the page number can be centred in it (touying anchors the
      // footer at the page bottom and the descent shrinks it from above).
      footer-descent: 0em,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: transition,
      slide-level: 2,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          font: "Noto Sans",
          size: 20pt,
          fill: self.colors.neutral-darkest,
        )
        show raw: set text(font: "Noto Sans Mono")
        set par(linebreaks: "optimized")

        body
      },
      // Emphasis in the Doumont manner: a pale tint of the accent colour
      // behind the words, rather than a second colour.
      alert: (self: none, it) => highlight(
        fill: self.colors.primary-light,
        extent: .1em,
        it,
      ),
    ),
    config-colors(
      neutral-lightest: background,
      neutral-darkest: foreground,
      neutral-light: suppressed,
      primary: accent,
      primary-light: if accent-tint == auto { tint(accent) } else {
        accent-tint
      },
    ),
    config-store(
      margin-width: margin-width,
      gap: gap,
      logo-square: logo-square,
      // `current / total` in the bottom right; the total excludes the
      // backmatter (touying freezes `last-slide-counter` in the appendix,
      // where slides are numbered with roman numerals instead). The number
      // sits centred in the bottom gap and ends flush with the content's
      // right edge, clear of the page edge.
      footer: self => align(
        right + horizon,
        pad(right: gap, text(
          size: .6em,
          fill: self.colors.neutral-light,
          context {
            if self.at("appendix", default: false) {
              let current = utils.slide-counter.get().first()
              let total = utils.last-slide-counter.final().first()
              numbering("i", current - total)
            } else {
              utils.slide-counter.display() + " / " + utils.last-slide-number
            }
          },
        )),
      ),
    ),
    ..args,
  )

  body
}
