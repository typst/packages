// Capa conforme NBR 14724:2024
// Elementos obrigatórios: instituição, autor, título, subtítulo, local, ano

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

  // Título (maiúsculas, negrito)
  if titulo != none {
    if subtitulo != none {
      // Título com dois-pontos no final
      text(weight: "bold", size: 14pt, upper(titulo) + ":")
      linebreak()
      // Subtítulo em linha separada
      text(size: 14pt, subtitulo)
    } else {
      text(weight: "bold", size: 14pt, upper(titulo))
    }
  }

  v(1fr)

  // Local e ano
  if local != none {
    text(size: 12pt, upper(local))
    linebreak()
  }

  if ano != none {
    text(size: 12pt, str(ano))
  }

  pagebreak()
}
