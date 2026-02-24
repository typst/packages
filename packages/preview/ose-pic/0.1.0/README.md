This package provides per-page foreground and background management.


Examples:

```typst
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

// Invocation
#add_to_shipout_bg(place(center + horizon, text(20mm, fill: red.transparentize(80%))[BACKGROUND]))
#add_to_shipout_fg(place(top + right, dx: -1cm, dy: 1cm, text(10mm, fill: blue.transparentize(50%))[FOREGROUND]))
```
