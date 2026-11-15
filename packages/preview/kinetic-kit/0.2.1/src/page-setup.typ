// page-setup.typ — shared document style engine
//
// Provides the dynamic page and style configuration used by the thesis template:
//   _header               — context-aware running header
//   _draft-indicator()   — "ENTWURF"/"DRAFT" watermark
//   setup-page()         — full document style setup (page, headings, figures, equations, code)
//   setup-front-matter() — Roman numeral pagination wrapper
//   setup-back-matter()  — heading numbering suppression wrapper
//   setup-content()      — Arabic numeral pagination wrapper
//   setup-appendix()     — A.1 numbering wrapper

#import "kit-colors.typ": kit-colors
#import "typography.typ": font-sizes-by-format, fonts, leading
#import "page-conf.typ": margins-by-format, page-dimensions-by-format, par-spacing
#import "pagination.typ": break-to-odd-page
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

    let single-line = it => {
        show linebreak: none
        it
    }

    let current-chapter = chapters-before.last()
    let chapter-count = counter(heading).at(current-chapter.location()).first()

    let chapter-label = single-line(if current-chapter.numbering != none {
        let lvl1-fmt = current-chapter.numbering.split(".").at(0)
        [#numbering(lvl1-fmt, chapter-count) #current-chapter.body]
    } else {
        current-chapter.body
    })

    if calc.even(this-page) {
        chapter-label
        linebreak()
    } else {
        let sections-in-chapter = query(
            selector(heading.where(level: 2))
                .after(current-chapter.location())
                .before(here()),
        )
        let sec-label = single-line(if sections-in-chapter.len() > 0 {
            let s = sections-in-chapter.last()
            if s.numbering != none {
                let sn = counter(heading).at(s.location())
                let sec-fmt = s.numbering.split(".").slice(0, 2).join(".")
                [#numbering(sec-fmt, ..sn.slice(0, 2)) #s.body]
            } else {
                s.body
            }
        } else { chapter-label })
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
/// -> content
#let setup-page(
    /// Paper format — `"a5"` (148×210 mm), `"17x24"` (170×240 mm) or `"a4"`
    /// (210×297 mm). Font sizes and margins follow from it.
    /// -> str
    format: "a5",

    /// Margin profile keyed on expected page count — `"short"` (under 200 pp),
    /// `"medium"` (200–399 pp) or `"long"` (400+ pp).
    /// -> str
    margin-preset: "short",

    /// Document language — `"de"` or `"en"`.
    /// -> str
    lang: "de",

    /// Extra inside margin added for binding.
    /// -> length
    binding-correction: 0mm,

    /// Render external hyperlinks in KIT Blue.
    /// -> bool
    colored-links: true,

    /// Show the draft watermark on every page.
    /// -> bool
    draft: false,

    /// Extra text appended to the watermark, e.g. a git SHA.
    /// -> content | str | none
    draft-info: none,

    /// Use serif headings instead of sans-serif.
    /// -> bool
    serif-headings: false,

    /// Deepest heading level that receives a number. Deeper headings are styled
    /// normally but rendered without a number or indent grid.
    /// -> int
    heading-numbering-depth: 3,

    /// Figure kind declarations, merged onto the built-in `image`, `table` and
    /// `raw` entries. Supplies the caption supplements; printing the matching list
    /// pages is the caller's job.
    /// -> array
    figure-kinds: (),

    /// Document body, injected by the show rule.
    /// -> content
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
    show: setup-outlines.with(figure-kinds: figure-kinds)

    // ── Figures ──────────────────────────────────────────────────────────
    show: setup-figures.with(font-sizes, lang: lang, figure-kinds: figure-kinds)

    // ── Bibliography ─────────────────────────────────────────────────────
    // Set custom title to get "Literaturverzeichnis" instead of "Bibliografie"
    set bibliography(title: t.at(lang).bibliography)

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

/// Restart page numbering at Roman `i` and remove heading numbering.
/// Apply before front-matter content: `#show: setup-front-matter`.
///
/// -> content
#let setup-front-matter(
    /// Document body, injected by the show rule.
    /// -> content
    doc,
) = {
    set page(numbering: "i")
    set heading(numbering: none)
    counter(page).update(1)
    doc
}

/// Restart page numbering at Arabic `1` and enable `1.1` heading numbering.
/// Apply before the main content: `#show: setup-content`.
///
/// -> content
#let setup-content(
    /// Document body, injected by the show rule.
    /// -> content
    doc,
) = {
    set heading(numbering: "1.1")
    set heading(supplement: context t.at(text.lang).section)
    show heading.where(level: 1): set heading(supplement: context t.at(text.lang).chapter)
    break-to-odd-page()
    set page(numbering: "1")
    counter(page).update(1)
    doc
}

/// Switch to `A.1` heading numbering and reset the heading counter.
/// Apply before appendix chapters: `#show: setup-appendix`.
///
/// -> content
#let setup-appendix(
    /// Document body, injected by the show rule.
    /// -> content
    doc,
) = {
    set heading(numbering: "A.1")
    counter(heading).update(0)
    doc
}

/// Suppress heading numbering for back-matter sections, which sit outside the
/// `1.1` numbering `setup-content` establishes.
/// Apply before back matter: `#show: setup-back-matter`.
///
/// -> content
#let setup-back-matter(
    /// Document body, injected by the show rule.
    /// -> content
    doc,
) = {
    set heading(numbering: none)
    doc
}
