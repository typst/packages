// #import "@preview/outline-summaryst:0.1.0": outline-summaryst, make-heading
#import "/src/outline-summaryst.typ": outline-summaryst, make-heading


#show: outline-summaryst.with(
  title: "Insert Title Here",
  subtitle: "Insert Subitle Here",
  author: "Author Name",
  foreword-name: "Foreword",
  foreword-contents: [
    Insert foreword here....
  ],
)







#make-heading("Part One", "This is the summary for part one")
#lorem(500)

#make-heading("Chapter One", [
  #show raw: set text(font: "Fira Code")
  You can also make subheadings, just set the `level` keyword argument of `make-heading` to some number $n$, where $n >= 1$
], level: 2)
#lorem(300)

#make-heading("Chapter Two", "This is the summary for chapter two in part one", level: 2)
#lorem(300)




#make-heading("Part Two", "And here we have the summary for part two")
#lorem(500)


#make-heading("Chapter One", "There's really no hard limit to how long these summaries can be and to be quite honest I'm rather curious to see how far we can go.

Adolphus W. Green (1844–1917) started as the Principal of the Groton School in 1864. By 1865, he became second assistant librarian at the New York Mercantile Library; from 1867 to 1869, he was promoted to full librarian. From 1869 to 1873, he worked for Evarts, Southmayd & Choate, a law firm co-founded by William M. Evarts, Charles Ferdinand Southmayd and Joseph Hodges Choate. He was admitted to the New York State Bar Association in 1873.

Anyway, how's your day been?", level: 2)
#lorem(300)

#make-heading("Chapter Two", "And here we have the summary for part two chapter two", level: 2)
#lorem(300)





