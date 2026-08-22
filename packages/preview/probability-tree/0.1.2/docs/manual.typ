#import "@preview/tidy:0.4.3"
#import "@preview/showybox:2.0.4" as sb
#import "@local/probability-tree:0.1.2": proba-tree, sn, sp

// Parse the module containing your doc-comments
#let docs = tidy.parse-module(
  read("../src/probability-tree.typ"),
  name: "Probability Tree — manual",
  preamble: "#import \"@local/probability-tree:0.1.2\": *\n",
)

// Render the documentation using a predefined style

#align(center)[
  #text(size: 24pt, weight: "bold")[Probability Tree]

  #v(.5em)

  #text(
    size: 16pt,
    weight: "bold",
  )[-- Quick reference --]

  #v(.5em)


  #sb.showybox(
    width: 70%,
    align: center,
    frame: (
      body-color: luma(.9),
    ),
    align(center)[
      #proba-tree(
      data: (
      sn([$Omega$], style: (fill: green, size: 1.2em)),
      (sn([M], style: (fill: green)), $p_1$, ([$E$], $alpha$), ([$F$], $beta$), ([$G$], $1-alpha-beta$)),
      ([$N$], $q_1$, ([$B$], $q$), ([$overline(B)$], $1-q$)),
      ([$P$], sp($1-p_1-q_1$, style: (highlight: aqua)), ([$B$], $q$), ([$overline(B)$], $1-q$)),
      ),
      proba-position: "on",
      proba-distance: .3,
      // proba-sloped : false,
      proba-padding: 3pt,
      node-padding: 0.3,
      h: 2.5,
      v: .9,
      proba-style: (fill: red),
      node-style: (fill: blue),
      )
    ],
  )
]

#v(.5em)

#align(center)[
  #text(size: 16pt, weight: "bold")[-- Overlaying custom labels (`extra`) --]
]

#v(.5em)

#sb.showybox(
  width: 70%,
  align: center,
  frame: (
    body-color: luma(.9),
  ),
  align(center)[
    #proba-tree(
      h: 2.5,
      v: 0.05,
      node-style: (fill: blue),
      data: (
        [$Omega$],
        ($F$, $$,
          ($F$, $$, ($F$, $$), ($P$, $$)),
          ($P$, $$, ($F$, $$), ($P$, $$)),
        ),
        ($P$, $$,
          ($F$, $$, ($F$, $$), ($P$, $$)),
          ($P$, $$, ($F$, $$), ($P$, $$)),
        ),
      ),
      extra: (pos, draw) => {
        let issues = ("FFF", "FFP", "FPF", "FPP", "PFF", "PFP", "PPF", "PPP")
        for i in range(0, 8) {
          let p = pos.at("N4" + str(i + 1))
          draw.content(
            (p.at(0) + 0.35, p.at(1)),
            anchor: "west",
            [$space arrow.long.r space #issues.at(i)$],
          )
        }
      },
    )
  ],
)

#v(.5em)

#tidy.show-module(docs, style: tidy.styles.default, show-module-name: false)
