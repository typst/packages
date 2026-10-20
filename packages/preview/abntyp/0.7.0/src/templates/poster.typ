// Template para Poster Tecnico e Cientifico conforme NBR 15437:2006
//
// Estrutura:
// - Titulo (obrigatorio) - parte superior
// - Subtitulo (opcional) - diferenciado tipograficamente ou separado por :
// - Autor (obrigatorio) - logo abaixo do titulo
// - Informacoes complementares (opcional) - instituicao, cidade, estado, pais, etc.
// - Resumo (opcional) - ate 100 palavras, seguido de palavras-chave
// - Conteudo (obrigatorio) - ideias centrais em texto/tabelas/ilustracoes
// - Referencias (opcional) - conforme NBR 6023
//
// Dimensoes recomendadas:
// - Largura: 0,60m a 0,90m
// - Altura: 0,90m a 1,20m
//
// O poster deve ser legivel a pelo menos 1 metro de distancia

// ---------------------------------------------------------------------------
// Apoio interno
// ---------------------------------------------------------------------------

// Cor de destaque do pôster: `poster()` e `academic-poster()` gravam aqui e
// `poster-section` e `poster-highlight` a usam quando não recebem `cor-destaque`.
#let _poster-cor = state("abnt-poster-cor", rgb("#003366"))

// Menor tamanho de letra do pôster (texto secundário: afiliação, contato, referências)
#let _poster-piso(tamanho) = calc.max(20pt, tamanho)

// `none` -> (); lista -> ela mesma; valor único (string, dicionário) -> lista de um item
#let _poster-lista(x) = if x == none { () } else if type(x) == array { x } else { (x,) }

// Nome do autor (texto, ou dicionário com name/nome)
#let _poster-nome(a) = if type(a) == dictionary {
  if "name" in a { a.name } else if "nome" in a { a.nome } else {
    panic("autores: falta a chave \"name\" (ou \"nome\") em " + repr(a))
  }
} else { a }

// Afiliação do autor (dicionário com affiliation/afiliacao) ou none
#let _poster-afiliacao(a) = if type(a) == dictionary {
  a.at("affiliation", default: a.at("afiliacao", default: none))
} else { none }

// Texto preto ou branco, o que contrasta com a cor dada
#let _poster-contraste(cor) = {
  let (r, g, b) = rgb(cor).components(alpha: false)
  let luz = 0.2126 * (r / 100%) + 0.7152 * (g / 100%) + 0.0722 * (b / 100%)
  if luz > 0.6 { black } else { white }
}

// Configuração comum de `poster()` e `academic-poster()`: documento, página,
// texto, parágrafo, títulos e legendas. Usada como `show: _poster-base.with(...)`.
#let _poster-base(
  titulo,
  autores,
  largura,
  altura,
  fundo,
  fonte,
  tamanho-corpo,
  cor-destaque,
  cor-texto,
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: if autores.len() > 0 { autores.map(_poster-nome).join(", ") } else { () },
  )

  // Configuracao de pagina para poster
  set page(
    width: largura,
    height: altura,
    margin: 2cm,
    fill: fundo,
  )

  // Configuracao de fonte
  set text(
    font: fonte,
    size: tamanho-corpo,
    fill: cor-texto,
    lang: "pt",
    region: "BR",
  )

  // Configuracao de paragrafo
  set par(
    leading: 1.2em,
    justify: true,
    first-line-indent: 0pt,
  )

  // Ilustrações e tabelas: identificação em cima, "Figura 1 – Título" (NBR 15437 4.6)
  set figure.caption(position: top, separator: [ – ])

  // Configuracao de headings para poster
  show heading.where(level: 1): it => {
    v(0.5em)
    text(
      weight: "bold",
      size: tamanho-corpo * 1.5,
      fill: cor-destaque,
      upper(it.body),
    )
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    v(0.3em)
    text(
      weight: "bold",
      size: tamanho-corpo * 1.2,
      it.body,
    )
    v(0.3em)
  }

  _poster-cor.update(cor-destaque)

  body
}

// Título e subtítulo: o título leva os dois pontos e o subtítulo vem na linha
// seguinte, em tamanho menor (NBR 15437 4.2: diferenciado tipograficamente ou
// separado por dois pontos)
#let _poster-titulo(titulo, subtitulo, tamanho, cor) = {
  text(weight: "bold", size: tamanho, fill: cor)[#upper(titulo)#if subtitulo != none [:]]
  if subtitulo != none {
    linebreak()
    text(size: tamanho * 0.6)[#subtitulo]
  }
}

// Autores (em negrito, separados por vírgula) e, abaixo, as afiliações: cada
// instituição distinta recebe um número, na ordem em que aparece, e o autor leva
// o número da sua
#let _poster-autores(autores, tam-autor, tam-afiliacao) = {
  if autores.len() == 0 { return }
  let afiliacoes = ()
  for a in autores {
    let af = _poster-afiliacao(a)
    if af != none and af not in afiliacoes { afiliacoes.push(af) }
  }
  text(size: tam-autor)[
    #autores.map(a => {
      text(weight: "bold", _poster-nome(a))
      let af = _poster-afiliacao(a)
      if af != none { super(str(afiliacoes.position(x => x == af) + 1)) }
    }).join[, ]
  ]
  if afiliacoes.len() > 0 {
    linebreak()
    v(0.5cm)
    text(size: tam-afiliacao)[
      #for (i, af) in afiliacoes.enumerate() {
        super(str(i + 1))
        af
        linebreak()
      }
    ]
  }
}

// Cabeçalho (centralizado, sem justificar nem hifenizar): título, autores,
// orientador, instituição, departamento e contato. Textos secundários não ficam
// abaixo de 20 pt (NBR 15437 5.3: legível a 1 m).
#let _poster-cabecalho(
  titulo,
  subtitulo,
  autores,
  orientador,
  instituicao,
  departamento,
  contato,
  tamanho-corpo,
  tamanho-titulo,
  cor-destaque,
) = {
  set par(justify: false)
  set text(hyphenate: false)

  _poster-titulo(titulo, subtitulo, tamanho-titulo, cor-destaque)

  v(1cm)

  _poster-autores(autores, tamanho-corpo * 1.3, _poster-piso(tamanho-corpo * 0.9))

  if orientador != none {
    linebreak()
    text(size: tamanho-corpo)[Orientador: #orientador]
  }

  if instituicao != none {
    v(0.3cm)
    text(size: tamanho-corpo, instituicao)
  }

  if departamento != none {
    linebreak()
    text(size: _poster-piso(tamanho-corpo * 0.9), departamento)
  }

  if contato != none {
    linebreak()
    text(size: _poster-piso(tamanho-corpo * 0.8), contato)
  }
}

// Resumo em caixa (texto sempre escuro: o fundo da caixa é claro) e
// palavras-chave separadas por "; " e finalizadas por ponto
#let _poster-resumo(texto-resumo, palavras-chave, cor-destaque, tamanho-corpo) = {
  if texto-resumo != none {
    box(
      width: 100%,
      inset: 1em,
      fill: cor-destaque.lighten(90%),
      radius: 5pt,
    )[
      #set text(fill: black)
      #text(weight: "bold", size: tamanho-corpo * 1.1)[RESUMO]
      #linebreak()
      #v(0.3em)
      #texto-resumo
      #if palavras-chave.len() > 0 {
        v(0.5em)
        text(weight: "bold")[Palavras-chave: ]
        [#palavras-chave.join("; ").]
      }
    ]
    v(1cm)
  }
}

// Conteúdo em colunas. O Typst enche a 1ª coluna até o fim da página antes de
// passar à 2ª; com `equilibrar`, a altura das colunas é a do conteúdo dividida
// pelo número de colunas (medida com `measure`), mais uma folga de 4 linhas, e
// o conteúdo se reparte por igual (as seções partem entre colunas). Se esse
// conteúdo não cabe na página, as colunas seguem o enchimento normal.
#let _poster-colunas(num-colunas, equilibrar, tamanho-corpo, body) = {
  let gutter = 2 * tamanho-corpo
  if num-colunas == 1 or not equilibrar {
    return columns(num-colunas, gutter: gutter, body)
  }
  layout(size => {
    let largura = (size.width - (num-colunas - 1) * gutter) / num-colunas
    let h = measure(width: largura, body).height / num-colunas + 4 * 1.2 * tamanho-corpo
    if h >= size.height {
      columns(num-colunas, gutter: gutter, body)
    } else {
      block(width: 100%, height: h, breakable: false, columns(num-colunas, gutter: gutter, body))
    }
  })
}

// Logotipo reduzido, se preciso, para caber em `largura` x `altura` (mantém a proporção)
#let _poster-logo(logo, largura, altura) = layout(_ => {
  let m = measure(logo)
  let k = calc.min(1, largura / m.width, altura / m.height)
  scale(k * 100%, reflow: true, logo)
})

/// Template principal para Poster Cientifico conforme NBR 15437:2006
///
/// O pôster é UMA folha: o conteúdo que passar da altura vira uma segunda página,
/// sem aviso (ajuste `tamanho-corpo`, `num-colunas` ou o texto).
///
/// Parametros:
/// - titulo: titulo do poster (obrigatorio; NBR 15437 4.1). Sai em maiúsculas,
///   centralizado, sem justificar nem hifenizar
/// - subtitulo: subtitulo (opcional); vai na linha seguinte ao título, que leva
///   os dois pontos
/// - autores: lista de autores (obrigatorios pela NBR 15437 4.3); cada um é um
///   texto ou um dicionário `(name: "...", affiliation: "...")`. Um autor só
///   pode ser passado sem lista. As afiliações saem numeradas por instituição
///   distinta
/// - instituicao: instituicao principal
/// - contato: informacoes de contato (email, endereco)
/// - texto-resumo: resumo (ate 100 palavras, NBR 15437 4.5: o template não conta)
/// - palavras-chave: palavras-chave (lista ou um texto só); saem separadas por
///   "; " e finalizadas por ponto
/// - num-colunas: numero de colunas para o conteudo (padrao: 3)
/// - equilibrar-colunas: se true (padrão), reparte o conteúdo por igual entre as
///   colunas; com false, a 1ª coluna enche até o fim da página (use `colbreak()`
///   para escolher onde a coluna muda)
/// - largura: largura do poster (padrao: 90cm; a NBR 15437 5.2 pede 60 a 90 cm)
/// - altura: altura do poster (padrao: 120cm; a NBR 15437 5.2 pede 90 a 120 cm)
/// - fonte: fonte a usar
/// - tamanho-titulo: tamanho da fonte do titulo (padrao: 72pt)
/// - tamanho-corpo: tamanho da fonte do corpo (padrao: 24pt). Afiliação, contato
///   e referências nunca ficam abaixo de 20 pt (legível a 1 m, NBR 15437 5.3)
/// - fundo: cor de fundo (opcional)
/// - cor-texto: cor do texto corrido (padrão: preto); com fundo escuro use um tom
///   claro. A caixa do resumo e `poster-highlight` têm fundo claro e texto preto
/// - cor-destaque: cor de destaque (opcional); `poster-section` e `poster-highlight`
///   a herdam
#let poster(
  titulo: "",
  subtitulo: none,
  autores: (),
  instituicao: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 3,
  equilibrar-colunas: true,
  largura: 90cm,
  altura: 120cm,
  fonte: "Arial",
  tamanho-titulo: 72pt,
  tamanho-corpo: 24pt,
  fundo: white,
  cor-texto: black,
  cor-destaque: rgb("#003366"),
  body,
) = {
  assert(
    titulo != "" and titulo != none,
    message: "poster(): informe o titulo (NBR 15437 4.1: o título é obrigatório)",
  )
  let autores = _poster-lista(autores)
  let palavras-chave = _poster-lista(palavras-chave).flatten()

  show: _poster-base.with(
    titulo, autores, largura, altura, fundo, fonte, tamanho-corpo, cor-destaque, cor-texto,
  )

  // Cabecalho do poster (titulo, autores, instituicao)
  align(center, _poster-cabecalho(
    titulo, subtitulo, autores, none, instituicao, none, contato,
    tamanho-corpo, tamanho-titulo, cor-destaque,
  ))

  v(1cm)

  // Linha divisoria
  line(length: 100%, stroke: 2pt + cor-destaque)

  v(1cm)

  // Resumo (se fornecido)
  _poster-resumo(texto-resumo, palavras-chave, cor-destaque, tamanho-corpo)

  // Conteudo em colunas
  _poster-colunas(num-colunas, equilibrar-colunas, tamanho-corpo, body)
}

/// Secao de poster com caixa colorida
/// - titulo: título da seção (letras brancas ou pretas, conforme a cor)
/// - cor-destaque: cor da caixa; sem ela, vale a de `poster()` ou
///   `academic-poster()`
#let poster-section(
  titulo: none,
  cor-destaque: auto,
  body,
) = context {
  let cor = if cor-destaque == auto { _poster-cor.get() } else { cor-destaque }
  block(
    width: 100%,
    inset: 1em,
    stroke: 2pt + cor,
    radius: 5pt,
  )[
    #if titulo != none {
      align(center)[
        #box(
          fill: cor,
          inset: 0.5em,
          radius: 3pt,
        )[
          #text(weight: "bold", fill: _poster-contraste(cor), upper(titulo))
        ]
      ]
      v(0.5em)
    }
    #body
  ]
  v(1em)
}

/// Caixa de destaque para poster (fundo claro, texto preto)
/// - cor-destaque: cor do fundo; sem ela, vale a de `poster()` ou `academic-poster()`
#let poster-highlight(
  cor-destaque: auto,
  body,
) = context {
  let cor = if cor-destaque == auto { _poster-cor.get() } else { cor-destaque }
  block(
    width: 100%,
    inset: 1em,
    fill: cor.lighten(90%),
    radius: 5pt,
  )[
    #set text(fill: black)
    #body
  ]
  v(0.5em)
}

/// Figura ou tabela para poster
/// Identificação em cima ("Figura 1 – Título" ou "Tabela 1 – Título", pelo tipo
/// do conteúdo) e fonte embaixo. Para tabela, use traços só horizontais
/// (IBGE; NBR 15437 4.6): `table(stroke: none, table.hline(), ..., table.hline())`.
/// - legenda: título da ilustração (ou tabela)
/// - origem: fonte, obrigatória pela norma (`Fonte: ...`)
#let poster-figure(
  body,
  legenda: none,
  origem: none,
) = {
  figure(body, caption: legenda)
  if origem != none {
    context align(left, text(size: _poster-piso(0.8 * text.size))[Fonte: #origem])
  }
  v(0.5em)
}

/// Referencias para poster
/// Formato compacto, sem notas de rodape; alinhadas à esquerda, sem recuo e sem
/// justificar, com letra de pelo menos 20 pt
#let poster-references(itens) = context {
  let corpo = text.size
  text(weight: "bold", size: 1.2em)[REFERÊNCIAS]
  v(0.3em)

  set par(
    first-line-indent: 0pt,
    justify: false,
  )
  set text(size: _poster-piso(0.8 * corpo), hyphenate: false)

  for item in itens {
    item
    linebreak()
    v(0.2em)
  }
}

/// Template de poster academico (com orientador, departamento e logotipos)
///
/// Vale o que está dito em `poster()` (título e subtítulo, autores com
/// afiliações numeradas por instituição, tamanhos mínimos, colunas equilibradas,
/// `cor-texto`, `cor-destaque` herdada pelas seções). Além disso:
/// - orientador: nome do orientador (sai abaixo dos autores)
/// - departamento: departamento ou unidade (abaixo da instituição)
/// - logo: logotipo à esquerda do título, um `image(...)`; é reduzido, se preciso,
///   a `largura-logo` x `altura-logo`, mantendo a proporção. Sozinho, deixa à
///   direita um vão do mesmo tamanho, para o título ficar centralizado
/// - logo-direita: segundo logotipo (outra instituição ou agência), à direita
/// - largura-logo, altura-logo: tamanho máximo de cada logotipo (padrão 10 x 6 cm)
/// Sem logotipo, o cabeçalho é igual ao de `poster()`.
#let academic-poster(
  titulo: "",
  subtitulo: none,
  autores: (),
  orientador: none,
  instituicao: none,
  departamento: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 3,
  equilibrar-colunas: true,
  largura: 90cm,
  altura: 120cm,
  fonte: "Arial",
  tamanho-titulo: 72pt,
  tamanho-corpo: 24pt,
  fundo: white,
  cor-texto: black,
  cor-destaque: rgb("#003366"),
  logo: none,
  logo-direita: none,
  largura-logo: 10cm,
  altura-logo: 6cm,
  body,
) = {
  assert(
    titulo != "" and titulo != none,
    message: "academic-poster(): informe o titulo (NBR 15437 4.1: o título é obrigatório)",
  )
  let autores = _poster-lista(autores)
  let palavras-chave = _poster-lista(palavras-chave).flatten()

  show: _poster-base.with(
    titulo, autores, largura, altura, fundo, fonte, tamanho-corpo, cor-destaque, cor-texto,
  )

  // Cabecalho com logotipos
  let cabecalho = _poster-cabecalho(
    titulo, subtitulo, autores, orientador, instituicao, departamento, contato,
    tamanho-corpo, tamanho-titulo, cor-destaque,
  )
  if logo == none and logo-direita == none {
    align(center, cabecalho)
  } else {
    let esquerda = if logo != none { _poster-logo(logo, largura-logo, altura-logo) }
    let direita = if logo-direita != none {
      _poster-logo(logo-direita, largura-logo, altura-logo)
    } else if esquerda != none {
      hide(esquerda)
    }
    grid(
      columns: (auto, 1fr, auto),
      gutter: 1cm,
      align: horizon,
      esquerda, align(center, cabecalho), direita,
    )
  }

  v(1cm)
  line(length: 100%, stroke: 2pt + cor-destaque)
  v(1cm)

  // Resumo
  _poster-resumo(texto-resumo, palavras-chave, cor-destaque, tamanho-corpo)

  // Conteudo
  _poster-colunas(num-colunas, equilibrar-colunas, tamanho-corpo, body)
}

/// Cria um poster A0 (padrao para congressos), 84,1 x 118,9 cm
/// Só repassa os parâmetros listados; para outros (fundo, tamanhos, orientador,
/// logotipo) use `poster()` ou `academic-poster()` com `largura` e `altura`.
#let poster-a0(
  titulo: "",
  subtitulo: none,
  autores: (),
  instituicao: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 3,
  fonte: "Arial",
  cor-destaque: rgb("#003366"),
  body,
) = {
  poster(
    titulo: titulo,
    subtitulo: subtitulo,
    autores: autores,
    instituicao: instituicao,
    contato: contato,
    texto-resumo: texto-resumo,
    palavras-chave: palavras-chave,
    num-colunas: num-colunas,
    largura: 84.1cm,   // A0 width
    altura: 118.9cm, // A0 height
    fonte: fonte,
    tamanho-titulo: 72pt,
    tamanho-corpo: 24pt,
    cor-destaque: cor-destaque,
    body,
  )
}

/// Cria um poster de 60 x 90 cm (o menor formato da NBR 15437 5.2)
/// O A1 da ISO (59,4 x 84,1 cm) fica abaixo do mínimo da norma (largura de 0,60 m
/// e altura de 0,90 m), então este formato usa 60 x 90 cm. Só repassa os
/// parâmetros listados; para outros use `poster()` com `largura: 60cm`, `altura: 90cm`.
#let poster-a1(
  titulo: "",
  subtitulo: none,
  autores: (),
  instituicao: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 2,
  fonte: "Arial",
  cor-destaque: rgb("#003366"),
  body,
) = {
  poster(
    titulo: titulo,
    subtitulo: subtitulo,
    autores: autores,
    instituicao: instituicao,
    contato: contato,
    texto-resumo: texto-resumo,
    palavras-chave: palavras-chave,
    num-colunas: num-colunas,
    largura: 60cm,
    altura: 90cm,
    fonte: fonte,
    tamanho-titulo: 56pt,
    tamanho-corpo: 22pt,
    cor-destaque: cor-destaque,
    body,
  )
}
