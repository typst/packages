// examples/letter_merge.typ - Personalized Letter & Invoice Mail Merge Example

#import "../lib.typ": mail-merge, field, fmt-field, join-fields, if-field

#set page(
  paper: "us-letter",
  margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
  header: align(right)[
    #text(size: 8pt, fill: luma(120))[CONFIDENTIAL & PERSONAL]
  ],
  footer: align(center)[
    #text(size: 9pt, fill: luma(120))[Acme Global Solutions • 100 Innovation Way, Suite 500, New York, NY]
  ]
)
#set par(justify: true, leading: 0.65em)

#mail-merge(
  csv("data/clients.csv", row-type: dictionary),
  filter: record => field(record, "Status") == "Active",
  sort-by: "Last Name",
  reset-page-counter: true,
  record => [
    // Header Logo & Sender Info
    #grid(
      columns: (1fr, 1fr),
      [
        #text(size: 16pt, weight: "bold", fill: rgb("#1a365d"))[ACME GLOBAL] \
        #text(size: 9pt, fill: luma(100))[Enterprise Solutions & Technology]
      ],
      align(right)[
        *Date:* #datetime.today().display("[Month repr:long] [Day], [Year]") \
        *Account ID:* #field(record, "First Name").slice(0, 1)#field(record, "Last Name")-2026
      ]
    )

    #v(1.5em)
    #line(length: 100%, stroke: 1pt + rgb("#1a365d"))
    #v(1.5em)

    // Recipient Address Block (using join-fields to cleanly skip blank Address 2 lines)
    #block(
      fill: rgb("#f7fafc"),
      inset: 12pt,
      radius: 4pt,
      stroke: 0.5pt + rgb("#e2e8f0"),
      [
        *#fmt-field(record, "First Name") #fmt-field(record, "Last Name")* \
        #if-field(record, "Company", c => [#c \ ])
        #field(record, "Address 1") \
        #if-field(record, "Address 2", a => [#a \ ])
        #join-fields(record, ("City", "State"), separator: ", ") #field(record, "Zip")
      ]
    )

    #v(2em)

    // Letter Body
    Dear #field(record, "First Name"),

    Thank you for being a valued partner with Acme Global Solutions since #fmt-field(record, "Join Date"). We are writing to provide you with your latest account statement and summary.

    #let balance = float(field(record, "Balance", default: "0"))
    #if balance > 0 [
      Our records indicate an outstanding account balance of *#fmt-field(record, "Balance", fmt: "currency")*. Please review the attached invoice summary and arrange for settlement at your earliest convenience.
    ] else [
      We are pleased to confirm that your account balance is fully settled (*\$0.00*). No payment action is required at this time.
    ]

    Should you have any questions regarding your account or our services, please feel free to reach out to your account representative at `#field(record, "Email")`.

    #v(2.5em)

    Sincerely,

    #v(2em)
    *Operations & Finance Team* \
    Acme Global Solutions
  ]
)
