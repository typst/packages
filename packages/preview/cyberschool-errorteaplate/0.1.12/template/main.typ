#import "@preview/cyberschool-errorteaplate:0.1.12": *
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
  supervisors: (
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
  abstract-title: "New abstract title",
  abstract: "abstract text",
  date: "New date",
  show-outline: true,
  outline-title: "Contents",
  outline-level: 3,
)

= Hello, world !
== Hello, world !
=== Hello, world !
