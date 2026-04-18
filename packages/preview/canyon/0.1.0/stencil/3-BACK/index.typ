#import "../SETUP/CONFIG.typ": CONFIG

#import "@preview/in-dexter:0.7.2": *

= Index

#columns(2)[
  #make-index(
    title: none,
    outlined: true,
    section-title: (letter, counter) => {
      if counter >= 0 {
        line(
          length: 100%,
          stroke: 2pt + CONFIG.color.theme,
        )
      }
    },
    use-page-counter: true,
  )
  #v(-0.5em)
  #line(
    length: 100%,
    stroke: 2pt + CONFIG.color.theme,
  )
]
