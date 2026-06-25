// mpp.typ — Typst-side helpers for the mpp-rs WASM plugin.
//
// Build the plugin first (see README), then drop mpp_rs.wasm next to this file.

#let _mpp = plugin("mpp_rs.wasm")

// Parse an .mpp file into a dictionary: (format: str, tasks: (..)).
// `read(.., encoding: none)` hands the raw bytes to the plugin; the plugin
// returns JSON bytes, which `json()` decodes directly (Typst 0.13+).
#let parse-mpp(path) = json(_mpp.parse_mpp(read(path, encoding: none)))

// "1984-12-31T00:48:00" -> datetime, for feeding date-based Gantt packages.
#let iso-to-datetime(s) = {
  if s == none { return none }
  let (date, time) = s.split("T")
  let (y, mo, d) = date.split("-").map(int)
  let (h, mi, sec) = time.split(":").map(int)
  datetime(year: y, month: mo, day: d, hour: h, minute: mi, second: sec)
}

// ---------------------------------------------------------------------------
// Example: reconstruct a work-breakdown tree from outline levels and render it
// with fletcher (indented list shown here for brevity; the `level` field is
// what drives a real tree / Gantt grouping).
// ---------------------------------------------------------------------------
#let wbs-outline(project) = {
  for t in project.tasks {
    let indent = (t.outline_level - 1) * 1.2em
    block(inset: (left: indent))[
      #t.id. #t.name
      #if t.start != none [ — #iso-to-datetime(t.start).display("[year]-[month]-[day]") ]
      #if t.percent_complete > 0 [ (#t.percent_complete%) ]
    ]
  }
}

// Usage:
//   #import "mpp.typ": parse-mpp, iso-to-datetime, wbs-outline
//   #let project = parse-mpp("schedule.mpp")
//   #wbs-outline(project)
//
// Or feed gantty:
//   #for t in project.tasks {
//     // gantty task with start: iso-to-datetime(t.start), end: iso-to-datetime(t.finish)
//   }
