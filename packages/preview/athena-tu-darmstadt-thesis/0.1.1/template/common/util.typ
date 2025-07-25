#let natural-image(..args) = context {
  let (width, height) = measure(image(..args))
  image(..args, width: width, height: height)
}



#let get-spacing-zero-if-first-on-page(default_spacing, heading_location, content_page_margin_full_top, enable: true) = {
    // get previous element
    //let elems = query(
    //  selector(heading).before(loc, inclusive: false),
    //  loc
    //)
    //[#elems]
    if not enable {
      return (default_spacing, false)
    }

    // check if heading is first element on page
    // note: this is a hack
    let heading_is_first_el_on_page = heading_location.position().y <= content_page_margin_full_top

    // change heading margin depending if its the first on the page
    if heading_is_first_el_on_page {
      return (0mm, true)
    }
    else {
      return (default_spacing, false)
    }
}



#let check-font-exists(font-name) = {
  let measured = measure[
    #text(font: font-name, fallback: false)[
      Test Text
    ]
  ]
  if measured.width == 0pt [
    #rect(stroke: (paint: red), radius: 1mm, inset: 1.5em, width: 100%)[
      #set text(fallback: true)
      #set heading(numbering: none)
      #show link: it => underline(text(blue)[#it])
      === Error - Can Not Find Font "#font-name"
      Please install the required font "#font-name". For instructions see the #link("https://github.com/JeyRunner/tuda-typst-templates#logo-and-font-setup")[Readme of this package].
    ]
    //#pagebreak()
  ]
}