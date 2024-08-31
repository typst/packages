#import "@preview/touying:0.4.2": *
#import "colors.typ": *
#import "admonition.typ": *
#import "settings.typ" as settings

//todo (low prio): add material symbols

// ===================================
// ============ UTILITIES ============
// ===================================

/// Creates a custom rectangle cell
#let _cell(
  body,
  width: 100%,
  height: 100%,
  inset: 0mm,
  outset: 0mm,
  alignment: top + left,
  fill: none,
  debug: settings.DEBUG,
) = rect(
  width: width,
  height: height,
  inset: inset,
  outset: outset,
  fill: fill,
  radius: 2em,
  stroke: if debug {
    1mm + red
  } else {
    none
  },
  align(alignment, body),
)

/// Adds gradient to body (used for slide-focus)
#let _gradientize(
  self,
  body,
  c1: blue-dark,
  c2: blue-dark,
  lighten-pct: 20%,
  angle: 45deg,
) = {
  rect(fill: gradient.linear(c1, c2.lighten(lighten-pct), angle: angle), body)
}

/// Creates a title and subtitle block
#let _title-and-sub(body, title, subtitle: none, heading-level: 1) = {
  grid(
    _cell(
      heading(level: heading-level, title),
      height: auto,
      width: auto,
    ),
    if subtitle != none {
      _cell(
        heading(level: heading-level + 1, subtitle),
        height: auto,
        width: auto,
      )
    },
    columns: 1fr,
    gutter: 0.6em,
    body
  )
}

/// Calculates page margin based on header and footer settings
#let _get-page-margin() = {
  if settings.SHOW-HEADER and settings.SHOW-FOOTER {
    (x: 2.8em, y: 2.5em)
  } else if settings.SHOW-HEADER {
    (x: 2.8em, bottom: 0em)
  } else if settings.SHOW-FOOTER {
    (top: 2em, left: 2.8em)
  } else {
    (x: 1em, y: 1em)
  }
}

// Creates a custom quote element
#let _custom-quote(it) = {
  box(
    fill: luma(220),
    outset: 1em,
    width: 100%,
    [
      // smartquote() doesn't work properly here,
      // probably because we're in a block
      #settings.QUOTES.at("left") #it.body #settings.QUOTES.at("right")
      #if it.attribution != none [
        #set text(size: 0.8em)
        #linebreak()
        #h(1fr)
        (#it.attribution)
      ]
    ],
  )
}

// ===================================
// ============= NAV BAR =============
// ===================================

//inspired from touying-buaa theme: https://github.com/Coekjan/touying-buaa/blob/a3fd8257328a80b7c7b74145a10a3984e26629a7/lib.typ
#let unistra-nav-bar(
  self: none,
) = states.touying-progress-with-sections(dict => {
  let (current-sections, final-sections) = dict
  current-sections = current-sections
    .filter(section => section.loc != none)
    .map(section => (
        section,
        section.children,
      ))
    .flatten()
    .filter(item => item.kind == "section")
  final-sections = final-sections
    .filter(section => section.loc != none)
    .map(section => (
        section,
        section.children,
      ))
    .flatten()
    .filter(item => item.kind == "section")
  let current-index = current-sections.len() - 1

  set text(size: 1.2em)

  let header-link(i, current-index, loc, title) = {
    link(
      loc,
      text(
        fill: if i == current-index {
          black
        } else {
          gray
        },
        underline.with(offset: 3pt, extent: -1pt)(title),
      ),
    )
  }

  for (i, section) in final-sections.enumerate() {
    if (i <= current-index) {
      box()[#header-link(
          i,
          current-index,
          section.loc,
          utils.section-short-title(section.title),
        )<touying-link>]
      if (i < current-index) {
        text(" | ", fill: black)
      }
    }
  }
})

// ================================
// ============ SLIDES ============
// ================================

// Creates a title slide
#let title-slide(
  self: none,
  title: "",
  subtitle: "",
  logo-path: "../assets/unistra.svg",
  logo-width: 40%,
  logo-height: auto,
  ..args,
) = {
  self = utils.empty-page(self)

  let info = self.info + args.named()

  let body = {
    set text(fill: self.colors.white)
    set block(inset: 0mm, outset: 0mm, spacing: 0em)
    set align(top + left)
    _gradientize(
      self,
      block(
        fill: none,
        width: 100%,
        height: 100%,
        inset: (left: 2em, top: 1em),
        grid(
          columns: (1fr),
          rows: (6em, 6em, 4em, 4em),
          _cell([
            #align(
              left,
              image(logo-path, width: logo-width, height: logo-height),
            )
          ]),
          _cell([
            #text(
              size: 2em,
              weight: "bold",
              if (title != "") {
                title
              } else {
                info.title
              },
            )
            #linebreak()
            #text(
              size: 1.7em,
              weight: "regular",
              if (subtitle != "") {
                subtitle
              } else {
                info.subtitle
              },
            )
          ]),
          _cell([
            #if ((none, "").all(x => x != info.subtitle)) {
              linebreak()
            }
            #set text(size: 1.5em, fill: self.colors.white)
            #text(weight: "bold", info.author)
          ]),
          _cell([
            #set text(fill: self.colors.white.transparentize(25%))
            #utils.info-date(self)
          ]),
        ),
      ),
      c1: self.colors.blue-dark,
      c2: self.colors.cyan,
    )
  }

  (self.methods.touying-slide)(self: self, repeat: none, body)
}

// Creates a normal slide with a title and body
#let slide(self: none, title: none, ..args) = {
  if title != auto {
    self.slide-title = title
  }

  (self.methods.touying-slide)(
    self: self,
    title: title,
    setting: body => {
      if self.auto-heading == true and title != none {
        heading(level: 2, title)
      }
      set text(size: 30pt)
      body
    },
    ..args,
  )
}

// Creates a focus slide with a gradient background
#let focus-slide(
  self: none,
  c1: none,
  c2: none,
  text-color: none,
  theme: none,
  text-alignment: center + horizon,
  counter: counter("focus-slide"),
  show-counter: true,
  body,
) = {
  assert(
    (c1 != none and c2 != none) or theme != none,
    message: "Please provide a color theme or two colors for the focus slide.",
  )

  if (theme != none) {
    assert(
      theme in self.colorthemes,
      message: "The theme " + theme + " is not defined. Available themes are: " + self
        .colorthemes
        .keys()
        .join(", "),
    )
    assert(
      self.colorthemes.at(theme).len() != 2 or self
        .colorthemes
        .at(theme)
        .len() != 3,
      message: "The theme " + theme + " is not a valid color theme. A valid color theme should have 2 or 3 colors.",
    )

    let theme-has-text-color = self.colorthemes.at(theme).len() == 3

    if (text-color == none and not theme-has-text-color) {
      text-color = self.colors.white
    } else {
      text-color = self.colorthemes.at(theme).at(2)
    }

    c1 = self.colorthemes.at(theme).at(0)
    c2 = self.colorthemes.at(theme).at(1)
  }

  let padding = auto
  if text-alignment == left + horizon {
    padding = 2em
  }

  self = utils.empty-page(self)

  let body = {
    set text(fill: text-color, size: 2em, weight: "bold", tracking: 0.8pt)

    if (show-counter) {
      counter.step()
    }

    context {
      let count-label = none
      if (show-counter) {
        count-label = counter.display("I") + ". "
      }
      _gradientize(
        self,
        block(
          width: 100%,
          height: 100%,
          grid.cell(
            if (count-label != none) {
              count-label
            } + body,
            align: text-alignment,
            inset: padding,
          ),
        ),
        c1: c1,
        c2: c2,
      )
    }
  }
  (self.methods.touying-slide)(self: self, repeat: none, body)
}

/// Creates a hero slide with a high width image, and optional title and subtitle
#let hero(
  self: none,
  title: none,
  heading-level: 1,
  subtitle: none,
  img: none,
  caption: none,
  bold-caption: false,
  numbering: none,
  txt: none,
  enhanced-text: true,
  text-fill: none,
  text-alignment: horizon + center,
  img-height: auto,
  img-width: auto,
  rows: (1fr),
  direction: "ltr",
  gap: auto,
  hide-footer: true,
) = {
  let create-figure() = {
    if (bold-caption) {
      caption = text(weight: "bold", caption)
    }

    figure(
      image(img, height: img-height, width: img-width),
      caption: caption,
      numbering: numbering,
    )
  }

  let create-image-cell() = {
    _cell(
      create-figure(),
    )
  }

  let create-text-cell(txt, text-fill) = {
    if enhanced-text {
      txt = text(size: 2em, weight: 900, txt)
    }

    _cell(
      txt,
      height: 100%,
      width: 100%,
      alignment: text-alignment,
      fill: text-fill,
    )
  }

  let create-grid(
    first-cell,
    second-cell,
    columns: (1fr, 1fr),
    rows: rows,
    column-gutter: auto,
    row-gutter: auto,
  ) = {
    grid(
      columns: columns,
      rows: rows,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      first-cell, second-cell,
    )
  }

  let create-body() = {
    if (txt == none) {
      align(
        center,
        create-figure(),
      )
    } else {
      if direction == "ltr" {
        create-grid(
          create-text-cell(txt, text-fill),
          create-image-cell(),
          column-gutter: gap,
        )
      } else if direction == "rtl" {
        create-grid(
          create-image-cell(),
          create-text-cell(txt, text-fill),
          column-gutter: gap,
        )
      } else if direction == "utd" {
        create-grid(
          create-image-cell(),
          create-text-cell(txt, text-fill),
          columns: (1fr),
          rows: (1fr, 1fr),
          row-gutter: gap,
        )
      } else if direction == "dtu" {
        create-grid(
          create-text-cell(txt, text-fill),
          create-image-cell(),
          columns: (1fr),
          rows: (1fr, 1fr),
          row-gutter: if gap {
            gap
          } else {
            -2em
          },
        )
      }
    }
  }

  let body = create-body()

  if (title != none) {
    body = _title-and-sub(
      body,
      title,
      subtitle: subtitle,
      heading-level: heading-level,
    )
  }

  if hide-footer {
    self.page-args.footer = none
    body = block(
      body,
      height: 100%,
      width: 100%,
    )

    if (title, subtitle, caption, txt).all(x => x == none) {
      body = block(
        body,
        // expand image as much as possible
        // as it is the only content
        inset: -25mm,
      )
    }
  }

  (self.methods.touying-slide)(self: self, repeat: none, body)
}

// Creates a gallery slide with a title and images
#let gallery(
  self: none,
  title: none,
  subtitle: none,
  images: (),
  columns: int,
  captions: (),
  bold-caption: true,
  heading-level: 2,
  height: auto,
  width: auto,
  fit: "cover",
  gutter: 0.5em,
  gap: 0.65em,
) = {
  let rows = (images.len() / columns)
  let body = {
    grid(
      ..images.enumerate().map(((i, img)) => {
        let caption = if i < captions.len() {
          let cap = captions.at(i)
          if cap != "" {
            cap
          } else {
            none
          }
        } else {
          none
        }

        if (bold-caption) {
          caption = text(weight: "bold", caption)
        }

        figure(
          image(img, height: height, width: width, fit: fit),
          caption: caption,
          gap: gap,
          numbering: none,
        )
      }),
      columns: columns,
      rows: (1fr) * rows,
      gutter: gutter,
    )
  }

  body = _title-and-sub(
    body,
    title,
    subtitle: subtitle,
    heading-level: heading-level,
  )

  (self.methods.touying-slide)(self: self, repeat: none, body)
}

// ====================================
// ============ REGISTER ==============
// == (incl. header, footer, colors) ==
// ====================================

#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  header: [],
  footer: [],
  footer-info-1: self => {
    [
      #self.info.title – #self.info.subtitle]
  },
  footer-info-2: self => {
    [
      #self.info.author | #utils.info-date(self)]
  },
  footer-number: self => {
    states.slide-counter.display() + " / " + states.last-slide-number
  },
  primary: aqua.darken(50%),
  ..args,
) = {
  let deco-format(it) = text(size: .6em, fill: gray, it)
  // color theme
  self = (self.methods.colors)(
    self: self,
    white: white,
    black: black,
    grey: grey,
    maroon: maroon,
    brown: brown,
    orange: orange,
    orange-bright: orange-bright,
    pink: pink,
    pink-bright: pink-bright,
    purple: purple,
    blue-dark: blue-dark,
    blue: blue,
    cyan: cyan,
    green: green,
    yellow: yellow,
    yellow-light: yellow-light,
    primary: primary,
  )
  // save the variables for later use
  self.unistra-nav = self => {
    grid(
      align: center + horizon,
      columns: (1fr, auto, auto),
      rows: 1.8em,
      components.cell(
        unistra-nav-bar(self: self),
      ),
    )
  }
  self.colorthemes = colorthemes
  self.slide-title = []
  self.simple-header = header
  self.simple-footer = footer
  self.auto-heading = true
  // set page
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.unistra-nav),
    )
  }

  let footer(self) = {
    let cell(body) = rect(
      width: 100%,
      height: 100%,
      inset: 0mm,
      outset: 0mm,
      fill: none,
      stroke: none,
      align(horizon + center, text(size: 0.6em, fill: self.colors.black, body)),
    )

    set align(center + horizon)

    let has-title-and-subtitle = (
      self.info.title,
      self.info.subtitle,
    ).all(x => x not in ("", none))

    block(
      width: 150%,
      height: 1.9em,
      stroke: (top: 0.5pt + self.colors.black),
      {
        set text(size: 1.5em)
        grid(
          columns: (auto, auto, auto),
          rows: (1.4em, 1.4em),
          gutter: 3pt,
          cell(image("../assets/unistra.svg", width: auto, height: 100%)),
          cell(
            box(
              text(
                self.info.title,
                weight: "bold",
              ) + if has-title-and-subtitle and settings.FOOTER-SHOW-SUBTITLE {
                settings.FOOTER-UPPER-SEP
              } else {
                ""
              } + if settings.FOOTER-SHOW-SUBTITLE {
                self.info.subtitle
              } + "\n" + utils.call-or-display(
                self,
                footer-info-2,
              ),
              width: 150%,
            ),
          ),
          cell(utils.call-or-display(self, footer-number)),
        )
      },
    )
  }

  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    fill: self.colors.white,
    header: if settings.SHOW-HEADER {
      header
    } else {
      none
    },
    footer: if settings.SHOW-FOOTER {
      footer
    } else {
      none
    },
    margin: _get-page-margin(),
    footer-descent: if _get-page-margin().x != 1em {
      0.2em
    } else {
      0.6em
    },
    header-ascent: 1em,
  )

  self.full-header = false
  self.full-footer = false

  // slides methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.focus-slide = focus-slide
  self.methods.gallery = gallery
  self.methods.hero = hero

  // other methods
  self.methods.alert = (self: none, it) => {
    text(fill: blue-dark, it)
  }

  self.methods.smaller = (self: none, it) => {
    text(size: 25pt, it)
  }

  self.methods.smallest = (self: none, it) => {
    text(size: 20pt, it)
  }

  // init
  self.methods.init = (self: none, body) => {
    // sets
    set heading(outlined: false)
    set text(
      fill: black,
      font: settings.FONT,
      size: 25pt,
      lang: settings.LANGUAGE,
    )
    set outline(target: heading.where(level: 1), title: none, fill: none)
    set enum(numbering: n => [*#n;.*])
    set highlight(extent: 1pt)

    // shows
    show footnote.entry: set text(size: 18pt)
    show table: set text(size: 22pt)
    show heading.where(level: 1): set text(size: 1.5em, weight: "bold")
    show heading.where(level: 2): set block(below: 1.5em)
    // color links
    show link: it => text(
      link-color,
      underline.with(offset: 3pt, extent: -1pt)(it),
    )
    // custom quote
    show quote: it => _custom-quote(it)
    show outline.entry: it => it.body
    show outline: it => block(inset: (x: 1em), it)

    body
  }
  self
}