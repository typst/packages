#import "../lib.typ": *
#import "@preview/note-me:0.6.0": *

#set page(width: 7.5cm, height: auto, margin: 2mm)
#set text(font: "IBM Plex Sans JP")

#let localized-note(body) = {
  let info = detect-info(body, fallback: "en")
  let l = info.at("lang")

  let title = if l == "ja" {
    "注意"
  } else if l == "de" {
    "Hinweis"
  } else if l == "fr" {
    "Remarque"
  } else {
    "Note"
  }

  note(title: title)[
    #auto-text(fallback: "en")[#body]
  ]
}

#localized-note[This is an English note.]

#localized-note[これは日本語の注記です。]

#localized-note[Dies ist ein deutscher Hinweis.]