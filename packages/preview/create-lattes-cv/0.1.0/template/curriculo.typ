// import of libraries
#import "@preview/curriculo-acad:0.1.0": *
#import "@preview/datify:0.1.3": *


// criando banco de dados
#let dados = toml(data/exemplo.toml)

// função: criar Lattes CV
// Argumentos:
// - database: o arquivo de TOML com os dados de Lattes (string)
// - kind: o tipo de currículo Lattes (string)
// - me: o nome para destacar nas citações (string)
// - last_page: resumo de produção no final (boolean)
#show: lattes-cv.with(
  database: dados,
  kind: "completo",
  me: "KLEER",
  last_page: true
)   
