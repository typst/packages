// Abreviacao de titulos de periodicos conforme NBR 6032:1989
// Abreviacao de titulos de periodicos e publicacoes seriadas

/// Dicionario de abreviaturas padrao NBR 6032:1989
/// Formato: palavra -> abreviatura
#let abbreviation-dict = (
  // A
  "academia": "Acad.",
  "administracao": "Adm.",
  "agricultura": "Agric.",
  "anais": "An.",
  "analise": "Anal.",
  "anuario": "Anu.",
  "aplicado": "apl.",
  "aplicada": "apl.",
  "arquivo": "Arq.",
  "associacao": "Assoc.",
  "atualidade": "Atual.",
  "atualidades": "Atual.",

  // B
  "biblioteca": "Bibl.",
  "bibliografico": "bibliogr.",
  "bibliografica": "bibliogr.",
  "bibliografia": "Bibliogr.",
  "biologia": "Biol.",
  "biologico": "biol.",
  "biologica": "biol.",
  "boletim": "B.",
  "brasileiro": "bras.",
  "brasileira": "bras.",

  // C
  "caderno": "Cad.",
  "cadernos": "Cad.",
  "ciencia": "Ci.",
  "ciencias": "Ci.",
  "cientifico": "cient.",
  "cientifica": "cient.",
  "colecao": "Col.",
  "comercio": "Com.",
  "comercial": "com.",
  "comunicacao": "Comun.",
  "comunicacoes": "Comun.",
  "congresso": "Congr.",
  "cultura": "Cult.",
  "cultural": "cult.",

  // D
  "desenvolvimento": "Desenv.",
  "diario": "D.",
  "direito": "Dir.",
  "documentacao": "Doc.",

  // E
  "edicao": "Ed.",
  "editora": "Ed.",
  "educacao": "Educ.",
  "educacional": "educ.",
  "engenharia": "Eng.",
  "escola": "Esc.",
  "escolar": "esc.",
  "estatistica": "Estat.",
  "estatistico": "estat.",
  "estudo": "Est.",
  "estudos": "Est.",
  "economia": "Econ.",
  "economico": "econ.",
  "economica": "econ.",

  // F
  "faculdade": "Fac.",
  "fasciculo": "Fasc.",
  "federacao": "Fed.",
  "federal": "fed.",
  "filosofia": "Fil.",
  "filosofico": "filos.",
  "filosofica": "filos.",
  "folha": "F.",
  "fundacao": "Fund.",

  // G
  "gazeta": "G.",
  "geografia": "Geogr.",
  "geografico": "geogr.",
  "geografica": "geogr.",
  "geologia": "Geol.",
  "geologico": "geol.",
  "geologica": "geol.",

  // H
  "historia": "Hist.",
  "historico": "hist.",
  "historica": "hist.",
  "hospital": "Hosp.",
  "hospitalar": "hosp.",

  // I
  "ilustracao": "Il.",
  "ilustrado": "il.",
  "ilustrada": "il.",
  "indice": "Ind.",
  "industria": "Industr.",
  "industrial": "industr.",
  "informacao": "Inf.",
  "informacoes": "Inf.",
  "informativo": "inform.",
  "informativa": "inform.",
  "instituto": "Inst.",
  "internacional": "Inter.",

  // J
  "jornal": "J.",
  "juridico": "jur.",
  "juridica": "jur.",

  // L
  "laboratorio": "Lab.",
  "legislacao": "Legisl.",
  "legislativo": "legisl.",
  "legislativa": "legisl.",
  "literatura": "Lit.",
  "literario": "lit.",
  "literaria": "lit.",

  // M
  "medicina": "Med.",
  "medico": "med.",
  "medica": "med.",
  "memoria": "Mem.",
  "memorias": "Mem.",
  "mensal": "mens.",
  "ministerio": "Minist.",
  "ministerial": "minist.",
  "municipal": "mun.",
  "musica": "Mus.",
  "musical": "mus.",
  "museu": "Mus.",

  // N
  "nacional": "nac.",
  "noticia": "Not.",
  "noticias": "Not.",
  "numero": "Num.",

  // O
  "observacao": "Obs.",
  "observacoes": "Obs.",
  "observatorio": "Obs.",
  "oficial": "of.",
  "organizacao": "Org.",

  // P
  "pagina": "Pag.",
  "paginas": "Pag.",
  "pesquisa": "Pesq.",
  "pesquisas": "Pesq.",
  "politica": "Pol.",
  "politico": "pol.",
  "producao": "Prod.",
  "publicacao": "Publ.",
  "publicacoes": "Publ.",
  "paulista": "paul.",

  // Q
  "quimica": "Quim.",
  "quimico": "quim.",

  // R
  "referencia": "Ref.",
  "referencias": "Ref.",
  "regional": "reg.",
  "relatorio": "Rel.",
  "relatorios": "Rel.",
  "resumo": "Res.",
  "resumos": "Res.",
  "revista": "R.",

  // S
  "secretaria": "Secr.",
  "seminario": "Semin.",
  "seminarios": "Semin.",
  "serie": "Ser.",
  "servico": "Serv.",
  "servicos": "Serv.",
  "sociedade": "Soc.",
  "sociologia": "Sociol.",
  "sociologico": "sociol.",
  "sociologica": "sociol.",
  "suplemento": "Supl.",

  // T
  "tecnica": "Tecn.",
  "tecnico": "tecn.",
  "tecnologia": "Tecnol.",
  "tecnologico": "tecnol.",
  "tecnologica": "tecnol.",
  "trabalho": "Trab.",
  "trabalhos": "Trab.",
  "trimestral": "trim.",

  // U
  "universidade": "Univ.",
  "universitario": "univ.",
  "universitaria": "univ.",

  // V
  "volume": "Vol.",
  "veterinaria": "Vet.",
  "veterinario": "vet.",
)

/// Palavras que nao devem ser abreviadas (menos de 5 letras ou excecoes)
#let no-abbreviate = (
  "de", "da", "do", "das", "dos",
  "e", "ou", "para", "por", "com", "sem",
  "a", "o", "as", "os", "um", "uma", "uns", "umas",
  "em", "no", "na", "nos", "nas",
  "ao", "aos",
  "lei", "ato", "art",
)

/// Artigos, preposicoes e conjuncoes a suprimir (exceto quando necessarios)
#let suppressible-words = (
  "de", "da", "do", "das", "dos",
  "a", "o", "as", "os",
  "um", "uma", "uns", "umas",
  "para", "por", "com", "sem",
  "em", "no", "na", "nos", "nas",
  "ao", "aos",
)

/// Verifica se uma palavra deve ser suprimida
/// - word: palavra a verificar
#let should-suppress(word) = {
  let lower-word = lower(word)
  // Suprimir se for a primeira palavra (artigo inicial)
  lower-word in suppressible-words
}

/// Verifica se uma palavra pode ser abreviada
/// - word: palavra a verificar
#let can-abbreviate(word) = {
  let lower-word = lower(word)

  // Nao abreviar palavras curtas (menos de 5 letras)
  if word.len() < 5 and lower-word not in abbreviation-dict {
    return false
  }

  // Nao abreviar se estiver na lista de excecoes
  if lower-word in no-abbreviate {
    return false
  }

  true
}

/// Obtem a abreviatura de uma palavra
/// - word: palavra a abreviar
/// - preserve-case: preservar maiusculas do original
#let get-abbreviation(word, preserve-case: true) = {
  let lower-word = lower(word)

  if lower-word in abbreviation-dict {
    let abbrev = abbreviation-dict.at(lower-word)

    // Preservar maiuscula inicial se a palavra original tinha
    if preserve-case and word.len() > 0 {
      let first-char = word.at(0)
      if first-char == upper(first-char) {
        // Primeira letra era maiuscula
        if abbrev.len() > 0 {
          return upper(abbrev.at(0)) + abbrev.slice(1)
        }
      }
    }

    return abbrev
  }

  // Palavra nao encontrada no dicionario
  // Tentar abreviar por truncamento (metodo normal)
  if word.len() >= 5 {
    // Verificar sufixos especiais
    if lower-word.ends-with("logia") {
      // Abreviar ate "l": Biologia -> Biol.
      let base = word.slice(0, word.len() - 4)
      return base + "."
    } else if lower-word.ends-with("grafia") {
      // Abreviar ate "gr": Geografia -> Geogr.
      let base = word.slice(0, word.len() - 4)
      return base + "."
    } else if lower-word.ends-with("nomia") {
      // Abreviar ate "n": Economia -> Econ.
      let base = word.slice(0, word.len() - 4)
      return base + "."
    }
  }

  // Retornar palavra original se nao puder abreviar
  word
}

/// Abrevia um titulo de periodico conforme NBR 6032:1989
/// - title: titulo completo do periodico
/// - suppress-articles: suprimir artigos e preposicoes (default: true)
///
/// Exemplo:
/// ```typst
/// #abbreviate-title("Revista Brasileira de Biologia")
/// // Resultado: "R. bras. Biol."
/// ```
#let abbreviate-title(title, suppress-articles: true) = {
  let words = title.split(" ")
  let result = ()
  let is-first = true

  for word in words {
    let lower-word = lower(word)

    // Pular palavras vazias
    if word.len() == 0 {
      continue
    }

    // Verificar se deve suprimir
    if suppress-articles and lower-word in suppressible-words {
      // Manter "e" entre palavras compostas
      if lower-word == "e" and not is-first {
        result.push("e")
      }
      is-first = false
      continue
    }

    // Verificar se pode abreviar
    if can-abbreviate(word) {
      result.push(get-abbreviation(word))
    } else {
      result.push(word)
    }

    is-first = false
  }

  result.join(" ")
}

/// Formata plural de abreviatura com traco-de-uniao
/// Conforme NBR 6032: acrescentar traco + ultima letra do plural
/// Exemplo: Academias -> Acad-s
/// - singular-abbrev: abreviatura no singular
/// - plural-suffix: sufixo do plural (default: "s")
#let abbreviate-plural(singular-abbrev, plural-suffix: "s") = {
  // Remover ponto final se houver
  let abbrev = singular-abbrev
  if abbrev.ends-with(".") {
    abbrev = abbrev.slice(0, abbrev.len() - 1)
  }

  // Adicionar traco e sufixo (sem ponto)
  abbrev + "-" + plural-suffix
}

/// Formata abreviatura de palavra composta
/// Exemplo: medico-sanitarias -> med.-sanit.
/// - compound-word: palavra composta com hifen
#let abbreviate-compound(compound-word) = {
  let parts = compound-word.split("-")
  let abbreviated-parts = parts.map(part => get-abbreviation(part))
  abbreviated-parts.join("-")
}

/// Formata titulo generico com identificacao do editor
/// Para quando dois periodicos tem o mesmo titulo generico
/// Exemplo: "Boletim Estatistico [IBGE]" -> "B. estat. IBGE"
/// - title: titulo do periodico
/// - editor: nome ou sigla do editor
#let abbreviate-with-editor(title, editor) = {
  let abbrev-title = abbreviate-title(title)
  [#abbrev-title #editor]
}

/// Lista de exemplos de abreviaturas conforme NBR 6032
#let abbreviation-examples = (
  "Revista Brasileira de Biologia": "R. bras. Biol.",
  "Revista Brasileira de Geografia": "R. bras. Geogr.",
  "Revista Brasileira de Economia": "R. bras. Econ.",
  "Memorias do Instituto Oswaldo Cruz": "Mem. Inst. Oswaldo Cruz",
  "Boletim do INT": "B. INT",
  "Ciencia e Cultura": "Ci. e Cult.",
  "Anais da Academia Brasileira de Ciencias": "An. Acad. bras. Ci.",
)
