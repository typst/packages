#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/fontawesome:0.6.0": *

//
// Variables shared across multiple reports go here
// Anything specific to one report should be in main.typ as a report over-ride
//
#let mycolor = rgb(166, 0, 120);
#let myfont = "Arial";

//
//  Template for a paragaph with an author picture in a circle bottom right
// 
#let authorwrap(
  authorimage :none,
  authorcaption: none,
  body,
) = {
  wrap-content(
  box(width: 3cm, height:3.5cm,
  figure(
  box(clip: true, stroke: 5pt + mycolor, radius: 1.5cm, width: 2.5cm, height: 2.5cm,
          image(authorimage, height: 3cm)),
  caption: authorcaption,
  numbering: none)),
  body,
    align: bottom + right,
  )
}

//
//  Template for an information box. Can over-ride the icon shown.
// 
#let infobox(
  info, 
  icon: "info-circle"
) = {
    box(   
      fill: mycolor.lighten(90%),
      stroke: 1pt,
      radius: 8pt,
      width: 100%,
      grid(
        columns: (1fr, 8fr),
        inset: 8pt,
        align(horizon+center, fa-icon(icon, size: 2.5em)),
        align(horizon + left, info)
      )
  )
}

//
//  Main Report Template. Can over-ride title and publication date.
// 
#let report(
  title: "Title of the Work",
  publishdate: "Some Date",
  mylogo: "assets/logo.png",
  myfeatureimage: "assets/techimage.png",
  myvalues: "VALUE1 | VALUE2 | VALUE3 | VALUE4",
  body,
) = {
  // Set table to have alterate shaded rows
  set table( 
    align: left,
    inset: 10pt,
    fill: (_, y) => if calc.even(y) { mycolor.lighten(90%) } 
  )
  // Set table to have bold header
  show table.cell: it => {
    if it.y == 0 {
      strong(it)
    } else {
      it
    }
  }
  // Make links blue and underlined
  show link: set text(fill: mycolor)
  show link: underline
  // Cover page
  page(
    margin: 0cm,
    numbering: none,
  )[
    // Left colored bar
    #place(
      left + top,
      rect(
        width: 2cm,
        height: 100%,
        fill: mycolor,
      ),
    )
    
    #place(
      bottom + left,
      move(dx: 1.25cm, dy: -5cm,
        rotate(-90deg, origin: bottom + left,
          text(size: 28pt, fill: white, spacing: 140%, font: myfont, myvalues))
      )
    )

    #place(
      left + bottom,
      polygon(
        fill: mycolor.lighten(80%),
        stroke: none,
        (0pt, 0pt),
        (50%, 0pt),
        (50%, -8cm),
      )
    )

    #place(
      bottom + right,
      rect(
        width: 50%,
        height: 8cm,
        fill: mycolor.lighten(80%),
      ),
    )

    // Tech Image
    #place(
      bottom + right,
      move(
        dx: -7.5cm, dy: -5cm,
          box(clip: true, stroke: 5pt + mycolor, radius: 3cm,
          width: 6cm, height: 6cm,
          image(myfeatureimage, height: 6cm))
      )
    )

    // logo
    #place(
      bottom + right,
      move(
        dx: -1cm, dy: -1cm,
        image(mylogo, width: 20%)
      )
    )

    // Content
    #pad(
      left: 3cm,
      right: 2cm,
      top: 3cm,
      bottom: 3cm,
      {
        set text(font: myfont)
        set text(size: 12pt)

        // Header info
        v(1fr)

        // Title
        set text(size: 28pt, weight: "semibold")
        set par(leading: 0.5em, justify: false)
        title
        linebreak()      
        set text(size: 14pt, weight: "regular")
        publishdate

        v(1.2fr)
      },
    )
  ]

  // Table of Contents
  page(
    header: none,
    numbering: none,
  )[
    // Style the outline entries
    #show outline.entry.where(level: 1): it => {
      v(18pt, weak: true)
      text()[#strong(it)]
    }

    // Style level 2 entries in blue
    #show outline.entry.where(level: 2): it => {
      v(12pt, weak: true)
      text()[#it]
    }

    #set text(size: 10pt, font: myfont)

    // Custom title styled like chapter headings
    #block(
      above: 0pt,
      below: 25pt,
      {
        set text(size: 20pt, weight: "semibold", font: myfont, fill: mycolor)
        align(right)[Table of Contents]
        v(-0.9em)
        line(length: 100%, stroke: 0.5pt + mycolor)
        v(0.5em)
      },
    )

    #set par(leading: 1.8em)

    #outline(
      title: none,
      depth: 2,
      indent: auto,
    )
  ]

  // Page setup for content
  set page(
    paper: "a4",
    margin: (top: 3.5cm, bottom: 3cm, left: 2.5cm, right: 2.5cm),
    header: context {
      let page-num = counter(page).get().first()

      // Don't show header on first page
      if page-num <= 1 {
        return
      }

      // Check if current page has a chapter heading
      let current-page = here().page()
      let headings-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == current-page)

      // Don't show header on pages with chapter headings
      if headings-on-page.len() > 0 {
        return
      }

      // Show header on all other pages
      set text(fill: mycolor, size: 10pt, font: myfont)

      let chapter-title = {
        let elems = query(heading.where(level: 1))
        if elems.len() > 0 {
          let relevant = elems.filter(h => h.location().page() <= current-page)
          if relevant.len() > 0 {
            upper(relevant.last().body)
          }
        }
      }

      grid(
        columns: (1fr, auto),
        align: (left, right),
        chapter-title, counter(page).display(),
      )
      line(length: 100%, stroke: 0.5pt + mycolor)
    },
  )

  // Reset page counter for main content
  counter(page).update(1)

  // Text setup
  set text(size: 10pt, font: myfont)

  set par(
    leading: 0.65em,
    spacing: 1em,
    justify: false,
    first-line-indent: 0pt,
  )

  // Chapter headings (level 1)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(size: 20pt, weight: "semibold")
    block(
      above: 0pt,
      below: 20pt,
      spacing: 0pt,
      {
        set par(spacing: 0pt)
        if it.numbering != none {
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.6em,
            align: (left, right),
            text(fill: mycolor)[#counter(heading).display().],
            // Right side: heading text in black
            text(fill: mycolor)[#it.body],
          )
        } else {
          // If no numbering, just right-align the text
          align(right, it.body)
        }
        v(-0.9em)
        line(length: 100%, stroke: 0.5pt + mycolor)
        v(0.5em)
      },
    )
  }

  // Section headings (level 2)
  show heading.where(level: 2): it => {
    set text(size: 16pt, weight: "semibold")
    block(
      above: 1.5em,
      below: 1em,
      {
        if it.numbering != none {
          counter(heading).display()
          [. ]
        }
        h(0.6em)
        it.body
      },
    )
  }

  // Subsection headings (level 3)
  show heading.where(level: 3): it => {
    set text(size: 16pt, weight: "medium")
    block(
      above: 1.2em,
      below: 0.8em,
      {
        if it.numbering != none {
          counter(heading).display()
          [. ]
        }
        h(0.6em)
        it.body
      },
    )
  }

  set heading(numbering: "1.1")

  body

  // Back cover page
  page(
    margin: 0cm,
    numbering: none,
    header: none,
    fill: black,
  )[
    #place(
      top + left,
      rect(
        width: 100%,
        height: 100%,
        fill: mycolor,
      ),
    )

    // logo centered in bottom half
    #place(
      center + horizon,
      dy: 25%,
      rect(
        fill: white,
        radius: 0.5cm,
        image(mylogo, width: 20%),
      )
    )
  ]
}
