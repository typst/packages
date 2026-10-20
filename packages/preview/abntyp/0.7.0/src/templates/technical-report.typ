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
// Parte Interna - Pos-textuais (ordem da NBR 10719 4.2.3):
// - Referencias (obrigatorio)
// - Glossario (opcional)
// - Apendice (opcional)
// - Anexo (opcional)
// - Indice (opcional)
// - Formulario de identificacao (opcional)

#import "../core/setup.typ": with-abnt-setup
#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/identifiers.typ": format-issn
#import "../text/headings.typ": *
#import "../elements/toc.typ": *
#import "../elements/abstract.typ": *
#import "../references/bibliography.typ": *

// ---------------------------------------------------------------------------
// Apoio interno
// ---------------------------------------------------------------------------

// Dados do relatório: `relatorio()` grava aqui os parâmetros que descrevem o
// documento (instituição, título, autores, ano...) e `report-cover` e
// `report-title-page` os usam como padrão quando o parâmetro não é repetido na
// chamada.
#let _relatorio-dados = state("abnt-relatorio-dados", (:))

// Referências automáticas (`arquivo-bibliografia`): o arquivo e o título ficam
// no estado; `referencias-relatorio()` marca a posição escolhida pelo autor e,
// sem marcador, `relatorio()` as coloca no fim do documento.
#let _relatorio-bib = state("abnt-relatorio-bib", none)
#let _relatorio-bib-marcada = state("abnt-relatorio-bib-marcada", false)

// Valor da chamada ou, se for `none`, o padrão gravado por `relatorio()`
#let _ou(valor, dados, chave) = if valor != none { valor } else { dados.at(chave, default: none) }

// `none` -> (); lista -> ela mesma; valor único (string, dicionário) -> lista de um item
#let _lista(x) = if x == none { () } else if type(x) == array { x } else { (x,) }

// Número, texto ou conteúdo, pronto para imprimir
#let _txt(x) = if type(x) in (int, float) { str(x) } else { x }

// Nome e qualificação de um autor (texto, ou dicionário com name/nome e
// qualification/qualificacao)
#let _autor-nome(a) = if type(a) == dictionary {
  if "name" in a { a.name } else if "nome" in a { a.nome } else {
    panic("autores: falta a chave \"name\" (ou \"nome\") em " + repr(a))
  }
} else { a }
#let _autor-qual(a) = if type(a) == dictionary {
  a.at("qualification", default: a.at("qualificacao", default: none))
} else { none }

// Valor de um item de dicionário que pode ter mais de um nome de chave
#let _campo(item, chaves, onde) = {
  for c in chaves { if c in item { return item.at(c) } }
  panic(onde + ": falta a chave \"" + chaves.first() + "\" em " + repr(item))
}

/// Template principal para Relatório Técnico conforme NBR 10719:2015
///
/// Os parâmetros que descrevem o relatório (`titulo`, `subtitulo`, `autores`,
/// `numero-relatorio`, `codigo-relatorio`, `instituicao`, `endereco-instituicao`,
/// `titulo-projeto`, `classificacao`, `issn`, `local`, `ano`, `volume`,
/// `titulo-volume`, `pagina-inicial`) valem como padrão de `report-cover()` e
/// `report-title-page()`: informados aqui, não precisam ser repetidos nelas
/// (repetir também funciona, e o valor da chamada prevalece). O template NÃO
/// imprime capa nem folha de rosto sozinho: chame `report-cover()` e
/// `report-title-page()` depois do `#show:`.
///
/// Parâmetros:
/// - titulo: título do relatório
/// - subtitulo: subtítulo (opcional)
/// - numero-relatorio: número do relatório (número, texto ou conteúdo)
/// - codigo-relatorio: código de identificação (sigla + categoria + data + assunto
///   + sequencial; ver `report-code()`)
/// - instituicao: nome do órgão ou entidade responsável
/// - endereco-instituicao: endereço da instituição
/// - titulo-projeto: título do projeto/programa/plano relacionado
/// - autores: lista de autores; cada um é um texto ou um dicionário
///   `(name: "...", qualification: "...")` (`nome` e `qualificacao` também valem).
///   Um autor só pode ser passado sem lista: `autores: "Ana"`
/// - classificacao: classificação de segurança (opcional)
/// - issn: ISSN se houver (impresso na capa como `ISSN 1234-5679`)
/// - local: cidade da instituição
/// - ano: ano de publicação
/// - volume: número do volume (se mais de um)
/// - titulo-volume: título específico do volume (opcional; NBR 10719 4.2.1.1.1 d)
/// - pagina-inicial: número da página da folha de rosto, para continuar a
///   numeração do volume anterior (NBR 10719 5.2: sequência única entre volumes).
///   Em branco, a folha de rosto vale 1
/// - fonte: fonte a usar
/// - espacamento: "simples" (padrão; a NBR 10719 5.1 recomenda espaço simples) ou
///   "1,5"
/// - paginacao: "auto" (padrão, NBR 10719: contagem a partir da folha de rosto,
///   número visível a partir da primeira seção primária numerada, canto superior
///   direito), "todas" ou "nenhuma"
/// - frente-verso: impressão frente-verso (margens espelhadas, número alternado,
///   elementos pré-textuais no anverso, seções primárias em página ímpar; o verso
///   da folha de rosto, com a equipe técnica e os dados de catalogação, fica
///   logo depois dela)
/// - arquivo-bibliografia: conteúdo do .bib, lido com `read("referencias.bib")`
///   (opcional). As referências saem no FIM do documento; como a NBR 10719 4.2.3
///   manda a ordem referências, glossário, apêndice, anexo, índice, quem tem
///   algum desses elementos deve chamar `referencias-relatorio()` no ponto certo
///   (antes do glossário/apêndice)
/// - titulo-bibliografia: título da seção de referências
/// - enumeracao: "abnt" (padrão: alíneas a), b), c); subalíneas com travessão) ou
///   "latex" (1., a), i), A.)
///
/// As equações em bloco (`$ x = y $`) saem numeradas `(1)` à direita (NBR 10719 5.7);
/// para desligar, escreva `#set math.equation(numbering: none)` no documento.
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
  titulo-volume: none,
  pagina-inicial: none,
  fonte: "Times New Roman",
  espacamento: "simples",
  paginacao: "auto",
  frente-verso: false,
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERÊNCIAS",
  enumeracao: "abnt",
  body,
) = {
  let autores = _lista(autores)

  // Um caminho em string seria resolvido relativo ao pacote: o .bib vai lido com read()
  assert(
    not (type(arquivo-bibliografia) == str and arquivo-bibliografia.ends-with(".bib")
      and not arquivo-bibliografia.contains("\n")),
    message: "relatorio(): use arquivo-bibliografia: read(\"" + repr(arquivo-bibliografia).trim("\"") + "\") em vez do caminho em string",
  )

  // Configuracao do documento
  set document(
    title: titulo,
    author: if autores.len() > 0 { autores.map(_autor-nome).join(", ") } else { () },
  )

  show: with-abnt-setup.with(
    fonte: fonte,
    suplemento-nivel1: "Capítulo",
    level-1-pagebreak-impar: frente-verso,
    enumeracao: enumeracao,
  )

  // Espaçamento (DECISOES #3): simples por padrão; "1,5" volta ao antigo
  assert(
    espacamento in ("simples", "1,5", "1.5"),
    message: "relatorio(): espacamento deve ser \"simples\" ou \"1,5\"",
  )
  let k = if espacamento == "simples" { 1 } else { 1.5 }
  set par(leading: abnt-leading(k), spacing: abnt-leading(k))

  // Equações em bloco numeradas (NBR 10719 5.7)
  set math.equation(numbering: "(1)")

  set page(margin: abnt-margens(frente-verso))
  set page(header: abnt-numero-pagina(paginacao: paginacao, frente-verso: frente-verso))

  // Frente-verso: os elementos pré-textuais consultam este estado (abre-anverso)
  abnt-frente-verso.update(frente-verso)

  // Dados que report-cover e report-title-page usam como padrão
  _relatorio-dados.update((
    titulo: if titulo == "" { none } else { titulo },
    subtitulo: subtitulo,
    numero-relatorio: numero-relatorio,
    codigo-relatorio: codigo-relatorio,
    instituicao: if instituicao == "" { none } else { instituicao },
    endereco-instituicao: endereco-instituicao,
    titulo-projeto: titulo-projeto,
    autores: autores,
    classificacao: classificacao,
    issn: issn,
    local: if local == "" { none } else { local },
    ano: ano,
    volume: volume,
    titulo-volume: titulo-volume,
    pagina-inicial: pagina-inicial,
  ))
  _relatorio-bib.update(if arquivo-bibliografia != none {
    (arquivo: arquivo-bibliografia, titulo: titulo-bibliografia)
  } else { none })

  // Conteudo
  body

  // Bibliografia automatica: no fim, a menos que `referencias-relatorio()`
  // tenha marcado outra posição
  if arquivo-bibliografia != none {
    context if not _relatorio-bib-marcada.final() {
      abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
    }
  }
}

/// Referências do relatório na posição certa (NBR 10719 4.2.3: referências,
/// glossário, apêndice, anexo, índice). Usa o `arquivo-bibliografia` e o
/// `titulo-bibliografia` dados a `relatorio()`; com esta chamada, a bibliografia
/// automática deixa de sair no fim do documento. Sem `arquivo-bibliografia`, use
/// `referencias(read("referencias.bib"))` direto.
/// ```typst
/// #referencias-relatorio()
/// #glossario(("Termo": "Definição."))
/// #apendice("A", "Roteiro")
/// ```
#let referencias-relatorio() = [
  #_relatorio-bib-marcada.update(true)
  #context {
    let b = _relatorio-bib.get()
    assert(
      b != none,
      message: "referencias-relatorio(): informe arquivo-bibliografia: read(\"referencias.bib\") em relatorio()",
    )
    abnt-bibliography(b.arquivo, titulo: b.titulo)
  }
]

/// Capa para Relatório Técnico conforme NBR 10719:2015
/// Primeira capa - recomenda-se incluir:
/// - Nome e endereço da instituição responsável
/// - Número do relatório
/// - ISSN (se houver; formatado `ISSN 1234-5679`)
/// - Título e subtítulo (se houver; `TÍTULO: subtítulo`)
/// - Classificação de segurança (se houver)
///
/// Os parâmetros não informados valem os de `relatorio()`. A capa não é a folha 1:
/// a contagem de páginas começa na folha de rosto (`report-title-page()`).
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

  context {
    let d = _relatorio-dados.get()
    let instituicao = _ou(instituicao, d, "instituicao")
    let endereco-instituicao = _ou(endereco-instituicao, d, "endereco-instituicao")
    let numero-relatorio = _ou(numero-relatorio, d, "numero-relatorio")
    let issn = _ou(issn, d, "issn")
    let titulo = _ou(titulo, d, "titulo")
    let subtitulo = _ou(subtitulo, d, "subtitulo")
    let classificacao = _ou(classificacao, d, "classificacao")
    let ano = _ou(ano, d, "ano")

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
      text(size: 11pt)[Relatório n. #_txt(numero-relatorio)]
      linebreak()
    }

    if issn != none {
      text(size: 10pt)[ISSN #if type(issn) == str { format-issn(issn) } else { issn }]
    }

    v(1fr)

    // Titulo e subtitulo (na mesma linha, com dois pontos colados ao título)
    if titulo != none {
      text(weight: "bold", size: 14pt, upper(titulo))
      if subtitulo != none {
        text(size: 14pt)[: #subtitulo]
      }
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
      text(size: 12pt, _txt(ano))
    }
  }

  pagebreak(weak: true)
}

/// Folha de rosto para Relatório Técnico conforme NBR 10719:2015
///
/// Anverso:
/// a) Nome do órgão ou entidade responsável
/// b) Título do projeto/programa/plano relacionado
/// c) Título do relatório
/// d) Subtítulo (precedido de dois pontos)
/// e) Número do volume (se mais de um), com o título específico do volume
/// f) Código de identificação
/// g) Classificação de segurança
/// h) Nome do autor ou autor-entidade
/// i) Local (cidade) da instituição
/// j) Ano de publicação
///
/// É aqui que a contagem de páginas começa (NBR 10719 5.2: todas as folhas, a
/// partir da folha de rosto, são contadas), com ou sem capa. Em frente-verso, a
/// folha de rosto abre no anverso. Os parâmetros não informados valem os de
/// `relatorio()`. `pagina-inicial` continua a numeração de um volume anterior.
#let report-title-page(
  instituicao: none,
  titulo-projeto: none,
  titulo: none,
  subtitulo: none,
  volume: none,
  titulo-volume: none,
  codigo-relatorio: none,
  classificacao: none,
  autores: none,
  local: none,
  ano: none,
  pagina-inicial: none,
) = {
  set page(numbering: none)
  abre-anverso()
  marcar-folha-rosto()
  set align(center)

  context {
    let d = _relatorio-dados.get()
    let instituicao = _ou(instituicao, d, "instituicao")
    let titulo-projeto = _ou(titulo-projeto, d, "titulo-projeto")
    let titulo = _ou(titulo, d, "titulo")
    let subtitulo = _ou(subtitulo, d, "subtitulo")
    let volume = _ou(volume, d, "volume")
    let titulo-volume = _ou(titulo-volume, d, "titulo-volume")
    let codigo-relatorio = _ou(codigo-relatorio, d, "codigo-relatorio")
    let classificacao = _ou(classificacao, d, "classificacao")
    let autores = _lista(_ou(autores, d, "autores"))
    let local = _ou(local, d, "local")
    let ano = _ou(ano, d, "ano")
    let pagina-inicial = _ou(pagina-inicial, d, "pagina-inicial")

    // Continuação da numeração de um volume anterior
    if pagina-inicial != none { counter(page).update(pagina-inicial) }

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
      text(size: 14pt)[: #subtitulo]
    }

    // Volume e titulo especifico do volume
    if volume != none {
      v(0.5em)
      text(size: 12pt)[Volume #_txt(volume)]
    }

    if titulo-volume != none {
      v(0.5em)
      text(weight: "bold", size: 12pt, titulo-volume)
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
    for autor in autores {
      text(size: 12pt, _autor-nome(autor))
      let qual = _autor-qual(autor)
      if qual != none {
        linebreak()
        text(size: 10pt, qual)
      }
      v(0.5em)
    }

    v(1fr)

    // Local e ano
    if local != none {
      text(size: 12pt, local)
      linebreak()
    }

    if ano != none {
      text(size: 12pt, _txt(ano))
    }
  }

  pagebreak(weak: true)
}

/// Verso da folha de rosto
/// Contém a equipe técnica (opcional) e/ou os dados de catalogação-na-publicação.
/// A NBR 10719 (4.2.1.1.2 b e 4.2.3.6) manda ter OS DADOS DE CATALOGAÇÃO OU o
/// formulário de identificação (`formulario-identificacao()`): um dos dois é
/// obrigatório, e o formulário só vale no lugar do CIP. Sem nenhum dos dois
/// parâmetros a função não imprime nada. Vem logo depois de `report-title-page()`.
/// - equipe-tecnica: lista de textos ou de `(funcao: "...", nome: "...")`
/// - dados-catalogacao: conteúdo da ficha (caixa de 12,5 cm, texto de 10 pt
///   alinhado à esquerda, sem recuo)
#let report-title-page-verso(
  equipe-tecnica: none,
  dados-catalogacao: none,
) = {
  let equipe = _lista(equipe-tecnica)
  if equipe.len() == 0 and dados-catalogacao == none { return }

  set page(numbering: none)
  set par(first-line-indent: 0pt)

  // Equipe tecnica (opcional)
  if equipe.len() > 0 {
    align(center)[
      #text(weight: "bold", size: 11pt, "EQUIPE TÉCNICA")
    ]
    v(1em)

    for member in equipe {
      if type(member) == dictionary {
        let nome = member.at("nome", default: member.at("name", default: none))
        let funcao = member.at("funcao", default: member.at("function", default: none))
        assert(nome != none, message: "equipe-tecnica: falta a chave \"nome\" em " + repr(member))
        if funcao != none [*#funcao:* #nome] else [#nome]
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
        #set align(left)
        #set text(size: 10pt)
        #set par(leading: abnt-leading(1), spacing: abnt-leading(1), justify: false)
        #dados-catalogacao
      ]
    ]
  }

  pagebreak(weak: true)
}

/// Errata para Relatório Técnico (NBR 10719 4.2.1.2: logo depois da folha de rosto)
/// Formato de tabela: Folha, Linha, Onde se lê, Leia-se. Sem `itens` não imprime nada.
/// - referencia: referência da publicação a que a errata se aplica
/// - itens: lista de `(pagina: 12, linha: 5, errado: "...", correto: "...")`
///   (`folha` também vale no lugar de `pagina`)
#let errata(
  referencia: none,
  itens: (),
) = {
  if itens.len() == 0 { return }
  abre-anverso()

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
  table(
    columns: (auto, auto, 1fr, 1fr),
    stroke: 0.5pt,
    inset: 6pt,
    align: left,

    [*Folha*], [*Linha*], [*Onde se lê*], [*Leia-se*],

    ..{
      let cells = ()
      for item in itens {
        cells.push(_txt(_campo(item, ("pagina", "folha"), "errata")))
        cells.push(_txt(_campo(item, ("linha",), "errata")))
        cells.push(_campo(item, ("errado",), "errata"))
        cells.push(_campo(item, ("correto",), "errata"))
      }
      cells
    }
  )

  pagebreak(weak: true)
}

/// Agradecimentos para Relatório Técnico
#let agradecimentos-relatorio(conteudo) = {
  abre-anverso()
  align(center)[
    #text(weight: "bold", size: 12pt, "AGRADECIMENTOS")
  ]
  v(1.5em)
  conteudo
  pagebreak(weak: true)
}

/// Resumo para Relatório Técnico conforme NBR 6028
/// As palavras-chave saem separadas por "; " e finalizadas por ponto (NBR 6028
/// 4.1.7). O espaçamento é o do documento (`espacamento` de `relatorio()`).
#let resumo-relatorio(conteudo, palavras-chave: ()) = {
  abre-anverso()
  align(center)[
    #text(weight: "bold", size: 12pt, "RESUMO")
  ]

  v(1.5em)

  set par(
    first-line-indent: 0pt,
    justify: true,
  )

  conteudo

  v(1.5em)

  let kw = _lista(palavras-chave).flatten()
  if kw.len() > 0 {
    [*Palavras-chave:* #kw.join("; "). ]
  }

  pagebreak(weak: true)
}

/// Formulário de identificação para Relatório Técnico (NBR 10719, Anexo A)
/// Obrigatório quando não se usam os dados de catalogação-na-publicação
/// (`report-title-page-verso(dados-catalogacao:)`); um dos dois basta. Sai como
/// quadro, com os campos do Anexo A na ordem da norma: título e subtítulo;
/// classificação de segurança, número, tipo e data; título do projeto/programa/plano
/// e número; autores; instituição executora e patrocinadora (cada uma com o
/// endereço completo, no mesmo campo); resumo; palavras-chave; edição, número de
/// páginas, volume/parte, número de classificação, ISSN, tiragem, preço,
/// distribuidor e observações. Sem nenhum campo informado, não imprime nada.
/// - instituicoes: lista de textos; vale como instituição executora quando
///   `instituicao-executora` não é dada
/// - distribuicao: campo extra, ao lado do distribuidor
#let formulario-identificacao(
  titulo: none,
  subtitulo: none,
  classificacao: none,
  numero-relatorio: none,
  tipo-relatorio: none,
  data: none,
  titulo-projeto: none,
  numero-projeto: none,
  autores: (),
  instituicao-executora: none,
  instituicao-patrocinadora: none,
  instituicoes: (),
  texto-resumo: none,
  palavras-chave: (),
  edicao: none,
  paginas: none,
  volume: none,
  numero-classificacao: none,
  issn: none,
  tiragem: none,
  preco: none,
  distribuicao: none,
  distribuidor: none,
  observacoes: none,
) = {
  let autores = _lista(autores)
  let kw = _lista(palavras-chave).flatten()
  let executora = if instituicao-executora != none { instituicao-executora } else if instituicoes.len() > 0 {
    _lista(instituicoes).join(linebreak())
  } else { none }

  let todos = (
    titulo, classificacao, numero-relatorio, tipo-relatorio, data, titulo-projeto, numero-projeto,
    executora, instituicao-patrocinadora, texto-resumo, edicao, paginas, volume, numero-classificacao,
    issn, tiragem, preco, distribuicao, distribuidor, observacoes,
  )
  if autores.len() == 0 and kw.len() == 0 and todos.all(x => x == none) { return }

  heading(level: 1, numbering: none, "FORMULÁRIO DE IDENTIFICAÇÃO")

  set text(size: 10pt)
  set par(first-line-indent: 0pt, justify: false, leading: abnt-leading(1), spacing: abnt-leading(1))

  // Campo do quadro: rótulo pequeno em negrito sobre o valor, ocupando `n` de 12 colunas
  let campo(rotulo, valor, n) = table.cell(colspan: n)[
    #text(size: 8pt, weight: "bold", rotulo)
    #if valor != none { linebreak(); _txt(valor) } else { v(1.2em) }
  ]

  let titulo-completo = if titulo != none and subtitulo != none [#titulo: #subtitulo] else { titulo }
  let issn-fmt = if issn != none and type(issn) == str { format-issn(issn) } else { issn }

  table(
    columns: (1fr,) * 12,
    stroke: 0.5pt,
    inset: 5pt,
    align: left,

    campo("Título e subtítulo", titulo-completo, 12),
    campo("Classificação de segurança", classificacao, 3),
    campo("N.º", numero-relatorio, 3),
    campo("Tipo de relatório", tipo-relatorio, 3),
    campo("Data", data, 3),
    campo("Título do projeto/programa/plano", titulo-projeto, 9),
    campo("N.º", numero-projeto, 3),
    campo("Autor(es)", if autores.len() > 0 { autores.map(_autor-nome).join(linebreak()) } else { none }, 12),
    campo("Instituição executora e endereço completo", executora, 12),
    campo("Instituição patrocinadora e endereço completo", instituicao-patrocinadora, 12),
    campo("Resumo", texto-resumo, 12),
    campo("Palavras-chave/descritores", if kw.len() > 0 [#kw.join("; ").] else { none }, 12),
    campo("Edição", edicao, 4),
    campo("N.º de páginas", paginas, 4),
    campo("N.º do volume/parte", volume, 4),
    campo("N.º de classificação", numero-classificacao, 3),
    campo("ISSN", issn-fmt, 3),
    campo("Tiragem", tiragem, 3),
    campo("Preço", preco, 3),
    ..if distribuicao != none {
      (campo("Distribuidor", distribuidor, 8), campo("Distribuição", distribuicao, 4))
    } else {
      (campo("Distribuidor", distribuidor, 12),)
    },
    campo("Observações/notas", observacoes, 12),
  )

  pagebreak(weak: true)
}

/// Código de identificação do relatório (NBR 10719 4.2.1.1.1 f)
/// Formato: sigla da instituição + categoria + data + assunto + número sequencial,
/// sem os campos vazios.
///
/// Exemplo: `#report-code(codigo-instituicao: "INPE", categoria: "RPE", ano: 2024,
/// assunto: "EST", sequencia: 1)` dá `INPE-RPE-2024-EST-001`
/// - sequencia: número (ou texto numérico), com três dígitos; `none` omite
/// Devolve texto: serve para `codigo-relatorio:` de `relatorio()` e de
/// `report-title-page()`.
#let report-code(
  codigo-instituicao: "",
  categoria: "",
  ano: none,
  assunto: "",
  sequencia: 1,
  separador: "-",
) = {
  assert(
    sequencia == none or type(sequencia) in (int, str),
    message: "report-code(): sequencia deve ser número ou texto numérico",
  )
  // Formatar numero com zeros a esquerda
  let seq-str = if sequencia == none { none } else {
    let s = str(int(sequencia))
    "0" * calc.max(0, 3 - s.len()) + s
  }

  let partes = (codigo-instituicao, categoria, if ano != none { str(ano) }, assunto, seq-str)
    .filter(p => p != none and p != "")
  if partes.len() == 0 { "" } else { partes.join(separador) }
}
