#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 2mm)
#set text(font: "IBM Plex Sans JP")

#let samples = (
  ja: "これは日本語の文章です。",
  en: "This is an English sentence.",
)

#let print-lang(text) = [
  #text $arrow$ #lang(text) \
]

#print-lang(samples.ja)
#print-lang(samples.en)