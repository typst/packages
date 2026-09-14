// SPDX-FileCopyrightText: 2025 Julien Rippinger <https://julienrippinger.eu>
//
// SPDX-License-Identifier: MIT-0

// Color used across the template
#let ulb-blue = rgb("#003087")

// This function inserts the cover page into the document
#let cover(
  faculty-logo: image("template/logos/archi.png"),
  faculty-logo-width: 75%,
  title-font: "IBM Plex Sans",
  title: "Title",
  subtitle: none,
  body-font: "IBM Plex Serif",
  name: "[Name SURNAME]",
  field-fr: "[Field in French]",
  field-en: "[Field]",
  aca-year: "20[..]-20[..]",
  supervisor: "[du/de la] Professeur[e] [Prénom NOM], [promoteur/promotrice]",
  supervisor-role: "[promoteur/promotrice]",
  co-supervisor: none,
  co-supervisor-role: "[co-promoteur/promotrice]",
  lab: none,
  jury1: "Name SURNAME (Université libre de Bruxelles, Chair)", // disable all jury list with none
  jury2: "Name SURNAME ([University], Secretary)",
  jury3: "Name SURNAME ([University])",
  jury4: "Name SURNAME ([University])",
  jury5: none, // "Name SURNAME ([University])"
  jury6: none, // "Name SURNAME ([University])"
  jury7: none, // "Name SURNAME ([University])"
  fund-logo: image("template/logos/FNRS-fr.png"),
  fund-logo-width: 85%,
  font-scale: 1, // optional
) = {
  // Set rules
  set page(margin: (x:9.523%, y:6.734%)) // 2cm margin on A4
  set text(hyphenate: false, font: body-font)
  // Start of main horizon block
  page(
    align(horizon, block(height: 100%, width: 100%)[
      // Faculty Logo Block
      #set image(width: faculty-logo-width)
      #align(top+left, block(height: 20%, spacing: 0%, faculty-logo))

      // Title Block
      #align(horizon+right,block(height: 20%, spacing: 0%)[
      #set text(font: title-font)
        #rect(fill: ulb-blue, width: 90%, height: 100%, inset: 5%)[
            #text(fill: white, size: (28pt*font-scale))[#title] \ \
            #text(fill: white, size: (22pt*font-scale))[#subtitle]
        ]
      ])

      // Author Block
      #align(horizon+left)[
        #set text(size: (14pt*font-scale))
        #move(dx:10%)[
          #block(height: 20%, width:85%, spacing: 0%)[
            #par(leading: 0.8em)[
              #context if text.lang == "en" [
                #set text(fill: ulb-blue)
                *Thesis submitted by #name* \
                #set text(fill: black, size: (11pt*font-scale))
                in fulfilment of the requirements of the PhD Degree in #field-en
                ("Doctorat en #field-fr") \
                Academic year #aca-year
              ] else if text.lang == "fr"  [
                #set text(fill: ulb-blue)
                *Thèse présentée par #name* \
                #set text(fill: black, size: (11pt*font-scale))
                en vue de l’obtention du grade académique de Doctorat en #field-fr \
                Année académique #aca-year
              ]
            ]
          ]
        ]
      ]

      // Supervision Block
      #align(horizon+right,block(height: 20%, spacing: 0%)[
        #set text(size: (14pt*font-scale))
        #move(dx:-5%)[
          #context if text.lang == "en" [
            #par(leading: 1.25em)[
              #set text(fill: ulb-blue)
              Supervisor: Professor #supervisor \
              #if co-supervisor != none [Co-supervisor: Professor #co-supervisor \ ]
              #set text(fill: black)
              #lab]
            ] else if text.lang == "fr"  [
              #set text(fill: ulb-blue)
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
      #set image(width: fund-logo-width)
      #if jury1 != none [
        #set text(size: (11pt*font-scale))
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
            ]], fund-logo)
          ]
        )
        ] else [
          #align(bottom+right, block(height: 20%, spacing: 0%)[
              #fund-logo
          ]
        )
      ]

    ]) // End of main horizon block
  ) // End of page
}
