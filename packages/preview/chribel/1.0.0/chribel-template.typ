#import "callouts.typ": callout, chribel-add-callout-template

#let chribel(
  title: none,
  subtitle: none,
  authors: none,
  subject: (
    short: none,
    long: none
  ),
  university: none,
  links: none,
  columns-count: 2,
  creation-date: datetime.today(),
  accent-color: rgb("#2e6bba"),
  body
) = {

  if type(authors) != array {
    authors = (authors,)
  }
  if type(links) == dictionary {
    links = (links,)
  }

  let header-title = if title.has("children") {
    title.children.filter(n => n.func() != linebreak).join()
  } else {
    title
  }
  /* ---------------------- Rules ---------------------- */
  set columns(gutter: 5mm)
  set page(margin: (x:6mm, y: 12mm),
    columns: columns-count,
    header: grid(
      columns: (1fr,) * 2,
      align: (left, right),
      stroke: (bottom: black + 0.5pt),
      inset: (bottom: 0.4em),
      ..{
        (university, header-title + if(subtitle != none){sym.space + sym.dash.en + sym.space + subtitle})
      }
    ),
    footer: grid(
      columns: (1fr,) * 3,
      align: (left, center, right),
      stroke: (top: black + 0.5pt),
      inset: (top: 0.4em),
      ..{
        (creation-date.display("[day].[month].[year]"), context{
          let current = here()
          let total = locate(<last-page>)
          
          [#current.page() / #text(link(total.position())[#total.page()], blue)]
        },subject.short)
        
      }
    ),
    
  )

  show heading: set text(font: "Arvo")
  set text(font: "Atkinson Hyperlegible Next", weight: "light", 10pt)
  set par(justify: true)


  show raw.where(block: true): block.with(stroke: gray+0.5pt, fill: gray.lighten(95%), radius: 3pt, width: 100%, inset: 0.5em, sticky: true, above: 1em, below: 1em)
  show raw.where(block: true): set text(0.9em)

  show raw.where(block: false): box.with(stroke: gray.lighten(50%)+0.5pt, fill: gray.lighten(95%), radius: 2pt, inset: (x:0.2em), outset: (y: 0.3em))
  

  
  
  show heading.where(level: 1): it => stack(
    spacing: 0.3em,
    it,
    line(stroke: (paint: accent-color, thickness: 1.25pt, cap: "round"), length: 100%)
  )

  show heading.where(level: 2): it => stack(
    spacing: 0.3em,
    it,
    line(stroke: (dash: (4pt, 4pt), paint: accent-color, thickness: 0.5pt, cap: "round"), length: 100%)
  )

  show outline.entry.where(level: 1): it => {
    block(above: 1.3em, stroke: (bottom: black + 0.5pt), inset: (bottom: 0.2em),link(
      it.element.location(),
      text(weight: "bold",it.indented(it.prefix(), it.body() + h(1fr) + it.page()))
    ))
  }

  set enum(numbering: n => text(0.9em, weight: "bold", accent-color, text(font: "Fantasque Sans Mono")[#n]+[.], baseline: 0.05em), body-indent: 0.3em)





  /* -------------------- Functions -------------------- */
  let title-block(title: none, subtitle: none, authors: none, links: none) = {
    
    show block: align.with(center)

    
    
    block({
      
      v(1cm)  
      text(2em,title, weight: "bold", font: "Arvo") + linebreak()
      text(1em,subtitle, style: "italic")
      
    })
    if((authors != none and type(authors) in (array,)) or 
       (links != none and type(links) in (array,) and type(links.first()) in (dictionary,))) {

      
         
      block({
        authors.join(", ")
        h(0.5em) + [*\/*] + h(0.5em)
        for href in links {
          (box(link(href.link,href.text), fill: accent-color.lighten(90%), stroke: (paint: accent-color, thickness: 0.5pt, dash: "dashed", cap: "round"), radius: 3pt, outset: (y: 3pt), inset: (left: 1pt, right: 3pt))) + h(0.4em, weak: true)
        }
      })
    }
    v(1cm)
  }


  /* ----------------------- Body ---------------------- */  
  title-block(title: title, subtitle: subtitle, authors: authors, links: links)

  body

  [#metadata("This is the last page of the document") <last-page>]
  
}
