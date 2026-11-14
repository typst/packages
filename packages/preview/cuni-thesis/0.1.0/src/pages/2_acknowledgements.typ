#import "../helpers.typ": *

//Acknowledgements, thanks to others
#let gratitude(vars) = {
  align(bottom)[
    #for value in vars.Acknowledgements {
     value
     linebreak() 
    }
    ]

  v(20mm)
  pagebreak()
}