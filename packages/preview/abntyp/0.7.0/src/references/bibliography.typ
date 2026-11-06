// Integração com sistema de bibliografia do Typst
// Formatação automática ABNT via CSL (NBR 6023:2018 / NBR 10520:2023)

#import "../core/spacing.typ": abnt-leading, abnt-top-edge, abnt-bottom-edge

/// Configura bibliografia ABNT
///
/// Usa o arquivo CSL ABNT incluído no pacote para formatação automática
/// das referências conforme NBR 6023:2018.
///
/// COMO INFORMAR O .bib (importante):
/// Por uma limitação do Typst, um *caminho em string* passado a uma função de
/// pacote é resolvido em relação ao pacote, e não ao SEU documento — então o
/// arquivo ao lado do seu .typ não seria encontrado. A forma correta é passar
/// o conteúdo lido com `read(...)`, que resolve o caminho a partir do seu
/// documento:
/// ```typst
/// #abnt-bibliography(read("referencias.bib"))
/// ```
///
/// Parâmetros:
/// - arquivo: conteúdo do .bib via `read("arquivo.bib")` (recomendado),
///   ou `bytes` via `read(..., encoding: none)`. Uma string simples ainda é
///   aceita como caminho legado, mas resolve relativo ao pacote (desencorajado).
/// - titulo: título da seção (padrão: "REFERÊNCIAS")
/// - completa: se true, mostra todas as entradas; se false, apenas as citadas
///
/// Como codificar no .bib (o Typst não lê todos os campos do BibTeX):
/// - capítulo de livro: `inbook` com `booktitle` e `editor` (não `incollection`)
/// - tese/dissertação: `publisher` (não `school`/`institution`) e `type` completo,
///   ex.: `type = {Tese (Doutorado em Física)}`; relatório/norma: `publisher`
/// - trabalho em evento: `booktitle = {Anais}`, `eventtitle`, `venue`,
///   `eventdate`, `publisher` (o CSL põe o evento em maiúsculas e `Anais [...]`)
/// - entidade como autor: caixa mista (`{{Organização Mundial da Saúde}}`)
/// - obra sem autoria: `shorttitle = {Primeira [...]}` para a chamada no texto
/// - mesmo sobrenome e ano: o CSL desambigua por iniciais `(Barbosa, C., 1958)`
///   no Typst 0.13 e 0.14; no 0.15 cai no sufixo `1958a`/`1958b`
///
/// Limitações conhecidas:
/// - O campo `subtitle` do BibTeX é DESCARTADO pelo Typst: escreva
///   `title = {Título: subtítulo}` (título e subtítulo saem juntos em negrito)
/// - Títulos sem autor: a primeira palavra deve estar em MAIÚSCULAS no .bib
/// - Legislação, jurisprudência, atos administrativos e documentos de cartório:
///   o Typst não tem campos para eles; escreva a referência à mão (NBR 6023, 7.11)
/// - Nomes que começam por letra acentuada vão para depois do Z na ordenação
#let abnt-bibliography(arquivo, titulo: "REFERÊNCIAS", completa: false) = {
  // Título da seção de referências
  heading(level: 1, numbering: none, titulo)

  // Configuração de parágrafo para referências (NBR 6023, 6.3): espaço simples,
  // alinhadas à margem esquerda (sem recuo e sem justificar) e separadas entre
  // si por uma linha em branco de espaço simples (spacing = passo de duas linhas
  // simples, ou seja, uma linha vazia entre as entradas). Idioma fixado em
  // pt-BR: sem a região o Typst escolhe pt-PT ("Acedido", "(eds..)").
  set text(
    lang: "pt",
    region: "BR",
    top-edge: abnt-top-edge,
    bottom-edge: abnt-bottom-edge,
  )
  set par(
    first-line-indent: 0pt,
    leading: abnt-leading(1),
    spacing: abnt-leading(2),
    justify: false,
  )

  // Resolução da fonte de referências:
  // - bytes  -> conteúdo lido com read(path, encoding: none)
  // - string com conteúdo (de read(path)) -> convertida em bytes
  // - string simples "arquivo.bib" -> caminho legado (relativo a ESTE módulo
  //   do pacote; prefira read(...) para que o caminho seja relativo ao seu .typ)
  if type(arquivo) == str and arquivo.ends-with(".bib") and not arquivo.contains("\n") {
    panic(
      "abnt-bibliography(): use read(\"" + arquivo + "\") em vez do caminho em string. "
        + "Um caminho em string seria resolvido relativo ao pacote, não ao seu documento.",
    )
  }

  let fonte = if type(arquivo) == bytes {
    arquivo
  } else if type(arquivo) == str and (arquivo.contains("\n") or arquivo.contains("@")) {
    bytes(arquivo)
  } else {
    arquivo
  }

  // O CSL ABNT (abnt.csl) é resolvido em relação a este arquivo do pacote
  bibliography(fonte, style: "abnt.csl", title: none, full: completa)
}

/// Configura citações para formato ABNT (OPCIONAL / retrocompatível).
///
/// As citações `@chave` já adotam automaticamente o estilo da bibliografia
/// declarada por `#referencias(...)` (que usa o CSL ABNT). Portanto, NÃO é
/// necessário chamar esta função --- o `@chave` funciona sozinho, bastando
/// haver um `#referencias(...)` no documento. Mantida apenas para que
/// documentos antigos com `#show: configurar-citacoes-abnt` continuem
/// compilando.
///
/// Exemplo (a função é dispensável):
/// ```typst
/// Conforme @silva2023, a formatação é importante.
/// Outros autores concordam @santos2022[p. 45].
///
/// #referencias("referencias.bib")
/// ```
///
/// Formato gerado pelo CSL ABNT (NBR 10520:2023, inicial maiúscula):
/// - No texto: (Silva, 2023)
/// - Com página: (Silva, 2023, p. 45)
/// - Autor na frase: Silva (2023) --- use #cite(<chave>, form: "prose")
/// - Múltiplas obras: (Santos, 2022; Silva, 2023) --- cite @a@b juntos
#let abnt-cite-setup(body) = body

/// Wrapper em português para abnt-cite-setup
///
/// Exemplo:
/// ```typst
/// #show: configurar-citacoes-abnt
/// ```
#let configurar-citacoes-abnt = abnt-cite-setup

/// Bibliografia ABNT simplificada (função wrapper)
///
/// Ideal para uso no final do documento. Informe o .bib com `read(...)` para
/// que o caminho seja resolvido a partir do SEU documento:
/// ```typst
/// #referencias(read("referencias.bib"))
/// ```
///
/// Parâmetros:
/// - arquivo: conteúdo do .bib via `read("arquivo.bib")` (recomendado)
/// - titulo: título da seção (padrão: "REFERÊNCIAS")
/// - completa: se true, mostra todas as entradas; se false, apenas as citadas
#let referencias(arquivo, titulo: "REFERÊNCIAS", completa: false) = {
  abnt-bibliography(arquivo, titulo: titulo, completa: completa)
}
