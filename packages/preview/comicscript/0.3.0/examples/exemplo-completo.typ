#import "@preview/comicscript:0.3.0" as hq
#import "pages/p01.typ": p1
#import "pages/p02.typ": p2

#set document(title: "ComicScript — exemplo das páginas 1 e 2")
#set page(paper: "a4", margin: 20mm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt", region: "BR")

#hq.renderizar(
  (p1, p2),
  modo: sys.inputs.at("modo", default: "editorial"),
  estados-notas: if sys.inputs.at("notas", default: "todas") == "abertas" {
    ("aberta",)
  } else {
    ("aberta", "resolvida", "descartada")
  },
)
