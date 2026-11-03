// Doctoral thesis title page

#import "typography.typ": font-sizes-by-format, fonts

#let _labels = (
    degree-preamble: "Zur Erlangung des akademischen Grades",
    degree-one: "eines", // masculine
    degree-one-f: "einer", // feminine
    submitted-at: "bei der",
    accepted-at: "von der",
    submitted: "eingereichte",
    accepted: "angenommene",
    dissertation: "Dissertation",
    by: "von",
    exam-date: "Tag der mündlichen Prüfung:",
    advisor: "Hauptreferent:",
    advisor-f: "Hauptreferentin:",
    co-advisor: "Korreferent:",
    co-advisor-f: "Korreferentin:",
)

/// Render the doctoral thesis title page.
///
/// The default @thesis.title-page, owning every parameter printed on the page; pass
/// `doctoral-title-page.with(..)` to configure it.
/// All text is always German, whatever the document language.
/// `format`, `lang`, `title`, `author-firstname` and `author-surname` are supplied
/// by the template when this is passed to @thesis.title-page;
/// setting them via `.with()` has no effect there.
///
/// -> content
#let doctoral-title-page(
    /// Thesis title.
    /// -> content
    title,

    /// Paper format --- `"a5"`, `"17x24"` or `"a4"`. Determines font sizes and
    /// title-page margins.
    /// -> str
    format: "a5",

    /// Accepted for the title-page contract and ignored — this page is always German.
    /// -> str
    lang: "de",

    /// Academic title preceding the author's name.
    /// -> str | none
    author-title: "M.Sc.",

    /// Author's first name.
    /// -> str
    author-firstname: "Max",

    /// Author's surname.
    /// -> str
    author-surname: "Mustermann",

    /// Selects the grammatical gender of the degree article.
    /// -> bool
    author-male: true,

    /// Degree name in masculine form.
    /// -> str
    doc-degree: "Doktors der Ingenieurwissenschaften (Dr.-Ing.)",

    /// Degree name in feminine form.
    /// -> str
    doc-degree-f: "Doktorin der Ingenieurwissenschaften (Dr.-Ing.)",

    /// KIT department or faculty.
    /// -> str
    department: "KIT-Fakultät für Maschinenbau",

    /// University name in genitive.
    /// -> str
    university-genitive: "des Karlsruher Instituts für Technologie (KIT)",

    /// Approved version when `true`, submitted version when `false`.
    /// -> bool
    status-approved: false,

    /// Date of the oral examination. Shown only when approved.
    /// -> content | str | none
    exam-date: none,

    /// Main advisor. Shown only when approved.
    /// -> content | str | none
    main-advisor: none,

    /// Selects the gendered label for the main advisor.
    /// -> bool
    main-advisor-male: true,

    /// Co-advisor. Shown only when approved.
    /// -> content | str | none
    co-advisor: none,

    /// Selects the gendered label for the co-advisor.
    /// -> bool
    co-advisor-male: true,
) = {
    let font-sizes = font-sizes-by-format.at(format)

    // The page is always in German, whatever the document language — set `lang`
    // so its phrases hyphenate correctly even inside an English thesis.
    set text(font: fonts.sans, size: font-sizes.base, lang: "de")

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
            #_labels.degree-preamble
            #if author-male { _labels.degree-one } else { _labels.degree-one-f }
        ]
        \
        #v(3mm)
        #text(size: font-sizes.title-info)[
            #if author-male { doc-degree } else { doc-degree-f }
        ]
        \
        #v(5mm)
        #text(size: font-sizes.base)[
            #if status-approved { _labels.accepted-at } else { _labels.submitted-at }
            #department \
            #university-genitive
        ]
        \
        #v(3mm)
        #text(size: font-sizes.base, weight: "bold")[
            #if status-approved { _labels.accepted } else { _labels.submitted }
        ]
        \
        #v(0.5mm)
        #text(size: font-sizes.title-info)[#_labels.dissertation]
        \
        #v(0.5mm)
        #text(size: font-sizes.base)[#_labels.by]
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
            [#_labels.exam-date], if exam-date != none { exam-date } else { "–" },
            if main-advisor-male { [#_labels.advisor] } else { [#_labels.advisor-f] },
            if main-advisor != none { main-advisor } else { "–" },

            if co-advisor-male { [#_labels.co-advisor] } else { [#_labels.co-advisor-f] },
            if co-advisor != none { co-advisor } else { "–" },
        )
        v(4mm)
    } else {
        v(10mm)
    }
}
