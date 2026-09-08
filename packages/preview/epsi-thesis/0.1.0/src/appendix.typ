#import "layout.typ": apply-common-layout, apply-heading-level2-styles, apply-figure-styles, dict

#let appendix-matter(language: "PT", appendix) = {
  set heading(numbering: "A")
  counter(heading).update(0)

  // Aplicar layout comum (margens, texto, parágrafos)
  apply-common-layout(lang: language)[
    #apply-figure-styles[
      #show heading.where(level: 1): it => {
        pagebreak(weak: false)
        
        context {
          let letra = numbering(it.numbering, ..counter(heading).at(it.location()))
          let prefixo = dict("appendix", lang: language)
  
          // "Anexo A" centrado
          align(center, text(size: 12pt, weight: "bold")[#prefixo #letra])
          
          v(1em)
          
          // Subtítulo à esquerda
          align(left, text(size: 12pt, weight: "bold", it.body))
          
        }
      }
  
      #show outline.entry.where(level: 1): it => {
        let loc = it.element.location()
        context {
          let letra = numbering(it.element.numbering, ..counter(heading).at(loc))
          
          link(loc)[#letra - #it.element.body]
          box(width: 1fr, it.fill)
          it.page
        }
      }
  
      // Aplicar estilos de nível 2 definidos centralmente em layout.typ
      #apply-heading-level2-styles[
        #appendix
      ]
    ]
  ]
}

