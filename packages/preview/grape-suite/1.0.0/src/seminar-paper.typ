#import "colors.typ" as colors: *
#import "todo.typ": todo, list-todos, hide-todos
#import "elements.typ": *

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

    sentence-supplement: "Example",

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

    show-outline: true,
    show-todolist: true,
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

    show heading: it => context {
        let num-style = it.numbering

        if num-style == none {
            return it
        }

        let num = text(weight: "thin", numbering(num-style, ..counter(heading).at(here()))+[ \u{200b}])
        let x-offset = -1 * measure(num).width

        pad(left: x-offset, par(hanging-indent: -1 * x-offset, text(fill: purple.lighten(25%), num) + [] + text(fill: purple, it.body)))
    }

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

    state("grape-suite-element-sentence-supplement").update(sentence-supplement)
    show: sentence-logic

    // outline
    if show-outline or show-todolist {
        pad(x: 2em, {
            if show-outline {
                outline(indent: true)
                v(1fr)
            }

            if show-todolist {
                list-todos()
            }
        })

        pagebreak(weak: true)
    }

    // main body setup
    set page(
        background: context state("grape-suite-seminar-paper-sidenotes", ())
            .final()
            .map(e => context {
                if here().page() == e.loc.at(0) {
                    place(top + right, align(left, par(justify: false, text(fill: purple, size: 0.75em, hyphenate: false, pad(x: 0.5cm, block(width: 3cm, strong(e.body)))))), dy: e.loc.at(1).y)
                } else {
                }
            }).join[],

        footer: if footer != none {footer} else {
            set text(size: 0.75em)
            line(length: 100%, stroke: purple)
            v(-0.5em)

            table(columns: (1fr, auto, 1fr),
                align: top,
                stroke: none,
                inset: 0pt,

                if footer-left != none {footer-left},

                align(center, context {
                    str(counter(page).display())
                    [ \/ ]
                    str(counter("grape-suite-last-page").final().first())
                }),

                if footer-left != none {footer-left}
            )
        }
    )

    set heading(numbering: "1.")
    counter(page).update(1)
    body

    // backup page count, because last page should not be counted
    context counter("grape-suite-last-page").update(counter(page).at(here()))

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

#let sidenote(body) = context {
    let pos = here()

    state("grape-suite-seminar-paper-sidenotes", ()).update(k => {
        k.push((loc: (pos.page(), pos.position()), body: body))
        return k
    })
}