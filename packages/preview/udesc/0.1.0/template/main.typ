//Modelo trabalhos acadêmicos da UDESC
//Não é um projeto oficial! 

#import "@preview/udesc:0.1.0": udesc

#show: udesc.with( 
  campus: [Centro de Ciências Tecnológicas -- CCT],
  departament: [PROGRAMA DE PÓS-GRADUAÇÃO – SIGLA OU NOME DO CURSdO],
  abstract: lorem(100),  
  title : [Manual de Trabalho Acadêmico da UDESC],
  city: "Joinville",
  year: 2024,
  author : "Lucas Vinícius Bublitz",
  obverse: [Artigo apresentado ao curso de graduação em alguma coisa do campous tal como requisito parcial para obtenção do título de Bacharel naquela coisa.\ \ Orientador: Dr. Prof. Miguel de Cervantes],
  epigraph : [_Somos por essa causa, essa somente,\ perdidos, mas nossa pena é só esta:\ sem esperança, ansiar eternamente._\ \ (A Divina Comédia, Canto IV, 40-42, Dante Alighieri)],
  acknowledgments : [Eu quero me agradecer por acreditar em mim mesmo, quero me agradecer por todo esse trabalho duro. Quero me agradecer por não tirar folgas. Quero me agradecer por nunca desistir. Quero me agradecer por ser generoso e sempre dar mais do que recebo. Quero me agradecer por tentar sempre fazer mais o certo do que o errado. Quero me agradecer por ser eu mesmo o tempo inteiro.],
  keywords: ("Primeira", "Segunda", "Terceira")
)
 

= Introdução

#lorem(100)
asd
#lorem(50)

#lorem(100)

#figure(
  caption: [Logo da UDESC],
  [
    #image("images/udesc.jpg")
    @Borges2014 
  ]
)

= Novo capítulos

#lorem(100)

#bibliography("bibliography.bib")