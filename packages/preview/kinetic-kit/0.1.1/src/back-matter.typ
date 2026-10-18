// back-matter.typ — back-matter pages
// bibliography, own publications, own patents, supervised theses

#import "translations.typ": t

// ── Bibliography ──────────────────────────────────────────────────────────

/// Print the bibliography section with a localised heading.
///
/// - body (content): A Typst `bibliography(...)` call.
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-bibliography(body, lang) = {
    heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#(
        t.at(lang).bibliography
    )]
    body
}

// ── Back-matter publication lists ─────────────────────────────────────────

/// Print the own publications section.
///
/// - body (content): Publication list content (e.g. a `bibliography(...)` call).
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-own-publications(body, lang) = {
    heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#(
        t.at(lang).own-publications
    )]
    body
}

/// Print the own patents section.
///
/// - body (content): Patent list content.
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-own-patents(body, lang) = {
    heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#(
        t.at(lang).patents
    )]
    body
}

/// Print the supervised student theses section.
///
/// - body (content): Thesis list content.
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-supervised-theses(body, lang) = {
    heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#(
        t.at(lang).supervised
    )]
    body
}
