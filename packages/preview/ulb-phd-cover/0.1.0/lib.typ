// SPDX-FileCopyrightText: 2025 Julien Rippinger
//
// SPDX-License-Identifier: MIT-0

#let cover(
  logo: "template/logos/archi.png",
  title-font: "IBM Plex Sans",
  title: "Title",
  subtitle: "Subtitle",
  body-font: "IBM Plex Serif",
  name: "[Name SURNAME]",
  field-fr: "[Field in French]",
  field-en: "[Field]",
  aca-year: "20[..]-20[..]",
  supervisor: "[du/de la] Professeur[e] [Prénom NOM], [promoteur/promotrice]",
  supervisor-role: "[promoteur/promotrice]",
  co-supervisor: "[du/de la] Professeur[e] [Prénom NOM]", // disable with none
  co-supervisor-role: "[co-promoteur/promotrice]",
  lab: "[nom de votre unité de recherche]", // disable with none
  jury1: "Name SURNAME (Université libre de Bruxelles, Chair)", // disable all jury list with none
  jury2: "Name SURNAME ([University], Secretary)",
  jury3: "Name SURNAME ([University])",
  jury4: "Name SURNAME ([University])",
  jury5: none, // "Name SURNAME ([University])"
  jury6: none, // "Name SURNAME ([University])"
  jury7: none, // "Name SURNAME ([University])"
  fund-logo: "template/logos/FNRS.png",
  fund-logo-width: 85%,
) = {
  // Set rules
  set page(paper: "a4", margin: (x:2cm, y:2cm))
  set text(hyphenate: false, font: body-font)
  // Start of main horizon block
  page(
    align(horizon, block(height: 100%, width: 100%)[
      // Faculty Logo Block
      #align(top+left, block(height: 20%, spacing: 0%, image(logo, width: 75%)))

      // Title Block
      #align(horizon+right,block(height: 20%, spacing: 0%)[
      #set text(font: title-font)
        #rect(fill: rgb("#003087"), width: 90%, height: 100%, inset: 5%)[
            #text(fill: white, size: 28pt)[#title] \ \
            #text(fill: white, size: 22pt)[#subtitle]
        ]
      ])

      // Author Block
      #align(horizon+left)[
        #set text(size: 14pt)
        #move(dx:10%)[
          #block(height: 20%, width:85%, spacing: 0%)[
            #par(leading: 0.8em)[
              #context if text.lang == "en" [
                #set text(fill: rgb("#003087"))
                *Thesis submitted by #name* \
                #set text(fill: black, size: 11pt)
                in fulfilment of the requirements of the PhD Degree in #field-en
                ("Doctorat en #field-fr") \
                Academic year #aca-year
              ] else if text.lang == "fr"  [
                #set text(fill: rgb("#003087"))
                *Thèse présentée par #name* \
                #set text(fill: black, size: 11pt)
                en vue de l’obtention du grade académique de Doctorat en #field-fr \
                Année académique #aca-year
              ]
            ]
          ]
        ]
      ]

      // Supervision Block
      #align(horizon+right,block(height: 20%, spacing: 0%)[
        #set text(size: 14pt)
        #move(dx:-5%)[
          #context if text.lang == "en" [
            #par(leading: 1.25em)[
              #set text(fill: rgb("#003087"))
              Supervisor: Professor #supervisor \
              #if co-supervisor != none [Co-supervisor: Professor #co-supervisor \ ]
              #set text(fill: black)
              #lab]
            ] else if text.lang == "fr"  [
              #set text(fill: rgb("#003087"))
              #par(leading: 0.6em, spacing: 1.25em)[
                Sous la direction #supervisor, \ #supervisor-role]
              #if co-supervisor != none [
                #par(leading: 0.6em, spacing: 1.25em)[
                et #co-supervisor, \ #co-supervisor-role]]
              #set text(fill: black)
              #par(leading: 0.6em, spacing: 1.25em)[#lab]
            ]
          ]
        ]
      )

      // Jury Block
      #if jury1 != none [
        #set text(size: 11pt)
        #align(bottom, block(height: 20%, spacing: 0%)[
          #grid(columns: (80%, auto), align: (left+bottom, right+bottom),
          [
            #context if text.lang == "en" [
              *Thesis jury:*
            ] else if text.lang == "fr"  [
              *Jury de thèse :*
            ]
            #par(leading: 0.6em)[
              #jury1 \
              #jury2 \
              #jury3 \
              #jury4 \
              #if jury5 != none [#jury5 \ ]
              #if jury6 != none [#jury6 \ ]
              #if jury7 != none [#jury7 \ ]
            ]], image(fund-logo, width: fund-logo-width))
          ]
        )
        ] else [
          #align(bottom+right, block(height: 20%, spacing: 0%)[
            #move(dy:-20%)[
              #image(fund-logo, width: fund-logo-width)
            ]
          ]
        )
      ]

    ]) // End of main horizon block
  ) // End of page

}
