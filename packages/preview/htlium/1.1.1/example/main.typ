#import "@preview/htlium:1.1.1": template

#show: body => template(body)

= Normaler Text
#lorem(400)

#datetime.today(offset: 1).display("[Day padding:None].[month].[year]")

== Text mit Referenzen

Das ist ein Zitat aus einem Buch @harry-potter.

#pagebreak()

= Abbildungen

#figure(
    image("./logo.png", width: 5cm),
    caption: "Das ist eine Abbildung."
)

#figure(
    table(
        columns: 3*(auto,),
        rows: 2*(auto,),
        [
            *Name:*
        ],
        [
            *Alter:*
        ],
        [
            *Beruf:*
        ],
        [
            Elias
        ],
        [
            16
        ],
        [
            Schüler
        ]
    ),
    caption: "Das ist eine Tabelle"
)


#pagebreak()

#include "src/text1.typ"

