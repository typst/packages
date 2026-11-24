// front-matter.typ — front-matter pages
// abstract, kurzfassung, acknowledgements, notation, abbreviations

#import "typography.typ": fonts
#import "translations.typ": t

// ── Abstract / Kurzfassung ────────────────────────────────────────────────

/// Print the English abstract section.
///
/// - body (content): Abstract text.
/// -> content
#let print-abstract(body) = {
    heading(level: 1, numbering: none, outlined: true)[Abstract]
    body
}

/// Print the German abstract (Kurzfassung) section.
///
/// - body (content): Kurzfassung text.
/// -> content
#let print-kurzfassung(body) = {
    heading(level: 1, numbering: none, outlined: true)[Kurzfassung]
    body
}

// ── Acknowledgements ──────────────────────────────────────────────────────

/// Print the acknowledgements section.
///
/// - body (content): Acknowledgements text.
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-acknowledgements(body, lang) = {
    heading(level: 1, numbering: none, outlined: true)[#(
        t.at(lang).acknowledgements
    )]
    body
}


// ── Notation / Symbol list ────────────────────────────────────────────────

/// Print the notation / symbol list section.
///
/// - body (content): Notation content (typically a table or list).
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-notation(body, lang) = {
    heading(level: 1, numbering: none, outlined: true)[#t.at(lang).notation]
    body
}

// ── Abbreviations ─────────────────────────────────────────────────────────

/// Print the list of abbreviations section.
///
/// - body (content): Abbreviations content (typically a glossarium list or table).
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-abbreviations(body, lang) = {
    heading(level: 1, numbering: none, outlined: true)[#(
        t.at(lang).abbreviations
    )]
    body
}
