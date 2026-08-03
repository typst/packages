// examples/certificate_merge.typ - Certificate & Diploma Mail Merge Example

#import "../lib.typ": mail-merge, field, fmt-field

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 1.2in, y: 1in)
)

#mail-merge(
  csv("data/students.csv", row-type: dictionary),
  sort-by: "Score",
  reverse: true,
  record => [
    // Outer Decorative Border Frame
    #rect(
      width: 100%,
      height: 100%,
      stroke: 3pt + rgb("#b7791f"),
      inset: 12pt,
      [
        #rect(
          width: 100%,
          height: 100%,
          stroke: 1pt + rgb("#d69e2e"),
          inset: 20pt,
          fill: rgb("#fffaf0"),
          [
            #align(center)[
              #v(1em)
              #text(size: 14pt, tracking: 0.2em, weight: "bold", fill: rgb("#744210"))[ACADEMY OF EXCELLENCE] \
              #v(0.5em)
              #text(size: 26pt, weight: "bold", fill: rgb("#2b6cb0"))[CERTIFICATE OF COMPLETION]

              #v(1em)
              #text(size: 12pt, style: "italic")[This is to certify that]

              #v(0.5em)
              #text(size: 24pt, weight: "bold", fill: rgb("#1a202c"))[
                #fmt-field(record, "First Name") #fmt-field(record, "Last Name")
              ]

              #v(0.5em)
              #text(size: 12pt)[has successfully completed the professional course]

              #v(0.5em)
              #text(size: 18pt, weight: "bold", fill: rgb("#2c5282"))[
                #field(record, "Course")
              ]

              #v(0.5em)
              #text(size: 11pt)[
                with a final score of *#field(record, "Score")%* (Grade *#field(record, "Grade")*) and is awarded \
                #rect(
                  fill: rgb("#ebf8ff"),
                  stroke: 1pt + rgb("#3182ce"),
                  radius: 3pt,
                  inset: (x: 10pt, y: 4pt),
                  text(weight: "bold", fill: rgb("#2b6cb0"))[#field(record, "Award")]
                )
              ]

              #v(2em)

              #grid(
                columns: (1fr, 1fr),
                [
                  #line(length: 140pt, stroke: 1pt + rgb("#a0aec0"))
                  #text(size: 10pt, weight: "bold")[#field(record, "Instructor")] \
                  #text(size: 8pt, fill: luma(120))[Course Instructor]
                ],
                [
                  #line(length: 140pt, stroke: 1pt + rgb("#a0aec0"))
                  #text(size: 10pt, weight: "bold")[#fmt-field(record, "Date")] \
                  #text(size: 8pt, fill: luma(120))[Date of Issuance]
                ]
              )
            ]
          ]
        )
      ]
    )
  ]
)
