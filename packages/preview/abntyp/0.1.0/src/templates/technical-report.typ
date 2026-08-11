// Template para Relatorio Tecnico e/ou Cientifico conforme NBR 10719:2015
//
// Estrutura:
// Parte Externa:
// - Capa (opcional)
// - Lombada (opcional)
//
// Parte Interna - Pre-textuais:
// - Folha de rosto (obrigatorio)
// - Errata (opcional)
// - Agradecimentos (opcional)
// - Resumo na lingua vernacula (obrigatorio)
// - Lista de ilustracoes (opcional)
// - Lista de tabelas (opcional)
// - Lista de abreviaturas e siglas (opcional)
// - Lista de simbolos (opcional)
// - Sumario (obrigatorio)
//
// Parte Interna - Textuais:
// - Introducao (obrigatorio)
// - Desenvolvimento (obrigatorio)
// - Consideracoes finais (obrigatorio)
//
// Parte Interna - Pos-textuais:
// - Referencias (obrigatorio)
// - Glossario (opcional)
// - Apendice (opcional)
// - Anexo (opcional)
// - Indice (opcional)
// - Formulario de identificacao (opcional)

#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../text/headings.typ": *
#import "../elements/toc.typ": *
#import "../elements/abstract.typ": *
#import "../references/bibliography.typ": *

/// Template principal para Relatorio Tecnico conforme NBR 10719:2015
///
/// Parametros:
/// - titulo: titulo do relatorio
/// - subtitulo: subtitulo (opcional)
/// - numero-relatorio: numero do relatorio
/// - codigo-relatorio: codigo de identificacao (sigla+categoria+data+assunto+sequencial)
/// - instituicao: nome do orgao ou entidade responsavel
/// - endereco-instituicao: endereco da instituicao
/// - titulo-projeto: titulo do projeto/programa/plano relacionado
/// - autores: lista de autores (nome e qualificacao)
/// - classificacao: classificacao de seguranca (opcional)
/// - issn: ISSN se houver
/// - local: cidade da instituicao
/// - ano: ano de publicacao
/// - volume: numero do volume (se mais de um)
/// - fonte: fonte a usar
/// - arquivo-bibliografia: arquivo .bib (opcional)
/// - titulo-bibliografia: titulo da secao de referencias
#let relatorio(
  titulo: "",
  subtitulo: none,
  numero-relatorio: none,
  codigo-relatorio: none,
  instituicao: "",
  endereco-instituicao: none,
  titulo-projeto: none,
  autores: (),
  classificacao: none,
  issn: none,
  local: "",
  ano: datetime.today().year(),
  volume: none,
  fonte: "Times New Roman",
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERENCIAS",
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: autores.map(a => if type(a) == dictionary { a.name } else { a }).join(", "),
  )

  // Configuracao de pagina conforme NBR 10719
  // Anverso: esquerda/superior 3cm, direita/inferior 2cm
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 2cm,
    ),
  )

  // Configuracao de fonte
  set text(
    font: fonte,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )

  // Configuracao de paragrafo
  set par(
    leading: 1.5em * 0.65,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )

  set list(indent: 2em, body-indent: 0.5em)
  set enum(indent: 2em, body-indent: 0.5em)
  set terms(indent: 0em, hanging-indent: 2em, separator: [: ])

  // Configuracao de headings
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 2): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 3): it => {
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 4): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 5): it => {
    v(1.5em)
    text(weight: "regular", style: "italic", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  // Excluir indentacao de containers que nao devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Configuracao de notas de rodape
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
  )

  // Conteudo
  body

  // Bibliografia automatica
  if arquivo-bibliografia != none {
    abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
  }
}

/// Capa para Relatorio Tecnico conforme NBR 10719:2015
/// Primeira capa - recomenda-se incluir:
/// - Nome e endereco da instituicao responsavel
/// - Numero do relatorio
/// - ISSN (se houver)
/// - Titulo e subtitulo (se houver)
/// - Classificacao de seguranca (se houver)
#let report-cover(
  instituicao: none,
  endereco-instituicao: none,
  numero-relatorio: none,
  issn: none,
  titulo: none,
  subtitulo: none,
  classificacao: none,
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  // Instituicao e endereco
  if instituicao != none {
    text(weight: "bold", size: 12pt, upper(instituicao))
    linebreak()
  }

  if endereco-instituicao != none {
    text(size: 10pt, endereco-instituicao)
  }

  v(1cm)

  // Numero do relatorio e ISSN
  if numero-relatorio != none {
    text(size: 11pt, "Relatorio n. " + str(numero-relatorio))
    linebreak()
  }

  if issn != none {
    text(size: 10pt, "ISSN " + issn)
  }

  v(1fr)

  // Titulo e subtitulo
  if titulo != none {
    text(weight: "bold", size: 14pt, upper(titulo))
  }

  if subtitulo != none {
    linebreak()
    text(size: 14pt, ": " + subtitulo)
  }

  v(1fr)

  // Classificacao de seguranca
  if classificacao != none {
    box(
      stroke: 1pt,
      inset: 0.5em,
    )[
      #text(weight: "bold", classificacao)
    ]
    v(1cm)
  }

  // Ano
  if ano != none {
    text(size: 12pt, str(ano))
  }

  pagebreak()
}

/// Folha de rosto para Relatorio Tecnico conforme NBR 10719:2015
///
/// Anverso:
/// a) Nome do orgao ou entidade responsavel
/// b) Titulo do projeto/programa/plano relacionado
/// c) Titulo do relatorio
/// d) Subtitulo (precedido de dois pontos)
/// e) Numero do volume (se mais de um)
/// f) Codigo de identificacao
/// g) Classificacao de seguranca
/// h) Nome do autor ou autor-entidade
/// i) Local (cidade) da instituicao
/// j) Ano de publicacao
#let report-title-page(
  instituicao: none,
  titulo-projeto: none,
  titulo: none,
  subtitulo: none,
  volume: none,
  codigo-relatorio: none,
  classificacao: none,
  autores: (),
  local: none,
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  // Instituicao
  if instituicao != none {
    text(weight: "bold", size: 12pt, upper(instituicao))
    v(0.5cm)
  }

  // Titulo do projeto relacionado
  if titulo-projeto != none {
    text(size: 11pt, titulo-projeto)
    v(1cm)
  }

  v(1fr)

  // Titulo e subtitulo
  if titulo != none {
    text(weight: "bold", size: 14pt, upper(titulo))
  }

  if subtitulo != none {
    text(size: 14pt, ": " + subtitulo)
  }

  // Volume
  if volume != none {
    v(0.5em)
    text(size: 12pt, "Volume " + str(volume))
  }

  v(1cm)

  // Codigo de identificacao
  if codigo-relatorio != none {
    text(size: 10pt, codigo-relatorio)
    v(0.5cm)
  }

  // Classificacao de seguranca
  if classificacao != none {
    box(
      stroke: 1pt,
      inset: 0.5em,
    )[
      #text(weight: "bold", size: 10pt, classificacao)
    ]
  }

  v(1fr)

  // Autores
  if autores.len() > 0 {
    for autor in autores {
      if type(autor) == dictionary {
        text(size: 12pt, autor.name)
        if "qualification" in autor {
          linebreak()
          text(size: 10pt, autor.qualification)
        }
      } else {
        text(size: 12pt, autor)
      }
      v(0.5em)
    }
  }

  v(1fr)

  // Local e ano
  if local != none {
    text(size: 12pt, local)
    linebreak()
  }

  if ano != none {
    text(size: 12pt, str(ano))
  }

  pagebreak()
}

/// Verso da folha de rosto
/// Contem equipe tecnica e/ou dados de catalogacao
#let report-title-page-verso(
  equipe-tecnica: none,
  dados-catalogacao: none,
) = {
  set page(numbering: none)

  // Equipe tecnica (opcional)
  if equipe-tecnica != none {
    align(center)[
      #text(weight: "bold", size: 11pt, "EQUIPE TECNICA")
    ]
    v(1em)

    for member in equipe-tecnica {
      if type(member) == dictionary {
        [*#member.funcao:* #member.nome]
      } else {
        member
      }
      linebreak()
    }

    v(2cm)
  }

  // Dados de catalogacao (parte inferior)
  v(1fr)

  if dados-catalogacao != none {
    align(center)[
      #box(
        width: 12.5cm,
        stroke: 0.5pt,
        inset: 0.5cm,
      )[
        #set text(size: 10pt)
        #set par(leading: 1em * 0.65)
        #dados-catalogacao
      ]
    ]
  }

  pagebreak()
}

/// Errata para Relatorio Tecnico
/// Formato de tabela: Folha, Linha, Onde se le, Leia-se
#let errata(
  referencia: none,
  itens: (),
) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "ERRATA")
  ]

  v(1.5em)

  // Referencia da publicacao
  if referencia != none {
    set par(first-line-indent: 0pt)
    referencia
    v(1em)
  }

  // Tabela de erros
  if itens.len() > 0 {
    table(
      columns: (auto, auto, 1fr, 1fr),
      stroke: 0.5pt,
      inset: 6pt,
      align: left,

      [*Folha*], [*Linha*], [*Onde se le*], [*Leia-se*],

      ..{
        let cells = ()
        for item in itens {
          cells.push(str(item.pagina))
          cells.push(str(item.linha))
          cells.push(item.errado)
          cells.push(item.correto)
        }
        cells
      }
    )
  }

  pagebreak()
}

/// Agradecimentos para Relatorio Tecnico
#let agradecimentos-relatorio(conteudo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "AGRADECIMENTOS")
  ]
  v(1.5em)
  conteudo
  pagebreak()
}

/// Resumo para Relatorio Tecnico conforme NBR 6028
#let resumo-relatorio(conteudo, palavras-chave: ()) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "RESUMO")
  ]

  v(1.5em)

  set par(
    leading: 1.5em * 0.65,
    first-line-indent: 0pt,
    justify: true,
  )

  conteudo

  v(1.5em)

  if palavras-chave.len() > 0 {
    [*Palavras-chave:* #palavras-chave.join(". ").]
  }

  pagebreak()
}

/// Formulario de identificacao para Relatorio Tecnico
/// Obrigatorio quando nao utilizados dados de catalogacao-na-publicacao
#let formulario-identificacao(
  titulo: none,
  classificacao: none,
  numero-relatorio: none,
  tipo-relatorio: none,
  data: none,
  autores: (),
  instituicoes: (),
  texto-resumo: none,
  palavras-chave: (),
  edicao: none,
  paginas: none,
  volume: none,
  issn: none,
  distribuicao: none,
  distribuidor: none,
  preco: none,
  observacoes: none,
) = {
  heading(level: 1, numbering: none, "FORMULARIO DE IDENTIFICACAO")

  let field(label, value) = {
    if value != none {
      [*#label:* #value]
      linebreak()
    }
  }

  set par(first-line-indent: 0pt)

  field("Titulo", titulo)
  field("Classificacao de seguranca", classificacao)
  field("Numero", numero-relatorio)
  field("Tipo de relatorio", tipo-relatorio)
  field("Data", data)

  if autores.len() > 0 {
    [*Autores:*]
    linebreak()
    for autor in autores {
      [- #if type(autor) == dictionary { autor.name } else { autor }]
      linebreak()
    }
  }

  if instituicoes.len() > 0 {
    [*Instituicoes:*]
    linebreak()
    for inst in instituicoes {
      [- #inst]
      linebreak()
    }
  }

  v(0.5em)

  if texto-resumo != none {
    [*Resumo:*]
    linebreak()
    texto-resumo
    linebreak()
  }

  if palavras-chave.len() > 0 {
    [*Palavras-chave:* #palavras-chave.join("; ")]
    linebreak()
  }

  v(0.5em)

  field("Edicao", edicao)
  field("Numero de paginas", paginas)
  field("Volume", volume)
  field("ISSN", issn)
  field("Distribuicao", distribuicao)
  field("Distribuidor", distribuidor)
  field("Preco", preco)
  field("Observacoes", observacoes)

  pagebreak()
}

/// Codigo de identificacao do relatorio
/// Formato: sigla da instituicao + categoria + data + assunto + numero sequencial
///
/// Exemplo: INPE-RPE-2024-EST-001
#let report-code(
  codigo-instituicao: "",
  categoria: "",
  ano: none,
  assunto: "",
  sequencia: 1,
  separador: "-",
) = {
  // Formatar numero com zeros a esquerda
  let seq-str = if sequencia < 10 { "00" + str(sequencia) }
                else if sequencia < 100 { "0" + str(sequencia) }
                else { str(sequencia) }

  [#codigo-instituicao#separador#categoria#separador#if ano != none {str(ano) + separador}#assunto#separador#seq-str]
}
