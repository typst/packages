// inspiration: https://github.com/Sematre/typst-letter-pro/tree/main
// example: https://medium.com/@christianhettlage/creating-your-own-typst-template-90fed295a781

#let upb-letter(
  sender: (
    structural-unit: none,
    structural-unit-extra: none,
    title: none,
    name: none,
    position: none,
    phone: none,
    email: none,
    address: none,
    city: none,
  ),

  co-signer: (
    title: none,
    name: none,
    position: none,
  ),
  
  secretary: (
    name: none,
    phone: none,
    fax: none,
  ),

  receiver: (
    note-1: none,
    note-2: none,
    note-3: none,
    institution: none,
    salutation: none,
    name: none,
    address: none,
    city: none,
    country: none,
    extra-line: none
  ),
  date: none,
  subject: none,

  // main body of text
  body,
) = {

let show-if-defined-nl(key,dict) = {
  if key in dict {
    [#dict.at(key)\ ]
  }
}

let folding-mark-1-pos = 105mm
let folding-mark-2-pos = 210mm

let top-margin = 4.5cm
let bottom-margin = 1.5cm

set text(font: "Karla")

set page(
  paper: "a4",
  margin: (top: top-margin, bottom: bottom-margin),
  header: {
      align(left)[
        #image("/assets/upb-logo-rgb-de-tight.svg", width: 5cm)
      ]
    }
  ,
  footer:
  context 
  [
  *Universität Paderborn*
  #h(1fr)
  #counter(page).display(
    "1 von 1",
    both: true,
  )
])


// Falzmarke oben
place(
  top + left,
  dx: -25mm,
  dy: -25mm + folding-mark-1-pos,
  line(length: 6mm,
  stroke: (thickness: 0.5pt))
)

// Falzmarke unten
place(
  top + left,
  dx: -25mm,
  dy: -25mm + folding-mark-2-pos,
  line(length: 6mm,
  stroke: (thickness: 0.5pt))
)


grid(columns: (80mm, 13mm, 62mm),
[
//  fill: grey,
#text(
  size: 7pt,
  [Universität Paderborn ⋅ Warburger Straße 100 ⋅ 33098 Paderborn]
)  

#text(
  size: 10pt,
  [
    #show-if-defined-nl("note-1", receiver)
    #show-if-defined-nl("note-2", receiver)
    #show-if-defined-nl("note-3", receiver)
    #show-if-defined-nl("institution", receiver)
    #show-if-defined-nl("salutation", receiver)
    #show-if-defined-nl("title", receiver)
    #show-if-defined-nl("name", receiver)
    #show-if-defined-nl("address", receiver)
    #show-if-defined-nl("city", receiver)
    #show-if-defined-nl("country", receiver)
    #show-if-defined-nl("extra", receiver)
]
)
],
[],
[

  #text(
    size: 8pt,
    [    
  // Infoblock
  #if("structural-unit" in sender) [
    #sender.structural-unit\
  ]
  #if("structural-unit-extra" in sender) [
    #sender.structural-unit-extra\
  ]
  
  // Kontaktblock
  #show-if-defined-nl("title",sender)
  #show-if-defined-nl("name",sender)
  #show-if-defined-nl("position",sender)
  #show-if-defined-nl("phone",sender)
  #show-if-defined-nl("email",sender)
  
  *Sekretariat*\

  #show-if-defined-nl("name",secretary)
  #show-if-defined-nl("phone",secretary)
  #show-if-defined-nl("fax",secretary)
  
  #show-if-defined-nl("address",sender)
  #show-if-defined-nl("city",sender)
]
  )
])


v(1em)

// Datum
align(right)[18. April 2024]

v(1em)

// Betreff
text(
  size: 10pt,
  weight: "bold",
  [#subject]
)

v(2em)

set par(justify: true )

// put the document body here
[#body]

v(4em)

grid(

  columns: (1fr,1fr),
  // Signatur Sender
  [
  #show-if-defined-nl("title",sender)
  #show-if-defined-nl("name",sender)
  #text(
    size: 8pt,
    [#show-if-defined-nl("position",sender)]
  )
],
  // Signatur Co-Signer
[
  #show-if-defined-nl("title",co-signer)
  #show-if-defined-nl("name",co-signer)
  #text(
    size: 8pt,
    [#show-if-defined-nl("position",co-signer)]
  )
]
)


}
