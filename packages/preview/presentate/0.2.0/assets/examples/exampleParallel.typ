#import "@submit/presentate:0.2.0": *

#set page(paper: "presentation-16-9")
#set text(size: 25pt)

#slide[
  = Content in Sync
  #table(columns: (1fr, 1fr), stroke: 1pt)[
    First

    #show: pause;
    I am

    #show: pause;

    in sync.
  ][
    // `[]` is a dummy content.
    #uncover(1, [], update-pause: true)
    Second

    #show: pause;
    I am

    #show: pause;

    in sync.
    
    #show: pause 
    Heheh
  ]
]
