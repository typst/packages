//#import "@preview/ape:0.3.0": *
#import "../lib.typ": *
#show: doc.with(
  lang: "fr",
  title: ("Chap", "Voici un titre très très long qui prend bcp de placee"),
  authors: "Auteur",
  style: "colored", // numbered, colored, plain
  title-page: true,
  outline: true,
  smallcaps: true,
)