// Template para tese/dissertação/TCC conforme NBR 14724:2024

#import "../core/setup.typ": with-abnt-setup
#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../text/headings.typ": *
#import "../elements/cover.typ": *
#import "../elements/title-page.typ": *
#import "../elements/abstract.typ": *
#import "../elements/toc.typ": *
#import "../references/bibliography.typ": *

/// Template de formatação para trabalhos acadêmicos (tese, dissertação, TCC)
///
/// Configura página, fonte, parágrafos, headings e demais elementos visuais
/// conforme NBR 14724:2024. Os metadados do trabalho (título, autor, etc.)
/// devem ser definidos via dados().
///
/// Parâmetros:
/// - fonte: fonte a usar ("Times New Roman" ou "Arial")
/// - arquivo-bibliografia: caminho para arquivo .bib (opcional)
/// - titulo-bibliografia: título da seção de referências (padrão: "REFERÊNCIAS")
#let normas-abnt(
  fonte: "Times New Roman",
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERÊNCIAS",
  body,
) = {
  show: with-abnt-setup.with(fonte: fonte, suplemento-nivel1: "Capítulo")

  // Nota: metadados do PDF (title, author) são definidos por dados().
  // Se o usuário não usar dados(), o PDF ficará sem metadados.

  // Conteúdo
  body

  // Bibliografia automática (se arquivo .bib fornecido)
  if arquivo-bibliografia != none {
    abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
  }
}

// Alias de retrocompatibilidade (0.1.2 usava abntcc)
#let abntcc = normas-abnt

/// Marca início da parte pré-textual (sem numeração visível).
/// Deve ser chamado após a capa, antes da folha de rosto.
/// A contagem inicia na folha de rosto conforme NBR 14724:2024.
#let pretextual() = {
  counter(page).update(1)
  set page(numbering: none)
}

/// Marca início da parte textual (numeração arábica visível).
/// NÃO reinicia o contador — a numeração continua da contagem
/// iniciada na folha de rosto, conforme NBR 14724:2024.
#let textual() = {
  set page(numbering: "1", number-align: top + right)
}

/// Marca início da parte pós-textual (referências, apêndices, anexos).
/// A numeração arábica continua sem interrupção, conforme NBR 14724:2024.
#let postextual() = {
  set page(numbering: "1", number-align: top + right)
}

/// Página de dedicatória
#let dedicatoria(conteudo) = {
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      #conteudo
    ]
  ]
  pagebreak()
}

/// Página de agradecimentos
#let agradecimentos(conteudo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "AGRADECIMENTOS")
  ]
  v(1.5em)
  conteudo
  pagebreak()
}

/// Epígrafe
#let epigrafe(citacao, autor) = {
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      \u{201C}#citacao\u{201D} \
      [(#autor)]
    ]
  ]
  pagebreak()
}

// Aliases curtos
#let dedica = dedicatoria
#let agradece = agradecimentos
