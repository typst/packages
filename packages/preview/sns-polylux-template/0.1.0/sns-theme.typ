/***************************************************************
 * A polylux theme by martino barbieri (https://mbarbieri.it)  *
 ***************************************************************/

#import "@preview/polylux:0.4.0" as pl: *

/* PER TEMPLATE SNS */
// Background and decorations
#let sns-theme_sns-colormap = (
rgb("#00728D"),
rgb("#183F56"),
rgb("#4D4E4F"),
rgb("#AB3502"),
rgb("#E69426"),
rgb("#9CD7F3"),
)

/* PER TEMPLATE UNIPI */
#let sns-theme_unipi-colormap = (
cmyk(100%,57%,0%,9%),
cmyk(100%,57%,0%,38%),
rgb("#444444"),
rgb("#AB3502"),
rgb("#E69426"),
cmyk(25%,7%,0%,0%),
)

#let sns-theme_colormap              = state("colormap",    none)

// Text and Fonts
#let sns-theme_text-font             = state("txt-font",    none)
#let sns-theme_title-font            = state("title-font",  none)
#let sns-theme_background-color      = state("bkg_color1",  none)
#let sns-theme_main-text-color       = state("txt_color1",  none)
#let sns-theme_second-text-color     = state("txt_color2",  none)
#let sns-theme_title-text-color      = state("title_color", none)
#let sns-theme_size                  = state("size",        none)

// Data
#let sns-theme_title                 = state("title",       none)
#let sns-theme_short-title           = state("short-title", none)
#let sns-theme_subtitle              = state("subtitle",    none)
#let sns-theme_event                 = state("event",       none)
#let sns-theme_short-event           = state("short-event", none)
#let sns-theme_authors               = state("authors",     none)

#let sns-theme_logo-1                = state("logo-1",      none)
#let sns-theme_logo-2                = state("logo-2",      none)

// Init
#let sns-theme(
  // General parameters
  aspect-ratio : "16-9",

  txt-font     : ("Roboto", "Fira Sans", "DejaVu Sans"),
  title-font   : ("Raleway", "PT Sans", "DejaVu Sans"),
  txt-color1   : black,
  txt-color2   : white,
  title-color  : rgb("#444444"),
  size         : 20pt,
  bkgnd-color  : white,

  colormap     : sns-theme_sns-colormap,

  // Data
  title        : none,
  subtitle     : none,
  short-title  : none,
  event        : none,
  short-event  : none,
  logo-2       : none,
  logo-1       : none,
  authors      : none,
  // Stuff
  body
) = {
  sns-theme_text-font.update(txt-font)
  sns-theme_title-font.update(title-font)
  sns-theme_background-color.update(bkgnd-color)
  sns-theme_main-text-color.update(txt-color1)
  sns-theme_second-text-color.update(txt-color2)
  sns-theme_title-text-color.update(title-color)
  sns-theme_size.update(size)

  sns-theme_colormap.update(colormap)

  set page(
    paper : "presentation-" + aspect-ratio,
    fill  : bkgnd-color,
    margin: 0pt,
    header: none,
    footer: none,
    header-ascent: 0pt,
    footer-descent: 0pt,
  )
  set text(
    fill : txt-color1,
    size : size,
    font : txt-font,
  )
  sns-theme_title.update(title)
  sns-theme_subtitle.update(subtitle)
  if short-title != none { sns-theme_short-title.update(short-title) }
    else { sns-theme_short-title.update(title) }
  sns-theme_event.update(event)
  if short-event != none { sns-theme_short-event.update(short-event) }
    else { sns-theme_short-event.update(event) }
  sns-theme_logo-2.update(logo-2)
  sns-theme_logo-1.update(logo-1)
  sns-theme_authors.update(authors)

  body
}

//Slides
#let title-slide(
  body            : none
) = context( {
  let content = align(top + center, context( {
    let title       = sns-theme_title.at(here())
    let subtitle    = sns-theme_subtitle.at(here())
    let event       = sns-theme_event.at(here())
    let authors     = sns-theme_authors.at(here())
    let logo        = sns-theme_logo-1.at(here())

    // Background
    place(
      bottom + right,
      polygon(
        fill   : sns-theme_colormap.at(here()).at(2),
        stroke : none,
        (0%, 42%),(100%, 42%),(100%, 0%),
      ),
    )
    place(
      bottom + right,
      polygon(
        fill   : sns-theme_colormap.at(here()).at(1),
        stroke : none,
        (0%, 29%),(0%, 37%),(100%, 37%),(100%, 0%),
      ),
    )
    place(
      bottom + right,
      polygon(
        fill   : sns-theme_colormap.at(here()).at(0),
        stroke : none,
        (0%, 20%),(0%, 30%),(100%, 30%),(100%, 0%),
      ),
    )
    place(
      top + left,
      dx: 2pt,
      polygon(
        fill   : sns-theme_colormap.at(here()).at(2),
        stroke : none,
        (10%, 0%),(0%, 16%),(75%, 0%),
      ),
    )
    place(
      top + left,
      polygon(
        fill   : sns-theme_colormap.at(here()).at(0),
        stroke : none,
        (0%, 0%),(0%, 15%),(75%, 0%),
      ),
    )
    place(
      bottom + center,
      dy: -1cm,
      text(fill: sns-theme_background-color.at(here()), size: 22pt, event)
    )
    if logo != none {
      place(
        bottom + right,
        dx: -0.5cm,
        dy: -0.3cm,
        scale(page.height/measure(logo).height*22%, reflow: true, logo)
      )
    }

    // Contents
    set align(center + horizon)
    v(-25%)
    text(
      font : sns-theme_title-font.at(here()),
      size : 64pt,
      fill: sns-theme_title-text-color.at(here()),
      strong(title)
    )
    linebreak()
    v(0em)
    text(
      font : sns-theme_title-font.at(here()),
      size : 22pt,
      fill: sns-theme_title-text-color.at(here()),
      subtitle
    )
    v(-0.9em)
    line(length: 90%, stroke: (paint: sns-theme_colormap.at(here()).at(5), thickness: 4pt))
    v(0.5em)
    set text(
      size: 24pt,
      top-edge: 0pt,
      bottom-edge: 0pt,
      fill: sns-theme_main-text-color.at(here())
    )
    for i in range(authors.len()) {
      move(dx: 2% * ( i - ( authors.len() - 1 ) / 2 ), authors.at(i))
    }
    body
  } ))

  pl.slide({ content })

  counter("logical-slide").update( n => n - 1 )
} )

#let small-sections(show-sec-name: true) = context( {
  set text(bottom-edge: "descender")
  if show-sec-name {pl.toolbox.current-section;" "}

  pl.toolbox.all-sections(
    (sections, current) => {
      let over_current = false
      for i in sections {
        if current == i {$ast.circle$; over_current = true}
        else if (over_current or current not in sections) {
          $circle.dotted$
        } else {$circle.filled$}
      }
    }
  )
} )

#let big-sections = context( {
  set align(horizon + right)
  grid(
  box(height: 40%, inset: 0.8cm)[#small-sections(show-sec-name: false)],
  box(height: 60%, inset: 0.8cm)[
    #pl.toolbox.current-section
  ])
} )

#let slide(
  title           : none,
  subtitle        : none,
  new-sec         : false,
  body
) = context( {
  // HEADER
  let header = align(top, context( {
    let logo        = sns-theme_logo-2.at(here())

    // If new-sec is false, do nothing
    // If new-sec is true, new section's name is the slide title
    // Else the new-sec name is new-sec
    if type(new-sec)==bool {if new-sec {
      pl.toolbox.register-section(title)
    }}
    else {pl.toolbox.register-section(new-sec)}

    place(
      top + left,
      grid(
        columns: (auto,auto),
        gutter: 0pt,
        if logo != none { pad(logo, x: 0.3cm, top: 0.2cm) },
        align(horizon+right,
        if title != none {
          grid(rect(
            width: 100%, height: 40%,
            inset: 0.8cm, outset: 0pt,
            fill: sns-theme_colormap.at(here()).at(1),
            align(horizon,text(fill: sns-theme_second-text-color.at(here()), {
              small-sections(show-sec-name: new-sec != true)}
            ))
          ),
          rect(
          width: 100%, height: 60%,
          inset: 0.8cm, outset: 0pt,
          fill: sns-theme_colormap.at(here()).at(0),
          align(horizon + center,
          {
            text(
              fill: sns-theme_second-text-color.at(here()),
              font: sns-theme_title-font.at(here()),
              size: 32pt,
              weight: "bold",
              title
            )
            if subtitle != none {
              smallcaps(text(
                fill: sns-theme_second-text-color.at(here()),
                font: sns-theme_title-font.at(here()),
                size: 24pt,
                " — " + subtitle
              ))
            }
          }
          )
          ))} else {
          rect(
            width: 100%, height: 100%,
            inset: 0cm, outset: 0pt,
            fill: sns-theme_colormap.at(here()).at(1),
            align(horizon + right,text(fill: sns-theme_second-text-color.at(here()),
              big-sections
            )))
          }
        )
      )
    )
  } ))

  // FOOTER
  let footer = align(top + center, context( {
    let short-title = sns-theme_short-title.at(here())
    let short-event = sns-theme_short-event.at(here())

    place(top + center, line(length: 100%-2cm, stroke: (paint: sns-theme_colormap.at(here()).at(1), thickness: 2pt)))

    set text(bottom-edge: "descender")

    block(
      height: 100%,
      width: 100%,
      inset: (x: 0.8cm),
      align(horizon,text(fill: sns-theme_colormap.at(here()).at(2), size: 16pt,
      grid(
        gutter: 0.8cm,
        columns: (0.7fr, 1fr, 0.7fr),
        align(left, short-title),
        align(center, smallcaps(short-event)),
        align(right, [#toolbox.slide-number/#toolbox.last-slide-number]),
      ))
    ))
  } ))

  set page(
    margin: (top: 2.5cm, bottom: 1cm),
    header: header,
    footer: footer,
  )

  pl.slide({
    set align(horizon)
    set text(size: sns-theme_size.at(here()), top-edge: 20pt, bottom-edge: 0pt)
    show: block.with(inset: (x: 1.2cm, y:.2cm), width: 100%)
    body
  })
} )

#let focus-slide(
  new-sec : none,
  body
) = context( {
  // HEADER
  let header = align(top, context( {
    let logo        = sns-theme_logo-1.at(here())
    set text(size: sns-theme_size.at(here()))

    // If new-sec is none, do nothing
    // Else the new-sec name is new-sec
    if new-sec!=none {pl.toolbox.register-section(new-sec)}

    place(
      top + left,
      grid(
        columns: (auto,auto),
        gutter: 0pt,
        if logo != none { pad(logo, x: 0.3cm, top: 0.2cm) },
        align(top+right,grid(
          box(
            width: 100%, height: 100%,
            inset: (top: 4pt, x: 0pt, bottom: 0pt), outset: 0pt,
            align(horizon,text(fill: sns-theme_second-text-color.at(here()),
              big-sections
            ))
          ),
        )
      ))
    )
  } ))

  set page(
    margin: (top: 2.5cm, bottom: 0cm),
    header: header,
    footer: none,
    fill: sns-theme_colormap.at(here()).at(1),
  )

  pl.slide({
    set align(horizon + center)
    set text(
      size: sns-theme_size.at(here())*1.5,
      fill: sns-theme_second-text-color.at(here()),
      style: "italic"
    )
    show: block.with(inset: (x: 1.2cm, y:.2cm), width: 100%)
    body
  })
} )

#let empty-slide(
  body
) = context( {
  // HEADER
  let header = align(top, context( {
    let logo        = sns-theme_logo-1.at(here())

    place(
      top + left,
      box(
        height: 2.5cm,
        if logo != none { pad(logo, x: 0.3cm, top: 0.2cm) }
      )
    )
  } ))

  set page(
    margin: (top: 0cm, bottom: 0cm),
    foreground: header,
    footer: none,
    fill: sns-theme_colormap.at(here()).at(1),
  )

  pl.slide({
    set align(horizon + center)
    set text(
      size: sns-theme_size.at(here())*1.5,
      fill: sns-theme_second-text-color.at(here()),
    )
    show: block.with(inset: (x: 1.2cm, y:.2cm), width: 100%)
    body
  })

  counter("logical-slide").update( n => n - 1 )
} )

#let new-section-slide(name)  = context( {
  // HEADER
  let header = align(top, context( {
    let logo        = sns-theme_logo-1.at(here())

    place(
      top + left,
      box(
        height: 2.5cm,
        if logo != none { pad(logo, x: 0.3cm, top: 0.2cm) }
      )
    )
  } ))

  set page(
    margin: (top: 0cm, bottom: 0cm),
    foreground: header,
    footer: none,
    fill: sns-theme_colormap.at(here()).at(1),
  )

  // TOC
  let content = context( {
    pl.toolbox.all-sections( (sections, current) => {
    set text(weight: "regular")
    let over_current = false
    for i in sections {
      if (current == i) {[
        + #text(weight: "black", i)
      ]; over_current = true}
      else if (over_current) [
        + #text(weight: "thin", i)
      ]
      else [
        + #text(i)
      ]
    }
    } )
  } )

  pl.slide({
    set align(horizon + center)
    set text(
      size: sns-theme_size.at(here())*1.5,
      fill: sns-theme_second-text-color.at(here()),
    )
    pl.toolbox.register-section(name)

    show: box.with()
    set align(left)
    content
  })

  counter("logical-slide").update( n => n - 1 )
} )

#let toc-slide()  = context( {
  // HEADER
  let header = align(top, {
    let logo        = sns-theme_logo-1.at(here())

    place(
      top + left,
      box(
        height: 2.5cm,
        if logo != none { pad(logo, x: 0.3cm, top: 0.2cm) }
      )
    )
  } )

  set page(
    margin: (top: 0cm, bottom: 0cm),
    foreground: header,
    footer: none,
    fill: sns-theme_colormap.at(here()).at(1),
  )

  // TOC
  let content = {
    pl.toolbox.all-sections( (sections, current) => {
    for i in sections [
      + #text(i)
    ]
    } )
  }

  pl.slide({
    set align(horizon + center)
    set text(
      size: sns-theme_size.at(here())*1.5,
      fill: sns-theme_second-text-color.at(here()),
    )

    show: box.with()
    set align(left)
    content
  })

  counter("logical-slide").update( n => n - 1 )
} )
