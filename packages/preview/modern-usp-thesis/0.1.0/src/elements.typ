// Elements for USP theses and dissertations

#let cover(
  institution: none,
  author: none,
  title: none,
  subtitle: none,
  volumes: none,
  local: none,
  year: none,
) = {
  set page(margin: 3cm)
  set align(center)
  set text(size: 12pt)

  if institution != none {
    upper(institution)
    v(1cm)
  }

  v(3cm)
  upper(author)

  v(4cm)
  text(14pt, strong(upper(title)))
  if subtitle != none {
    [: ]
    text(14pt, strong(upper(subtitle)))
  }

  if volumes != none {
    v(1cm)
    [Volume #volumes]
  }

  v(1fr)
  [#local \ #year]
  
  pagebreak()
}

#let title-page(
  author: none,
  title: none,
  subtitle: none,
  version: "Original",
  volumes: none,
  nature: none,
  institute: none,
  degree: none,
  program: none,
  area: none,
  area-label: "Área de Concentração: ",
  advisor: none,
  coadvisor: none,
  local: none,
  year: none,
) = {
  set page(margin: 3cm)
  set align(center)
  
  upper(author)
  
  v(4cm)
  text(14pt, strong(upper(title)))
  if subtitle != none {
    [: ]
    text(14pt, strong(upper(subtitle)))
  }
  
  v(2cm)
  strong(version)

  v(2cm)
  align(right)[
    #box(width: 50%)[
      #set align(left)
      #set text(size: 10pt)
      #nature
      
      #if area != none [#area-label #area]
      
      #advisor
      #if coadvisor != none [\ #coadvisor]
    ]
  ]

  v(1fr)
  [#local \ #year]

  pagebreak()
}

#let approval-sheet(
  author: none,
  title: none,
  subtitle: none,
  nature: none,
  date: "____/____/____",
  banca: (),
  labels: (
    author: "Autor",
    title: "Título",
    approved-on: "Aprovado em",
    banca: "Banca Examinadora",
    judgement: "Julgamento",
  ),
  is-branded: false,
) = {
  set page(margin: 3cm)
  set text(size: 12pt)
  
  [#labels.author: #author \ ]
  [#labels.title: #strong(title)]
  if subtitle != none [: #strong(subtitle)]
  
  v(1cm)
  nature
  if not nature.ends-with(".") [.]
  
  v(1cm)
  [#labels.approved-on: #date]
  
  v(1cm)
  align(center)[#labels.banca]
  v(0.5cm)
  
  for membro in banca [
    #v(1cm)
    #line(length: 100%, stroke: 0.5pt)
    #membro.nome \
    #membro.instituicao \
    #labels.judgement: #line(length: 3cm, stroke: 0.5pt)
  ]
  
  pagebreak()
}

#let abstract-page(
  title,
  body,
  keywords-list: (),
  keywords-label: "Palavras-chave: ",
  reference: none,
) = {
  heading(level: 1, numbering: none, outlined: false)[#title]
  
  set align(left)
  if reference != none {
    set text(size: 10pt)
    reference
    v(1cm)
  }
  
  set par(justify: true, leading: 0.5em)
  body
  
  v(1cm)
  strong([#keywords-label])
  keywords-list.join([. ])
  [.]
  
  pagebreak()
}
