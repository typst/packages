This package provides per-page foreground and background management.


Setup:

```typst
#import "@preview/ose-pic:0.1.2": *
// Setup
#set page(
    foreground: osepic_default_foreground_handler(),
    background: osepic_default_background_handler(),
)
// Or...
#set page(
    foreground: [
        // My other stuff...
        #context osepic_default_foreground_handler()],
    background: [
        // My other stuff...
        #context osepic_default_background_handler()],
)
// Or even easier...
#show: ose-pic-init
```

Use:

```typst
// Invocation...
#AddToShipoutBG(place(center + horizon, text(20mm, fill: red.transparentize(80%))[BACKGROUND]))
#AddToShipoutFG(place(top + right, dx: -1cm, dy: 1cm, text(10mm, fill: blue.transparentize(50%))[FOREGROUND]))

// And the every-page version...
#AddToShipoutBGAll(place(top + left, box(inset: 15mm, [Every-page BG])))
#AddToShipoutFGAll(place(bottom + right, box(inset: 15mm, [Every-page FG])))
```
