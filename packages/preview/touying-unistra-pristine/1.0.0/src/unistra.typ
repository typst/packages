#import "@preview/touying:0.5.2": *
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
    (x: 2em, left: 2.8em)
  } else {
    (x: 1em, y: 1em)
  }
}

// Creates a custom quote element
#let _custom-quote(it) = {
  v(1em)
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

#let smaller = it => {
  text(size: 25pt, it)
}

#let smallest = it => {
  text(size: 20pt, it)
}

#let unistra-nav-bar(self) = {
  show: block.with(inset: (x: 5em))
  set text(size: 1.4em)
  grid(
    components.mini-slides(display-section: true, display-subsection: false),
  )
}

/// Creates a normal slide with a title and body
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let footer(self) = {
    let cell(body) = rect(
      width: 150%,
      height: 100%,
      inset: 0mm,
      outset: 0mm,
      fill: none,
      stroke: none,
      align(horizon + center, text(size: 0.5em, fill: self.colors.black, body)),
    )

    set align(center + horizon)

    let has-title-and-subtitle = (
      self.info.title,
      self.info.subtitle,
    ).all(x => x not in ("", none))

    block(
      width: 125%,
      height: 1.8em,
      outset: 2mm,
      stroke: (top: 0.5pt + self.colors.black),
      {
        set text(size: 1.5em)
        grid(
          columns: (auto, auto, auto),
          rows: (1.4em, 1.4em),
          gutter: 3pt,
          cell(self.info.logo),
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
                [#self.info.author | #self.info.date],
              ),
              width: 125%,
            ),
          ),
          cell(
            utils.call-or-display(
              self,
              context utils
                .slide-counter
                .display() + " / " + utils.last-slide-number,
            ),
          ),
        )
      },
    )
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      header: if settings.SHOW-HEADER {
        unistra-nav-bar(self)
      } else {
        none
      },
      footer: if settings.SHOW-FOOTER {
        footer
      } else {
        none
      },
    ),
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

/// Creates a title slide with a logo, title, subtitle, author, and date.
///
/// Example:
///
/// ```typst
/// #title-slide(title: "Override Title", logo-width: 60%)[]
/// ```
///
/// If no title or subtitle is provided, will use the info object.
///
/// - `title` (str): The title of the slide. Default: "".
///
/// - `subtitle` (str): The subtitle of the slide. Default: "".
///
/// - `logo-width` (str): The width of the logo. Default: "40%".
///
/// - `logo-height` (str): The height of the logo. Default: "auto".
///
/// - `..args`: Additional arguments to pass to the slide.
#let title-slide(
  title: "",
  subtitle: "",
  logo: "",
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()

  let body = {
    set text(fill: white)
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
              logo,
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
            #utils.display-info-date(self)
          ]),
        ),
      ),
      c1: self.colors.blue-dark,
      c2: self.colors.cyan,
    )
  }

  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
    config-common(subslide-preamble: none),
  )

  touying-slide(
    self: self,
    body,
  )
})

/// Creates a focus slide with a gradient background.
///
/// If no colors are provided, will use the theme.
///
/// Examples:
///
/// ```typst
/// #focus-slide(c1: blue, c2: cyan)[Title]
/// ```
///
/// ```typst
/// #focus-slide(theme: "smoke")[Title]
/// ```
///
/// - `c1` (color): The first color of the gradient. Default: none.
///
/// - `c2` (color): The second color of the gradient. Default: none.
///
/// - `text-color` (color): The color of the text. Default: none.
///
/// - `theme` (str): The color theme to use. Themes are defined in src/colors.typ. Possible values: "lblue", "blue", "dblue", "yellow", "pink", "neon", "mandarine", "hazy", "smoke". Default: none.
///
/// - `text-alignment` (str): The text alignment.
///
/// - `counter` (counter): The counter to use for titles. Will show a count-label before the title. Default: counter("focus-slide").
///
/// - `show-counter` (bool): Whether to show the counter. Default: true.
///
/// - `body` (content): Content of the slide.
#let focus-slide(
  c1: none,
  c2: none,
  text-color: none,
  theme: none,
  text-alignment: center + horizon,
  counter: counter("focus-slide"),
  show-counter: true,
  body,
) = touying-slide-wrapper(self => {
  assert(
    (c1 != none and c2 != none) or theme != none,
    message: "Please provide a color theme or two colors for the focus slide.",
  )

  let new-text-color = text-color
  let new-c1 = c1
  let new-c2 = c2

  if (theme != none) {
    assert(
      theme in self.store.colorthemes,
      message: "The theme " + theme + " is not defined. Available themes are: " + self
        .store
        .colorthemes
        .keys()
        .join(", "),
    )
    assert(
      self.store.colorthemes.at(theme).len() != 2 or self
        .store
        .colorthemes
        .at(theme)
        .len() != 3,
      message: "The theme " + theme + " is not a valid color theme. A valid color theme should have 2 or 3 colors.",
    )

    let theme-has-text-color = self.store.colorthemes.at(theme).len() == 3

    if (text-color == none and not theme-has-text-color) {
      new-text-color = self.colors.white
    } else {
      new-text-color = self.store.colorthemes.at(theme).at(2)
    }

    new-c1 = self.store.colorthemes.at(theme).at(0)
    new-c2 = self.store.colorthemes.at(theme).at(1)
  }

  let padding = auto
  if text-alignment == left + horizon {
    padding = 2em
  }

  let body = {
    set text(fill: new-text-color, size: 2em, weight: "bold", tracking: 0.8pt)

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
        c1: new-c1,
        c2: new-c2,
      )
    }
  }

  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
    config-common(subslide-preamble: none),
  )

  touying-slide(self: self, body)
})

/// Creates a hero slide with a high width image, and optional title, subtitle, caption and text. The image can take all the space, or be on the left or right side.
///
/// Examples:
///
/// ```typst
/// #hero(
/// image("../assets/unistra.svg", height: 70%),
/// title: "Hero",
/// subtitle: "Subtitle",
/// )
/// ```
///
/// ```typst
/// #hero(
/// image("../assets/cat1.jpg", height: 100%, width: 100%),
/// txt: "Some Text Next to Image";
/// enhanced-text: false,
/// direction: "rtl",
/// )
///
/// - `title` (str): The title of the slide. Default: none.
///
/// - `heading-level` (int): The heading level of the title. Default: 1.
///
/// - `subtitle` (str): The subtitle of the slide. Default: none.
///
/// - `caption` (str): The caption of the image. Default: none.
///
/// - `bold-caption` (bool): Whether to make the caption bold. Default: false.
///
/// - `numbering` (str): The numbering of the caption (figure). Default: none.
///
/// - `txt` (str): The text to show with the image. Default: none.
///
/// - `enhanced-text` (bool): Whether to enhance the text. Enhanced text has size 2em and weight 900. Default: true.
///
/// - `text-fill` (color): The fill color of the text. Default: none.
///
/// - `text-alignment` (str): The alignment of the text. Default: horizon + center.
///
/// - `rows` (list): The rows of the grid. Default: (1fr).
///
/// - `direction` (str): The direction of the image and text. Possible values: "ltr", "rtl", "utd", "dtu". Default: "ltr".
///
/// - `gap` (str): The gap between the image and text. Default: auto.
///
/// - `hide-footer` (bool): Whether to hide the footer. Default: true.
#let hero(
  title: none,
  heading-level: 1,
  subtitle: none,
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
  img: none,
  ..args,
) = touying-slide-wrapper(self => {
  let fig = args.pos().at(0)

  if (fig == none) {
    panic("A hero slide requires an inline image such as image('path/to/image.jpg')")
  }

  let create-figure() = {
    if (bold-caption) {
      caption = text(weight: "bold", caption)
    }

    figure(
      fig,
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

  let self = utils.merge-dicts(
    self,
    config-common(subslide-preamble: none),
  )

  touying-slide(self: self, body)
})

/// Creates a gallery slide with a title and images.
///
/// Example:
///
/// ```typst
/// #gallery(
/// image("../assets/cat1.jpg"),
/// image("../assets/cat2.jpg"),
/// title: "Gallery",
/// captions: (
///   "Cat 1",
///   "Cat 2",
/// ),
/// columns: 2
/// ```
///
/// - `title` (str): The title of the gallery. Default: none.
///
/// - `heading-level` (int): The heading level of the title. Default: 2.
///
/// - `subtitle` (str): The subtitle of the gallery. Default: none.
///
/// - `columns` (int): The number of columns. Default: auto.
///
/// - `captions` (list[str]): The list of captions. Default: ().
///
/// - `bold-caption` (bool): Whether to make the captions bold. Default: true.
///
/// - `height` (str): The height of the images. Default: auto.
///
/// - `width` (str): The width of the images. Default: auto.
///
/// - `fit` (str): The fit of the images. Can be "cover", "stretch" or "contain". Default: "cover".
///
/// - `gutter` (str): The gutter between the images. Default: 0.5em.
///
/// - `gap` (str): The gap between the images. Default: 0.65em.
#let gallery(
  title: none,
  heading-level: 2,
  subtitle: none,
  images: (),
  columns: auto,
  captions: (),
  bold-caption: true,
  height: auto,
  width: auto,
  fit: "cover",
  gutter: 0.5em,
  gap: 0.65em,
  ..args,
) = touying-slide-wrapper(self => {
  let figs = args.pos()

  if (figs == none) {
    panic("A hero slide requires at least one inline image such as image('path/to/image.jpg')")
  }

  let rows = (figs.len() / columns)
  let body = {
    set align(center + horizon)
    grid(
      ..figs.enumerate().map(((i, fig)) => {
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
          fig,
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

  let self = utils.merge-dicts(
    self,
    config-common(subslide-preamble: none),
  )

  touying-slide(self: self, body)
})

/// Registers the Unistra theme.
#let unistra-theme(
  aspect-ratio: "16-9",
  header: [],
  footer: [],
  footer-info-2: self => {
    [
      #self.info.author | #utils.info-date(self)]
  },
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-colors(
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
      primary: blue-dark,
    ),

    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: _get-page-margin(),
      footer-descent: if (_get-page-margin().at("x")) != 1em {
        0.2em
      } else {
        0.6em
      },
      header-ascent: 1em,
    ),

    config-common(
      slide-fn: slide,
      title-slide: title-slide,
      focus-slide: focus-slide,
      gallery: gallery,
      hero: hero,
      subslide-preamble: self => text(
        1.5em,
        weight: "bold",
        utils.display-current-heading(depth: self.slide-level) + "\n",
      ),
    ),

    config-methods(
      alert: utils.alert-with-primary-color,
      smaller: smaller,
      smallest: smallest,

      // init
      init: (self: none, body) => {
        // sets
        set text(
          fill: black,
          font: settings.FONT,
          size: 22pt,
          lang: settings.LANGUAGE,
        )
        set outline(target: heading.where(level: 1), title: none, fill: none)
        set enum(numbering: n => [*#n;.*])
        set highlight(extent: 1pt)

        // shows
        show strong: self.methods.alert.with(self: self)
        show footnote.entry: set text(size: 18pt)

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
      },
    ),

    config-store(
      colorthemes: colorthemes,
      slide-title: [],
      auto-heading: true,
    ),

    ..args,
  )

  body
}