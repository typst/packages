// Sizing for a picture that carries a caption, shared by the image layout and
// the figure component.
//
// A native Typst `figure` composes a caption beneath a picture but cannot size
// itself to a region: handed a picture that fills its container, it adds the
// caption underneath and the pair ends up taller than the cell. The correction
// is the same wherever a captioned picture appears, and it is delicate enough
// that neither caller should carry its own copy.
//
// This is unrelated to `fit.typ`, which scales a finished block geometrically.
// Scaling a figure would take the caption's type size with it; here the caption
// keeps the size the deck gave it and the picture takes the space that is left.

// Composes a picture and its caption as one native figure, sized to its region.
//
// `resize(height, width)` rebuilds the picture at a given size.
//
// `pin` decides where the caption lands when the picture is bounded by the
// region's width rather than its height. Pinned, the caption sits at the foot of
// the region, so figures in adjacent cells share a caption baseline whatever
// their aspect ratios. Unpinned, it hugs the picture, which is what a figure
// centred on a slide of its own wants. The picture is the same size either way:
// `contain` bounds it by the width in exactly the case the two differ.
#let captioned-image(
  resize,
  caption,
  width: 100%,
  pin: false,
  figure-args: (:),
) = {
  let framed(height) = figure(
    resize(height, width),
    caption: caption,
    ..figure-args,
  )
  layout(region => {
    let natural = measure(
      resize(auto, width),
      width: region.width,
    ).height
    // Whatever the figure adds around the picture: caption, gap, and any
    // supplement the deck's numbering puts there.
    let chrome = measure(framed(auto), width: region.width).height - natural
    // Measurement passes hand out an unbounded region. Reporting a natural
    // height there would make the overflow observer flag every captioned
    // figure, so fall back to the relative height the region would otherwise
    // carry and let the bounded pass do the real fitting. Unlike `unsolvable`
    // in fit.typ, which detects the infinite and non-positive regions its
    // fitters meet, this test also catches a huge-but-finite height, so a
    // threshold far above any paper size stands in for "unbounded".
    let bounded = region.height < 1e5pt
    let remaining = calc.max(region.height - chrome, 0pt)
    let picture-height = if not bounded {
      100%
    } else if pin {
      remaining
    } else {
      calc.min(natural, remaining)
    }
    if pin and bounded {
      framed(picture-height)
    } else {
      align(center + horizon, framed(picture-height))
    }
  })
}
