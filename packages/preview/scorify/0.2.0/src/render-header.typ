// render-header.typ - Title, composer, and other header text

/// Draw the header block above the first system.
/// Uses standard Typst text (not CeTZ) for proper document styling.
#let render-header(
  title: none,
  subtitle: none,
  composer: none,
  arranger: none,
  lyricist: none,
) = {
  if title == none and composer == none { return }

  // Title block
  block(width: 100%, {
    if title != none {
      align(center, text(size: 18pt, weight: "bold", title))
    }
    if subtitle != none {
      align(center, text(size: 12pt, style: "italic", subtitle))
    }
    v(2pt)
    // Composer/arranger on the right, lyricist on the left
    if composer != none or arranger != none or lyricist != none {
      grid(
        columns: (1fr, 1fr),
        {
          if lyricist != none {
            align(left, text(size: 10pt, "Text: " + lyricist))
          }
        },
        {
          if composer != none {
            align(right, text(size: 10pt, composer))
          }
          if arranger != none {
            align(right, text(size: 9pt, style: "italic", "arr. " + arranger))
          }
        },
      )
    }
    v(6pt)
  })
}
