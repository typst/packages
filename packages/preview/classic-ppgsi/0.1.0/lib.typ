// ============================================================================
// classic-ppgsi — porte 1:1 do modelo LaTeX abntex2ppgsi (PPgSI-EACH-USP)
// API pública em inglês; usar via namespace: #import "@preview/classic-ppgsi:0.1.0" as ppgsi
// ============================================================================

#import "biblio.typ": cite, prose, references, register-bib, _blue

// Pacotes do ecossistema integrados ao template (re-exportados via namespace):
//   ppgsi.lq      → lilaq  (gráficos de dados, dentro de ppgsi.figure)
//   ppgsi.cetz    → cetz   (desenho/diagramas, dentro de ppgsi.figure)
// glossy/codly/cheq agem por show-rule no corpo (ver thesis()).
#import "@preview/glossy:0.9.1" as glossy
#import "@preview/codly:1.3.0" as codly
#import "@preview/cheq:0.4.0": checklist
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/cetz:0.5.2" as cetz

#let cm-dash = "\u{2002}\u{2013}\u{2002}" // " – " (espaco-en + travessao + espaco-en)


#let _heading-numbering = (..nums) => {
  let n = nums.pos()
  if n.len() <= 3 { numbering("1.1.1", ..n) }
}

#let _chapter-mark(loc) = {
  // capitulos numerados + back-matter (apendice/anexo/referencias, outlined);
  // exclui pre-textuais (outlined:false), que nao tem cabecalho.
  let chaps = query(heading.where(level: 1)).filter(h => (
    h.location().page() <= loc.page() and (h.numbering != none or h.outlined == true)
  ))
  if chaps.len() == 0 { return none }
  let h = chaps.last()
  if h.numbering != none {
    let num = numbering("1", ..counter(heading).at(h.location()))
    [Capítulo #num. #h.body]
  } else {
    h.body
  }
}

// Conteudo "single space" (resumo, fontes, ficha, citacoes, referencias).
#let _single(body) = {
  set par(leading: 0.65em, spacing: 0.65em)
  body
}

// ---------------------------------------------------------------------------
// ILUSTRACOES: source, figure, table, frame, algorithm
// ---------------------------------------------------------------------------

// Replica p{Xin}+\tabcolsep do LaTeX: largura dada = texto; soma 12pt (6pt/lado).
#let _addsep(columns) = if type(columns) == array {
  columns.map(c => if type(c) == length { c + 12pt } else { c })
} else { columns }

// Linha "Fonte – ..." abaixo da ilustracao (tam. 10, centralizada, simples).
#let _src(body) = {
  set text(size: 10pt)
  set par(leading: 0.6em, first-line-indent: 0pt, justify: false)
  v(3pt, weak: true)
  align(center, [Fonte#cm-dash#body])
}
#let source = _src

// Fonte "elaborado pelo autor": reaproveita author/date definidos em thesis().
//   source: auto       -> "Fonte – <author>, <date>"
//   source: none       -> sem linha de fonte
//   source: <conteúdo> -> "Fonte – <conteúdo>" (ex.: citação a outro trabalho)
#let _self-source = state("ppgsi-self-source", none)
#let _render-source(src) = if src == none {
} else if src == auto {
  context { let s = _self-source.get(); if s != none { _src(s) } }
} else {
  _src(src)
}

// "Nome do Autor, ano" — a mesma fonte que `source: auto` usa, exposta para uso
// inline (ex.: #ppgsi.myself, ou source: ppgsi.myself).
#let myself = context _self-source.get()

#let figure(body, caption: none, source: auto, placement: none) = std.figure(
  {
    body
    _render-source(source)
  },
  caption: caption,
  kind: image,
  supplement: [Figura],
  placement: placement,
)

#let table(
  caption: none,
  source: auto,
  columns: auto,
  align: auto,
  header: none,
  ..rows,
) = std.figure(
  {
    std.table(
      columns: _addsep(columns),
      align: align,
      stroke: none,
      inset: (x: 6pt, y: 3pt),
      std.table.hline(stroke: 0.6pt),
      ..if header != none {
        (std.table.header(..header), std.table.hline(stroke: 0.6pt))
      } else { () },
      ..rows.pos().flatten(),
      std.table.hline(stroke: 0.6pt),
    )
    _render-source(source)
  },
  caption: caption,
  kind: std.table,
  supplement: [Tabela],
  placement: none,
)

#let frame(
  caption: none,
  source: auto,
  columns: auto,
  align: auto,
  header: none,
  ..rows,
) = std.figure(
  {
    std.table(
      columns: _addsep(columns),
      align: align,
      stroke: 0.5pt,
      inset: (x: 6pt, y: 3pt),
      ..if header != none { (std.table.header(..header),) } else { () },
      ..rows.pos().flatten(),
    )
    _render-source(source)
  },
  caption: caption,
  kind: "frame",
  supplement: [Quadro],
  placement: none,
)

// Algorithm: caixa com regua acima/abaixo e linhas numeradas.
// (a norma permite leve diferenca para ilustracoes do tipo algoritmo/codigo)
#let algorithm(caption: none, source: auto, ..lines) = std.figure(
  block(width: 100%, breakable: false, {
    set text(size: 12pt)
    set par(leading: 0.7em, first-line-indent: 0pt, justify: false)
    line(length: 100%, stroke: 0.8pt)
    v(3pt)
    let ls = lines.pos()
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.8em,
      row-gutter: 0.35em,
      align: (right, left),
      ..ls.enumerate().map(((i, l)) => (text(size: 10pt)[#(i + 1):], l)).flatten(),
    )
    v(3pt)
    line(length: 100%, stroke: 0.8pt)
    _render-source(source)
  }),
  caption: caption,
  kind: "algorithm",
  supplement: [Algoritmo],
  placement: none,
)

// Código-fonte: listagem com legenda "Código N –"; o codly estiliza o raw block
// (números de linha etc.) — ver codly-init em thesis().
#let code(body, caption: none, source: auto) = std.figure(
  {
    body
    _render-source(source)
  },
  caption: caption,
  kind: "code",
  supplement: [Código],
  placement: none,
)

// Citação direta longa (>3 linhas): recuo de 4cm, fonte 10, espaçamento simples,
// sem aspas, justificada; `citation` opcional ao final (ex.: prose/cite ou (AUTOR, ano, p. X)).
#let quote(body, citation: none) = block(width: 100%, inset: (left: 4cm), {
  set text(size: 10pt)
  set par(leading: 0.65em, spacing: 0.65em, first-line-indent: 0pt, justify: true)
  body
  if citation != none { [ #citation] }
})

// Theme do glossy que reproduz o grid 2-col da "Lista de abreviaturas e siglas".
// (entry.label precisa ser emitido para os @sigla do texto linkarem na lista)
#let _sigla-theme = (
  section: (title, body) => body,
  group: (name, index, total, body) => body,
  entry: (entry, index, total) => block(below: 1em, grid(
    columns: (3.5em, 1fr),
    column-gutter: 1cm,
    [#entry.short#entry.label], entry.long,
  )),
)

// ---------------------------------------------------------------------------
// APENDICES E ANEXOS (letras A, B, C independentes; capitulo centralizado)
// ---------------------------------------------------------------------------

#let _apx = counter("ppgsi-apendice")
#let _anx = counter("ppgsi-anexo")
#let _apx-sec = counter("ppgsi-apx-section")
#let _apx-subsec = counter("ppgsi-apx-subsection")

// Congela a letra no local do heading (evita vazar valor final no sumario);
// zera a numeração interna de seções a cada novo apêndice/anexo.
#let _back-chapter(contador, rotulo, titulo) = {
  contador.step()
  _apx-sec.update(0)
  _apx-subsec.update(0)
  context {
    let letra = numbering("A", ..contador.get())
    heading(level: 1, numbering: none, [#rotulo #letra#cm-dash#titulo])
  }
}

#let appendix(title) = _back-chapter(_apx, [Apêndice], title)
#let annex(title) = _back-chapter(_anx, [Anexo], title)

// cite / prose / references: ver biblio.typ (motor próprio ABNT).

// Seções internas de apêndice/anexo: numeradas automaticamente (1, 1.1), fora do sumário.
#let section(body) = {
  _apx-sec.step()
  _apx-subsec.update(0)
  context heading(level: 2, numbering: none, outlined: false,
    [#numbering("1", _apx-sec.get().first()) #body])
}
#let subsection(body) = {
  _apx-subsec.step()
  context heading(level: 3, numbering: none, outlined: false,
    [#numbering("1.1", _apx-sec.get().first(), _apx-subsec.get().first()) #body])
}

// ---------------------------------------------------------------------------
// PRE-TEXTUAIS
// ---------------------------------------------------------------------------

#let _capa(logo, instituicao, autor, titulo, local, data) = {
  set align(center)
  set par(leading: 1.1em, first-line-indent: 0pt, justify: false)
  set text(size: 12pt)
  if logo != none { image(logo, width: 2.7cm) }
  v(0.3cm)
  instituicao
  v(4cm)
  autor
  v(5cm)
  text(weight: "bold", titulo)
  v(1fr)
  local
  parbreak()
  data
  v(1cm)
}

#let _folha-de-rosto(autor, titulo, preambulo, orientador, coorientador, local, data) = {
  set align(center)
  set par(leading: 1.1em, first-line-indent: 0pt, justify: false)
  set text(size: 12pt)
  autor
  v(1fr)
  v(1fr)
  text(weight: "bold", titulo)
  v(1fr)
  // preambulo: bloco de meia largura, alinhado a direita, justificado, simples
  align(left, pad(left: 50%, _single({
    set par(justify: true, leading: 0.65em, spacing: 1.3em)
    preambulo
    v(2em)
    [#orientador]
    if coorientador != none {
      v(0.5em)
      [#coorientador]
    }
  })))
  v(1fr)
  local
  parbreak()
  data
  v(1cm)
}

#let _ficha(ficha) = {
  if ficha == none { return }
  page(margin: 0cm, header: none, footer: none, {
    if type(ficha) == str {
      image(ficha, width: 100%, height: 100%, fit: "contain")
    } else { ficha }
  })
}

// ---------------------------------------------------------------------------
// TEMPLATE PRINCIPAL
// ---------------------------------------------------------------------------

// Normaliza uma entrada de `abstract`: conteúdo -> (body: <conteúdo>); dicionário -> ele mesmo.
#let _abstract-part(v) = if v == none { none } else if type(v) == dictionary { v } else { (body: v) }

// Divide "Título: subtítulo" em (título, subtítulo); sem ":", subtítulo é none.
#let _split-title(t) = if type(t) == str and ":" in t {
  let i = t.position(":")
  (t.slice(0, i).trim(), t.slice(i + 1).trim())
} else { (t, none) }

// Referência ABNT da própria obra (gerada para o resumo/abstract quando citation: auto).
#let _work-reference(name, title, year, unit, degree, institution, location, defense) = context {
  let folhas = counter(page).final().first()
  let (main, sub) = _split-title(title)
  let titulo = if sub != none { [*#main*: #sub] } else { [*#main*] }
  [#name. #titulo. #year. #folhas #unit #degree -- #institution, #location, #defense.]
}

#let thesis(
  title: "Título do trabalho: subtítulo do trabalho",
  title-en: none,
  author: (given: "Fulano de", surname: "Tal"),
  institution: [
    UNIVERSIDADE DE SÃO PAULO

    ESCOLA DE ARTES, CIÊNCIAS E HUMANIDADES

    PROGRAMA DE PÓS-GRADUAÇÃO EM SISTEMAS DE INFORMAÇÃO
  ],
  location: "São Paulo",
  date: "2015",
  defense-year: none,
  degree: [Dissertação (Mestrado em Ciências)],
  degree-en: [Dissertation (Master of Science)],
  institution-ref: [Escola de Artes, Ciências e Humanidades, Universidade de São Paulo],
  institution-ref-en: [School of Arts, Sciences and Humanities, University of São Paulo],
  self-source: auto,
  logo: "assets/usp_logo.jpg",
  preamble: none,
  advisor: [Orientador: Prof. Dr. Fulano de Tal],
  co-advisor: [Coorientador: Prof. Dr. Fulano de Tal],
  catalog-card: none,
  errata: none,
  approval-text: none,
  committee: (),
  dedication: none,
  acknowledgments: none,
  epigraph: none,
  abstract: none,
  acronyms: none,
  symbols: none,
  list-figures: true,
  list-algorithms: true,
  list-code: true,
  list-frames: true,
  list-tables: true,
  bibliography: none,
  validate: true,
  body,
) = {
  // ---- Resumo/abstract: normaliza entradas por idioma ---------------------
  let _abs-pt = _abstract-part(if abstract != none { abstract.at("pt-br", default: none) } else { none })
  let _abs-en = _abstract-part(if abstract != none { abstract.at("en-us", default: none) } else { none })

  // ---- Autor: nome para exibição e forma invertida da referência ----------
  let _author-str = if type(author) == dictionary { author.given + " " + author.surname } else { author }
  let _author-cite = if type(author) == dictionary { [#upper(author.surname), #author.given] } else { [#author] }
  let _defense = if defense-year != none { defense-year } else { date }

  // ---- Referência da própria obra (citation: auto por padrão) -------------
  let _resolve-cit(part, lang) = {
    if part == none { return none }
    let c = part.at("citation", default: auto)
    if c == none { return none }
    if c != auto { return c }
    if lang == "en" {
      if title-en == none { return none }
      _work-reference(_author-cite, title-en, date, "p.", degree-en, institution-ref-en, location, _defense)
    } else {
      _work-reference(_author-cite, title, date, "f.", degree, institution-ref, location, _defense)
    }
  }
  let _cit-pt = _resolve-cit(_abs-pt, "pt")
  let _cit-en = _resolve-cit(_abs-en, "en")

  // ---- Validação dos elementos obrigatórios (ABNT) ------------------------
  if validate {
    let req(cond, nome) = assert(cond, message: "Elemento obrigatório ausente: " + nome + " (use validate: false para desativar).")
    req(title not in (none, ""), "título")
    req(_author-str not in (none, ""), "autor")
    req(advisor != none, "orientador (advisor)")
    req(_abs-pt != none and _abs-pt.at("body", default: none) != none, "resumo (abstract.ptBR)")
    req(_abs-en != none and _abs-en.at("body", default: none) != none, "abstract (abstract.enUS)")
    req(bibliography != none, "referências (bibliography)")
  }

  // ---- Metadados do PDF: palavras-chave (arrays) e data (ano) -------------
  let _doc-keywords = ()
  for p in (_abs-pt, _abs-en) {
    let kw = if p != none { p.at("keywords", default: none) } else { none }
    if type(kw) == array { _doc-keywords += kw }
  }
  let _doc-date = if type(date) == str and date.match(regex("^\\d{4}$")) != none {
    datetime(year: int(date), month: 1, day: 1)
  } else { auto }

  // ---- Estilos globais ----------------------------------------------------
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm, top: 3cm, bottom: 2cm),
    header-ascent: 1cm,
    header: context {
      let loc = here()
      let pg = loc.page()
      let mark = _chapter-mark(loc)
      if mark == none { return } // pre-textual: sem cabecalho
      set text(size: 10pt)
      let chap-here = query(heading.where(level: 1)).filter(h => h.location().page() == pg)
      if chap-here.len() > 0 {
        align(right, counter(page).display())
        return
      }
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        mark, counter(page).display(),
      )
      v(-0.4em)
      line(length: 100%, stroke: 0.4pt)
    },
  )
  set text(font: "New Computer Modern", size: 12pt, lang: "pt", region: "br", hyphenate: true)
  set document(title: title, author: _author-str, keywords: _doc-keywords, date: _doc-date)
  set math.equation(numbering: "(1)")
  set par(
    leading: 1.1em,
    spacing: 1.1em,
    first-line-indent: (amount: 1.25cm, all: true),
    justify: true,
  )
  set heading(numbering: _heading-numbering)

  // ---- Ilustracoes: legenda acima, separador travessao --------------------
  set std.figure(gap: 0.6em)
  set std.figure.caption(separator: cm-dash, position: top)
  show std.figure.caption: it => {
    set text(size: 12pt)
    set par(leading: 0.6em, first-line-indent: 0pt, spacing: 0.6em)
    layout(size => context {
      let number = it.counter.display(it.numbering)
      let is-alg = it.kind == "algorithm"
      let label = if is-alg { strong[#it.supplement #number] } else { [#it.supplement #number#cm-dash] }
      let gap = if is-alg { [ ] } else { [] }
      let full = label + gap + it.body
      if measure(full).width <= size.width {
        align(center, full)
      } else {
        set par(hanging-indent: measure(label + gap).width, justify: true)
        full
      }
    })
  }

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(size: 12pt, weight: "bold")
    set par(first-line-indent: 0pt, justify: false, leading: 0.93em)
    block(above: 0pt, below: 22pt, width: 100%, {
      if it.numbering == none { align(center, it.body) } else { it }
    })
  }
  show heading.where(level: 2): it => {
    set text(size: 12pt, weight: "regular", style: "italic")
    set par(first-line-indent: 0pt, justify: false, leading: 0.93em)
    block(above: 32pt, below: 22pt, it)
  }
  show heading.where(level: 3): it => {
    set text(size: 12pt, weight: "regular", style: "normal")
    set par(first-line-indent: 0pt, justify: false, leading: 0.93em)
    block(above: 32pt, below: 22pt, it)
  }

  // ---- Pacotes integrados (show-rules de documento) -----------------------
  // glossy: habilita @sigla (expande na 1ª menção); codly: estiliza raw blocks;
  // cheq: listas "- [ ]"/"- [x]" viram caixas. glossy só se houver siglas.
  let _glossy-init = if acronyms != none { glossy.init-glossary.with(acronyms) } else { it => it }
  show: _glossy-init
  show: codly.codly-init.with()
  show: checklist

  // título de elemento pré-textual (centralizado, negrito, sem numeração)
  let pre-titulo(nome) = heading(level: 1, numbering: none, outlined: false, bookmarked: true, nome)

  // ---- Registra a fonte .bib para o motor de citações/referências ---------
  if bibliography != none { register-bib(bibliography) }

  // Fonte padrão das ilustrações: "<author>, <date>" (ou self-source explícito).
  _self-source.update(if self-source == auto { [#_author-str, #date] } else { self-source })

  // ---- CAPA (nao contada) -------------------------------------------------
  // Nome do autor em caixa alta na capa e na folha de rosto (convenção ABNT).
  _capa(logo, institution, upper(_author-str), title, location, date)
  counter(page).update(0)
  pagebreak()

  // ---- FOLHA DE ROSTO (= pagina 1) ----------------------------------------
  _folha-de-rosto(upper(_author-str), title, preamble, advisor, co-advisor, location, date)
  pagebreak()

  // ---- FICHA CATALOGRAFICA (verso) ----------------------------------------
  _ficha(catalog-card)

  // ---- ERRATA -------------------------------------------------------------
  if errata != none {
    pre-titulo[Errata]
    errata
  }

  // ---- FOLHA DE APROVACAO -------------------------------------------------
  if approval-text != none {
    pre-titulo(hide[Folha de aprovação]) // marcador/bookmark sem titulo visivel
    // (o conteudo da aprovacao nao tem titulo impresso)
  }
  if approval-text != none {
    _single({
      set par(justify: true)
      approval-text
      v(3cm)
      set align(center)
      for member in committee {
        v(1.2cm)
        line(length: 10cm, stroke: 0.5pt)
        member
        parbreak()
      }
    })
    pagebreak()
  }

  // ---- DEDICATORIA --------------------------------------------------------
  if dedication != none {
    v(1fr)
    align(center, emph(dedication))
    v(1fr)
    pagebreak()
  }

  // ---- AGRADECIMENTOS -----------------------------------------------------
  if acknowledgments != none {
    pre-titulo[Agradecimentos]
    acknowledgments
  }

  // ---- EPIGRAFE -----------------------------------------------------------
  if epigraph != none {
    v(1fr)
    align(right, emph(epigraph))
    pagebreak()
  }

  // ---- RESUMO -------------------------------------------------------------
  if _abs-pt != none {
    pre-titulo[Resumo]
    _single({
      set par(first-line-indent: 0pt, spacing: 18pt)
      if _cit-pt != none { align(left, _cit-pt); parbreak() }
      _abs-pt.at("body", default: none)
      let kw = _abs-pt.at("keywords", default: none)
      if kw != none {
        parbreak()
        if type(kw) == array { [Palavras-chave: #(kw.join(". ")).] } else { [Palavras-chave: #kw] }
      }
    })
  }

  // ---- ABSTRACT -----------------------------------------------------------
  if _abs-en != none {
    pre-titulo[Abstract]
    _single({
      set par(first-line-indent: 0pt, spacing: 18pt)
      set text(lang: "en")
      if _cit-en != none { align(left, _cit-en); parbreak() }
      _abs-en.at("body", default: none)
      let kw = _abs-en.at("keywords", default: none)
      if kw != none {
        parbreak()
        if type(kw) == array { [Keywords: #(kw.join(". ")).] } else { [Keywords: #kw] }
      }
    })
  }

  // ---- LISTAS DE ILUSTRACOES ----------------------------------------------
  let lista(nome, target) = {
    pre-titulo(nome)
    // entrada inteira azul (prefixo + dash + título); pontilhado e página pretos
    show outline.entry: it => {
      let tail = if it.fill != none { box(width: 1fr, it.fill) } else { h(1fr) }
      it.indented(
        text(fill: _blue, { it.prefix(); cm-dash }),
        text(fill: _blue, it.body()) + [ ] + tail + [ ] + it.page(),
      )
    }
    outline(title: none, target: target)
  }
  if list-figures { lista([Lista de figuras], std.figure.where(kind: image)) }
  if list-algorithms { lista([Lista de algoritmos], std.figure.where(kind: "algorithm")) }
  if list-code { lista([Lista de códigos], std.figure.where(kind: "code")) }
  if list-frames { lista([Lista de quadros], std.figure.where(kind: "frame")) }
  if list-tables { lista([Lista de tabelas], std.figure.where(kind: std.table)) }

  // ---- LISTA DE SIGLAS (renderizada pelo glossy) --------------------------
  if acronyms != none {
    pre-titulo[Lista de abreviaturas e siglas]
    set par(first-line-indent: 0pt)
    glossy.glossary(title: "", theme: _sigla-theme, sort: false, show-all: true)
  }

  // ---- LISTA DE SIMBOLOS --------------------------------------------------
  if symbols != none {
    pre-titulo[Lista de símbolos]
    set par(first-line-indent: 0pt)
    grid(
      columns: (auto, 1fr),
      column-gutter: 1cm,
      row-gutter: 1.2em,
      ..symbols.map(((s, d)) => (s, d)).flatten(),
    )
  }

  // ---- SUMARIO ------------------------------------------------------------
  pre-titulo[Sumário]
  {
    // sumário: linha inteira em azul (prefixo + título + pontilhado + página)
    show outline.entry.where(level: 1): it => block(above: 1em, below: 0pt, text(fill: _blue, weight: "bold", {
      let e = it.indented(it.prefix(), it.inner())
      // "REFERÊNCIAS" em maiusculas no sumario (quirk do abntex bibsection)
      if it.element.body == [Referências] { upper(e) } else { e }
    }))
    show outline.entry.where(level: 2): it => text(fill: _blue, style: "italic", it.indented(it.prefix(), it.inner()))
    show outline.entry.where(level: 3): it => text(fill: _blue, it.indented(it.prefix(), it.inner()))
    outline(title: none, depth: 3, indent: 1.2em)
  }

  // ---- ELEMENTOS TEXTUAIS -------------------------------------------------
  body
}
