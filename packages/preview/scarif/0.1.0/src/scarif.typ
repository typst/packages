#import "@preview/shadowed:0.3.0": shadow

#import "gradients.typ"

// Global variables
#let default-font = "HK Grotesk"
#let default-text-size = 12pt
#let default-title-font = "Buenard"
#let default-title-size = 24pt
#let default-sub-title-size = 14pt
#let default-raw-font = "Cascadia Mono"
#let default-radius = 4pt
#let default-shadow-fill = rgb(89, 85, 101, 25%)

#let shadow = shadow.with(
  blur: 6pt,
  spread: 1pt,
  radius: default-radius,
  fill: default-shadow-fill,
)

#let fit-to-width(max-text-size: 64pt, min-text-size: 4pt, body) = context {
  let content-size = measure(body)

  layout(size => {
    if content-size.width > 0pt and content-size.height > 0pt {
      let ratio-x = size.width / content-size.width
      let ratio-y = size.height / content-size.height

      let ratio = calc.min(ratio-x, ratio-y)

      let text-size = (
        calc.clamp(
          (ratio * 1em).to-absolute().pt(),
          min-text-size.pt(),
          max-text-size.pt(),
        )
          * 1pt
      )

      set text(size: text-size)
      body
    }
  })
}
/// A document title
/// -> content
#let title(
  /// The title.
  /// -> content
  title,
  /// The optional sub title.
  /// none | content
  sub-title: none,
  /// How to fill the title header.
  /// color | gradient
  fill: gradients.lagoon,
) = {
  set document(title: title)

  let luma-color = if type(fill) == color {
    luma(fill)
  } else {
    luma(fill.sample(50%))
  }

  let brightness = luma-color.components().at(0)

  let text-color = if brightness > 70% { black } else { white }

  shadow()[
    #block(width: 100%, inset: 12pt, radius: default-radius, fill: fill)[
      #set par(spacing: 10pt)

      #fit-to-width(max-text-size: default-title-size)[
        #text(font: default-title-font, weight: "bold", fill: text-color, title)
      ]

      #if sub-title != none [
        #text(
          font: default-font,
          size: default-sub-title-size,
          weight: "semibold",
          fill: text-color,
          sub-title,
        )
      ]
    ]
  ]
}

/// Raw text with optional syntax highlighting.
/// -> content
#let raw(
  /// The raw text or a raw element.
  ///
  /// If a raw element is supplied, its fields will override any fields set in
  /// this function.
  ///
  /// -> str | content
  text,
  /// Whether the raw text is displayed as a separate block.
  /// -> bool
  block: false,
  /// The language to syntax-highlight in.
  /// -> none | str
  lang: none,
  /// The horizontal alignment that each line in a raw block should have.
  /// -> alignment
  align: start,
  /// Additional syntax definitions to load.
  ///
  /// The syntax definitions should be in the sublime-syntax file format.
  ///
  /// -> str | bytes | array
  syntaxes: (),
  /// The theme to use for syntax highlighting.
  ///
  /// Themes should be in the tmTheme file format.
  ///
  /// -> none | auto | str | bytes
  theme: auto,
  /// The size for a tab stop in spaces.
  ///
  /// A tab is replaced with enough spaces to align with the next multiple of
  /// the size.
  ///
  /// -> int
  tab-size: 2,
) = {
  if type(text) == content {
    if text.has("text") {
      block = text.at("block", default: block)
      lang = text.at("lang", default: lang)
      align = text.at("align", default: align)
      syntaxes = text.at("syntaxes", default: syntaxes)
      theme = text.at("theme", default: theme)
      tab-size = text.at("tab-size", default: tab-size)
      text = text.at("text")
    } else {
      panic("raw: text must be of type str or a raw element")
    }
  }

  set std.text(font: default-raw-font)

  if block [
    #shadow()[
      #std.block(width: 100%, inset: 12pt, radius: default-radius, fill: white)[
        #std.raw(
          text,
          block: false,
          align: align,
          lang: lang,
          syntaxes: syntaxes,
          theme: theme,
          tab-size: tab-size,
        ) <scarif-disable-raw-show-rule>
      ]
    ]
  ] else [
    #std.raw(
      text,
      block: false,
      align: align,
      lang: lang,
      syntaxes: syntaxes,
      theme: theme,
      tab-size: tab-size,
    ) <scarif-disable-raw-show-rule>
  ]
}

/// A raster or vector graphic.
/// -> content
#let image(
  /// Raw bytes making up an image in one of the supported formats.
  ///
  /// -> bytes
  source,
  /// The image's format.
  /// -> auto | str | dictionary
  format: auto,
  /// The width of the image.
  /// -> auto | relative
  width: auto,
  /// The height of the image.
  /// -> auto | relative
  height: auto,
  /// An alternative description of the image.
  /// -> none | str
  alt: none,
  /// The page number that should be embedded as an image.
  ///
  /// This attribute only has an effect for PDF files.
  ///
  /// -> int
  page: 1,
  /// How the image should adjust itself to a given area.
  /// -> str
  fit: "cover",
) = {
  if type(source) == content {
    if source.has("source") {
      format = source.at("format", default: format)
      width = source.at("width", default: width)
      height = source.at("height", default: height)
      alt = source.at("alt", default: alt)
      page = source.at("page", default: page)
      fit = source.at("fit", default: fit)
      source = source.at("source")
    } else {
      panic("image: source must be of type str, bytes or an image element")
    }
  }

  // Images should always be full size in width if not specified otherwise
  if width == auto {
    width = 100%
  }

  shadow()[
    #block(radius: default-radius, fill: white, clip: true)[
      #std.image(
        source,
        format: format,
        width: width,
        height: height,
        alt: alt,
        page: page,
        fit: fit,
      ) <scarif-disable-image-show-rule>
    ]
  ]
}

#let template(
  doc,
  raw-show-rule: false,
  image-show-rule: false,
) = {
  set text(font: default-font, size: default-text-size)
  set par(justify: true)
  set heading(numbering: "1.1")
  set math.equation(numbering: i => [(#i)], supplement: [])

  // Exlcude scarif.raw raws to prevent recursion
  show std.raw: it => if (
    raw-show-rule
      and not (it.has("label") and it.label == <scarif-disable-raw-show-rule>)
  ) {
    raw(it)
  } else {
    it
  }

  // Exclude shadowed.shadow and scarif.image images to prevent recursion
  show std.image: it => if (
    image-show-rule
      and not (
        it.has("label")
          and (
            it.label == <scarif-disable-image-show-rule>
              or it.label == <shadowed-shadow>
          )
      )
  ) {
    image(it)
  } else {
    it
  }

  doc
}
