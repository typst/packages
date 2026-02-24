#import "/src/callisto.typ"

// Render whole notebook
#callisto.render(nb: json("notebooks/julia.ipynb"))

// Render all code cells named/tagged with "plot", showing only the cell output
#callisto.render("plot", nb: json("notebooks/julia.ipynb"), cell-type: "code", input: false)

// Let's get functions preconfigured to use this notebook
#let (render, result, source, Cell, In, Out) = callisto.config(
   nb: json("notebooks/julia.ipynb"),
)

// Render only the first 3 cells
#render(range(3))

// Get the result of cell with label "plot2"
#result("plot2")

// Force using the PNG version of this output
#result("plot2", format: "image/png")

// Change the width of an image read from the notebook
#{
   set image(width: 100%)
   result("plot2")
}

// Another way to do the same thing
#image(result("plot2").source, width: 100%)

// Get the source of that cell as a raw block, then get the text of it
#source("plot2").text

// Render the cell with execution number 4 (count can also be set by config())
#Cell(4, count: "execution")

// Render separately the input and output of cell named/tagged "abc"
#In("abc")
#Out("abc")

