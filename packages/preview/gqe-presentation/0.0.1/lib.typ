// This theme contains ideas from the former "bristol" theme, contributed by
// https://github.com/MarkBlyth

#import "@preview/polylux:0.3.1": *
#import "@preview/showybox:2.0.1": showybox

#let clean-footer = state("clean-footer", [])
#let clean-short-title = state("clean-short-title", none)
#let clean-color = state("clean-color", rgb("#008685"))
#let clean-logo = state("clean-logo", none)
#let font-gqe = state("font-gqe",("PT Sans"))
#let logo-gqe = state("logo-gqe",image("assets/logo-gqe-le-moulon.png"))
#let logo-ideev = state("logo-ideev",image("assets/logo-ideev.jpg"))


#let gqe-theme(
  aspect-ratio: "4-3",
  footer: [HCERES – GQE-Le Moulon, 14-15/11/2024],
  short-title: none,
  logo: none,
  color: rgb("#4a7ebb"),
  font: ("PT Sans"),
  body
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 0em,
    header: none,
    footer: none,
  )
  set text(size: 25pt, font: font)
  show footnote.entry: set text(size: .6em)

  clean-footer.update(footer)
  clean-color.update(color)
  clean-short-title.update(short-title)
  clean-logo.update(logo)
  font-gqe.update(font)

  body
}


#let title-slide(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  watermark: none,
) = {

  let footer = align(bottom, context{
    set align(center)
    let color = clean-color.get()
    set text(size: 12pt, font: font-gqe.get(),fill:rgb("#008685"))
    

	    block(
	      stroke: ( top: 0.9pt + rgb("#4a7ebb") ), width: 90%, inset: ( y: 0.8em ),
	      grid(columns: (60%,40%),{
	      
	      grid(columns: (30%, 25%,20%,20%),{
		set align(horizon + center)
		set image(height: 25pt)
		image("assets/logo_faculte_sciences.png")
		},{
		set align(horizon + center)
		set image(height: 20pt)
		image("assets/logo-inrae-fond-blanc.png")
		},{
		set align(horizon + center)
		set image(height: 30pt)
		image("assets/logo_CNRS_biologie.png")
		},{
		set align(horizon + center)
		set image(height: 20pt)
		image("assets/logo_agroparistech.png")
	      }
	      
	      )
	      }, {
	      	set align(horizon + center)
	      	clean-footer.get()
	      	}  )
	    )
    
  })
  let content = context {
    let color = clean-color.get()
    let logo = clean-logo.get()
    let authors = if type(authors) in ("string", "content") {
      ( authors, )
    } else {
      authors
    }

    if watermark != none {
      set image(width: 100%)
      place(watermark)
    }

    v(5%)
    grid(columns: (5%, 1fr, 1fr, 5%),
      [],{
        set align(bottom + left)
        set image(height: 2em)
        logo-gqe.get()
        },{
        set align(bottom + right)
        set image(height: 2em)
        logo-ideev.get()
      } ,
      []
    )

    v(-10%)
    align(center + horizon)[
      #block(
        stroke: ( y: 1mm + color ),
        inset: 1em,
        breakable: false,
        [
          #text(1.3em)[*#title*] \
          #{
            if subtitle != none {
              parbreak()
              text(.9em)[#subtitle]
            }
          }
        ]
      )
      #set text(size: .8em)
      #grid(
        columns: (1fr,) * calc.min(authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..authors
      )
      #v(1em)
      #date
    ]
    
    show: footer
    
  }
  logic.polylux-slide(content)
}

#let slide(title: none, body) = {
  let header = align(top, context {

    show: block.with(width: 100%, inset: (y: .3em))
    grid(
      columns: (1fr, 1fr),
      {
        set align(left)
        set image(height: 1em)
        logo-gqe.get()
      },
      
      {
        set align(right)
        set image(height: 1em)
        logo-ideev.get()
      }
    )
  })

  let footer = context {
    let color = clean-color.get()
    set text(font: font-gqe.get(),fill:rgb("#008685"))

    block(
      stroke: ( top: 0.9pt + color ), width: 100%, inset: ( y: .3em ),
      text(.5em, {
        clean-footer.get()
        h(1fr)
        logic.logical-slide.display()
      })
    )
  }

  set page(
    margin: ( top: 2em, bottom: 2em, x: 1em ),
    header: header,
    footer: footer,
    footer-descent: 1em,
    header-ascent: 1.5em,
  )

  let body = pad(x: .0em, y: .5em, body)
  

  let content = {
    if title != none {
      heading(level: 2, title)
    }
    body
  }
  
  logic.polylux-slide(content)
}

#let focus-slide(background: teal, foreground: white, body) = {
  set page(fill: background, margin: 2em)
  set text(fill: foreground, size: 1.5em)
  let content = { v(.1fr); body; v(.1fr) }
  // logic.polylux-slide(align(horizon, body))
  logic.polylux-slide(content)
}

#let new-section-slide(name) = {
  set page(margin: 2em)
  let content = locate( loc => {
    let color = clean-color.at(loc)
    set align(center + horizon)
    show: block.with(stroke: ( bottom: 1mm + color ), inset: 1em,)
    set text(size: 1.5em)
    strong(name)
    utils.register-section(name)
  })
  logic.polylux-slide(content)
}





#let pave(titre, texte) = {
  set text(size: 0.9em)
 showybox(
  frame: (
    border-color: aqua.darken(50%),
    title-color: aqua.lighten(60%),
    body-color: aqua.lighten(80%),
    radius: 8pt,
  ),
  title-style: (
    color: black,
    weight: "bold",
    align: left
  ),
  shadow: (
    offset: 3pt,
  ),
  title: titre,
  texte
)
}

#let centrer(t) = align(
  end + horizon,
  t
)
