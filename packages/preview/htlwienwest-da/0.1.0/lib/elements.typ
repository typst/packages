#import "settings.typ" as settings


// finds the first level one header on this or some previous page
#let heading_near_to_here = context {
  let here = here()
  let page = here.page()

  // get all headings of level 1 after this one
  let next_headings = query(heading.where(level: 1).after(here))

  // check if there is at least one heading ahead
  if (next_headings.len() != 0) {
    let n = next_headings.first()
    // get the page of the first upfront heading
    let np = locate(heading.where(level: 1, body: n.body)
      .after(here))
      .page()
    // check if the heading is on the same page as we are
    if np == page {
      // return if so
      return n.body
    }
  }

  // if we haven't found any header on this page, we take the 
  // nearest previous one
  let nearest_prev = query(heading.where(level: 1).before(here))
    .last()
    .body
  return nearest_prev
}

// the common header that is used on all pages except the first one
#let common_header(title) = {

  // insert the header reference if needed
  // header_reference 
  
  v(settings.HEADER_INNER_MARGIN)
  set text(10pt)
  set align(top)
  block(
    grid(
      columns: (1fr, auto),
      column-gutter: 2mm,
      pad(top: 3mm)[
        #grid(
          row-gutter: 2mm,
          title,
          [#heading_near_to_here],
          {
            v(1mm)
            line(length: 100%, stroke: rgb("#c80404"))
          },
        )
      ],
      pad(top: 1mm, right: -1mm,
        image("images/HTLWienWest.png", height: 1.91cm)
      )
    )
  ) 
}

// the common footer with page number that is used on all pages except the 
#let common_footer(participants) = {
  set text(10pt)
  set align(top)
  v(settings.FOOTER_INNER_UPPER_MARGIN)

  let page_num = context {
    let c = counter(page)
    let num = here().page-numbering()
    if num == "i" {
      c.display(num)
    } else {
      let n = c.display() 
      let f = numbering(num, c.final().first())
      [#n von #f]
    }
  }

  let authors = participants.map(e => e.vorname + " " + e.nachname).join(", ")

  context {
    // page number and author side switching on each page
    let pair = if calc.rem(here().page(), 2) == 0 {
      (page_num, authors)
    } else {
      (authors, page_num)
    }
    
    grid(
      columns: (1fr, auto),
      inset: 1mm,
      stroke: (top: rgb("#c80404")),
      ..pair
    )
  }
}


// returns the `Ausgearbieted von ...` string for some heading
#let elaborated_by = context {
  let currPage = here().page()

  let startOfBody =locate(<startOfBody>).page()
  if startOfBody > currPage {
    return []
  }
  
  let endOfBody =locate(<endOfBody>).page()
  if endOfBody <= currPage {
     return []
  }

  // select next heading with level 1 or 2
  let next_header_sel = selector(heading.where(level:   1)
      .or(heading.where(level: 2)))
    .after(here())
  // select metadata between this heading and next heading
  let meta_sel = selector(metadata)
    .before(next_header_sel)
    .and()
    .after(here())

  // get those metadata and filter for author ones
  let meta_q = query(meta_sel)
    .filter(e => e.value.keys().contains("type"))
    .filter(e => e.value.type == "author")

  let author = if meta_q.len() != 0 {
    meta_q.first().value.value
  } else {
    return []
  }

  return [Ausgearbeitet von #author]  
}
