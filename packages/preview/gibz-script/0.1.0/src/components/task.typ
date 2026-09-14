#import "../colors.typ": gibz-blue
#import "../state.typ": gibz-lang
#import "../i18n.typ": t
#import "./base_box.typ": base-box

#let task-theme = (
  accent: gibz-blue,
  bg: luma(98%),
  border: 1pt, // keep for future use if you want thicker borders
  radius: 8pt,
  pad: 12pt,
  gap: 8pt,
  label-color: luma(35%),
)

#let _task_badge(label, theme: task-theme) = box(
  inset: (x: 7pt, y: 3pt),
  radius: 999pt,
  stroke: 0.6pt + theme.accent,
  fill: theme.bg,
  [
    #set text(size: 0.70em, baseline: -1pt)
    #label
  ],
)

#let _task_field(name, body, theme: task-theme) = [
  #set text(size: 0.95em)
  #block(above: 2pt, below: 2pt, [
    #if name != none {
      text(fill: theme.label-color, weight: 600, size: 0.75em)[#name]
      linebreak()
    }
    #body
  ])
]

// Public component
#let task(
  title,
  minutes: none, // Number or text (e.g. "2×20")
  social: none, // 1: individual; 2: partner; or text label
  recording: none,
  evaluation: none,
  body,
  opts: (:), // e.g. (accent: rgb("#16a34a"))
  lang: none, // overrides document language ("de" | "en")
) = {
  let theme = task-theme + opts

  context {
    let L = if lang != none { lang } else { gibz-lang.get() }

    let time-value = if type(minutes) in (int, float) {
      str(minutes) + " " + t("minutes", lang: L)
    } else { minutes }

    let social-badge = if social == 1 { "👤" } else { "👥" }
    let social-label = if social == 1 { t("individual-work", lang: L) } else if social == 2 {
      t("partner-work", lang: L)
    } else { social }

    let badges = [
      #if minutes != none {
        _task_badge([🕒 #time-value], theme: theme)
        h(6pt)
      }
      #if social != none {
        _task_badge([#social-badge #social-label], theme: theme)
      }
    ]

    // Outer visual container via base_box
    base-box(
      [
        // Header
        #block(below: 6pt, [
          #text(size: 0.75em, weight: 600, fill: theme.accent)[✏️ #t("exercise", lang: L)]
        ])
        #v(6pt)

        // Title
        #block(below: 6pt, [ #text(size: 1.15em, weight: 700)[#title] ])

        // Badges
        #if minutes != none or social != none { badges }

        // Spacing
        #v(10pt)

        // Task body
        #_task_field(none, body, theme: theme)

        // Results recording
        #if recording != none {
          pad(y: 10pt, line(stroke: 0.6pt + theme.accent, length: 100%))
          _task_field(t("results-recording", lang: L), recording, theme: theme)
          v(4pt)
        }

        // Evaluation
        #if evaluation != none {
          pad(y: 10pt, line(stroke: 0.6pt + theme.accent, length: 100%))
          _task_field(t("evaluation", lang: L), evaluation, theme: theme)
          v(theme.gap)
        }
      ],
      style: (
        fill: theme.bg.transparentize(50%),
        stroke: (paint: theme.accent, thickness: 1pt), // keeps your colored border
        radius: theme.radius,
        inset: theme.pad,
      ),
    )
  }
}
