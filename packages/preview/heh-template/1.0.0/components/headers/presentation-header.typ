#import "/utils/utils.typ": get-next-heading, heh-logo
#import "/utils/states.typ": (
  group-current-slide, group-slide-count, group-title-state, heh-config,
)
#import "@preview/polylux:0.4.0": toolbox

// Affiche le logo à gauche et l'année académique et le titre à droite
#let presentation-header(show-titles: true, show-progression: true) = context {
  let next-heading = get-next-heading(level: 2)
  let config = heh-config.get()
  set text(size: 14pt)

  grid(
    columns: (100pt, 1fr, auto),
    heh-logo(width: 200pt),
    {
      if show-titles {
        colbreak()
        align(center + horizon)[
          #set text(size: 16pt)
          #underline(group-title-state.get())
          #linebreak()
          #next-heading
        ]
      }
    },
    context {
      if show-progression {
        colbreak()

        align(right + horizon, {
          // La slide actuelle n'est pas passée
          let max-dots = 13

          let passed-slides = group-current-slide.get().at(0) - 1
          let remaining-slides = (
            group-slide-count.get().at(0) - passed-slides - 1
          )

          let total-slides = passed-slides + remaining-slides + 1

          if total-slides > max-dots {
            if passed-slides > 1 {
              passed-slides = calc.max(
                1,
                passed-slides - (total-slides - max-dots),
              )
            }
            total-slides = passed-slides + remaining-slides + 1
            if total-slides > max-dots {
              remaining-slides = calc.max(
                0,
                remaining-slides - (total-slides - max-dots),
              )
            }
          }

          let slidecircle(fill: none) = box(inset: 3pt, circle(
            radius: 4pt,
            fill: fill,
          ))

          for _ in range(passed-slides) {
            slidecircle(
              fill: config.campus.style.primary-color.transparentize(60%),
            )
          }

          slidecircle(fill: config.campus.style.primary-color)

          for _ in range(remaining-slides) {
            slidecircle()
          }
        })
      }
    },
  )
}

