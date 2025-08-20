#import "colors.typ" as colors: *

#let project(
    title: none,
    subtitle: none,

    submit-to: "Submitted to",
    submit-by: "Submitted by",

    university: "UNIVERSITY",
    faculty: "FACULTY",
    institute: "INSTITUTE",
    seminar: "SEMINAR",
    semester: "SEMESTER",
    docent: "DOCENT",

    author: "AUTHOR",
    student-number: none,
    email: "EMAIL",
    address: "ADDRESS",

    title-page-part: none,
    title-page-part-submit-date: none,
    title-page-part-submit-to: none,
    title-page-part-submit-by: none,

    date: datetime.today(),
    date-format: (date) => date.display("[day].[month].[year]"),

    header: none,
    header-right: none,
    header-middle: none,
    header-left: none,

    footer: none,
    footer-right: none,
    footer-middle: none,
    footer-left: none,

    show-declaration-of-independent-work: true,

    page-margins: none,
    fontsize: 11pt,

    body
) = {
    let ifnn-line(e) = if e != none [#e \ ]

    set text(font: "Atkinson Hyperlegible", size: fontsize)
    // show math.equation: set text(font: "Fira Math")
    show math.equation: set text(font: "STIX Two Math")

    set par(justify: true)

    set enum(indent: 1em)
    set list(indent: 1em)

    show link: underline
    show link: set text(fill: purple)

    // show heading: set text(fill: purple)
    show heading: it => locate(loc => style(s => {
        let num-style = it.numbering

        if num-style == none {
            return it
        }

        let num = text(weight: "thin", numbering(num-style, ..counter(heading).at(loc))+[ \u{200b}])

        [#move(text(fill: purple.lighten(25%), num) + [] + text(fill: purple, it.body), dx: -1 * measure(num, s).width)]
    }))

    // title page
    [
        #set text(size: 1.25em, hyphenate: false)
        #set par(justify: false)

        #v(0.9fr)
        #text(size: 2.5em, fill: purple, strong(title)) \
        #if subtitle != none {
            v(0em)
            text(size: 1.5em, fill: purple.lighten(25%), subtitle)
        }

        #if title-page-part == none [
            #if title-page-part-submit-date == none {
                ifnn-line(semester)
                ifnn-line(date-format(date))
            } else {
                title-page-part-submit-date
            }

            #if title-page-part-submit-to == none {
                ifnn-line(text(size: 0.6em, upper(strong(submit-to))))
                ifnn-line(university)
                ifnn-line(faculty)
                ifnn-line(institute)
                ifnn-line(seminar)
                ifnn-line(docent)
            } else {
                title-page-part-submit-to
            }

            #if title-page-part-submit-by == none {
                ifnn-line(text(size: 0.6em, upper(strong(submit-by))))
                ifnn-line(author + if student-number != none [ (#student-number)])
                ifnn-line(email)
                ifnn-line(address)
            } else {
                title-page-part-submit-by
            }
         ] else {
            title-page-part
        }

        #v(0.1fr)
    ]

    // page setup
    let ufi = ()
    if university != none { ufi.push(university) }
    if faculty != none { ufi.push(faculty) }
    if institute != none { ufi.push(institute) }

    set page(
        margin: if page-margins != none {page-margins} else {
            (top: 2.5cm, bottom: 2.5cm, right: 4cm)
        },

        header: if header != none {header} else [
            #set text(size: 0.75em)

            #table(columns: (1fr, auto, 1fr), align: bottom, stroke: none, inset: 0pt, if header-left != none {header-left} else [
                #title
            ], align(center, if header-middle != none {header-middle} else []), if header-right != none {header-right} else [
                #show: align.with(top + right)
                #author, #date-format(date)
            ])
        ] + v(-0.5em) + line(length: 100%, stroke: purple),
    )

    // outline
    pad(x: 2em, outline(indent: true))
    pagebreak(weak: true)

    set page(
        footer: if footer != none {footer} else {
            set text(size: 0.75em)
            line(length: 100%, stroke: purple)
            v(-0.5em)

            table(columns: (1fr, auto, 1fr),
                align: top,
                stroke: none,
                inset: 0pt,

                if footer-left != none {footer-left},

                align(center)[
                    #counter(page).display() /
                    #locate(loc => counter("grape-suite-last-page").final(loc).first())
                ],

                if footer-left != none {footer-left}
            )
        }
    )

    set heading(numbering: "1.")
    counter(page).update(1)

    // main body
    body

    // backup page count, because last page should not be counted
    locate(loc => counter("grape-suite-last-page").update(counter(page).at(loc)))

    // declaration of independent work
    if show-declaration-of-independent-work {
        pagebreak(weak: true)
        set page(footer: [])

        heading(outlined: false, numbering: none, [Selbstständigkeitserklärung])
        [Hiermit versichere ich, dass ich die vorliegende schriftliche Hausarbeit (Seminararbeit, Belegarbeit) selbstständig verfasst und keine anderen als die von mir angegebenen Quellen und Hilfsmittel benutzt habe. Die Stellen der Arbeit, die anderen Werken wörtlich oder sinngemäß entnommen sind, wurden in jedem Fall unter Angabe der Quellen (einschließlich des World Wide Web und anderer elektronischer Text- und Datensammlungen) kenntlich gemacht. Dies gilt auch für beigegebene Zeichnungen, bildliche Darstellungen, Skizzen und dergleichen. Ich versichere weiter, dass die Arbeit in gleicher oder ähnlicher Fassung noch nicht Bestandteil einer Prüfungsleistung oder einer schriftlichen Hausarbeit (Seminararbeit, Belegarbeit) war. Mir ist bewusst, dass jedes Zuwiderhandeln als Täuschungsversuch zu gelten hat, aufgrund dessen das Seminar oder die Übung als nicht bestanden bewertet und die Anerkennung der Hausarbeit als Leistungsnachweis/Modulprüfung (Scheinvergabe) ausgeschlossen wird. Ich bin mir weiter darüber im Klaren, dass das zuständige Lehrerprüfungsamt/Studienbüro über den Betrugsversuch informiert werden kann und Plagiate rechtlich als Straftatbestand gewertet werden.]

        v(1cm)

        table(columns: (auto, auto, auto, auto),
            stroke: white,
            inset: 0cm,

            strong([Ort:]) + h(0.5cm),
            repeat("."+hide("'")),
            h(0.5cm) + strong([Unterschrift:]) + h(0.5cm),
            repeat("."+hide("'")),
            v(0.75cm) + strong([Datum:]) + h(0.5cm),
            v(0.75cm) + repeat("."+hide("'")),)
    }
}