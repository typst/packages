#let choices(names, box_size: 0.5in, gap: 0.125in, text_size: 20pt, margin_top: 0.25cm) = {
  v(margin_top)

  for c in names {
    stack(
      dir: ltr,
      box(
        stroke: luma(0),
        width: box_size,
        height: box_size,
      ),
      h(gap),
      text( size: text_size, baseline: gap )[ #c ]
    )
  }
}

#let ballot_template(doc) = {
  set text(16pt)
  set par(
    spacing: 20pt,
  )
  title(context {
    if document.title != none {
      document.title
    } else [
      RCV Ballot
    ]
  })
  
  [
    Rank choices in ascending order from most preferred (1) to least preferred. 

    Rank all choices where you would be satisfied with the outcome.

    
    === Example

    #set text(13pt)


    Johnny and his friends are voting on lunch options. Johnny would be satisfied with either hot dogs or burgers, but prefers hot dogs. 

    Johnny ranks hot dogs number 1 and burgers number 2, but leaves pancakes blank because he would not be happy with them.

    #image("media/example.png", width: 2in, height: 2in)


    #v(0.5cm)
  ]
  
  doc
}