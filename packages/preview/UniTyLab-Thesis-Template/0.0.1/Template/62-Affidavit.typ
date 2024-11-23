// Imports
#import "config.typ": *
#import "/Studi/90-Document/91-Doc-Info.typ": *

#set heading(supplement: [Affidavit])

#let sign(author) = {
  
  let fun = underline(
    emph(
      text(
        size: 13pt,
        weight: "medium",
        function + ":"
      )
    )
  )
  
  let sign = rect(
    width: 95%,
    height: 3em,
    stroke: (bottom: 1.5pt,)
  )

  [#v(0.5em)]
  block(
    width: 100%,
    height: auto,
    inset: 1.5em,
    radius: 12pt,
    stroke: luma(0),
    stack(
      dir: ttb,
      [
        #author.giv-name #author.fam-name (#author.mtr-no) \ 
        #author.course
      ],
      [#v(1.4em, weak: true)],
      [#sign],
      [#v(0.7em, weak: true)],
      [
        #h(1mm) #author.uni #h(2mm) \u{2015} #h(2mm) #doc-date \ 
        #h(1mm) #author.giv-name #author.fam-name
      ],
    )
  )
  [#v(0.5em)]
}

<affidavit>
#for (author) in authors [
  #pagebreak()
  = Affidavit of #author.giv-name #author.fam-name

  I hereby affirm that this #doc-type represents my own written work and that I have used no sources and aids other than those indicated. 

  All passages quoted from publications or paraphrased from these sources are properly cited and attributed.
  
  The thesis was not submitted in the same or in a substantially similar version, not even partially, to another examination board and was not published elsewhere.
  
  #sign(author)
]














