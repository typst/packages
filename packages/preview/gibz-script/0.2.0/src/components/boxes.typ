#import "../colors.typ": gibz-blue
#import "../state.typ": gibz-lang
#import "../i18n.typ": t
#import "../fonts.typ": heading-font
#import "./base_box.typ": base-box

// Shared "simple box" layout for hint/question/warning/video/supplementary:
// a big icon in its own column, an optional small colored eyebrow label, an
// optional bold title, then the body content. Only icon/colors/eyebrow text
// are specific to each box; everything else (spacing, sizes, base-box
// styling) is shared here.
//
// The icon column is taller than a single line of body text (icon size +
// padding), so with no eyebrow/title both columns are vertically centered
// against each other — otherwise a short one-liner would look lopsided,
// hugging the top with a dead gap below. With an eyebrow/title, the header
// grows downward, so both columns are top-aligned instead so the icon lines
// up with the first line rather than centering against the whole block.
#let gibz-box(icon, content, eyebrow: none, eyebrow-color: gibz-blue, title: none, style: (:)) = {
  set text(size: 10pt)
  let has-header = eyebrow != none or title != none
  let row-align = if has-header { top } else { horizon }
  base-box(
    [
      #grid(
        columns: (50pt, 1fr),
        align: (center + row-align, left + row-align),
        [
          #set text(size: 20pt)
          #pad(top: 3pt, right: 15pt, bottom: 5pt, icon)
        ],
        [
          #if eyebrow != none {
            block(below: 10pt, text(font: heading-font, size: 0.75em, weight: 600, fill: eyebrow-color)[#eyebrow])
          }
          #if title != none {
            block(below: 8pt, text(font: heading-font, size: 1.05em, weight: 700)[#title])
          }
          #content
        ],
      )
    ],
    style: style,
  )
}

#let hint(hint, title: none) = gibz-box(emoji.lightbulb, hint, title: title)

#let question(question, task: none, title: none) = gibz-box(
  emoji.quest,
  {
    question
    if task != none {
      linebreak()
      [#task]
    }
  },
  title: title,
)

#let warning(body, title: none) = gibz-box(
  emoji.warning,
  body,
  title: title,
  style: (fill: rgb("#fff4e5"), stroke: (paint: rgb("#c97a12"), thickness: 1pt)),
)

#let video(url, title, description: none) = {
  show link: set text(font: "DejaVu Sans Mono", size: 7pt)
  gibz-box(
    emoji.clapperboard,
    [
      #if description != none { [#description #linebreak()] }
      #link(url)
    ],
    title: title,
  )
}

#let supplementary(body, title: none, lang: none) = context {
  let L = if lang != none { lang } else { gibz-lang.get() }
  gibz-box(
    [📖],
    body,
    eyebrow: t("supplementary-material", lang: L),
    title: title,
  )
}
