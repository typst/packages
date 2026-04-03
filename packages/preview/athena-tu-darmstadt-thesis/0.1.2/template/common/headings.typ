#import "props.typ": tud_heading_line_thin_stroke, tud_header_line_height

#let tud_body_line_height = tud_header_line_height / 2

#let tud-heading-with-lines(
  heading_margin_before: 0mm,
  heading_line_spacing: 0mm,
  text-size: 14.3pt,
  text-weight: "bold",
  text-prefix: "",
  text-suffix: "",
  counter-suffix: "",
  it
) = {
  set text(
      font: "Roboto",
      fallback: false,
      weight: text-weight,
      size: text-size
    )
  //set block(below: 0.5em, above: 2em)
  block(
    breakable: false, inset: 0pt, outset: 0pt, fill: none,
    //above: heading_margin_before,
    //below: 0.6em //+ 10pt
  )[
    #stack(
      v(heading_margin_before),
      line(length: 100%, stroke: tud_heading_line_thin_stroke),
      v(heading_line_spacing),
      block({
        text-prefix
        if it.outlined and it.numbering != none {
          counter(heading).display(it.numbering)
          counter-suffix
          h(2pt)
        }
        it.body
        text-suffix
      
      }),
      v(heading_line_spacing),
      line(length: 100%, stroke: tud_heading_line_thin_stroke),
      v(10pt)
    )
  ]
}

#let tuda-section-lines(above: 1.8em, below: 1.2em, ruled: true, body) = {
  block(
    width: 100%,
    inset: 0mm,
    outset: 0mm,
    above: above,
    below: below,
    {
      set block(spacing: 0.2em)
      if ruled {
        line(length: 100%, stroke: tud_body_line_height)
      }
      body
      if ruled {
        line(length: 100%, stroke: tud_body_line_height)
      }
    }
  )
}


/// Creates a section similar to headers
/// But does not add other text or a counter.
/// ```
/// #tuda-section("Lorem ipsum")
/// ```
/// - title (str): The title of this section
#let tuda-section(title) = {
  tuda-section-lines(text(title, font: "Roboto", weight: "bold", size: 11pt))
}

/// Creates a subsection similar to level 2 headers.
/// But does not add other text or a counter.
/// ```
/// #tuda-subsection("Lorem ipsum")
/// ```
/// - title (str): The title of this subsection
#let tuda-subsection(title) = {
  tuda-section-lines(above: 1.4em, below: 1em, text(title, font: "Roboto", weight: "regular", size: 11pt))
}

#let tuda-subsection-unruled(title) = {
  tuda-section-lines(above: 1.4em, below: 1em, ruled: false, text(title, font: "Roboto", weight: "regular", size: 11pt))
}