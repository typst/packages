//
// This file is where you should include the files
// belonging to your appendix. In other words, the chapters
// after your conclusion and bibliography go here.
//
// The main matter has its own index file in
// mainmatter/index.typ. Include the main contents of your
// thesis there.
//

#let appendixFiles = (
  "A.typ",
  "B.typ",
  "C.typ",
)

#for file in appendixFiles {
  include file
}
