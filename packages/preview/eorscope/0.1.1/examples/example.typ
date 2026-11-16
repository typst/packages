// typst compile --root . examples/example.typ
#import "../lib.typ": employer-cost, employer-rate-text, employer-cost-table, employer-rates-table, format-amount

#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt)

= Hiring in Germany and India

#let de = employer-cost("DE", 60000)
A gross salary of #format-amount(de.salary, digits: 0) EUR a year costs the employer
#format-amount(de.cost, digits: 0) EUR more in statutory charges, i.e.
#format-amount(de.total, digits: 0) EUR in total.

At each country's example salary, the published employer cost is
#employer-rate-text("DE") of gross in Germany and #employer-rate-text("IN") in India.

#employer-cost-table("DE", 60000)

#employer-cost-table("IN", 1200000)

= Europe at a glance

#employer-rates-table(region: "Europe")
