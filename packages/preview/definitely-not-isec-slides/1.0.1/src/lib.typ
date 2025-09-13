#import "@preview/touying:0.6.1": *

// Project
#import "helper.typ": *
#import "logos.typ": *

// Core Imports
#import "@preview/codly:1.3.0": * // For bindings
#import "@preview/cetz:0.4.2" // For bindings
#import "@preview/fletcher:0.5.8" as fletcher: edge, node // For bindings
#import "@preview/tiaoma:0.3.0" // For auto QR generation

// Styling Macro Imports
#import "@preview/showybox:2.0.4": showybox

// -----------------------------------------------------------------------------
// General Config 
// -----------------------------------------------------------------------------

// Touying bindings for cetz
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

// Touying bindings for fletcher
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

// -----------------------------------------------------------------------------
// Slide Types
// -----------------------------------------------------------------------------

/// Normal slide for the presentation, with title (header) and footer
///
/// Example:
///
/// ```typst
/// #slide(title: [Slide Title])[
///   #lorem(20)
/// ]
/// ```
///
/// - title (content): Title for the slide
/// - alignment (alignment): Alignment of the contents of the slide
/// - outlined (boolean): If the slide shows on the PDF ToC 
///
/// -> content
#let slide(
  title: auto,
  alignment: none,
  outlined: true,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()

  // Header:
  // ---------------------------------------------------------------------------
  // [ ] Slide Title                                                [ ] Logo [ ]
  // ---------------------------------------------------------------------------
  let header(self) = {
    // Slide Title: if the user overrides the title of a certain slide, use it
    let hdr = if title != auto { title } else { self.store.header }

    show heading: set text(size: 24pt, weight: "semibold")

    grid(
      columns: (self.page.margin.left, 1fr, 1cm, auto, 1.2cm),
      block(),
      heading(level: 1, outlined: outlined, hdr),
      block(),
      move(dy: -0.31cm, institute-logo(self)),
      block(),
    )
  }

  // Footer:
  // ---------------------------------------------------------------------------
  // Slide Number [ ] First Author
  // ---------------------------------------------------------------------------
  let footer(self) = context {
    set block(height: 100%, width: 100%)
    set text(size: 15pt, fill: self.colors.footer)

    grid(
      columns: (self.page.margin.bottom - 1.68%, 1.3%, auto, 1cm),
      block(fill: self.colors.primary)[
        #set align(center + horizon)
        #set text(fill: white, size: 12pt)
        #utils.slide-counter.display()
      ],
      block(),
      block[
        #set align(left + horizon)
        #set text(size: 13pt)
        #info.at("footer", default: "")
      ],
      block(),
    )

    // Progress bar
    if self.store.progress-bar {
      place(bottom + left, float: true,
        move(dy: 1.05cm, // Bad solution, I know
          components.progress-bar(
            height: 3pt,
            self.colors.primary,
            white,
          )
        )
      )
    }
  }

  let self = utils.merge-dicts(self, config-page(
    header: header,
    footer: footer,
  ))

  set align(
    if alignment == none {
      self.store.default-alignment 
    } else {
      alignment 
    } 
  )

  touying-slide(self: self, ..args)
})

/// Title slide for the presentation
///
/// Example:
///
/// ```typst
/// #title-slide()
/// ```
///
/// -> content
#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    let footer-isec = [
      #set text(size: 13.3pt, weight: "medium")

      #let arrow-icon = [
        #move(dy: -0.05cm, dx: -0.05cm, rotate(45deg, square(
          fill: none,
          size: 0.18cm,
          stroke: (
            "top": self.colors.primary + 1.35pt,
            "bottom": none,
            "right": self.colors.primary + 1.35pt,
            "left": none,
          ),
        )))
      ]

      #v(-0.5cm)
      #box(arrow-icon) #h(0.1cm) #self.store.institute
    ]

    set page(footer: footer-isec, header: none)
    set block(below: 0pt, above: 0pt)

    // Top-right icon + text
    place(top + right, dy: -1.9cm, dx: 0.78cm, [
      #self.store.logo
    ])

    v(0.8cm)

    block(width: 83%)[
      #let title = text(size: 40.5pt, weight: "bold")[#info.at(
          "title",
          default: "",
        )]

      #move(dx: 0.04em)[
        #grid(
          columns: (0.195cm, auto),
          column-gutter: 0.7cm,
          context [
            #let s = measure(title)
            #move(dy: -0.4cm, rect(
              fill: self.colors.primary,
              height: s.height + 0.65cm,
            ))
          ],
          title,
        )
      ]
    ]

    v(0.6cm)

    block(width: 70%)[
      #text(
        size: 28.3pt,
        fill: self.colors.primary,
        weight: "bold",
      )[#info.subtitle]
    ]

    v(1.48cm)

    block(width: 70%)[
      #set text(size: 19pt)
      #if type(info.authors) == array [
        #for author in info.authors [
          #author #h(1.1em)
        ]
      ] else [
        #info.authors
      ]
    ]

    v(0.95cm)

    block(width: 70%)[
      #info.extra
    ]

    if (
      self.info.at("download-qr", default: none) != none
        and self.info.at("download-qr", default: none) != ""
    ) {
      place(bottom + right)[
        #align(center + horizon)[
          #let s = 4.9cm
          #tiaoma.qrcode(self.info.download-qr, width: s, height: s)
        ]
      ]
    }
  }

  touying-slide(self: self, body)
})

/// Standout slide for the presentation
///
/// Example:
///
/// ```typst
/// #standout-slide(title: [Text])
/// ```
///
/// - title (content): Title for the standout slide
///
/// -> content
#let standout-slide(
  title: none,
  ..args,
) = touying-slide-wrapper(self => {
  let body = {
    set align(center + horizon)
    set text(size: 28pt)
    if title != none {
      move(dy: -2.08cm)[
        #text(weight: "semibold")[#title]
      ]
    }
  }

  let self = utils.merge-dicts(self, config-page(
    header: none,
    footer: none,
  ))

  //counter("touying-slide-counter").update(n => if n > 0 { n - 1 } else { 0 })

  touying-slide(self: self, body, ..args)
})

/// Section slide for the presentation
///
/// Example:
///
/// ```typst
/// #section-slide(title: [Section A], subtitle: [Subtitle])
/// ```
///
/// - title (content): Title for the section
/// - subtitle (content): Subtitle for the section
///
/// -> content
#let section-slide(
  title: none,
  subtitle: none,
  ..args,
) = touying-slide-wrapper(self => {
  let body = {
    align(center + horizon)[
      #move(dy: -0.4cm)[
        #if title != none [
          #text(size: 36pt, weight: "semibold")[#title]
        ]

        #if subtitle != none [
          #text(size: 20pt)[#subtitle]
        ]
      ]
    ]
  }

  let self = utils.merge-dicts(self, config-page(
    header: none,
    footer: none,
  ))

  touying-slide(self: self, body, ..args)
})

/// Blank slide for free content in the presentation
///
/// Example:
///
/// ```typst
/// #blank-slide[
///   #align(center + horizon)[#lorem(5)]
/// ]
/// ```
///
/// -> content
#let blank-slide(
  ..args,
  body,
) = touying-slide-wrapper(self => {
  let body = {
    align(center + horizon)[
      #body
    ]
  }

  let self = utils.merge-dicts(self, config-page(
    header: none,
    footer: none,
    margin: 0pt,
  ))

  touying-slide(self: self, body, ..args)
})

// -----------------------------------------------------------------------------
// Main Function
// -----------------------------------------------------------------------------

/// Theme cofniguration
///
/// Example:
///
/// ```typst
/// #show: definitely-not-isec-theme.with(
///   aspect-ratio: "16-9",
///   slide-alignment: top,
///   config-info(
///     title: [Long Paper Title \ with One to Three Lines],
///     subtitle: [An optional short subtitle],
///     authors: ([*First Author*], [Second Author], [Third Author]),
///     extra: [SomeConf 2025],
///     footer: [First Author, Second Author, Third Author],
///     download-qr: "",
///   ),
///   config-common(
///     handout: false,
///   ),
///   config-colors(
///   ),
/// )
/// ```
///
/// - aspect-ratio (str): Aspect ratio for the page. See typst documentatin.
/// - slide-alignemnt (alignment): Default alignment for `#slide()`
/// - config-info (dict):
///     - title (content): Title for the presentation
///     - subtitle (content): Subtitle for the presentation
///     - authors (array): Arrray of authors (content)
///     - extra (content): Extra information for the presentation
///     - footer (content): Footer for each `#slide()`
///     - download-qr (str): URL to show on `#title-slide()` with a QR
/// - config-common (dict):
///     - handout (bool): Boolean for handout mode
/// - config-colors (dict): Colors for the presentation
///     - ... see definition of `#definitely-not-isec-theme`
#let definitely-not-isec-theme(
  aspect-ratio: "16-9",
  header: utils.display-current-heading(level: 1),
  font: "Open Sans",
  institute: [isec.tugraz.at],
  logo: tugraz-logo,
  slide-alignment: top,
  progress-bar: true,
  ..args,
  body,
) = {
  // Touying configuration
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (
        left: 1.49cm,
        right: 1.48cm,
        top: 2.6cm,
        bottom: 1.6cm,
      )
    ),
    config-store(
      header: header,
      font: font,
      institute: institute,
      logo: logo,
      default-alignment: slide-alignment,
      progress-bar: progress-bar,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: none,
      preamble: {
        codly(
          display-name: false,
          display-icon: false,
          radius: 0pt,
          stroke: 1pt + black,
          smart-indent: true,
          fill: luma(260),
          zebra-fill: luma(250),
          number-format: number => [#text(size: 12pt, fill: gray)[#number]],
          number-align: right + horizon,
          breakable: true,
        )
      }
    ),
    config-colors( // Exported from official template
      tug: rgb("e4154b"),
      primary: rgb("e4154b"),
      footer: rgb("808080"),
      isec: rgb("272733"),
      foot: rgb("e1e1e1"),
      web: rgb("0c5a77"),
      csbme: rgb("19b4e3"),
      arch: rgb("0a98a2"),
      bauw: rgb("d68e23"),
      etec: rgb("68242c"),
      mach: rgb("3066ba"),
      chem: rgb("5e60a8"),
      math: rgb("1e6934"),
      crypto: rgb("a6c947"),
      system: rgb("1171a8"),
      formal: rgb("f7931e"),
      applied: rgb("7d219e"),
      page: rgb("e4154b"),
      fore: rgb("0f0f0f"),
      back: rgb("ffffff"),
      dark: rgb("3b5a70"),
      lite: rgb("eeece1"),
      head: rgb("245b78"),
      body: rgb("e2e9ed"),
      urlA: rgb("0066d8"),
      urlB: rgb("6c2f91"),
      colA: rgb("e4154b"),
      colB: rgb("5191c1"),
      colC: rgb("a5a5a5"),
      colD: rgb("285f82"),
      colE: rgb("78b473"),
      colF: rgb("e59352"),
      tugred: rgb("e4154b"),
      tuggreen: rgb("78b473"),
      tugblue: rgb("285f82"),
      tugyellow: rgb("e59352"),
      tugcyan: rgb("19b4e3"),
      tugpurple: rgb("7d219e"),
      tugviolet: rgb("5e60a8"),
      tugmagenta: rgb("7d219e"),
      tugturquoise: rgb("0a98a2"),
      tugbrown: rgb("68242c"),
      tugblack: rgb("0f0f0f"),
      tugwhite: rgb("ffffff"),
      tuggray: rgb("a5a5a5"),
      tuggrey: rgb("a5a5a5"),
      tugdark: rgb("3b5a70"),
      tugmid: rgb("5191c1"),
      tuglite: rgb("eeece1"),
      main: rgb("e4154b"),
      emph: rgb("285f82"),
      standout: rgb("245b78"),
    ),
    config-methods(
      cover: (self: none, body) => hide(body),
      init: (
      self: none,
      body,
    ) => {
      // TUGraz uses Source Sans Pro, but its a licensed Adobe font
      set text(size: 20pt, lang: "en", region: "US", font: font)
      show emph: it => { text(self.colors.primary, it.body) }
      show cite: it => { text(self.colors.primary, it) }
      show strong: it => { text(weight: "bold", it.body) }

      // Bibliography
      set bibliography(title: none, style: "ieee")
      set cite(style: "alphanumeric")
      show bibliography: set par(spacing: 0.4cm)
      show bibliography: set grid(align: top + left)
      show bibliography: set text(17pt)
      show bibliography: t => {
        show grid.cell.where(x: 0): set text(fill: self.colors.primary)
        show grid.cell.where(x: 0): set align(top + left)
        show link: set text(fill: gray)
        t
      }

      // Lists & Enums
      set list(
        marker: ( 
          (move(dy: 0.11cm, square(width: 0.4em, height: 0.4em, fill: self.colors.primary))),
          (move(dy: 0.11cm, square(width: 0.4em, height: 0.4em, fill: black))),
          (move(dy: 0.11cm, square(width: 0.4em, height: 0.4em, fill: gray))),
        ),
        body-indent: 1.2em,
      )
      set enum(
        numbering: n => {
          square(stroke: none, fill: self.colors.primary, size: 0.53cm)[
            #align(center + horizon)[ #text(size: 12pt, fill: white)[#n] ]
          ]
        },
        body-indent: 0.6cm
      )

      // Code blocks
      show: codly-init.with()
      show raw.where(block: true): set text(size: 13pt)

      // Hotfixes, the messy part

      // https://github.com/touying-typ/touying/issues/136
      set par(spacing: 0.65em)

      body
    }),
    ..args,
  )

  body
}

// -----------------------------------------------------------------------------
// Macros
// -----------------------------------------------------------------------------

/// Macro for a pdfpc note
///
/// Example:
///
/// ```typst
///   #note("This will show on pdfpc speaker notes")
/// ```
///
/// - text (str): Note for pdfpc
///
/// -> content
#let note(text) = [
  #pdfpc.speaker-note(text)
]

/// Quote block for phrases. Has a color.primary rectangle in the left
///
/// Example:
///
/// ```typst
/// #quote-block[
///   #lorem(10)
/// ]
/// ```
///
/// - top-pad (length): Extra height of the quote colored block
/// - color (color): Color of the quote block
/// - spacing (length): Spacing after the `#quote-block`
///
/// -> content
#let quote-block(
  top-pad: 0.55cm,
  color: none,
  spacing: 0.3cm,
  body,
) = [
  #touying-fn-wrapper((self: none) => [
    // Grid with the design
    #let g(s: 0cm, body) = [
      #grid(
        columns: (0.195cm, auto),
        column-gutter: 0.7cm,
        row-gutter: 0cm,
        [
        #rect(
          fill: if color == none { self.colors.primary } else { color },
          height: s + top-pad,
        )
      ],
        align(horizon, body),
      )
    ]

    // We compute its "auto" heigth and then print it with the correct height
    #layout(size => {
      let (height,) = measure(width: size.width, g(body))
      g(s: height, body)
    })

    #v(spacing)
  ])
]

/// Block with title and content
///
/// Example:
///
/// ```typst
/// #color-block(title: [Advantages])[
///   - A
///   - B
///   - C
/// ]
/// ```
///
/// - title (content): Title for the color block
/// - icon (str): Icon to show at the left of the title (Tableau Icons) https://tabler.io/icons
/// - spacing (length): Spacing before and after the color block
/// - color (color): Color for the title block
/// - color-body (color): Color for the background of the body
///
/// -> content
#let color-block(
  title: [],
  icon: none,
  spacing: 0.78em,
  color: none,
  color-body: none,
  body
) = [
  #import "@preview/tableau-icons:0.331.0": *
  #touying-fn-wrapper((self: none) => [
    #show emph: it => {
      text(weight: "medium", fill: self.colors.primary, it.body)
    }

    #showybox(
      title-style: (
        color: white,
        sep-thickness: 0pt,
      ),
      frame: (
        //inset: 0.4em,
        radius: 0pt,
        thickness: 0pt,
        border-color: if color == none { self.colors.primary } else { color },
        title-color: if color == none { self.colors.primary } else { color },
        body-color: if color-body == none { self.colors.lite } else { color-body },
        inset: (x: 0.55em, y: 0.65em),
      ),
      above: spacing,
      below: spacing,
      title: if icon == none {
        align(horizon)[#strong(title)]
      } else {
        align(horizon)[
    #draw-icon(icon, height: 1.2em, baseline: 20%, fill: white) #h(0.2cm) #strong[#title]
        ]
      },
      body,
    )
  ])
]

/// Showcase the colors of the slide
///
/// Example:
///
/// ```typst
/// #showcase-colors
/// ```
///
/// -> content
#let showcase-colors = [
    #touying-fn-wrapper((self: none) => [
      #set rect(width: 7.4cm, height: 1.5cm)
      #set text(fill: white)
      #set align(center)
      #grid(columns: 3, rows: 6, column-gutter: 1.8cm, row-gutter: 0.05cm, align: left,
        rect(fill: self.colors.isec)[isec],
        rect(fill: self.colors.tug)[tug = main],
        rect(fill: self.colors.colA)[colA = tugred],
        rect(fill: self.colors.csbme)[csbme = tugcyan],
        rect(fill: self.colors.fore)[fore],
        rect(fill: self.colors.colB)[colB = tugmid],
        rect(fill: self.colors.crypto)[crypto],
        rect(fill: self.colors.back)[#text(fill: black)[back]],
        rect(fill: self.colors.colC)[colC = tuggray],
        rect(fill: self.colors.system)[system],
        rect(fill: self.colors.foot)[#text(fill: black)[foot]],
        rect(fill: self.colors.colD)[colD = tugblue],
        rect(fill: self.colors.formal)[formal],
        rect(fill: self.colors.emph)[emph],
        rect(fill: self.colors.colE)[colE = tuggreen],
        rect(fill: self.colors.applied)[applied = tugpurple],
        rect(fill: self.colors.lite)[#text(fill: black)[lite]],
        rect(fill: self.colors.colF)[colF = tugyellow],
      )
    ])
]

//vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
