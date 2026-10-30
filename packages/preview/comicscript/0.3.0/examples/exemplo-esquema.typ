#import "@preview/comicscript:0.3.0" as hq
#import "pages/p01.typ": p1
#import "pages/p02.typ": p2

#set document(title: "ComicScript — esquema geométrico")
#set page(paper: "a4", margin: 20mm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt, lang: "pt", region: "BR")

// Na página 1, a segunda linha tem três vezes a altura da primeira.
// Na página 2, a segunda linha tem dois quadrinhos de mesma largura.
#hq.renderizar((p1, p2), modo: "esquema")
