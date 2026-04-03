#import "@preview/jsume:0.1.0": *

#show: jsume.with(
  paper: "a4",
  top-margin: 0.3in,
  bottom-margin: 0.3in,
  left-margin: 0.3in,
  right-margin: 0.3in,
  font: "Libertinus Serif",
  nerd-font: "Symbols Nerd Font",
  font-size: 11pt,
  lang: "en-US",
  jsume-data: json("en-US.jsume.json"),
)
