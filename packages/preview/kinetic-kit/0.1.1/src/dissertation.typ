// dissertation.typ — KIT doctoral dissertation template
//
// Public API (re-exported via lib.typ):
//   dissertation(...) — doctoral dissertation

#import "page-setup.typ": setup-appendix, setup-content, setup-front-matter, setup-page
#import "title-page.typ": print-dissertation-title
#import "typography.typ": font-sizes-by-format
#import "front-matter.typ": (
    print-abbreviations, print-abstract, print-acknowledgements, print-kurzfassung,
    print-notation,
)
#import "back-matter.typ": (
    print-bibliography, print-own-patents, print-own-publications,
    print-supervised-theses,
)
#import "outlines.typ": print-list-of, print-toc
#import "figure-kinds.typ": resolve-figure-kinds, resolve-localized


/// KIT doctoral dissertation template.
///
/// - author-title (str | none): Academic title preceding the author's name (e.g. `"M.Sc."`).
/// - author-firstname (str): Author's first name.
/// - author-surname (str): Author's surname.
/// - author-male (bool): `true` for male, `false` for female grammatical forms.
/// - title (content): Dissertation title.
/// - doc-degree (str): Degree name in masculine form.
/// - doc-degree-f (str): Degree name in feminine form.
/// - department (str): Faculty / department name.
/// - university-genitive (str): University name in genitive case.
/// - status-approved (bool): `false` = submitted, `true` = approved.
/// - exam-date (str | none): Date of oral examination (when approved).
/// - main-advisor (str | none): Main referee (when approved).
/// - main-advisor-male (bool): Grammatical gender for main advisor label.
/// - co-advisor (str | none): Co-referee (when approved).
/// - co-advisor-male (bool): Grammatical gender for co-advisor label.
/// - format ("a5" | "17x24" | "a4"): Paper format — `"a5"` (148×210 mm, default),
///   `"17x24"` (170×240 mm), or `"a4"` (210×297 mm, discouraged by KSP). Font sizes and
///   margins are set automatically.
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
/// - notation (content | none): Notation list. `none` = omit.
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
/// - own-publications (content | none): Own publications content (heading added by template). `none` = omit.
/// - own-patents (content | none): Own patents content (heading added by template). `none` = omit.
/// - supervised-theses (content | none): Supervised theses content (heading added by template). `none` = omit.
/// - bibliography (content | none): Bibliography content. Pass `bibliography("refs.bib", title: none, style: "ieee")`.
///   The template adds a translated heading. `none` = omit.
/// - appendix (content | none): Appendix chapters. Template applies `A`, `A.1`, … numbering
///   and places the appendix before the back-matter lists. `none` = omit.
/// - doc (content): Main document body (chapters only).
/// -> content
#let dissertation(
    author-title: "M.Sc.",
    author-firstname: "Max",
    author-surname: "Mustermann",
    author-male: true,
    title: [Your Thesis Title],
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
    notation: none,
    abbreviations: none,
    show-lof: true,
    show-lot: true,
    show-lol: false,
    figure-kinds: (),
    own-publications: none,
    own-patents: none,
    supervised-theses: none,
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
    print-dissertation-title(
        title,
        author-title: author-title,
        author-firstname: author-firstname,
        author-surname: author-surname,
        author-male: author-male,
        doc-degree: doc-degree,
        doc-degree-f: doc-degree-f,
        department: department,
        university-genitive: university-genitive,
        status-approved: status-approved,
        exam-date: exam-date,
        main-advisor: main-advisor,
        main-advisor-male: main-advisor-male,
        co-advisor: co-advisor,
        co-advisor-male: co-advisor-male,
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

    if notation != none {
        print-notation(notation, lang)
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

    if bibliography != none {
        print-bibliography(bibliography, lang)
    }

    if own-publications != none {
        print-own-publications(own-publications, lang)
    }
    if own-patents != none {
        print-own-patents(own-patents, lang)
    }
    if supervised-theses != none {
        print-supervised-theses(supervised-theses, lang)
    }
}
