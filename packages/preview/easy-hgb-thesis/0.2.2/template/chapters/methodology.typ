// Demonstration chapter, will be completely replaced with your own chapter composition

= Methodology

#lorem(30)

Reference a:

- Chapter: @introduction_heading
- Section: @nested_subheading
- Equation: @bayes_theorem

// Let's show a small table
#{
  show: figure.with(
    caption: [Demonstrate the List of tables and its numbering @demo-cite],
  )
  table(
    columns: 2,
    table.header[Header 1][Header 2],
    [Data 1], [Data 2],
    [Data 3], [Data 4],
  )
}

$
  P(A | B) = (P(A) P(B | A)) / P(B)
$ <bayes_theorem>

#lorem(10)
