// pivot — public API. Exports the deliberate, minimal surface.

#import "src/field/elements.typ": bits, bytes, gap, reserved
#import "src/packet/render.typ": packet
#import "src/struct/render.typ": struct
#import "src/hexdump/render.typ": hexdump
#import "src/timeline/render.typ": timeline
#import "src/timeline/elements.typ": event
#import "src/flowchart/render.typ": flowchart
#import "src/flowchart/elements.typ": node, edge

// Named themes. Pass `theme: themes.default + (token: value, ...)` to customise.
#import "src/theme.typ" as themes

// The shared Okabe–Ito colour-blind-safe highlight palette, for `fill:`.
#import "src/palette.typ": palette
