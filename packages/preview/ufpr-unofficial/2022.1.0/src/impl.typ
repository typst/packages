#let _note(body) = {
  set text(size: 10pt)
  set par(leading: 1em, spacing: 1em)
  body
}

#let _citation_handle(value) = {
  return if type(value) == content and value.func() == ref [#cite(
    value.at("target"), form: "prose"
  )] else {value}
}

#let _default-source = [Autor (#datetime.today().year())]

#let _annex_list = state("annex-list", ())

/*
Elemento que renderiza ilustrações ou anexos.

As ilustrações são elementos que explicam e/ou complementam visualmente o documento e devem ser inseridas
o mais próximo possível do trecho a que se referem.

Anexo é um texto ou documento não elaborado pelo(a) autor(a), que serve de fundamentação, comprovação ou
ilustração.

= Exemplo
````
// Ilustração
#illustration(
  image("gato.png", height: 5cm),
  supplement: "fotografia",
  caption: "Foto do meu gato.",
  source: "Autor (2019)"
)

// Anexo
#illustration(
  image("ABNT_NBR_14724_2024-1.pdf"),
  supplement: "anexo",
  caption: "ABNT NBR 14724",
  source: [@abnt-nbr-14724],
)
````

- body (content): Conteúdo a ser representado na ilustração.
- supplement (str): Tipo de ilustração, podendo ser `"figura"`, `"gráfico"`, `"mapa"`, `"fotografia"`, etc.,
  ou colocar como anexo com `"anexo"`.
- caption (content): Título da ilustração, contendo sua descrição.
- source (content): Fonte da ilustração. Por padrão, esse valor é "Autor (_ano atual_)", mas pode ser uma
  referêcia à uma obra como ` [@obra] `.
*/
#let illustration(
  body,
  supplement: "figura",
  caption: "",
  source: _default-source,
) = {
  if caption == "" {panic("Argumento caption é obrigatório e deve ter o título da ilustração.")}
  counter(lower(supplement)).step()
  if lower(supplement) == "anexo" {
    _annex_list.update(l => l + ((
      body: body,
      caption: caption,
      source: source
    ),))
  } else {
    align(center, block(breakable: false)[
      #figure(body,
        caption: caption,
        supplement: upper(supplement)
      )
      #v(1em, weak: true)
      #align(center, _note[FONTE: #_citation_handle(source).])
    ])
  }
}

/*
Tabelas são elementos que apresentam informações tratadas estatisticamente e devem ser inseridas o
mais próximo possível do trecho a que se referem.

= Exemplo
```
#sheet(
  columns: 2,
  caption: "Tabela de chave-valor.",
  source: [@joao-silva],
  note: [
    Essa tabela é um exemplo de como usar a função `sheet()`.
  ]
  legend: [
    Toda chave é associada a um valor.
  ]
)
```

- children (content): Conteúdo de cada célula da tabela.
- columns (int|array): Número de colunas da tabela ou seu espaçamento.
- caption (content): Título da tabela, contendo sua descrição.
- source (content): Fonte da tabela. Por padrão, esse valor é "Autor (_ano atual_)", mas pode ser uma
  referêcia à uma obra como ` [@obra] `.
- breakable (bool): Indica se a tabela pode quebrar entre páginas quando o conteúdo for longo.
- note (content|none): Notas da tabela, elemento opcional.
- legend (content|none): Legenda da tabela, elemento opcional.
*/
#let sheet(
  columns: 1,
  caption: "",
  source: _default-source,
  breakable: false,
  note: none,
  legend: none,
  ..children
) = {
  if caption == "" {panic("Argumento caption é obrigatório e deve ter o título da tabela.")}
  let n-cols
  let cols
  if type(columns) == int {
    n-cols = columns
    cols = range(columns).map(_ => 1fr)
  }
  else if type(columns) == array {
    n-cols = columns.len()
    cols = columns
  }
  else {panic("Argumento columns deve ser um número inteiro ou uma array de medidas.")}

  show figure: set block(breakable: breakable)
  let caption-line = table.cell.with(colspan: n-cols, stroke: none, inset: (left: 0pt, top: 1em))
  let footer = (caption-line[FONTE: #source],)
  if note != none {footer.push(caption-line[NOTAS: #note])}
  if legend != none {footer.push(caption-line[LEGENDA: #legend])}
  counter("tabela").step()

  context {
    let break-counter = counter("tabela-" + counter("tabela").display())
    let break-indicator = context {
      let final = break-counter.final().at(0)
      let idx = break-counter.get().at(0)
      if final == 1 []
      else if idx == 0 [ (continua)]
      else if idx == final - 1 [ (conclusão)]
      else [ (continuação)]
      break-counter.step()
    }

    figure(
      table(
        columns: cols,
        table.header(
          caption-line(inset: (bottom: 1em, left: 0pt))[
            TABELA #counter("tabela").display() -- #caption#break-indicator
          ],
          ..children.pos().slice(0, n-cols)
        ),
        ..children.pos().slice(n-cols),
        ..footer
      ),
      caption: caption,
      supplement: "TABELA"
    )
  }
}

/*
Template principal para a construção de trabalhos acadêmicos no padrão ABNT, incluindo elementos
pré-textuais, textuais e pós-textuais.

= Exemplo
```
// Exemplo de um relatório sem elementos opcionais
#show: template.with(
  title: "Meu Relatório Técnico",
  authors: ("Fulano de Tal",),
  advisor: "Prof. Dr. Orientador",
  city: "Cidade",
  year: 2026,
  description: [
    Relatório técnico apresentado à disciplina de Metodologia Científica
    da Universidade Federal do Paraná, como requisito parcial para aprovação
    na disciplina.
  ],
  references: bibliography("refs.bib"),
  abstract: [
    Este relatório técnico apresenta o desenvolvimento de uma solução para organização
    e padronização de documentos acadêmicos utilizando Typst. (...)
  ]
)
// O conteúdo textual começa aqui
= Introdução
(...)
```

- body (content): Conteúdo principal do trabalho.
- title (str): Título do trabalho.
- authors (array): Array com os nomes completos dos autores.
- advisor (str): Nome completo com formação do(a) orientador(a).
- city (str): Cidade da instituição à qual o trabalho é submetido.
- year (int): Ano de realização do trabalho.
- description (content): Descrição da natureza acadêmica do trabalho, objetivo, instituição e área de concentração.
- references (bibliography): Elemento `bibliography("refs.bib")` onde "refs.bib" é o arquivo BibTex de referências
  utilizadas no trabalho.
- has-cover (bool): Opcional, indica se deve incluir a capa.
- co-advisor (content|none): Opcional, nome do(a) coorientador(a), quando houver.
- catalog (content|none): Opcional, elemento `image` da ficha catalográfica (verso da folha de rosto).
- approval (content|none): Opcional, elemento `image` da folha de aprovação.
- dedication (content|none): Opcional, texto de dedicatória.
- acknowledgement (content|none): Opcional, texto de agradecimentos.
- epigraph (array): Opcional, lista de epígrafes como _array_ de elementos `quote`.
- abstract (content|none): Opcional, resumo em língua vernácula.
- abstract-foreign ((content|none, content|none)): Opcional, par com título e conteúdo do resumo em língua estrangeira.
- abbreviations (array): Opcional, lista de abreviaturas em pares de (termo, significado).
- acronyms (array): Opcional, lista de siglas em pares de (termo, significado).
- glossary (array): Opcional, lista de termos e definições, em pares de (termo, significado).
*/
#let template(
  body,
  // Obrigatórios
  title: "",
  authors: (),
  advisor: "",
  city: "",
  year: 0,
  description: [],
  references: none,
  // Opcionais
  has-cover: false,
  co-advisor: none,
  catalog: none,
  approval: none,
  dedication: none,
  acknowledgement: none,
  epigraph: (),
  abstract: none,
  abstract-foreign: (none, none),
  abbreviations: (),
  acronyms: (),
  glossary: (),
) = {
  // Conferir argumentos obrigatórios
  if title == "" {
    panic("Argumento title é obrigatório e deve ter o título do trabalho.")
  }
  if authors.len() == 0 {
    panic("Argumento authors é obrigatório e deve ter uma array dos nomes completos dos autores.")
  }
  if advisor == "" {
    panic("Argumento advisor é obrigatório e deve ter o nome completo com formação do(a) orientador(a) do trabalho.")
  }
  if city == "" {
    panic("Argumento city é obrigatório e deve ter o nome da cidade da instituição no qual o trabalho foi definido.")
  }
  if year == 0 {
    panic("Argumento year é obrigatório e deve ter o ano da realização do trabalho.")
  }
  if description == [] {
    panic("Argumento description é obrigatório e deve ter uma descrição indicando a natureza acadêmica do trabalho, objetivo, nome da instituição a que é submetido e a área de concentração.")
  }
  if references == none {
    panic("Argumento references é obrigatório e deve ter a função bibliography(bib) em que bib é o caminho do arquivo .BIB de referências.")
  }
  // --- Metadados do documento ---
  set document(
    author: authors,
    description: description,
    title: title
  )

  // --- Formatação global ---
  // Página
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      inside: 3cm,
      outside: 2cm
    ),
    header-ascent: 1cm,
    number-align: top
  )

  // Texto
  set par(
    first-line-indent: (all: true, amount: 1.5cm),
    justify: true,
    spacing: 1.5em,
    leading: 1.5em
  )
  set text(font: "Arial", size: 12pt, lang: "pt")

  // Títulos
  set heading(numbering: "1.1")
  show heading: it => {
    let weight
    let alignment
    if it.level == 1 {
      weight = "bold"
      pagebreak(weak: true)
    } else {
      weight = "regular"
      v(1.5em, weak: true)
    }
    if it.numbering == none {alignment = center} else {alignment = left}
    set text(size: 12pt, weight: weight)
    align(alignment, upper(it))
    v(1.5em)
  }

  // Ilustrações
  set figure.caption(separator: [ -- ], position: top)
  show figure.caption: it => if it.kind == table {none} else {_note(it)}
  set figure(gap: 1em)

  // Referências
  set bibliography(style: "abnt-autordata.csl", title: "Referências", full: true)
  set cite(form: "full")
  show ref: it => if it.element == none {footnote(it)} else {it}

  // Notas de Rodapé
  set footnote.entry(indent: 0pt, separator: line(length: 4cm, stroke: 1pt))
  show footnote.entry: it => _note(it)

  // Equações e Fórmulas
  set math.equation(numbering: i => text(font: "Arial")[(#i)], supplement: none)

  // Tabelas
  set table(
    stroke: (x, y) => (
      left: if x == 0 {none} else {1pt},
      y: 1pt
    ),
    align: (x, y) => if y == 1 {center} else {left}
  )
  set table.header(repeat: true)
  show table: it => _note(it)

  // Menções
  show quote: it => block[
    #text(style: "italic", it)
    #align(right)[-- #it.attribution]
  ]

  // Enumerações
  set enum(
    indent: 1.5cm,
    numbering: "a)"
  )

  // --- Páginas pré-textuais ---
  {
    let _title-placement(offset) = {
      for a in authors {align(center, upper(a))}
      for _ in range(12 - offset) {linebreak()}
      align(center, upper(text(title, hyphenate: false)))
    }
    let _city-year-placement = place(bottom + center)[#upper(city) \ #year]

    // Capa
    if has-cover {
      page(background: image("cover.png"))[
        #align(center)[UNIVERSIDADE FEDERAL DO PARANÁ\ \ ]
        #_title-placement(authors.len() + 2)
        #_city-year-placement
      ]
      pagebreak()*2
      counter(page).update(1)
    }

    // Folha de Rosto (frente)
    _title-placement(authors.len())
    align(right, block(width: 50%, align(left, _note[
      \ \
      #description
      \ \
      Orientador: #advisor
      #if co-advisor != none [\ Coorientador: #co-advisor]
    ])))
    _city-year-placement
    pagebreak()

  }
  // Folha de Rosto (verso)
  if catalog != none {catalog}
  pagebreak()

  // Aprovação
  if approval != none {
    approval
    pagebreak()
  }

  // Dedicatória
  if dedication != none {
    align(bottom + right, text(dedication, style: "italic"))
    pagebreak()
  }

  // Agradecimento
  if acknowledgement != none {
    heading("Agradecimentos", outlined: false, numbering: none)
    acknowledgement
    pagebreak()
  }

  // Epígrafe
  if epigraph.len() != 0 {
    for q in epigraph {
      linebreak()
      align(bottom + right, q)
    }
    pagebreak()
  }

  // Resumo
  if abstract != none {
    heading("Resumo", outlined: false, numbering: none)
    set par(first-line-indent: 0pt, leading: 1em, spacing: 1em)
    abstract
    pagebreak()
  }

  // Resumo em Língua Estrangeira
  if abstract-foreign != (none, none) {
    heading(abstract-foreign.at(0), outlined: false, numbering: none)
    set par(first-line-indent: 0pt, leading: 1em, spacing: 1em)
    abstract-foreign.at(1)
    pagebreak()
  }

  {
    let _figure-outline(kind, title) = context {
      let entries = ()
      for f in query(figure.where(kind: kind)) {
        entries.push[#f.supplement #counter(lower(f.supplement.text)).at(f.location()).first() --]
        entries.push[#f.caption.body.text #box(width: 1fr, repeat[.])]
        entries.push[#counter(page).at(f.location()).first()]
      }
      if entries.len() == 0 {return}
      heading(title, outlined: false, numbering: none)
      grid(..entries,
        columns: 3,
        column-gutter: measure[.].width,
        row-gutter: 1.5em,
        align: (x, y) => if x == 2 {bottom + right} else {top + left}
      )
    }

    // Lista de Ilustrações
    _figure-outline(image, "Lista de Ilustrações")

    // Lista de Tabelas
    _figure-outline(table, "Lista de Tabelas")
  }
  pagebreak(weak: true)

  // Lista de Abreviaturas
  if abbreviations.len() != 0 {block[
    #align(center)[*LISTA DE ABREVIATURAS*]
    #grid(columns: (auto, 1fr), column-gutter: 1em, row-gutter: 1.5em, ..abbreviations)
  ]}
  // Lista de Siglas
  if acronyms.len() != 0 {block[
    #align(center)[*LISTA DE SIGLAS*]
    #grid(columns: (auto, 1fr), column-gutter: 1em, row-gutter: 1.5em, ..acronyms)
  ]}

  // Sumário
  context {
    heading("Sumário", outlined: false, numbering: none)
    let entries = ()
    let weight
    for h in query(heading.where(outlined: true)) {
      weight = if h.level == 1 {"bold"} else {"regular"}
      if h.numbering == none {
        entries.push([])
      } else {
        entries.push(text(weight: weight)[#numbering("1.1", ..counter(heading).at(h.location()))])
      }
      entries.push(text(weight: weight)[#upper(h.body) #box(width: 1fr, repeat[.])])
      entries.push(text(weight: weight)[#counter(page).at(h.location()).first()])
    }
    grid(..entries,
      columns: 3,
      column-gutter: measure[.].width,
      row-gutter: 1.5em,
      align: (x, y) => if x == 2 {bottom + right} else {top + left}
    )
  }

  // --- Páginas textuais ---
  set page(numbering: (i, total) => align(if calc.odd(i) {right} else {left}, _note(i)))
  body

  // --- Páginas pós-textuais ---
  set page(numbering: none)

  // Referências
  references

  // Glossário
  if glossary.len() != 0 {
    set par(first-line-indent: 0pt)
    heading("Glossário", numbering: none)
    for (term, definition) in glossary.chunks(2) [
      *#upper(term):* #definition
      #linebreak()
    ]
    pagebreak(weak: true)
  }

  // Anexos
  context {
    let list = _annex_list.final()
    if list.len() > 0 {
      for (i, struct) in list.enumerate(start: 1) {
        heading(numbering: none)[ANEXO #i -- #struct.caption]
        struct.body
        align(center)[FONTE: #struct.source]
        pagebreak(weak: true)
      }
    }
  }
}