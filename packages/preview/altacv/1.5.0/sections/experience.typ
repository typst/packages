// JSON Resume's `work[]` and `volunteer[]` render as near-identical
// block lists — position heading, accent-coloured org line, optional
// term row + location, optional preamble paragraph, bulleted
// highlights. They share this file because they share the shape;
// `_experience` carries an extra `summary` / `description` preamble
// that `_volunteer` skips.

#import "../internal/text.typ": _present
#import "../internal/primitives.typ": name, term, _join_with_dividers
#import "../internal/dates.typ": _format_date_range

#let _experience(work, labels, prefs) = if work.len() > 0 [
  == #labels.work

  #_join_with_dividers(work, job => [
    #block(breakable: false)[
      === #job.position
      // `link()` inherits the surrounding bold + accent from `name()`,
      // so the company stays visually identical to the unlinked case
      // and just gains click behaviour. `styled-link` would impose the
      // italic / underline treatment used for publication titles.
      // `_present` (rather than `!= none`) so an empty-string url
      // doesn't render a dead link.
      #let url = job.at("url", default: none)
      #name[#if _present(url) { link(url, job.name) } else { job.name }]
      #term(_format_date_range(job, prefs, labels), location: job.at("location", default: none))

      // `summary` wins over `description` only when present-and-non-
      // empty; an empty-string `summary` falls through to `description`
      // so callers using either field name get the right preamble.
      #let summary = job.at("summary", default: none)
      #let preamble = if _present(summary) { summary } else { job.at("description", default: none) }
      #if _present(preamble) [
        // Softer than `name()` (the bold accent line above) — same
        // treatment as `projects[].description` — so the prose
        // preamble doesn't compete with the role headings or the
        // highlight bullets that follow.
        #emph(preamble)
      ]
      #for bullet in job.at("highlights", default: ()) [- #bullet]
    ]
  ])
]

// JSON Resume `volunteer[]` mirrors `work[]` shape, but uses
// `organization` where work uses `name`. Renderer is otherwise
// identical to `_experience`: position heading, accent-coloured
// organisation line, optional date range + location, bulleted
// highlights.
#let _volunteer(entries, labels, prefs) = if entries.len() > 0 [
  == #labels.volunteer

  #_join_with_dividers(entries, entry => [
    #block(breakable: false)[
      === #entry.position
      #name[#entry.at("organization", default: "")]
      #term(_format_date_range(entry, prefs, labels), location: entry.at("location", default: none))

      #for bullet in entry.at("highlights", default: ()) [- #bullet]
    ]
  ])
]
