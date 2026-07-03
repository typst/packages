#import "@preview/clean-othaw:0.3.6": *

#let anhang =[
    #set page(flipped:true)
    //#set heading(supplement: [Anhang])
    = KI-Dokumentation
    #table(
        columns: (auto, 11%,auto,auto, 7%,auto, auto, auto),
        align: left + horizon,
        stroke: 0.4pt,
        [Zeile],
        [Arbeitsphase],
        [Zweck],
        [Tool ],
        [Datum],
        [Prompt],
        [Art des Outputs],
        [Eigene Nachbearbeitung]
    )

    #set page(flipped:false)
    #appendix-pdf("PDF-Dokument", read("assets/Anhang A.pdf",encoding:none))
]
