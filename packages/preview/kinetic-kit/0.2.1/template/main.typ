// ── kinetic-kit ───────────────────────────────────────────────────────────
// The official Typst template for doctoral theses published through
// KIT Scientific Publishing (KSP).
//
// Quick start:
//   1. Configure the template in the thesis.with(...) call below.
//   2. Replace the placeholders with your own text.
//   3. Add your chapters below the #show: line.
//   4. Optionally set draft: true while writing to stamp a "DRAFT" watermark.
//
// Documentation: https://github.com/ll-nick/kinetic-kit

#import "@preview/kinetic-kit:0.2.1": doctoral-title-page, thesis

// ── Document configuration ─────────────────────────────────────────────────
#show: thesis.with(
    // ── Metadata ──────────────────────────────────────────────────────────────
    format: "a5", // "a5" (148×210 mm) | "17x24" (170×240 mm) | "a4" (210×297 mm)
    lang: "en", // "de" or "en" --- text language (hyphenation, quotes) plus all template-generated headings and labels

    author-firstname: "Vorname",
    author-surname: "Nachname",
    title: [Titel der Arbeit],

    // Everything printed on the title page is configured here. Replace this whole
    // argument with your own function or content for a fully custom title page.
    title-page: doctoral-title-page.with(
        author-title: "M.Sc.", // Academic title preceding your name
        author-male: true, // true → male grammatical forms on the title page

        // Adjust the degree name to match your faculty's convention.
        doc-degree: "Doktors der Ingenieurwissenschaften (Dr.-Ing.)",
        doc-degree-f: "Doktorin der Ingenieurwissenschaften (Dr.-Ing.)",
        department: "KIT-Fakultät für Maschinenbau",
        university-genitive: "des Karlsruher Instituts für Technologie (KIT)",

        // Use status-approved: false while writing. Switch to true once approved
        // and fill in the exam details below.
        status-approved: false,
        // status-approved: true,
        // exam-date:         "12. Dezember 2025",
        // main-advisor:      "Prof. Dr.-Ing. Vorname Nachname",
        // main-advisor-male: true,
        // co-advisor:        "Prof. Dr. Vorname Nachname",
        // co-advisor-male:   false,
    ),

    // ── Content ───────────────────────────────────────────────────────────────
    // front-matter and back-matter are free-form: write each section inline, as
    // below, or pull it in with `#include "abstract.typ"`. Each gets its own `=`
    // heading; numbering is suppressed. Typst's own `outline()` renders the
    // contents, and `outline(target: figure.where(kind: …))` the list pages ---
    // the template styles and names them.
    // What follows is a starting point --- the usual sections in a conventional
    // order. Reorder or delete to suit your thesis.
    front-matter: [
        // The block scopes lang: "de" so only the Kurzfassung hyphenates as German.
        #[
            #set text(lang: "de")
            = Kurzfassung
            Hier steht die deutsche Kurzfassung. Sie fasst Fragestellung, Methodik,
            wichtigste Ergebnisse und Schlussfolgerung zusammen.
        ]

        = Abstract
        Here should be your English abstract. It summarizes the research question,
        methodology, key results, and conclusion.

        // Optional --- uncomment to add.
        // = Acknowledgements
        // Thanks to …

        // = Notation
        // #table(columns: 2, stroke: none, [$x$], [State vector], [$u$], [Input vector])

        // = List of Abbreviations
        // See the documentation for glossarium-based first-use expansion.

        #outline()
    ],

    // ── Appendix ──────────────────────────────────────────────────────────────
    // Numbered A, A.1, A.2, B, …
    // appendix: [
    //   = Appendix A
    //   …
    // ],

    // The list pages and bibliography go here.
    back-matter: [
        #outline(target: figure.where(kind: image))
        #outline(target: figure.where(kind: table))
        // #outline(target: figure.where(kind: raw))   // uncomment if you include code listings

        // A list page for any additional figure kinds declared in figure-kinds below.
        // #outline(title: [List of Algorithms], target: figure.where(kind: "algorithm"))

        #bibliography("refs.bib", style: "ieee")

        // Optional further sections --- uncomment what applies. A separate .bib with
        // `full: true` lists every entry whether or not it is cited.
        // #bibliography("own-publications.bib", title: [Own Publications], style: "ieee", full: true)
        // #bibliography("supervised-theses.bib", title: [Supervised Student Theses], style: "ieee", full: true)

        // = Patents
        // Nachname, V. (2024). *Title of the patent*. DPMA, DE 10 2024 000 000 A1.
    ],

    // ── Formatting ────────────────────────────────────────────────────────────
    serif-headings: false, // true = Libertinus Serif headings; false = Libertinus Sans
    heading-numbering-depth: 3, // Deepest numbered level: 3 = 1.1.1, 4 = 1.1.1.1

    // Register figure kinds beyond image / table / raw. A declared kind gets its
    // own caption label ("Algorithm 1.2: …") and counter.
    // `supplement` is that label --- one value or one per language.
    // For a list page, add an `#outline(title: …, target: …)` to back-matter.
    // figure-kinds: (
    //     (kind: "algorithm", supplement: (de: [Algorithmus], en: [Algorithm])),
    // ),

    margin-preset: "short", // "short" (<200 pp) | "medium" (200--399) | "long" (≥400)
    binding-correction: 0mm, // Add 8--10 mm for physically bound print copies (BCOR)
    colored-links: true, // Set to false for the black-link print copy

    // ── Draft watermark ───────────────────────────────────────────────────────
    // Set draft: true while writing to stamp "DRAFT" / "ENTWURF" on every page.
    draft: false,
    // draft-info: "v0.1 --- 2025-06-01", // Optional info next to the watermark, e.g. version, date or commit hash.
)

// ── Chapters ──────────────────────────────────────────────────────────────
// Add your chapters here. Each = heading starts a new chapter.
// You can write chapters inline or in separate files using #include.
//
// Example:
//   #include "introduction.typ"
//   #include "methods.typ"
//   #include "results.typ"
//   #include "conclusion.typ"

#include "guide.typ"

