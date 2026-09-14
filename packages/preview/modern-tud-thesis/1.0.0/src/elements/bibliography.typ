#import "@preview/hydra:0.6.2": anchor
#import "/src/utils.typ": i18n


#let maincontent-counter(name) = {
  if query(<backmatter-start>).len() > 0 {
    counter(name).at(<backmatter-start>)
  } else {
    counter(name).final()
  }
}

#let references = (
  "outline": (
    title: i18n("ref-count"),
    counter: context {query(cite).map(c => c.key).dedup().len()},
  ),
  "pages": (
    title: i18n("page-count"),
    counter: context {maincontent-counter(page).at(0)},
  ),
  "figures": (
    title: i18n("figure-count"),
    counter: context {maincontent-counter(figure.where(kind: image)).at(0)},
  ),
  "tables": (
    title: i18n("table-count"),
    counter: context {maincontent-counter(figure.where(kind: table)).at(0)},
  ),
  "appendix": (
    title: i18n("appendix-count"),
    counter: context {counter("appendix").final().at(0)}
  )
)

#let bibliography(
  title: none,
  authors: none,
  faculty: none,
  thesis-type: none,
  chair: none,
  abstract: none,
  showbibliography: false,
  number-of-attachments: none,
) = {

  if showbibliography == false{
    return
  }

   // set anchor for hydra
  set page(header: anchor())
  
  // abstract
  if  abstract != none {
    heading(i18n("abstract"), outlined: false)
    abstract
  }

  
  // bibliography reference
  place(
    bottom,
    [
      #heading(i18n("bibliography-reference"), outlined: false)

      #for author in authors {
          author.name
          linebreak()
      }

      #title \
      #thesis-type

      #i18n("university-name"), \
      #faculty,\
      #chair

      #grid(
        columns: 2,
        gutter: 1em,
        ..for (name, reference) in references {
          if showbibliography == auto or name in showbibliography {
            (reference.title, reference.counter)
          }
        },
        ..if number-of-attachments != none {
          (
            i18n("attachement-count"),
            str(number-of-attachments)
          )
        }
      )
    ]
  )
}
