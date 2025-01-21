//#import "@preview/ape:0.1.0": *
#import "../lib.typ" : *


#show: doc.with(
	lang: "fr",

  title: ("Chapitre", "Titre"),
  authors: (),
  style: "numbered",

  title-page: true,
  outline: true,
)


#{
  for _ in range(50){
    [= Test]
  }
}






