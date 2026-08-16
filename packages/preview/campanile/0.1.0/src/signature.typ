#let signature(
  title: "thesis-title",
  author: "thesis-author",
  committee-members: (
    (name: "thesis-chair", role: "thesis-chair-role"),
    (name: "thesis-member-1", role: "thesis-member-1-role")
  )
) = [
  #set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
    numbering: none,
    header: none,
  )
  #set text(size: 11pt)
  #set par(justify: true, first-line-indent: 0em)

  #v(0.6cm)
  #line(length: 100%, stroke: 0.5pt)
  #v(0.4cm)

  #align(center)[
    *#title*

    #v(0.15cm)
    by #author
  ]

  #v(0.2cm)
  #line(length: 100%, stroke: 0.5pt)

  #align(center)[
    #v(0.2cm)
    *Research Project*
  ]

  #v(0.2cm)
  Submitted to the Department of Electrical Engineering and Computer Sciences, University of California at Berkeley, in partial satisfaction of the requirements for the degree of *Master of Science, Plan II*.

  #v(0.3cm)
  Approval for the Report and Comprehensive Examination:

  #v(0.4cm)
  #align(center)[
    *Committee:*

    #assert.eq(
      committee-members.len(), 
      2, 
      message: "masters thesis committee should have 2 members"
    )

    #let committee-0 = committee-members.at(0)
    #let committee-1 = committee-members.at(1)

    #v(1cm)
    #line(length: 55%, stroke: 0.5pt)
    #v(-0.25cm)
    #committee-0.at("name") \
    #committee-0.at("role")

    #v(0.6cm)
    #line(length: 55%, stroke: 0.5pt)
    #v(-0.25cm)
    (Date)

    #v(0.5cm)
    \* \* \* \* \* \* \*
    #v(1cm)
    
    #line(length: 55%, stroke: 0.5pt)
    #v(-0.25cm)
    #committee-1.at("name") \
    #committee-1.at("role")

    #v(0.6cm)
    #line(length: 55%, stroke: 0.5pt)
    #v(-0.25cm)
    (Date)
  ]

  #pagebreak()
]