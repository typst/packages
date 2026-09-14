#let _error_msg(font, download_url) = block(
    stroke: red + 2pt,
    inset: 8mm,
    radius: 4pt,
    width: 100%,
    )[
        #let rf = raw(font)
        #set text(font: ("Arials", "Roboto"), fallback: true)
        = 😢 Schriftart #rf konnte nicht gefunden werden!

        Damit das Dokument korrekt generiert werden kann, muss #rf
        installiert sein.
        #if download_url != none [
            Du kannst die Schriftart über #link(download_url) herunterladen.
        ] else [
            Dafür lade dir als erstes die Schriftart herunter.
        ]

         Je nachdem wie du mit Typst arbeitest, müssen folgende Schritte durchgeführt werden.

        == Typst Web App

        Erstelle einen Ordner `fonts/` und ziehe *alle* heruntergeladenen `.ttf` Dateien hinein. Schon erledigt!

        == Lokal
        Wenn du Lokal arbeitest hast du zwei Möglichkeiten:

        === *Installation*
        
        Installiere *alle* Schriftarten auf deinem Rechner. 
        Sobald das getan ist, sollte Typst die Schriftart finden.
        
        === *Fonts Ordner*

        - Erstelle einen Ordner `fonts/` und ziehe *alle* heruntergeladenen `.ttf` Dateien hinein.
        - Übergib den Pfad zu dem erstellten Ordner mit dem `--font-path` Argument an Typst oder setze die `TYPST_FONT_PATHS` Umgebungsvariable
        
        Mehr dazu findest du in der #link("https://typst.app/docs/reference/text/text#font")[Dokumentation].

    ]


#let checkfont(font, download_url: none) = context {
    let size = measure(text(font: font, fallback: false)[
        Test
    ])
    
    if size.width == 0pt {
        _error_msg(font, download_url)
        pagebreak()
    }
    
}


