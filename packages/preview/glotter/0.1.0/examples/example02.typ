#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 2mm)
#set text(font: "IBM Plex Sans JP")

#let samples = (
  ja: "これは日本語の文章です。",
  en: "This is an English sentence.",
)

#let info = detect-info(
  samples.en,
  k: 3,
  min-margin: 0.12,
)

#let print-info(info) = [
  Language: #info.at("lang") \
  Probability: #info.at("probability") \
  Ambiguous: #info.at("ambiguous")
]

#print-info(info)