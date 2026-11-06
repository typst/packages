// Integração com sistema de bibliografia do Typst
// Formatação automática ABNT via CSL (NBR 6023:2018 / NBR 10520:2023)

/// Configura bibliografia ABNT
///
/// Usa o arquivo CSL ABNT incluído no pacote para formatação automática
/// das referências conforme NBR 6023:2018.
///
/// Parâmetros:
/// - arquivo: caminho para arquivo .bib ou .yaml com as referências
/// - titulo: título da seção (padrão: "REFERÊNCIAS")
/// - completa: se true, mostra todas as entradas; se false, apenas as citadas
///
/// Exemplo:
/// ```typst
/// #abnt-bibliography("referencias.bib")
/// ```
///
/// Limitações conhecidas:
/// - Subtítulos aparecem em negrito junto com o título (limitação do CSL)
/// - Títulos sem autor: a primeira palavra deve estar em MAIÚSCULAS no .bib
/// - Legislação tem suporte limitado
#let abnt-bibliography(arquivo, titulo: "REFERÊNCIAS", completa: false) = {
  // Título da seção de referências
  heading(level: 1, numbering: none, titulo)

  // Configuração de parágrafo para referências
  // Recuo francês de 1,25cm, espaçamento simples
  set par(
    hanging-indent: 1.25cm,
    first-line-indent: 0pt,
    leading: 1em,
  )

  // Usa o CSL ABNT incluído no pacote
  // O caminho é relativo a este arquivo
  bibliography(arquivo, style: "abnt.csl", title: none, full: completa)
}

/// Configura citações para formato ABNT
///
/// Aplica configurações de citação autor-data conforme NBR 10520:2023.
/// Use esta função com #show para configurar todo o documento.
///
/// Exemplo:
/// ```typst
/// #show: abnt-cite-setup
///
/// Conforme @silva2023, a formatação é importante.
/// Outros autores concordam @santos2022[p. 45].
/// ```
///
/// Formato das citações:
/// - No texto: (Silva, 2023)
/// - Com página: (Silva, 2023, p. 45)
/// - Múltiplos: (Silva, 2023; Santos, 2022)
#let abnt-cite-setup(body) = {
  // Configurações de citação no estilo autor-data
  set cite(style: "author-date")
  body
}

/// Wrapper em português para abnt-cite-setup
///
/// Exemplo:
/// ```typst
/// #show: configurar-citacoes-abnt
/// ```
#let configurar-citacoes-abnt = abnt-cite-setup

/// Bibliografia ABNT simplificada (função wrapper)
///
/// Versão simplificada que aplica todas as configurações necessárias.
/// Ideal para uso no final do documento.
///
/// Parâmetros:
/// - arquivo: caminho para arquivo .bib
/// - titulo: título da seção (padrão: "REFERÊNCIAS")
/// - completa: se true, mostra todas as entradas; se false, apenas as citadas
#let referencias(arquivo, titulo: "REFERÊNCIAS", completa: false) = {
  abnt-bibliography(arquivo, titulo: titulo, completa: completa)
}
