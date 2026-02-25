// Skill level visualization components
// Provides level bars and item-with-level display

#import "theme.typ": __st-theme, LEVEL_BAR_GAP_SIZE, LEVEL_BAR_BOX_HEIGHT, __stroke_length

// === Level Bar ===
// Horizontal bar showing proficiency level (e.g., 4/5)
#let level-bar(
  level,
  max-level: 5,
  width: 3.5cm,
  accent-color: none,
) = {
  context {
    let accent-color-value = if accent-color == none {
      __st-theme.final().accent-color
    } else {
      accent-color
    }
    let col-width = (width - LEVEL_BAR_GAP_SIZE * (max-level - 1)) / max-level
    let levels = range(max-level).map(l => box(
      height: LEVEL_BAR_BOX_HEIGHT,
      width: 100%,
      stroke: accent-color-value + __stroke_length(0.75),
      rect(
        width: 100%
          * if (level - l < 0) { 0 } else if (level - l > 1) { 1 } else {
            level - l
          },
        height: 100%,
        fill: accent-color-value,
      ),
    ))
    grid(
      columns: (col-width,) * max-level,
      gutter: LEVEL_BAR_GAP_SIZE,
      ..levels
    )
  }
}

// === Item with Level ===
// Displays a skill/language item with proficiency bar
#let item-with-level(
  title,
  level,
  subtitle: "",
) = (
  context {
    let theme = __st-theme.final()

    block[
      #text(title)
      #h(1fr)
      #text(fill: theme.font-color.lighten(40%), subtitle)
      #level-bar(level, width: 100%)
    ]
  }
)
