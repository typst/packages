//
// This file is where you should include the files
// belonging to your main matter, or the actual main
// contents of the thesis that come after the front matter.
// In other words, chapters from introduction to conclusion
// go here.
//
// Appendices have their own index file appendices/index.typ.
// Include appendix-specific chapters there.
//

#let mainMatterFiles = (
  "01.typ",
  "02.typ",
  "03.typ",
  "04.typ",
)

#for file in mainMatterFiles {
  include file
}
