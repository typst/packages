#import "ofb_common.typ": *

#let todos=state("todos",())

// Todo generation
#let todo(who,what,when)={
  if type(what)=="string" {
    what=upper(what.at(0))+what.slice(1)
  } else if type(what)=="content" {
    what=eval(repr(what).replace(regex("\[."),it=>upper(it.text),count:1))
  }
  todos.update(it=>it+((who,what,when)))
  strong[#who #when : #what]
}

// General setup
#let ofbnote(
  meta: (:),
  doc
) = {
  // Page
  set page(
    background: {place(dx:10.8cm,dy:20cm,image("vagues.svg", fit:"stretch"))},
    footer: [
      #align(center,block[#context [#counter(page).display() / #counter(page).final().first()]]),
      #place(top + right,dy: -30%,block[
        #align(top + right,{text(fill: palettea,size: 0.8em)[
          *Office français de la biodiversité*\
          "Le Nadar", 5 Square Félix Nadar\
          94300 Vincennes\
          ofb.gouv.fr
        ]})
      ]
    )],
    footer-descent: 30%,
    margin:(bottom: 17%, top: 3cm, left: 3cm, right: 3cm),
  )

  // Headings
  set heading(numbering: "I.1.a ")
  show par: set block(spacing: 1em, above: 1.5em, below: 1.5em)
  show heading.where(level:1): it => block(width: 100%, above: 3em, below: 2em)[
    #set text(size: 1.4em, weight: "bold", fill: palettea)
    #it
    #v(0.3em)
  ]
  show heading.where(level:2): it => block(width: 100%, above: 2em, below: 2em)[
    #set text(size: 1.2em, weight: "bold", style: "italic", fill: paletteb)
    #it
    #v(0.3em)
  ]
  show heading.where(level:3): it => block(width: 100%, above: 2em, below: 2em)[
    #set text(weight: "bold", fill: palettec)
    #it
    #v(0.3em)
  ]
  show heading.where(level:4): it => text(weight: "bold", fill: palettea)[
    #it.body + " "
  ]

  _conf(meta: meta, [
    // Document heading
    #block(width: 100%,image("logo_ofb_sigle2.png",width: 25%))
    #align(right,[
      #text(fill: palettea,size: 2em,weight: "bold",meta.at("title"))\
      #if meta.at("authors", default: none)!=none [
        #text(fill: rgb("#666666"),style: "italic",meta.at("authors"))\
      ]
      #if meta.at("date", default: none)!=none [
        #text(fill: rgb("#666666"),style: "italic",meta.at("date"))\
      ]
      #if meta.at("version", default: none)!=none [
        #text(fill: rgb("#666666"),style: "italic","Version "+meta.at("version"))
      ]
    ])

    // Generate todo list as a first section
    #context {
      let todolist=todos.final()
      if todolist.len()>0 [
  = Suites à donner
        #mytable(columns: (auto,auto,auto),[Qui ?],[Quoi ?],[Pour quand ?],..(todolist.flatten()))
      ]
    }

    #doc
  ])
}

// Appendix
#let appendix(doc) = {
  set heading(
    supplement: "Annexe ",
    numbering: (..nums) => if nums.pos().len()==1 { "Annexe " + numbering("A.", ..nums)} else {numbering("A.1.a.", ..nums)}
  )
  context counter(heading).update(0)
  pagebreak(weak: true)
  doc
}
