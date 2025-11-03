#import "@preview/gloss-awe:0.0.5": *
#import "abbreviations.typ": *
#import "@preview/treet:0.1.1": *
#import "@preview/big-todo:0.2.0": *
#import "@preview/gentle-clues:1.2.0": *
#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/hydra:0.6.0": hydra
#import "@preview/codly:1.3.0": *

#let colorize = true

#let use-case-color = rgb("E28862")
#let use-case-color-light = rgb("EEC0AB")
#let requirement-color = silver

#if not colorize {
  use-case-color = rgb("AAAAAA")
  use-case-color-light = rgb("CCCCCC")
}

#let side-padding = 1em
#let top-bot-padding = 3em

#let small-line = line(length: 100%, stroke: 0.045em)

#let example-text(content: none) = {
  if(content == none){
    return
  }
[
  #linebreak()
  #text(weight: "semibold")[Beispiel: ]
  #content
]
}

#let track(title, padding: top-bot-padding/8, type: "E", example: none, label:none, content) = {
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
  #example-text(content: example)
  ]]]]
}

#let narrow-track(title, type: "Info", label:none, content) = [
  #track(title, padding: 0em, type: type, label:label, content)
]

#let use-case(nummer, name, kurzbeschreibung, akteur, vorbedingungen, hauptszenario) = [
  #pad(left: 0em, right: 0em, rest: top-bot-padding/2)[
  #figure()[
  #block()[
  #show table.cell.where(x: 0): set text(weight: "bold")

    #table(
      columns: (0.4fr, 1fr),
      fill: (x, y) => if calc.even(x) { use-case-color } else { use-case-color-light },
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

#let attributed-quote(label, body) = [
  #pad(left: side-padding, right: side-padding, rest: top-bot-padding)[
      // use a box to prevent the quote from beeing split on two pages
      #box(
        quote(
          block: true, quotes: true, attribution:             [#cite(label.target, form: "author") #label])[
        #body
    ])
  ]
]

#let diagram-figure(caption, plabel, filename, rendered:true) = [
  #pad(left: side-padding, right: side-padding, rest: top-bot-padding)[
  #figure(
    caption: caption,
    kind: "diagram",
    supplement: [Diagramm],
    include "Diagrams/" + (if (rendered){"rendered/"} else {""}) + filename + ".typ"
  ) #plabel
]]

#let code-figure(caption, plabel, filename, annotations: none) = [
  #pad(left: 0em, right: 0em, rest: top-bot-padding/4)[

  #figure(
    caption: caption,
    kind: "code",
    supplement: [Code],
    include "Code/" + filename + ".typ"
  ) #plabel
]]

#let image-figure(plabel, filename, p-caption, height: auto, width: auto) = [
  #align(center)[
  #pad(left: side-padding, right: side-padding, rest: top-bot-padding)[
  #figure(
    image("Images/" + filename, height: height, width: width),
    caption: p-caption
  ) #plabel
]]]

#let image-figure-no-pad(plabel, filename, p-caption, height: auto, width: auto) = [
  #align(center)[
  #figure(
    image("Images/" + filename, height: height, width: width),
    caption: p-caption
  ) #plabel
]]

#let tree-figure(p-label, p-caption, content) = [
#pad(left: side-padding, right: side-padding, rest: top-bot-padding)[
#par(leading: 0.5em)[
#figure(caption: p-caption)[
#align(left)[
#tree-list(content)]] #p-label ]]
]

#let get-current-heading-hydra(top-level: false) = {
    if(top-level){
      return hydra(1)
    }

    return hydra(2)
}
