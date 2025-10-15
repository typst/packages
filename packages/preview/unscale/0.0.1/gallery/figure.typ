#import "@preview/unscale:0.0.1": rescale, scale-rule, unscale

#show scale: scale-rule

#set page(width: 5cm, height: 5cm, margin: 0.5cm)

#let diagram = {
  emoji.face.inv
  place(center + horizon, dy: -0.16cm, unscale[Smile!])
}

#figure(scale(-800%, reflow: true, diagram), caption: [A smiley face])
