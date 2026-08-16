// Sistema de citacoes e referencias conforme NBR 6023:2018 e NBR 10520:2023
//
// ============================================================================
// SISTEMAS DE CHAMADA (NBR 10520:2023, secao 4)
// ============================================================================
//
// A NBR 10520:2023 permite dois sistemas de chamada para citacoes:
//
// 1. SISTEMA AUTOR-DATA (este arquivo)
//    - Formato: (Autor, ano) ou (Autor, ano, p. X)
//    - Mais comum em trabalhos academicos no Brasil
//    - Pode ser usado com notas de rodape
//
// 2. SISTEMA NUMERICO (ver numeric.typ)
//    - Formato: (1) ou (1, p. X) ou sobrescrito
//    - Permitido pela norma, inspirado no abntex2-num.bst
//    - NAO pode ser usado com notas de rodape
//
// Escolha UM sistema e use consistentemente em todo o trabalho.
//
// ============================================================================

// Este modulo fornece funcoes auxiliares para o sistema AUTOR-DATA
// Para referências completas, usar arquivo .bib com estilo CSL ABNT
// Para sistema numerico, ver: numeric.typ

// ============================================================================
// REGRA DE CAIXA NA CHAMADA (NBR 10520:2023)
// ============================================================================
// No sistema autor-data, o sobrenome na CHAMADA (na sentença ou entre
// parênteses) leva apenas a INICIAL maiúscula — ex.: (Silva, 2023, p. 45).
// A CAIXA ALTA do sobrenome entre parênteses era regra da NBR 10520:2002
// (revogada) e permanece SOMENTE na lista de referências (NBR 6023:2018,
// funções ref-* abaixo). O autor informa a grafia correta da chamada
// (ex.: "Silva", "Brasil", "IBGE", "Organização Mundial da Saúde").

// Sufixo de localização da fonte: , v. X, p. Y, <localização livre>
// (NBR 10520:2023, 5.1 — volume/tomo antes da página; fontes não paginadas)
#let _abnt-localizacao(volume: none, pagina: none, localizacao: none) = {
  if volume != none { [, v. #volume] }
  if pagina != none { [, p. #pagina] }
  if localizacao != none { [, #localizacao] }
}

// Sufixo de expressão final da citação: , grifo nosso / , tradução nossa
// (NBR 10520:2023, 5.1 — grifo/tradução indicados ao FINAL, dentro do parêntese)
#let _abnt-expressao(grifo: none, traducao: none) = {
  if grifo != none { [, grifo #grifo] }
  if traducao != none { [, tradução #traducao] }
}

/// Citação autor-data entre parênteses — (Silva, 2023, p. 45)
/// - autor: sobrenome (string), com apenas a inicial maiúscula (ou sigla)
/// - ano: ano da publicação (int ou string)
/// - pagina: página (opcional). Use string para intervalos: "42-43"
/// - volume: volume/tomo antes da página (opcional) — (Senac, 1979, v. 1, p. 16)
/// - localizacao: fontes não paginadas (opcional) — [cap. V, art. 49, inc. I]
/// - grifo: "nosso" ou "do autor" (opcional) — (..., grifo nosso)
/// - traducao: "nossa" ou "própria" (opcional) — (..., tradução nossa)
#let citar(
  autor,
  ano,
  pagina: none,
  volume: none,
  localizacao: none,
  grifo: none,
  traducao: none,
) = {
  [(#autor, #ano#_abnt-localizacao(volume: volume, pagina: pagina, localizacao: localizacao)#_abnt-expressao(grifo: grifo, traducao: traducao))]
}

/// Citação com autor na sentença — "Segundo Silva (2023, p. 45)..."
/// Página/volume são opcionais (NBR 10520:2023: "Autor (ano, p. X)")
#let citar-autor(autor, ano, pagina: none, volume: none) = {
  [#autor (#ano#_abnt-localizacao(volume: volume, pagina: pagina))]
}

/// Citação indireta (paráfrase) — (Silva, 2023)
/// Página/localização é opcional na citação indireta (NBR 10520:2023, 5.2)
#let citar-indireto(autor, ano, pagina: none) = {
  [(#autor, #ano#if pagina != none [, p. #pagina])]
}

/// Citação de citação (apud) — fonte original apud fonte consultada
/// Na lista de referências, inclui-se SOMENTE a fonte consultada.
/// - pagina-original: página na fonte original (opcional)
/// - pagina: página na fonte consultada (opcional)
#let citar-apud(
  autor-original,
  ano-original,
  autor-secundario,
  ano-secundario,
  pagina-original: none,
  pagina: none,
) = {
  [(#autor-original, #ano-original#if pagina-original != none [, p. #pagina-original] apud #autor-secundario, #ano-secundario#if pagina != none [, p. #pagina])]
}

/// Vários autores de uma MESMA obra (até 3) — (Silva; Santos; Costa, 2023)
#let citar-multiplos(autores, ano, pagina: none) = {
  let formatted = autores.join("; ")
  [(#formatted, #ano#if pagina != none [, p. #pagina])]
}

/// Várias OBRAS citadas simultaneamente (autores/anos distintos)
/// Separadas por ponto e vírgula, em ordem alfabética (NBR 10520:2023, 4.1)
/// — (Fonseca, 1997; Paiva, 1997; Silva, 1997)
/// - obras: lista de pares (autor, ano) ou trios (autor, ano, pagina)
#let citar-varios(obras) = {
  let parts = obras.map(o => {
    if o.len() >= 3 and o.at(2) != none [#o.at(0), #o.at(1), p. #o.at(2)]
    else [#o.at(0), #o.at(1)]
  })
  [(#parts.join("; "))]
}

/// Citação com mais de 3 autores (et al.) — (Silva et al., 2023)
#let citar-etal(primeiro-autor, ano, pagina: none) = {
  [(#primeiro-autor et al., #ano#if pagina != none [, p. #pagina])]
}

/// Citação de entidade coletiva — (Brasil, 2023) / (IBGE, 2011, p. 3)
/// Informe o nome por extenso ou a sigla (siglas em CAIXA ALTA) na grafia certa.
#let citar-entidade(entidade, ano, pagina: none) = {
  [(#entidade, #ano#if pagina != none [, p. #pagina])]
}

/// Citação de obra sem autoria (entrada pelo título)
/// Informe a 1ª palavra do título seguida de [...] quando houver mais palavras
/// (NBR 10520:2023, 4.1) — ex.: citar-titulo([Anteprojeto [...]], 1987)
#let citar-titulo(titulo, ano, pagina: none) = {
  [(#titulo, #ano#if pagina != none [, p. #pagina])]
}

// ============================================================================
// CITAÇÕES INTEGRADAS AO .bib  (caminho recomendado — ergonômico)
// ============================================================================
// Com um arquivo .bib + #referencias(...), o nome/ano vêm da entrada e a lista
// de referências é gerada e mantida em sincronia automaticamente. Na maioria
// dos casos basta a sintaxe nativa do Typst, sem nenhuma função:
//   @silva2023            -> (Silva, 2023)
//   @silva2023[p. 45]     -> (Silva, 2023, p. 45)
//   @silva2023@santos2022 -> (Santos, 2022; Silva, 2023)   (várias obras)
//   4+ autores            -> (Cormen et al., 2012)          (et al. automático)
// As funções abaixo cobrem os dois casos que a sintaxe nativa não resolve.

/// Autor na sentença, com página, a partir do .bib — "Silva (2023, p. 45)".
/// Ergonômico: sobrenome e ano vêm da entrada `.bib`; a página é posicional.
///   #pag(<silva2023>, 45)  ->  Silva (2023, p. 45)
///   #pag(<silva2023>)      ->  Silva (2023)
/// - chave: label da entrada, ex.: <silva2023>
/// - pagina (posicional, opcional): número ou intervalo de página
/// - autor (nomeado, opcional): sobrenomes na grafia da sentença. Use para 2–3
///   autores, pois o motor do Typst só sabe juntar nomes com ";" — na sentença a
///   NBR 10520:2023 pede "e" (Lima; Serrano entre parênteses, mas Lima e Serrano
///   na frase). O ano continua vindo do `.bib`.
///   #pag(<lima2024>, autor: "Lima e Serrano")      -> Lima e Serrano (2024)
///   #pag(<lima2024>, 45, autor: "Lima e Serrano")  -> Lima e Serrano (2024, p. 45)
#let pag(chave, autor: none, ..args) = {
  let pagina = if args.pos().len() >= 1 { args.pos().at(0) } else { none }
  if autor != none {
    [#autor (#cite(chave, form: "year")#if pagina != none [, p. #pagina])]
  } else {
    cite(chave, form: "prose", supplement: if pagina != none [p. #pagina])
  }
}

/// Citação de citação (apud) integrada ao .bib.
/// A fonte CONSULTADA é uma chave `.bib` (entra na lista de referências e
/// fornece autor/ano automaticamente); a fonte ORIGINAL, não acessada, é
/// informada como texto, pois NÃO entra na lista (NBR 10520:2023, 5.3).
///   #apud("Freire", 1994, <oliveira2021>, 25)
///     ->  (Freire, 1994 apud Oliveira; Costa, 2021, p. 25)
/// - autor-original, ano-original: dados da fonte não acessada (texto)
/// - chave-consultada: label `<chave>` da obra efetivamente consultada
/// - pagina (posicional, opcional): página na fonte consultada
/// - pagina-original (nomeado, opcional): página na fonte original
#let apud(autor-original, ano-original, chave-consultada, pagina-original: none, ..args) = {
  let pagina = if args.pos().len() >= 1 { args.pos().at(0) } else { none }
  [(#autor-original, #ano-original#if pagina-original != none [, p. #pagina-original] apud #cite(chave-consultada, form: "author"), #cite(chave-consultada, form: "year")#if pagina != none [, p. #pagina])]
}

/// Título da seção de referências
#let referencias-titulo() = {
  heading(level: 1, numbering: none, "REFERÊNCIAS")
}

// Funções para formatação manual de referências
// (usar quando não for possível usar .bib)

/// Formata referência de livro
#let ref-livro(
  autor: none,
  titulo: none,
  subtitulo: none,
  edicao: none,
  local: none,
  editora: none,
  ano: none,
) = {
  set par(
    hanging-indent: 1.25cm,
    first-line-indent: 0pt,
  )

  if autor != none { upper(autor); [. ] }
  if titulo != none { strong(titulo) }
  if subtitulo != none { [: #subtitulo] }
  [. ]
  if edicao != none { [#edicao. ed. ] }
  if local != none { [#local: ] }
  if editora != none { editora }
  if ano != none { [, #ano.] }
}

/// Formata referência de artigo de periódico
#let ref-artigo(
  autor: none,
  titulo: none,
  revista: none,
  local: none,
  volume: none,
  numero: none,
  paginas: none,
  mes: none,
  ano: none,
) = {
  set par(
    hanging-indent: 1.25cm,
    first-line-indent: 0pt,
  )

  if autor != none { upper(autor); [. ] }
  if titulo != none { [#titulo. ] }
  if revista != none { strong(revista) }
  if local != none { [, #local] }
  if volume != none { [, v. #volume] }
  if numero != none { [, n. #numero] }
  if paginas != none { [, p. #paginas] }
  if mes != none { [, #mes] }
  if ano != none { [. #ano.] }
}

/// Formata referência de documento eletrônico
#let ref-online(
  autor: none,
  titulo: none,
  site: none,
  ano: none,
  url: none,
  data-acesso: none,
) = {
  set par(
    hanging-indent: 1.25cm,
    first-line-indent: 0pt,
  )

  if autor != none { upper(autor); [. ] }
  if titulo != none { strong(titulo); [. ] }
  if site != none { [#site, ] }
  if ano != none { ano }
  [. ]
  if url != none { [Disponível em: #url. ] }
  if data-acesso != none { [Acesso em: #data-acesso.] }
}

// Aliases curtos
#let cautor = citar-autor
#let cindireto = citar-indireto
#let capud = citar-apud
#let cmultiplos = citar-multiplos
#let cvarios = citar-varios
#let cetal = citar-etal
#let centidade = citar-entidade
#let ctitulo = citar-titulo
#let ref-titulo = referencias-titulo
