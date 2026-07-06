#import "@preview/clean-ut:0.1.0":*

= Materials and Methods

== Materials

#figure(
  table(
    columns: 2,
    table.header([Chemicals], [Provider], repeat: true),
    // inhalt
    [Oranges], [Tree],
    // [],[],
  ),
  caption: [List of Chemicals],
)

#figure(
  table(
    columns: 2,
    align: horizon,
    table.header([Solution], [Composition]),
    //inhalt
    [Orange juice], [100% Oranges],
  ),
  caption: [List of Solutions],
)

#figure(
  table(
    columns: 2,
    table.header([Enzyme], [Provider]),
    [Lysozyme], [Saliva],
  ),
  caption: [List of Enzymes],
)

#figure(
  table(
    columns: 2,
    table.header([Primer], [Sequence]),
    [seq-fwd], [#upper("ctgtttctccatacccgtt")],
  ),
  caption: [List of Primers, 5'\-3' orientation],
)

#figure(
  table(
    columns: 2,
    table.header([Software], [Provider]),
    //inhalt
    [Excel], [Microsoft],
  ),
  caption: [List of Softwares],
)

#[
  #show figure.where(kind: table): set block(breakable: true)
  #todo("this #[] block and the show rule above in the code makes this table be able to span multiple pages. Do this for every table you want to span multiple pages")


  #figure(
    table(
      columns: 2,
      table.header([Instrument], [Provider]),
      //inhalt
      [Paper&Pen], [Also trees],
    ),
    caption: [List of Instruments],
  )
]


== Methods
#set heading(outlined: false)

//describe each method

#heading([Rickrolling people], level: 3, numbering: none)
#link("https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1", [Totally unsuspicious link])

#pagebreak()