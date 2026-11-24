// thesis.typ — KIT Master's / Bachelor's / Diploma thesis template
//
// Public API (re-exported via lib.typ):
//   thesis(...) — Master's / Bachelor's / Diploma thesis

#import "page-setup.typ": setup-appendix, setup-content, setup-front-matter, setup-page
#import "title-page.typ": print-thesis-title
#import "typography.typ": font-sizes-by-format
#import "front-matter.typ": (
    print-abbreviations, print-abstract, print-acknowledgements, print-kurzfassung,
)
#import "back-matter.typ": print-bibliography
#import "outlines.typ": print-list-of, print-toc
#import "figure-kinds.typ": resolve-figure-kinds, resolve-localized


/// KIT Master's / Bachelor's / Diploma thesis template.
///
/// - author-firstname (str): Author's first name.
/// - author-surname (str): Author's surname.
/// - title (content): Thesis title.
/// - thesis-type (str): e.g. `"Masterarbeit"`, `"Bachelorarbeit"`.
/// - department (str): Faculty / department name.
/// - university-genitive (str): University name in genitive case.
/// - examiner (str | none): First examiner. `none` if unknown.
/// - supervisor (str | none): Supervisor. `none` if unknown.
/// - date-submitted (str | none): Submission date string. `none` if unknown.
/// - format ("a5" | "17x24" | "a4"): Paper format — `"a5"` (148×210 mm, default),
///   `"17x24"` (170×240 mm), or `"a4"` (210×297 mm). Font sizes and margins are set automatically.
/// - lang ("de" | "en"): Document language.
/// - margin-preset ("short" | "medium" | "long"): Margin profile keyed on page count.
/// - binding-correction (length): BCOR added to inside margin. Default `0mm`.
/// - colored-links (bool): KIT Blue links when `true`, black when `false`.
/// - draft (bool): Show "ENTWURF" watermark when `true`.
/// - draft-info (str | none): Optional version string below watermark. Default `none`.
/// - serif-headings (bool): Use serif font for headings when `true`. Default `false` (sans-serif).
/// - heading-numbering-depth (int): Deepest heading level to number. Default `3`.
/// - abstract-en (content | none): English abstract. `none` = omit.
/// - abstract-de (content | none): German abstract. `none` = omit.
/// - acknowledgements (content | none): Acknowledgements. `none` = omit.
/// - abbreviations (content | none): Abbreviations list. `none` = omit.
/// - show-lof (bool): Include List of Figures.
/// - show-lot (bool): Include List of Tables.
/// - show-lol (bool): Include List of Listings.
/// - figure-kinds (array): Figure kinds beyond `image`, `table` and `raw`, as dictionaries
///   with `kind`, `supplement`, and optionally `list-title` and `show-list`. `supplement`
///   and `list-title` take either one value or one per language, e.g.
///   `(de: [Algorithmus], en: [Algorithm])`. The built-in kinds are not declared here —
///   their list pages are governed by `show-lof` / `show-lot` / `show-lol`. Declared
///   kinds get a list page after the built-in ones, in declaration order.
/// - bibliography (content | none): Bibliography content. Pass `bibliography("refs.bib", title: none, style: "ieee")`.
///   The template adds a translated heading. `none` = omit.
/// - appendix (content | none): Appendix chapters. Template applies `A`, `A.1`, … numbering
///   and places the appendix before the back-matter lists. `none` = omit.
/// - doc (content): Main document body (chapters only).
/// -> content
#let thesis(
    author-firstname: "Max",
    author-surname: "Mustermann",
    title: [Your Thesis Title],
    thesis-type: "Masterarbeit",
    department: "KIT-Fakultät für Maschinenbau",
    university-genitive: "des Karlsruher Instituts für Technologie (KIT)",
    examiner: none,
    supervisor: none,
    date-submitted: none,
    format: "a5",
    lang: "de",
    margin-preset: "short",
    binding-correction: 0mm,
    colored-links: true,
    draft: false,
    draft-info: none,
    serif-headings: false,
    heading-numbering-depth: 3,
    abstract-en: none,
    abstract-de: none,
    acknowledgements: none,
    abbreviations: none,
    show-lof: true,
    show-lot: true,
    show-lol: false,
    figure-kinds: (),
    bibliography: none,
    appendix: none,
    doc,
) = {
    assert(
        format in ("a5", "17x24", "a4"),
        message: "format must be \"a5\", \"17x24\" (170×240 mm), or \"a4\"",
    )
    let author-name = author-firstname + " " + author-surname
    let font-sizes = font-sizes-by-format.at(format)
    let resolved-figure-kinds = resolve-figure-kinds(
        figure-kinds,
        show-lof: show-lof,
        show-lot: show-lot,
        show-lol: show-lol,
    )

    set document(
        title: title,
        author: author-name,
        date: datetime.today(),
    )

    // ── Global page/text/heading setup -─────────────────────────────────────
    show: setup-page.with(
        format: format,
        margin-preset: margin-preset,
        lang: lang,
        binding-correction: binding-correction,
        colored-links: colored-links,
        draft: draft,
        draft-info: draft-info,
        serif-headings: serif-headings,
        heading-numbering-depth: heading-numbering-depth,
        figure-kinds: figure-kinds,
    )

    // ── Title page ──────────────────────────────────────────────────────────
    print-thesis-title(
        title,
        thesis-type: thesis-type,
        author-firstname: author-firstname,
        author-surname: author-surname,
        department: department,
        university-genitive: university-genitive,
        examiner: examiner,
        supervisor: supervisor,
        date-submitted: date-submitted,
        format: format,
    )

    // ── Front matter (Roman numerals) ───────────────────────────────────────
    show: setup-front-matter
    counter(page).update(0)

    if acknowledgements != none {
        print-acknowledgements(acknowledgements, lang)
    }

    if abstract-en != none {
        print-abstract(abstract-en)
    }
    if abstract-de != none {
        print-kurzfassung(abstract-de)
    }

    if abbreviations != none {
        print-abbreviations(abbreviations, lang)
    }

    print-toc(lang: lang)

    // ── Main content (Arabic numerals) ──────────────────────────────────────
    show: setup-content
    counter(page).update(1)

    doc

    // ── Back matter ─────────────────────────────────────────────────────────
    if appendix != none {
        show: setup-appendix
        appendix
    }

    // Titles resolve against the document language rather than `text.lang`: a list
    // page is one back-matter section, unlike a supplement that follows its figure.
    for entry in resolved-figure-kinds {
        if entry.show-list {
            print-list-of(
                entry.kind,
                title: resolve-localized(
                    entry.list-title,
                    lang,
                    kind: entry.kind,
                    field: "list-title",
                ),
            )
        }
    }

    if bibliography != none { print-bibliography(bibliography, lang) }
}
