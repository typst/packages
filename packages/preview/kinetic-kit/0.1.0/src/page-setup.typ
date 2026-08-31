// page-setup.typ — shared document style engine
//
// Provides the dynamic page and style configuration used by both the
// dissertation and thesis templates:
//   _header               — context-aware running header
//   _draft-indicator()   — "ENTWURF"/"DRAFT" watermark
//   setup-page()         — full document style setup (page, headings, figures, equations, code)
//   setup-front-matter() — Roman numeral pagination wrapper
//   setup-content()      — Arabic numeral pagination wrapper
//   setup-appendix()     — A.1 numbering wrapper

#import "kit-colors.typ": kit-colors
#import "typography.typ": font-sizes-by-format, fonts, leading
#import "page-conf.typ": margins-by-format, page-dimensions-by-format, par-spacing
#import "translations.typ": t
#import "outlines.typ": setup-outlines
#import "figures.typ": setup-figures
#import "headings.typ": setup-headings


// ── Running header ────────────────────────────────────────────────────────
//
// Even page: chapter number and title
// Odd page:  section title, falls back to chapter title.
// Suppressed on chapter-opening pages and before the first chapter.
#let _header(font-sizes) = context {
    set text(font: fonts.sans, size: font-sizes.small)
    set par(spacing: par-spacing / 2)
    let this-page = here().page()

    // Suppress on chapter-opening pages
    if query(heading.where(level: 1)).any(h => (
        h.location().page() == this-page
    )) {
        return
    }

    // Suppress before the first chapter
    let chapters-before = query(
        selector(heading.where(level: 1)).before(here()),
    )
    if chapters-before.len() == 0 { return }

    let current-chapter = chapters-before.last()
    let chapter-count = counter(heading).at(current-chapter.location()).first()

    let chapter-label = if current-chapter.numbering != none {
        let lvl1-fmt = current-chapter.numbering.split(".").at(0)
        [#numbering(lvl1-fmt, chapter-count) #current-chapter.body]
    } else {
        current-chapter.body
    }

    if calc.even(this-page) {
        chapter-label
        linebreak()
    } else {
        let sections-in-chapter = query(
            selector(heading.where(level: 2))
                .after(current-chapter.location())
                .before(here()),
        )
        let sec-label = if sections-in-chapter.len() > 0 {
            let s = sections-in-chapter.last()
            if s.numbering != none {
                let sn = counter(heading).at(s.location())
                let sec-fmt = s.numbering.split(".").slice(0, 2).join(".")
                [#numbering(sec-fmt, ..sn.slice(0, 2)) #s.body]
            } else {
                s.body
            }
        } else { chapter-label }
        align(right, sec-label)
    }
    line(length: 100%, stroke: 0.3pt + kit-colors.black)
}


// ── Draft indicator ───────────────────────────────────────────────────────

#let _draft-indicator(lang, draft-info, font-sizes) = place(
    bottom + center,
    dy: -6mm,
    box(
        inset: (x: 6pt, y: 4pt),
        text(font: fonts.sans, size: font-sizes.small)[
            #t.at(lang).draft#if draft-info != none [ · #draft-info]
        ],
    ),
)

// ── Base page setup ───────────────────────────────────────────────────────

/// Apply the full KIT document style: page geometry, running headers, KSP
/// typography, heading styles, figure captions, equations, and code blocks.
/// Use as a show rule: `#show: setup-page.with(...)`.
///
/// - format (str): Paper format — `"a5"` (148×210 mm, default), `"17x24"` (170×240 mm),
///   or `"a4"` (210×297 mm). Font sizes and margins are set automatically per KSP specifications.
/// - margin-preset (str): Margin profile keyed on expected page count —
///   `"short"` (under 200 pp), `"medium"` (200–399 pp), `"long"` (400+ pp).
/// - lang (str): Document language — `"de"` or `"en"`.
/// - binding-correction (length): Extra inside margin added for binding (e.g. `3mm`).
/// - colored-links (bool): Render external hyperlinks in KIT blue when `true`.
/// - draft (bool): Show the draft watermark on every page when `true`.
/// - draft-info (content): Optional extra text appended to the watermark (e.g. a git SHA).
/// - serif-headings (bool): Use Libertinus Serif for headings when `true`. Default `false`
/// - heading-numbering-depth (int): Deepest heading level that receives a number. Default `3`.
///   Headings deeper than this are styled normally but rendered without a number or indent grid.
/// - figure-kinds (array): Figure kind declarations, merged onto the built-in
///   `image`, `table` and `raw` entries. Supplies the caption supplements;
///   printing the matching list pages is the caller's job.
/// - doc (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-page(
    format: "a5",
    margin-preset: "short",
    lang: "de",
    binding-correction: 0mm,
    colored-links: true,
    draft: false,
    draft-info: none,
    serif-headings: false,
    heading-numbering-depth: 3,
    figure-kinds: (),
    doc,
) = {
    assert(
        format in ("a5", "17x24", "a4"),
        message: "format must be \"a5\", \"17x24\" (170×240 mm), or \"a4\"",
    )
    let font-sizes = font-sizes-by-format.at(format)
    let page-dimensions = page-dimensions-by-format.at(format)
    let preset-margins = margins-by-format.at(format).at(margin-preset)
    let body-margins = (
        top: preset-margins.top,
        bottom: preset-margins.bottom,
        inside: preset-margins.inside + binding-correction,
        outside: preset-margins.outside,
    )

    set page(
        width: page-dimensions.width,
        height: page-dimensions.height,
        margin: body-margins,
        binding: left,
        header: _header(font-sizes),
        foreground: if draft {
            _draft-indicator(lang, draft-info, font-sizes)
        } else {
            none
        },
        footer: context {
            // Suppress before the very first chapter
            if (
                query(selector(heading.where(level: 1)).before(here())).len() == 0
            ) {
                return
            }
            set text(font: fonts.serif, size: font-sizes.base)
            if calc.odd(here().page()) {
                align(right, counter(page).display())
            } else {
                align(left, counter(page).display())
            }
        },
    )

    set text(font: fonts.serif, size: font-sizes.base, lang: lang, overhang: false)
    set par(
        justify: true,
        first-line-indent: 0pt,
        leading: leading,
        spacing: par-spacing,
    )

    // ── Colored links ─────────────────────────────────────────────────────
    show link: it => {
        if colored-links and type(it.dest) == str {
            text(fill: kit-colors.blue)[#it]
        } else {
            it
        }
    }

    // ── Headings ─────────────────────────────────────────────────────────
    show: setup-headings.with(
        font-sizes,
        serif-headings: serif-headings,
        heading-numbering-depth: heading-numbering-depth,
    )

    // ── Outlines ──────────────────────────────────────────────────────────
    show: setup-outlines

    // ── Figures ──────────────────────────────────────────────────────────
    show: setup-figures.with(font-sizes, lang: lang, figure-kinds: figure-kinds)

    // ── Footnotes ────────────────────────────────────────────────────────
    show footnote.entry: it => {
        set text(size: font-sizes.footnote)
        context {
            let n = counter(footnote).at(it.note.location()).first()
            grid(
                columns: (auto, 1fr),
                column-gutter: 0.3em,
                align: top,
                super[#n], it.note.body,
            )
        }
    }

    // ── Equations ────────────────────────────────────────────────────────
    set math.equation(numbering: it => {
        let ch = counter(heading.where(level: 1)).at(here()).first()
        if ch > 0 { numbering("(1.1)", ch, it) } else { numbering("(1)", it) }
    })

    // ── Code listings ─────────────────────────────────────────────────────
    show raw.where(block: true): it => {
        set text(font: fonts.mono, size: font-sizes.small)
        block(
            width: 100%,
            fill: luma(245),
            inset: (x: 1em, y: 0.8em),
            radius: 5pt,
            it,
        )
    }

    doc
}

// ── Section-specific page setup (thin wrappers) ───────────────────────────

/// Switch to Roman numeral page numbering and remove heading numbering.
/// Apply before front-matter content: `#show: setup-front-matter`.
///
/// - doc (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-front-matter(doc) = {
    set page(numbering: "i")
    set heading(numbering: none)
    doc
}

/// Switch to Arabic page numbering and enable `1.1` heading numbering.
/// Apply before the main content: `#show: setup-content`.
///
/// - doc (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-content(doc) = {
    set page(numbering: "1")
    set heading(numbering: "1.1")
    set heading(supplement: context t.at(text.lang).section)
    show heading.where(level: 1): set heading(supplement: context t.at(text.lang).chapter)
    doc
}

/// Switch to `A.1` heading numbering and reset the heading counter.
/// Apply before appendix chapters: `#show: setup-appendix`.
///
/// - doc (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-appendix(doc) = {
    set heading(numbering: "A.1")
    counter(heading).update(0)
    doc
}
