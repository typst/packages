// kinetic-kit
// The official Typst template for doctoral theses published through
// KIT Scientific Publishing (KSP).
//
// Public API (re-exported via lib.typ):
//   thesis(...)

#import "page-setup.typ": (
    setup-appendix, setup-back-matter, setup-content, setup-front-matter, setup-page,
)
#import "page-conf.typ": title-page-margins-by-format
#import "pagination.typ": break-to-odd-page
#import "title-page.typ": doctoral-title-page


/// The main entry point of the package.
///
/// By default it assembles a complete doctoral thesis in the KSP-approved style, but it
/// is fully configurable and can just as well produce a bachelor's or master's thesis.
/// The KSP endorsement covers only doctoral theses in the default configuration;
/// customized documents are not.
///
/// -> content
#let thesis(
    /// Paper format --- `"a5"` (148×210 mm, recommended by KSP),
    /// `"17x24"` (170×240 mm) or `"a4"` (210×297 mm).
    /// Font sizes and margins follow from it.
    /// -> str
    format: "a5",

    /// Document language --- `"de"` or `"en"`.
    /// -> str
    lang: "de",

    /// Author's first name.
    /// -> str
    author-firstname: "Max",

    /// Author's surname.
    /// -> str
    author-surname: "Mustermann",

    /// Thesis title.
    /// -> content
    title: [Your Thesis Title],

    /// Title page. Pass @doctoral-title-page`.with(..)` to configure the default,
    /// your own content, a function called as
    /// `(title, author-firstname:, author-surname:, format:, lang:)`, or `none`.
    /// -> content | function | none
    title-page: doctoral-title-page,

    /// Roman-numeral pages before the body --- abstracts, acknowledgements, the table
    /// of contents, any page of your own, in the order written.
    /// -> content | none
    front-matter: outline(),

    /// Appendix chapters, numbered `A`, `A.1`, … and placed directly after the body.
    /// -> content | none
    appendix: none,

    /// Pages after the appendix --- list pages such as
    /// `outline(target: figure.where(kind: image))`, the bibliography, own
    /// publications, whatever the document needs, in the order written.
    /// -> content | none
    back-matter: none,

    /// Use serif headings instead of sans-serif.
    /// -> bool
    serif-headings: false,

    /// Deepest heading level to number.
    /// -> int
    heading-numbering-depth: 3,

    /// Figure kinds beyond `image`, `table` and `raw`, as dictionaries with `kind`
    /// and `supplement`. `supplement` takes either one value or one per language,
    /// e.g. `(de: [Algorithmus], en: [Algorithm])`. Declaring a built-in kind is an
    /// error.
    /// -> array
    figure-kinds: (),

    /// Margin profile keyed on page count --- `"short"` (under 200 pp), `"medium"`
    /// (200–399 pp) or `"long"` (400+ pp).
    /// -> str
    margin-preset: "short",

    /// BCOR added to the inside margin for physically bound copies.
    /// -> length
    binding-correction: 0mm,

    /// KIT Blue hyperlinks when `true`, black when `false`.
    /// -> bool
    colored-links: true,

    /// Show the "ENTWURF"/"DRAFT" watermark on every page.
    /// -> bool
    draft: false,

    /// String shown next to the watermark, e.g. a date or git SHA.
    /// -> str | none
    draft-info: none,

    /// Main document body.
    /// -> content
    doc,
) = {
    assert(
        format in ("a5", "17x24", "a4"),
        message: "format must be \"a5\", \"17x24\" (170×240 mm), or \"a4\"",
    )
    let author-name = author-firstname + " " + author-surname

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
    // Scoped so the setup reverts before the front matter. Applied here rather than
    // left to the caller so a custom title page gets the right geometry and no page
    // number without reaching for internal constants.
    {
        set page(
            margin: title-page-margins-by-format.at(format),
            binding: left,
            header: none,
            footer: none,
            numbering: none,
        )
        if type(title-page) == function {
            title-page(
                title,
                author-firstname: author-firstname,
                author-surname: author-surname,
                format: format,
                lang: lang,
            )
        } else if title-page != none {
            title-page
        }
        break-to-odd-page()
    }

    // Each section is `show: setup-*` then the content. The content defaults to
    // empty and is a no-op when absent; every `setup-*` is either overridden by
    // the next one or invisible with no content to style, so none need guarding.

    // ── Front matter (Roman numerals) ───────────────────────────────────────
    show: setup-front-matter
    front-matter

    // ── Main content (Arabic numerals) ─────────────────────────────────────
    show: setup-content
    doc

    // ── Appendix (A, A.1, … numbering) ────────────────────────────────────
    show: setup-appendix
    appendix

    // ── Back matter (unnumbered headings) ────────────────────────────────
    show: setup-back-matter
    back-matter
}
