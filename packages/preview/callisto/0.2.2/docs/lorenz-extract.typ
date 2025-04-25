#import "/src/callisto.typ" as callisto: *

#set page(height: auto, margin: (x: 2cm, top: 1cm, bottom: 0pt))

#callisto.render(
  range(5),
  nb: "/tests/notebooks/Lorenz.ipynb",
  output-type: "display_data",
)
 
