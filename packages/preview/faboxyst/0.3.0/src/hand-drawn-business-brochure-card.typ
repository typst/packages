// The portrait card from the supplied Freepik Business Brochure reference,
// composed from three independently reusable components.
// Free-license attribution for the supplied source: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "hand-drawn-folded-ribbon.typ": hand-drawn-folded-ribbon
#import "hand-drawn-photo-frame.typ": hand-drawn-photo-frame
#import "hand-drawn-bullet-panel.typ": hand-drawn-bullet-panel

#let _hdbbc-art(width, height, paper, ink, stroke-width) = {
  let sw = stroke-width / 1cm * 540 / (width / 1cm)
  let frame = "M 23 19 C 159 14 362 22 514 18 C 519 212 512 580 518 785 C 367 793 164 786 22 792 C 18 578 24 214 19 27 C 19 23 20 20 23 19 Z"
  let echo = "M 31 27 C 164 22 365 30 506 26 C 511 217 505 575 510 777 C 365 785 169 778 30 784 C 26 572 32 219 27 34 C 27 31 28 28 31 27 Z"
  let marks = "M 27 12 l 28 1 m -23 5 l 13 1 M 500 36 l 1 24 m 5 -18 l 1 12 M 21 698 l 2 -26 m 4 21 l 1 -15 M 477 788 l 26 -1 m -19 6 l 13 -1"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 540 810\" preserveAspectRatio=\"none\">"
    + "<path d=\"" + frame + "\" fill=\"" + paper.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "<path d=\"" + echo + "\" fill=\"none\" stroke=\"" + ink.lighten(25%).to-hex() + "\" stroke-width=\"" + str(sw * 0.55) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.7\"/>"
    + "<path d=\"" + marks + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.88) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A reusable portrait brochure card containing a folded title ribbon, photo
/// frame and editable bullet panel. The three child components are also
/// available independently in this package.
#let hand-drawn-business-brochure-card(
  title: [Lorem ipsum],
  photo-content: none,
  photo-placeholder: [Your photo here],
  bullet-items: (
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
    [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
  ),
  width: auto,
  height: auto,
  min-height: 12.2cm,
  direction: auto,
  paper: white,
  stroke-colour: auto,
  stroke-width: 1.5pt,
  ribbon-colour: rgb("#FFB52F"),
  photo-colour: rgb("#C8EAF5"),
  bullet-colour: rgb("#20B4DC"),
  ribbon-height: 1.46cm,
  photo-height: 5.2cm,
  bullet-min-height: 3.9cm,
  component-gap: 0.30cm,
  padding: 0.30cm,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if stroke-width <= 0pt or padding < 0pt or component-gap < 0pt {
    panic("stroke-width must be positive; padding and component-gap cannot be negative")
  }
  if ribbon-height <= 0pt or photo-height <= 0pt or bullet-min-height <= 0pt or min-height <= 0pt {
    panic("component heights and min-height must be positive")
  }
  if bullet-items.len() == 0 { panic("bullet-items must contain at least one item") }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let edge-ink = if print-mode { luma(50) }
    else if stroke-colour == auto { rgb("#242222") } else { stroke-colour }
  let paper-ink = if print-mode { white } else { paper }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 8.6) }
      else { width / 1cm }
    let w = W * 1cm
    let content-width = w - 2 * padding
    let ribbon-width = w * 0.87
    let photo-width = w * 0.84
    let bullet-width = w * 0.90
    if content-width < bullet-width { panic("card width is too small for its components") }

    let ribbon = hand-drawn-folded-ribbon(
      title: title,
      width: ribbon-width,
      height: ribbon-height,
      direction: text-dir,
      fold-side: "end",
      colour: ribbon-colour,
    )
    let photo = hand-drawn-photo-frame(
      content: photo-content,
      placeholder: photo-placeholder,
      width: photo-width,
      height: photo-height,
      direction: text-dir,
      colour: photo-colour,
    )
    let bullets = hand-drawn-bullet-panel(
      items: bullet-items,
      width: bullet-width,
      min-height: bullet-min-height,
      direction: text-dir,
      colour: bullet-colour,
    )
    let contents = stack(spacing: component-gap,
      align(center, ribbon),
      align(center, photo),
      align(center, bullets),
    )
    let contents-height = measure(contents).height
    let required-height = contents-height + 2 * padding
    let h = if height == auto { calc.max(min-height, required-height) }
      else { calc.max(height, required-height) }
    let art = _hdbbc-art(w, h, paper-ink, edge-ink, stroke-width)

    box(width: w, height: h, inset: 0pt, {
      place(center, art)
      place(center, contents)
    })
  })
}
