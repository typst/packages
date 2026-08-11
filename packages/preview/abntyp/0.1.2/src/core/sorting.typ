// Ordenacao alfabetica conforme NBR 6033:1989
// Criterios de aplicacao da ordem alfabetica em listas, indices, catalogos, bibliografias

/// Artigos definidos por idioma (nao considerar na ordenacao)
#let definite-articles = (
  // Alemao
  "der", "die", "das",
  // Espanhol
  "el", "la", "lo", "los", "las",
  // Frances
  "le", "la", "l'", "les",
  // Ingles
  "the",
  // Italiano
  "il", "lo", "l'", "la", "gli", "gl'", "i", "le",
  // Portugues
  "o", "a", "os", "as",
)

/// Artigos indefinidos por idioma (nao considerar na ordenacao)
#let indefinite-articles = (
  // Alemao (tambem podem ser numerais)
  "ein", "eine",
  // Espanhol (tambem podem ser numerais)
  "un", "una",
  // Frances (tambem podem ser numerais)
  "un", "une",
  // Ingles
  "a", "an",
  // Italiano
  "un", "uno", "una", "un'",
  // Portugues
  "um", "uma", "uns", "umas",
)

/// Todos os artigos (definidos e indefinidos)
#let all-articles = definite-articles + indefinite-articles

/// Remove acentos e sinais diacriticos para ordenacao
/// Conforme NBR 6033: letras com acentos sao alfabetadas sem as modificacoes
///
/// Exemplo:
/// ```typst
/// #remove-accents("Muller") // Retorna "Muller"
/// #remove-accents("cafe") // Retorna "cafe"
/// ```
#let remove-accents(text) = {
  let result = text
  // Mapeamento de caracteres acentuados para seus equivalentes
  let accent-map = (
    // Minusculas
    ("a", "a"), ("a", "a"), ("a", "a"), ("a", "a"), ("a", "a"),
    ("e", "e"), ("e", "e"), ("e", "e"), ("e", "e"),
    ("i", "i"), ("i", "i"), ("i", "i"), ("i", "i"),
    ("o", "o"), ("o", "o"), ("o", "o"), ("o", "o"), ("o", "o"),
    ("u", "u"), ("u", "u"), ("u", "u"), ("u", "u"),
    ("c", "c"), ("n", "n"),
    // Maiusculas
    ("A", "A"), ("A", "A"), ("A", "A"), ("A", "A"), ("A", "A"),
    ("E", "E"), ("E", "E"), ("E", "E"), ("E", "E"),
    ("I", "I"), ("I", "I"), ("I", "I"), ("I", "I"),
    ("O", "O"), ("O", "O"), ("O", "O"), ("O", "O"), ("O", "O"),
    ("U", "U"), ("U", "U"), ("U", "U"), ("U", "U"),
    ("C", "C"), ("N", "N"),
  )

  for (from, to) in accent-map {
    result = result.replace(from, to)
  }
  result
}

/// Remove artigo inicial para ordenacao
/// Conforme NBR 6033: artigos iniciais nao sao considerados na ordenacao
///
/// Parametros:
/// - text: texto a processar
/// - keep-articles-in-names: se true, mantem artigos que fazem parte de nomes proprios (ex: "La Fontaine")
///
/// Exemplo:
/// ```typst
/// #remove-initial-article("A batalha") // Retorna "batalha"
/// #remove-initial-article("The book") // Retorna "book"
/// ```
#let remove-initial-article(text, keep-articles-in-names: false) = {
  let words = text.split(" ")
  if words.len() == 0 { return text }

  let first-word = lower(words.at(0))

  // Verifica se primeira palavra e um artigo
  if first-word in all-articles or first-word.trim("'") in all-articles {
    // Se deve manter artigos em nomes proprios, verifica se segunda palavra comeca com maiuscula
    if keep-articles-in-names and words.len() > 1 {
      let second-word = words.at(1)
      if second-word.len() > 0 {
        let first-char = second-word.at(0)
        // Se segunda palavra comeca com maiuscula, pode ser nome proprio - manter artigo
        if first-char == upper(first-char) and first-char != lower(first-char) {
          return text
        }
      }
    }
    // Remove o artigo
    words.slice(1).join(" ")
  } else {
    text
  }
}

/// Gera chave de ordenacao para um texto conforme NBR 6033
/// - Remove acentos
/// - Ignora artigos iniciais
/// - Converte para minusculas para comparacao
///
/// Parametros:
/// - text: texto original
/// - ignore-articles: se true, remove artigos iniciais
///
/// Exemplo:
/// ```typst
/// #sort-key("A batalha") // Retorna "batalha"
/// #sort-key("Cafe") // Retorna "cafe"
/// ```
#let sort-key(text, ignore-articles: true) = {
  let result = text

  // Remove artigos iniciais se solicitado
  if ignore-articles {
    result = remove-initial-article(result)
  }

  // Remove acentos (simplificado - Typst nao tem suporte nativo)
  // Para ordenacao correta, o texto ja deve estar normalizado

  // Converte para minusculas
  lower(result.trim())
}

/// Compara duas strings para ordenacao alfabetica conforme NBR 6033
/// Metodo: palavra por palavra, e dentro de cada palavra, letra por letra
///
/// Retorna:
/// - -1 se a < b
/// - 0 se a == b
/// - 1 se a > b
///
/// Exemplo:
/// ```typst
/// #compare-strings("Monte Alegre", "Monteiro") // -1 (Monte Alegre vem antes)
/// ```
#let compare-strings(a, b) = {
  let key-a = sort-key(a)
  let key-b = sort-key(b)

  if key-a < key-b { -1 }
  else if key-a > key-b { 1 }
  else { 0 }
}

/// Ordena uma lista de strings conforme NBR 6033
///
/// Parametros:
/// - items: lista de strings a ordenar
/// - ignore-articles: se true, ignora artigos iniciais na ordenacao
/// - key: funcao para extrair chave de ordenacao (opcional)
///
/// Exemplo:
/// ```typst
/// #let lista = ("O gato", "A casa", "Zebra", "Arvore")
/// #sort-alphabetically(lista)
/// // Resultado: ("Arvore", "A casa", "O gato", "Zebra")
/// ```
#let sort-alphabetically(items, ignore-articles: true, key: none) = {
  if key != none {
    items.sorted(key: it => sort-key(key(it), ignore-articles: ignore-articles))
  } else {
    items.sorted(key: it => sort-key(it, ignore-articles: ignore-articles))
  }
}

/// Tipos de entrada para ordenacao de homografas conforme NBR 6033
/// Ordem: autor proprio > autor entidade > assunto > titulo
#let entry-types = (
  author-person: 1,    // Autor (nome proprio)
  author-entity: 2,    // Autor (entidade coletiva)
  subject: 3,          // Assunto
  title: 4,            // Titulo
)

/// Cria entrada para lista ordenada com tipo especificado
///
/// Parametros:
/// - text: texto da entrada
/// - entry-type: tipo da entrada (usar constantes de entry-types)
///
/// Exemplo:
/// ```typst
/// #let entradas = (
///   make-entry("Brasil, Victor", entry-type: entry-types.author-person),
///   make-entry("Brasil - Historia", entry-type: entry-types.subject),
///   make-entry("Brasil, Ministerio", entry-type: entry-types.author-entity),
/// )
/// ```
#let make-entry(text, entry-type: entry-types.title) = {
  (text: text, entry-type: entry-type)
}

/// Ordena entradas homografas conforme NBR 6033
/// Quando textos tem mesma grafia, ordena por tipo:
/// 1. Autor (nome proprio)
/// 2. Autor (entidade coletiva)
/// 3. Assunto
/// 4. Titulo
#let sort-homographs(entries) = {
  entries.sorted(key: it => {
    let base-key = sort-key(it.text)
    let type-key = str(it.entry-type)
    base-key + "_" + type-key
  })
}

/// Formata lista ordenada alfabeticamente
///
/// Parametros:
/// - items: lista de strings ou conteudo
/// - numbered: se true, adiciona numeracao
/// - ignore-articles: se true, ignora artigos na ordenacao
///
/// Exemplo:
/// ```typst
/// #alphabetical-list(("Zebra", "Arvore", "Casa"))
/// ```
#let alphabetical-list(items, numbered: false, ignore-articles: true) = {
  let sorted-items = sort-alphabetically(items, ignore-articles: ignore-articles)

  if numbered {
    enum(..sorted-items)
  } else {
    list(..sorted-items)
  }
}

/// Indice alfabetico
/// Cria um indice organizado por letras iniciais
///
/// Parametros:
/// - items: lista de tuplas (termo, pagina) ou strings
/// - show-letters: se true, mostra cabecalhos de letras
///
/// Exemplo:
/// ```typst
/// #alphabetical-index((
///   ("Algoritmo", 15),
///   ("Banco de dados", 23),
///   ("Arvore", 18),
/// ))
/// ```
#let alphabetical-index(items, show-letters: true) = {
  // Ordena os itens
  let sorted = items.sorted(key: it => {
    if type(it) == array {
      sort-key(it.at(0))
    } else {
      sort-key(it)
    }
  })

  let current-letter = ""

  for item in sorted {
    let term = if type(item) == array { item.at(0) } else { item }
    let page = if type(item) == array and item.len() > 1 { item.at(1) } else { none }

    // Obtem primeira letra (sem acento, maiuscula)
    let first-letter = upper(sort-key(term).at(0, default: ""))

    // Mostra cabecalho de letra se mudou
    if show-letters and first-letter != current-letter and first-letter != "" {
      current-letter = first-letter
      v(0.5em)
      text(weight: "bold", size: 12pt, current-letter)
      v(0.3em)
    }

    // Mostra entrada
    if page != none {
      [#term #box(width: 1fr, repeat[.]) #page \ ]
    } else {
      [#term \ ]
    }
  }
}

/// Regras para ordenacao de numerais conforme NBR 6033
/// - Numeros precedem letras
/// - Ordenar por valor numerico
/// - Ordinais seguem seus cardinais correspondentes
///
/// Exemplo de ordem correta:
/// 1, 2, 3, 3., 3o, 8, 8., 8o, 9, 10, 100, 1000
#let extract-number(text) = {
  // Tenta extrair numero do inicio do texto
  let digits = ""
  for char in text.codepoints() {
    if "0123456789".contains(char) {
      digits += char
    } else {
      break
    }
  }
  if digits.len() > 0 {
    int(digits)
  } else {
    none
  }
}

/// Verifica se texto comeca com numero
#let starts-with-number(text) = {
  if text.len() == 0 { return false }
  let first = text.at(0)
  "0123456789".contains(first)
}

/// Ordena lista mista de numeros e texto conforme NBR 6033
/// Numeros vem antes de letras, ordenados por valor
#let sort-mixed(items) = {
  // Separa itens que comecam com numero dos que comecam com letra
  let numeric = items.filter(it => starts-with-number(str(it)))
  let alpha = items.filter(it => not starts-with-number(str(it)))

  // Ordena numericos por valor
  let sorted-numeric = numeric.sorted(key: it => {
    let num = extract-number(str(it))
    if num != none { num } else { 0 }
  })

  // Ordena alfabeticos normalmente
  let sorted-alpha = sort-alphabetically(alpha)

  // Junta: numeros primeiro, depois letras
  sorted-numeric + sorted-alpha
}
