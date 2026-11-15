// Ordenacao alfabetica conforme NBR 6033:1989
// Criterios de aplicacao da ordem alfabetica em listas, indices, catalogos, bibliografias

/// Artigos definidos por idioma (nao considerar na ordenacao)
#let definite-articles = (
  // Alemao
  "der", "die", "das",
  // Arabe (ligados por hifen)
  "al-", "el-",
  // Catalao
  "els",
  // Holandes
  "het",
  // Hungaro
  "az",
  // Gales
  "yr",
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
/// Conforme NBR 6033 (3.1.3): letras com acentos sao alfabetadas sem as modificacoes
/// (ä, ã, ñ, ü valem a, a, n, u). Tambem trata ç, ø, œ, æ e ß (-> ss) e descarta as
/// marcas combinantes (texto em NFD). Maiusculas e minusculas sao preservadas.
///
/// Exemplo:
/// ```typst
/// #remove-accents("Müller") // Retorna "Muller"
/// #remove-accents("café") // Retorna "cafe"
/// ```
#let remove-accents(text) = {
  // Mapeamento de caracteres acentuados para seus equivalentes
  let accent-map = (
    "ª": "a", "à": "a", "á": "a", "â": "a", "ã": "a", "ä": "a",
    "å": "a", "ā": "a", "ă": "a", "ą": "a", "À": "A", "Á": "A",
    "Â": "A", "Ã": "A", "Ä": "A", "Å": "A", "Ā": "A", "Ă": "A",
    "Ą": "A", "æ": "ae", "Æ": "AE", "ç": "c", "ć": "c", "ĉ": "c",
    "ċ": "c", "č": "c", "Ç": "C", "Ć": "C", "Ĉ": "C", "Ċ": "C",
    "Č": "C", "ð": "d", "ď": "d", "đ": "d", "Ð": "D", "Ď": "D",
    "Đ": "D", "è": "e", "é": "e", "ê": "e", "ë": "e", "ē": "e",
    "ĕ": "e", "ė": "e", "ę": "e", "ě": "e", "È": "E", "É": "E",
    "Ê": "E", "Ë": "E", "Ē": "E", "Ĕ": "E", "Ė": "E", "Ę": "E",
    "Ě": "E", "ĝ": "g", "ğ": "g", "ġ": "g", "ģ": "g", "Ĝ": "G",
    "Ğ": "G", "Ġ": "G", "Ģ": "G", "ĥ": "h", "ħ": "h", "Ĥ": "H",
    "Ħ": "H", "ì": "i", "í": "i", "î": "i", "ï": "i", "ĩ": "i",
    "ī": "i", "ĭ": "i", "į": "i", "ı": "i", "Ì": "I", "Í": "I",
    "Î": "I", "Ï": "I", "Ĩ": "I", "Ī": "I", "Ĭ": "I", "Į": "I",
    "İ": "I", "ĵ": "j", "Ĵ": "J", "ķ": "k", "Ķ": "K", "ĺ": "l",
    "ļ": "l", "ľ": "l", "ł": "l", "Ĺ": "L", "Ļ": "L", "Ľ": "L",
    "Ł": "L", "ñ": "n", "ń": "n", "ņ": "n", "ň": "n", "Ñ": "N",
    "Ń": "N", "Ņ": "N", "Ň": "N", "º": "o", "ò": "o", "ó": "o",
    "ô": "o", "õ": "o", "ö": "o", "ø": "o", "ō": "o", "ŏ": "o",
    "ő": "o", "Ò": "O", "Ó": "O", "Ô": "O", "Õ": "O", "Ö": "O",
    "Ø": "O", "Ō": "O", "Ŏ": "O", "Ő": "O", "œ": "oe", "Œ": "OE",
    "ŕ": "r", "ŗ": "r", "ř": "r", "Ŕ": "R", "Ŗ": "R", "Ř": "R",
    "ś": "s", "ŝ": "s", "ş": "s", "š": "s", "Ś": "S", "Ŝ": "S",
    "Ş": "S", "Š": "S", "ß": "ss", "ţ": "t", "ť": "t", "Ţ": "T",
    "Ť": "T", "ù": "u", "ú": "u", "û": "u", "ü": "u", "ũ": "u",
    "ū": "u", "ŭ": "u", "ů": "u", "ű": "u", "ų": "u", "Ù": "U",
    "Ú": "U", "Û": "U", "Ü": "U", "Ũ": "U", "Ū": "U", "Ŭ": "U",
    "Ů": "U", "Ű": "U", "Ų": "U", "ŵ": "w", "Ŵ": "W", "ý": "y",
    "ÿ": "y", "ŷ": "y", "Ý": "Y", "Ŷ": "Y", "Ÿ": "Y", "ź": "z",
    "ż": "z", "ž": "z", "Ź": "Z", "Ż": "Z", "Ž": "Z",
  )
  text
    .replace(regex("[\u{300}-\u{36f}]"), "")
    .replace(regex("[" + accent-map.keys().join() + "]"), m => accent-map.at(m.text))
}

/// Remove artigo inicial para ordenacao
/// Conforme NBR 6033 (3.4): artigos iniciais nao sao levados em consideracao,
/// a nao ser que facam parte integrante de um nome.
///
/// - Artigo colado por apostrofo ou hifen sai (compara-se so o prefixo ate o
///   apostrofo/hifen: "L'enfant" -> "enfant", "al-Khwarizmi" -> "Khwarizmi").
/// - Nome inicial no formato "Sobrenome, Prenome" com artigo estrangeiro e uma
///   so palavra antes da virgula ("La Fontaine, Jean de", "Le Corbusier, Charles")
///   mantem o artigo, pois ele e parte do sobrenome. Artigos em portugues e
///   ingles (o, a, os, as, um, uma, the, an...) nunca sao mantidos por essa regra.
///
/// Parametros:
/// - text: texto a processar
/// - keep-articles-in-names: se true, mantem artigos que fazem parte de nomes proprios
///   (heuristica: segunda palavra comeca com maiuscula, ex: "La Rochefoucault")
///
/// Exemplo:
/// ```typst
/// #remove-initial-article("A batalha") // Retorna "batalha"
/// #remove-initial-article("The book") // Retorna "book"
/// #remove-initial-article("L'enfant créateur") // Retorna "enfant créateur"
/// ```
#let remove-initial-article(text, keep-articles-in-names: false) = {
  let words = text.split(" ")
  if words.len() == 0 { return text }

  // Artigo ligado a palavra seguinte por apostrofo ou hifen: l'enfant, al-Khwarizmi
  let glued = words.at(0).match(regex("^([^'’\-]+['’\-])(.+)$"))
  if glued != none {
    let prefix = lower(glued.captures.at(0)).replace("’", "'")
    if prefix in all-articles {
      return text.slice(glued.captures.at(0).len())
    }
    return text
  }

  let first-word = lower(words.at(0))

  // Verifica se primeira palavra e um artigo
  if first-word in all-articles {
    // "La Fontaine, Jean de": artigo estrangeiro + uma palavra + virgula = sobrenome
    let portugues-ou-ingles = ("o", "a", "os", "as", "um", "uma", "uns", "umas", "the", "an")
    if words.len() > 1 and words.at(1).ends-with(",") and first-word not in portugues-ou-ingles {
      return text
    }
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
    // Artigo sozinho (verbete de uma palavra) nao e removido
    if words.len() == 1 { return text }
    // Remove o artigo
    words.slice(1).join(" ")
  } else {
    text
  }
}

/// Verifica se uma palavra e sigla ou inicial (NBR 6033, 3.3): duas ou mais
/// letras, todas maiusculas (ASA, ISO, I.A.P.A.S), ou uma letra maiuscula
/// seguida de ponto (C.).
#let _is-sigla(word) = {
  let letters = word.clusters().filter(c => c.match(regex("^\p{L}$")) != none)
  if letters.len() >= 2 {
    letters.all(c => c == upper(c) and c != lower(c))
  } else if letters.len() == 1 {
    word.ends-with(".") and letters.at(0) == upper(letters.at(0))
  } else {
    false
  }
}

/// Gera chave de ordenacao para um texto conforme NBR 6033
///
/// DEVOLVE UMA STRING, que pode ser usada direto em `array.sorted(key: ...)`:
/// `lista.sorted(key: sort-key)` ou `lista.sorted(key: it => sort-key(it.nome))`.
/// A chave segue estes criterios (strings sao comparadas por ponto de codigo):
/// - Acentos e sinais diacriticos sao ignorados (3.1.3: Müller = Muller)
/// - Artigo inicial e ignorado (3.4), ver `remove-initial-article`
/// - Maiusculas e minusculas valem o mesmo; o espaco e o sinal de menor valor
///   (palavra por palavra, 4.1)
/// - Simbolos e sinais nao alfabeticos sao ignorados (3.6.1: `£ 100 por dia`
///   ordena pelo 100)
/// - Numeros sao lidos por valor e precedem as letras (3.5.1): `1.000.000` e um
///   numero so; o ordinal vem logo apos o cardinal de mesmo valor (3.5.1.1):
///   8, 8., 8º, 8th, 9
/// - Siglas e iniciais (3.3) antecedem letras e palavras iguais nao usadas como
///   sigla (`ASA` antes de `asa`): o desempate vai ao final da chave
/// A chave NAO e legivel: serve so para comparar (nao a imprima nem tire a
/// primeira letra dela; para o titulo de cada letra use `sort-initial`).
///
/// Parametros:
/// - text: texto original (string)
/// - ignore-articles: se true, remove artigos iniciais
/// - keep-articles-in-names: ver `remove-initial-article`
///
/// Exemplo:
/// ```typst
/// #("Zebra", "Álvaro", "asa", "ASA", "8º", "8", "9").sorted(key: sort-key)
/// // Resultado: ("8", "8º", "9", "Álvaro", "ASA", "asa", "Zebra")
/// ```
#let sort-key(text, ignore-articles: true, keep-articles-in-names: false) = {
  let result = text.trim()

  // Remove artigos iniciais se solicitado
  if ignore-articles {
    result = remove-initial-article(result, keep-articles-in-names: keep-articles-in-names)
  }

  // Palavras com letra ou numero (as demais, so de simbolos, nao contam), para o desempate das siglas
  let words = result.split(regex("\s+")).filter(w => w.match(regex("[\p{L}\p{N}]")) != none)
  let flags = words.map(w => if _is-sigla(w) { "0" } else { "1" }).join()

  // Numeros: 2 digitos com a quantidade de algarismos + algarismos sem zeros a esquerda
  // + 1 digito do ordinal (0 cardinal, 1 ponto, 2 º/ª/°, 3 st/nd/rd/th)
  let number = regex("(\d{1,3}(?:\.\d{3})+)|(\d+)[.,](\d+)|(\d+)(\.|º|ª|°|st\b|nd\b|rd\b|th\b)?")
  let encode(digits, rank, fraction) = {
    let digits = digits.trim("0", at: start)
    if digits == "" { digits = "0" }
    let length = str(calc.min(digits.len(), 99))
    (if length.len() < 2 { "0" } else { "" }) + length + digits + str(rank) + fraction
  }
  result = lower(result).replace(number, m => {
    let c = m.captures
    if c.at(0) != none {
      encode(c.at(0).replace(".", ""), 0, "")
    } else if c.at(1) != none {
      encode(c.at(1), 0, c.at(2))
    } else {
      let suffix = c.at(4)
      let rank = if suffix == none { 0 } else if suffix == "." { 1 } else if suffix in ("º", "ª", "°") { 2 } else { 3 }
      encode(c.at(3), rank, "")
    }
  })

  // Remove acentos e depois os simbolos; o espaco continua separando as palavras
  result = remove-accents(result).replace(regex("[^\p{L}\p{N}\s]"), "")
  result = result.split(regex("\s+")).filter(w => w != "").join(" ")

  result + "\u{1}" + flags
}

/// Letra (ou "0-9") para o titulo de cada grupo de um indice alfabetico:
/// primeira letra do texto sem artigo inicial, acento e simbolos, em maiuscula.
#let sort-initial(text, ignore-articles: true) = {
  let plain = text.trim()
  if ignore-articles { plain = remove-initial-article(plain) }
  let letter = remove-accents(plain).clusters().find(c => c.match(regex("^[\p{L}\p{N}]$")) != none)
  if letter == none { "" } else if letter.match(regex("^\p{N}$")) != none { "0-9" } else { upper(letter) }
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
/// - keep-articles-in-names: ver `remove-initial-article`
///
/// Exemplo:
/// ```typst
/// #let lista = ("O gato", "A casa", "Zebra", "Arvore")
/// #sort-alphabetically(lista)
/// // Resultado: ("Arvore", "A casa", "O gato", "Zebra")
/// ```
#let sort-alphabetically(items, ignore-articles: true, key: none, keep-articles-in-names: false) = {
  if key != none {
    items.sorted(key: it => sort-key(key(it), ignore-articles: ignore-articles, keep-articles-in-names: keep-articles-in-names))
  } else {
    items.sorted(key: it => sort-key(it, ignore-articles: ignore-articles, keep-articles-in-names: keep-articles-in-names))
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

/// Ordena entradas homografas conforme NBR 6033 (4.2)
/// Entradas com a mesma entrada principal (o texto antes da primeira virgula ou
/// do primeiro traco com espacos: "Brasil, Vitor", "Brasil - Historia") ficam
/// reunidas e, dentro delas, na ordem:
/// 1. Autor (nome proprio)
/// 2. Autor (entidade coletiva)
/// 3. Assunto
/// 4. Titulo
/// e, em cada tipo, em ordem alfabetica do texto inteiro.
#let sort-homographs(entries) = {
  entries.sorted(key: it => {
    let head = it.text.split(regex(",| [-–—] ")).at(0)
    sort-key(head) + "\u{2}" + str(it.entry-type) + "\u{2}" + sort-key(it.text)
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

    // Obtem primeira letra (sem acento, maiuscula; numeros em "0-9")
    let first-letter = sort-initial(term)

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
/// Numeros vem antes de letras, ordenados por valor (a chave de `sort-key` ja
/// trata numeros, ordinais e simbolos)
#let sort-mixed(items) = {
  items.sorted(key: it => sort-key(str(it)))
}
