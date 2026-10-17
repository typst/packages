// Sistema Numerico de Citacoes conforme NBR 10520:2023
//
// ============================================================================
// SOBRE O SISTEMA NUMERICO
// ============================================================================
//
// A NBR 10520:2023 (secao 6) permite dois sistemas de chamada para citacoes:
// - Sistema autor-data (padrao no Brasil)
// - Sistema numerico (permitido pela norma)
//
// Este modulo implementa o sistema numerico, inspirado no abntex2-num.bst
// do pacote abntex2 para LaTeX.
//
// IMPORTANTE (NBR 10520:2023, secao 6.2.2):
// "O sistema numerico NAO pode ser usado quando houver notas"
// Isso significa que se voce usar o sistema numerico, NAO pode ter notas
// de rodape no documento, pois haveria conflito na numeracao.
//
// ============================================================================
// FUNCIONAMENTO
// ============================================================================
//
// No sistema numerico:
// - Citacoes sao indicadas por numeros arabicos consecutivos
// - A numeracao remete a lista de referencias ao final do documento
// - A numeracao NAO reinicia a cada pagina
// - Fonte repetida recebe a MESMA numeracao da primeira ocorrencia
//
// Formatos permitidos (NBR 10520:2023):
// - Entre parenteses: (15, p. 34)
// - Em expoente (sobrescrito): ¹⁵, p. 34
//
// ============================================================================
// INSPIRACAO
// ============================================================================
//
// Este modulo foi inspirado no abntex2-num.bst do projeto abntex2
// (https://github.com/abntex/abntex2), adaptado para a sintaxe do Typst.
//
// ============================================================================

#import "../core/spacing.typ": abnt-leading

// Estado global para o sistema numerico
// Armazena o mapeamento de chaves de citacao para numeros
// O numero de cada chave e o seu tamanho + 1 no momento do primeiro registro
#let _numeric-citations = state("abnt-numeric-citations", (:))

// Configuracao do documento (citacao-num-config): estilo e colchetes padrao,
// lidos por todas as funcoes citar-num-* cujo parametro e `auto`.
#let _numeric-config = state("abnt-numeric-config", (estilo: "parentheses", colchetes: "()"))

// Resolve estilo/colchetes: valor passado na chamada, ou o do documento se `auto`.
// Use dentro de `context`.
#let _numeric-cfg(estilo, colchetes) = {
  let cfg = _numeric-config.get()
  (
    if estilo == auto { cfg.estilo } else { estilo },
    if colchetes == auto { cfg.colchetes } else { colchetes },
  )
}

// Registra chaves ainda nao citadas, em ordem. O update e uma funcao do
// proprio estado (nao depende de leitura em context); do contrario cada
// citacao nova dependeria da anterior e o layout nao convergiria com 5+.
#let _numeric-register(..chaves) = _numeric-citations.update(c => {
  for chave in chaves.pos() {
    if chave not in c { c.insert(chave, c.len() + 1) }
  }
  c
})

// ============================================================================
// CONFIGURACAO DO SISTEMA NUMERICO
// ============================================================================

/// Configura o documento para usar o sistema numerico de citacoes
///
/// ATENCAO: O sistema numerico NAO pode ser usado com notas de rodape
/// (NBR 10520:2023, secao 6.2.2: "O sistema numerico nao pode ser utilizado
/// quando houver notas"). O pacote NAO impede nem avisa se houver `#footnote`
/// no documento: a proibicao e responsabilidade de quem escreve.
///
/// Grava o estilo e os colchetes do documento: todas as funcoes `citar-num-*`,
/// `citacao-num-curta` e `citacao-num-longa` passam a usa-los, a menos que a
/// chamada traga o proprio `estilo`/`colchetes`. Tambem reinicia a numeracao.
///
/// Parametros:
/// - estilo: estilo de apresentacao ("parentheses" ou "superscript")
///   - "parentheses": (1), (2, p. 45) - padrao
///   - "superscript": ¹, ², p. 45 - sobrescrito
/// - colchetes: tipo de delimitador para estilo parentheses
///   - "()" - parenteses (padrao)
///   - "[]" - colchetes
///
/// Exemplo:
/// ```typst
/// #show: citacao-num-config
///
/// Conforme demonstrado #citar-num(<silva2023>), o resultado foi positivo.
/// ```
#let citacao-num-config(
  estilo: "parentheses",
  colchetes: "()",
  body,
) = {
  // Armazenar configuracao no estado global lido por citar-num e demais
  _numeric-config.update((estilo: estilo, colchetes: colchetes))

  // Resetar contadores no inicio do documento
  _numeric-citations.update((:))

  body
}

// ============================================================================
// FUNCOES DE CITACAO NUMERICA
// ============================================================================

/// Citacao numerica simples
///
/// Insere uma citacao no formato numerico. Se a referencia ja foi citada,
/// reutiliza o mesmo numero.
///
/// Parametros:
/// - chave: chave da referencia (string identificadora)
/// - pagina: pagina (opcional)
/// - estilo: "parentheses" ou "superscript" (opcional, usa padrao do documento)
///
/// Exemplos:
/// ```typst
/// O resultado foi confirmado #citar-num("silva2023").
/// Conforme demonstrado #citar-num("santos2022", pagina: "45").
/// ```
///
/// Formatos de saida (NBR 10520:2023):
/// - Parenteses: (1) ou (1, p. 45)
/// - Sobrescrito: ¹ ou ¹, p. 45
#let citar-num(
  chave,
  pagina: none,
  volume: none,
  estilo: auto,
  colchetes: auto,
) = {
  _numeric-register(chave)
  context {
    let (estilo, colchetes) = _numeric-cfg(estilo, colchetes)
    let num = _numeric-citations.get().at(chave)

    // Formatar localizacao (pagina, volume)
    let loc = if pagina != none or volume != none {
      let parts = ()
      if volume != none { parts.push([v. #volume]) }
      if pagina != none { parts.push([p. #pagina]) }
      [, #parts.join(", ")]
    } else {
      []
    }

    // Formatar saida conforme estilo
    if estilo == "superscript" {
      // Formato sobrescrito: ¹, p. 45
      // Nota: sem espaco antes do sobrescrito (NBR 10520:2023)
      super[#num#loc]
    } else {
      // Formato parenteses: (1, p. 45)
      let (open, close) = if colchetes == "[]" {
        ("[", "]")
      } else {
        ("(", ")")
      }
      [#open#num#loc#close]
    }
  }
}

/// Citacao numerica com autor no texto
///
/// Quando o nome do autor aparece na sentenca, apenas o numero vai
/// entre parenteses ou sobrescrito.
///
/// Exemplo:
/// ```typst
/// Segundo Silva #citar-num-linha("silva2023", pagina: "45"), o resultado...
/// ```
///
/// Saida: Segundo Silva (1, p. 45), o resultado...
#let citar-num-linha(
  chave,
  pagina: none,
  volume: none,
  estilo: auto,
  colchetes: auto,
) = {
  citar-num(chave, pagina: pagina, volume: volume, estilo: estilo, colchetes: colchetes)
}

/// Citacao numerica multipla
///
/// Cita multiplas referencias de uma vez.
///
/// Exemplo:
/// ```typst
/// Varios autores confirmam #citar-num-multiplos(("silva2023", "santos2022", "costa2021")).
/// ```
///
/// Saida: (1, 2, 3) (NBR 10520:2023, 6.2.3: "(5, 7)") ou ¹, ², ³
#let citar-num-multiplos(
  chaves,
  estilo: auto,
  colchetes: auto,
) = {
  _numeric-register(..chaves)
  context {
    let (estilo, colchetes) = _numeric-cfg(estilo, colchetes)
    let citations = _numeric-citations.get()
    let nums = chaves.map(chave => citations.at(chave))

    if estilo == "superscript" {
      super[#nums.map(str).join(", ")]
    } else {
      let (open, close) = if colchetes == "[]" {
        ("[", "]")
      } else {
        ("(", ")")
      }
      [#open#nums.map(str).join(", ")#close]
    }
  }
}

/// Citacao numerica de citacao (apud)
///
/// Para citar uma fonte que voce nao teve acesso direto,
/// citada em outra obra que voce consultou.
///
/// NBR 10520:2023, 7.3: na lista de referencias entra SOMENTE a fonte consultada.
/// Por isso so a fonte consultada e numerada e registrada; a original aparece
/// como TEXTO, exatamente como voce a escrever em `chave-original`.
///
/// Parametros:
/// - chave-original: texto da fonte original (nao acessada), ex.: "Freire, 1994"
/// - pagina-original: pagina na fonte original (opcional)
/// - chave-consultada: chave da fonte consultada (numerada, vai para a lista)
/// - pagina-consultada: pagina na fonte consultada (opcional)
///
/// Exemplo:
/// ```typst
/// Segundo a teoria #citar-num-apud("Freire, 1994", "streck2017", pagina-original: "13", pagina-consultada: "25").
/// ```
///
/// Saida: (Freire, 1994, p. 13 apud 1, p. 25)
#let citar-num-apud(
  chave-original,
  chave-consultada,
  pagina-original: none,
  pagina-consultada: none,
  estilo: auto,
  colchetes: auto,
) = {
  _numeric-register(chave-consultada)
  context {
    let (estilo, colchetes) = _numeric-cfg(estilo, colchetes)
    let citations = _numeric-citations.get()
    let cons-num = citations.at(chave-consultada)

    let orig-loc = if pagina-original != none { [, p. #pagina-original] } else { [] }
    let cons-loc = if pagina-consultada != none { [, p. #pagina-consultada] } else { [] }

    if estilo == "superscript" {
      super[#chave-original#orig-loc apud #cons-num#cons-loc]
    } else {
      let (open, close) = if colchetes == "[]" {
        ("[", "]")
      } else {
        ("(", ")")
      }
      [#open#chave-original#orig-loc apud #cons-num#cons-loc#close]
    }
  }
}

// ============================================================================
// CITACOES DIRETAS COM NUMERO
// ============================================================================

/// Citacao direta curta (ate 3 linhas) com numero
///
/// Formatada entre aspas duplas, com numero ao final.
///
/// Exemplo:
/// ```typst
/// #citacao-num-curta("silva2023", pagina: "45")[
///   O resultado demonstrou significativa melhoria.
/// ]
/// ```
///
/// Saida: "O resultado demonstrou significativa melhoria" (1, p. 45).
#let citacao-num-curta(
  chave,
  pagina: none,
  estilo: auto,
  colchetes: auto,
  body,
) = {
  // O conteudo escrito em varias linhas ([\n texto\n]) traz espaco no comeco e no
  // fim; com aspas retas isso inverte a aspa de fechamento (“ texto “). Tira os
  // espacos das pontas e usa aspas tipograficas explicitas.
  let miolo = if body.has("children") {
    let filhos = body.children
    while filhos.len() > 0 and filhos.first() == [ ] { filhos = filhos.slice(1) }
    while filhos.len() > 0 and filhos.last() == [ ] { filhos = filhos.slice(0, -1) }
    filhos.join()
  } else { body }
  [“#miolo” #citar-num(chave, pagina: pagina, estilo: estilo, colchetes: colchetes).]
}

/// Citacao direta longa (mais de 3 linhas) com numero
///
/// Formatada com recuo de 4cm, fonte menor, espacamento simples, sem aspas.
/// Numero ao final da citacao.
///
/// Exemplo:
/// ```typst
/// #citacao-num-longa("silva2023", pagina: "45-46")[
///   A teleconferencia permite ao individuo participar de um encontro
///   nacional ou regional sem a necessidade de deixar seu local de
///   origem. Tipos comuns de teleconferencia incluem o uso de televisao,
///   telefone e computador.
/// ]
/// ```
#let citacao-num-longa(
  chave,
  pagina: none,
  estilo: auto,
  colchetes: auto,
  body,
) = {
  set par(
    first-line-indent: 0pt,
    leading: abnt-leading(1), // espacamento simples
  )
  set text(size: 10pt) // fonte menor

  block(
    inset: (left: 4cm),
    [#body #citar-num(chave, pagina: pagina, estilo: estilo, colchetes: colchetes).]
  )
}

// ============================================================================
// BIBLIOGRAFIA NUMERADA
// ============================================================================

/// Bibliografia no sistema numerico
///
/// Gera a lista de referencias ordenada pela ordem de citacao no texto,
/// com numeros correspondentes as citacoes.
///
/// NOTA: A NBR 6023:2018 permite ordenacao alfabetica ou por ordem de citacao.
/// No sistema numerico, a ordenacao por ordem de citacao e mais intuitiva.
///
/// Parametros:
/// - itens: lista de referencias no formato (chave, conteudo)
/// - titulo: titulo da secao (padrao: "REFERENCIAS")
///
/// Exemplo:
/// ```typst
/// #bibliografia-numerica(
///   (
///     ("silva2023", [SILVA, J. *Titulo do livro*. Sao Paulo: Editora, 2023.]),
///     ("santos2022", [SANTOS, M. Artigo importante. *Revista*, v. 1, 2022.]),
///   )
/// )
/// ```
#let bibliografia-numerica(
  itens,
  titulo: "REFERÊNCIAS",
) = {
  // Titulo da secao
  heading(level: 1, numbering: none, titulo)

  v(1em)

  // Configuracao de paragrafo para referencias
  set par(
    hanging-indent: 0pt,
    first-line-indent: 0pt,
    leading: abnt-leading(1), // espacamento simples
  )

  context {
    let citations = _numeric-citations.get()

    // Ordenar itens pela ordem de citacao
    let ordered = itens.filter(item => item.at(0) in citations)
                       .sorted(key: item => citations.at(item.at(0)))

    // Itens nao citados vao ao final (se full: true)
    let uncited = itens.filter(item => item.at(0) not in citations)

    // Renderizar referencias numeradas
    for item in ordered {
      let (key, content) = item
      let num = citations.at(key)

      block(spacing: 0.8em)[
        #text(weight: "bold")[#num] #h(0.5em) #content
      ]
    }

    // Avisar sobre referencias nao citadas
    if uncited.len() > 0 {
      v(1em)
      text(fill: gray, size: 9pt)[
        _Nota: #uncited.len() referencia(s) nao citada(s) no texto foram omitidas._
      ]
    }
  }
}

/// Referencia numerada individual (para uso manual)
///
/// Quando nao se usa arquivo .bib, permite criar referencias numeradas manualmente.
///
/// Parametros:
/// - num: numero da referencia
/// - conteudo: conteudo formatado da referencia (conforme NBR 6023:2018)
#let ref-numerica(num, conteudo) = {
  set par(
    hanging-indent: 0pt,
    first-line-indent: 0pt,
  )

  block(spacing: 0.8em)[
    #text(weight: "bold")[#num] #h(0.5em) #conteudo
  ]
}

// ============================================================================
// AVISO SOBRE NOTAS DE RODAPE
// ============================================================================

/// Funcao para inserir aviso sobre incompatibilidade com notas
///
/// Use no inicio do documento quando adotar o sistema numerico.
#let aviso-sistema-numerico() = {
  text(size: 10pt, fill: luma(60), style: "italic")[
    Este documento utiliza o sistema numérico de citações (NBR 10520:2023, seção 6.2.2).
    Conforme a norma, o sistema numérico não pode ser usado simultaneamente com
    notas de rodapé.
  ]
}

// ============================================================================
// UTILITARIOS
// ============================================================================

/// Obtem o numero atual de uma citacao (se ja foi citada)
///
/// Util para referencias cruzadas manuais.
#let get-citation-number(chave) = {
  context {
    let citations = _numeric-citations.get()
    if chave in citations {
      str(citations.at(chave))
    } else {
      "?"
    }
  }
}

/// Reseta a numeracao de citacoes
///
/// Use apenas se precisar reiniciar a numeracao (ex: em livros com partes independentes).
/// NOTA: A NBR 10520:2023 diz que a numeracao NAO deve reiniciar a cada pagina,
/// mas pode ser reiniciada por capitulo em alguns casos.
#let reset-numeric-citations() = {
  _numeric-citations.update((:))
}

/// Obtem o total de citacoes ate o momento
#let get-citation-count() = {
  context {
    _numeric-citations.get().len()
  }
}

// Aliases curtos
#let cnum = citar-num
#let cnlinha = citar-num-linha
#let cnmultiplos = citar-num-multiplos
#let cnapud = citar-num-apud
#let cncurta = citacao-num-curta
#let cnlonga = citacao-num-longa
#let bibnum = bibliografia-numerica
