#import "@preview/touying:0.6.1": *
#import "colors.typ": *
#import "icons.typ": *
#import "utils.typ": *

#let unistra-nav-bar(self) = {
  show: block.with(inset: (x: 5em))
  set text(size: 1.4em)
  place(
    grid(
      components.mini-slides(
        display-section: true,
        display-subsection: false,
      ),
    ),
    dy: -1.4em,
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
      width: 100%,
      height: 100%,
      inset: 0mm,
      outset: 0mm,
      fill: none,
      stroke: none,
      text(size: 0.5em, fill: self.colors.black, body),
    )

    let author = self.info.author
    let date = self.info.date
    if self.store.footer-hide.contains("author") {
      author = none
    }

    if self.store.footer-hide.contains("date") {
      date = none
    }

    set align(center + horizon)
    block(width: 101%, height: -25%, stroke: (top: 0.5pt + self.colors.black), {
      set text(size: 1.5em)

      // give priority to short, since long is also used in title slide
      let title = self.info.title
      if (self.info.short-title != auto) {
        title = self.info.short-title
      }

      let first-col-width = auto
      let second-col-width = 75%
      if self.info.logo.func() == image {
        first-col-width = 19%
        second-col-width = 71.5%
      }

      grid(
        columns: (first-col-width, second-col-width, 8.5%),
        rows: 0.5em,
        stroke: (x: 1pt + self.colors.black),
        cell(box(self.info.logo, height: 100%)),
        cell(box(
          width: 100%,
          text(
            title, // either title or short-title
            weight: "bold",
          )
            + self.store.footer-first-sep
            + if _is(author) { author }
            + if _is(date) and _is(author) {
              self.store.footer-second-sep
            } else { "" }
            + if _is(date) { date },
        )),
        cell(utils.call-or-display(self, context {
          let current = int(utils.slide-counter.display())
          let last = int(utils.last-slide-counter.display())
          if current > last {
            (
              text(self.store.footer-appendix-label, style: "italic")
                + str(current)
            )
          } else {
            str(current)
          }
        }
          + " / "
          + utils.last-slide-number)),
      )
    })
  }

  let self = utils.merge-dicts(self, config-page(
    header: if self.store.show-header {
      unistra-nav-bar(self)
    } else {
      none
    },
    footer: if self.store.show-footer {
      footer
    } else {
      none
    },
    // todo: change if no footer/header, etc.
    margin: (x: 3em, y: 2em),
  ))

  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Creates a outline slide with outlined headings.
///
/// Example:
///
/// ```typst
/// #outline-slide(title: "Outline")
/// ```
///
/// - `title` (str): The title of the slide. Default: "Outline".
///
/// - `title-size` (length): The size of the title. Default: 1.5em.
///
/// - `title-margin` (length): The margin between the title and the content. Default: -0.5em.
///
/// - `content-size` (length): The size of the content. Default: 1.2em.
///
/// - `fill` (color): The fill color of the outline block. Default: nblue.D.
///
/// - `outset` (length): The outset of the outline block. Default: 30pt.
///
/// - `height` (ratio): The height of the outline block. Default: 80%.
///
/// - `radius` (ratio): The radius of the outline block. Default: 7%.
///
/// - `..args`: Additional arguments to pass to the outline.
#let outline-slide(
  title: utils.i18n-outline-title,
  title-size: 1.5em,
  title-margin: -0.5em,
  content-size: 1.2em,
  fill: nblue.D,
  outset: 30pt,
  height: 80%,
  width: 100%,
  radius: 7%,
  ..args,
) = {
  let body = {
    text(
      title-size,
      weight: "bold",
      title,
    )

    v(title-margin)

    // Retrieving focus slides titles, which have a specific heading level applied.
    let outline-content = outline(
      target: selector.or(..range(99, 100).map(l => heading.where(level: l))),
      ..args,
    )

    // We're increasing the width of the outline content slightly to compensate for the lesser width applied to the titles of focus slides.
    // Otherwise, the outline content would be too narrow and would linebreak prematurely.
    text(content-size, box(outline-content, width: width * 1.1))
  }

  body = place(
    block(
      body,
      fill: fill,
      outset: outset,
      height: height,
      width: width,
      radius: radius,
    ),
    dy: -0.5em,
  )

  slide(body)
}

/// Creates a title slide with a logo, title, subtitle, author, email, and date.
///
/// Example:
///
/// ```typst
/// #title-slide(title: "Override Title", logo: image("../assets/unistra.svg", width: 60%))
/// ```
///
/// If no title or subtitle is provided, will use the info object.
///
/// - `title` (str): The title of the slide. Default: "".
///
/// - `subtitle` (str): The subtitle of the slide. Default: "".
///
/// - `logo` (content): Logo to display in the upper left corner of the slide. Default: "".
///
/// - `logos` (array): List of logos to display in a row in the upper left corner of the slide. Default: ().
///
/// - `..args`: Additional arguments to pass to the slide.
#let title-slide(
  title: "",
  subtitle: "",
  logo: "",
  logos: (),
  hide: (),
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()

  let nb-logos = logos.len()

  if logo != "" and nb-logos > 0 {
    panic("'logo' and 'logos' cannot be set at the same time.")
  }

  let logo-body = none
  if nb-logos == 0 {
    logo-body = logo
  } else {
    logo-body = grid(
      columns: if nb-logos > 0 {
        nb-logos
      } else {
        1
      },
      ..(logos).map(logo => logo),
    )
  }

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
          columns: 1fr,
          rows: (6em, 6em, 4em, 4em),
          logo-body,
          _cell([
            #text(size: 2em, weight: "bold", if (title != "") {
              title
            } else {
              info.title
            })
            #linebreak()
            #text(size: 1.7em, weight: "regular", if (subtitle != "") {
              subtitle
            } else {
              info.subtitle
            })
          ]),

          _cell([
            #if ((none, "").all(x => x != info.subtitle)) {
              linebreak()
            }
            #set text(size: 1.5em, fill: self.colors.white)
            #text(weight: "bold", info.author)
            #if "email" in info {
              linebreak()
              text(info.email, size: 0.8em)
            }
          ]),
          if "date" not in hide {
            _cell([
              #set text(fill: self.colors.white.transparentize(25%))
              #utils.display-info-date(self)
            ])
          },
        ),
      ),
      c1: self.colors.nblue.E,
      c2: self.colors.cyan.E,
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
/// - `text-size` (length): The size of the text. Default: 2em.
///
/// - `theme` (str | int): The color theme name or ID (1-18) to use. Themes are defined in src/colors.typ. Default: none.
///
/// - `icon` (function): The icon to show above the text. Should be `us-icon()` or `nv-icon()`.
///
/// - `icon-size` (length): The size of the icon. Default: 1.7em.
///
/// - `counter` (counter): The counter to use for titles. Will show a count-label before the title. Default: counter("focus-slide").
///
/// - `show-counter` (bool): Whether to show the counter. Default: true.
///
/// - `outlined` (bool): Whether to outline the heading and make it appear in an outline slide. Default: true.
///
/// - `body` (content): Content of the slide.
#let focus-slide(
  c1: none,
  c2: none,
  text-color: none,
  text-size: 2em,
  theme: none,
  icon: none,
  icon-size: 1.7em,
  counter: counter("focus-slide"),
  show-counter: true,
  outlined: true,
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
    let theme-colors = none
    let theme-name = none

    if (type(theme) == int) {
      let theme-id-str = str(theme)
      assert(
        theme-id-str in self.store.colorthemes-ids,
        message: "The theme ID "
          + str(theme)
          + " is not defined. Available theme IDs are: "
          + self.store.colorthemes-ids.keys().join(", "),
      )
      theme-colors = self.store.colorthemes-ids.at(theme-id-str)
    } else {
      assert(
        theme in self.store.colorthemes,
        message: "The theme "
          + theme
          + " is not defined. Available themes are: "
          + self.store.colorthemes.keys().join(", "),
      )
      theme-colors = self.store.colorthemes.at(theme)
      theme-name = theme
    }

    assert(
      theme-colors.len() == 2 or theme-colors.len() == 3,
      message: "The theme "
        + (if theme-name != none { theme-name } else { str(theme) })
        + " is not a valid color theme. A valid color theme should have 2 or 3 colors.",
    )

    let theme-has-text-color = theme-colors.len() == 3

    if (text-color == none and not theme-has-text-color) {
      new-text-color = self.colors.white
    } else if (theme-has-text-color) {
      new-text-color = theme-colors.at(2)
    }

    new-c1 = theme-colors.at(0)
    new-c2 = theme-colors.at(1)
  }

  let body = {
    set text(
      fill: new-text-color,
      size: text-size,
      weight: "bold",
      tracking: 0.8pt,
    )

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
          grid(
            grid.cell(
              if (_is(icon)) {
                text(size: icon-size)[#icon]
              },
              align: center + bottom,
            ),
            grid.cell(
              heading(
                // we define a high level to avoid the outline slide
                // displaying other types of headings
                // that would be outlined by default
                level: 99,
                outlined: outlined,
                bookmarked: outlined,
                // Setting a box with a width slightly smaller than 100% to create some margin and more space for the text.
                // This avoids having to linebreak manually to achieve that, as the linebreak would appear in the outline slide.
                box(
                  width: 90%,
                  if (count-label != none) {
                    // bold does not change anything on the focus-slide; used only for the outline slide
                    text(weight: "bold", count-label)
                  }
                    + body,
                ),
              ),
              align: center + top,
            ),
            columns: 1fr,
            // add third auto row to allow automatic adjustement with longer text
            rows: (1.1fr, auto, 1fr),
            row-gutter: 0.43em,
            align: center + horizon,
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
/// #let custom-enhance = txt => text(size: 2em, weight: 900, fill: orange, txt)
/// #hero(
/// image("../assets/cat1.jpg", height: 100%, width: 100%),
/// txt: (text: "Some text next to the image", enhanced: custom-enhance),
/// direction: "rtl",
/// )
/// ```
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
/// - `columns` (int | relative | fraction | array): The columns of the grid. Default: (1fr).
///
/// - `rows` (int | relative | fraction | array): The rows of the grid. Default: (1fr).
///
/// - `txt` (dict): The text to display next to the image, along with its style. Contains the following keys: text, enhanced, fill, align.
///   - `text` (content): The text to display. Default: none.
///   - `enhanced` (bool | function): Whether to enhance the text. Can pass a custom function that will act as a callback to enhance the text. Default: true.
///   - `fill` (color): The fill color of the text. Default: none.
///   - `align` (alignment): The alignment of the text. Default: horizon + center.
///
/// - `direction` (str): The direction of the image and text. Possible values: "ltr", "rtl", "utd", "dtu". Default: "ltr".
///
/// - `gap` (int | relative | fraction | array): The gap between the image and text. Default: auto.
///
/// - `hide-footer` (bool): Whether to hide the footer. Default: true.
///
/// - `fill` (color): The fill color of the slide. Only works when `hide-footer` is true. Default: none.
///
/// - `inset` (length): How much negative inset should be applied to the slide to make the image take all the space. Only works when `hide-footer` is true and there is no title, subtitle or caption. Default: -25mm.
///
/// - `footnote` (bool): Whether to leave some width to accomodate for a footnote. Default: false.
#let hero(
  title: none,
  heading-level: 1,
  subtitle: none,
  caption: none,
  bold-caption: false,
  numbering: none,
  columns: (1fr, 2fr),
  rows: 1fr,
  txt: (:),
  direction: "ltr",
  gap: auto,
  hide-footer: true,
  fill: none,
  inset: -25mm,
  footnote: false,
  ..args,
) = touying-slide-wrapper(self => {
  let fig = args.pos().at(0)

  if (txt != (:) and "text" not in txt) {
    panic("The txt argument value must contain a text key")
  }

  // merge with default values
  let merged-txt = utils.merge-dicts(
    (
      text: none,
      enhanced: true,
      fill: none,
      align: horizon + center,
    ),
    txt,
  )

  if (fig == none) {
    panic(
      "A hero slide requires an inline image such as image('path/to/image.jpg')",
    )
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
    _cell(create-figure())
  }

  let create-text-cell() = {
    let new-txt = merged-txt.text
    if type(merged-txt.enhanced) == bool and merged-txt.enhanced {
      new-txt = text(size: 2em, weight: 900, merged-txt.text)
    } else if (
      type(merged-txt.enhanced) == bool and not merged-txt.enhanced
    ) {
      new-txt = merged-txt.text
    } else if type(merged-txt.enhanced) == function {
      new-txt = (merged-txt.enhanced)(merged-txt.text)
    } else {
      panic("Value of enhanced key must be a boolean or a function")
    }

    _cell(
      new-txt,
      height: 100%,
      width: 100%,
      inset: 20mm,
      alignment: merged-txt.align,
      fill: merged-txt.fill,
    )
  }

  let create-grid(
    first-cell,
    second-cell,
    columns: columns,
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
    if (merged-txt.text == none) {
      align(center, create-figure())
    } else {
      if direction == "ltr" {
        create-grid(
          create-text-cell(),
          create-image-cell(),
          column-gutter: gap,
        )
      } else if direction == "rtl" {
        create-grid(
          create-image-cell(),
          create-text-cell(),
          column-gutter: gap,
          // columns are reversed in this direction
          columns: (2fr, 1fr),
        )
      } else if direction == "utd" {
        create-grid(
          create-image-cell(),
          create-text-cell(),
          columns: 1fr,
          rows: (1fr, 1fr),
          row-gutter: gap,
        )
      } else if direction == "dtu" {
        create-grid(
          create-text-cell(),
          create-image-cell(),
          columns: 1fr,
          rows: (1fr, 1fr),
          row-gutter: if gap != auto {
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
      v(heading-level * -0.6em) + title,
      subtitle: subtitle,
      heading-level: heading-level,
    )
  }

  if hide-footer or footnote {
    body = block(
      body,
      fill: fill,
      height: if (footnote) {
        80%
      } else {
        100%
      },
      width: 100%,
    )
  }

  if (title, subtitle, caption).all(x => x == none) {
    body = block(
      body,
      // expand image as much as possible
      // as it is the only content
      // todo: calculate this automatically
      inset: inset,
    )
  }

  let self = utils.merge-dicts(self, config-common(subslide-preamble: none))

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
/// - `height` (length): The height of the images. Default: auto.
///
/// - `width` (length): The width of the images. Default: auto.
///
/// - `fit` (str): The fit of the images. Can be "cover", "stretch" or "contain". Default: "cover".
///
/// - `gutter` (int | relative | fraction | array): The gutter between the images. Default: 0.5em.
///
/// - `gap` (int | relative | fraction | array): The gap between the images. Default: 0.65em.
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
    panic(
      "A gallery slide requires at least one inline image such as image('path/to/image.jpg')",
    )
  }

  let rows = (figs.len() / columns)
  let body = {
    set align(center + horizon)
    grid(
      ..figs
        .enumerate()
        .map(((i, fig)) => {
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
      rows: 1fr * rows,
      gutter: gutter,
    )
  }

  body = _title-and-sub(
    body,
    title,
    subtitle: subtitle,
    heading-level: heading-level,
  )

  let self = utils.merge-dicts(self, config-common(subslide-preamble: none))

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
      red: red,
      pink: pink,
      purple: purple,
      violet: violet,
      nblue: nblue,
      blue: blue,
      cyan: cyan,
      ngreen: ngreen,
      green: green,
      camo: camo,
      yellow: yellow,
      primary: nblue.E,
    ),

    config-page(
      paper: "presentation-" + aspect-ratio,
      footer-descent: 0em,
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

    config-store(
      // colorthemes from colors.typ
      colorthemes: colorthemes,
      colorthemes-ids: colorthemes-ids,
      show-header: false,
      show-footer: true,
      // footer first separator
      footer-first-sep: " | ",
      // footer second separator
      footer-second-sep: " | ",
      footer-appendix-label: "A-",
      font: ("Unistra A", "Segoe UI", "Roboto"),
      // type of left/right quote to use for the custom "Quote" element
      quotes: (
        left: "« ",
        right: " »",
        outset: 0.5em,
        margin-top: 0em,
      ),
      // elements to hide from footer ("author", "date")
      footer-hide: (),
      link-icons: (
        "video": (
          regex("\.(gif|mp4|avi|mov|webm|mkv)$"),
          nv-icon("file-video"),
        ),
        "image": (
          regex("\.(jpg|jpeg|png|bmp|svg|webp|tiff)$"),
          nv-icon("picture-layer"),
        ),
        "audio": (regex("\.(mp3|wav|ogg|flac|m4a)$"), nv-icon("file-audio")),
        "archive": (regex("\.(zip|tar|gz|bz2|xz)$"), nv-icon("folders")),
        "code": (
          regex(
            "\.(css|html|js|ts|tsx|json|xml|yml|toml|ini|cfg|bat|sh|ps1|py|java|c|cpp|h|hpp|rs|go|php|rb|pl|swift)$",
          ),
          us-icon("code"),
        ),
        "facebook": (regex("(fb|facebook)\.com/"), nv-icon("facebook")),
        "pinterest": (regex("pinterest\.com/"), nv-icon("pinterest")),
        "tumblr": (regex("tumblr\.com/"), nv-icon("tumblr")),
        // do not use Nova's "youtube" icon, too old
        // icon "play" is the closest to current logo
        "youtube": (
          regex("(youtube\.com|youtu\.be)/"),
          nv-icon("video-control-play"),
        ),
      ),
    ),

    config-methods(
      alert: utils.alert-with-primary-color,
      smaller: smaller,
      smallest: smallest,

      // init
      init: (self: none, body) => {
        // states
        let in-outline = state("in-outline", false)

        // sets
        set text(
          fill: black,
          font: self.store.font,
          size: 25pt,
        )
        set outline(target: heading.where(level: 1), title: none)
        set outline.entry(fill: none)
        set enum(numbering: n => [*#n;.*])
        //set list(spacing: 1em)
        // the default [‣] icon does not align properly
        set list(marker: ([•], [--]))
        set highlight(extent: 1pt)

        // shows
        show strong: self.methods.alert.with(self: self)
        show footnote.entry: set text(size: 18pt)

        show heading.where(level: 1): set text(size: 1.5em, weight: "bold")
        show heading.where(level: 2): set block(below: 1.5em)
        // color and iconize links
        show link: it => context {
          // except for the outline slide
          if in-outline.get() {
            text(weight: "regular", it)
          } else {
            let dest = if type(it.dest) == str {
              it.dest
            } else {
              str(it.dest)
            }

            let styled-link = text(
              link-color,
              underline.with(
                offset: 3pt,
                extent: -1pt,
              )(it),
            )

            if self.store.link-icons.len() > 0 {
              let found = none
              for pair in self.store.link-icons.values() {
                let (pattern, icon) = pair
                if dest.matches(pattern).len() > 0 {
                  found = icon
                  break
                }
              }
              if found != none {
                [#styled-link #super(found)]
              } else {
                styled-link
              }
            } else {
              styled-link
            }
          }
        }
        // custom quote
        show quote: it => _custom-quote(
          it,
          self.store.quotes.at("left"),
          self.store.quotes.at("right"),
          self.store.quotes.at("outset"),
          self.store.quotes.at("margin-top"),
        )
        show outline.entry: it => (
          // support links for outline entries
          link(it.element.location(), it.body()) + linebreak()
        )
        show outline: it => context {
          // state used to not color links in outline
          in-outline.update(true)
          block(inset: (x: 1em), it)
          in-outline.update(false)
        }
        // bibliography
        show bibliography: set text(size: 15pt)
        show bibliography: set par(spacing: 0.5em, leading: 0.4em)
        show bibliography: it => {
          // fixes https://github.com/typst/hayagriva/issues/114
          show "https://doi.org/": ""
          it
        }

        body
      },
    ),

    ..args,
  )

  body
}
