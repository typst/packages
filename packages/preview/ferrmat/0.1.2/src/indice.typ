// ============================================================================
// ferrmat – Módulo de Índice Remissivo
// Equivalente ao makeidx/imakeidx do LaTeX.
// ============================================================================

// ---------------------------------------------------------------------------
// irem — marcar um termo no texto (Índice REMissivo)
// ---------------------------------------------------------------------------

/// Marca um termo para o índice remissivo nesta posição do documento.
/// O termo é invisível — não aparece no texto.
///
/// - `termo`: O termo principal (ex: "derivada").
/// - `sub`: Subtermo opcional (ex: "parcial" → aparece como "derivada, parcial").
/// - `ver`: Remissiva "ver" (ex: `irem("velocidade", ver: "cinemática")` → "velocidade, _ver_ cinemática").
///
/// ```example
/// A #irem("derivada") derivada de uma função...
/// A #irem("derivada", sub: "parcial") derivada parcial...
/// ```
#let irem(
  termo,
  sub: none,
  ver: none,
) = {
  assert(type(termo) == str and termo.len() > 0,
    message: "irem: termo deve ser uma string não vazia")
  [#metadata((
    tipo: "ferrmat-idx",
    termo: termo,
    sub: sub,
    ver: ver,
  )) <ferrmat-idx>]
}

/// Marca um termo e o exibe em negrito no texto (útil para definições).
///
/// ```example
/// #irem-def("integral") é a operação inversa da derivada.
/// ```
#let irem-def(
  termo,
  sub: none,
) = [#irem(termo, sub: sub)#strong(termo)]

// ---------------------------------------------------------------------------
// imprimir-indice — gerar o índice remissivo
// ---------------------------------------------------------------------------

/// Gera o índice remissivo com todos os termos marcados por `irem()`.
///
/// - `titulo`: Título do índice. `auto` = "Índice Remissivo". `none` = sem título.
/// - `colunas`: Número de colunas. Padrão: 2.
///
/// ```example
/// #imprimir-indice()
/// ```
#let imprimir-indice(
  titulo: auto,
  colunas: 2,
) = context {
  // --- Coletar todas as entradas ---
  let entradas = query(<ferrmat-idx>)

  if entradas.len() == 0 {
    return
  }

  // --- Agrupar por termo → páginas ---
  // Estrutura: (termo, sub, ver, paginas: dict-como-set para O(1) lookup)
  let mapa = (:)

  for entrada in entradas {
    let dados = entrada.value
    if dados.at("tipo", default: "") != "ferrmat-idx" { continue }

    let termo = dados.termo
    let sub = dados.sub
    let ver = dados.ver
    let pagina = entrada.location().page()
    let pag-chave = str(pagina)

    // Chave única para agrupar
    let chave = if sub != none { termo + "\x00" + sub } else { termo }

    if chave not in mapa {
      let pags = (:)
      pags.insert(pag-chave, true)
      mapa.insert(chave, (
        termo: termo,
        sub: sub,
        ver: ver,
        paginas: pags,
      ))
    } else {
      let existente = mapa.at(chave)
      existente.paginas.insert(pag-chave, true)
      if ver != none and existente.ver == none {
        existente.ver = ver
      }
      mapa.insert(chave, existente)
    }
  }

  // --- Ordenar chaves alfabeticamente (case-insensitive) ---
  let chaves = mapa.keys().sorted(key: k => lower(k))

  // --- Título ---
  let titulo-final = if titulo == auto { "Índice Remissivo" } else { titulo }
  if titulo-final != none {
    heading(level: 1, numbering: none, titulo-final)
  }

  // --- Renderizar ---
  let conteudo = {
    let letra-atual = ""

    for chave in chaves {
      let item = mapa.at(chave)
      let primeira-letra = upper(item.termo.first())

      // Separador de letra
      if primeira-letra != letra-atual {
        letra-atual = primeira-letra
        v(0.5em)
        text(weight: "bold", size: 1.1em, primeira-letra)
        v(0.2em)
      }

      // Montar linha
      if item.sub != none {
        // Subtermo: indentado
        let linha = h(1.5em) + item.sub
        if item.ver != none {
          linha = linha + [, _ver_ #item.ver]
        } else {
          let pags = item.paginas.keys().map(k => int(k)).sorted().map(p => str(p)).join(", ")
          linha = linha + [, #pags]
        }
        [#linha \ ]
      } else {
        // Termo principal
        let linha = [#item.termo]
        if item.ver != none {
          linha = linha + [, _ver_ #item.ver]
        } else {
          let pags = item.paginas.keys().map(k => int(k)).sorted().map(p => str(p)).join(", ")
          linha = linha + [, #pags]
        }
        [#linha \ ]
      }
    }
  }

  set par(first-line-indent: 0pt)

  if colunas > 1 {
    columns(colunas, gutter: 1em, conteudo)
  } else {
    conteudo
  }
}
