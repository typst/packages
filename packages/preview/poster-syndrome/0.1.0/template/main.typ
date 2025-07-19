#import "@preview/poster-syndrome:0.1.0": *
#import "@preview/codetastic:0.2.2": qrcode

#let debug-boxes = true
#let debug-boxes = false

// initialise with defaults
#let (poster, frame) = poster-syndrome-setup()

#let qr = block(qrcode(
    "https://en.m.wikipedia.org/wiki/The_Classic_of_Tea",
    width: 2cm,
    ecl: "l",
    colors: (white, _default-theme.palette.highlight.darken(40%)),
    quiet-zone: 0,
  ))

#show: poster.with(
  title: text[to train a teapet],
  subtitle: text[how to · why · advanced techniques],
  authors: text[Huang Long Shan\
    Qing Long Shan \
    Zhaozhuang Nenni],
  affiliation: text(size: 28pt)[Yixing mines],
  qr-code: qr,
  date: datetime.today().display(),
  cover-image: image("devil.jpg"),
  credit: "Teapet",
  foreground: _page-foreground(frames:none), // show boxes with frames: _default-frames
  background: _page-background,
)


#frame(tag: "introduction")[
  #set par(justify: true)
  #columns(2)[

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore $alpha approx beta$ et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore@tea1,@tea2.

    #colbreak()

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat@tea3.

    $
      alpha = beta
    $

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore. Ut enim ad minim veniam, quis nostrud exercitation@tea4.
  ]
]


#frame(tag: "description")[

  == an ancient art

  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

  #image("fig-tea1.svg")

  === Everything is on the table

  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

  #block[
    #show strong: set text(weight: 200)
    #show strong: emph
    #align(center)[#grid(
        columns: (1fr, auto, auto, auto, auto, auto, auto),
        column-gutter: 1pt,
        row-gutter: auto,
        align: horizon,
        inset: (x, y) => if (y > 1) {
          (
            x: 6pt,
            y: 8pt,
          )
        } else {
          (
            x: 6pt,
            y: 10pt,
          )
        },
        grid.hline(
          start: 0,
          end: 7,
          stroke: _default-theme.palette.highlight.darken(10%) + 2pt,
        ),
        [*species*],
        [*length*],
        [*depth*],
        [*approval*],
        [*mass*],
        [*porosity*],
        [*year*],
        grid.hline(
          start: 0,
          end: 7,
          stroke: _default-theme.palette.highlight.darken(10%) + 0.5pt,
        ),
        [Elephant],
        [39.1],
        [18.7],
        [181],
        [3750],
        [light],
        [1970],
        [Demon],
        [39.5],
        [17.4],
        [186],
        [3800],
        [compact],
        [1970],
        [Demon],
        [40.3],
        [18.0],
        [195],
        [3250],
        [compact],
        [1990],
        [Frog],
        [NA],
        [NA],
        [NA],
        [NA],
        [NA],
        [1990],
        [Elephant],
        [36.7],
        [19.3],
        [193],
        [3450],
        [compact],
        [1990],
        [Frog],
        [39.3],
        [20.6],
        [190],
        [3650],
        [light],
        [1990],
        grid.hline(
          start: 0,
          end: 7,
          stroke: _default-theme.palette.highlight.darken(10%) + 2pt,
        ),
      )
    ]

  ]

  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et magna aliqua.

]

#frame(tag: "methods")[
  #columns(2, gutter: 24pt)[
    == technically speaking

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

    $
      E & eq T plus U\
      & eq minus frac(G m M, lr(|bold(r)|)) plus 1 / 2 m lr(|bold(v)|)^2\
      & eq m lr((minus frac(G M, lr(|bold(r)|)) plus lr(|bold(omega) times bold(r)|)^2 / 2))\
      & eq minus frac(G m M, 2 lr(|bold(r)|))
    $

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

    $ d P lr((1 minus M^2)) eq rho V^2 lr((frac(d A, A))) $


    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

    #colbreak()

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

    $
      frac(diff bold(u), diff t) plus lr((bold(u) dot.op nabla)) bold(u) eq minus 1 / rho nabla P plus nu nabla^2 bold(u)
    $

    === More nonsense

    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

    $ integral.triple Q thin d V plus integral.double F thin d bold(A) eq 0 $

    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.

  ]
  #block(above: 0.2em)[#image("fig-tea2.svg")]

  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.

  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.
]


#frame(tag: "illustration")[
  
  // Green tea (绿茶 - lǜchá), White tea (白茶 - báichá), Yellow tea (黄茶 - huángchá), Black tea (红茶 - hóngchá), Oolong tea (乌龙茶 - wūlóngchá), and Dark tea (黑茶 - hēichá)

  #let li = (
    insta(image("green-tea.jpg"), description: text[白茶]),
    insta(image("white-tea.jpg"), description: text[绿茶]),
    insta(image("yellow-tea.jpg"), description: text[黄茶]),
    insta(image("red-tea.jpg"), description: text[乌龙茶]),
    insta(image("oolong-tea.jpg"), description: text[红茶]),
    insta(image("dark-tea.jpg"), description: text[黑茶]),
  )


  #grid(columns: 6 * (1fr,), column-gutter: 10pt, ..li)

]

#frame(tag: "outlook")[
  #columns(3)[

    == outlook

    Lorem ipsum dolor sit amet,

    1. consectetur adipiscing elit, sed do eiusmod tempor incididunt ut

    2. labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

    3. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,

    4. sunt in culpa qui officia deserunt mollit anim id est laborum.

    Lorem ipsum dolor sit amet, consectetur elit.


    == recent developments

    Lorem ipsum dolor sit amet, consectetur adipiscing elit,

    - Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

    - Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

    - Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

    Mollit anim id est laborum,

    ```r
    head(teapets) |>
      tail()
    ```
    #colbreak()
    == references
    #set par(justify: false)
    #set text(size: 20pt)
    #bibliography("tea.bib", title: none, style: "spie")

    == Acknowledgments
    #set text(size: 24pt)
    Thanks for the tea
  ]
]
