/// Appendix module for APA 7th Edition.
///
/// Implements Appendix formatting rules (Section 2.14 of the APA Publication Manual, 7th ed.):
/// - Begins on a new page following the references or body text.
/// - Centered bold label ("Appendix" or "Appendix A", "Appendix B", etc.).
/// - Centered bold title on the next line below the label.
/// - Subordinate table and figure numbering restart with the appendix letter (e.g. Table A1, Figure A1).
/// - Full PDF/UA-1 accessibility with semantic Level 1 headings for outline navigation.

/// Counter to track appendix indices automatically.
#let appendix-counter = counter("apa-appendix")

/// Helper to render an APA 7 compliant Appendix.
///
/// Parameters:
/// - title: Title of the appendix (content or string). Centered and bold below the label.
/// - letter: Explicit letter ("A", "B", etc.) or auto to calculate alphabetically.
/// - multi: Boolean or auto. If false, renders "Appendix" without letter (single appendix).
/// - lang: ISO 639-1 language code (default: "en").
/// - body: Content of the appendix.
#let apa-appendix(
  title: [Untitled Appendix],
  letter: auto,
  multi: true,
  lang: "en",
  body,
) = {
  // APA 7 Section 2.14: Each appendix must begin on a new, separate page.
  // Using weak: true prevents accidental empty blank pages if already at top of page.
  pagebreak(weak: true)
  appendix-counter.step()

  context {
    let count = appendix-counter.get().first()
    let let-str = if letter != auto {
      letter
    } else {
      // 1 -> "A", 2 -> "B", ..., 26 -> "Z"
      if count >= 1 and count <= 26 {
        str.from-unicode(64 + count)
      } else {
        str(count)
      }
    }

    let appendix-label = if not multi {
      if lang == "es" [Apéndice] else [Appendix]
    } else {
      if lang == "es" [Apéndice #let-str] else [Appendix #let-str]
    }

    // Semantic Level 1 heading for PDF/UA-1 outline
    heading(level: 1, appendix-label)

    // Appendix title centered and bold below label
    align(center)[
      #strong(title)
      #v(1em)
    ]

    // Reset subordinate table and figure counters for this appendix (e.g. Table A1, Figure A1)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)

    set figure(numbering: n => let-str + str(n))

    body
  }
}
