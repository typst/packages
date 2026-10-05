#import "@preview/modern-usp-thesis:0.1.0": usp-thesis, appendix, annex

// Latex-style font
#set text(font: "New Computer Modern")

#show: usp-thesis.with(
  title: [Desenvolvimento de Templates Typst para a USP],
  title-alt: [Development of Typst Templates for USP],
  subtitle: [Um Estudo de Caso de Automação Acadêmica],
  author: "João da Silva",
  advisor: "Prof. Dr. Orientador Exemplar",
  institute: "Instituto de Matemática e Estatística",
  program: "Estatística",
  degree: "Mestre",
  local: "São Paulo",
  // year: "2026", // defaults to the current year
  abstract-pt: [
    Este trabalho descreve a criação de um template Typst para dissertações e teses seguindo as diretrizes da USP. O template automatiza a formatação de capas, resumos e elementos pré-textuais.
  ],
  keywords-pt: ("Typst", "USP", "Dissertação", "Automação"),
  abstract-en: [
    This work describes the creation of a Typst template for theses and dissertations following USP guidelines. The template automates the formatting of covers, abstracts, and pre-textual elements.
  ],
  keywords-en: ("Typst", "USP", "Thesis", "Automation"),
  dedication: [À minha família.],
  acknowledgments: [Agradeço à USP e à CAPES pelo apoio.],
  epigraph: ["O sucesso é a soma de pequenos esforços repetidos dia após dia." \ --- Robert Collier],
  errata: [
    #table(
      columns: (1fr, 1fr, 1fr, 1fr),
      [Folha], [Linha], [Onde se lê], [Leia-se],
      [10], [5], [Typstt], [Typst],
    )
  ],
  list-of-figures: true,
  list-of-tables: true,
  abbreviations: [
    #grid(
      columns: (100pt, 1fr),
      row-gutter: 1em,
      [ABNT], [Associação Brasileira de Normas Técnicas],
      [USP], [Universidade de São Paulo],
      [IME], [Instituto de Matemática e Estatística],
    )
  ],
  symbols: [
    #grid(
      columns: (100pt, 1fr),
      row-gutter: 1em,
      [$sigma$], [Desvio padrão],
      [$mu$], [Média populacional],
    )
  ],
  banca: (
    (nome: "Prof. Dr. Examinador 1", instituicao: "IME-USP"),
    (nome: "Prof. Dr. Examinador 2", instituicao: "IME-USP"),
    (nome: "Prof. Dr. Examinador Externo", instituicao: "UNICAMP"),
  ),
)

= Introdução

A USP exige uma formatação rigorosa para trabalhos acadêmicos. Este template visa facilitar esse processo @typst.

#figure(
  rect(width: 100pt, height: 50pt, fill: blue.lighten(80%))[Logo],
  caption: [Exemplo de ilustração],
) <fig-exemplo>

= Metodologia

Utilizamos a linguagem Typst por sua velocidade e facilidade de uso em comparação ao LaTeX.

#figure(
  table(
    columns: (auto, auto),
    [Recurso], [Benefício],
    [Velocidade], [Compilação instantânea],
    [Sintaxe], [Fácil de ler e escrever],
  ),
  caption: [Comparação de recursos],
) <tab-recursos>

= Resultados

O template consegue gerar PDFs compatíveis com as normas ABNT adotadas pela USP.

= Conclusão

Typst é uma alternativa viável para a redação de teses na USP.

#bibliography("references.bib")

// --- Pós-textuais ---

= Glossário

/ Typst: Um novo sistema de composição de documentos baseado em marcação que é projetado para ser tão poderoso quanto o LaTeX e tão fácil de usar quanto o Markdown.

#show: appendix

= Detalhes da Implementação
Este apêndice contém detalhes técnicos sobre as funções de layout.

#show: annex

= Regulamento da Pós-Graduação
Documentação oficial da USP.
