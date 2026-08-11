// Configuração global de layout e tipografia

#set text(
  font: ("NewsGotT", "Times New Roman", "Liberation Serif"),
  size: 12pt,
  lang: "pt"
)

// Configuração da página
#set page(
  paper: "a4",
  margin: 2.5cm,
  numbering: "1",
  number-align: center
)

// Configuração de parágrafos
#set par(
  justify: true,
  leading: 1.5em
)

// Função para aplicar configurações comuns de layout
#let apply-common-layout(content, lang: "PT") = {
  set page(numbering: "1", margin: 2.5cm)
  set text(font: ("NewsGotT", "Times New Roman", "Liberation Serif"), size: 12pt)
  set par(leading: 1.5em, justify: true, spacing: 1.5em)

  let fig_supplement = if lang == "EN" { "Figure" } else { "Figura" }
  let tab_supplement = if lang == "EN" { "Table" } else { "Tabela" }
  
  show figure.where(kind: image): set figure(supplement: fig_supplement)
  show figure.where(kind: table): set figure(supplement: tab_supplement)
  
  content
}

// Função para aplicar estilos de títulos de forma consistente
#let apply-heading-styles(content) = {
  show heading.where(level: 1): it => block(
    width: 100%,
    above: 2em,
    below: 2em,
    align(center, text(size: 12pt, weight: "bold", it.body))
  )
  
  show heading.where(level: 2): it => block(
    width: 100%,
    below: 1em,
    align(left, text(size: 12pt, weight: "bold", it.body))
  )
  
  content
}

// Função para aplicar apenas estilos de nível 2 (para usar em appendix)
#let apply-heading-level2-styles(content) = {
  show heading.where(level: 2): it => block(
    width: 100%,
    below: 1em,
    align(left, text(size: 12pt, weight: "bold", it.body))
  )
  
  content
}

// Função para aplicar estilos de figuras e tabelas
#let apply-figure-styles(content) = {
  show figure.caption: it => {
    text(size: 11pt)[
      #text(weight: "bold")[
        #it.supplement
        #context it.counter.display(it.numbering)
      ]: #it.body
    ]
  }
  
  content
}

// Função combinada: aplica layout comum + estilos de títulos
#let apply-standard-layout(content, lang: "PT") = {
  apply-common-layout(lang: lang)[
   #apply-heading-styles[
      #apply-figure-styles(content)
    ]
  ]
}

// Dicionário centralizado de termos traduzidos
#let translations = (
  "pt": (
    "abstract": "Resumo",
    "keywords": "Palavras-chave",
    "acknowledgements": "Agradecimentos",
    "funding": "Financiamento",
    "integrity": "Declaração de Integridade",
    "copyright": "Direitos de Autor e Condições de Utilização do Trabalho por Terceiros",
    "toc": "Índice",
    "lof": "Lista de Figuras",
    "lot": "Lista de Tabelas",
    "acronyms": "Abreviaturas e Siglas",
    "glossary": "Glossário",
    "appendix": "Anexo",
    "bibliography": "Referências",
    "copyright_statement": "Este é um trabalho académico que pode ser utilizado por terceiros desde que boas práticas internacionalmente aceites, no que concerne aos direitos de autor e direitos conexos.
Assim, o presente trabalho pode ser utilizado nos termos previstos na licença abaixo indicada.
Caso o utilizador necessite de permissão para poder fazer um uso do trabalho em condições não previstas no licenciamento indicado, deverá contactar o autor, através do RepositóriUM da Universidade do Minho.

Licença concebida aos utilizadores deste trabalho:",
    "integrity_statement": "Declaro ter atuado com integridade na elaboração do presente trabalho académico e confirmo que não recorri à prática de plágio nem a qualquer forma de utilização indevida ou falsificação de informações ou resultados em nenhuma das etapas conducentes à sua elaboração.
Mais declaro que conheço e que respeitei o Código de Conduta Ética da Universidade do Minho.",
    "ai_tools": "Declaração de Uso de Ferramentas de Inteligência Artificial (IA)",
    "ai_tools_statement": "Declaro ter atuado com integridade na elaboração do presente trabalho académico e confirmo que não recorri a qualquer forma de utilização indevida de ferramentas de Inteligência Artificial (IA), nem à falsificação ou omissão de informações, fontes, dados, resultados ou processos em nenhuma das etapas conducentes à sua elaboração.
Declaro ainda que qualquer utilização de ferramentas de IA foi feita de forma transparente e responsável, encontrando-se devidamente assinalada/descrita no trabalho, e que procedi à verificação crítica da exatidão do conteúdo produzido com o seu apoio, assumindo integralmente a responsabilidade pelo que submeto.
Mais declaro que conheço e que respeitei o Código de Conduta Ética da Universidade do Minho, bem como as normas aplicáveis de integridade académica e de proteção de dados."
  ),
  "en": (
    "abstract": "Abstract",
    "keywords": "Keywords",
    "acknowledgements": "Acknowledgements",
    "funding": "Funding",
    "integrity": "Statement of Integrity",
    "copyright": "Copyright and Conditions of Use of the Work by Third Parties",
    "toc": "Table of Contents",
    "lof": "List of Figures",
    "lot": "List of Tables",
    "acronyms": "Abbreviations and Acronyms",
    "glossary": "Glossary",
    "appendix": "Appendix",
    "bibliography": "References",
    "copyright_statement": "This is an academic work that can be used by third parties as long as internationally accepted good practices regarding copyright and related rights are respected.
Thus, the present work can be used under the terms provided in the license indicated below.
If the user needs permission to make use of the work under conditions not provided for in the indicated licensing, they should contact the author through the RepositóriUM of the University of Minho.

License granted to users of this work:",
    "integrity_statement": "I declare that I have acted with integrity in the preparation of this academic work and confirm that I have not resorted to plagiarism or any form of improper use or falsification of information or results in any of the stages leading to its preparation.
I further declare that I know and have respected the Code of Ethical Conduct of the University of Minho.",
    "ai_tools": "Declaration on the Use of Artificial Intelligence (AI) Tools",
    "ai_tools_statement": "I hereby declare having acted this academic work with integrity and confirm that I have not resorted to any form of undue use of AI tools, nor to the falsification or omission of information, sources, data, results or processes in any of the stages leading to its elaboration.
I further declare that any use of AI tools was done in a transparent and responsible manner, being duly noted in the work, and that I critically verified the accuracy of the content produced with their support, assuming full responsibility for what I submit.
I further declare that I have fully acknowledged the Code of Ethical Conduct of the University of Minho, as well as the applicable standards of academic integrity and data protection."
  )
)

// Função auxiliar para buscar traduções
#let dict(key, lang: "PT") = {
  let lang-key = if lang == "EN" { "en" } else { "pt" }
  if key in translations.at(lang-key) {
    translations.at(lang-key).at(key)
  } else {
    key
  }
}

