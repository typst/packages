#import "@local/ratsch-bmim:0.2.0" as bmim: poster-box

#show: bmim.poster(
  title:[],
  authors:(
    [John Doe & Jane Doe],
    [Max Mustermann]
  ),
  contact: [`iace.office@umit-tirol.at`],
  event: [Wichtiges Event],
  location: [UMIT TIROL, Hall in Tirol],
)

#poster-box[A Box][
  #lorem(30)
]

#poster-box(height:1fr)[Another Box][
  Do try @tab:try.
  #figure(
    table(
      columns: 4,
      ..(context{counter("a").step(); str(counter("a").get().first())},)*8,
    ),
    caption: [Try me! #lorem(20)],
  ) <tab:try>
]
#colbreak()

#poster-box[Oh, a box][
  #lorem(30)
]
