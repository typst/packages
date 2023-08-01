//Function to insert TODO
#let todo(body, inline: false, big_text: 40pt, small_text: 15pt, gap: 2mm) = {
  if inline {
    set text(fill: red, size: small_text, weight: "bold")
    box([TODO: #body 
    #place()[    
      #set text(size: 0pt)
      #figure(kind: "todo", supplement: "", caption: body, [])
    ]])
  }
  else {
    set text(size: 0pt) //to hide default figure text, figures is only used for outline as only headings and figures can used for outlining at this point
    figure(kind: "todo", supplement: "", outlined: true, caption: body)[
      #block()[
        #set text(fill: red, size: big_text, weight: "bold")
        ! TODO !
      ]
      #v(gap)
      #block[
        #set text(fill: red, size: small_text, weight: "bold")
        #body
      ]
      #v(gap)
    ]
  }
}

//Function to insert TODOs outline
#let todo_outline = outline(
    title: [TODOs],
    target: figure.where(kind: "todo")
)