#import "../src/outline-summaryst.typ": style-outline, make-heading
// or import "@preview/outline-summaryst:0.1.0": style-outline, make-heading


#show outline: style-outline.with(outline-title: "Table of Contents")

#outline()


#make-heading("Part One", "This is the summary for part one")
#lorem(500)

#make-heading("Chapter One", "Summary for chapter one in part one", level: 2)
#lorem(300)

#make-heading("Chapter Two", "This is the summary for chapter two in part one", level: 2)
#lorem(300)

#make-heading("Part Two", "And here we have the summary for part two")
#lorem(500)

#make-heading("Chapter One", "Summary for chapter one in part two", level: 2)
#lorem(300)

#make-heading("Chapter Two", "Summary for chapter two in part two", level: 2)
#lorem(300)