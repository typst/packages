// ============================================================
// src/templates.typ
// Templates prontos: projeto, paper e case
// ============================================================

#import "core.typ": configurar
#import "elements.typ": capa, folha-de-rosto, sumario, configurar-rodape, configurar-alineas

// ----------------------------------------------------------
// Projeto de Pesquisa
// ----------------------------------------------------------
#let template-projeto(
  autor: "NOME COMPLETO DO ESTUDANTE",
  titulo: "TÍTULO DO PROJETO:",
  subtitulo: "",
  natureza: "Projeto de pesquisa apresentado à disciplina Metodologia Científica, do curso de X da [FACULDADE], como requisito parcial para obtenção de nota.",
  orientador: "Prof. Me. Silvio Santos",
  local: "Cidade - [SIGLA do estado]",
  ano: "2026",
  corpo,
) = {
  show: configurar.with(numeracao: none)

  capa(autor: autor, titulo: titulo, subtitulo: subtitulo, local: local, ano: ano)
  folha-de-rosto(autor: autor, titulo: titulo, subtitulo: subtitulo, natureza: natureza, orientador: orientador, local: local, ano: ano)
  sumario()

  set page(numbering: "1", number-align: top + right)
  counter(page).update(4)

  corpo
}

// ----------------------------------------------------------
// Paper / Artigo Científico
//
// `autores` é uma lista de dicionários, cada um com:
//   (nome: "...", nota: "...", email: "...")
// O campo `email` é opcional — se omitido, não aparece na nota.
//
// `nota-titulo` é opcional — se vazio (""), não gera nota no título.
//
// Exemplo com dois autores:
//   autores: (
//     (nome: "Fulano Silva", nota: "Acadêmico de X – [FACULDADE].", email: "fulano@gmail.com"),
//     (nome: "Beltrana Costa", nota: "Acadêmica de X – [FACULDADE].", email: ""),
//   ),
// ----------------------------------------------------------
#let template-paper(
  titulo: "TÍTULO DO ARTIGO:",
  subtitulo: "",
  nota-titulo: "",           // Nota de rodapé vinculada ao título; deixe "" para omitir
  autores: (                 // Lista de autores
    (nome: "Nome do Autor", nota: "Acadêmico do curso de X – [FACULDADE].", email: "estudante@gmail.com"),
  ),
  orientador: "Prof. Me. Nome do Orientador",
  nota-orientador: "Professor da [FACULDADE] – [Sigla, se houver].",
  email-orientador: "professor@gmail.com",
  resumo: [],
  palavras-chave: "Palavra. Palavra. Palavra.",
  corpo,
) = {
  show: configurar
  show: configurar-rodape

  // Título centralizado, com nota opcional
  align(center)[
    #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em)
    #text(weight: "bold")[
      #titulo#if nota-titulo != "" { footnote(nota-titulo) }
    ] \
    #text(weight: "regular")[#subtitulo]
  ]

  v(1em)

  // Autores + orientador alinhados à direita
  align(right)[
    #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em, justify: false)
    // Cada autor numa linha com sua nota de rodapé
    #for a in autores {
      let nota-completa = if a.at("email", default: "") != "" {
        a.nota + " E-mail: " + a.at("email", default: "")
      } else {
        a.nota
      }
      [#a.nome#footnote[#nota-completa] \ ]
    }
    // Orientador
    #let nota-orient = if email-orientador != "" {
      nota-orientador + " E-mail: " + email-orientador
    } else {
      nota-orientador
    }
    #orientador#footnote[#nota-orient]
  ]

  v(2em)

  block[
    #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em, spacing: 1em)
    #text(weight: "bold")[Resumo:] #resumo

    #text(weight: "bold")[Palavras-chave:] #palavras-chave
  ]
  v(2em)

  corpo
}

// ----------------------------------------------------------
// Case / Relatório Parcial
// ----------------------------------------------------------
#let template-case(
  tipo: "RELATÓRIO PARCIAL:",
  tema: "TEMA DO CASE",
  nota-tema: "Case apresentado à disciplina de X na [FACULDADE] – [Sigla, se houver].",
  discente: "Discente (nome completo)",
  nota-discente: "Discente do curso de X – [FACULDADE].",
  docente: "Docente (nome completo)",
  nota-docente: "Docente Mestre, Orientador.",
  corpo,
) = {
  show: configurar
  show: configurar-rodape
  show: configurar-alineas

  align(center)[
    #set par(first-line-indent: (amount: 0pt, all: true))
    #strong[#tipo] #tema#footnote[#nota-tema]
  ]

  v(1em)

  align(right)[
    #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em, justify: false)
    #discente#footnote[#nota-discente] \
    #docente#footnote[#nota-docente]
  ]

  v(2em)

  corpo
}
