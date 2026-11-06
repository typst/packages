#import "/theofig.typ": *
#set page(paper: "a6", height: auto, margin: 6mm)

// show rule for all (optionally except some)
#show figure-where-kind-in(
  theofig-kinds, except: ("proposition",)
): it => {
  show figure.caption: strong.with(delta: -300)
  show: emph 
  show figure.caption: emph // double emph = no emph
  it
}

// show rule for one
#show figure.where(kind: "remark"): set text(blue)

// styling arguments for one
#let proposition = proposition.with(
  format-caption: (underline, text.with(tracking: 3pt)),
  format-body: smallcaps,
)

#definition[#lorem(15)]
#theorem[#lorem(15)]
#remark[#lorem(15)]

#proposition[#lorem(15)]
