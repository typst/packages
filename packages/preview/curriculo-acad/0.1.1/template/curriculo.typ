// import of libraries
#import "@preview/curriculo-acad:0.1.1": *
#import "@preview/datify:1.0.0": *


// criando banco de dados
#let dados = toml("data/exemplo.toml")

// função: criar Lattes CV
// Argumentos:
// - dados: o objeto de dados (criado acima)
// - kind: o tipo de currículo Lattes (string)
// - me: o nome para destacar nas citações (string)
// - last-page: resumo de produção no final (boolean)
#show: lattes-cv.with(
  dados,
  kind: "completo",
  me: "KLEER",
  last-page: true,
)
