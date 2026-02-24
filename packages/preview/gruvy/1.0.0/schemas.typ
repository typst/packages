#import "@preview/valkyrie:0.2.2" as z
#import "colors.typ": colors

#let available-themes = z.choice(("light", "dark"))
#let available-contrasts = z.choice(("soft", "medium", "hard"))
#let available-accent-colors = z.choice(colors.neutral.keys())
