// Caixa para registrar o que foi aprendido, dúvidas e próximos passos.
#import "settings.typ": settings

#let campo-reflexao(rotulo, resposta, sugestao) = context {
  let s = settings.get()
  block(width: 100%, above: 0.25em, below: 0.5em)[
    #text(font: s.fonts.sans, weight: "bold", fill: s.theme.strong)[#rotulo]
    #linebreak()
    #if resposta == none {
      text(fill: s.theme.muted, style: "italic")[#sugestao]
      linebreak()
      line(length: 100%, stroke: 0.5pt + s.theme.line)
    } else {
      resposta
    }
  ]
}

// Cada resposta pode ser escrita entre colchetes no arquivo .typ.
#let reflexao(
  titulo: "Reflexão pessoal",
  entendi: none,
  duvidas: none,
  conexoes: none,
  proxima_revisao: none,
) = context {
  let s = settings.get()
  block(
    width: 100%,
    breakable: true,
    inset: 0.8em,
    fill: s.theme.page,
    stroke: (left: 2pt + s.theme.strong, top: 0.5pt + s.theme.line, right: 0.5pt + s.theme.line, bottom: 0.5pt + s.theme.line),
  )[
    #text(font: s.fonts.sans, size: 1.15em, weight: "bold", fill: s.theme.strong)[#titulo]
    #v(0.4em)
    #campo-reflexao("O que entendi e consigo explicar sem consultar?", entendi, "Escreva a ideia principal com suas próprias palavras.")
    #campo-reflexao("O que ainda ficou confuso?", duvidas, "Anote conceitos, etapas ou exceções que precisa esclarecer.")
    #campo-reflexao("Com que outro assunto ou situação isso se conecta?", conexoes, "Registre relações com outras matérias, questões ou exemplos práticos.")
    #campo-reflexao("Qual será meu próximo passo de revisão?", proxima_revisao, "Defina uma ação concreta: resolver questões, reler um artigo ou revisar um ponto.")
  ]
}
