//Function to insert TODO
#let todo(body, big_text: 40pt, small_text: 15pt, gap: 2mm) = {
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
    ]
}

//Function to insert TODOs outline
#let todo_outline = outline(
    title: [TODOs],
    target: figure.where(kind: "todo")
)