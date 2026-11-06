// Template para livros e folhetos conforme NBR 6029:2023
// Informacao e documentacao - Livros e folhetos - Apresentacao

#import "../core/setup.typ": with-abnt-setup, _abnt-titulo
#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/dates.typ": *
#import "../core/sorting.typ": sort-key, sort-initial
#import "../core/identifiers.typ": display-isbn, validate-isbn, validate-isbn10
#import "../elements/toc.typ": _abnt-outline-rules, _abnt-lista-rules
#import "../elements/index.typ": indice, _indice-canto

// Frente-verso: ligado por livro(frente-verso: true); os elementos que a NBR 6029
// manda abrir em pagina impar consultam este estado.
#let _frente-verso = state("abnt-livro-frente-verso", false)

// Dados da obra (titulo, autor, editora...), gravados por livro(): servem de padrao
// para as funcoes de capa e folha de rosto quando o parametro nao e repetido.
#let _livro-dados = state("abnt-livro-dados", (:))
#let _livro-dado(chave, valor) = if valor == auto {
  _livro-dados.get().at(chave, default: none)
} else { valor }

// Marcas de pagina (metadata nao conta como conteudo para o `weak` do pagebreak):
// - sem-moldura: pagina sem cabecalho nem numero (guardas, quarta capa);
// - fim / ini: fim do conteudo anterior e inicio do elemento que abre em impar/par.
//   A pagina em branco que o `pagebreak(to: ...)` insere nao tem marca nenhuma e
//   vem logo antes de uma pagina `ini`: assim o cabecalho e o numero a reconhecem
//   sem depender da paridade lida da execucao anterior (que nao converge quando ha
//   varios elementos em sequencia).
#let _livro-marca-sem-moldura() = [#metadata(none) <abnt-livro-sem-moldura>]
#let _livro-sem-moldura() = {
  let atual = here().page()
  let paginas(rotulo) = query(rotulo).map(m => m.location().page())
  atual in paginas(<abnt-livro-sem-moldura>) or (
    (atual + 1) in paginas(<abnt-livro-ini>)
      and atual not in paginas(<abnt-livro-fim>)
      and atual not in paginas(<abnt-livro-ini>)
  )
}

// Abre a proxima folha em pagina FISICA impar (impar: true) ou par (impar: false),
// deixando em branco, e sem cabecalho nem numero, a pagina que sobrar.
#let _livro-abre(impar) = {
  [#metadata(none) <abnt-livro-fim>]
  pagebreak(weak: true, to: if impar { "odd" } else { "even" })
  [#metadata(none) <abnt-livro-ini>]
}
// Quebra de pagina antes de um elemento que abre em impar (em frente-verso) ou so
// em pagina nova (sem frente-verso); os elementos nao terminam com quebra de
// pagina: cada um abre a sua.
#let _abre-impar() = context {
  if _frente-verso.get() { _livro-abre(true) } else { pagebreak(weak: true) }
}

// Primeira pagina com cabecalho e numero (6029 5.1 e 5.3): a seguinte ao sumario;
// sem sumario, a da primeira secao primaria numerada.
#let _livro-primeira-pagina() = {
  let fim = query(<abnt-fim-sumario>)
  if fim.len() > 0 {
    fim.last().location().page() + 1
  } else {
    let textuais = query(heading.where(level: 1)).filter(h => h.numbering != none)
    if textuais.len() > 0 { textuais.first().location().page() } else { none }
  }
}

// Titulo de elemento sem indicativo (listas, sumario, agradecimentos): mesmo tipo da
// secao primaria (14 pt, negrito, centralizado), com os mesmos vaos dos titulos.
#let _livro-titulo(texto) = {
  context v(1.5em * 1.4 + par.spacing, weak: true)
  align(center, text(weight: "bold", size: 14pt, texto))
  v(1.5em * 1.4)
}

// Texto simples de um conteudo (para ordenar termos do indice)
#let _livro-texto(x) = {
  if type(x) == str { x }
  else if type(x) == content {
    if x.has("text") { x.text }
    else if x.has("children") { x.children.map(_livro-texto).join() }
    else if x.has("body") { _livro-texto(x.body) }
    else if x.has("child") { _livro-texto(x.child) }
    else if x.func() == [ ].func() { " " }
    else { "" }
  } else if x == none { "" }
  else { str(x) }
}

// Nome em caixa alta, menos a indicacao de participacao: "SILVA, Ana (org.)"
// (6029 4.2.1.2.1 a). Aceita texto, conteudo ou lista de nomes (um por linha).
#let _livro-nome(a) = {
  if type(a) == array {
    a.map(_livro-nome).join(linebreak())
  } else if type(a) == str {
    let m = a.match(regex("^(.*?)(\s*\([^)]*\))?\s*$"))
    upper(m.captures.at(0)) + if m.captures.at(1) != none { m.captures.at(1) } else { "" }
  } else if a == none {
    none
  } else {
    upper(a)
  }
}

// Edicao: so a partir da 2a (6029 4.2.1.2.1 d). Numero vira "2ª edição"; texto vai
// como foi dado ("2ª edição, revista e ampliada").
#let _livro-edicao(e) = {
  if e == none { none }
  else if type(e) == int { if e > 1 { [#{str(e)}ª edição] } else { none } }
  else if type(e) == str and e.trim() == "" { none }
  else { e }
}

// Volume: "Volume 3"; texto que ja traz a designacao ("Tomo 3") vai como foi dado
#let _livro-volume(v) = {
  if v == none { none }
  else if type(v) == int { [Volume #v] }
  else if type(v) == str and v.match(regex("^[0-9IVXLivxl]+$")) != none { [Volume #v] }
  else { v }
}

// ISBN impresso com o prefixo; vazio ou none nao imprime nada. Lista: um por linha
// (NBR ISO 2108, 6.4). Texto com digito verificador errado e recusado (ISO 2108, 4.2).
#let _livro-isbn(isbn) = {
  if isbn == none or isbn == "" or isbn == () { none }
  else if type(isbn) == array { isbn.map(_livro-isbn).join(linebreak()) }
  else if type(isbn) == str {
    assert(
      validate-isbn(isbn) or validate-isbn10(isbn),
      message: "livro(): ISBN \"" + isbn + "\" inválido (NBR ISO 2108: 13 dígitos com prefixo 978 ou 979, ou 10 dígitos, com dígito verificador correto). Confira o número; para texto livre passe conteúdo, como [em obtenção].",
    )
    display-isbn(isbn)
  }
  else { [ISBN #isbn] }
}

// Titulo e subtitulo diferenciados tipograficamente; o ":" fica colado ao titulo
// (6029 4.2.1.2.1 b)
#let _livro-titulo-sub(titulo, subtitulo, tam-titulo, tam-subtitulo) = {
  let sep = if subtitulo == none { none }
    else if type(titulo) == str and titulo.trim().ends-with(regex("[:?!.]")) { none }
    else { ":" }
  text(weight: "bold", size: tam-titulo)[#upper(titulo)#sep]
  if subtitulo != none {
    linebreak()
    text(size: tam-subtitulo, subtitulo)
  }
}

/// Template principal para livro ou folheto
/// Conforme NBR 6029:2023
///
/// Parametros:
/// - titulo: titulo da obra
/// - subtitulo: subtitulo (opcional)
/// - autor: nome do autor (texto, conteudo ou lista de nomes)
/// - editora: nome da editora
/// - local: cidade de publicacao
/// - ano: ano de publicacao
/// - edicao: numero da edicao (so e impressa a partir da 2a) ou texto
///   completo ("2ª edição, revista e ampliada")
/// - volume: numero do volume (se houver) ou texto ("Tomo 3")
/// - isbn: numero ISBN (texto ou lista de textos)
/// - fonte: fonte a usar
/// - cabecalho: titulo corrente (opcional), so nos elementos textuais (da pagina
///   seguinte ao sumario em diante; nunca na capa, folhas de rosto, paginas em
///   branco nem quarta capa). Conteudo unico: pagina impar a direita e, em
///   frente-verso, pagina par a esquerda. Dicionario `(par: ..., impar: ...)`:
///   um conteudo para cada lado; o valor `auto` e o titulo do capitulo corrente
///   (por exemplo `(par: [Titulo do livro], impar: auto)`). Sem frente-verso so
///   se imprime o texto de `impar` (ou o conteudo unico), a direita
/// - frente-verso: impressao frente-verso (padrao: false). Se true: margens
///   espelhadas, e folha de rosto, dedicatoria, agradecimento, epigrafe,
///   sumario, prefacio/apresentacao, posfacio, glossario e capitulos abrem em
///   pagina impar (a quarta capa, em pagina par); as paginas deixadas em branco
///   nao levam cabecalho nem numero
/// - paginacao: "auto" (padrao, NBR 6029: contagem a partir da primeira folha do
///   miolo -- falsa folha de rosto ou folha de rosto --, numero visivel somente
///   apos o sumario, rodape centralizado), "todas" (visivel desde o inicio do
///   miolo) ou "nenhuma"
/// - enumeracao: "abnt" (padrão: alíneas a), b), c); subalíneas com travessão) ou
///   "latex" (1., a), i), A.)
///
/// Titulo, subtitulo, autor, editora, local, ano, edicao, volume e isbn tambem
/// servem de padrao para `book-cover`, `book-back-cover`, `half-title-page`,
/// `book-title-page` e `book-title-page-verso`: basta nao repeti-los (repetir
/// continua valendo e prevalece). Equacoes em bloco (`$ ... $`) saem numeradas;
/// `@rotulo` de equacao sai "(1)".
#let livro(
  titulo: "",
  subtitulo: none,
  autor: "",
  editora: "",
  local: "",
  ano: datetime.today().year(),
  edicao: none,
  volume: none,
  isbn: none,
  fonte: "Times New Roman",
  cabecalho: none,
  paginacao: "auto",
  frente-verso: false,
  enumeracao: "abnt",
  body,
) = {
  // ISBN invalido da erro ja aqui, mesmo que nenhuma pagina o imprima
  let _ = _livro-isbn(isbn)

  // Configuracao do documento (o titulo do PDF leva o subtitulo)
  set document(
    title: if subtitulo != none and type(titulo) == str and type(subtitulo) == str {
      titulo + ": " + subtitulo
    } else { titulo },
    author: autor,
  )

  show: with-abnt-setup.with(
    fonte: fonte,
    suplemento-nivel1: "Capítulo",
    level-1-pagebreak-impar: frente-verso,
    enumeracao: enumeracao,
  )

  set page(margin: abnt-margens(frente-verso))
  _frente-verso.update(frente-verso)
  _livro-dados.update((
    titulo: titulo,
    subtitulo: subtitulo,
    autor: autor,
    editora: editora,
    local: local,
    ano: ano,
    edicao: edicao,
    volume: volume,
    isbn: isbn,
  ))

  // Numero de pagina automatico (rodape centralizado; local a criterio do projeto
  // grafico); nao sai em pagina marcada como sem moldura (brancas, guardas, quarta capa)
  set page(footer: if paginacao == "nenhuma" { auto } else {
    context {
      if not _livro-sem-moldura() {
        abnt-numero-pagina(paginacao: paginacao, centro: true, apos-sumario: true)
      }
    }
  })

  // Titulo corrente no alto da mancha (livro-especifico), so nos elementos textuais
  set page(
    header: context {
      let primeira = _livro-primeira-pagina()
      let atual = here().page()
      if cabecalho != none and primeira != none and atual >= primeira and not _livro-sem-moldura() {
        // Capitulo corrente: o ultimo titulo primario ate esta pagina; na pagina em que
        // ele abre nao se repete o titulo
        let capitulo = {
          let h = query(heading.where(level: 1)).filter(t => t.location().page() <= atual)
          if h.len() > 0 and h.last().location().page() < atual { h.last().body } else { none }
        }
        let valor(v) = if v == auto { capitulo } else { v }
        let par-c = if type(cabecalho) == dictionary { valor(cabecalho.at("par", default: none)) } else { cabecalho }
        let impar-c = if type(cabecalho) == dictionary { valor(cabecalho.at("impar", default: none)) } else { cabecalho }
        // Frente-verso: pagina par (verso, esquerda) e impar (anverso, direita) pela
        // folha fisica; sem frente-verso nao ha o que alternar
        if frente-verso and calc.even(atual) {
          if par-c != none { align(left, text(size: 10pt, par-c)) }
        } else {
          if impar-c != none { align(right, text(size: 10pt, impar-c)) }
        }
      }
    },
  )

  // Livros usam 14pt para heading level 1 (diferente do padrão 12pt).
  // Capitulos (com numero) abrem em pagina impar em frente-verso; os sem numero
  // (referencias, apendice, anexo, indice) so quebram a pagina: as funcoes de
  // prefacio, posfacio e glossario abrem em impar por conta propria.
  show heading.where(level: 1): it => {
    if it.numbering != none { _abre-impar() }
    pagebreak(weak: true)
    context v(1.5em + par.spacing, weak: true)
    let titulo = text(weight: "bold", size: 14pt, _abnt-titulo(it, caixa-alta: true))
    if it.numbering == none { align(center, titulo) } else { titulo }
    v(1.5em)
  }

  // Parte (ver `parte()`): igual a do setup, mas a pagina em branco anterior (em
  // frente-verso) fica sem cabecalho nem numero
  show figure.where(kind: "parte"): it => {
    _abre-impar()
    v(1fr)
    align(center, text(size: 16pt, weight: "bold", upper(it.supplement + [ ] + it.counter.display("1") + [: ] + it.caption.body)))
    v(1fr)
  }

  // Equacoes em bloco numeradas, "(1)" a direita (6029 5.7); @rotulo sai "(1)"
  set math.equation(numbering: "(1)")
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation and el.numbering != none and it.supplement == auto {
      context link(el.location(), numbering(el.numbering, ..counter(math.equation).at(el.location())))
    } else { it }
  }

  body
}

/// Primeira capa do livro
/// Conforme NBR 6029:2023 - deve conter:
/// - Nome do autor
/// - Titulo e subtitulo por extenso
/// - Nome da editora e/ou logomarca
/// - Recomenda-se: edicao, local e ano
///
/// Parametros (os que ficarem de fora usam o que foi dado a `livro()`):
/// - autor: nome do autor
/// - titulo: titulo da obra
/// - subtitulo: subtitulo (opcional)
/// - editora: nome da editora
/// - logo-editora: logomarca da editora (opcional)
/// - edicao: numero da edicao (so a partir da 2a) ou texto
/// - local: cidade (opcional)
/// - ano: ano (opcional)
#let book-cover(
  autor: auto,
  titulo: auto,
  subtitulo: auto,
  editora: auto,
  logo-editora: none,
  edicao: auto,
  local: auto,
  ano: auto,
) = context {
  let autor = _livro-dado("autor", autor)
  let titulo = _livro-dado("titulo", titulo)
  let subtitulo = _livro-dado("subtitulo", subtitulo)
  let editora = _livro-dado("editora", editora)
  let edicao = _livro-edicao(_livro-dado("edicao", edicao))
  let local = _livro-dado("local", local)
  let ano = _livro-dado("ano", ano)

  pagebreak(weak: true)
  set page(numbering: none)
  set align(center)
  // Titulo longo nao e justificado nem hifenizado
  set par(justify: false)
  set text(hyphenate: false)
  _livro-marca-sem-moldura()

  v(2cm)

  // Autor
  text(size: 14pt, _livro-nome(autor))

  v(1fr)

  // Titulo e subtitulo
  _livro-titulo-sub(titulo, subtitulo, 18pt, 14pt)

  v(1fr)

  // Edicao
  if edicao != none {
    text(size: 12pt, edicao)
    v(0.5em)
  }

  // Editora
  if logo-editora != none {
    logo-editora
    v(0.5em)
  }
  text(size: 12pt, editora)

  v(1em)

  // Local e ano
  if local != none and local != "" {
    text(size: 12pt, local)
    linebreak()
  }
  if ano != none {
    text(size: 12pt, str(ano))
  }

  v(2cm)
}

/// Folha de guarda (NBR 6029, 4.1.3: obrigatoria em capa dura)
/// Uma pagina sem cabecalho nem numero, em branco ou com `conteudo`.
#let book-guarda(conteudo: none) = {
  pagebreak(weak: true)
  _livro-marca-sem-moldura()
  if conteudo != none { conteudo }
  pagebreak()
}

/// Orelha (NBR 6029, 4.1.5; elemento opcional)
/// Uma pagina estreita (a largura da orelha), sem cabecalho nem numero, com o que a norma
/// recomenda: dados biograficos do autor e comentario sobre a obra; podem constar o
/// publico a que se destina e outras informacoes. Chame uma vez por orelha.
///
/// A sobrecapa (4.1.1) e feita de primeira capa, quarta capa e orelhas: componha-a com
/// `book-cover()`, `book-orelha()` e `book-back-cover()`, na ordem da sua grafica.
///
/// Parametros:
/// - biografia: dados biograficos do autor
/// - comentario: comentario sobre a obra
/// - publico: publico a que se destina
/// - outros: outras informacoes
/// - largura: largura da orelha (padrao 9 cm); a altura e a da pagina do livro
#let book-orelha(biografia: none, comentario: none, publico: none, outros: none, largura: 9cm) = {
  set page(width: largura, margin: (x: 1cm, y: 2cm), numbering: none)
  _livro-marca-sem-moldura()
  set par(justify: false, first-line-indent: 0pt, spacing: 1em)
  set text(size: 10pt)
  let partes = (biografia, comentario, publico, outros).filter(p => p != none)
  partes.join(v(1em))
  pagebreak(weak: true)
}

/// Quarta capa (contracapa)
/// Conforme NBR 6029:2023 - deve conter:
/// - ISBN (obrigatorio)
/// - Codigo de barras (se houver)
/// - Pode conter: resumo e endereco da editora
///
/// Coloque no FIM do documento: abre uma pagina par (em frente-verso), sem
/// cabecalho nem numero.
///
/// Parametros:
/// - isbn: numero ISBN (o de `livro()` se nao for dado; nada e impresso se vazio)
/// - codigo-barras: codigo de barras (imagem, opcional)
/// - resumo: resumo do conteudo (opcional)
/// - endereco-editora: endereco da editora (opcional)
#let book-back-cover(
  isbn: auto,
  codigo-barras: none,
  resumo: none,
  endereco-editora: none,
) = context {
  let isbn = _livro-isbn(_livro-dado("isbn", isbn))

  if _frente-verso.get() { _livro-abre(false) } else { pagebreak(weak: true) }
  set page(numbering: none)
  _livro-marca-sem-moldura()

  v(1fr)

  // Resumo
  if resumo != none {
    set par(first-line-indent: 0pt)
    resumo
    v(2em)
  }

  // Endereco da editora
  if endereco-editora != none {
    set text(size: 10pt)
    endereco-editora
    v(2em)
  }

  v(1fr)

  // ISBN e codigo de barras
  if isbn != none {
    align(left)[
      #text(size: 10pt, isbn)
    ]
  }

  if codigo-barras != none {
    v(0.5em)
    codigo-barras
  }
}

/// Falsa folha de rosto (opcional)
/// Apenas o titulo da obra; `serie` (opcional) vai no verso (4.2.1.1 b)
///
/// Parametros:
/// - titulo: titulo (o de `livro()` se nao for dado)
/// - serie: nome da serie ou colecao, com numero, para o verso (opcional)
#let half-title-page(titulo: auto, serie: none) = context {
  let titulo = _livro-dado("titulo", titulo)
  _abre-impar()
  set page(numbering: none)
  marcar-folha-rosto(primeiro: true)
  set align(center)
  set par(justify: false)
  set text(hyphenate: false)

  v(1fr)
  text(size: 14pt, titulo)
  v(1fr)

  // Verso: serie ou colecao
  if serie != none {
    pagebreak(weak: true)
    set align(left)
    set text(size: 10pt)
    set par(first-line-indent: 0pt, justify: false)
    serie
  }
}

/// Folha de rosto - anverso
/// Conforme NBR 6029:2023 - elementos na ordem:
/// a) Autor
/// b) Titulo e subtitulo
/// c) Outros colaboradores
/// d) Indicacao de edicao (a partir da 2a)
/// e) Numeracao do volume
/// f) Editora
/// g) Local de publicacao
/// h) Ano de publicacao
///
/// Parametros (os que ficarem de fora usam o que foi dado a `livro()`):
/// - autor: nome do autor; participacao entre parenteses ("Ana Lima (org.)")
///   nao sai em caixa alta; lista de nomes: um por linha
/// - titulo: titulo
/// - subtitulo: subtitulo (opcional)
/// - colaboradores: outros colaboradores (tradutor, ilustrador, etc.)
/// - edicao: numero da edicao (a partir da 2a) ou texto
/// - volume: numero do volume (se houver) ou texto ("Tomo 3")
/// - editora: editora
/// - local: cidade
/// - ano: ano
#let book-title-page(
  autor: auto,
  titulo: auto,
  subtitulo: auto,
  colaboradores: none,
  edicao: auto,
  volume: auto,
  editora: auto,
  local: auto,
  ano: auto,
) = context {
  let autor = _livro-dado("autor", autor)
  let titulo = _livro-dado("titulo", titulo)
  let subtitulo = _livro-dado("subtitulo", subtitulo)
  let edicao = _livro-edicao(_livro-dado("edicao", edicao))
  let volume = _livro-volume(_livro-dado("volume", volume))
  let editora = _livro-dado("editora", editora)
  let local = _livro-dado("local", local)
  let ano = _livro-dado("ano", ano)

  _abre-impar()
  set page(numbering: none)
  marcar-folha-rosto(primeiro: true)
  set align(center)
  // Titulo longo nao e justificado nem hifenizado
  set par(justify: false)
  set text(hyphenate: false)

  // Autor
  text(size: 12pt, _livro-nome(autor))

  v(1fr)

  // Titulo e subtitulo (diferenciados tipograficamente)
  _livro-titulo-sub(titulo, subtitulo, 16pt, 14pt)

  v(1em)

  // Colaboradores
  if colaboradores != none {
    set text(size: 11pt)
    colaboradores
  }

  v(1em)

  // Edicao
  if edicao != none {
    text(size: 11pt, edicao)
    v(0.5em)
  }

  // Volume
  if volume != none {
    text(size: 11pt, volume)
  }

  v(1fr)

  // Editora
  text(size: 12pt, editora)

  v(0.5em)

  // Local
  text(size: 12pt, local)

  // Ano
  if ano != none {
    linebreak()
    text(size: 12pt, str(ano))
  }
}

/// Folha de rosto - verso
/// Conforme NBR 6029:2023 - deve conter:
/// a) Direito autoral
/// b) Direito de reproducao
/// c) Titulo original (se traducao)
/// d) Outros suportes disponiveis
/// e) Creditos
/// f) Ficha catalografica + nome e CRB do bibliotecario
/// g) Dados da editora
/// Tambem: ISBN (NBR ISO 2108, 6.2.1) e licenca (Creative Commons).
///
/// Parametros:
/// - ano-copyright: ano do copyright
/// - detentor-copyright: detentor dos direitos (com so um dos dois, sai "© ano"
///   ou "© detentor")
/// - licenca: simbolo e explicacao de licenca (ex.: Creative Commons), opcional
/// - titulo-original: titulo original (se traducao)
/// - direitos-reproducao: texto sobre direito de reproducao
/// - outros-formatos: outros suportes disponiveis
/// - creditos: creditos diversos
/// - isbn: ISBN (o de `livro()` se nao for dado; nada e impresso se vazio)
/// - ficha-catalografica: conteudo da ficha catalografica
/// - bibliotecario: nome e CRB do bibliotecario (impresso abaixo da ficha)
/// - dados-editora: dados da editora
#let book-title-page-verso(
  ano-copyright: none,
  detentor-copyright: none,
  licenca: none,
  titulo-original: none,
  direitos-reproducao: none,
  outros-formatos: none,
  creditos: none,
  isbn: auto,
  ficha-catalografica: none,
  bibliotecario: none,
  dados-editora: none,
) = context {
  let isbn = _livro-isbn(_livro-dado("isbn", isbn))

  pagebreak(weak: true)
  set page(numbering: none)
  set text(size: 10pt)
  set par(first-line-indent: 0pt, leading: abnt-leading(1), spacing: abnt-leading(1))

  // Copyright
  if ano-copyright != none or detentor-copyright != none {
    [© #ano-copyright #detentor-copyright]
    v(1em)
  }

  // Licenca
  if licenca != none {
    licenca
    v(1em)
  }

  // Direito de reproducao
  if direitos-reproducao != none {
    direitos-reproducao
    v(1em)
  }

  // Titulo original
  if titulo-original != none {
    [Título original: #emph[#titulo-original]]
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

  // ISBN
  if isbn != none {
    isbn
    v(1em)
  }

  v(1fr)

  // Ficha catalografica (parte inferior)
  if ficha-catalografica != none {
    align(center)[
      #box(
        width: 12.5cm,
        height: auto,
        stroke: 0.5pt,
        inset: 0.5cm,
      )[
        #ficha-catalografica
      ]
    ]
    v(0.5em)
  }

  // Nome e CRB do bibliotecario: abaixo da ficha, fora da moldura
  if bibliotecario != none {
    align(center, text(size: 9pt, bibliotecario))
    v(1em)
  }

  // Dados da editora
  if dados-editora != none {
    align(center)[
      #text(size: 9pt, dados-editora)
    ]
  }
}

/// Errata (NBR 6029, 4.2.1.3)
/// Tabela de erros e correcoes; vai logo apos a folha de rosto.
///
/// Parametros:
/// - referencia: referencia da publicacao (opcional)
/// - itens: lista de dicionarios `(pagina: .., linha: .., errado: .., correto: ..)`
#let book-errata(referencia: none, itens: ()) = {
  _abre-impar()
  _livro-titulo("ERRATA")

  if referencia != none {
    set par(first-line-indent: 0pt)
    referencia
    v(1em)
  }

  if itens.len() > 0 {
    set par(first-line-indent: 0pt, justify: false)
    set text(size: 11pt)
    table(
      columns: (auto, auto, 1fr, 1fr),
      stroke: 0.5pt,
      inset: 6pt,
      align: left,
      [*Folha*], [*Linha*], [*Onde se lê*], [*Leia-se*],
      ..itens.map(i => (str(i.pagina), str(i.linha), i.errado, i.correto)).flatten(),
    )
  }
}

/// Dedicatoria
/// Conforme NBR 6029:2023 - pagina impar
#let book-dedication(conteudo) = {
  _abre-impar()
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      #set text(size: 11pt)
      #conteudo
    ]
  ]
}

/// Agradecimentos
/// Conforme NBR 6029:2023 - pagina impar
#let book-acknowledgments(conteudo) = {
  _abre-impar()
  _livro-titulo("AGRADECIMENTOS")
  conteudo
}

/// Epigrafe
/// Conforme NBR 6029:2023 - pagina impar
///
/// A referencia da epigrafe vai em NOTA DE RODAPE (4.2.1.6): `autor` recebe a
/// referencia (NBR 6023) ou so o nome do autor.
///
/// Parametros:
/// - citacao: texto da epigrafe
/// - autor: referencia (ou autor) da epigrafe
/// - em-nota: true (padrao) poe `autor` em nota de rodapé; false imprime
///   "(autor)" ao lado da citacao (forma antiga, para autor simples)
#let book-epigraph(citacao, autor, em-nota: true) = {
  _abre-impar()
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      #set text(size: 11pt, style: "italic")
      \u{201C}#citacao\u{201D}#if em-nota { footnote(autor) } else {
        linebreak()
        set text(style: "normal")
        [(#autor)]
      }
    ]
  ]
}

// Lista de figuras de um ou mais tipos: nao sai se estiver vazia (4.2.1.7)
#let _livro-lista(titulo, alvo) = context {
  if query(alvo).len() > 0 {
    pagebreak(weak: true)
    _livro-titulo(titulo)
    show: _abnt-lista-rules
    outline(title: none, target: alvo)
  }
}

/// Lista de ilustracoes
/// Conforme NBR 6029:2023 - ordem de apresentacao
/// Formato: nome especifico + travessao + titulo + pagina
/// Nao sai se nao houver ilustracoes.
///
/// - tipo: tipo (kind) das ilustracoes; padrao `image`. Aceita o tipo de um
///   `container(tipo: ...)` ou uma lista deles. A numeracao e por tipo: para
///   "Mapa 1", "Gráfico 1", "Mapa 2" use tipos proprios
///   (`container(tipo: "mapa", suplemento: "Mapa")`) e uma lista para cada um:
///   `#book-list-illustrations(tipo: "mapa", titulo: "LISTA DE MAPAS")`
/// - titulo: titulo da lista
#let book-list-illustrations(tipo: image, titulo: "LISTA DE ILUSTRAÇÕES") = {
  let tipos = if type(tipo) == array { tipo } else { (tipo,) }
  let alvo = tipos
    .map(k => selector(figure.where(kind: if k == "imagem" { image } else if k == "tabela" { table } else { k })))
    .reduce((a, b) => a.or(b))
  _livro-lista(titulo, alvo)
}

/// Lista de tabelas (nao sai se nao houver tabelas)
#let book-list-tables() = _livro-lista("LISTA DE TABELAS", figure.where(kind: table))

/// Lista de quadros (nao sai se nao houver quadros)
/// Quadros: `container(tipo: "quadro", ...)`
#let book-list-quadros() = _livro-lista("LISTA DE QUADROS", figure.where(kind: "quadro"))

// Lista de pares (sigla/simbolo, significado) em duas colunas alinhadas, com a
// definicao em recuo deslocado; nao sai se estiver vazia
#let _livro-lista-pares(titulo, items, ordenar) = {
  let pares = if type(items) == dictionary { items.pairs() } else { items }
  if pares.len() > 0 {
    pagebreak(weak: true)
    _livro-titulo(titulo)

    set par(first-line-indent: 0pt, justify: false, leading: abnt-leading(1), spacing: abnt-leading(1.5))

    let pares = if ordenar {
      pares.sorted(key: p => sort-key(_livro-texto(p.at(0)), ignore-articles: false))
    } else { pares }
    context {
      let largura = (calc.max(..pares.map(p => measure(p.at(0)).width)) + 1em).to-absolute()
      for (chave, valor) in pares {
        par(hanging-indent: largura)[#box(width: largura, chave)#valor]
      }
    }
  }
}

/// Lista de abreviaturas e siglas
/// Conforme NBR 6029:2023 - ordem alfabetica; sigla e significado em colunas
/// alinhadas. Nao sai se estiver vazia.
/// - items: dicionario sigla -> significado (ou lista de pares)
#let book-list-abbreviations(items) = _livro-lista-pares("LISTA DE ABREVIATURAS E SIGLAS", items, true)

/// Lista de simbolos
/// Conforme NBR 6029:2023 - ordem de apresentacao. Nao sai se estiver vazia.
/// - items: dicionario simbolo -> significado (ou lista de pares)
#let book-list-symbols(items) = _livro-lista-pares("LISTA DE SÍMBOLOS", items, false)

/// Sumario do livro
/// Conforme NBR 6027: abre no anverso (pagina impar, em frente-verso), titulo
/// com o mesmo tipo da secao primaria e entradas destacadas por nivel.
#let book-toc(
  titulo: "SUMÁRIO",
  profundidade: 3,
) = {
  _abre-impar()
  pagebreak(weak: true)
  _livro-titulo(titulo)

  show: _abnt-outline-rules.with(profundidade: profundidade)

  outline(
    title: none,
    target: selector(heading).or(figure.where(kind: "parte")),
    depth: profundidade,
    indent: 0pt,
  )
  [#box(width: 0pt, height: 0pt) <abnt-fim-sumario>]
}

/// Prefacio ou apresentacao
/// Conforme NBR 6029:2023 - pagina impar, sem indicativo de secao
/// Em novas edicoes: prefacio novo precede os anteriores
#let book-preface(titulo: "PREFÁCIO", conteudo) = {
  _abre-impar()
  heading(level: 1, numbering: none, upper(titulo))
  conteudo
}

/// Apresentacao
#let book-presentation(conteudo) = {
  book-preface(titulo: "APRESENTAÇÃO", conteudo)
}

/// Posfacio
/// Conforme NBR 6029:2023 - elemento pos-textual opcional
#let book-postface(conteudo) = {
  _abre-impar()
  heading(level: 1, numbering: none, "POSFÁCIO")
  conteudo
}

/// Glossario
/// Conforme NBR 6029:2023 - elemento pos-textual opcional
/// - items: dicionario termo -> definicao
#let book-glossary(items) = {
  _abre-impar()
  heading(level: 1, numbering: none, "GLOSSÁRIO")

  set par(first-line-indent: 0pt)

  let sorted-keys = items.keys().sorted(key: sort-key)
  for key in sorted-keys {
    [*#key:* #items.at(key) \ ]
    v(0.5em)
  }
}

/// Apendice
/// Conforme NBR 6029:2023 - identificacao: termo + travessao + titulo
/// Multiplos: letras maiusculas consecutivas (A, B, C...); `letra: none` para
/// apendice unico ("APÊNDICE – TÍTULO")
/// - rotulo: texto de um rotulo para citar com `@` ("Apêndice A"); como
///   `book-appendix(rotulo: "ap-a", ...)` e `@ap-a`
#let book-appendix(letra: "A", titulo: "", rotulo: none, body) = {
  let titulo-h = heading(level: 1, numbering: none, supplement: if letra != none { [Apêndice #letra] } else { [Apêndice] })[APÊNDICE #letra -- #titulo]
  if rotulo != none { [#titulo-h#label(rotulo)] } else { titulo-h }
  // Subdivisoes sem numero: nao continuam a numeracao do ultimo capitulo
  set heading(numbering: none)
  body
}

/// Anexo
/// Conforme NBR 6029:2023 - identificacao: termo + travessao + titulo
/// Multiplos: letras maiusculas consecutivas (A, B, C...); `letra: none` para
/// anexo unico
/// - rotulo: como em `book-appendix`
#let book-annex(letra: "A", titulo: "", rotulo: none, body) = {
  let titulo-h = heading(level: 1, numbering: none, supplement: if letra != none { [Anexo #letra] } else { [Anexo] })[ANEXO #letra -- #titulo]
  if rotulo != none { [#titulo-h#label(rotulo)] } else { titulo-h }
  // Subdivisoes sem numero: nao continuam a numeracao do ultimo capitulo
  set heading(numbering: none)
  body
}

/// Indice remissivo
/// Conforme NBR 6034 - no final da publicacao
///
/// Dois modos:
/// - sem entradas: `#book-index()` imprime o indice montado pelos `idx()` do texto
///   (paginas automaticas; ver `indice()`);
/// - com entradas: `#book-index(((termo, paginas), ...))` (termo e paginas em
///   texto ou conteudo; as paginas sao digitadas), ordenado pela NBR 6033.
///
/// - canto: `"letras"` ou `"entradas"` imprime no canto superior externo de cada pagina as
///   letras iniciais ou a primeira e a ultima entradas (6034, 6.5); so no modo automatico
#let book-index(titulo: "ÍNDICE", canto: none, ..entradas) = {
  let entries = if entradas.pos().len() > 0 { entradas.pos().first() }
    else { entradas.named().at("entries", default: none) }

  // `canto:` (6034, 6.5; so no indice automatico) abre pagina nova: vem antes do titulo
  show: body => if canto != none and entries == none {
    set page(foreground: _indice-canto(canto))
    body
  } else { body }

  heading(level: 1, numbering: none, upper(titulo))

  if entries == none {
    // Entradas em espaco simples (6034 nao pede 1,5)
    set par(leading: abnt-leading(1), spacing: abnt-leading(1))
    indice(titulo: none)
  } else {
    set par(first-line-indent: 0pt)
    set text(size: 10pt)

    let pares = if type(entries) == dictionary { entries.pairs() } else { entries }

    // Organizar por letra inicial (a ordem vem da chave de ordenacao)
    let by-letter = (:)
    for (term, pages) in pares {
      let chave = _livro-texto(term)
      let letter = sort-initial(chave)
      if letter not in by-letter {
        by-letter.insert(letter, ())
      }
      by-letter.at(letter).push((term, pages, chave))
    }

    for letter in by-letter.keys().sorted() {
      text(weight: "bold", size: 11pt, if letter == "" { "#" } else { letter })
      linebreak()
      for (term, pages, _) in by-letter.at(letter).sorted(key: e => sort-key(e.at(2))) {
        [#term #box(width: 1fr, repeat[.]) #pages \ ]
      }
      v(0.5em)
    }
  }
}

/// Colofao
/// Conforme NBR 6029:2023 - ultima folha do miolo
/// Especificacoes graficas da publicacao
#let book-colophon(conteudo) = {
  pagebreak(weak: true)
  v(1fr)
  set text(size: 10pt)
  set par(first-line-indent: 0pt)
  align(center)[
    #conteudo
  ]
}

/// Mantida por compatibilidade: nao faz nada.
/// A numeracao (NBR 6029:2023: folhas iniciais contadas e nao numeradas, numero
/// visivel apos o Sumario) ja e automatica; ver o parametro `paginacao` de `livro()`.
#let book-start-numbering() = {}

/// Equacoes e formulas
/// Conforme NBR 6029:2023 - numeradas com algarismos arabicos entre parenteses
/// (`livro()` ja numera as equacoes em bloco; esta funcao continua valendo)
#let book-equation(body) = {
  set math.equation(numbering: "(1)")
  body
}
