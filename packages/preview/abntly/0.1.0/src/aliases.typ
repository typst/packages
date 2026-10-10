// The Portuguese names of the package. Each function is defined first in English, in the other modules; its alias
// here is a function of its own, with its parameters and its help (the `///` comments, which the editor shows) in
// Portuguese, that only calls the English one. The values with a name are translated too
// (`modo-de-numeracao-das-equacoes: "rotulo"`), and an argument a collector would swallow is refused in Portuguese.
// Three functions have the same name in both languages and no alias: `auto-ref`, `errata` and `apud`. The keys the
// functions read from the author's dictionaries are accepted in Portuguese by the English functions themselves (the
// entries of the index, the members of the board, the people of the work); the data `com-dados` gives keep their
// English keys.
#import "abntly.typ": abntly
#import "elements.typ": (source, legend, note, call, frame, fitted, ibge-table, preamble, algorithm, subfigures, part,
  sideways, stamp, signature)
#import "spacing.typ": no-indent
#import "layout.typ": front-matter, main-matter, back-matter, dark-indigo
#import "words.typ": config-names
#import "info.typ": config-info
#import "structure.typ": (cover, title-page, approval-page, catalog-card, dedication, acknowledgments, epigraph,
  abstract, keywords, list-of, list-of-figures, list-of-tables, list-of-frames, list-of-acronyms, list-of-symbols,
  appendix, annex, glossary, with-info)
#import "index.typ": index

// a value written in Portuguese, as the English function takes it; another one is refused in Portuguese
#let translated(values, value, field) = {
  assert(value in values, message: field + " deve ser " + values.keys().map(repr).join(", ", last: " ou ")
    + "; recebido: " + repr(value))
  values.at(value)
}

// a collector (`..entradas`) takes any named argument in silence: the ones the alias does not have are refused in
// Portuguese, before the English function refuses them in English
#let positional(args, function, named) = assert(args.named().len() == 0, message: function + ": recebe "
  + named + "; recebido: " + repr(args.named()))

// the values of `modo-de-numeracao-das-equacoes`
#let number-modes = (rotulo: "label", linha: "line")

/// Cor padrão dos links: um índigo escuro (`#372aac`). É o valor padrão do parâmetro `hiperlink` de
/// `trabalho-academico`.
#let indigo-escuro = dark-indigo

// --- the main function ----------------------------------------------------------------------------------------------

/// Aplica a formatação da ABNT a todo o documento. Deve ser usada com uma regra `show` no início do arquivo:
/// `#show: trabalho-academico.with(dados: config-dados(...))`. É equivalente à função `abntly`, com os parâmetros em
/// português.
///
/// A função configura a página, as margens, as fontes, os espaçamentos, a apresentação dos elementos do texto, as
/// citações e a lista de referências. Configurações que não são parâmetros podem ser alteradas com regras `set` após
/// a chamada. Por exemplo, `#set text(size: 11pt)` altera o tamanho da fonte, e os demais tamanhos se ajustam
/// proporcionalmente.
///
/// - corpo (content): Conteúdo do trabalho.
/// - dados (dictionary): Dados do trabalho, criados com `config-dados`. São usados na capa, na folha de rosto, na
///   folha de aprovação e na ficha catalográfica, e gravados nos metadados do PDF. Pode ser omitido em um trabalho sem
///   essas páginas.
/// - idioma (str): Idioma do trabalho: `"pt"` ou `"en"`. Define a hifenização e os termos gerados pelo pacote
///   ("Capítulo", "Fonte", "Sumário"). Para outro idioma, informe os termos em `nomes` e use `#set text(lang: "es")`
///   após a chamada.
/// - nomes (dictionary): Termos do pacote a substituir, criados com `config-nomes`.
/// - frente-e-verso (bool): Se `true`, formata o trabalho para impressão em frente e verso: margens espelhadas,
///   número da página no lado externo e seções primárias iniciando em página ímpar. Nesse modo, os carimbos de versão
///   provisória da ficha catalográfica e da folha de aprovação não são exibidos.
/// - hiperlink (color, none): Cor dos links (endereços, remissões, citações, sumário e chamadas de notas). Use
///   `black` para impressão ou `none` para remover os links.
/// - tamanho-da-fonte-da-tabela (length): Tamanho do texto das tabelas, em `em` do corpo. O padrão, `10em / 12`,
///   corresponde a 10 pt em um corpo de 12 pt. Use `1em` para manter o tamanho do corpo. Quadros usam sempre o tamanho
///   do corpo.
/// - numeracao-das-equacoes (str, function): Formato da numeração das equações. `"(1.1)"` numera por capítulo e
///   `"(1)"` numera ao longo do trabalho. Com uma letra no final, como `"(1.1a)"` ou `"(1a)"`, as linhas de uma mesma
///   equação compartilham o número e recebem letras. Também aceita uma função.
/// - modo-de-numeracao-das-equacoes (str): Quais equações são numeradas. `"rotulo"` numera apenas as equações (ou
///   linhas) que têm rótulo. `"linha"` numera todas as linhas; `#<equate:revoke>` no fim de uma linha remove o número
///   dela.
/// - sistema-de-citacao (str): Sistema de chamada das citações (NBR 10520:2023): `"alf"`, autor-data, como em
///   "(Silva, 2020, p. 4)"; `"num"`, numérico entre parênteses, como em "(1, p. 30)"; `"overcite"`, numérico em
///   expoente; `"ieee"`, numérico entre colchetes, como em "[1, p. 30]". A lista de referências segue a NBR 6023:2025
///   em todos os sistemas.
/// -> content
#let trabalho-academico(
  corpo,
  dados: (:),
  idioma: "pt",
  nomes: (:),
  frente-e-verso: false,
  hiperlink: dark-indigo,
  tamanho-da-fonte-da-tabela: 10em / 12,
  numeracao-das-equacoes: "(1.1)",
  modo-de-numeracao-das-equacoes: "rotulo",
  sistema-de-citacao: "alf",
) = abntly(
  corpo,
  info: dados,
  lang: idioma,
  names: nomes,
  two-sided: frente-e-verso,
  hyperlink: hiperlink,
  table-font-size: tamanho-da-fonte-da-tabela,
  equation-numbering: numeracao-das-equacoes,
  equation-number-mode: translated(number-modes, modo-de-numeracao-das-equacoes,
    "trabalho-academico: modo-de-numeracao-das-equacoes"),
  citation-system: sistema-de-citacao,
)

/// Define os termos do pacote que devem ser substituídos, para o parâmetro `nomes` de `trabalho-academico`. Exemplo:
/// `config-nomes(chapter: "Unidade", source: "Origem")`.
///
/// As chaves são as do arquivo `src/lang.toml`, em inglês: chapter, part, algorithm, frame, source, legend, note,
/// own-work, continues, continuation, conclusion, contents, references. Os nomes usados por `auto-ref` também podem
/// ser substituídos: section, subsection, subsubsection, appendix-name, annex-name, equation, page.
///
/// - ..palavras (arguments): Termos a substituir, identificados pela chave. Aceitam texto ou conteúdo.
/// -> dictionary
#let config-nomes(..palavras) = config-names(..palavras)

/// Define os dados do trabalho, para o parâmetro `dados` de `trabalho-academico`. Esses dados são usados na capa, na
/// folha de rosto, na folha de aprovação e na ficha catalográfica. Campos não informados são omitidos dessas páginas;
/// o título e o autor são obrigatórios para elas.
///
/// - titulo (str, content): Título do trabalho.
/// - subtitulo (str, content, none): Subtítulo. É impresso após o título, separado por dois-pontos.
/// - autor (str, content, dictionary): Autor. Pode ser o nome completo ou um dicionário com nome e sobrenome
///   separados, como `(nome: "Lucas Lima", sobrenome: "Rodrigues")`. O sobrenome é usado na ficha catalográfica
///   ("Rodrigues, Lucas Lima"). Quando o autor é informado como texto, a última palavra é tratada como sobrenome.
/// - orientador (str, content, dictionary, none): Orientador, no mesmo formato do autor, com a titulação no nome
///   ("Prof. Dr. Nome do Orientador"). No dicionário, `genero: "f"` produz o rótulo "Orientadora" e `rotulo` define um
///   rótulo personalizado.
/// - coorientador (str, content, dictionary, none): Coorientador, no mesmo formato do orientador.
/// - instituicao (str, content, none): Nome da instituição.
/// - programa (str, content, none): Curso, programa de pós-graduação ou departamento.
/// - area (str, content, none): Área de concentração. É impressa abaixo da natureza do trabalho.
/// - ano (auto, int, str, content): Ano de depósito. Com `auto`, usa o ano atual.
/// - local (str, content, none): Local (cidade) da instituição.
/// - versao (str, content, none): Versão do trabalho, como "Versão corrigida". É impressa abaixo do título.
/// - volume (int, str, content, none): Número do volume, impresso ao lado do ano ("2026, v. 2"). Use quando o
///   trabalho tiver mais de um volume.
/// - tipo (str, content, none): Tipo do trabalho, usado na ficha catalográfica: `"tcc"`, `"dissertacao"`, `"tese"`,
///   `"qualificacao-mestrado"` ou `"qualificacao-doutorado"`. Para outro tipo, informe o texto como conteúdo.
/// - marca (content, none): Marca (logotipo) da instituição, exibida no topo da capa. Exemplo:
///   `image("marca.svg", width: 2cm)`.
/// -> dictionary
#let config-dados(titulo: none, subtitulo: none, autor: none, orientador: none, coorientador: none,
  instituicao: none, programa: none, area: none, ano: auto, local: none, versao: none, volume: none, tipo: none,
  marca: none, ..outros) = {
  assert(outros.pos().len() == 0 and outros.named().len() == 0, message: "config-dados: campo desconhecido "
    + repr(outros) + "; os campos são titulo, subtitulo, autor, orientador, coorientador, instituicao, programa, "
    + "area, ano, local, versao, volume, tipo e marca")
  config-info(title: titulo, subtitle: subtitulo, author: autor, advisor: orientador, co-advisor: coorientador,
    institution: instituicao, program: programa, area: area, year: ano, location: local, version: versao,
    volume: volume, work-type: tipo, logo: marca)
}

// --- the parts of the work ------------------------------------------------------------------------------------------

/// Inicia a parte pré-textual: os títulos seguintes não são numerados. Deve ser usada com uma regra `show`:
/// `#show: pretextual`.
///
/// O início do trabalho já é pré-textual, e os elementos pré-textuais do pacote (resumo, listas, sumário) já têm
/// títulos sem número. Use esta função apenas se o trabalho escrever títulos pré-textuais como títulos comuns, como
/// em `= Apresentação`.
///
/// - corpo (content): Restante do trabalho.
/// -> content
#let pretextual(corpo) = front-matter(corpo)

/// Inicia a parte textual: o conteúdo seguinte começa em uma página nova, a primeira a exibir o número da página e o
/// cabeçalho, e os títulos voltam a ser numerados ("1", "1.1"). Deve ser usada com uma regra `show`:
/// `#show: textual`.
///
/// Sem esta função, a parte textual começa na primeira seção primária numerada. Use-a quando o texto começar sem um
/// título numerado.
///
/// - corpo (content): Restante do trabalho.
/// -> content
#let textual(corpo) = main-matter(corpo)

/// Inicia a parte pós-textual: a numeração das páginas e o cabeçalho continuam, e os títulos seguintes não são
/// numerados (NBR 14724:2024, seção 5.2.3). Deve ser usada com uma regra `show`: `#show: postextual`.
///
/// Os elementos pós-textuais do pacote (referências, glossário, apêndices, anexos e índice) já têm os títulos no
/// formato correto, e a lista de referências marca o início dessa parte para o sumário. Use esta função apenas se o
/// trabalho escrever títulos pós-textuais como títulos comuns, como em `= Referências`.
///
/// - corpo (content): Restante do trabalho.
/// -> content
#let postextual(corpo) = back-matter(corpo)

// --- the elements of the text ---------------------------------------------------------------------------------------

/// Gera a linha da fonte de uma ilustração ou de uma tabela: "Fonte: …" (NBR 14724:2024, seções 5.8 e 5.9). Deve ser
/// chamada dentro da figura, depois da ilustração. Sem argumento, indica que a ilustração foi produzida pelo próprio
/// autor: "Fonte: Elaboração própria.".
///
/// - ..corpo (content): Fonte consultada, com o ponto final.
/// -> content
#let fonte(..corpo) = source(..corpo)

/// Gera a linha da legenda de uma ilustração: "Legenda: …" (NBR 14724:2024, seção 5.8). Deve ser chamada dentro da
/// figura, depois da fonte.
///
/// - corpo (content): Texto da legenda.
/// -> content
#let legenda(corpo) = legend(corpo)

/// Gera uma nota abaixo de uma ilustração ou de uma tabela: "Nota: …" (NBR 14724:2024, seção 5.8). Deve ser chamada
/// dentro da figura, depois da fonte e da legenda.
///
/// Com o parâmetro `chamada`, gera uma nota específica de uma tabela, identificada por um número em expoente no lugar
/// da palavra "Nota". A chamada correspondente é inserida na célula da tabela com a função `chamada`.
///
/// - corpo (content): Texto da nota.
/// - palavra (auto, content): Palavra exibida antes dos dois-pontos. O padrão é "Nota", no idioma do texto. Exemplo:
///   `[Notas]`.
/// - chamada (none, int, str): Número da chamada de uma nota específica. Com `1`, a nota começa com "¹" e não exibe a
///   palavra.
/// -> content
#let nota(corpo, palavra: auto, chamada: none) = note(corpo, word: palavra, call: chamada)

/// Gera a chamada de uma nota específica em uma célula de tabela: um número em expoente, como em "São Paulo¹". O
/// número é um link para a nota criada com `nota(chamada: 1)` abaixo da mesma tabela.
///
/// - n (int, str): Número da chamada.
/// -> content
#let chamada(n) = call(n)

/// Gera um quadro: uma ilustração com informações textuais organizadas em linhas e colunas, com o título "Quadro 1 —
/// Título" acima e numeração própria (NBR 14724:2024, seção 5.8). Uma tabela dentro do quadro recebe linhas fechadas
/// de 0,4 pt em todas as células, e o texto mantém o tamanho do corpo.
///
/// A função aceita os mesmos argumentos de `figure`. Para dados numéricos, use uma tabela, com `ajustada`.
///
/// - ..args (arguments): Argumentos de `figure`: o conteúdo e `caption`, entre outros.
/// -> content
#let quadro(..args) = frame(..args)

/// Gera uma figura em que o título, a fonte, a legenda e as notas ficam limitados à largura da ilustração, como pede
/// a NBR 14724:2024 (seção 5.8). O conjunto é centralizado na página, e o título, a fonte e as notas são alinhados à
/// esquerda. A largura da ilustração é medida automaticamente e não ultrapassa a largura da mancha gráfica.
///
/// Uma tabela com cabeçalho (`table.header(...)`) dentro desta função é formatada conforme as normas de apresentação
/// tabular do IBGE (NBR 14724:2024, seção 5.9): recebe os traços horizontais automaticamente e, se ocupar mais de uma
/// página, repete o cabeçalho e o título com as indicações "(continua)", "(continuação)" e "(conclusão)". Uma tabela
/// sem cabeçalho e um quadro mantêm as linhas definidas pelo autor.
///
/// - ..args (arguments): Argumentos de `figure`: o conteúdo, `caption`, `kind` e `supplement`, entre outros.
/// - largura (auto, length, ratio): Largura do conjunto. Com `auto`, é a largura medida da ilustração. Informe uma
///   largura menor para forçar a quebra do texto nas células de uma tabela com colunas `auto`.
/// - rotulo (none, label): Rótulo da figura, para as remissões (`@rotulo`). Nesta função, o rótulo é informado como
///   parâmetro, e não depois da chamada.
/// -> content
#let ajustada(..args, largura: auto, rotulo: none) = fitted(..args, width: largura, label: rotulo)

/// Gera uma tabela no padrão do IBGE para uma `figure` comum: os traços horizontais das normas de apresentação
/// tabular (NBR 14724:2024, seção 5.9) — um grosso no topo e na base, um duplo sob o cabeçalho, finos entre as
/// linhas, nenhum nas laterais — e o texto no tamanho reduzido das tabelas. Aceita os argumentos de `table`, com o
/// cabeçalho em `table.header(...)`, que é obrigatório. Escreva-a dentro de uma `figure`, com `fonte` e `nota` depois
/// dela, como de costume: o título, a fonte e as notas ocupam a largura da mancha gráfica, e a figura pode flutuar
/// com `placement`. Uma `figure` não quebra entre páginas.
///
/// Para uma tabela cujo título, fonte e notas se limitam à largura da própria tabela, ou que continua nas páginas
/// seguintes com o cabeçalho e "(continua)", use `ajustada`, em que uma tabela com cabeçalho recebe essa forma
/// por si só.
///
/// - ..args (arguments): Argumentos de `table`: `columns`, `align`, o cabeçalho em `table.header(...)` e as células,
///   entre outros. Um `stroke` é ignorado: os traços são os do IBGE.
/// -> content
#let tabela-ibge(..args) = ibge-table(..args)

/// Gera um parágrafo sem o recuo da primeira linha: o texto que continua depois de uma equação destacada, de uma
/// citação longa ou de uma lista, como em "em que $x$ é…", que pertence ao parágrafo anterior.
///
/// - corpo (content): Texto do parágrafo.
/// -> content
#let sem-recuo(corpo) = no-indent(corpo)

/// Gera o bloco da natureza do trabalho: tipo do trabalho, objetivo, instituição e área de concentração. O bloco é
/// composto em espaço simples, alinhado do meio da mancha para a margem direita (NBR 14724:2024, seção 5.2).
///
/// A folha de rosto e a folha de aprovação já incluem esse bloco. Use esta função apenas em páginas montadas
/// manualmente.
///
/// - corpo (content): Texto da natureza do trabalho.
/// -> content
#let preambulo(corpo) = preamble(corpo)

/// Gera um algoritmo: uma ilustração de código ou de pseudocódigo, com o título "Algoritmo 1 — Título" acima e
/// numeração própria. Como nas demais ilustrações (NBR 14724:2024, seção 5.8), a fonte é indicada abaixo, com
/// `fonte`. O código ocupa a largura da mancha gráfica, e um algoritmo longo continua na página seguinte.
///
/// Uma `figure` cujo conteúdo é um bloco de código também é tratada como algoritmo, com a mesma numeração.
///
/// - ..args (arguments): Argumentos de `figure`: o conteúdo e `caption`, entre outros.
/// -> content
#let algoritmo(..args) = algorithm(..args)

/// Gera uma figura composta por partes (subfiguras). O título do conjunto fica acima ("Figura 1 — Título"), e o
/// título de cada parte fica abaixo dela ("(a) Título"). A fonte, a legenda e as notas do conjunto ficam abaixo das
/// partes. A remissão a uma parte gera o número do conjunto e a letra da parte ("1a").
///
/// Cada parte é uma `figure`, seguida do seu rótulo. A fonte de uma parte é indicada dentro da figura dela. O último
/// argumento posicional pode ser um conteúdo com a fonte, a legenda e as notas do conjunto. Esta função não pode ser
/// usada dentro de `ajustada`.
///
/// - ..args (arguments): Partes (`figure(...)`, cada uma seguida do rótulo) e, por último, o conteúdo que fica abaixo
///   do conjunto (`fonte`, `legenda`, `nota`).
/// - colunas (int, array): Número de colunas ou lista com a largura de cada coluna.
/// - espaco (length): Espaço horizontal e vertical entre as partes.
/// - titulo (content): Título do conjunto.
/// - rotulo (none, label): Rótulo do conjunto.
/// -> content
#let subfiguras(..args, colunas: 2, espaco: 1em, titulo: none, rotulo: none) = subfigures(..args, columns: colunas,
  gutter: espaco, caption: titulo, label: rotulo)

/// Gera a página de abertura de uma parte, uma divisão do texto acima das seções primárias. A página não tem
/// cabeçalho nem número e exibe "Parte I" e o título, centralizados. A seção primária seguinte começa em uma página
/// nova, e a numeração das seções continua de uma parte para a outra. As normas da ABNT não tratam desse elemento.
///
/// - titulo (content): Título da parte.
/// -> content
#let parte(titulo) = part(titulo)

/// Gira o conteúdo em 90° em uma página própria, para uma figura ou uma tabela mais larga que a mancha gráfica. A
/// página permanece em pé, com as mesmas margens, e o topo do conteúdo fica voltado para o lado da encadernação. O
/// texto continua na página seguinte. As normas da ABNT não tratam desse elemento.
///
/// - corpo (content): Conteúdo a girar: uma figura ou uma tabela em `ajustada`, por exemplo.
/// -> content
#let deitada(corpo) = sideways(corpo)

/// Gera um carimbo (marca-d'água), como "RASCUNHO" ou "VERSÃO PRELIMINAR", para o fundo de uma página. O texto é
/// exibido em negrito, em cor clara, girado e centralizado na página. As normas da ABNT não tratam desse elemento.
///
/// O carimbo é usado no parâmetro `background` da página. Use `#set page(background: carimbo[RASCUNHO])` para
/// aplicá-lo a todas as páginas seguintes, ou `#page(background: carimbo[RASCUNHO])[...]` para uma única página.
///
/// - corpo (content): Texto do carimbo.
/// - nota (none, content): Texto menor, exibido abaixo do texto principal.
/// - cor (color): Cor do carimbo. É clareada (misturada com 70% de branco) antes de ser aplicada.
/// - angulo (angle): Ângulo de rotação. O padrão, `-45deg`, gira o texto no sentido anti-horário.
/// - tamanho (length): Tamanho do texto principal, em `em` do corpo. O padrão corresponde a 40 pt em um corpo de 12
///   pt.
/// -> content
#let carimbo(corpo, nota: none, cor: rgb(255, 0, 0), angulo: -45deg, tamanho: 10em / 3) = stamp(corpo, note: nota,
  color: cor, angle: angulo, size: tamanho)

/// Gera as linhas de assinatura dos membros da banca examinadora. Cada assinatura é um traço de 8 cm, centralizado,
/// com a titulação e o nome em negrito, o papel e a instituição abaixo dele. A NBR 14724:2024 (seção 4.2.1.3) exige o
/// nome, a titulação, a assinatura e a instituição de cada membro na folha de aprovação.
///
/// A função `folha-de-aprovacao` já gera as assinaturas. Use esta função em páginas montadas manualmente. As
/// assinaturas de uma mesma chamada ficam uma abaixo da outra; para colocá-las lado a lado, use um `grid` com uma
/// chamada por célula.
///
/// - ..membros (dictionary, content): Membros da banca, um por argumento. Cada membro é um dicionário com as chaves
///   `nome`, `titulacao` e `instituicao` (obrigatórias) e `papel` (opcional). Também aceita conteúdo, com o texto que
///   fica abaixo do traço.
/// -> content
#let assinatura(..membros) = {
  positional(membros, "assinatura", "os membros da banca, cada um um dicionário (nome, titulação, instituição, "
    + "papel) ou conteúdo")
  signature(..membros)
}

// --- the pages of the structure -------------------------------------------------------------------------------------

/// Gera a capa do trabalho (NBR 14724:2024, seção 4.1.1) a partir dos dados de `config-dados`. De cima para baixo, a
/// capa contém: a marca da instituição (se informada), a instituição e o programa, o autor, o título com o subtítulo,
/// a versão do trabalho (se informada), o local e o ano. O título e o autor são obrigatórios.
///
/// Os parâmetros `topo`, `meio` e `pe` substituem a parte correspondente da capa por um conteúdo personalizado. Use
/// `com-dados` para acessar os dados do trabalho nesse conteúdo:
///
/// ```typ
/// #capa()
/// #capa(topo: com-dados(d => [#upper(d.institution) \ #d.author]))
/// ```
///
/// - topo (auto, content): Conteúdo da parte superior, no lugar da instituição e do autor.
/// - meio (auto, content): Conteúdo da parte central, no lugar do título e da versão.
/// - pe (auto, content): Conteúdo da parte inferior, no lugar do local e do ano.
/// - altura-do-meio (ratio, length, relative): Altura da área que vai do título ao fim da mancha. Valores maiores
///   deslocam o título para cima. O padrão, `55%`, posiciona o título no meio da página.
/// -> content
#let capa(topo: auto, meio: auto, pe: auto, altura-do-meio: 55%) = cover(top: topo, middle: meio, bottom: pe,
  middle-height: altura-do-meio)

/// Gera a folha de rosto (NBR 14724:2024, seção 4.2.1.1). De cima para baixo, a página contém: o autor, o título com
/// o subtítulo, a versão do trabalho (se informada), a natureza do trabalho, o orientador e o coorientador, o local e
/// o ano. O texto da natureza é passado como conteúdo da função; os demais elementos vêm de `config-dados`.
///
/// A natureza é composta em espaço simples, alinhada do meio da mancha para a margem direita (seção 5.2), e é
/// reaproveitada pela folha de aprovação. A contagem das páginas do trabalho começa na folha de rosto, e a ficha
/// catalográfica ocupa o verso dela.
///
/// ```typ
/// #folha-de-rosto[Tese apresentada ao Programa de Pós-Graduação da Universidade do Brasil,
///   como requisito parcial para a obtenção do título de Doutor.]
/// ```
///
/// - corpo (content): Texto da natureza do trabalho: tipo do trabalho, objetivo e instituição a que é submetido.
/// - topo (auto, content): Conteúdo da parte superior, no lugar do autor.
/// - meio (auto, content): Conteúdo da parte central, no lugar do título, da versão, da natureza e dos orientadores.
/// - pe (auto, content): Conteúdo da parte inferior, no lugar do local e do ano.
/// - altura-do-meio (ratio, length, relative): Altura da área que vai do título ao fim da mancha, como na capa. O
///   padrão, `85%`, posiciona o título na parte superior da página.
/// -> content
#let folha-de-rosto(corpo, topo: auto, meio: auto, pe: auto, altura-do-meio: 85%) = title-page(corpo, top: topo,
  middle: meio, bottom: pe, middle-height: altura-do-meio)

/// Gera a folha de aprovação (NBR 14724:2024, seção 4.2.1.3). De cima para baixo, a página contém: o autor, o título
/// com o subtítulo, a natureza do trabalho (a mesma da folha de rosto, com a área de concentração), a linha da
/// aprovação com o local e a data, as assinaturas dos membros da banca, o local e o ano. A página é composta em
/// espaço simples.
///
/// A data de aprovação e as assinaturas são preenchidas após a aprovação do trabalho. Por isso, a data fica em branco
/// por padrão, e a página recebe o carimbo "FOLHA PROVISÓRIA" até que `provisoria: false` seja informado.
///
/// ```typ
/// #folha-de-aprovacao(
///   (titulacao: [Prof. Dr.], nome: [Fulano de Tal], papel: [Orientador],
///     instituicao: [Universidade do Brasil]),
///   (titulacao: [Profa. Dra.], nome: [Beltrana de Tal], instituicao: [Universidade do Brasil]),
/// )
/// ```
///
/// - ..membros (dictionary, content): Membros da banca, no formato aceito por `assinatura`.
/// - data (str, content, none): Data de aprovação, como "30 de setembro de 2026". Com `none`, é exibida uma linha em
///   branco para preenchimento.
/// - topo (auto, content): Conteúdo da parte superior, no lugar do autor.
/// - meio (auto, content): Conteúdo da parte central, no lugar do título e da natureza.
/// - pe (auto, content): Conteúdo da parte inferior, no lugar da linha da aprovação, das assinaturas, do local e do
///   ano.
/// - altura-do-meio (auto, ratio, length, relative): Altura da área que vai do título ao fim da mancha, como na capa.
///   Com `auto`, o espaço livre da página é distribuído entre o autor, o título e a natureza.
/// - provisoria (bool): Se `true`, exibe o carimbo "FOLHA PROVISÓRIA" no fundo da página. Use `false` na versão
///   final. O carimbo nunca é exibido com `frente-e-verso: true`.
/// -> content
#let folha-de-aprovacao(..membros, data: none, topo: auto, meio: auto, pe: auto, altura-do-meio: auto,
  provisoria: true) = {
  positional(membros, "folha-de-aprovacao", "os membros da banca, cada um um dicionário (nome, titulação, "
    + "instituição, papel), e data, topo, meio, pe, altura-do-meio e provisoria")
  approval-page(..membros, date: data, top: topo, middle: meio, bottom: pe, middle-height: altura-do-meio,
    draft: provisoria)
}

/// Gera a página com os dados internacionais de catalogação na publicação (ficha catalográfica), no verso da folha de
/// rosto (NBR 14724:2024, seção 4.2.1.1.2). Deve ser chamada logo após a folha de rosto.
///
/// A ficha é um quadro de 13,5 cm por 8 cm na parte inferior da página, montado com os dados de `config-dados`:
/// autor, título, local, ano, número de páginas, orientador, tipo do trabalho, instituição e assuntos. Os assuntos
/// são as palavras-chave do resumo no idioma do trabalho.
///
/// A ficha definitiva é normalmente fornecida pela biblioteca da instituição. Para usá-la, informe-a no parâmetro
/// `ficha`: `ficha-catalografica(ficha: image("ficha.pdf", width: 13.5cm))`.
///
/// - ficha (auto, content): Ficha fornecida pela biblioteca, no lugar da ficha gerada pelo pacote.
/// - provisoria (auto, bool): Se `true`, exibe o carimbo "FICHA PROVISÓRIA" no fundo da página. Com `auto`, o carimbo
///   é exibido na ficha gerada pelo pacote e omitido na ficha informada em `ficha`. O carimbo nunca é exibido com
///   `frente-e-verso: true`.
/// -> content
#let ficha-catalografica(ficha: auto, provisoria: auto) = catalog-card(card: ficha, draft: provisoria)

/// Gera a página da dedicatória (NBR 14724:2024, seção 4.2.1.4). A página não tem título. O texto é composto em
/// itálico, centralizado, no meio da página.
///
/// - corpo (content): Texto da dedicatória.
/// -> content
#let dedicatoria(corpo) = dedication(corpo)

/// Gera os agradecimentos (NBR 14724:2024, seção 4.2.1.5): o título "Agradecimentos", centralizado e sem número,
/// seguido do texto.
///
/// - corpo (content): Texto dos agradecimentos.
/// -> content
#let agradecimentos(corpo) = acknowledgments(corpo)

/// Gera a página da epígrafe (NBR 14724:2024, seção 4.2.1.6). A página não tem título. O texto é alinhado à direita,
/// na parte inferior da página. As quebras de linha e o itálico são definidos pelo autor.
///
/// - corpo (content): Texto da epígrafe, com a indicação de autoria.
/// -> content
#let epigrafe(corpo) = epigraph(corpo)

/// Gera um resumo (NBR 14724:2024, seções 4.2.1.7 e 4.2.1.8; NBR 6028:2021): o título, centralizado e sem número,
/// seguido do texto, sem recuo de parágrafo. As palavras-chave são incluídas no fim do texto, com a função
/// `palavras-chave`.
///
/// O título acompanha o idioma do resumo: "Resumo", "Abstract", "Resumen" ou "Résumé". Em um resumo em língua
/// estrangeira, o parâmetro `idioma` também define a hifenização do texto.
///
/// ```typ
/// #resumo[
///   Texto do resumo.
///
///   #palavras-chave[primeira][segunda][terceira]
/// ]
/// #resumo(idioma: "en")[
///   Abstract text.
///
///   #palavras-chave[first][second][third]
/// ]
/// ```
///
/// - corpo (content): Texto do resumo, com as palavras-chave.
/// - idioma (auto, str): Idioma do resumo, como `"en"`, `"es"` ou `"fr"`. Com `auto`, é o idioma do trabalho.
/// - titulo (auto, content): Título do resumo. Informe-o para um idioma cujo termo o pacote não tem.
/// -> content
#let resumo(corpo, idioma: auto, titulo: auto) = abstract(corpo, lang: idioma, title: titulo)

/// Gera a linha das palavras-chave de um resumo (NBR 6028:2021, seção 4.1.7): o rótulo em negrito, seguido de
/// dois-pontos, com as palavras separadas por ponto e vírgula e finalizadas por ponto. O rótulo acompanha o idioma do
/// resumo ("Palavras-chave", "Keywords").
///
/// As palavras-chave do resumo no idioma do trabalho são usadas como assuntos na ficha catalográfica e gravadas nos
/// metadados do PDF.
///
/// - ..palavras (str, content): Palavras-chave, uma por argumento.
/// - separador (str, content): Separador entre as palavras.
/// - fim (str, content): Pontuação após a última palavra.
/// - rotulo (auto, content): Rótulo exibido antes dos dois-pontos. Informe-o para um idioma cujo termo o pacote não
///   tem.
/// -> content
#let palavras-chave(..palavras, separador: "; ", fim: ".", rotulo: auto) = {
  positional(palavras, "palavras-chave", "as palavras, e separador, fim e rotulo")
  keywords(..palavras, sep: separador, end: fim, label: rotulo)
}

/// Gera a lista das ilustrações de um tipo ou a lista de tabelas (NBR 14724:2024, seções 4.2.1.9 e 4.2.1.10): o
/// título, centralizado e sem número, e uma entrada para cada item, na ordem em que aparecem no texto, como em
/// "Figura 1 — Título ..... 9".
///
/// A norma recomenda uma lista própria para cada tipo de ilustração. As funções `lista-de-figuras`,
/// `lista-de-tabelas` e `lista-de-quadros` geram as listas mais comuns.
///
/// - alvo (str, function, selector): Tipo das figuras a listar (`image`, `table`, `"quadro"`, `raw` ou o `kind` de um
///   tipo próprio) ou um seletor.
/// - titulo (auto, content): Título da lista. Com `auto`, é o termo do pacote para o tipo ("Lista de ilustrações",
///   "Lista de tabelas", "Lista de quadros"). É obrigatório para os demais tipos.
/// -> content
#let lista-de(alvo, titulo: auto) = list-of(alvo, title: titulo)

/// Gera a lista de ilustrações com as figuras do trabalho. Equivale a `lista-de(image)`.
///
/// -> content
#let lista-de-figuras() = list-of-figures()

/// Gera a lista de tabelas. Equivale a `lista-de(table)`.
///
/// -> content
#let lista-de-tabelas() = list-of-tables()

/// Gera a lista de quadros. Equivale a `lista-de("quadro")`.
///
/// -> content
#let lista-de-quadros() = list-of-frames()

/// Gera a lista de abreviaturas e siglas (NBR 14724:2024, seção 4.2.1.11): o título, centralizado e sem número, e as
/// siglas em ordem alfabética, cada uma seguida da expressão por extenso.
///
/// As entradas podem ser informadas de duas formas. Como pares, a lista é apenas impressa:
/// `("ABNT", [Associação Brasileira de Normas Técnicas])`. Como dicionários, as siglas também podem ser citadas no
/// texto pela chave (`@abnt`), e a primeira menção exibe a expressão por extenso, seguida da sigla entre parênteses:
/// `(key: "abnt", short: "ABNT", long: [Associação Brasileira de Normas Técnicas])`.
///
/// - ..entradas (array, dictionary): Siglas, todas como pares ou todas como dicionários.
/// -> content
#let lista-de-siglas(..entradas) = {
  positional(entradas, "lista-de-siglas", "as siglas, cada uma um par ou um dicionário do glossarium")
  list-of-acronyms(..entradas)
}

/// Gera a lista de símbolos (NBR 14724:2024, seção 4.2.1.12): o título, centralizado e sem número, e os símbolos na
/// ordem informada, cada um seguido do seu significado.
///
/// As entradas são pares, como `($c$, [Velocidade da luz no vácuo])`, ou dicionários, como em `lista-de-siglas`.
///
/// - ..entradas (array, dictionary): Símbolos, todos como pares ou todos como dicionários.
/// -> content
#let lista-de-simbolos(..entradas) = {
  positional(entradas, "lista-de-simbolos", "os símbolos, cada um um par ou um dicionário do glossarium")
  list-of-symbols(..entradas)
}

/// Inicia os apêndices (NBR 14724:2024, seção 4.2.3.3). Deve ser usada com uma regra `show`: `#show: apendice`. A
/// partir dela, cada título primário é identificado pela palavra "APÊNDICE", por uma letra maiúscula consecutiva e
/// por um travessão, como em "APÊNDICE A — Título", centralizado. As seções de um apêndice são numeradas com a letra
/// dele ("A.1").
///
/// Por padrão, uma página com o título "Apêndices" é inserida antes do primeiro apêndice.
///
/// - corpo (content): Restante do trabalho.
/// - divisoria (bool): Se `true`, insere a página "Apêndices" antes do primeiro apêndice. A norma não exige essa
///   página. Use `#show: apendice.with(divisoria: false)` para omiti-la.
/// -> content
#let apendice(corpo, divisoria: true) = appendix(corpo, divider: divisoria)

/// Inicia os anexos (NBR 14724:2024, seção 4.2.3.4). Deve ser usada com uma regra `show`: `#show: anexo`. A partir
/// dela, cada título primário é identificado como "ANEXO A — Título", centralizado, e as seções de um anexo são
/// numeradas com a letra dele ("A.1").
///
/// Por padrão, uma página com o título "Anexos" é inserida antes do primeiro anexo.
///
/// - corpo (content): Restante do trabalho.
/// - divisoria (bool): Se `true`, insere a página "Anexos" antes do primeiro anexo. A norma não exige essa página.
///   Use `#show: anexo.with(divisoria: false)` para omiti-la.
/// -> content
#let anexo(corpo, divisoria: true) = annex(corpo, divider: divisoria)

/// Gera o glossário (NBR 14724:2024, seção 4.2.3.2): o título, centralizado e sem número, e os termos em ordem
/// alfabética, cada um em negrito, seguido da definição.
///
/// As entradas podem ser informadas de duas formas. Como pares, o glossário é apenas impresso:
/// `("Typst", [sistema de composição tipográfica])`. Como dicionários, os termos também podem ser citados no texto
/// pela chave (`@typst`): `(key: "typst", short: "Typst", description: [sistema de composição tipográfica])`.
///
/// - ..entradas (array, dictionary): Termos e definições, todos como pares ou todos como dicionários.
/// -> content
#let glossario(..entradas) = {
  positional(entradas, "glossario", "os termos, cada um um par ou um dicionário do glossarium")
  glossary(..entradas)
}

/// Gera o índice (NBR 14724:2024, seção 4.2.3.5; NBR 6034:2004), o último elemento do trabalho: o título,
/// centralizado e sem número, e as entradas em ordem alfabética, em duas colunas. As entradas e as páginas são
/// informadas pelo autor, e cada página é um link.
///
/// Uma entrada é um dicionário com as chaves `termo` (o cabeçalho), `paginas` (um número, uma faixa como `"15-18"` ou
/// uma lista deles), `sub` (lista de subcabeçalhos, que também são entradas), `ver` e `ver-tambem` (remissivas). Uma
/// entrada simples pode ser informada como par: `("Termo", 3)`.
///
/// ```typ
/// #indice(
///   (termo: "Entropia", paginas: (12, "15-18"), sub: ((termo: "de mistura", paginas: 16),)),
///   (termo: "Equilíbrio", ver: "Entropia"),
///   ("Isolamento", 3),
/// )
/// ```
///
/// - ..entradas (dictionary, array): Entradas do índice.
/// - colunas (int): Número de colunas.
/// - ordenar (bool): Se `true`, ordena as entradas alfabeticamente, conforme a NBR 6033:1989. Use `false` para manter
///   a ordem informada, em um índice sistemático ou cronológico.
/// -> content
#let indice(..entradas, colunas: 2, ordenar: true) = {
  positional(entradas, "indice", "as entradas, e colunas e ordenar")
  index(..entradas, columns: colunas, sort: ordenar)
}

/// Dá acesso aos dados do trabalho para compor um conteúdo personalizado. A função recebida é chamada em um contexto
/// próprio (`context`), com um dicionário `d`, e o conteúdo que ela retorna é inserido na página. É usada nos
/// parâmetros `topo`, `meio` e `pe` da capa, da folha de rosto e da folha de aprovação, e no parâmetro `ficha` da
/// ficha catalográfica.
///
/// ```typ
/// #capa(topo: com-dados(d => [#upper(d.institution) \ #d.author]))
/// ```
///
/// Campos disponíveis em `d` (as chaves são em inglês). Um campo não informado vale `none`.
///
/// - `title`, `subtitle`, `full-title`: título, subtítulo e título completo ("Título: subtítulo");
/// - `author`, `author-inverted`, `author-reference`: nome do autor em ordem direta, invertido ("Autor, Nome do") e
///   no formato de referência ("AUTOR, Nome do");
/// - `advisor`, `co-advisor`: nomes do orientador e do coorientador;
/// - `advisor-label`, `co-advisor-label`: rótulos correspondentes ("Orientador", "Orientadora" ou o rótulo
///   personalizado);
/// - `institution`, `program`, `area`, `location`, `year`, `volume`, `version`, `logo`: campos de `config-dados`;
/// - `area-label`: o termo "Área de concentração";
/// - `year-volume`: ano com o volume ("2026, v. 2");
/// - `work-type`: tipo do trabalho por extenso ("Tese (Doutorado)");
/// - `preamble`: natureza do trabalho informada na folha de rosto (`none` antes dela);
/// - `keywords`: palavras-chave do resumo no idioma do trabalho;
/// - `pages`: número de páginas, contadas a partir da folha de rosto;
/// - `data`: dicionário original de `config-dados`.
///
/// - fn (function): Função que recebe os dados e retorna o conteúdo.
/// -> content
#let com-dados(fn) = with-info(fn)
