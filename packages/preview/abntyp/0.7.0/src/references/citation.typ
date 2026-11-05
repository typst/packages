// Sistema de citacoes e referencias conforme NBR 6023:2018 e NBR 10520:2023
//
// ============================================================================
// SISTEMAS DE CHAMADA (NBR 10520:2023, secao 6)
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
//    - NAO pode ser usado com notas de rodape (NBR 10520:2023, 6.2.2)
//
// Escolha UM sistema e use consistentemente em todo o trabalho.
//
// ============================================================================

#import "../core/spacing.typ": abnt-leading, abnt-top-edge, abnt-bottom-edge

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
// (NBR 10520:2023, 7.1.3 — volume/tomo antes da página; 7.1.4 — fontes não paginadas)
#let _abnt-localizacao(volume: none, pagina: none, localizacao: none) = {
  if volume != none { [, v. #volume] }
  if pagina != none { [, p. #pagina] }
  if localizacao != none { [, #localizacao] }
}

// Sufixo de expressão final da citação: , grifo nosso / , tradução nossa
// (NBR 10520:2023, 7.1.5 e 7.1.6 — tradução e grifo indicados ao FINAL, dentro do
// parêntese, nesta ordem: ..., tradução nossa, grifo nosso)
#let _abnt-expressao(grifo: none, traducao: none) = {
  if traducao != none { [, tradução #traducao] }
  if grifo != none { [, grifo #grifo] }
}

// Mesmo conteúdo de _abnt-localizacao + _abnt-expressao, mas sem vírgula
// inicial — para uso como `supplement` do #cite() nativo (o motor de
// citação do Typst já insere ", " antes do supplement).
#let _abnt-cite-supplement(volume: none, pagina: none, localizacao: none, grifo: none, traducao: none) = {
  let parts = ()
  if volume != none { parts.push([v. #volume]) }
  if pagina != none { parts.push([p. #pagina]) }
  if localizacao != none { parts.push([#localizacao]) }
  if traducao != none { parts.push([tradução #traducao]) }
  if grifo != none { parts.push([grifo #grifo]) }
  if parts.len() == 0 { none } else { parts.join([, ]) }
}

/// Citação autor-data entre parênteses — (Silva, 2023, p. 45)
/// - autor: sobrenome (string), com apenas a inicial maiúscula (ou sigla).
///   Pode ser um `<chave>` de entrada `.bib` — nesse caso autor/ano vêm do
///   `.bib` (via #cite() nativo), a citação entra automaticamente na
///   bibliografia e o texto renderizado vira link clicável; `ano` é ignorado.
/// - ano: ano da publicação (int ou string). Ignorado se `autor` for `<chave>`.
/// - pagina: página (opcional). Use string para intervalos: "42-43"
/// - volume: volume/tomo antes da página (opcional) — (Senac, 1979, v. 1, p. 16)
/// - localizacao: fontes não paginadas (opcional) — [cap. V, art. 49, inc. I]
/// - grifo: "nosso" ou "próprio" (opcional; NBR 10520:2023, 7.1.5) — (..., grifo nosso)
/// - traducao: "nossa" ou "própria" (opcional) — (..., tradução nossa)
///
///   #citar("Silva", 2023, pagina: "45")   -> (Silva, 2023, p. 45)
///   #citar(<silva2023>, pagina: "45")     -> (Silva, 2023, p. 45), citado no .bib
#let citar(
  autor: none,
  ano: none,
  pagina: none,
  volume: none,
  localizacao: none,
  grifo: none,
  traducao: none,
  ..args,
) = {
  let pos = args.pos()
  if autor == none and pos.len() >= 1 { autor = pos.at(0) }
  if ano == none and pos.len() >= 2 { ano = pos.at(1) }
  if type(autor) == label {
    cite(autor, form: "normal", supplement: _abnt-cite-supplement(volume: volume, pagina: pagina, localizacao: localizacao, grifo: grifo, traducao: traducao))
  } else {
    [(#autor, #ano#_abnt-localizacao(volume: volume, pagina: pagina, localizacao: localizacao)#_abnt-expressao(grifo: grifo, traducao: traducao))]
  }
}

// Autor na sentença (NBR 10520:2023, 6.1.4): o motor do Typst junta os nomes com
// ";" (Lima; Serrano), que vale entre parênteses; na frase a norma pede
// "Lima e Serrano" e "Cruz, Correa e Costa". Troca os ";" só dentro da citação.
#let _abnt-autores-na-frase(corpo) = {
  show regex("[^;()]+(?:; [^;()]+)+"): it => {
    let t = it.text
    let nomes = t.split(";").map(n => n.trim())
    nomes.slice(0, -1).join(", ") + " e " + nomes.last() + if t.ends-with(" ") { " " } else { "" }
  }
  corpo
}

/// Citação com autor na sentença — "Segundo Silva (2023, p. 45)..."
/// Página/volume são opcionais (NBR 10520:2023: "Autor (ano, p. X)")
/// `autor` aceita `<chave>` de entrada `.bib` (ver `citar`); nesse caso
/// equivale a `pag(<chave>)`.
#let citar-autor(autor: none, ano: none, pagina: none, volume: none, ..args) = {
  let pos = args.pos()
  if autor == none and pos.len() >= 1 { autor = pos.at(0) }
  if ano == none and pos.len() >= 2 { ano = pos.at(1) }
  if type(autor) == label {
    _abnt-autores-na-frase(cite(autor, form: "prose", supplement: _abnt-cite-supplement(volume: volume, pagina: pagina)))
  } else {
    [#autor (#ano#_abnt-localizacao(volume: volume, pagina: pagina))]
  }
}

/// Citação indireta (paráfrase) — (Silva, 2023)
/// Página/localização é opcional na citação indireta (NBR 10520:2023, 7.2)
/// `autor` aceita `<chave>` de entrada `.bib` (ver `citar`).
#let citar-indireto(autor: none, ano: none, pagina: none, ..args) = {
  let pos = args.pos()
  if autor == none and pos.len() >= 1 { autor = pos.at(0) }
  if ano == none and pos.len() >= 2 { ano = pos.at(1) }
  if type(autor) == label {
    cite(autor, form: "normal", supplement: if pagina != none [p. #pagina])
  } else {
    [(#autor, #ano#if pagina != none [, p. #pagina])]
  }
}

/// Citação de citação (apud) — fonte original apud fonte consultada
/// Na lista de referências, inclui-se SOMENTE a fonte consultada.
/// - pagina-original: página na fonte original (opcional)
/// - pagina: página na fonte consultada (opcional)
/// `autor-secundario` (a fonte CONSULTADA) aceita `<chave>` de entrada
/// `.bib` — nesse caso `ano-secundario` é ignorado e a citação entra
/// automaticamente na bibliografia, com link clicável (equivale a `apud`).
#let citar-apud(
  autor-original: none,
  ano-original: none,
  autor-secundario: none,
  ano-secundario: none,
  pagina-original: none,
  pagina: none,
  ..args,
) = {
  let pos = args.pos()
  if autor-original == none and pos.len() >= 1 { autor-original = pos.at(0) }
  if ano-original == none and pos.len() >= 2 { ano-original = pos.at(1) }
  if autor-secundario == none and pos.len() >= 3 { autor-secundario = pos.at(2) }
  if ano-secundario == none and pos.len() >= 4 { ano-secundario = pos.at(3) }
  if type(autor-secundario) == label {
    [(#autor-original, #ano-original#if pagina-original != none [, p. #pagina-original] apud #cite(autor-secundario, form: "author"), #cite(autor-secundario, form: "year")#if pagina != none [, p. #pagina])]
  } else {
    [(#autor-original, #ano-original#if pagina-original != none [, p. #pagina-original] apud #autor-secundario, #ano-secundario#if pagina != none [, p. #pagina])]
  }
}

/// Vários autores de uma MESMA obra (até 3) — (Silva; Santos; Costa, 2023)
#let citar-multiplos(autores, ano, pagina: none) = {
  let formatted = autores.join("; ")
  [(#formatted, #ano#if pagina != none [, p. #pagina])]
}

/// Várias OBRAS citadas simultaneamente (autores/anos distintos)
/// Separadas por ponto e vírgula, em ordem alfabética de autor (NBR 10520:2023,
/// 6.1.8; a ordem de digitação não importa). Obras do mesmo autor ficam juntas,
/// em ordem de ano, com os anos separados por vírgula (6.1.7) —
/// (Dreyfuss, 1989, 1991, 1995; Fonseca, 1997; Paiva, 1997)
/// - obras: lista de pares (autor, ano) ou trios (autor, ano, pagina)
/// A ordenação compara o texto: nomes que começam por letra acentuada vão para
/// depois do Z (limite do Typst).
#let citar-varios(obras) = {
  let chave(x) = if type(x) == str { lower(x) } else if type(x) == content and x.has("text") { lower(x.text) } else { repr(x) }
  let ord = obras.sorted(key: o => (chave(o.at(0)), chave(o.at(1))))
  let grupos = ()
  for o in ord {
    let n = grupos.len()
    if n > 0 and grupos.at(n - 1).autor == o.at(0) {
      grupos.at(n - 1).obras.push(o)
    } else {
      grupos.push((autor: o.at(0), obras: (o,)))
    }
  }
  let parts = grupos.map(g => {
    g.autor
    for o in g.obras {
      [, #o.at(1)]
      if o.len() >= 3 and o.at(2) != none [, p. #o.at(2)]
    }
  })
  [(#parts.join("; "))]
}

/// Citação com mais de 3 autores (et al.) — (Silva et al., 2023)
#let citar-etal(primeiro-autor, ano, pagina: none) = {
  [(#primeiro-autor et al., #ano#if pagina != none [, p. #pagina])]
}

/// Citação de entidade coletiva — (Brasil, 2023) / (IBGE, 2011, p. 3)
/// Informe o nome por extenso ou a sigla (siglas em CAIXA ALTA) na grafia certa.
/// `entidade` aceita `<chave>` de entrada `.bib` (ver `citar`).
#let citar-entidade(entidade: none, ano: none, pagina: none, ..args) = {
  let pos = args.pos()
  if entidade == none and pos.len() >= 1 { entidade = pos.at(0) }
  if ano == none and pos.len() >= 2 { ano = pos.at(1) }
  if type(entidade) == label {
    cite(entidade, form: "normal", supplement: if pagina != none [p. #pagina])
  } else {
    [(#entidade, #ano#if pagina != none [, p. #pagina])]
  }
}

/// Citação de obra sem autoria (entrada pelo título)
/// Informe a 1ª palavra do título seguida de [...] quando houver mais palavras
/// (NBR 10520:2023, 6.1.1.4) — ex.: citar-titulo([Anteprojeto [...]], 1987)
/// `titulo` aceita `<chave>` de entrada `.bib` (ver `citar`).
#let citar-titulo(titulo: none, ano: none, pagina: none, ..args) = {
  let pos = args.pos()
  if titulo == none and pos.len() >= 1 { titulo = pos.at(0) }
  if ano == none and pos.len() >= 2 { ano = pos.at(1) }
  if type(titulo) == label {
    cite(titulo, form: "normal", supplement: if pagina != none [p. #pagina])
  } else {
    [(#titulo, #ano#if pagina != none [, p. #pagina])]
  }
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
/// - autor (nomeado, opcional): sobrenomes na grafia da sentença. Já não é
///   preciso para 2–3 autores: `pag` troca sozinha o ";" do motor do Typst pelo
///   "e" da NBR 10520:2023 (Lima; Serrano entre parênteses, mas Lima e Serrano
///   na frase; Cruz, Correa e Costa para três). Use `autor:` só para outra grafia.
///   O ano continua vindo do `.bib`. Atenção: `#cite(<chave>, form: "prose")` e
///   `@chave` nativos NÃO fazem essa troca; use `pag(<chave>)`.
///   #pag(<lima2024>, autor: "Lima e Serrano")      -> Lima e Serrano (2024)
///   #pag(<lima2024>, 45, autor: "Lima e Serrano")  -> Lima e Serrano (2024, p. 45)
#let pag(chave, autor: none, ..args) = {
  let pagina = if args.pos().len() >= 1 { args.pos().at(0) } else { none }
  if autor != none {
    [#autor (#cite(chave, form: "year")#if pagina != none [, p. #pagina])]
  } else {
    _abnt-autores-na-frase(cite(chave, form: "prose", supplement: if pagina != none [p. #pagina]))
  }
}

/// Citação de citação (apud) integrada ao .bib.
/// A fonte CONSULTADA é uma chave `.bib` (entra na lista de referências e
/// fornece autor/ano automaticamente); a fonte ORIGINAL, não acessada, é
/// informada como texto, pois NÃO entra na lista (NBR 10520:2023, 7.3).
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

// ============================================================================
// NOTAS DE REFERÊNCIA ABREVIADAS (NBR 10520:2023, 8.1.2)
// ============================================================================
// Para notas de rodapé do sistema autor-data (NÃO use com o sistema numérico:
// 6.2.2). A primeira citação da fonte leva a referência completa em nota
// (8.1.1); as seguintes podem ser abreviadas com as funções abaixo, que
// devolvem o texto da nota já terminado em ponto:
//   #footnote[#citar-ibid(pagina: 52)]            -> Ibid., p. 52.
//   #footnote[#citar-id(2006, pagina: 12)]        -> Id., 2006, p. 12.
//   #footnote[#citar-opcit("Minayo", pagina: 23)] -> MINAYO, op. cit., p. 23.
//   #footnote[#citar-loccit("Shakespeare")]       -> SHAKESPEARE, loc. cit.
//   #footnote[#citar-passim("Bechara", 2009)]     -> BECHARA, 2009, passim.
//   #footnote[#citar-cf("Caldeira", 1992)]        -> Cf. CALDEIRA, 1992.
//   #footnote[#citar-etseq("Faria", 1994, 17)]    -> FARIA, 1994, p. 17 et seq.
//   #footnote[#citar-ref("Faria", 8, pagina: 15)] -> FARIA, ref. 8, p. 15.
// O autor sai em maiúsculas (8.1.2); `pagina` vira "p. X" e `localizacao` entra
// como foi escrita (cap. V, art. 49). Anos aceitam número ou texto ([202-]).
//
// ATENÇÃO — mesma página: a norma só permite `Id.`, `Ibid.` e `op. cit.` na MESMA
// página ou folha da citação a que se referem, e `op. cit.` não pode ser usada
// quando houver duas obras do mesmo autor na página (8.1.2.2, a, b, c). O pacote
// NÃO verifica isto: as notas completas são escritas à mão e ele não sabe em que
// página caiu a nota anterior. Confira no PDF e, se a nota anterior ficou em outra
// página, repita a chamada abreviada (`MINAYO, 2021, p. 54.`) em vez de usar a
// expressão latina.

// Monta a nota: partes separadas por vírgula e ponto final, exceto quando a
// última parte já termina em ponto (Ibid., loc. cit., et seq.)
#let _abnt-nota-abrev(partes, termina-em-ponto: false, prefixo: none) = {
  if prefixo != none { prefixo }
  partes.join([, ])
  if not termina-em-ponto [.]
}

// ", p. X" / ", cap. V": localizador opcional da nota abreviada
#let _abnt-nota-onde(pagina, localizacao) = {
  let r = ()
  if pagina != none { r.push([p. #pagina]) }
  if localizacao != none { r.push([#localizacao]) }
  r
}

/// Idem (NBR 10520:2023, 8.1.2.2 a): mesma autoria, documento diferente.
/// Só vale na mesma página da citação a que se refere (o pacote não verifica).
///   #citar-id(2006, pagina: 12)  ->  Id., 2006, p. 12.
#let citar-id(ano, pagina: none, localizacao: none) = {
  _abnt-nota-abrev(([Id.], [#ano], .._abnt-nota-onde(pagina, localizacao)))
}

/// Ibidem (8.1.2.2 b): mesma autoria e mesmo documento da nota imediatamente anterior.
/// Só vale na mesma página da citação a que se refere (o pacote não verifica).
///   #citar-ibid(pagina: 52)  ->  Ibid., p. 52.
#let citar-ibid(pagina: none, localizacao: none) = {
  let onde = _abnt-nota-onde(pagina, localizacao)
  _abnt-nota-abrev(([Ibid.], ..onde), termina-em-ponto: onde.len() == 0)
}

/// Opus citatum, opere citato (8.1.2.2 c): mesma obra, citações não subsequentes.
/// Só vale na mesma página da citação a que se refere e não pode ser usada se
/// houver duas obras do mesmo autor na página (o pacote não verifica).
///   #citar-opcit("Minayo", pagina: 23)  ->  MINAYO, op. cit., p. 23.
#let citar-opcit(autor, pagina: none, localizacao: none) = {
  let onde = _abnt-nota-onde(pagina, localizacao)
  _abnt-nota-abrev((upper(autor), [op. cit.], ..onde), termina-em-ponto: onde.len() == 0)
}

/// Loco citato (8.1.2.2 e): mesma fonte e mesma localização já citadas.
///   #citar-loccit("Shakespeare")  ->  SHAKESPEARE, loc. cit.
#let citar-loccit(autor) = {
  _abnt-nota-abrev((upper(autor), [loc. cit.]), termina-em-ponto: true)
}

/// Passim (8.1.2.2 d): informação em diversos trechos da fonte.
///   #citar-passim("Bechara", 2009)  ->  BECHARA, 2009, passim.
#let citar-passim(autor, ano) = {
  _abnt-nota-abrev((upper(autor), [#ano], [passim]))
}

/// Conferre (8.1.2.2 f): sugestão de consulta, para comparar ou confrontar.
///   #citar-cf("Bechara", 2009, pagina: 337)  ->  Cf. BECHARA, 2009, p. 337.
#let citar-cf(autor, ano, pagina: none, localizacao: none) = {
  _abnt-nota-abrev((upper(autor), [#ano], .._abnt-nota-onde(pagina, localizacao)), prefixo: [Cf. ])
}

/// Sequentia (8.1.2.2 g): a página citada e as seguintes.
///   #citar-etseq("Faria", 1994, 17)  ->  FARIA, 1994, p. 17 et seq.
#let citar-etseq(autor, ano, pagina) = {
  _abnt-nota-abrev((upper(autor), [#ano], [p. #pagina et seq.]), termina-em-ponto: true)
}

/// Remissão à nota anterior (8.1.2.1): chamada, "ref." e número da nota.
///   #citar-ref("Faria", 8, pagina: 15)  ->  FARIA, ref. 8, p. 15.
#let citar-ref(autor, nota, pagina: none, localizacao: none) = {
  _abnt-nota-abrev((upper(autor), [ref. #nota], .._abnt-nota-onde(pagina, localizacao)))
}

/// Título da seção de referências
#let referencias-titulo() = {
  heading(level: 1, numbering: none, "REFERÊNCIAS")
}

// Funções para formatação manual de referências
// (usar quando não for possível usar .bib)
//
// Comuns às três funções (NBR 6023:2018, 6.3 e 8.1.1): o autor vem como
// "Sobrenome, Prenome" (vários: "Silva, A.; Santos, B."); só o último sobrenome
// sai em maiúsculas (LUCK, Heloisa.). Entidade (sem vírgula): nome todo em
// maiúsculas. As referências saem em espaço simples, alinhadas à margem esquerda
// (sem recuo), separadas da seguinte por uma linha em branco de espaço simples.

// Autor da referência: LUCK, Heloisa / SILVA, A.; SANTOS, B. / ENTIDADE
#let _abnt-autor-ref(autor) = {
  if type(autor) != str { return upper(autor) }
  autor.split(";").map(a => {
    let a = a.trim()
    let i = a.position(",")
    if i == none { upper(a) } else { upper(a.slice(0, i)) + ", " + a.slice(i + 1).trim() }
  }).join("; ")
}

// Texto seguido de ponto final, sem duplicar quando já termina em ponto (R. D.)
#let _abnt-com-ponto(x) = {
  if type(x) == str and x.ends-with(".") { x } else { [#x.] }
}

// Local e editora: [S. l.: s. n.] quando faltam os dois (NBR 6023, 8.4.4 e 8.5.6)
#let _abnt-local-editora(local, editora) = {
  if local == none and editora == none { [[S. l.: s. n.]] }
  else if local == none { [[S. l.]: #editora] }
  else if editora == none { [#local: [s. n.]] }
  else { [#local: #editora] }
}

// Bloco da referência: espaço simples, margem esquerda, sem recuo, sem justificar
#let _abnt-ref-bloco(corpo) = {
  set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(
    first-line-indent: 0pt,
    leading: abnt-leading(1),
    spacing: abnt-leading(2),
    justify: false,
  )
  block(spacing: abnt-leading(2), corpo)
}

/// Formata referência de livro
///
/// `ano` aceita número ou texto. Sem local ou editora sai `[S. l.: s. n.]`.
#let ref-livro(
  autor: none,
  titulo: none,
  subtitulo: none,
  edicao: none,
  local: none,
  editora: none,
  ano: none,
) = _abnt-ref-bloco({
  if autor != none { _abnt-com-ponto(_abnt-autor-ref(autor)); [ ] }
  if titulo != none { strong(titulo) }
  if subtitulo != none { [: #subtitulo] }
  [. ]
  if edicao != none { [#edicao. ed. ] }
  _abnt-local-editora(local, editora)
  if ano != none { [, #ano.] } else { [.] }
})

/// Formata referência de artigo de periódico
///
/// `ano`, `volume`, `numero` aceitam número ou texto. Sem `local` sai `[s. l.]`.
/// `mes` (opcional, ex.: "jan.") sai antes do ano: `p. 199-202, jan. 1985.`
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
) = _abnt-ref-bloco({
  if autor != none { _abnt-com-ponto(_abnt-autor-ref(autor)); [ ] }
  if titulo != none { [#titulo. ] }
  if revista != none { strong(revista) }
  if local != none { [, #local] } else { [, [s. l.]] }
  if volume != none { [, v. #volume] }
  if numero != none { [, n. #numero] }
  if paginas != none { [, p. #paginas] }
  if mes != none and ano != none { [, #mes #ano] }
  else if mes != none { [, #mes] }
  else if ano != none { [, #ano] }
  [.]
})

/// Formata referência de documento eletrônico
///
/// `ano` aceita número ou texto. Sem `site` sai `[S. l.: s. n.]`.
#let ref-online(
  autor: none,
  titulo: none,
  site: none,
  ano: none,
  url: none,
  data-acesso: none,
) = _abnt-ref-bloco({
  if autor != none { _abnt-com-ponto(_abnt-autor-ref(autor)); [ ] }
  if titulo != none { strong(titulo); [. ] }
  if site != none { [#site] } else { [[S. l.: s. n.]] }
  if ano != none { [, #ano] }
  [. ]
  if url != none { [Disponível em: #url. ] }
  if data-acesso != none { [Acesso em: #data-acesso.] }
})

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
