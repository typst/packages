// Configuração de fontes conforme NBR 14724:2024
// Fonte: a NBR 14724 5.1 recomenda tamanho 12 para todo o texto e não fixa o tipo de letra;
// o pacote usa Times New Roman por padrão (Arial é opcional)
// Tamanho: 12pt para texto, menor para citações longas, notas, legendas

/// Fontes usadas pelo pacote (a ABNT não fixa o tipo de letra)
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
#let abnt-font-setup(fonte-familia: "Times New Roman", body) = {
  set text(
    font: fonte-familia,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )
  body
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

/// Texto em tamanho reduzido (10pt) para citações longas, notas, legendas, fontes
#let small-text(body) = {
  text(size: 10pt, body)
}

/// Texto para notas de rodapé (alias de small-text)
#let footnote-text = small-text

/// Texto para legendas (alias de small-text)
#let caption-text = small-text

/// Configura notas de rodapé conforme ABNT
/// - Separadas do texto por espaço simples e filete de 5 cm
/// - Fonte tamanho 10
/// - Alinhadas à margem esquerda
#let abnt-footnote-setup(body) = {
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
    gap: 0.5em,
  )
  body
}

// === Atalhos de formatação inline ===

/// Sublinhado — wrapper de #underline
/// Exemplo: #sublinhado[texto sublinhado]
/// (não se chama `sub`: esse nome é o subscrito nativo do Typst)
#let sublinhado(body) = underline(body)

/// Riscado — wrapper de #strike
/// Exemplo: #risc[texto riscado]
#let risc(body) = strike(body)

/// Versalete — primeira letra em tamanho normal, restante em caixa alta 0.8em
/// Requer string: #caps("Texto em Versalete")
/// Com content (#caps[...]) cai em smallcaps nativo
#let caps(texto) = {
  if type(texto) == str {
    let chars = texto.clusters()
    if chars.len() > 0 {
      chars.first()
      text(size: 0.8em, upper(chars.slice(1).join()))
    }
  } else {
    smallcaps(texto)
  }
}
