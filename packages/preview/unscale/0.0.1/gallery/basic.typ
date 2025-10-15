#import "@preview/unscale:0.0.1": scale-rule, unscale, rescale

#show scale: scale-rule

#set page(width: auto, height: auto, margin: 0.5cm)


#scale(x: 500%, y: 300%, reflow: true, box(fill: blue, align(center + horizon, text(size: 20pt)[Default])))

#scale(x: 500%, y: 300%, reflow: true, box(fill: red, align(center + horizon, rescale(text(size: 20pt)[Rescale]))))

#scale(x: 500%, y: 300%, reflow: true, box(fill: green, align(center + horizon, unscale(text(size: 20pt)[Unscale]))))
