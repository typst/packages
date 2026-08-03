// examples/advanced_features.typ - Advanced Sorting, Filtering, Stats & Custom Data Example

#import "../lib.typ": (
  mail-merge,
  mail-merge-stats,
  mail-merge-preview,
  field,
  fmt-field,
  join-fields,
  if-field,
  is-empty,
  is-non-empty,
  record-index,
  record-total,
  is-first-record,
  is-last-record
)

#set page(paper: "us-letter", margin: 1in)

= Typst Mail Merge - Advanced Features Demonstration

// 1. Inspecting Dataset Statistics
#let stats = mail-merge-stats(csv("data/clients.csv", row-type: dictionary))

#block(
  fill: rgb("#ebf8ff"),
  stroke: 1pt + rgb("#3182ce"),
  inset: 10pt,
  radius: 4pt,
  [
    == Dataset Overview
    - *Total Records in CSV:* #stats.total-records
    - *Detected Field Headers:* #stats.fields.join(", ")
    - *Sample Record:* `#stats.sample-record`
  ]
)

#v(1.5em)

== 1. Filtered & Sorted Mail Merge (Active Clients, Sorted by City)

#mail-merge(
  csv("data/clients.csv", row-type: dictionary),
  filter: r => field(r, "Status") == "Active",
  sort-by: "City",
  pagebreak: false,
  r => [
    #box(
      width: 100%,
      fill: rgb("#f7fafc"),
      stroke: 0.5pt + rgb("#cbd5e0"),
      inset: 8pt,
      radius: 3pt,
      [
        *Record [#record-index(r) / #record-total(r)]:* #field(r, "First Name") #field(r, "Last Name") \
        *Location:* #join-fields(r, ("City", "State"), separator: ", ") \
        *Status:* #fmt-field(r, "Status", fmt: "upper") \
        *First/Last Flags:* First: #is-first-record(r), Last: #is-last-record(r)
      ]
    )
    #v(0.5em)
  ]
)

#v(1.5em)

== 2. Mail Merge with Inline Array Data (No CSV file required)

#let custom-data = (
  ("Name", "Role", "Points"),
  ("Alice Vance", "Team Lead", "1250"),
  ("Bob Ross", "Designer", "980"),
  ("Charlie Brown", "Developer", "1100")
)

#mail-merge(
  custom-data,
  sort-by: r => float(field(r, "Points")),
  reverse: true,
  pagebreak: false,
  r => [
    - *#field(r, "Name")* (#field(r, "Role")) — *#field(r, "Points") pts*
  ]
)

#v(1.5em)

== 3. Fast Draft Preview (Limited to 2 items)

#mail-merge-preview(
  csv("data/students.csv", row-type: dictionary),
  limit: 2,
  pagebreak: false,
  r => [
    - Preview Student: *#field(r, "First Name") #field(r, "Last Name")* (#field(r, "Course"))
  ]
)
