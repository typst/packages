#import "style/boxes.typ": *
#import "style/layouts.typ": *
#import "style/themes.typ": *

// theme
// use default theme
#set-theme(steel-blue)

// You can also set your own theme by updating the theme variables in the style files.
// For example,
// #update-theme(
//  heading-color: rgb(100, 200, 255),
//  fill-color: rgb(100, 200, 255),
//  stroke-color: rgb(100, 200, 255),
//)

// layout
#set page("a0", margin: 0cm)
#set-poster-layout(layout-a0)

// spacing between boxes
#set columns(gutter: 2.0em)

// math font
#show math.equation: set text(font: "New Computer Modern Math")


/// Title
#title-box(
  "Research Poster Template",
  authors: "Author Name¹, Co-Author²",
  institutes: "¹First Affiliation, ²Second Affiliation",
)
#v(-1.0cm)



/// Main content
#box(inset: 2.0cm)[
#columns(2, [

#column-box(heading: "Introduction")[
  This template demonstrates a two-column research poster layout with:
  - Summary of objectives and background
  - Model definition using mathematical equations
  - Bulleted methods and results
]

#v(5.0em)

#column-box(heading: "Method")[
  We assume a linear model for input vectors $x in RR^d$:
  
  $ 
    f(x; W, b) = W x + b, quad W in RR^(k times d), b in RR^k. 
  $
  
  The loss function is squared error with $ell_2$ regularization:
  $ cal(L)(W,b) = 1/n sum_(i=1)^n norm(y_i - f(x_i; W,b))_2^2 + lambda norm(W)_F^2. $
  
  Optimization updates using gradient descent with learning rate $eta$:
  $ 
    W <- W - eta nabla_W cal(L), quad 
    b <- b - eta nabla_b cal(L). 
  $
]

#colbreak()

#column-box(heading: "Experiments")[
  Dataset: Synthetic data ($n = 10^4$, $d = 32$).
  Training conditions:
  - Learning rate: $eta = 10^(-2)$
  - Regularization: $lambda = 10^(-3)$
  - Epochs: 50
  
  Results summary:
  - Epochs to convergence: 18
  - MSE: $1.23 times 10^(-2)$
]

#v(5.0em)

#column-box(heading: "Conclusion")[
  - Stable learning achieved with linear model and simple regularization
  - Future improvements: nonlinear features and dropout
  - Data augmentation and outlier robustness remain open challenges
]

#v(5.0em)

#column-box(heading: "References")[
  [1] Goodfellow et al., Deep Learning, MIT Press, 2016. \
  [2] Hastie et al., Elements of Statistical Learning, Springer, 2009.
]



])
]


#bottom-box()[
  Here is the bottom box. Write anything you want to write here.
]


