/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {
  set page(
    paper: "a4",
    header: [I'm the header],
    numbering: "1 / 1"
  )
  doc
}


/********************/
/* TESTING TEMPLATE */
/********************/

#show: apply

= Testing basic feature

== You know

#lorem(200)

#lorem(100)

== Sometimes

=== You get real bored

#lorem(10) #footnote[I'm a happy footnote.] #lorem(250)

=== Pov le stage

#lorem(500)

== La vie c'est cool

#lorem(150)
