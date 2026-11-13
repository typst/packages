// All visual constants live here. Values from the mock use 1 CSS px = .75pt.
#let monash-blue = rgb("006DAE")
#let monash-black = rgb("000000")
#let monash-grey-dark = rgb("5A5A5A")
#let monash-grey = rgb("5A5A5A")
#let monash-grey-mid = rgb("969696")
#let monash-grey-soft = rgb("E6E6E6")
#let monash-grey-light = rgb("E6E6E6")
#let body-fonts = ("STIX Two Text", "Libertinus Serif")
#let math-fonts = ("STIX Two Math", "New Computer Modern Math")
#let heading-fonts = ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans", "Libertinus Serif")
#let code-fonts = ("JetBrains Mono", "DejaVu Sans Mono")
#let monash-fonts = (
  font: body-fonts,
  heading-font: heading-fonts,
  math-font: math-fonts,
  code-font: code-fonts,
)
// Typst has no font-enumeration API. Only name families known to be available.
#let embedded-fonts = ("Libertinus Serif", "New Computer Modern Math", "DejaVu Sans Mono")
#let available-fonts = sys.inputs.at("monash-fonts", default: "").split("|") + embedded-fonts
#let resolve-font(value, stack) = if value != auto { value } else {
  stack.filter(family => family in available-fonts)
}
#let body-size = 11pt
#let cover-title-size = 33pt
#let assignment-title-size = 22pt
#let chapter-size = 21pt
#let section-size = 13pt
#let subsection-size = 11pt
#let label-size = 10.5pt
#let caption-size = 10pt
#let furniture-size = 9pt
#let byline-size = 10pt
#let code-size = 9pt
#let footnote-size = 9.5pt
#let subtitle-size = 14pt
#let doc-type-size = 12pt
#let unit-size = 10pt
#let light-weight = 300
#let body-leading = .5em
#let body-top-edge = 1em
#let body-bottom-edge = .5em
#let compact-top-edge = .7em
#let first-page-top = 42pt
#let paragraph-gap = 9.75pt
#let code-leading = .9em
#let zero = 0pt
#let full = 100%
#let margin-x = 25mm
#let margin-top = 27mm
#let margin-bottom = 25mm
#let hairline = .75pt
#let table-rule = 1.1pt
#let furniture-gap = 6pt
#let header-ascent = 21pt
#let footer-descent = 15pt
#let assignment-logo-height = 30pt
#let cover-logo-height = 42pt
#let title-gap = 22.5pt
#let byline-gap = 12.75pt
#let rule-gap = 16.5pt
#let first-question-gap = 25pt
#let cover-top = 60pt
#let cover-title-top = 258pt
#let cover-title-leading = .4em
#let title-leading = .45em
#let cover-gap = 12pt
#let cover-rule-gap = 10.5pt
#let cover-band = 10.5pt
#let field-label-width = 82pt
#let field-gap = 9pt
#let field-row-gap = 4.5pt
#let group-gap = 19.5pt
#let unit-tracking = .06em
#let notch-left = 17pt
#let notch-width = 7.5pt
#let notch-depth = 3.75pt
#let box-inset = (x: 12pt, y: 9pt)
#let question-gap = 7.5pt
#let question-above = 22.5pt
#let heading-above = 17.25pt
#let heading-below = 15.75pt
#let section-above = 27pt
#let section-below = 9.75pt
#let number-gap = 12pt
#let abstract-inset = 30pt
#let abstract-gap = 7.5pt
#let contents-gap = 48pt
#let contents-indent = 19.5pt
#let contents-entry-gap = 3.75pt
#let contents-chapter-gap = 9pt
#let caption-gap = 6pt
#let code-inset = (x: 6pt, y: 7.5pt)
#let code-number-gap = 12pt
#let square-bullet-size = 3pt
#let footnote-rule-width = 90pt
// Internal example/test geometry also uses these tokens.
#let diagram-width = 322.5pt
#let diagram-height = 126pt
#let test-wide-width = 550pt
#let sample-figure-height = 42pt
#let alternate-accent = monash-grey-dark
#let notch-rule() = layout(size => block(width: full, height: notch-depth, above: zero, below: zero,
  curve(
    curve.move((zero, zero)),
    curve.line((notch-left, zero)),
    curve.line((notch-left + notch-width / 2, notch-depth)),
    curve.line((notch-left + notch-width, zero)),
    curve.line((size.width, zero)),
    stroke: hairline + monash-grey-mid,
  ),
))
#let syntax-theme(accent) = {
  let keyword-scopes = (
    "keyword.control", "keyword.declaration", "storage.type", "storage.modifier",
  ).join(", ")
  let theme = ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <plist version="1.0">
      <dict>
        <key>name</key><string>Academic</string>
        <key>settings</key>
        <array>
          <dict>
            <key>settings</key>
            <dict><key>foreground</key><string>BODY_COLOUR</string></dict>
          </dict>
          <dict>
            <key>scope</key><string>KEYWORD_SCOPES</string>
            <key>settings</key>
            <dict><key>foreground</key><string>ACCENT_COLOUR</string></dict>
          </dict>
          <dict>
            <key>scope</key><string>comment</string>
            <key>settings</key>
            <dict><key>foreground</key><string>COMMENT_COLOUR</string></dict>
          </dict>
        </array>
      </dict>
    </plist>
  ```.text
  bytes(theme
    .replace("KEYWORD_SCOPES", keyword-scopes)
    .replace("BODY_COLOUR", monash-black.to-hex())
    .replace("ACCENT_COLOUR", accent.to-hex())
    .replace("COMMENT_COLOUR", monash-grey.to-hex()))
}

#let cover-unit-height = 14.625pt
#let cover-title-inset = 3.5pt
#let field-size = 12pt
#let assignment-title-inset = 2pt

#let title-top-edge = .85em
#let title-bottom-edge = .3em
#let part-body-indent = 13.5pt
#let question-heading-gap = 15.75pt

#let example-table-width = 80%
#let code-line-height = 14.4pt
#let code-top-edge = 1em
#let code-bottom-edge = .6em

#let line-tail-space = 6.75pt
#let furniture-bottom-edge = .45em

// Editable schematic used by the mock-matching example.
#let schematic-svg = bytes(
```xml
<svg xmlns="http://www.w3.org/2000/svg" width="430" height="168" viewBox="0 0 430 168">
<title>Schematic nodes expanded against map size</title>
<path d="M48 12V136H330" fill="none" stroke="#000000" stroke-width="1"/>
<path d="M48 132C140 120 230 80 322 18" fill="none" stroke="#000000" stroke-width="1.5"
  stroke-dasharray="6 4"/>
<path d="M48 134C150 130 240 116 322 92" fill="none" stroke="#006DAE" stroke-width="2"/>
<g font-family="STIX Two Text,Libertinus Serif,serif" font-size="13" fill="#000000">
<text x="334" y="22">Zero heuristic</text><text x="334" y="96">Manhattan</text>
<text x="189" y="160" text-anchor="middle">Map size</text>
<text x="18" y="78" text-anchor="middle" transform="rotate(-90 18 78)">Nodes expanded</text>
</g></svg>
```.text)

#let chapter-title-inset = 5.25pt
#let section-bottom-edge = .4em
#let chapter-leading = .15em
#let section-leading = .25em

#let contents-heading-extra = 3.75pt
#let contents-row-height = 16.875pt
#let equation-size = 12pt
#let equation-inset = 7.5pt
#let figure-above-extra = 15pt
#let table-above-extra = 14.25pt

#let equation-top-assignment = 12.75pt
#let equation-top-report = 18.75pt
#let table-header-inset = (x: 6pt, y: 7.5pt)
#let table-body-inset = (x: 6pt, y: 6.375pt)

#let field-row-bottom = 9.6pt

#let invalid-relative-size = 1em

#let code-figure-above = 8.25pt
#let table-caption-gap = 10.5pt
#let proof-equation-gap = 3.75pt
