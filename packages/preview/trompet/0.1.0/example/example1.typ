#import "@preview/trompet:0.1.0": *
#import "@preview/lambdabus:0.1.0": normalization-steps
#set page(height: 10in)

// create an expression representing the factorial of 2.
// This large syntax is only necessary when styling each piece individually
#let my-expression = expression(application(style: teal,
  abstraction("n",
    abstraction("f", style: green,
      application(style: teal,
        application(style: teal,
          application(style: teal,
            value("n", style: teal),
            abstraction("a", style: teal,
              abstraction("b", style: teal,
                application(style: teal,
                  value("b", style: teal),
                  application(style: teal,
                    value("a", style: teal),
                    abstraction("c", style: teal,
                      abstraction("x", style: purple,
                        application(style: blue,
                          application(style: teal,
                            value("b", style: teal),
                            value("c", style: teal),
                          ),
                          application(style: yellow,
                            value("c", style: teal),
                            value("x", style: red)
                          )
                        ),
                      )
                    ),
                  ),
                ),
              )
            ),
          ),
          abstraction("x", value("f", style: orange), style: teal)
        ),
        abstraction("x", value("x", style: teal), style: teal),
      ),
    ), style: blue), "\\f.\\x.f (f x)"))

// Use lambdabus to find the intermediate steps of the calculation, and display each of them as a tromp diagram
#columns(2)[
  #normalization-steps(my-expression).map(e => tromp(e, scale: 0.40)).join()
]
