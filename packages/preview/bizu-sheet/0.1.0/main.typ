#import "@preview/bizu-sheet:0.1.0": *

#show: bizuario.with(
  title: "Meu bizuário",
  subtitle: "Revisão rápida",
  author: "Seu nome",
)

= Primeiro tópico

#b-card(title: "Resumo", tone: "info")[
  Escreva aqui o conteúdo da sua revisão.
]

#b-formula(
  title: "Fórmula importante",
  $ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2 a) $,
)

#b-checklist((
  [Revise a definição principal.],
  [Confira as unidades ou condições.],
  [Resolva uma questão de aplicação.],
))
