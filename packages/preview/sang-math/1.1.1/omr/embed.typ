// A fixed-size sheet floats inside a flow block, centred on the physical page.
// This keeps all marks inside A4 even with 15/20mm or asymmetric exam margins.
// Do not scale: the grader uses the original bubble and marker geometry.
#let omr-embed(body) = context {
  layout(size => {
    if page.width == auto or page.width < 210mm {
      panic("sang-math OMR: embedding requires a page at least 210mm wide")
    }
    if size.width < 170mm {
      panic("sang-math OMR: place the sheet in one column at least 170mm wide")
    }
    let offset = here().position().x
    let shift = (page.width - 190mm) / 2 - offset
    block(width: size.width, height: 140mm)[
      #place(top + left, dx: shift, body)
    ]
  })
}
