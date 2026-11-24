// Template para publicacao periodica tecnica e/ou cientifica
// Conforme NBR 6021:2015

#import "../core/setup.typ": with-abnt-setup
#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/dates.typ": *
#import "../references/abbreviations.typ": *
#import "article.typ": _cabecalho-artigo

// Dados do fasciculo, gravados por `periodical()`: a capa, a folha de rosto e a
// legenda os usam quando o parametro nao e informado (como `dados()` no TCC)
#let _per-meta = state("abnt-periodico", (:))

// Valor explicito ou, na falta, o do fasciculo (deve ser chamado dentro de `context`)
#let _per-resolve(explicito, chave, padrao: none) = if explicito != none {
  explicito
} else {
  _per-meta.get().at(chave, default: padrao)
}

// Data da edicao: "2014", "jan./mar. 2013" ou, com dia (periodicidade inferior a
// mensal), "16 set. 2014" (NBR 6021 5.5, 5.7.2.4)
#let _per-data(dia, mes-inicio, mes-fim, ano) = {
  let mes = if mes-inicio == none { "" } else if mes-fim != none {
    format-month-range(mes-inicio, mes-fim)
  } else { get-month-abbrev(mes-inicio) }
  let dia-texto = if dia != none and mes-fim == none { [#dia ] } else { [] }
  [#dia-texto#mes #ano]
}

// Legenda bibliografica (NBR 6021 5.7.2.3 a): "R. bras. Biol., Cidade, v. 8, n. 2, p. 9-21, maio/ago. 2026."
#let _per-legenda(titulo, local, volume, numero, paginas, data) = {
  [#abbreviate-title(titulo), #local, v. #volume, n. #numero, p. #paginas, #data.]
}

// Marca o inicio de um artigo ou secao (editorial, instrucoes para autores): serve ao
// sumario (titulo, autores, pagina) e a legenda (intervalo de paginas da secao) e
// reinicia a numeracao das secoes, que recomeca a cada artigo
#let _per-marca(titulo, autores: (), listar: true) = {
  counter(heading).update(0)
  [#metadata((titulo: titulo, autores: autores, listar: listar)) <abnt-per-secao>]
}

/// Template principal para fasciculo de periodico
///
/// Parametros:
/// - titulo: titulo do periodico
/// - subtitulo: subtitulo (opcional)
/// - issn: numero ISSN
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - ano: ano de publicacao
/// - mes-inicio: mes inicial (1-12)
/// - mes-fim: mes final (1-12, opcional para periodo)
/// - dia: dia da edicao (opcional; periodicidade inferior a mensal, com um so mes)
/// - local: cidade de publicacao
/// - editora: editora (informativo: nenhum elemento do template a imprime)
/// - instituicao: instituicao responsavel (impressa na capa)
/// - doi: identificador DOI (informativo: nenhum elemento do template o imprime; o
///   DOI de cada artigo vai em `periodical-article(doi:)`)
/// - pagina-inicial: numero da pagina em que o fasciculo comeca (padrao: 1). A
///   numeracao e sequencial do primeiro ao ultimo fasciculo do volume (NBR 6021 5.6):
///   informe aqui a pagina seguinte a ultima do fasciculo anterior. A folha de rosto
///   leva esse numero; a capa nao e numerada.
/// - fonte: fonte a usar
/// - enumeracao: "abnt" (padrão: alíneas a), b), c); subalíneas com travessão) ou
///   "latex" (1., a), i), A.)
///
/// `titulo`, `subtitulo`, `issn`, `volume`, `numero`, `ano`, `mes-*`, `dia`, `local` e
/// `instituicao` valem como padrao de `periodical-cover()` e `periodical-title-page()`
/// (informe-os so aqui). A legenda bibliografica de rodape traz o intervalo de paginas
/// do artigo ou secao corrente (NBR 6021 5.7.1.2) e nao aparece na capa nem na folha
/// de rosto e seu verso.
#let periodical(
  titulo: "",
  subtitulo: none,
  issn: none,
  volume: none,
  numero: none,
  ano: datetime.today().year(),
  mes-inicio: none,
  mes-fim: none,
  dia: none,
  local: none,
  editora: none,
  instituicao: none,
  doi: none,
  pagina-inicial: 1,
  fonte: "Times New Roman",
  enumeracao: "abnt",
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
  )

  show: with-abnt-setup.with(fonte: fonte, level-1-pagebreak: false, enumeracao: enumeracao)

  // Paginação e legenda bibliografica no rodape (periodico-especifico)
  set page(
    numbering: "1",
    number-align: top + right,
    footer: context {
      let data = _per-data(dia, mes-inicio, mes-fim, ano)

      // Intervalo de paginas do artigo ou secao corrente: da marca que comecou
      // ate esta pagina ate a pagina anterior a da marca seguinte (a ultima vai
      // ate o fim do fasciculo). Fora de qualquer secao (ex.: sumario): a pagina.
      let atual = counter(page).get().first()
      let inicios = query(<abnt-per-secao>).map(m => counter(page).at(m.location()).first())
      let ate-aqui = inicios.filter(n => n <= atual)
      let paginas = str(atual)
      if ate-aqui.len() > 0 {
        let inicio = ate-aqui.last()
        let seguintes = inicios.filter(n => n > atual)
        let fim = if seguintes.len() > 0 { calc.max(inicio, seguintes.first() - 1) } else {
          counter(page).final().first()
        }
        paginas = if fim > inicio { str(inicio) + "-" + str(fim) } else { str(inicio) }
      }

      set text(size: 10pt)
      set align(left)
      _per-legenda(titulo, local, volume, numero, paginas, data)
    },
  )

  // A capa nao e numerada: a folha de rosto leva `pagina-inicial`
  counter(page).update(pagina-inicial - 1)

  _per-meta.update((
    titulo: titulo, subtitulo: subtitulo, issn: issn, volume: volume, numero: numero,
    ano: ano, mes-inicio: mes-inicio, mes-fim: mes-fim, dia: dia, local: local,
    instituicao: instituicao,
  ))

  body
}

/// Capa do fasciculo conforme NBR 6021:2015
/// Primeira capa com elementos obrigatorios
///
/// Parametros (os que ficarem `none` valem o que foi dado a `periodical()`):
/// - titulo: titulo do periodico
/// - subtitulo: subtitulo (opcional)
/// - issn: numero ISSN (obrigatorio, canto superior direito)
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - ano: ano
/// - mes-inicio: mes inicial
/// - mes-fim: mes final (opcional)
/// - dia: dia (periodicidade inferior a mensal; impresso como "16 de setembro de 2014")
/// - instituicao: instituicao responsavel (obrigatoria, 4.1.1 e)
/// - logo: logomarca (opcional)
/// - suplemento: indicacao de suplemento (opcional)
#let periodical-cover(
  titulo: none,
  subtitulo: none,
  issn: none,
  volume: none,
  numero: none,
  ano: none,
  dia: none,
  mes-inicio: none,
  mes-fim: none,
  instituicao: none,
  logo: none,
  suplemento: none,
) = {
  set page(numbering: none, footer: none)

  context {
    let titulo = _per-resolve(titulo, "titulo", padrao: "")
    let subtitulo = _per-resolve(subtitulo, "subtitulo")
    let issn = _per-resolve(issn, "issn")
    let volume = _per-resolve(volume, "volume")
    let numero = _per-resolve(numero, "numero")
    let ano = _per-resolve(ano, "ano")
    let dia = _per-resolve(dia, "dia")
    let mes-inicio = _per-resolve(mes-inicio, "mes-inicio")
    let mes-fim = _per-resolve(mes-fim, "mes-fim")
    let instituicao = _per-resolve(instituicao, "instituicao")

    // ISSN no canto superior direito
    if issn != none {
      place(top + right)[
        #text(size: 10pt)[ISSN #issn]
      ]
    }

    v(2cm)

    // Logomarca (se houver)
    if logo != none {
      align(center)[#logo]
      v(1cm)
    }

    // Titulo e subtitulo
    align(center)[
      #text(weight: "bold", size: 16pt, upper(titulo))
      #if subtitulo != none {
        linebreak()
        text(size: 14pt, subtitulo)
      }
    ]

    v(1fr)

    // Indicacao de suplemento
    if suplemento != none {
      align(center)[
        #text(size: 12pt, suplemento)
      ]
      v(1em)
    }

    // Volume, numero e data
    align(center)[
      #text(size: 12pt)[
        v. #volume
        #h(1em)
        n. #numero
        #h(1em)
        #if mes-inicio != none {
          if mes-fim != none {
            [#month-names.at(mes-inicio - 1)/#month-names.at(mes-fim - 1)]
          } else if dia != none {
            [#dia de #month-names.at(mes-inicio - 1) de]
          } else {
            month-names.at(mes-inicio - 1)
          }
        }
        #h(0.5em)
        #ano
      ]
    ]

    // Instituicao responsavel
    if instituicao != none {
      v(1em)
      align(center, text(size: 12pt, instituicao))
    }

    v(2cm)
    pagebreak()
  }
}

/// Folha de rosto do fasciculo (anverso)
/// Conforme NBR 6021:2015 secao 4.3.1
///
/// Parametros (os que ficarem `none` valem o que foi dado a `periodical()`):
/// - titulo: titulo do periodico
/// - issn: numero ISSN
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - paginas: intervalo de paginas do fasciculo (ex: "1-154"); se omitido, e calculado
///   (da pagina desta folha ate a ultima do documento)
/// - ano: ano
/// - mes-inicio: mes inicial
/// - mes-fim: mes final (opcional)
/// - dia: dia da edicao (opcional)
/// - local: cidade de publicacao
#let periodical-title-page(
  titulo: none,
  issn: none,
  volume: none,
  numero: none,
  paginas: none,
  ano: none,
  dia: none,
  mes-inicio: none,
  mes-fim: none,
  local: none,
) = {
  // Sem rodape: a legenda completa desta folha ja esta no corpo (5.7.1.1)
  set page(numbering: none, footer: none)

  context {
    let titulo = _per-resolve(titulo, "titulo", padrao: "")
    let issn = _per-resolve(issn, "issn")
    let volume = _per-resolve(volume, "volume")
    let numero = _per-resolve(numero, "numero")
    let ano = _per-resolve(ano, "ano")
    let dia = _per-resolve(dia, "dia")
    let mes-inicio = _per-resolve(mes-inicio, "mes-inicio")
    let mes-fim = _per-resolve(mes-fim, "mes-fim")
    let local = _per-resolve(local, "local")
    let paginas = if paginas != none { paginas } else {
      str(counter(page).get().first()) + "-" + str(counter(page).final().first())
    }

    // Titulo com destaque
    align(center)[
      #text(weight: "bold", size: 14pt, upper(titulo))
    ]

    v(2cm)

    // ISSN acima da legenda bibliografica
    if issn != none {
      align(center)[
        #text(size: 10pt)[ISSN #issn]
      ]
    }

    v(1cm)

    // Legenda bibliografica completa
    align(center)[
      #set par(first-line-indent: 0pt)
      #text(size: 10pt)[
        #_per-legenda(titulo, local, volume, numero, paginas, _per-data(dia, mes-inicio, mes-fim, ano))
      ]
    ]

    v(1fr)
    pagebreak()
  }
}

/// Verso da folha de rosto
/// Conforme NBR 6021:2015 secao 4.3.1.2
///
/// Parametros:
/// - ano-copyright: ano do copyright
/// - detentor-copyright: detentor dos direitos
/// - direitos-reproducao: autorizacao de reproducao (opcional)
/// - outros-formatos: outros suportes disponiveis (opcional)
/// - catalogacao: dados de catalogacao na publicacao
/// - creditos: creditos e outras informacoes
#let periodical-title-page-verso(
  ano-copyright: none,
  detentor-copyright: none,
  direitos-reproducao: none,
  outros-formatos: none,
  catalogacao: none,
  creditos: none,
) = {
  set page(numbering: none, footer: none)
  set text(size: 10pt, top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(first-line-indent: 0pt, leading: abnt-leading(1), spacing: abnt-leading(1))

  // Copyright
  if ano-copyright != none and detentor-copyright != none {
    [© #ano-copyright #detentor-copyright]
    v(1em)
  }

  // Autorizacao de reproducao
  if direitos-reproducao != none {
    direitos-reproducao
    v(1em)
  }

  // Outros suportes
  if outros-formatos != none {
    outros-formatos
    v(1em)
  }

  // Creditos
  if creditos != none {
    creditos
    v(1em)
  }

  v(1fr)

  // Dados de catalogacao (parte inferior)
  if catalogacao != none {
    align(center)[
      #box(
        width: 12cm,
        stroke: 0.5pt,
        inset: 0.5cm,
      )[
        #catalogacao
      ]
    ]
  }

  pagebreak()
}

/// Sumario do fasciculo
/// Conforme NBR 6027: uma entrada por artigo (titulo, autores e pagina inicial),
/// mais o editorial e as instrucoes para autores; as secoes internas dos artigos
/// nao entram. As entradas vem de `periodical-article()`, `editorial()` e
/// `author-guidelines()`, na ordem em que aparecem no fasciculo.
#let periodical-toc(
  titulo: "SUMÁRIO",
) = {
  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  // A propria pagina do sumario conta como secao (legenda), mas nao e listada
  _per-marca(titulo, listar: false)

  context {
    set par(first-line-indent: 0pt, justify: false, leading: abnt-leading(1), spacing: abnt-leading(1))
    for m in query(<abnt-per-secao>).filter(m => m.value.listar) {
      let entrada = m.value
      let pagina = counter(page).at(m.location()).first()
      let autores = if entrada.autores.len() > 0 { entrada.autores.map(a => a.name).join("; ") } else { "" }
      link(m.location())[
        #entrada.titulo
        #if autores != "" { linebreak(); autores }
        #box(width: 1fr, repeat[.])
        #pagina
      ]
      parbreak()
    }
  }

  pagebreak()
}

/// Editorial
/// Texto do editor apresentando o conteudo do fasciculo
#let editorial(conteudo) = {
  _per-marca("EDITORIAL")
  heading(level: 1, numbering: none, "EDITORIAL")
  conteudo
  pagebreak()
}

/// Legenda bibliografica completa
/// Para uso no rodape de cada pagina ou folha de rosto
///
/// Parametros:
/// - titulo: titulo do periodico (sera abreviado)
/// - local: cidade
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - paginas: paginas (ex: "1-154" para fasciculo, "9-21" para artigo)
/// - mes-inicio: mes inicial (1-12)
/// - mes-fim: mes final (1-12, opcional)
/// - dia: dia da edicao (opcional; so com um mes)
/// - ano: ano
#let bibliographic-legend(
  titulo: "",
  local: "",
  volume: none,
  numero: none,
  paginas: none,
  mes-inicio: none,
  mes-fim: none,
  dia: none,
  ano: none,
) = {
  text(size: 10pt)[
    #_per-legenda(titulo, local, volume, numero, paginas, _per-data(dia, mes-inicio, mes-fim, ano))
  ]
}

/// Artigo em periodico
/// Conforme NBR 6022:2018 (integrado com NBR 6021:2015)
///
/// Cada artigo vira uma entrada do sumario (`periodical-toc()`), reinicia a
/// numeracao das secoes e tem a legenda bibliografica com o seu intervalo de paginas.
/// Mesmos elementos de `artigo()`: titulo (12 pt), subtitulo, titulo em outro idioma,
/// autores, resumo, abstract, datas de submissao e aprovacao, DOI. Para os
/// agradecimentos, `agradecimentos-artigo()`.
///
/// Parametros:
/// - titulo: titulo do artigo
/// - subtitulo: subtitulo (opcional); sai depois de dois-pontos colados ao titulo
/// - titulo-en: titulo em outro idioma (opcional)
/// - autores: lista de autores com afiliacao
/// - resumo: resumo em portugues
/// - palavras-chave: palavras-chave
/// - resumo-en: abstract em ingles (opcional)
/// - palavras-chave-en: keywords (opcional)
/// - submissao: data de submissao (obrigatoria, NBR 6022 5.1.4): texto, conteudo ou datetime
/// - aprovacao: data de aprovacao (idem)
/// - doi: identificacao e disponibilidade (opcional), por exemplo o DOI
#let periodical-article(
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
  body,
) = {
  _per-marca(titulo, autores: autores)

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
  body
}

/// Instrucoes editoriais para autores
/// Conforme NBR 6021:2015 secao 4.5.2
#let author-guidelines(conteudo) = {
  _per-marca("INSTRUÇÕES PARA AUTORES")
  heading(level: 1, numbering: none, "INSTRUÇÕES PARA AUTORES")
  set par(first-line-indent: 0pt)
  conteudo
}

/// Suplemento de periodico
/// Conforme NBR 6021:2015 secao 5.4
///
/// Parametros:
/// - titulo-principal: titulo do periodico principal
/// - titulo-suplemento: titulo do suplemento
/// - volume: volume do periodico principal
/// - ano: ano
/// - issn: ISSN do periodico principal
#let supplement-info(
  titulo-principal: "",
  titulo-suplemento: "",
  volume: none,
  ano: none,
  issn: none,
) = {
  text(size: 10pt)[
    Suplemento de: #titulo-principal, v. #volume, #ano.
    #titulo-suplemento
    #if issn != none { [ISSN #issn] }
  ]
}
