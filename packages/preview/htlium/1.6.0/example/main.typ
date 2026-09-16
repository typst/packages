#import "@preview/htlium:1.6.0": template
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

= Boxen

#custom-box(
    icon("star", solid: false),
    purple,
    "Das ist eine benutzerdefinierte Box",
    [
        Hier könnte dein Inhalt stehen. Du kannst auch weitere Boxen oder andere Elemente hier einfügen.
    ],
    [
        $a^2 + b^2 = c^2$
    ],
)

#info-box([
    Hallo das ist eine Info
])

#warning-box([
    Hier kann eine Warnung stehen!
])

#note-box([

])

#tip-box([])

#important-box([])

#pagebreak()

= Codeblock

```rust
fn main() {
    println!("Hello, world!");
}
```

#pagebreak()