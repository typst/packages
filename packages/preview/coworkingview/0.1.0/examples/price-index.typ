#import "@preview/coworkingview:0.1.0": *

#assert(rate("berlin", "flex_desk").median == 214)
#assert(rate("Abu Dhabi", "flex desk").median == 1400)
#assert(rate("Abu Dhabi", "flex_desk").low_confidence == true)
#assert(rate("madrid", "day_pass").p25 == none)
#assert(rate("madrid", "day_pass").median == 22)
#assert(rate("example-town", "flex_desk") == none)
#assert(rate("nowhere", "flex_desk") == none)
#assert(cities().len() == 4)
#assert(attribution().contains("CC BY 4.0"))

= CoworkingView Price Index

Median flexible-office prices from the bundled snapshot. The line under the
table is the CC BY 4.0 credit for these figures.

#rates-table()

== Cities

#let _city-amount(value, currency) = {
  if value == none {
    "—"
  } else if currency == none {
    str(int(value))
  } else {
    str(int(value)) + " " + currency
  }
}

#table(
  columns: (1.4fr, auto, auto, auto),
  align: (left, right, right, left),
  inset: (x: 5pt, y: 4pt),
  table.header([City], [Entry median], [Sample], [Published]),
  ..cities()
    .map(city => (
      city.city_name,
      _city-amount(city.entry_median, city.currency),
      if city.sample_size == none { "—" } else { str(int(city.sample_size)) },
      if city.published { "yes" } else { "no" },
    ))
    .flatten(),
)

#v(0.6em)
#text(size: 8pt, attribution())
