// Metadados compartilhados entre template e elementos
//
// Permite que dados() armazene metadados em state e que
// elementos (capa, folha-rosto, resumo, etc.) os leiam
// automaticamente, sem repetição.

/// State global com metadados do documento
#let abnt-metadata = state("abnt-metadata", (:))

/// Resolve um parâmetro: usa o valor explícito se != none,
/// senão busca no state, senão retorna fallback.
/// IMPORTANTE: deve ser chamado dentro de um bloco `context`.
#let _resolve(explicit, key, fallback: none) = {
  if explicit != none {
    explicit
  } else {
    let meta = abnt-metadata.get()
    let val = meta.at(key, default: none)
    if val != none { val } else { fallback }
  }
}

// Verifica se um valor é considerado "vazio" (nada útil):
// none, string vazia "", ou array vazio ()
#let _vazio(val) = {
  val == none or val == "" or val == ()
}

/// Armazena metadados do documento no state global.
/// Os elementos (capa, folha-rosto, resumo, etc.) leem esses dados automaticamente.
/// Valores vazios (none, "" e ()) são ignorados para não poluir o state.
///
/// - titulo: título do trabalho
/// - subtitulo: subtítulo (opcional)
/// - autor: nome do autor (singular, para templates de autor único)
/// - autores: lista de autores (array de dicts, para templates multi-autor)
/// - instituicao: nome da instituição
/// - faculdade: faculdade/unidade
/// - programa: programa de pós-graduação
/// - local: cidade
/// - ano: ano de depósito
/// - natureza: natureza do trabalho
/// - objetivo: objetivo
/// - area: área de concentração
/// - orientador: orientador
/// - coorientador: coorientador (opcional)
/// - palavras-chave: palavras-chave em português
/// - palavras-chave-en: keywords em inglês
#let dados(
  titulo: none,
  subtitulo: none,
  autor: none,
  autores: none,
  instituicao: none,
  faculdade: none,
  programa: none,
  local: none,
  ano: none,
  natureza: none,
  objetivo: none,
  area: none,
  orientador: none,
  coorientador: none,
  palavras-chave: none,
  palavras-chave-en: none,
  ..args,
) = {
  // Filtrar valores vazios (none, "", ()) para não poluir o state
  let campos = (
    "titulo": titulo,
    "subtitulo": subtitulo,
    "autor": autor,
    "autores": autores,
    "instituicao": instituicao,
    "faculdade": faculdade,
    "programa": programa,
    "local": local,
    "ano": ano,
    "natureza": natureza,
    "objetivo": objetivo,
    "area": area,
    "orientador": orientador,
    "coorientador": coorientador,
    "palavras-chave": palavras-chave,
    "palavras-chave-en": palavras-chave-en,
  )
  let meta = (:)
  for (chave, valor) in campos {
    if not _vazio(valor) { meta.insert(chave, valor) }
  }

  // Avisar sobre parâmetros nomeados desconhecidos (typos do usuário)
  if args.named().len() > 0 {
    panic("dados(): parâmetros desconhecidos: " + repr(args.named().keys()) + ". Verifique a ortografia.")
  }

  // Configurar metadados do PDF
  if not _vazio(titulo) or not _vazio(autor) {
    set document(
      title: if not _vazio(titulo) { titulo } else { "" },
      author: if not _vazio(autor) { autor } else { "" },
    )
  }

  abnt-metadata.update(old => {
    old + meta
  })

  // Passa body adiante (permite #show: dados.with(...))
  // Em show rules, Typst passa o body do documento como único argumento posicional.
  if args.pos().len() > 0 {
    args.pos().first()
  }
}

/// Converte valor para string de forma segura.
/// Aceita int, float, string e content sem erro.
/// Para content, retorna o próprio content (renderizável em Typst).
#let _str-safe(val) = {
  if type(val) == str { val }
  else if type(val) == int or type(val) == float { str(val) }
  else if val == none { "" }
  else if type(val) == content { val }
  else { str(val) }
}

/// Renderiza título e subtítulo no padrão ABNT.
/// Título em maiúsculas negrito + ":" + subtítulo em tamanho diferenciado.
///
/// - titulo: título principal
/// - subtitulo: subtítulo (opcional)
/// - tamanho-titulo: tamanho da fonte do título (padrão: 14pt)
/// - tamanho-subtitulo: tamanho da fonte do subtítulo (padrão: 14pt)
#let _render-titulo(
  titulo,
  subtitulo: none,
  tamanho-titulo: 14pt,
  tamanho-subtitulo: 14pt,
) = {
  if titulo != none {
    if subtitulo != none {
      text(weight: "bold", size: tamanho-titulo, upper(titulo) + ":")
      linebreak()
      text(size: tamanho-subtitulo, subtitulo)
    } else {
      text(weight: "bold", size: tamanho-titulo, upper(titulo))
    }
  }
}
