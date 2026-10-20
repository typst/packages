#import "@preview/touying:0.7.0": *
#import components: *
#import utils: *

#let RVL_PRIMARY = rgb("#002060")
#let RVL_NEUTRAL_LIGHTEST = rgb("#ffffff")
#let RVL_NEUTRAL_DARKEST = rgb("#000000")
#let RVL_TITLE_META = rgb("#666666")
#let RVL_DIVIDER = rgb("#c8ccd2")

#let RVL_CARD_STROKE = rgb("#cbd5e1")
#let RVL_CARD_FILL = rgb("#fbfdff")
#let RVL_FIGURE_STROKE = rgb("#9aa4b2")
#let RVL_FIGURE_FILL = rgb("#f7f9fc")
#let RVL_FIGURE_TEXT = rgb("#344054")
#let RVL_FIGURE_SUBTITLE = rgb("#667085")
#let RVL_QUESTION_STROKE = rgb("#d6deeb")
#let RVL_QUESTION_FILL = rgb("#fbfcfe")
#let RVL_QUESTION_LABEL = rgb("#7b8798")

// Page geometry (inches)
#let RVL_W = 13.3333in
#let RVL_H = 7.5in

// Title & body placeholders
#let RVL_TITLE_X = 0.9167in
#let RVL_TITLE_Y = 0.659in
#let RVL_TITLE_W = 11.5in
#let RVL_TITLE_H = 1.45in

#let RVL_BODY_X = 0.9167in
#let RVL_BODY_Y = 1.9963in
#let RVL_BODY_W = 11.5in

// Accent bars
#let RVL_LEFT_BAR_X = 0.70in
#let RVL_LEFT_BAR_Y = 0.659in
#let RVL_LEFT_BAR_W = 0.0625in
#let RVL_LEFT_BAR_H = 0.52in

#let RVL_BOTTOM_BAR_Y = 7.2874in
#let RVL_BOTTOM_BAR_H = 0.1307in
#let RVL_BODY_H = RVL_BOTTOM_BAR_Y - RVL_BODY_Y - 0.15in

// Logo (right anchor so it never clips)
#let RVL_LOGO_Y = -0.2564in
#let RVL_LOGO_W = 4.5667in
#let RVL_LOGO_H = 1.1417in
#let RVL_LOGO_RIGHT_PAD = -0.05in // negative moves left a bit (safe margin)

// Footer positioning
#let RVL_FOOTER_Y = 6.9514in
#let RVL_FOOTER_DATE_W = 3.0in
#let RVL_FOOTER_CENTER_X = 4.4167in
#let RVL_FOOTER_CENTER_W = 4.5in
#let RVL_FOOTER_PAGENO_X = 10.0660in
#let RVL_FOOTER_PAGENO_W = 3.0in

// Extra padding inside title boxes to avoid clipping descenders.
#let RVL_TITLE_INSET_TOP = 4pt
#let RVL_TITLE_INSET_BOTTOM = 8pt
#let RVL_COVER_INSET_TOP = 6pt
#let RVL_COVER_INSET_BOTTOM = 10pt

// Cover layout
#let RVL_COVER_W = 12.2in
#let RVL_COVER_H = 2.3in
#let RVL_COVER_META_W = 10.8in
#let RVL_COVER_VENUE_H = 0.22in
#let RVL_COVER_GROUP_SEP = 0.22in
#let RVL_COVER_ITEM_SEP = 0.07in
#let RVL_COVER_AUTHOR_PAD_TOP = 0.12in
#let RVL_COVER_DIVIDER_W = 6.5in
#let RVL_COVER_DIVIDER_STROKE = 0.8pt + RVL_DIVIDER

// ----------------------------
// Date helpers
// ----------------------------

/// Parse an ISO date string into a `datetime`.
///
/// - `iso` (`str`): Date string in `YYYY-MM-DD` format.
/// -> datetime
#let rvl-date(iso) = {
  let p = iso.split("-")
  datetime(year: int(p.at(0)), month: int(p.at(1)), day: int(p.at(2)))
}

#let rvl-format-date(d) = {
  let dt = if type(d) == str { rvl-date(d) } else { d }
  let mons = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  [#mons.at(dt.month() - 1) #dt.day(), #dt.year()]
}

// ----------------------------
// Auto-fit helper (measure-based)
// ----------------------------
#let rvl-fit-text(content, width, max-height, sizes, leading: 0.98em) = context {
  for s in sizes {
    let c = block(width: width)[
      #set text(size: s)
      #set par(leading: leading)
      #content
    ]
    if measure(c).height <= max-height { return c }
  }

  // Fallback: scale down the smallest candidate.
  let s = sizes.last()
  let c = block(width: width)[
    #set text(size: s)
    #set par(leading: leading)
    #content
  ]
  let h = measure(c).height
  let pct = calc.max(1%, max-height / h * 100%)
  block(width: width, height: max-height)[
    #set align(top + center)
    #scale(x: pct, y: pct, origin: top + center)[#c]
  ]
}

#let rvl-abbrev-author(name) = {
  let parts = name.split(" ").filter(p => p.len() > 0)
  if parts.len() <= 1 { return name }
  let last = parts.last()
  let initials = parts.slice(0, parts.len() - 1).map(p => p.first() + ".").join(" ")
  initials + " " + last
}

#let rvl-format-authors(authors) = {
  if type(authors) == array {
    authors.map(rvl-abbrev-author).join(", ")
  } else {
    authors
  }
}

#let rvl-fit-title(title, width, max-height) = rvl-fit-text(
  title,
  width,
  max-height,
  (36pt, 34pt, 32pt, 30pt, 28pt, 26pt, 24pt),
  leading: 0.96em,
)

#let rvl-fit-cover-title(title, width, max-height) = rvl-fit-text(
  title,
  width,
  max-height,
  (42pt, 38pt, 34pt, 30pt, 27pt, 24pt, 22pt),
  leading: 0.98em,
)

#let rvl-fit-cover-authors(content, width, max-height) = rvl-fit-text(
  content,
  width,
  max-height,
  (22pt, 20pt, 18pt, 16pt, 14pt, 12pt, 11pt, 10pt),
  leading: 0.92em,
)

#let rvl-fit-cover-venue(content, width, max-height) = rvl-fit-text(
  content,
  width,
  max-height,
  (20pt, 18pt, 16pt, 14pt, 12pt),
  leading: 0.95em,
)

// ----------------------------
// Decorations & overlay layers
// ----------------------------
#let rvl-decorations(self) = [
  #place(top + left, dx: 0in, dy: RVL_BOTTOM_BAR_Y)[
    #rect(width: RVL_W, height: RVL_BOTTOM_BAR_H, fill: self.colors.primary)
  ]

  #if self.store.title != none {
    place(top + left, dx: RVL_LEFT_BAR_X, dy: RVL_LEFT_BAR_Y)[
      #rect(width: RVL_LEFT_BAR_W, height: RVL_LEFT_BAR_H, fill: self.colors.primary)
    ]
  }
]

#let rvl-logo(self) = [
  #place(top + right, dx: RVL_LOGO_RIGHT_PAD, dy: RVL_LOGO_Y)[
    #image("../template/assets/logo.png", width: RVL_LOGO_W, height: RVL_LOGO_H, fit: "contain")
  ]
]

#let rvl-footer-layer(self) = [
  #set text(size: 14pt, fill: self.colors.neutral-darkest)

  #if self.info.date != none {
    place(top + left, dx: RVL_TITLE_X, dy: RVL_FOOTER_Y)[
      #box(width: RVL_FOOTER_DATE_W, align(left)[#rvl-format-date(self.info.date)])
    ]
  }

  #if self.store.footer != none {
    place(top + left, dx: RVL_FOOTER_CENTER_X, dy: RVL_FOOTER_Y)[
      #box(width: RVL_FOOTER_CENTER_W, align(center)[#utils.call-or-display(self, self.store.footer)])
    ]
  }

  #place(top + left, dx: RVL_FOOTER_PAGENO_X, dy: RVL_FOOTER_Y)[
    #box(width: RVL_FOOTER_PAGENO_W, align(right)[#context utils.slide-counter.display()])
  ]
]

#let rvl-outline-nav-card(title) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  stroke: 1pt + RVL_CARD_STROKE,
  fill: RVL_CARD_FILL,
)[
  #set text(size: 18pt, weight: "bold", fill: RVL_PRIMARY)
  #title
]

/// Render a simple statistic or summary card.
///
/// - `title`: Card title shown in the accent color.
/// - `body`: Card contents.
/// -> content
#let rvl-stat-card(title, body) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  stroke: 1pt + RVL_CARD_STROKE,
  fill: RVL_CARD_FILL,
)[
  #set text(size: 16pt)
  #text(size: 18pt, weight: "bold", fill: RVL_PRIMARY)[#title]
  #v(0.25em)
  #body
]

/// Render a styled placeholder block for a figure slot.
///
/// - `title`: Main placeholder label.
/// - `subtitle`: Optional secondary description.
/// - `height`: Placeholder height.
/// -> content
#let rvl-figure-placeholder(title, subtitle: none, height: 2.4in) = block(
  width: 100%,
  height: height,
  inset: 18pt,
  radius: 10pt,
  stroke: 1.2pt + RVL_FIGURE_STROKE,
  fill: RVL_FIGURE_FILL,
)[
  #set align(center + horizon)
  #set text(fill: RVL_FIGURE_TEXT)
  #text(size: 15pt, weight: "semibold")[Figure placeholder]
  #v(0.45em)
  #text(size: 19pt, weight: "bold")[#title]
  #if subtitle != none {
    v(0.55em)
    text(size: 15pt, fill: RVL_FIGURE_SUBTITLE)[#subtitle]
  }
]

/// Deprecated alias for `rvl-stat-card`.
///
/// New decks should use `rvl-stat-card`.
/// -> content
#let stat-card(title, body) = rvl-stat-card(title, body)

/// Deprecated alias for `rvl-figure-placeholder`.
///
/// New decks should use `rvl-figure-placeholder`.
/// -> content
#let fig-placeholder(title, subtitle: none, height: 2.4in) = rvl-figure-placeholder(
  title,
  subtitle: subtitle,
  height: height,
)

/// Render the central research-question card used on outline slides.
///
/// - `question`: Main question text.
/// - `label`: Small label shown above the question.
/// - `height`: Card height.
/// -> content
#let rvl-outline-question-card(
  question,
  label: [RESEARCH QUESTION],
  height: 2.55in,
) = block(
  width: 100%,
  height: height,
  inset: 16pt,
  radius: 14pt,
  stroke: 1pt + RVL_QUESTION_STROKE,
  fill: RVL_QUESTION_FILL,
)[
  #set par(justify: false)
  #text(size: 11pt, weight: "semibold", tracking: 0.08em, fill: RVL_QUESTION_LABEL)[#label]
  #v(0.38em)
  #rvl-fit-text(
    question,
    RVL_BODY_W - 32pt,
    height - 0.9in,
    (16.5pt, 16pt, 15.5pt, 15pt, 14.5pt, 14pt),
    leading: 0.98em,
  )
]

// ----------------------------
// Slide functions
// ----------------------------

/// Render a standard content slide in the RVL layout.
///
/// - `body`: Slide body content.
/// - `title`: Optional slide title. Defaults to the current level-2 heading.
/// - `args`: Additional Touying slide options.
/// -> content
#let rvl-slide(body, title: auto, ..args) = touying-slide-wrapper(self => {
  let slide-title = if title != auto { title } else {
    utils.display-current-heading(level: 2, numbered: false)
  }
  self.store.title = slide-title

  self = utils.merge-dicts(
    self,
    config-page(
      width: RVL_W,
      height: RVL_H,
      fill: self.colors.neutral-lightest,
      margin: 0in,
      header: none,
      footer: none,
      background: rvl-decorations(self),
      foreground: [#rvl-logo(self) #rvl-footer-layer(self)],
    ),
  )

  // Fit to the inner height (box height minus inset).
  let fit_h = RVL_TITLE_H - RVL_TITLE_INSET_TOP - RVL_TITLE_INSET_BOTTOM

  let layer = [
    #if self.store.title != none {
      place(top + left, dx: RVL_TITLE_X, dy: RVL_TITLE_Y)[
        #box(
          width: RVL_TITLE_W,
          height: RVL_TITLE_H,
          clip: true,
          inset: (top: RVL_TITLE_INSET_TOP, bottom: RVL_TITLE_INSET_BOTTOM),
        )[
          #set text(weight: "bold", fill: self.colors.primary)
          #rvl-fit-title(self.store.title, RVL_TITLE_W, fit_h)
        ]
      ]
    }

    #place(top + left, dx: RVL_BODY_X, dy: RVL_BODY_Y)[
      #box(width: RVL_BODY_W, height: RVL_BODY_H, clip: true)[
        #set text(size: 25pt, fill: self.colors.neutral-darkest)
        #set par(leading: 1.12em)
        #set list(spacing: 0.6em)
        #body
      ]
    ]
  ]

  touying-slide(self: self, layer, ..args)
})

/// Render the default outline slide with a question card and section nav cards.
///
/// - `question`: Central research question.
/// - `sections`: Sequence of section labels.
/// - `title`: Slide title.
/// - `prompt`: Short label above the question card.
/// - `question-label`: Label shown inside the question card.
/// - `question-height`: Height of the question card.
/// - `body`: Optional extra content appended below the outline grid.
/// -> content
#let rvl-outline-slide(
  question: [This is a question.],
  sections: ([Introduction], [Method], [Experiment], [Conclusion]),
  title: [Outline],
  prompt: [Central research question],
  question-label: [RESEARCH QUESTION],
  question-height: 2.55in,
  ..args,
  body,
) = rvl-slide(title: title, ..args)[
  #set text(size: 18pt)
  #grid(
    columns: (1fr),
    rows: (auto, question-height, auto),
    gutter: 0.18in,
    [
      *#prompt*
    ],
    [
      #rvl-outline-question-card(
        question,
        label: question-label,
        height: question-height,
      )
    ],
    [
      #grid(
        columns: sections.map(_ => 1fr),
        gutter: 0.18in,
        ..sections.map(section => rvl-outline-nav-card(section)),
      )
    ],
  )
  #body
]

/// Render the title slide using `config-info(...)` metadata.
///
/// Supported metadata fields:
/// - `title`: Deck title.
/// - `presenter`: Presenter name shown with the date.
/// - `paper_authors`: Full author list shown below the title.
/// - `paper_authors_short`: Optional shorter author list for compact covers.
/// - `paper_venue`: Venue or source label.
/// - `date`: Presentation date as `datetime` or ISO string via `rvl-date`.
/// -> content
#let rvl-title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let presenter = info.at("presenter", default: info.at("author", default: none))
  let paper_authors = info.at("paper_authors_short", default: info.at("paper_authors", default: none))
  let paper_venue = info.at("paper_venue", default: none)

  self = utils.merge-dicts(self, config-page(
    width: RVL_W,
    height: RVL_H,
    fill: self.colors.neutral-lightest,
    margin: 0in,
    header: none,
    footer: none,
    background: none,
    foreground: none,
  ))

  let fit_h = RVL_COVER_H - RVL_COVER_INSET_TOP - RVL_COVER_INSET_BOTTOM
  let authors_h = if paper_venue != none { 0.80in } else { 0.92in }

  let presenter_date = if presenter != none and info.date != none {
    [#presenter #h(0.35em)·#h(0.35em) #rvl-format-date(info.date)]
  } else if presenter != none {
    presenter
  } else if info.date != none {
    rvl-format-date(info.date)
  } else {
    none
  }

  let body = [
    #set align(center + horizon)
    #set text(fill: self.colors.neutral-darkest)
    #set par(justify: false)

    #box(width: RVL_COVER_W, inset: (top: RVL_COVER_INSET_TOP, bottom: RVL_COVER_INSET_BOTTOM))[
      #set text(weight: "bold")
      #rvl-fit-cover-title(info.title, RVL_COVER_W, fit_h)
    ]

    #v(RVL_COVER_GROUP_SEP)
    #line(length: RVL_COVER_DIVIDER_W, stroke: RVL_COVER_DIVIDER_STROKE)

    #if paper_authors != none {
      v(RVL_COVER_AUTHOR_PAD_TOP)
      if paper_venue != none {
        box(width: RVL_COVER_META_W, height: RVL_COVER_VENUE_H, clip: true)[
          #set align(center + horizon)
          #set text(fill: RVL_TITLE_META)
          #rvl-fit-cover-venue(paper_venue, RVL_COVER_META_W, RVL_COVER_VENUE_H)
        ]
        v(RVL_COVER_ITEM_SEP)
      }

      box(width: RVL_COVER_META_W, height: authors_h, clip: true)[
        #set align(center + horizon)
        #rvl-fit-cover-authors(rvl-format-authors(paper_authors), RVL_COVER_META_W, authors_h)
      ]
    }

    #if presenter_date != none {
      v(RVL_COVER_GROUP_SEP)
      set text(size: 16pt, fill: RVL_TITLE_META, weight: "regular")
      presenter_date
    }
  ]

  touying-slide(self: self, body)
})

/// Render emphasized inline alert styling using the theme primary color.
///
/// - `body`: Content to emphasize.
/// -> content
#let alert(body) = touying-fn-wrapper(self => utils.alert-with-primary-color.with(self: self)(body))

/// Attach speaker notes to the current slide.
///
/// - `mode`: Note output mode passed to Touying.
/// - `setting`: Note setting transformer passed to Touying.
/// - `note`: Note content.
/// -> content
#let speaker-note(mode: "typ", setting: it => it, note) = {
  touying-fn-wrapper(utils.speaker-note, mode: mode, setting: setting, note)
}

/// Apply the RVL Touying theme to a slide deck.
///
/// - `footer`: Footer content rendered in the bottom center area.
/// - `args`: Additional Touying configuration arguments.
/// - `body`: Deck body content.
/// -> content
#let rvl-theme(footer: none, ..args, body) = {
  set text(font: "DejaVu Sans", size: 28pt, fill: RVL_NEUTRAL_DARKEST)

  show heading.where(level: 1): it => none
  show heading.where(level: 2): it => none

  show heading.where(level: 3): it => [
    #set text(size: 30pt, weight: "bold")
    #it.body
    #v(0.10in)
  ]

  show: touying-slides.with(
    config-page(width: RVL_W, height: RVL_H, margin: 0in),
    config-common(slide-fn: rvl-slide, new-section-slide-fn: none),
    config-methods(title-slide: rvl-title-slide, alert: utils.alert-with-primary-color),
    config-colors(
      primary: RVL_PRIMARY,
      neutral-lightest: RVL_NEUTRAL_LIGHTEST,
      neutral-darkest: RVL_NEUTRAL_DARKEST,
    ),
    config-store(title: none, footer: footer),
    ..args,
  )

  body
}
