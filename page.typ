/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {
  set page(
    paper: "a4",
    header: [I'm the header],
    numbering: "1 / 1"
  )

  set par(justify: true)

  doc
}


/********************/
/* TESTING TEMPLATE */
/********************/

#show: apply

#set page(numbering: none)

= Testing basic feature

== You know

#lorem(200)

#lorem(100)

== Sometimes

=== You get real bored

#lorem(10) #footnote[I'm a happy footnote.] #lorem(250)

=== Pov le stage

#lorem(100)

#set page(numbering: "1.1")
#counter(page).update(1)

#lorem(400)
== La vie c'est cool

#lorem(150)
