// Template para artigo científico conforme NBR 6022:2018

#import "../core/setup.typ": with-abnt-setup
#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/dates.typ": format-date
#import "../references/bibliography.typ": *

// Data como o autor der: texto/conteúdo, ou datetime (vira "4 de abril de 2018")
#let _data-artigo(d) = if type(d) == datetime { format-date(d) } else { d }

// Bloco de resumo (NBR 6022 6.2; NBR 6028): título centralizado em negrito, texto sem
// recuo, palavras-chave separadas por "; " e finalizadas por ponto (como no TCC)
#let _bloco-resumo(rotulo, texto, rotulo-palavras, palavras) = {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", rotulo))
  texto
  if palavras.len() > 0 {
    parbreak()
    [*#rotulo-palavras:* #(palavras,).flatten().join("; ").]
  }
  v(2em)
}

// Elementos pré-textuais do artigo (NBR 6022 5.1), na ordem do esquema 1: título,
// título em outro idioma, autores, resumo, abstract, datas, identificação (DOI).
// Usado por `artigo()` e por `periodical-article()`.
#let _cabecalho-artigo(
  titulo: "",
  subtitulo: none,
  titulo-en: none,
  autores: (),
  resumo: none,
  palavras-chave: (),
  resumo-en: none,
  palavras-chave-en: (),
  submissao: none,
  aprovacao: none,
  doi: none,
) = {
  // Título em maiúsculas e negrito; subtítulo separado por dois-pontos colado ao
  // título (5.1.1), sem hifenização
  align(center)[
    #set par(justify: false)
    #set text(hyphenate: false)
    #text(weight: "bold", upper(titulo) + if subtitulo != none { ":" } else { "" })
    #if subtitulo != none {
      linebreak()
      subtitulo
    }
    #if titulo-en != none {
      linebreak()
      text(style: "italic", titulo-en)
    }
  ]

  v(1em)

  // Autores
  for autor in autores {
    align(center)[
      #text(size: 12pt, autor.name)
      #if "affiliation" in autor {
        footnote(autor.affiliation)
      }
    ]
  }

  v(2em)

  if resumo != none {
    _bloco-resumo("RESUMO", resumo, "Palavras-chave", palavras-chave)
  }

  if resumo-en != none {
    _bloco-resumo("ABSTRACT", resumo-en, "Keywords", palavras-chave-en)
  }

  // Datas de submissão e aprovação (obrigatórias, 5.1.4) e identificação (5.1.5)
  if submissao != none or aprovacao != none or doi != none {
    set par(first-line-indent: 0pt)
    let linhas = ()
    if submissao != none { linhas.push([*Data de submissão:* #_data-artigo(submissao).]) }
    if aprovacao != none { linhas.push([*Data de aprovação:* #_data-artigo(aprovacao).]) }
    if doi != none { linhas.push([*DOI:* #doi]) }
    linhas.join(linebreak())
    v(2em)
  }
}

/// Agradecimentos do artigo (NBR 6022 5.3.5): título centralizado, sem quebra de
/// página; é o último elemento pós-textual (depois das referências, apêndices e
/// anexos). Com `arquivo-bibliografia`, passe o texto em `artigo(agradecimentos: …)`,
/// que o coloca depois da lista de referências.
#let agradecimentos-artigo(conteudo) = {
  heading(level: 1, numbering: none, "AGRADECIMENTOS")
  conteudo
}

/// Template para artigo científico
///
/// Parâmetros:
/// - titulo: título do artigo
/// - subtitulo: subtítulo (opcional); sai depois de dois-pontos colados ao título
/// - titulo-en: título em outro idioma (opcional)
/// - autores: lista de autores com afiliação
/// - resumo: resumo em português
/// - resumo-en: abstract em inglês
/// - palavras-chave: palavras-chave
/// - palavras-chave-en: keywords
/// - submissao: data de submissão (obrigatória pela NBR 6022 5.1.4): texto, conteúdo
///   ou `datetime`
/// - aprovacao: data de aprovação (idem)
/// - doi: identificação e disponibilidade (opcional), por exemplo o DOI
/// - agradecimentos: texto de agradecimentos (opcional), impresso depois das referências
///   automáticas; veja `agradecimentos-artigo`
/// - espacamento: "simples" (padrão, NBR 6022 6.1) ou "1,5"
/// - fonte: fonte a usar
/// - colunas: número de colunas (1 ou 2)
/// - arquivo-bibliografia: conteúdo do arquivo .bib, lido com `read("referencias.bib")`
///   (opcional)
/// - titulo-bibliografia: título da seção de referências (padrão: "REFERÊNCIAS")
/// - enumeracao: "abnt" (padrão: alíneas a), b), c); subalíneas com travessão) ou
///   "latex" (1., a), i), A.)
#let artigo(
  titulo: "",
  subtitulo: none,
  titulo-en: none,
  autores: (),
  resumo: none,
  resumo-en: none,
  palavras-chave: (),
  palavras-chave-en: (),
  submissao: none,
  aprovacao: none,
  doi: none,
  agradecimentos: none,
  espacamento: "simples",
  fonte: "Times New Roman",
  colunas: 1,
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERÊNCIAS",
  enumeracao: "abnt",
  body,
) = {
  assert(
    espacamento in ("simples", "1,5"),
    message: "artigo: 'espacamento' deve ser \"simples\" ou \"1,5\"",
  )

  // Configuração do documento
  set document(
    title: titulo,
    author: if autores.len() > 0 { autores.map(a => a.name).join(", ") } else { () },
  )

  show: with-abnt-setup.with(fonte: fonte, level-1-pagebreak: false, enumeracao: enumeracao)

  // Espaçamento simples (padrão) ou 1,5 em todo o artigo
  let k = if espacamento == "simples" { 1 } else { 1.5 }
  set par(leading: abnt-leading(k), spacing: abnt-leading(k))

  // Paginação visível desde o início para artigos
  set page(
    numbering: "1",
    number-align: top + right,
  )

  _cabecalho-artigo(
    titulo: titulo,
    subtitulo: subtitulo,
    titulo-en: titulo-en,
    autores: autores,
    resumo: resumo,
    palavras-chave: palavras-chave,
    resumo-en: resumo-en,
    palavras-chave-en: palavras-chave-en,
    submissao: submissao,
    aprovacao: aprovacao,
    doi: doi,
  )

  // Corpo do artigo
  if colunas == 2 {
    columns(2, body)
  } else {
    body
  }

  // Bibliografia automática (se arquivo .bib fornecido)
  if arquivo-bibliografia != none {
    abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
  }

  // Agradecimentos: último elemento pós-textual
  if agradecimentos != none {
    agradecimentos-artigo(agradecimentos)
  }
}

/// Seção de artigo (sem numeração)
#let article-section(titulo) = {
  heading(level: 1, numbering: none, titulo)
}

/// Subseção de artigo
#let article-subsection(titulo) = {
  heading(level: 2, numbering: none, titulo)
}
