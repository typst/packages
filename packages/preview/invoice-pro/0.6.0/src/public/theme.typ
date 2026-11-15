// `theme`: the public facade (namespace == parameter name, like `locale`).
#import "../theming/presets.typ": (
  bold, boxed, classic, compact, corporate, elegant, plain, prestige, soft,
  technical,
)
#import "layout.typ" as layout
#import "custom.typ" as custom
#import "../theming/build.typ": resolve
#import "../theming/color.typ": contrast, legible, on-color
/// Default renderers (a module), for "eject" or explicit calls: `theme.parts.totals(ctx, view)`.
#import "../theming/parts/defaults.typ" as parts
