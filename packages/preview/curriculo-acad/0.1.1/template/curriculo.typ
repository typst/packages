// import of libraries
#import "@local/curriculo-acad:0.1.1": *

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
