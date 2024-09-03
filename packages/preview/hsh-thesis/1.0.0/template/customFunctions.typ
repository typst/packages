#import "@preview/gloss-awe:0.0.5": *
#import "abbreviations.typ": *
#import "@preview/treet:0.1.0": *
#import "@preview/big-todo:0.2.0": *
#import "@preview/gentle-clues:0.9.0": *
#import "@preview/wrap-it:0.1.0": wrap-content
#import "@preview/hydra:0.3.0": hydra
#import "@preview/codly:1.0.0": *

#let colorize = true

#let useCaseColor = rgb("E28862")
#let useCaseColorLight = rgb("EEC0AB")
#let requirementColor = silver

#if not colorize {
  useCaseColor = rgb("AAAAAA")
  useCaseColorLight = rgb("CCCCCC")
}

#let sidePadding = 1em
#let topBotPadding = 3em

#let smallLine = line(length: 100%, stroke: 0.045em)

#let exampleText(content: none) = {
  if(content == none){
    return
  }
[
  #linebreak()
  #text(weight: "semibold")[Beispiel: ]
  #content
]
}
  

#let track(title, padding: topBotPadding/8, type: "E", example: none, label:none, content) = {
  let c = counter(type)
  c.step()
  [
    #box[
  #context[
    #pad(top: padding, bottom: padding)[
    #text(weight: "semibold")[
    #heading(outlined: false, depth: 9, numbering: (..nums) => {
  let nums = nums.pos()
  // the number to actually display
  let num = nums.last()

  // combine indent and formatted numbering
  h(0em)
  numbering(type + "1", num)
})[#smallcaps(title)]#label
  ] #linebreak()
  #content
  #exampleText(content: example)
  ]]]]
}

#let narrowTrack(title, type: "Info", label:none, content) = [
  #track(title, padding: 0em, type: type, label:label, content)
]


#let useCase(nummer, name, kurzbeschreibung, akteur, vorbedingungen, hauptszenario) = [
  #pad(left: 0em, right: 0em, rest: topBotPadding/2)[
  #figure()[
  #block()[
  #show table.cell.where(x: 0): set text(weight: "bold")

    #table(
      columns: (0.4fr, 1fr),
      fill: (x, y) => if calc.even(x) { useCaseColor } else { useCaseColorLight },
      stroke: (x: none, y: 2.5pt + rgb("FFFF")),

      [Name], text([UC] + str(nummer) + " - " + name, weight: "semibold"),
      [Kurzbeschreibung], kurzbeschreibung,
      [Akteur], akteur,
      [Vorbedingungen], vorbedingungen,
      [Hauptszenario], hauptszenario,
     // [Nachbedingung], nachbedingung
    )
  ]]]
]


#let attributedQuote(label, body) = [
  #pad(left: sidePadding, right: sidePadding, rest: topBotPadding)[
      // use a box to prevent the quote from beeing split on two pages
      #box(
        quote(
          block: true, quotes: true, attribution:             [#cite(label.target, form: "author") #label])[
        #body
    ])
  ]
  ]
  

#let diagramFigure(caption, plabel, filename, rendered:true) = [
  #pad(left: sidePadding, right: sidePadding, rest: topBotPadding)[
  #figure(
    caption: caption,
    kind: "diagram",
    supplement: [Diagramm],
    include "Diagrams/" + (if (rendered){"rendered/"} else {""}) + filename + ".typ"
  ) #plabel
]]


#let codeFigure(caption, plabel, filename, annotations: none) = [
  #pad(left: 0em, right: 0em, rest: topBotPadding/4)[
    
  #figure(
    caption: caption,
    kind: "code",
    supplement: [Code],
    include "Code/" + filename + ".typ"
  ) #plabel
]]

#let imageFigure(plabel, filename, pCaption, height: auto, width: auto) = [
  #align(center)[
  #pad(left: sidePadding, right: sidePadding, rest: topBotPadding)[
  #figure(
    image("Images/" + filename, height: height, width: width),
    caption: pCaption
  ) #plabel
]]]

#let imageFigureNoPad(plabel, filename, pCaption, height: auto, width: auto) = [
  #align(center)[
  #figure(
    image("Images/" + filename, height: height, width: width),
    caption: pCaption
  ) #plabel
]]

#let treeFigure(pLabel, pCaption, content) = [
#pad(left: sidePadding, right: sidePadding, rest: topBotPadding)[
#par(leading: 0.5em)[
#figure(caption: pCaption)[
#align(left)[
#tree-list(content)]] #pLabel ]]
]

// header


#let getCurrentHeadingHydra(loc, topLevel: false, topMargin) = {
    if(topLevel){
      return hydra(1, top-margin:topMargin)
    }
    
    return hydra(2, top-margin:topMargin)
}

#let getCurrentHeading(loc, topLevel: false, topMargin) = {

    let chapterNumber = counter(heading).display()
    if(topLevel){
      chapterNumber = str(counter(heading).get().at(0))
    }
  
    let topLevelElems = query(
      selector(heading).before(loc),
      loc,
    )

    if(topLevel){
      topLevelElems = query(
      selector(heading.where(level: 1)).before(loc),
      loc,
      )
    }
    
    let currentTopLevelElem = ""
    
    if topLevelElems != () {
      currentTopLevelElem = topLevelElems.last().body
    }
    
    return chapterNumber + " " + currentTopLevelElem
}