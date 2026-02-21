#import "src/themes/sorbonne.typ": sorbonne-template, sorbonne-red, sorbonne-blue, sorbonne-lightblue, sorbonne-yellow, sorbonne-text
#import "src/themes/iplesp.typ": iplesp-template, iplesp-red, iplesp-blue, iplesp-lightblue, iplesp-yellow, iplesp-green, iplesp-teal, iplesp-purple, iplesp-orange, iplesp-slate, iplesp-text
#import "src/core.typ": slide, focus-slide, figure-slide, figure-slide-split, acknowledgement-slide, equation-slide, ending-slide, cite-box, alert, muted, subtle, appendix, slide-break, two-col, three-col, grid-2x2, highlight-box, alert-box, example-box, algorithm-box, themed-block

// Aliases pour la commodité (par défaut vers Example car c'est le plus ancien)
#let template = sorbonne-template

#import "@preview/presentate:0.2.4": pause, uncover, only, fragments, step-item
