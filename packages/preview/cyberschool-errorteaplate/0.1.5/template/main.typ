#import "@preview/cyberschool-errorteaplate:0.1.5": *
#show: conf.with(
  title: "Title",
  pre-title: "Pre-title",
  authors: (
    (
      name: "name",
      affiliation: "affiliation",
      email: "email",
    ),
  ),
  logos: (
    image.with("assets/Logo_univ_rennes.png"),
    image.with("assets/Logo_cyberschool.png"),
  ),
  abstract: "abstract text",
  outline-title: "Contents",
)

= Hello, world !
== Hello, world !
=== Hello, world !
