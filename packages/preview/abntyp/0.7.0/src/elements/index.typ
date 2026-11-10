// Indice conforme NBR 6034:2004
//
// Definicoes:
// - Indice: Relacao de palavras/frases ordenadas que localiza e remete para
//   informacoes no texto
// - Cabecalho: Palavra(s) ou simbolo(s) que determina(m) a entrada
// - Entrada: Unidade do indice (cabecalho + indicativo de localizacao)
// - Subcabecalho: Palavra/simbolo que complementa o cabecalho
// - Remissiva: Indicacao que remete a outro cabecalho (ver ou ver tambem)
//
// Tipos de indice:
// - Quanto a ordenacao: alfabetica, sistematica, cronologica, numerica, alfanumerica
// - Quanto ao enfoque: especial (autores, assuntos, titulos, etc.) ou geral

#import "../core/sorting.typ": sort-key, sort-initial

/// Estado para armazenar entradas do indice
#let index-entries = state("abnt-index-entries", ())

/// Registra uma entrada no indice
/// Esta funcao deve ser chamada no local do texto onde o termo aparece
///
/// Parametros:
/// - termo: termo principal (cabecalho)
/// - subtermo: subtermo/subcabecalho (opcional)
/// - subsubtermo: terceiro nivel, abaixo do subtermo (opcional; so vale com `subtermo`)
/// - exibicao: texto a exibir no documento (se diferente do termo)
/// - volume: volume ou parte onde a entrada esta, em documento de mais de um (NBR 6034,
///   6.12 c): numero (sai "v. 2") ou texto ("pt. 1"). Sai "Idade Media, v. 2, 36; v. 3, 81"
///
/// Exemplo:
/// ```typst
/// A #idx("algoritmo") e uma sequencia de instrucoes...
/// #idx("algoritmo", subtermo: "de ordenacao")[Quicksort] e eficiente...
/// ```
#let idx(termo, subtermo: none, subsubtermo: none, exibicao: none, volume: none) = {
  // Registrar entrada
  context {
    let current-page = counter(page).get().first()
    let entry = (
      term: termo,
      subterm: subtermo,
      subsubterm: subsubtermo,
      page: current-page,
      volume: volume,
    )
    index-entries.update(entries => entries + (entry,))
  }

  // Exibir texto (se fornecido)
  if exibicao != none {
    exibicao
  }
}

/// Cria uma entrada de indice sem exibir texto
/// Use quando quiser indexar um termo que ja aparece no texto
#let index-entry(termo, subtermo: none, subsubtermo: none, volume: none) = {
  context {
    let current-page = counter(page).get().first()
    let entry = (
      term: termo,
      subterm: subtermo,
      subsubterm: subsubtermo,
      page: current-page,
      volume: volume,
    )
    index-entries.update(entries => entries + (entry,))
  }
}

/// Remissiva "ver" - remete de um termo para outro
/// Exemplo: Aviacao ver Aeronautica
#let index-see(de, para) = {
  (type: "see", from: de, to: para)
}

/// Remissiva "ver tambem" - amplia opcoes de consulta
/// Exemplo: Ferias ver tambem Licenca
#let index-see-also(de, para) = {
  (type: "see-also", from: de, to: para)
}

// Letras ou primeira e ultima entradas da pagina, no canto superior externo (6.5).
// Para `set page(foreground:)`: nao substitui o cabecalho nem o numero da pagina.
#let _indice-canto(modo) = context {
  let aqui = here().page()
  let marcas = query(<abnt-ix-canto>).filter(m => m.location().page() == aqui)
  if marcas.len() > 0 {
    let a = marcas.first().value
    let b = marcas.last().value
    let texto = if modo == "letras" {
      if a.inicial == b.inicial { a.inicial } else { a.inicial + "–" + b.inicial }
    } else {
      if a.rotulo == b.rotulo { a.rotulo } else { [#a.rotulo – #b.rotulo] }
    }
    let m = page.margin
    let externa = if type(m) != dictionary { m }
      else if "outside" in m { m.outside } else { m.at("right", default: 2cm) }
    let externa = if type(externa) == relative { externa.length } else { externa }
    // margem automatica do Typst (2,5/21 do menor lado): usa o valor da A4
    let externa = if externa == auto { 2.5cm } else { externa }
    // Com margens inside/outside o lado externo alterna: direita nas paginas impares
    let direita = not (type(m) == dictionary and "outside" in m) or calc.odd(aqui)
    place(
      top + if direita { right } else { left },
      dx: if direita { -externa } else { externa },
      dy: 2.4cm,
      text(size: 10pt, weight: "bold", texto),
    )
  }
}

/// Gera o indice alfabetico
///
/// Parametros:
/// - titulo: titulo do indice (padrao: "INDICE"); `none` omite o titulo (para quem ja
///   escreveu um `heading`, como `book-index`)
/// - nota: nota explicativa do padrao adotado, impressa antes das entradas (NBR 6034, 6.3)
/// - rotulo-tipo: tipo do indice para o titulo (ex: "DE ASSUNTOS", "ONOMÁSTICO")
/// - entradas-ver: lista de remissivas "ver"
/// - entradas-ver-tambem: lista de remissivas "ver tambem"
/// - colunas: numero de colunas (padrao: 2)
/// - cabecalhos-letras: se true, mostra letras como cabecalhos de secao
/// - canto: `"letras"` ou `"entradas"` imprime, no canto superior externo de cada pagina
///   do indice, as letras iniciais ou a primeira e a ultima entradas da pagina
///   (NBR 6034, 6.5). Abre pagina nova (usa `set page`) e vale so para as paginas do
///   indice. A margem externa e lida da pagina; o texto sai a 2,4 cm do alto
///
/// Quando as subdivisoes de um cabecalho passam de uma pagina ou coluna para a seguinte,
/// o cabecalho (e o subcabecalho) e repetido com "(continuacao)" (6.8).
///
/// Exemplo:
/// ```typst
/// #indice(
///   rotulo-tipo: "DE ASSUNTOS",
///   entradas-ver: (
///     index-see("Aviacao", "Aeronautica"),
///   ),
///   entradas-ver-tambem: (
///     index-see-also("Ferias", "Licenca"),
///   ),
/// )
/// ```
#let indice(
  titulo: "ÍNDICE",
  nota: none,
  rotulo-tipo: none,
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
  cabecalhos-letras: true,
  canto: none,
) = {
  assert(canto in (none, "letras", "entradas"), message: "indice(canto:) aceita none, \"letras\" ou \"entradas\"")
  let corpo = {
  // Titulo do indice (`none` ou "" nao imprime titulo nem o vao dele)
  if titulo not in (none, "") {
    let full-title = if rotulo-tipo != none {
      titulo + " " + rotulo-tipo
    } else {
      titulo
    }

    align(center)[
      #text(weight: "bold", size: 12pt, full-title)
    ]

    v(1.5em)
  }

  // Nota explicativa do padrao adotado (6.3)
  if nota != none {
    set par(first-line-indent: 0pt)
    text(size: 10pt, nota)
    v(1em)
  }

  context {
    let entries = index-entries.final()

    // Chave de agrupamento e de ordem (NBR 6033): sem distincao de caixa e de acento
    // (content vira string pelo repr). A entrada mostra a 1a grafia registrada.
    let key-of = x => sort-key(if type(x) == str { x } else { repr(x) })
    let label-of = x => if type(x) == str { x } else { repr(x) }

    // Agrupar entradas por termo
    let grouped = (:)
    for entry in entries {
      let pagina = (volume: entry.at("volume", default: none), pagina: entry.page)
      let term-key = key-of(entry.term)
      if term-key not in grouped {
        grouped.insert(term-key, (term: entry.term, label: label-of(entry.term), pages: (), subterms: (:)))
      }

      if entry.subterm != none {
        let subterm-key = key-of(entry.subterm)
        if subterm-key not in grouped.at(term-key).subterms {
          grouped.at(term-key).subterms.insert(subterm-key, (subterm: entry.subterm, pages: (), subsubterms: (:)))
        }
        let subsubterm = entry.at("subsubterm", default: none)
        if subsubterm != none {
          let subsub-key = key-of(subsubterm)
          let subs = grouped.at(term-key).subterms.at(subterm-key).subsubterms
          if subsub-key not in subs {
            grouped.at(term-key).subterms.at(subterm-key).subsubterms.insert(subsub-key, (subsubterm: subsubterm, pages: ()))
          }
          grouped.at(term-key).subterms.at(subterm-key).subsubterms.at(subsub-key).pages.push(pagina)
        } else {
          grouped.at(term-key).subterms.at(subterm-key).pages.push(pagina)
        }
      } else {
        grouped.at(term-key).pages.push(pagina)
      }
    }

    // Remissivas de termos sem entrada propria tambem sao listadas (NBR 6034, 6.10 e 6.11)
    for entry in entradas-ver + entradas-ver-tambem {
      if type(entry) == dictionary and key-of(entry.from) not in grouped {
        grouped.insert(key-of(entry.from), (term: entry.from, label: label-of(entry.from), pages: (), subterms: (:)))
      }
    }

    // Ordenar termos alfabeticamente (as chaves ja sao chaves de ordenacao)
    let sorted-terms = grouped.keys().sorted()

    // Agrupar por letra inicial
    let by-letter = (:)
    for term in sorted-terms {
      let letter = sort-initial(grouped.at(term).label)
      if letter not in by-letter {
        by-letter.insert(letter, ())
      }
      by-letter.at(letter).push(term)
    }

    // Processar remissivas "ver"
    let see-map = (:)
    for entry in entradas-ver {
      if type(entry) == dictionary and entry.type == "see" {
        see-map.insert(key-of(entry.from), entry.to)
      }
    }

    // Processar remissivas "ver tambem"
    let see-also-map = (:)
    for entry in entradas-ver-tambem {
      if type(entry) == dictionary and entry.type == "see-also" {
        if key-of(entry.from) not in see-also-map {
          see-also-map.insert(key-of(entry.from), ())
        }
        see-also-map.at(key-of(entry.from)).push(entry.to)
      }
    }

    // Funcao para formatar paginas: por volume (NBR 6034, 6.12 c), na ordem em que os
    // volumes aparecem; sem volume saem so as paginas
    let format-pages = itens => {
      let volumes = itens.map(x => x.volume).dedup()
      volumes.map(volume => {
        // Remover duplicatas e ordenar
        let unique = itens.filter(x => x.volume == volume).map(x => x.pagina).dedup().sorted()

        // Agrupar paginas consecutivas
        let result = ()
        let start = unique.at(0)
        let end = start

        for i in range(1, unique.len()) {
          let page = unique.at(i)
          if page == end + 1 {
            end = page
          } else {
            result.push(if start == end { str(start) } else { str(start) + "-" + str(end) })
            start = page
            end = page
          }
        }
        result.push(if start == end { str(start) } else { str(start) + "-" + str(end) })

        let paginas = result.join(", ")
        if volume == none { paginas }
        else if type(volume) == int { "v. " + str(volume) + ", " + paginas }
        else { volume + ", " + paginas }
      }).join("; ")
    }

    // Renderizar indice
    set par(first-line-indent: 0pt)

    let marca = (inicial, rotulo) => [#metadata((inicial: inicial, rotulo: rotulo)) <abnt-ix-canto>]
    let linha = (recuo, conteudo) => {
      h(recuo)
      conteudo
      linebreak()
    }

    // Linhas de um termo: (recuo, texto, cab). `cab` e o que se repete no alto da coluna
    // quando a linha abre coluna ou pagina nova: o cabecalho e, se for o caso, o
    // subcabecalho, com "continuacao" (6.8)
    let linhas-de = (term-key, data) => {
      let continua = (0em, [#data.term #emph[(continuação)]])
      let ls = ()
      if term-key in see-map {
        ls.push((recuo: 0em, texto: [#data.term #emph[ver] #see-map.at(term-key)], cab: ()))
      } else {
        ls.push((recuo: 0em, texto: [#data.term#if data.pages.len() > 0 [, #format-pages(data.pages)]], cab: ()))
        for subterm-key in data.subterms.keys().sorted() {
          let sub-data = data.subterms.at(subterm-key)
          ls.push((
            recuo: 1em,
            texto: [#sub-data.subterm#if sub-data.pages.len() > 0 [, #format-pages(sub-data.pages)]],
            cab: (continua,),
          ))
          for subsub-key in sub-data.subsubterms.keys().sorted() {
            let subsub-data = sub-data.subsubterms.at(subsub-key)
            ls.push((
              recuo: 2em,
              texto: [#subsub-data.subsubterm, #format-pages(subsub-data.pages)],
              cab: (continua, (1em, [#sub-data.subterm #emph[(continuação)]])),
            ))
          }
        }
        if term-key in see-also-map {
          ls.push((
            recuo: 1em,
            texto: [#emph[ver também] #see-also-map.at(term-key).join(", ")],
            cab: (continua,),
          ))
        }
      }
      ls
    }

    // O termo com as suas subentradas fica inteiro na coluna. So o que e mais alto que uma
    // coluna comeca coluna nova e e fatiado aqui, em partes do tamanho da coluna, cada uma
    // (menos a primeira) com o cabecalho repetido. Nao ha consulta de posicao: o layout
    // nao depende de si mesmo e converge (repetir o cabecalho onde o Typst quebra a coluna
    // empurra as quebras seguintes e nao converge em 5 passagens).
    layout(tam => {
      // Altura util da pagina inteira (a regiao de `tam` e so o que resta na pagina)
      let m = page.margin
      let altura = if type(m) == dictionary and "top" in m and "bottom" in m and type(page.height) == length {
        let parte = x => if type(x) == relative { x.length } else { x }
        let topo = parte(m.top)
        let pe = parte(m.bottom)
        if type(topo) == length and type(pe) == length { page.height - topo - pe } else { tam.height }
      } else { tam.height }
      let vao = text.size
      let larg = (tam.width - (colunas - 1) * vao) / colunas
      let m1 = measure(width: larg, [x]).height
      let passo = (measure(width: larg, [x \ x \ x]).height - m1) / 2
      let cabem = calc.max(1, calc.floor((altura - m1) / passo) + 1)

      columns(colunas, gutter: vao)[
        #for letter in by-letter.keys().sorted() {
          // Cabecalho da letra: vai junto do 1o termo, para nao ficar sozinho no pe da coluna
          let cab-letra = if cabecalhos-letras {
            v(0.5em)
            text(weight: "bold", size: 11pt, letter)
            v(0.3em)
          }

          // Entradas desta letra
          for (k, term-key) in by-letter.at(letter).enumerate() {
            let data = grouped.at(term-key)
            let ls = linhas-de(term-key, data)
            let todas = { for l in ls { linha(l.recuo, l.texto) } }
            let letra = if k == 0 { cab-letra }

            if measure(width: larg, todas).height <= altura {
              block(width: 100%, above: par.leading, below: par.leading, breakable: false, { letra; marca(letter, data.term); todas })
            } else {
              colbreak(weak: true)
              letra
              // o 1o pedaco perde as linhas da letra; os outros, as do cabecalho repetido
              let linhas-letra = if letra == none { 0 } else { calc.ceil(measure(width: larg, letra).height / passo) }
              let i = 0
              while i < ls.len() {
                let cab = if i == 0 { () } else { ls.at(i).cab }
                let gasto = if i == 0 { linhas-letra } else { cab.len() }
                let fim = calc.min(i + calc.max(1, cabem - gasto), ls.len())
                marca(letter, data.term)
                for (recuo, texto) in cab { linha(recuo, texto) }
                for l in ls.slice(i, fim) { linha(l.recuo, l.texto) }
                i = fim
                if i < ls.len() { colbreak() }
              }
            }
          }
        }
      ]
    })
  }

  pagebreak(weak: true)
  }

  if canto == none { corpo } else {
    set page(foreground: _indice-canto(canto))
    corpo
  }
}

/// Indice de assuntos (wrapper para indice)
#let indice-assuntos(
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: "DE ASSUNTOS",
    entradas-ver: entradas-ver,
    entradas-ver-tambem: entradas-ver-tambem,
    colunas: colunas,
  )
}

/// Indice onomastico (de nomes/autores)
#let indice-onomastico(
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: "ONOMÁSTICO",
    entradas-ver: entradas-ver,
    entradas-ver-tambem: entradas-ver-tambem,
    colunas: colunas,
  )
}

/// Indice de autores
#let indice-autores(
  entradas-ver: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: "DE AUTORES",
    entradas-ver: entradas-ver,
    colunas: colunas,
  )
}

/// Indice geral (combina categorias)
#let indice-geral(
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: none,
    entradas-ver: entradas-ver,
    entradas-ver-tambem: entradas-ver-tambem,
    colunas: colunas,
  )
}

/// Entrada de indice manual (para casos especiais)
/// Use quando precisar de controle total sobre a entrada
///
/// Parametros:
/// - termo: termo principal
/// - qualificador: qualificador entre parenteses (opcional)
/// - paginas: paginas (string ou lista)
/// - subentradas: lista de subentradas
///
/// Exemplo:
/// ```typst
/// #manual-index-entry(
///   termo: "Pedro II",
///   qualificador: "Imperador do Brasil",
///   paginas: "15-18, 45",
/// )
/// ```
#let manual-index-entry(
  termo: none,
  qualificador: none,
  paginas: none,
  subentradas: (),
) = {
  set par(first-line-indent: 0pt)

  // Termo principal
  termo

  // Qualificador
  if qualificador != none {
    [ (#qualificador)]
  }

  // Paginas
  if paginas != none {
    [, #paginas]
  }

  linebreak()

  // Subentradas
  for sub in subentradas {
    h(1em)
    if type(sub) == dictionary {
      sub.termo
      if "paginas" in sub and sub.paginas != none {
        [, #sub.paginas]
      }
    } else {
      sub
    }
    linebreak()
  }
}
