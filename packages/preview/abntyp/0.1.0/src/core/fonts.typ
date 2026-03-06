// Configuração de fontes conforme NBR 14724:2024
// Fonte: Arial ou Times New Roman
// Tamanho: 12pt para texto, menor para citações longas, notas, legendas

/// Fontes recomendadas pela ABNT
#let abnt-fonts = (
  serif: "Times New Roman",
  sans: "Arial",
)

/// Tamanhos de fonte ABNT
#let abnt-font-sizes = (
  normal: 12pt,        // Texto principal
  small: 10pt,         // Citações longas, notas de rodapé, legendas, fontes
  footnote: 10pt,      // Notas de rodapé
  caption: 10pt,       // Legendas de figuras e tabelas (pode ser 10 ou 11)
  cover-title: 14pt,   // Título na capa (pode variar)
  cover-author: 12pt,  // Nome do autor na capa
)

/// Aplica fonte padrão ABNT (Times New Roman, 12pt)
#let abnt-font-setup(fonte-familia: "Times New Roman") = {
  set text(
    font: fonte-familia,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )
}

/// Aplica configuração completa de fonte ABNT
#let with-abnt-font(fonte-familia: "Times New Roman", body) = {
  set text(
    font: fonte-familia,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )
  body
}

/// Texto em tamanho reduzido (para citações longas, notas, etc.)
#let small-text(body) = {
  text(size: 10pt, body)
}

/// Texto para notas de rodapé
#let footnote-text(body) = {
  text(size: 10pt, body)
}

/// Texto para legendas
#let caption-text(body) = {
  text(size: 10pt, body)
}

/// Configura notas de rodapé conforme ABNT
/// - Separadas do texto por espaço simples e filete de 5 cm
/// - Fonte tamanho 10
/// - Alinhadas à margem esquerda
#let abnt-footnote-setup() = {
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
    gap: 0.5em,
  )
}
