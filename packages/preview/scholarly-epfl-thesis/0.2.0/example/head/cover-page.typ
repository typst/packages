#page(
  numbering: none, margin: (y: 6cm), {
    set text(font: "Latin Modern Sans")

    align(
      center, [
        #let v-skip = v(1em, weak: true)
        #let v-space = v(2em, weak: true)

        #text(size: 18pt)[
          FIRST LINE OF TITLE\
          SECOND LINE OF TITLE
        ]

        #v-space

        #text(fill: gray)[
          THIS IS A TEMPORARY TITLE PAGE

          It will be replaced for the final print by a version\
          provided by the service académique.
        ]

        #v-space

        #v(1fr)

        #grid(
          columns: (1fr, 60%), align(horizon, image("../images/Logo_EPFL.svg", width: 75%)), align(left)[
            Thèse n. 1234 2011\
            présentée le 12 Mars 2011\
            à la Faculté des Sciences de Base\
            laboratoire SuperScience\
            programme doctoral en SuperScience\
            École Polytechnique Fédérale de Lausanne\
            #v-skip
            pour l’obtention du grade de Docteur ès Sciences\
            par\
            #h(2cm) Your Name\
            #v-space
            acceptée sur proposition du jury:\
            #v-skip
            Prof Name Surname, président du jury\
            Prof Name Surname, directeur de thèse\
            Prof Name Surname, rapporteur\
            Prof Name Surname, rapporteur\
            Prof Name Surname, rapporteur
            #v-space
            Lausanne, EPFL, 2011
          ],
        )
      ],
    )
  },
)
