#import "@preview/board-n-pieces:0.4.0": *

#let board = board.with(

  white-square-fill: white, 
  highlighted-white-square-fill: rgb("#aee9da"),

  black-square-fill: luma(50%),
  highlighted-black-square-fill: rgb("#326b67"),

  arrow-stroke: .35em + green,

  stroke: 0.5pt,
  display-numbers: true, 
  square-size: 2em,
)