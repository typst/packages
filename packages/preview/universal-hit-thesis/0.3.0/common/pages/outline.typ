#import "../theme/type.typ": 字体
#import "../components/header.typ": use-hit-header
#import "../utils/states.typ": default-header-text-state, special-chapter-titles-state

#let outline-page(
  use-same-header-text: false,
  bilingual: false,
  par-leading: 0.65em,
  par-leading-en: 0.65em,
  par-spacing-en: 1.2em,
) = context [
  
  #let special-chapter-titles = special-chapter-titles-state.get()

  #show: use-hit-header.with(
    header-text: if use-same-header-text {
      special-chapter-titles.目录
    }
  )

  #set par(leading: par-leading)

  #[
    #show heading: none
    #heading(special-chapter-titles.目录, level: 1, outlined: false)
  ]

  #show outline.entry.where(level: 1): set text(font: 字体.黑体)

  #outline(title: align(center)[#special-chapter-titles.目录], indent: 1em)

  #if bilingual {
      pagebreak()
      set par(first-line-indent: 0em, leading: par-leading-en, spacing: par-spacing-en)
      show: use-hit-header.with(
        header-text: if use-same-header-text {
          special-chapter-titles.目录-en
        }
      )
      heading(level: 1, numbering: none, outlined: false)[#special-chapter-titles.目录-en] 
      let elems = query(metadata.where(label: <enheading>))
      for e in elems {
        let heading_before = query(heading.where().before(e.location())).last()
        let entry = []
        // indent according to level
        h(1em * (heading_before.level - 1))
        // display bold for level 1
        let t = if heading_before.level == 1{
          text.with(weight: "bold")
        } else {
          text
        }
        if heading_before.numbering != none{
          if heading_before.level == 1{
            entry += t()[Chapter ]
          }
          entry += t(numbering("1.1    ", ..counter(heading).at(e.location())))
          
        }
        entry += t(e.value)
        entry += box(width: 1fr, repeat([.]))
        entry += numbering(e.location().page-numbering(), ..counter(page).at(e.location()))
        link(heading_before.location(), entry)
        parbreak()
      }
    }
]