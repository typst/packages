// Capa conforme NBR 14724:2024
// Elementos obrigatórios: instituição, autor, título, subtítulo, local, ano

#import "../core/metadata.typ"

/// Cria capa conforme ABNT
/// - instituicao: nome da instituição (em maiúsculas)
/// - autor: nome do autor
/// - titulo: título do trabalho
/// - subtitulo: subtítulo (opcional)
/// - local: cidade
/// - ano: ano de depósito
#let capa(
  instituicao: none,
  faculdade: none,
  programa: none,
  autor: none,
  titulo: none,
  subtitulo: none,
  local: none,
  ano: none,
) = {
  set page(numbering: none)

  context {
    let instituicao = metadata._resolve(instituicao, "instituicao")
    let faculdade = metadata._resolve(faculdade, "faculdade")
    let programa = metadata._resolve(programa, "programa")
    let autor = metadata._resolve(autor, "autor")
    let titulo = metadata._resolve(titulo, "titulo")
    let subtitulo = metadata._resolve(subtitulo, "subtitulo")
    let local = metadata._resolve(local, "local")
    let ano = metadata._resolve(ano, "ano")

    set align(center)

    // Instituição (maiúsculas, negrito)
    if instituicao != none {
      text(weight: "bold", size: 12pt, upper(instituicao))
      linebreak()
    }

    if faculdade != none {
      text(weight: "bold", size: 12pt, upper(faculdade))
      linebreak()
    }

    if programa != none {
      text(weight: "bold", size: 12pt, upper(programa))
    }

    v(1fr)

    // Autor
    if autor != none {
      text(size: 12pt, upper(autor))
    }

    v(1fr)

    // Título (maiúsculas, negrito) + subtítulo
    metadata._render-titulo(titulo, subtitulo: subtitulo)

    v(1fr)

    // Local e ano
    if local != none {
      text(size: 12pt, upper(local))
      linebreak()
    }

    if ano != none {
      text(size: 12pt, metadata._str-safe(ano))
    }
  }

  pagebreak()
}
