// Identificadores padrao internacionais conforme normas ABNT
// NBR ISO 2108:2006 - ISBN
// NBR 10525:2005 - ISSN

// ============================================================================
// ISBN - Numero Padrao Internacional de Livro (NBR ISO 2108:2006)
// ============================================================================

/// Calcula digito verificador do ISBN-13 usando modulo 10
///
/// Algoritmo:
/// 1. Multiplicar cada um dos 12 primeiros digitos alternadamente por 1 e 3
/// 2. Somar todos os produtos
/// 3. Dividir a soma por 10 e obter o resto
/// 4. Subtrair o resto de 10 (se resto = 0, digito = 0)
///
/// Parametros:
/// - digits: string com os 12 primeiros digitos do ISBN (sem o digito verificador)
///
/// Retorna: digito verificador (string "0"-"9")
///
/// Exemplo:
/// ```typst
/// #isbn-check-digit("978011000222") // Retorna "4"
/// ```
#let isbn-check-digit(digits) = {
  // Remove caracteres nao numericos
  let clean = digits.replace(regex("[^0-9]"), "")

  if clean.len() < 12 {
    return none
  }

  // Pega apenas os 12 primeiros digitos
  let d = clean.slice(0, 12)

  // Calcula soma ponderada
  let sum = 0
  for i in range(12) {
    let digit = int(d.at(i))
    let weight = if calc.rem(i, 2) == 0 { 1 } else { 3 }
    sum += digit * weight
  }

  // Calcula digito verificador
  let remainder = calc.rem(sum, 10)
  let check = if remainder == 0 { 0 } else { 10 - remainder }

  str(check)
}

/// Valida ISBN-13 (verifica digito verificador)
///
/// Parametros:
/// - isbn: ISBN completo (pode incluir hifens)
///
/// Retorna: true se valido, false se invalido
///
/// Exemplo:
/// ```typst
/// #validate-isbn("978-0-11-000222-4") // true
/// #validate-isbn("978-0-11-000222-5") // false
/// ```
#let validate-isbn(isbn) = {
  // Remove hifens e espacos
  let clean = isbn.replace(regex("[^0-9]"), "")

  if clean.len() != 13 {
    return false
  }

  let calculated = isbn-check-digit(clean.slice(0, 12))
  let provided = clean.at(12)

  calculated == provided
}

/// Valida ISBN-10 (formato antigo)
///
/// Algoritmo modulo 11:
/// 1. Multiplicar cada digito por peso decrescente (10, 9, 8, ..., 2)
/// 2. Somar produtos
/// 3. Resto da divisao por 11 deve ser 0
///
/// Parametros:
/// - isbn: ISBN-10 (pode usar X como digito verificador)
///
/// Retorna: true se valido
#let validate-isbn10(isbn) = {
  let clean = isbn.replace(regex("[^0-9Xx]"), "")

  if clean.len() != 10 {
    return false
  }

  let sum = 0
  for i in range(10) {
    let char = clean.at(i)
    let digit = if char == "X" or char == "x" { 10 } else { int(char) }
    let weight = 10 - i
    sum += digit * weight
  }

  calc.rem(sum, 11) == 0
}

/// Converte ISBN-10 para ISBN-13
///
/// Parametros:
/// - isbn10: ISBN de 10 digitos
///
/// Retorna: ISBN-13 formatado
///
/// Exemplo:
/// ```typst
/// #isbn10-to-isbn13("0-393-04002-X") // "978-0-393-04002-9"
/// ```
#let isbn10-to-isbn13(isbn10) = {
  // Remove formatacao
  let clean = isbn10.replace(regex("[^0-9Xx]"), "")

  if clean.len() != 10 {
    return none
  }

  // Pega os 9 primeiros digitos (ignora digito verificador antigo)
  let base = "978" + clean.slice(0, 9)

  // Calcula novo digito verificador
  let check = isbn-check-digit(base)

  // Formata ISBN-13
  base + check
}

/// Formata ISBN com hifens
///
/// Parametros:
/// - isbn: ISBN sem formatacao (13 digitos)
/// - group: codigo do grupo de registro (ex: "85" para Brasil)
/// - registrant-len: tamanho do elemento registrante
/// - publication-len: tamanho do elemento publicacao
///
/// Retorna: ISBN formatado com hifens
///
/// Nota: A estrutura do ISBN varia por editora. Esta funcao oferece
/// formatacao basica. Para formatacao precisa, consulte a agencia ISBN.
///
/// Exemplo:
/// ```typst
/// #format-isbn("9788577777770", group: "85", registrant-len: 4, publication-len: 4)
/// // "978-85-7777-7777-0"
/// ```
#let format-isbn(isbn, group: none, registrant-len: 4, publication-len: 4) = {
  let clean = isbn.replace(regex("[^0-9]"), "")

  if clean.len() != 13 {
    return isbn
  }

  // Estrutura padrao: 978-XX-XXXX-XXXX-X
  // Prefixo (3) - Grupo (variavel) - Registrante (variavel) - Publicacao (variavel) - Check (1)

  let prefix = clean.slice(0, 3) // 978 ou 979

  if group != none {
    let group-len = group.len()
    let start = 3
    let g = clean.slice(start, start + group-len)
    let r = clean.slice(start + group-len, start + group-len + registrant-len)
    let p = clean.slice(start + group-len + registrant-len, 12)
    let c = clean.slice(12, 13)

    prefix + "-" + g + "-" + r + "-" + p + "-" + c
  } else {
    // Formatacao generica
    prefix + "-" + clean.slice(3, 5) + "-" + clean.slice(5, 9) + "-" + clean.slice(9, 12) + "-" + clean.slice(12, 13)
  }
}

/// Exibe ISBN formatado conforme NBR ISO 2108:2006
///
/// Parametros:
/// - isbn: numero ISBN (com ou sem hifens)
/// - format: formato de exibicao (true para exibir "ISBN" antes do numero)
/// - product-form: forma do produto (opcional, ex: "brochura", "e-book")
///
/// Exemplo:
/// ```typst
/// #display-isbn("978-85-1234-567-8")
/// // ISBN 978-85-1234-567-8
///
/// #display-isbn("978-85-1234-567-8", product-form: "e-book")
/// // ISBN 978-85-1234-567-8 (e-book)
/// ```
#let display-isbn(isbn, format: true, product-form: none) = {
  let result = if format { "ISBN " } else { "" }
  result += isbn

  if product-form != none {
    result += " (" + product-form + ")"
  }

  result
}

/// Cria bloco de ISBN para ficha catalografica
/// Exibe multiplos ISBN quando a publicacao tem diferentes formas
///
/// Parametros:
/// - isbns: lista de tuplas (isbn, forma do produto)
///
/// Exemplo:
/// ```typst
/// #isbn-block((
///   ("978-85-1234-567-8", "brochura"),
///   ("978-85-1234-568-5", "capa dura"),
///   ("978-85-1234-569-2", "e-book"),
/// ))
/// ```
#let isbn-block(isbns) = {
  set par(first-line-indent: 0pt)

  for (isbn, form) in isbns {
    [ISBN #isbn (#form) \ ]
  }
}

// ============================================================================
// ISSN - Numero Padrao Internacional para Publicacao Seriada (NBR 10525:2005)
// ============================================================================

/// Calcula digito verificador do ISSN usando modulo 11
///
/// Algoritmo:
/// 1. Tomar os 7 primeiros digitos
/// 2. Aplicar peso constante (8 a 2)
/// 3. Multiplicar e somar
/// 4. Dividir por 11 (modulo)
/// 5. Subtrair resto de 11
/// 6. Se resultado = 10, digito = X
///
/// Parametros:
/// - digits: string com os 7 primeiros digitos do ISSN
///
/// Retorna: digito verificador (string "0"-"9" ou "X")
///
/// Exemplo:
/// ```typst
/// #issn-check-digit("0317847") // Retorna "1"
/// ```
#let issn-check-digit(digits) = {
  // Remove caracteres nao numericos
  let clean = digits.replace(regex("[^0-9]"), "")

  if clean.len() < 7 {
    return none
  }

  // Pega apenas os 7 primeiros digitos
  let d = clean.slice(0, 7)

  // Calcula soma ponderada
  let sum = 0
  for i in range(7) {
    let digit = int(d.at(i))
    let weight = 8 - i  // Pesos: 8, 7, 6, 5, 4, 3, 2
    sum += digit * weight
  }

  // Calcula digito verificador
  let remainder = calc.rem(sum, 11)
  let check = if remainder == 0 { 0 } else { 11 - remainder }

  if check == 10 {
    "X"
  } else {
    str(check)
  }
}

/// Valida ISSN (verifica digito verificador)
///
/// Parametros:
/// - issn: ISSN completo no formato XXXX-XXXX
///
/// Retorna: true se valido, false se invalido
///
/// Exemplo:
/// ```typst
/// #validate-issn("0317-8471") // true
/// #validate-issn("1050-124X") // true
/// #validate-issn("0317-8472") // false
/// ```
#let validate-issn(issn) = {
  // Remove hifens e espacos
  let clean = issn.replace(regex("[^0-9Xx]"), "")

  if clean.len() != 8 {
    return false
  }

  let calculated = issn-check-digit(clean.slice(0, 7))
  let provided = upper(clean.at(7))

  upper(calculated) == provided
}

/// Formata ISSN com hifen
///
/// Parametros:
/// - issn: ISSN sem formatacao (8 caracteres)
///
/// Retorna: ISSN no formato XXXX-XXXX
///
/// Exemplo:
/// ```typst
/// #format-issn("03178471") // "0317-8471"
/// ```
#let format-issn(issn) = {
  let clean = issn.replace(regex("[^0-9Xx]"), "")

  if clean.len() != 8 {
    return issn
  }

  clean.slice(0, 4) + "-" + clean.slice(4, 8)
}

/// Exibe ISSN formatado conforme NBR 10525:2005
///
/// Parametros:
/// - issn: numero ISSN (com ou sem hifen)
/// - format: se true, exibe "ISSN" antes do numero
///
/// Exemplo:
/// ```typst
/// #display-issn("0317-8471")
/// // ISSN 0317-8471
/// ```
#let display-issn(issn, format: true) = {
  let formatted = format-issn(issn)
  if format {
    "ISSN " + formatted
  } else {
    formatted
  }
}

/// Gera meta tag HTML para ISSN online
/// Conforme NBR 10525:2005 secao 5.5
///
/// Parametros:
/// - issn: numero ISSN
///
/// Retorna: string com meta tag HTML
///
/// Exemplo:
/// ```typst
/// #issn-meta-tag("1234-5678")
/// // <META SCHEME="ISSN" NAME="identifier" CONTENT="1234-5678">
/// ```
#let issn-meta-tag(issn) = {
  let formatted = format-issn(issn)
  "<META SCHEME=\"ISSN\" NAME=\"identifier\" CONTENT=\"" + formatted + "\">"
}

/// Cria bloco de ISSN para ficha catalografica ou capa
///
/// Parametros:
/// - issn: numero ISSN principal
/// - title-key: titulo-chave (opcional)
/// - support: suporte (impresso, online, CD-ROM)
///
/// Exemplo:
/// ```typst
/// #issn-block(
///   "0100-1965",
///   title-key: "Ciencia da Informacao (Brasilia. Online)",
///   support: "online"
/// )
/// ```
#let issn-block(issn, title-key: none, support: none) = {
  set par(first-line-indent: 0pt)

  [ISSN #format-issn(issn)]

  if support != none {
    [ (#support)]
  }
  [ \ ]

  if title-key != none {
    text(size: 10pt, style: "italic")[Titulo-chave: #title-key \ ]
  }
}

/// Exibe multiplos ISSN relacionados
/// Para publicacoes em diferentes suportes
///
/// Parametros:
/// - isbns: lista de tuplas (issn, suporte)
///
/// Exemplo:
/// ```typst
/// #issn-multiple((
///   ("0100-1965", "impresso"),
///   ("1518-8353", "online"),
/// ))
/// ```
#let issn-multiple(issns) = {
  set par(first-line-indent: 0pt)

  for (issn, support) in issns {
    [ISSN #format-issn(issn) (#support) \ ]
  }
}

// ============================================================================
// Funcoes de conveniencia para referencias bibliograficas
// ============================================================================

/// Adiciona ISBN a referencia de livro
/// Conforme NBR 6023
///
/// Exemplo:
/// ```typst
/// SILVA, Maria. *Manual de normas ABNT*. 2. ed. Sao Paulo: Atlas, 2023. #ref-isbn("978-85-1234-567-8")
/// ```
#let ref-isbn(isbn) = {
  [ISBN #isbn.]
}

/// Adiciona ISSN a referencia de periodico
/// Conforme NBR 6023
///
/// Exemplo:
/// ```typst
/// CIENCIA DA INFORMACAO. Brasilia: IBICT, 1972-. #ref-issn("0100-1965")
/// ```
#let ref-issn(issn) = {
  [ISSN #format-issn(issn).]
}

// ============================================================================
// Validacao e utilitarios
// ============================================================================

/// Verifica se string contem ISBN ou ISSN valido
///
/// Parametros:
/// - text: texto a verificar
///
/// Retorna: dicionario com tipo ("isbn", "issn" ou none) e valor
#let detect-identifier(text) = {
  let clean = text.replace(regex("[^0-9Xx]"), "")

  if clean.len() == 13 and validate-isbn(clean) {
    (type: "isbn-13", value: clean, valid: true)
  } else if clean.len() == 10 and validate-isbn10(clean) {
    (type: "isbn-10", value: clean, valid: true)
  } else if clean.len() == 8 and validate-issn(clean) {
    (type: "issn", value: clean, valid: true)
  } else {
    (type: none, value: clean, valid: false)
  }
}

/// Grupos de registro ISBN conhecidos
#let isbn-groups = (
  "0": "Paises de lingua inglesa",
  "1": "Paises de lingua inglesa",
  "2": "Paises de lingua francesa",
  "3": "Paises de lingua alema",
  "4": "Japao",
  "5": "Russia (ex-URSS)",
  "7": "China",
  "65": "Brasil (antigo)",
  "85": "Brasil",
  "972": "Portugal",
  "989": "Portugal",
)

/// Identifica pais/regiao pelo grupo de registro do ISBN
#let isbn-country(isbn) = {
  let clean = isbn.replace(regex("[^0-9]"), "")

  if clean.len() < 5 {
    return none
  }

  // Tenta identificar grupo (pode ter 1-5 digitos apos o prefixo)
  let after-prefix = clean.slice(3)  // Pula 978/979

  // Tenta grupos de tamanhos diferentes
  for len in (3, 2, 1) {
    if after-prefix.len() >= len {
      let group = after-prefix.slice(0, len)
      if group in isbn-groups {
        return isbn-groups.at(group)
      }
    }
  }

  none
}
