#import "@preview/knowledge-key:1.0.1": *

#show: knowledge-key.with(
  title: [Title],
  authors: "Author1, Author2"
)

#include "sections/01-introduction.typ"
#include "sections/02-devops-with-gitlab.typ"
#include "sections/03-terraform.typ"