#import "style/formatting.typ": *

// Action Icons
#let A = (
  box(image("style/action-icons/single.svg", height: 1em))
)
#let AA = (
  box(image("style/action-icons/double.svg", height: 1em))
)
#let AAA = (
  box(image("style/action-icons/triple.svg", height: 1em))
)
#let R = (
  box(image("style/action-icons/reaction.svg", height: 1em))
)
#let F = (
  box(image("style/action-icons/free.svg", height: 1em))
)

#let boxTop(info) = [
  #text(size: 1.3em, weight: "extrabold")[#align(center)[#info\ ]]
]

#let pftab(name, columns: (1fr, 4fr), breakable: false, ..contents) = [
  #block(breakable: breakable)[
  *#smallcaps(text(size: 1.3em)[#upper(name)])*
  #v(-.5em)
  #table(
  columns: columns,
  align: (col, row) =>
   if col == 0 { center }
    else { center },
  fill: (col, row) => if row == 0 {rgb("002a16") } else if calc.odd(row+1) { colors.pfwhite } else { colors.otherRow },
  inset: 5pt,
  stroke: none,
  // align: horizon,
  ..contents
  )
  #v(1em)
]]

#let chapHeader(chapNum, title, desc) = [
  #v(1em)
  #set text(fill: colors.pfgreen)
  #place(
    top + center,
    scope: "parent",
    float: true,
  )[
    #block(
      fill: rgb("#f4eee0"),
      stroke: (
        bottom: 3pt + rgb("#664200"),
        rest: none,
      ),
      outset: (x: 100%, y: 13pt),
      text(weight: "extrabold")[#text(1.4em)[#upper(chapNum)] \ #text(1.6em)[#upper(title)] \ #text(1.2em, style: "italic")[#desc]])
    #v(1em)
  ]
]

#let note(info) = [
  #v(1em)
  #box(
    fill: rgb("#e2d7d3"),
    inset: 7pt,
    // outset: 2pt,
  )[
    #show heading: it => align(center)[#it] 
    #info
  ]
]

#let attention(content) = [
  #v(1em)
  #box(
    fill: rgb("#eadcb7"),
    stroke: (1pt + black),
    inset: 4pt,
  )[
    #show heading: it => align(center)[#it] 
    #content
  ]
]

#let readAloud(content) = [
  #v(1em)
  #line(stroke: 1pt + colors.pfbrown, length: 100%)
  #text(fill: colors.pfbrown)[#content]
  #line(stroke: 1pt + colors.pfbrown, length: 100%)]

#let statbox(stats) = [
  #v(1em)
    #set par(spacing: .6em, first-line-indent: 0em) // hanging-indent: 1em)
    #let creature_header(body) = {
      box(
        text(weight: "extrabold",size:  1.4em, stretch: 50%)[#upper(stats.name)]
      )
      h(1fr)
      sym.wj
      box(text(weight: "extrabold",size: 1.4em, stretch: 50%)[CREATURE #body])
    }
    #creature_header[#stats.creature]
    #line(stroke: 1pt, length: 100%)
    #for trait in (stats.trait) [
    #let style = if trait == "tiny" or trait == "small" or trait == "medium" or trait == "large" {
        rgb("#3a7a58")
      } else if trait == "uncommon" {
          orange
      } else if trait == "rare" {
          navy
      } else if trait == "unique" {
          rgb("#871F78") // Dark Purple
      } else {
      colors.pfmaroon
    }
    #box(
        fill: style,
      stroke: (
        left: colors.pfyellow + 2pt,
        right: colors.pfyellow + 2pt,
        top: colors.pfyellow + 1pt,
        bottom: colors.pfyellow + 1pt,
      ),
        inset: 4pt
      )[#text(weight: "semibold", size: .8em, fill: white)[#upper[#trait]]]
    ]
    
    _ #stats.description _

    #for (word, detail) in stats.details {
      par(hanging-indent: 1em)[#text(weight: "extrabold")[#word] #detail\ ]
    }
    #box[
    #for (stat, value) in stats.stats {
      let sign = if value > -1 {
        "+"
      } else {
        ""
      }
      text[*#stat* #sign#value, ]
    }]

    #if stats.other != [] {
    for (name, value) in stats.other {
      text[*#name* #value \ ]}
    }
    #if stats.extra != none {
    for (thing, description) in stats.extra {
      par(hanging-indent: 1em)[#text(weight: "extrabold")[#thing] #description\ ]}
    }
    #line(stroke: 1pt, length: 100%)
    #box[
    #for (stat, value) in stats.defense {
      if stat == "extra"{
      text[; #value]
      continue
    }
      let sign = if value > -1 and stat != "AC" {
        "+"
      } else {
        ""
      }
      text[*#stat* #sign#value, ]
    }]
    
    #par(hanging-indent: 1em)[#text(weight: "extrabold")[HP] #stats.hp\ ]
    #for trait in stats.traits {
    par(hanging-indent: 1em)[
       _*#trait.at(0)*_ #trait.at(1) \ ]
    }

    #line(stroke: 1pt, length: 100%)
    #for action in stats.actions {
    par(hanging-indent: 1em)[
       _*#action.at(0)*_ #action.at(1) \ ]
    }
]

#let spell(spl) = [
  #v(1em)
    #set par(spacing: .6em, first-line-indent: 0em) // hanging-indent: 1em)
    #let creature_header(body) = {
      box(
        text(weight: "extrabold",size: 1.4em, stretch: 50%)[#upper(spl.name)]
      )
      h(1fr)
      sym.wj
      box(text(weight: "extrabold",size: 1.4em, stretch: 50%)[#upper(spl.type) #body])
    }
    #creature_header[#spl.level]
    #line(stroke: 1pt, length: 100%)
    #for trait in spl.trait [
    #let style = if trait == "tiny" or trait == "small" or trait == "medium" or trait == "large" {
        rgb("#3a7a58") // Size Green
      } else if trait == "uncommon" {
          orange
      } else if trait == "rare" {
          navy
      } else if trait == "unique" {
          rgb("#871F78") // Dark Purple
      } else {
      colors.pfmaroon
    }
    #box(
        fill: style,
      stroke: (
        left: colors.pfyellow + 2pt,
        right: colors.pfyellow + 2pt,
        top: colors.pfyellow + 1pt,
        bottom: colors.pfyellow + 1pt,
      ),
        inset: 4pt
      )[#text(weight: "semibold", size: .8em, fill: white)[#upper[#trait]]]
    ]
  
  #for req in spl.reqs {
    par(hanging-indent: 1em)[#req\ ]
  }
  #line(stroke: 1pt, length: 100%)
  #par(hanging-indent: 0pt)[#spl.effect]
  #if spl.crit != [] {
    for text in spl.crit {
      par(hanging-indent: 1em)[#text]
    }
  }
  #if spl.heightened != [] {
    line(stroke: 1pt, length: 100%)
    par(hanging-indent: 1em)[#spl.heightened\ ]
  }
]

#let feat(feat) = [
  #v(1em)
    #set par(spacing: .6em, first-line-indent: 0em) // hanging-indent: 1em)
    #set text(size: 10pt) 
    #let creature_header(body) = {
      box(
        text(weight: "extrabold", size: 1.4em, stretch: 50%)[#upper(feat.name)]
      )
      h(1fr)
      sym.wj
      box(text(weight: "extrabold",size: 1.4em, stretch: 50%)[FEAT #body])
    }
    #creature_header[#feat.level]
    #line(stroke: 1pt, length: 100%)
    #for trait in (feat.trait) [
    #let style = if trait == "tiny" or trait == "small" or trait == "medium" or trait == "large" {
        rgb("#3a7a58") // Size Green
      } else if trait == "uncommon" {
          orange
      } else if trait == "rare" {
          navy
      } else if trait == "unique" {
          rgb("#871F78") // Dark Purple
      } else {
      colors.pfmaroon
    }
    #box(
        fill: style,
      stroke: (
        left: colors.pfyellow + 2pt,
        right: colors.pfyellow + 2pt,
        top: colors.pfyellow + 1pt,
        bottom: colors.pfyellow + 1pt,
      ),
        inset: 4pt
      )[#text(weight: "semibold", size: .8em, fill: white)[#upper[#trait]]]
    ]
  
  #for feat in feat.reqs {
    par(hanging-indent: 1em)[#feat\ ]
  }
  #if feat.reqs != () {
    line(stroke: 1pt, length: 100%)
  }
  #par(hanging-indent: 0pt)[#feat.effect]
  #if feat.special != [] {
    line(stroke: 1pt, length: 100%)
    par(hanging-indent: 1em)[#feat.special\ ]
  }
]
#let complication(comp) = [
  #v(1em)
    #set par(spacing: .6em, first-line-indent: 0em) // hanging-indent: 1em)
    #let creature_header(body) = {
      box(
        text(weight: "extrabold", size: 1.3em, stretch: 50%)[#upper(comp.name)]
      )
      h(1fr)
      sym.wj
      box(text(weight: "extrabold",size: 1.3em, stretch: 50%)[COMPLICATION])
    }
    #creature_header[]
    #line(stroke: 1pt, length: 100%)
    #comp.trigger
    #line(stroke: 1pt, length: 100%)
    #comp.effect
]
