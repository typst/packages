// abntly: academic works in the Brazilian ABNT standard (NBR 14724, 6023, 6024, 6027, 6028, 10520).
//
// A single style, configured as far as possible with `set` rules. The modules, and what each one exports:
//
// - src/abntly.typ: the main function, `abntly`, which applies the rules of the modules below, one after the other.
// - src/layout.typ: the page, the running header, the links and the parts of the work (`front-matter`,
//   `main-matter`, `back-matter`); the default colour of the links (`dark-indigo`).
// - src/fonts.typ: the typography (New Computer Modern).
// - src/spacing.typ: the spacing (the 1.5 of NBR 14724 between the lines, the distances and indents around each
//   element); the paragraph without the indent of its first line (`no-indent`).
// - src/elements.typ: the form of the elements of the text, with the functions the author writes inside a figure
//   (`source`, `legend`, `note`, and `call` in a table), a reference with its name (`auto-ref`), the quadro
//   (`frame`), the figure in a box as wide as its illustration (`fitted`), where a table with a header is a table of
//   the IBGE, the same table for a plain figure (`ibge-table`), the nature of the work on the title page and the
//   approval sheet (`preamble`), and the elements beyond the norms: the algorithm (`algorithm`), the subfigures (`subfigures`, over the package subpar), the part
//   (`part`), the figure lying down (`sideways`), the stamp of a draft (`stamp`) and the signature line
//   (`signature`). The displayed equations are numbered over the package equate.
// - src/words.typ: the words of the package in Portuguese and English (src/lang.toml), over the package linguify;
//   `config-names` replaces them.
// - src/info.typ: the data of the work (`config-info`), which the main function takes in `info` and the pages of the
//   structure print.
// - src/structure.typ: those pages: the cover (`cover`), the title page (`title-page`), the catalog card on its verso
//   (`catalog-card`) and the approval sheet (`approval-page`), and the pages of the pre-textual part around them: the
//   errata (`errata`), the dedication (`dedication`), the acknowledgments (`acknowledgments`), the epigraph
//   (`epigraph`) and the abstracts (`abstract`, with their `keywords`); the lists (`list-of`, `list-of-figures`,
//   `list-of-tables`, `list-of-frames`, `list-of-acronyms`, `list-of-symbols`), the summary, the glossary
//   (`glossary`), the appendices (`appendix`) and the annexes (`annex`). `with-info` gives the data of the work,
//   ready to print, to a part of a page the author writes.
// - src/index.typ: the index (`index`, written by the author).
// - src/citations.typ: the calls and the list of references (NBR 10520, NBR 6023) over Typst's `cite` and
//   `bibliography` with the CSL of src/csl/; the citation of a citation (`apud`).
// - src/aliases.typ: the name of each function in Portuguese, with its parameters and its help in Portuguese (the
//   main function is `trabalho-academico`). `auto-ref`, `errata` and `apud` have the same name in both languages.
#import "abntly.typ": abntly
#import "elements.typ": (source, legend, note, call, auto-ref, frame, fitted, ibge-table, preamble, algorithm,
  subfigures, part, sideways, stamp, signature)
#import "spacing.typ": no-indent
#import "layout.typ": front-matter, main-matter, back-matter, dark-indigo
#import "words.typ": config-names
#import "info.typ": config-info
#import "structure.typ": (cover, title-page, approval-page, catalog-card, errata, dedication, acknowledgments,
  epigraph, abstract, keywords, list-of, list-of-figures, list-of-tables, list-of-frames, list-of-acronyms,
  list-of-symbols, appendix, annex, glossary, with-info)
#import "index.typ": index
#import "citations.typ": apud
// the Portuguese names, each a function with its parameters and its help in Portuguese (src/aliases.typ)
#import "aliases.typ": (trabalho-academico, indigo-escuro, config-nomes, config-dados, pretextual, textual,
  postextual, fonte, legenda, nota, chamada, quadro, ajustada, tabela-ibge, sem-recuo, preambulo, algoritmo,
  subfiguras, parte, deitada, carimbo, assinatura, capa, folha-de-rosto, folha-de-aprovacao, ficha-catalografica,
  dedicatoria, agradecimentos, epigrafe, resumo, palavras-chave, lista-de, lista-de-figuras, lista-de-tabelas,
  lista-de-quadros, lista-de-siglas, lista-de-simbolos, apendice, anexo, glossario, indice, com-dados)
