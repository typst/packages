// Configuração de página conforme NBR 14724:2024
// Formato A4 (21 cm x 29,7 cm)
// Margens: superior e esquerda 3 cm, inferior e direita 2 cm

/// Configuração padrão de página ABNT
/// - papel: formato do papel (default: "a4")
/// - margem-superior: margem superior (default: 3cm)
/// - margem-inferior: margem inferior (default: 2cm)
/// - margem-esquerda: margem esquerda (default: 3cm)
/// - margem-direita: margem direita (default: 2cm)
#let abnt-page-setup(
  papel: "a4",
  margem-superior: 3cm,
  margem-inferior: 2cm,
  margem-esquerda: 3cm,
  margem-direita: 2cm,
) = {
  set page(
    paper: papel,
    margin: (
      top: margem-superior,
      bottom: margem-inferior,
      left: margem-esquerda,
      right: margem-direita,
    ),
  )
}

/// Aplica configuração de página ABNT ao documento
#let with-abnt-page(body) = {
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 2cm,
    ),
  )
  body
}

// Paginação
// - Elementos pré-textuais: contados mas não numerados (ou algarismos romanos minúsculos)
// - Elementos textuais e pós-textuais: algarismos arábicos, canto superior direito

/// Inicia paginação em algarismos arábicos
/// Usar no início da seção textual (Introdução)
#let start-arabic-numbering() = {
  counter(page).update(1)
  set page(numbering: "1")
}

/// Configura paginação no canto superior direito (padrão ABNT)
#let abnt-page-numbering() = {
  set page(
    numbering: "1",
    number-align: top + right,
  )
}

/// Paginação pré-textual (romanos minúsculos, opcional)
#let pretextual-numbering() = {
  set page(numbering: "i")
}

/// Remove numeração de página (para capa, folha de rosto)
#let no-page-numbering() = {
  set page(numbering: none)
}
