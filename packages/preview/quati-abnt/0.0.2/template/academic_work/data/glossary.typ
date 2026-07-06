// # Glossary. Glossário.

#import "../util.typ": foreign_text


// ## Abbreviations. Abreviaturas.
// NBR 14724:2024 4.2.1.11

#let abbreviations_entries = (
  (
    key: "ibge",
    short: "IBGE",
    long: "Instituto Brasileiro de Geografia e Estatística",
    group: "Normatização",
  ),
  (
    key: "abnt",
    short: "ABNT",
    long: "Associação Brasileira de Normas Técnicas",
    group: "Normatização",
  ),
  (
    key: "nbr",
    short: "NBR",
    plural: "NBRs",
    long: "Norma Brasileira",
    longplural: "Normas Brasileiras",
    group: "Normatização",
  ),
)


// ## Glossary. Glossário.
// NBR 14724:2024 4.2.3.2

#let glossary_entries = (
  (
    key: "rn",
    short: "rede neural",
    plural: "redes neurais",
    custom: foreign_text[neural network],
    description: [Em inglês, #foreign_text[neural network]. Modelo computacional composto por camadas de unidades interligadas que aprendem padrões em dados por meio de ajustes de pesos @li:2022:survey_convolutional_neural_networks.],
    group: "Computação",
  ),
)


// ## Symbols. Símbolos.
// NBR 14724:2024 4.2.1.12

#let symbols_entries = ()
