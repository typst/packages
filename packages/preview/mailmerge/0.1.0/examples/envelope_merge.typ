// examples/envelope_merge.typ - Envelope Printing Mail Merge Example

#import "../lib.typ": mail-merge, field, fmt-field, join-fields, if-field

#set page(
  width: 220mm,
  height: 110mm,
  margin: (x: 0.5in, y: 0.5in)
)

#mail-merge(
  csv("data/clients.csv", row-type: dictionary),
  record => [
    // Sender Return Address (Top Left)
    #align(top + left)[
      #text(size: 8pt, weight: "bold", fill: rgb("#2d3748"))[ACME GLOBAL SOLUTIONS] \
      #text(size: 7.5pt, fill: rgb("#718096"))[
        100 Innovation Way, Suite 500 \
        New York, NY 10001 \
        USA
      ]
    ]

    #v(0.8in)

    // Recipient Address (Centered / Shifted Right)
    #align(center)[
      #block(
        width: 60%,
        align(left)[
          #text(size: 12pt, weight: "bold")[
            #fmt-field(record, "First Name") #fmt-field(record, "Last Name")
          ] \
          #text(size: 11pt)[
            #if-field(record, "Company", c => [#c \ ])
            #field(record, "Address 1") \
            #if-field(record, "Address 2", a => [#a \ ])
            #join-fields(record, ("City", "State"), separator: ", ") #field(record, "Zip")
          ]
        ]
      )
    ]
  ]
)
