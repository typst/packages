// KIT Dissertation / Thesis Title Page

#import "typography.typ": font-sizes-by-format, fonts
#import "kit-colors.typ": kit-colors
#import "page-conf.typ": title-page-margins-by-format
#import "translations.typ": t

// ── Dissertation Title Page ────────────────────────────────────────────────
// All strings are always in German (legal document requirement).

/// Render the KIT dissertation title page (German legal format).
/// All text on this page is always in German regardless of document language.
///
/// - title (content): Dissertation title.
/// - author-title (content): Academic title preceding the author's name (`none` = omit).
/// - author-firstname (str): Author's first name.
/// - author-surname (str): Author's surname.
/// - author-male (bool): Selects grammatical gender for the degree article.
/// - doc-degree (str): Degree name in masculine form (e.g. `"Doktor-Ingenieur"`).
/// - doc-degree-f (str): Degree name in feminine form (e.g. `"Doktor-Ingenieurin"`).
/// - department (str): KIT department or faculty.
/// - university-genitive (str): University name in genitive (e.g. `"des Karlsruher Instituts…"`).
/// - status-approved (bool): `false` = submitted version, `true` = approved version.
/// - exam-date (content): Date of oral examination — shown only when `status-approved` is `true`.
/// - main-advisor (content): Main referee — shown only when `status-approved` is `true`.
/// - main-advisor-male (bool): Selects gendered label for the main advisor.
/// - co-advisor (content): Co-referee — shown only when `status-approved` is `true`.
/// - co-advisor-male (bool): Selects gendered label for the co-advisor.
/// - format (str): Paper format — `"a5"`, `"17x24"`, or `"a4"`. Determines font
///   sizes and title-page margins.
/// -> content
#let print-dissertation-title(
    title,
    author-title: "M.Sc.",
    author-firstname: "Max",
    author-surname: "Mustermann",
    author-male: true,
    doc-degree: "Doktors der Ingenieurwissenschaften (Dr.-Ing.)",
    doc-degree-f: "Doktorin der Ingenieurwissenschaften (Dr.-Ing.)",
    department: "KIT-Fakultät für Maschinenbau",
    university-genitive: "des Karlsruher Instituts für Technologie (KIT)",
    status-approved: false,
    exam-date: none,
    main-advisor: none,
    main-advisor-male: true,
    co-advisor: none,
    co-advisor-male: true,
    format: "a5",
) = {
    let font-sizes = font-sizes-by-format.at(format)
    let title-page-margins = title-page-margins-by-format.at(format)

    set page(
        margin: title-page-margins,
        binding: left,
        header: none,
        footer: none,
        numbering: none,
    )

    set text(font: fonts.sans, size: font-sizes.base)

    // Title page always uses German strings
    let tr = t.at("de")

    let author-name = author-firstname + " " + author-surname
    let author-full = if author-title != none {
        author-title + " " + author-name
    } else {
        author-name
    }

    // ── Zone ①: Title ─────────────────────────────────────────────────────
    v(18mm)
    align(center)[
        #set par(justify: false)
        #text(
            font: fonts.serif,
            size: font-sizes.title,
            weight: "bold",
            hyphenate: false,
        )[#title]
    ]

    // ── Zone ②: Degree claim and author ───────────────────────────────────
    v(1fr)

    align(center)[
        #text(size: font-sizes.base)[
            #tr.degree-preamble
            #if author-male { tr.degree-one } else { tr.degree-one-f }
        ]
        \
        #v(3mm)
        #text(size: font-sizes.title-info)[
            #if author-male { doc-degree } else { doc-degree-f }
        ]
        \
        #v(5mm)
        #text(size: font-sizes.base)[
            #if status-approved { tr.accepted-at } else { tr.submitted-at }
            #department \
            #university-genitive
        ]
        \
        #v(3mm)
        #text(size: font-sizes.base, weight: "bold")[
            #if status-approved { tr.accepted } else { tr.submitted }
        ]
        \
        #v(0.5mm)
        #text(size: font-sizes.title-info)[#tr.dissertation]
        \
        #v(0.5mm)
        #text(size: font-sizes.base)[#tr.by]
        \
        #v(0.5mm)
        #text(size: font-sizes.author, weight: "bold")[#author-full]
    ]

    v(1fr)

    // ── Zone ③: Exam date and advisors (only when approved) ───────────────
    if status-approved {
        v(4mm)
        grid(
            columns: (auto, 1fr),
            column-gutter: 1em,
            row-gutter: 3mm,
            [#tr.exam-date], if exam-date != none { exam-date } else { "–" },
            if main-advisor-male { [#tr.advisor] } else { [#tr.advisor-f] },
            if main-advisor != none { main-advisor } else { "–" },

            if co-advisor-male { [#tr.co-advisor] } else { [#tr.co-advisor-f] },
            if co-advisor != none { co-advisor } else { "–" },
        )
        v(4mm)
    } else {
        v(10mm)
    }
}

// ── Master / Bachelor Thesis Title Page ───────────────────────────────────

/// Render the KIT master's / bachelor's thesis title page (German legal format).
/// All text on this page is always in German regardless of document language.
///
/// - title (content): Thesis title.
/// - thesis-type (str): Thesis type (e.g. `"Masterarbeit"`, `"Bachelorarbeit"`).
/// - author-firstname (str): Author's first name.
/// - author-surname (str): Author's surname.
/// - department (str): KIT department or faculty.
/// - university-genitive (str): University name in genitive (e.g. `"des Karlsruher Instituts…"`).
/// - examiner (content): First examiner (Erstprüfer).
/// - supervisor (content): Supervisor (Betreuer).
/// - date-submitted (content): Submission date string.
/// - format (str): Paper format — `"a5"`, `"17x24"`, or `"a4"`. Determines font
///   sizes and title-page margins.
/// -> content
#let print-thesis-title(
    title,
    thesis-type: "Masterarbeit",
    author-firstname: "Max",
    author-surname: "Mustermann",
    department: "KIT-Fakultät für Maschinenbau",
    university-genitive: "des Karlsruher Instituts für Technologie (KIT)",
    examiner: none,
    supervisor: none,
    date-submitted: none,
    format: "a5",
) = {
    let font-sizes = font-sizes-by-format.at(format)
    let title-page-margins = title-page-margins-by-format.at(format)

    set page(
        margin: title-page-margins,
        binding: left,
        header: none,
        footer: none,
        numbering: none,
    )

    set text(font: fonts.sans, size: font-sizes.base)

    let tr = t.at("de") // title page always in German
    let author-name = author-firstname + " " + author-surname

    v(18mm)
    align(center)[
        #set par(justify: false)
        #text(
            font: fonts.serif,
            size: font-sizes.title,
            weight: "bold",
            hyphenate: false,
        )[#title]
    ]

    v(1fr)

    align(center)[
        #text(size: font-sizes.title-info)[#thesis-type]
        \
        #v(3mm)
        #text(size: font-sizes.base)[
            #department \
            #university-genitive
        ]
        \
        #v(5mm)
        #text(size: font-sizes.base)[#tr.by]
        \
        #v(2mm)
        #text(size: font-sizes.author, weight: "bold")[#author-name]
    ]

    v(1fr)

    v(4mm)
    grid(
        columns: (auto, 1fr),
        column-gutter: 1em,
        row-gutter: 3mm,
        [Erstprüfer:], if examiner != none { examiner } else { "–" },
        [Betreuer:], if supervisor != none { supervisor } else { "–" },
        [Eingereicht am:], if date-submitted != none { date-submitted } else { "–" },
    )
    v(4mm)
}
