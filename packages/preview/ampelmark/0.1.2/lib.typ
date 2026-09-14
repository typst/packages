// TLP Color Definitions (v2.0)
// Source: CISA/FIRST TLP 2.0 User Guide RGB
#let tlp-red-color = rgb(255, 0, 51)
#let tlp-amber-color = rgb(255, 192, 0)
#let tlp-green-color = rgb(51, 255, 0)
#let tlp-clear-color = rgb(255, 255, 255)
#let tlp-black-color = rgb(0, 0, 0)

// Helper function to create a TLP label
#let tlp-visual-label(
  color: red,
  text-label: "",
) = {
  box(
    fill: tlp-black-color,
    inset: (x: 8pt, y: 4pt),
    radius: 4pt,
    stroke: none,
    align(center, text(fill: color, size: 12pt, weight: "bold", text-label))
  )
}

// Internal maps
#let tlp-info = (
  red: (color: tlp-red-color, text: "TLP:RED"),
  amber: (color: tlp-amber-color, text: "TLP:AMBER"),
  amber-strict: (color: tlp-amber-color, text: "TLP:AMBER+STRICT"),
  green: (color: tlp-green-color, text: "TLP:GREEN"),
  clear: (color: tlp-clear-color, text: "TLP:CLEAR"),
)

// Public: Display a TLP label (inline or block)
#let tlp-label(level) = {
  let info = tlp-info.at(level, default: tlp-info.clear)
  tlp-visual-label(color: info.color, text-label: info.text)
}

// Public: Wrap content in a block with a label
#let tlp-box(level, content) = {
  let info = tlp-info.at(level, default: tlp-info.clear)
  
  stack(
    dir: ttb,
    spacing: 5pt,
    tlp-visual-label(color: info.color, text-label: info.text),
    block(
      width: 100%,
      inset: 10pt,
      stroke: 1pt + info.color,
      content
    )
  )
}

#let tlp-header-footer(level) = {
  let info = tlp-info.at(level, default: tlp-info.clear)
  align(right, tlp-visual-label(color: info.color, text-label: info.text))
}

// Public: Setup document with TLP Headers and Footers
// Usage: #show: tlp.tlp-setup.with("red")
#let tlp-setup(level, doc) = {
  set page(
    header: tlp-header-footer(level),
    footer: tlp-header-footer(level),
  )
  doc
}

//  Shortcuts
#let tlp-red(content) = tlp-box("red", content)
#let tlp-amber(content) = tlp-box("amber", content)
#let tlp-amber-strict(content) = tlp-box("amber-strict", content)
#let tlp-green(content) = tlp-box("green", content)
#let tlp-clear(content) = tlp-box("clear", content)
