#import "@preview/Cyberschool-template:0.1.0": *
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
  logos_paths: (
    "assets/Logo_univ_rennes.png",
    "assets/Logo_cyberschool.png",
  ),
  abstract: "abstract text",
  outline_title: "Contents",
)

= Hello, world !
== Hello, world !
=== Hello, world !
