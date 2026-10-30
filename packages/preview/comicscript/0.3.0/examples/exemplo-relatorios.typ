#import "@preview/comicscript:0.3.0" as hq
#import "pages/p01.typ": p1
#import "pages/p02.typ": p2

#set document(title: "ComicScript — relatórios")
#set page(paper: "a4", margin: 20mm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt", region: "BR")
#let paginas = (p1, p2)

#hq.mapa-narrativo(paginas)
#pagebreak()
#hq.pendencias(paginas)
#pagebreak()
#hq.dialogos(paginas)
#pagebreak()
#hq.dialogos(paginas, personagem: "Sam")
#pagebreak()
// Limiar baixo apenas para mostrar a sinalização de revisão no exemplo.
#hq.relatorio-textos(paginas, limite-palavras: 12)
