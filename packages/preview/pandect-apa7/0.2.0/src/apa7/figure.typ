/// Figure module for APA 7th Edition.
///
/// Implements APA 7 figure formatting rules (Chapter 7, Sections 7.22-7.36):
/// - Numbering placed above the figure (e.g. "Figure 1" in bold).
/// - Title in italic title case on a new line below the number.
/// - Notes below the figure starting with italicized "Note." or "Nota.".
/// - Accessibility: mandates or supports 'alt' text for screen readers (PDF/UA-1).

/// Helper to render APA figure notes.
#let render-figure-note(
  note,
  lang: "en",
) = {
  if note == none or note == "" {
    return none
  }

  let note-label = if lang == "es" {
    emph[Nota.]
  } else {
    emph[Note.]
  }

  align(left)[
    #set text(size: 10pt)
    #set par(first-line-indent: 0pt, leading: 0.6em, spacing: 0.6em)
    #note-label #note
  ]
}

/// Helper function to create an APA 7 compliant figure.
///
/// Automatically applies:
/// - Caption placed on top with bold figure number and italic title.
/// - Alt text description attribute for PDF/UA-1 universal accessibility.
/// - Flush-left italicized notes block below the figure.
///
/// Parameters:
/// - body: The graphic, plot, or image element.
/// - title: Figure title (content or string). Displayed in italics below figure number.
/// - alt: Alternative text description for screen readers and accessibility.
/// - note: Optional explanatory note placed at the bottom.
/// - lang: ISO 639-1 language code (default: "en").
#let apa-figure(
  body,
  title: [Untitled Figure],
  alt: none,
  note: none,
  lang: "en",
) = {
  let figure-supplement = if lang == "es" { [Figura] } else { [Figure] }

  figure(
    caption: title,
    kind: image,
    supplement: figure-supplement,
    alt: alt,
    [
      #body
      #render-figure-note(note, lang: lang)
    ]
  )
}

/// Applies APA 7 figure caption styling across all figures in the document.
#let apply-figures(lang: "en", body) = {
  // APA 7: Figure captions are placed ABOVE the graphic (unlike older APA 6).
  show figure.where(kind: image): set figure.caption(position: top)

  show figure.where(kind: image): set figure(
    supplement: if lang == "es" [Figura] else [Figure]
  )

  show figure.caption.where(kind: image): it => align(left)[
    #strong[#it.supplement #context it.counter.display(it.numbering)] \
    #emph[#it.body]
  ]

  body
}
