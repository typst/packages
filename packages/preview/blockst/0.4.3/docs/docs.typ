// blockst — Handbuch (PDF) und Website (HTML) aus einer Quelle.
//
//     typst compile docs/docs.typ public --format bundle --features bundle,html --root .

#import "@schule/schuldocs:0.3.0": docs, doc-target

// Das Logo (examples/logo.svg, ein Hut- auf einem Stapelblock) vor dem
// Namen. schuldocs setzt `logo` an die Stelle des Namens, deshalb bringt der
// Inhalt den Namen mit — auf der Website in der Schrift des Kopfes, im
// Handbuch in der Schrift der Titelseite.
#let logo = context if doc-target() == "web" {
  // In einer Box, sonst steht das Bild als Block da und der Name landet in
  // einem eigenen <p> innerhalb der Überschrift.
  { box(image("../examples/logo.svg", height: 1.35em, alt: "blockst")); "blockst" }
} else {
  text(
    font: ("Inter", "Source Sans 3", "Noto Sans", "Helvetica Neue"),
    size: 30pt, weight: 600, fill: rgb("#0c4a6e"),
  )[#box(baseline: 18%, image("../examples/logo.svg", height: 1.05em)) #h(0.1em) blockst]
}

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Loewe1000",),
  logo: logo,
  abstract: [
    *blockst* renders programming blocks directly in Typst documents — Scratch,
    Blockly with a jwinf profile, MakeCode for the micro:bit and the Calliope
    mini, and Open Roberta NEPO — for worksheets, tutorials and teaching
    material. Block code is written as plain text and rendered by a bundled WASM
    plugin, Scratch in 26 languages including right-to-left scripts, with a
    turtle-graphics execution engine and helpers for importing real `.sb3`
    project files.
  ],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/blockst"),),
  notices: ([Part of the Schule Typst ecosystem],),
  // Ein Kapitel je Seite; die Kataloge allein rendern mehrere hundert Blöcke.
  split: true,
  toc-depth: 2,
)

#include "content.typ"
