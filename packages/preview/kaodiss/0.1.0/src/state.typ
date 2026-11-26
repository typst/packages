// Counters, markers and helpers shared by all modules.
// Layout decisions never depend on `state`: everything that differs between
// front, main and back matter is passed down through show rules, so that the
// document converges in few layout iterations.


#let part-counter = counter("kao-part")
#let sidenote-counter = counter("kao-sidenote")


// Markers used to find chapter starts and empty pages.
// <kao-break>: last piece of content before a chapter/part page break.
// <kao-start>: first piece of content of a chapter or part page.
// <kao-matter>: switch between front, main and back matter.
#let break-marker() = [#metadata("break")<kao-break>]
#let start-marker(kind) = [#metadata(kind)<kao-start>]
#let matter-marker(value) = [#metadata(value)<kao-matter>]

// Continue on the next odd (right-hand) page, like LaTeX's \cleardoublepage.
// Pages skipped this way stay completely empty.
#let clear-double-page() = {
  break-marker()
  pagebreak(weak: true, to: "odd")
}

// Displays the page number of a location in the numbering style that was
// active there (roman in the front matter, arabic afterwards).
#let page-label(loc) = {
  let style = loc.page-numbering()
  if style == none { style = "1" }
  numbering(style, ..counter(page).at(loc))
}

// Kinds of figures that get kaobook captions and per-chapter numbering.
#let float-kinds = (image, table, raw, "algorithm")
// Kinds of theorem-like environments numbered within sections.
#let section-kinds = ("kao-def", "kao-thm", "kao-ex")

// True if a heading is a part heading (created with `#part`).
#let is-part(h) = h.at("label", default: none) == <kao-part>
