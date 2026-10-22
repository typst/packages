#import "@preview/simple-cornell-notes:0.1.0": cornell-page

#set document(title: "Cornell notes", author: "Philipp Knoch")

// See README.md for all options.
#let sheet = cornell-page.with(
  paper: "a4",
  theme: "sage", // "sage", "blue", or "mono" for printing.
  margin: 8mm,
  cue-width: 28%,
  summary-height: 30mm,
  padding: 2mm,
  font-size: 11pt,
  ruling: "lined", // "lined", "dotted", "grid", or "none".
  line-spacing: 7mm,
  show-header: false, // Set true to show topic, source, and date above the notes.
  show-page-numbers: false,
)

// For typed notes, use ruling: "none" above and write inside the [square brackets].
#sheet(
  title: none,
  course: none,
  date: none,
  cues: [
    // Cues...
  ],
  notes: [
    // Your Notes...
  ],
  summary: [
    // Summary...
  ],
)

// Need another sheet? Copy the #sheet(...) call above, or uncomment this:
// #sheet(title: [Continued])
