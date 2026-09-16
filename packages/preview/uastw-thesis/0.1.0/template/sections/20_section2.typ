#import "@preview/in-dexter:0.7.2": *

#let lightgray = rgb("#EEEEEE")
#let gold = rgb("#ffd700")

= This is the heading of the second chapter

Cross-references should be generated automatically in order to make updating easy. This example shows a cross-reference to @fig1. 

#figure(
    //image("images/fig1.png", width: 60%),
    rect(
      fill: black, 
      width: 250pt, 
      height: 30pt,
      radius: 2pt,
      align(horizon, 
        grid(
          columns: (1fr, 1fr),
          align: (left, right),
          text(size: 16pt, fill: gold, weight: "bold")[Einstein Albert],
          text(size: 16pt, fill: gold, weight: "bold")[2008],
        )
      )
    ),
    caption: [Example of name and year printed on spine (Source).],
) <fig1> 

Below there is a cross-reference to @tab1. The table format shown here serves as an example only. Tables may be formatted individually. 


#figure(
  table(
		columns: (1fr, 1fr, 1fr),
		align: left, 
		fill: (x, y) => if y == 0 { lightgray },
		table.header([*Date*], [*Subject*],[*Room*],),
		[20.08.2008], [Graph Theory], [HS 3.13],
		[01.10.2008], [Biomathematics], [HS 1.05]
    ),
  caption: [Schedule for "Applied Mathematics" (Source).],
)<tab1>



This is a cross-reference to @eq1:


$ x = -p / 2 plus.minus sqrt((p / 2) ^ 2 - q) $	 <eq1>


Bibliography references should be automated especially when there is a long list of books. This is a sample reference to sources @Schiller1801 and @goethe1999faust1. The style of citation and the Bibliography format used here is one of several possible ways, depending on the discipline and the functionality of the word processor.

