#import "../helpers/datum.typ": datum_bekommen

#let eig-ung(gruppenarbeit: false, stadt: "Berlin", name: "Max Mustermann") = {
    set page(numbering: none)
    pagebreak()
    heading(level: 1, numbering: none)[Eigenständigkeitserklärung]
    v(1em)
    set par(justify: true)

    if gruppenarbeit [
        Hiermit erklären wir, dass wir die vorliegende Arbeit eigenständig verfasst, keine anderen als die angegebenen Quellen und Hilfsmittel verwendet sowie die aus fremden Quellen direkt oder indirekt übernommenen Stellen/Gedanken als solche kenntlich gemacht haben. Diese Arbeit wurde noch keiner anderen Prüfungskommission in dieser oder einer ähnlichen Form vorgelegt. Sie wurde bisher auch nicht veröffentlicht.
    ] else [
        Hiermit erkläre ich, dass ich die vorliegende Arbeit eigenständig verfasst, keine anderen als die angegebenen Quellen und Hilfsmittel verwendet sowie die aus fremden Quellen direkt oder indirekt übernommenen Stellen/Gedanken als solche kenntlich gemacht habe. Diese Arbeit wurde noch keiner anderen Prüfungskommission in dieser oder einer ähnlichen Form vorgelegt. Sie wurde bisher auch nicht veröffentlicht.

    ]
    v(3cm)
    v(1.5cm)

    
    grid(
        columns: (1fr, 1fr),
        column-gutter: 2em,
        [
            #stadt, #datum_bekommen()
            #v(0.4em)
        ],
        [],
        [
            #line(length: 100%)
        ],
        [
            #line(length: 100%)
        ],
        [
            #v(0.4em)
            Ort, Datum
        ],
        [
            #v(0.4em)
            Unterschrift — #name
        ],
    )
}
