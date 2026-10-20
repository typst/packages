
# FeynDrawGram - Render Feynman diagrams from FeynDrawGram JSON files

This package renders diagrams produced by the
[FeynDrawGram web app](https://mbarbieri.it/feyndrawgram/).
The input is the JSON exported by the "Save" button in the app.

Typical use:
```
#import "@preview/feyndrawgram:1.0.0": feyndrawgram

#feyndrawgram(json("my-diagram.json"))
```

## Parameters:
+ `use-cetz-decorations  (default: false)`
    If `false`, photons/gluons are drawn by sampling exactly the same
    analytic path the web app shows on screen. If true, simple
    straight wavy/gluon edges with multiplicity 1 use CeTZ' native
    `decorations.wave` / `coil`; curved or multi-line oscillating edges
    always fall back to sampling so that parallel waves stay in
    phase.
+ `unit  (default: 1pt)`
    Length of one canvas pixel in document units.