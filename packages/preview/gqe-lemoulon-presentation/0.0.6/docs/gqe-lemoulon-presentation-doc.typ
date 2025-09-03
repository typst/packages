#import "@preview/tidy:0.4.2"
#import "template.typ": *
#import "../src/exports.typ": *

#let version = toml("/typst.toml").package.version
#show "tidy:0.0.0": "tidy:" + version


#show: project.with(
  title: "GQE - Le Moulon - presentation",
  subtitle: "GQE laboratory theme for touying.",
  authors: (
    "Olivier Langella",
  ),
  abstract: [
    *gqe-lemoulon-presentation* is a template that generates presentation slides using the #link("https://touying-typ.github.io/",[Touying]) package in #link("https://typst.app/", [Typst]).
  ],
  date: datetime.today().display("[month repr:long] [day], [year]"),
  version: version,
  url: "https://forge.inrae.fr/gqe-moulon/gqe-presentation"
)


= Builtin functions

#{
  let module = tidy.parse-module(read("/src/image-legende.typ"))
  tidy.show-module(module, style: tidy.styles.default)
}

#{
  let module = tidy.parse-module(read("/src/pave.typ"))
  tidy.show-module(module, style: tidy.styles.default)
}


= GQE theme reference

#{
  let module = tidy.parse-module(read("../themes/gqe.typ"))
  tidy.show-module(module, style: tidy.styles.default)
}
