#import "@preview/comicscript:0.3.0" as hq

#set page(paper: "a4", margin: 20mm)
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt", region: "BR")

#let paginas = (
  hq.pagina(
    1,
    hq.linha(
      hq.quadro[Uma luz acende sobre a bancada de testes.],
      hq.quadro(
        textos: (hq.fala("Alex")[Podemos começar?],),
      )[Alex confere o painel de controle.],
    ),
  ),
)

#hq.renderizar(paginas, modo: sys.inputs.at("modo", default: "roteiro"))
