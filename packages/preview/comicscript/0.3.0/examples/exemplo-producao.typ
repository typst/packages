#import "@preview/comicscript:0.3.0" as hq
#import "pages/p01.typ": p1
#import "pages/p02.typ": p2

#set document(title: "ComicScript — produção da arte")
#set page(paper: "a4", margin: 20mm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt", region: "BR")

// Inclui notas de composição e continuidade; oculta subtexto e alternativas.
#hq.renderizar((p1, p2), modo: "producao")
