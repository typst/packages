// university-block.typ
//
// Top-left block of the cover. Crops the official University of Stuttgart
// logo PDF to the round symbol and the wordmark, which drops "Germany"
// from the English file, and sets the institute and chair lines below in
// Typst, so any department can use the cover.
//
// Geometry, measured from the official PDFs, which share a 100mm by 50mm
// artboard. The German symbol is 13mm wide at 19.47mm, 18.5mm. The English
// logo is drawn about 5% smaller, its symbol is 12.36mm wide at the same
// corner. Both are scaled so the symbol is 13mm, the size of the earlier
// institute logo. The wordmark ends 9.02mm below the symbol top, "Germany"
// starts 10.3mm below it.

// Official download locations, shown in errors and the README.
#let logo-url-en = "https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_englisch.pdf"
#let logo-url-de = "https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_deutsch.pdf"

#let _logo-gray = rgb(53, 62, 73)

// Accept only the official PDF, the crop does not fit the PNG or JPG.
#let _check-pdf(logo, language) = {
  if type(logo) == content and logo.func() == image and type(logo.source) == str {
    let ok = lower(logo.source).ends-with(".pdf")
    let url = if language == "german" { logo-url-de } else { logo-url-en }
    assert(ok, message: "university-logo must be the official logo PDF, not " + logo.source + ". Download it from " + url)
  }
}

// Places the official logo so its symbol's top-left corner is at (0, 0)
// and the symbol is 13mm wide, then clips it to the given window. The
// artboard-sized box keeps Typst from shrinking the image to the window.
#let _window(logo, scale, x, y, width, height) = box(width: width, height: height, clip: true,
  place(top + left, dx: -19.47mm * scale - x, dy: -18.5mm * scale - y,
    box(width: 100mm * scale, height: 50mm * scale, {
      set image(width: 100mm * scale)
      logo
    })))

// logo  content, image("...") of the official PDF, or none
#let university-block(
  logo: none,
  language: "english",
  institute: "",
  chair: "",
  sans-font: "TeX Gyre Heros",
) = box(width: 160mm, height: 18.57mm, {
  _check-pdf(logo, language)
  let scale = if language == "german" { 1.0 } else { 13.0 / 12.36 }

  if logo != none {
    // Symbol, then the wordmark band above "Germany".
    place(top + left, _window(logo, scale, 0mm, 0mm, 14.5mm, 13.1mm))
    place(top + left, dx: 14.5mm, _window(logo, scale, 14.5mm, 0mm, 70mm, 9.7mm))
  }

  // Institute and chair, positioned and sized like the earlier institute
  // logo, slightly spaced out toward the texture of Univers for UniS. No
  // outline to match its heavier stem, PDF viewers draw hairline outlines
  // at least one screen pixel wide, which made the lines too heavy.
  place(top + left, dx: 16.3mm, dy: 10.4mm, {
    set text(
      font: sans-font, size: 10pt, fill: _logo-gray, tracking: 0.04em,
      top-edge: "cap-height", bottom-edge: "baseline",
    )
    set par(leading: 4.83mm - 2.54mm, spacing: 0pt, justify: false)
    institute
    linebreak()
    chair
  })
})
