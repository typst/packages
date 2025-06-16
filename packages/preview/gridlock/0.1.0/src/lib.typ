/// This function deals with the floating figures in your document.
/// You don’t need to call it manually.
///
/// Unfortunately we can’t use ```typc layout()``` here since that messes with the floating.
/// This means that figures wider than the line width are measured before they are shrunk down to fit,
/// which results in inaccurate measurements.
/// To solve this problem, the compiler will remind you to manually set the width of these figures.
///
/// - it (content): The figure.
///
/// -> content
#let float-adjustment(it) = context {
  let body-size = measure(it.body).height

  if it.kind == image {
    layout(size => {
      let container-width = size.width
      let body-width = measure(it.body).width

      if body-width > container-width {
        // TODO: v0.12 might introduce a warning function. could be more appropriate
        panic("Make sure none your figures are wider than " + str(container-width/1pt) + "pt.")
      }
    })
  }

  let caption-size = measure(it.caption).height
  let height = body-size

  if it.caption != none {
    height = body-size + figure.gap.to-absolute() + caption-size
  }

  let line-height = text.top-edge

  let padding = line-height
  while height > padding {
    padding += line-height
  }
  set place(clearance: padding - height + line-height)

  it
  h(line-height)
}

/// Sets up the basic layout of the document.
/// If you want to change the line height, you need to adjust the vertical margins so that the text area is an exact multiple of the line height.
/// This is necessary because otherwise, floating figures won’t line up with the first/last line on the page.
///
/// To change an element’s line height, use its ```typ top-edge``` property: \
/// ```typ #show heading: set text(top-edge: 18pt)```.
///
/// Note that inline math is wrapped in a ```typc box()``` to ensure a consistent line height.
/// As a side effect, these formulas cannot be broken across lines.
///
/// - paper (string): The paper size.
///
/// - margin (dictionary): The margins.
/// To calculate the correct margins, find out how many lines fit on the page and multiply them with the line height.
/// That’s the height of the text area.
/// Subtract this from the page height (default: 841.89~pt) and you get the total height of the vertical margins.
/// Split this up between top and bottom as you like.
///
/// Example for Typst’s default settings (A4 paper, margins 2.5/21 × the page’s shorter edge) with a 13~pt line height:
/// $ "lines per page" &= ("page height" - 2 × "vertical margin") / "line height" \
///   &= (841.89 - 2 × 595.28 × 2.5 class("binary",slash) 21) / 13 \
///   &= 53.85… "pt" \ \ \
///   "new vertical margin" &= "page height" - "lines per page" × "line height" \
///   &= 841.89 - 53 × 13 \
///   &= 152.89 "pt" $
///
/// For even margins, simply divide by 2 and you get 76.445~pt (the package’s default setting).
/// You could also, for example, make the bottom margin twice as high as the top margin by setting ```typc (bottom: 101.89pt, top: 51pt)```.
///
/// - font-size (length): The font size of the body text.
///
/// - line-height (length): The distance between lines of body text.
///
/// -> content
#let gridlock(
  paper: "a4",
  margin: (y: 76.445pt),
  font-size: 11pt,
  line-height: 13pt,

  body,
) = {
  set page(
    paper: paper,
    margin: margin,
  )

  set text(
    size: font-size,
    top-edge: line-height
  )

  set par(
    leading: 0pt,
    first-line-indent: line-height,
    justify: true,
    // spacing: 0pt // Uncomment this property or set it in your main source file
                    // ONLY if you’re on the web app or the main branch.
                    // Don’t if you’re using the release version.
  )

  set block(spacing: 0pt)
  show quote.where(block: true): set block(spacing: line-height)

  show heading: set text(top-edge: 1.2em)
  show footnote.entry: set text(top-edge: 0.8em)
  show math.equation.where(block: false): it => box(height: line-height, it)

  show figure.where(placement: top): float-adjustment
  show figure.where(placement: bottom): float-adjustment
  show figure.where(placement: auto): float-adjustment

  body
}

/// This function aligns blocks to the grid.
/// It measures the size of its argument, calculates the appropriate spacing,
/// and applies it using the ```typc pad()``` function.
///
/// Some elements are aligned automatically and do *not* need to be wrapped in ```typc lock()```:
/// / block quotes: These have their spacing set to the line height.
///   If you want to change the spacing, do ```typc #show quote.where(block: true): set block(spacing: 26pt)```.
/// / lists (numbered, bulleted, term): These simply have their spacing set to 0~pt.
///   If you want to change their spacing, use a show rule like with block quotes.
/// / figures with the `placement` argument (floating figures): These are handled automatically with a show rule.
///   Note that you *do* need to wrap non-floating figures in ```typc lock()```.
///
/// - body (content): The bock to be aligned.
///
/// -> content
#let lock(body) = context[#layout(size => [
  #let (height,) = measure( block(width: size.width, body), )
  #let line-height = text.top-edge
  #let padding = line-height

  #while height > padding {
    padding += line-height
  }

  #let pos = here().position().y
  #if pos == page.margin.top [
    #pad(bottom: (padding + line-height - height), body)
  ] else [
    #pad(y: (padding - height + (2 * line-height)) / 2, body)
  ]
])]
