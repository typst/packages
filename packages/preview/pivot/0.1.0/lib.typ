// pivot — public API. Exports the deliberate, minimal surface.

#import "src/field/elements.typ": bits, bytes, gap, reserved
#import "src/packet/render.typ": packet
#import "src/struct/render.typ": struct
#import "src/hexdump/render.typ": hexdump

// Named themes. Pass `theme: themes.default + (token: value, ...)` to customise.
#import "src/theme.typ" as themes

// The shared Okabe–Ito colour-blind-safe highlight palette, for `fill:`.
#import "src/palette.typ": palette
