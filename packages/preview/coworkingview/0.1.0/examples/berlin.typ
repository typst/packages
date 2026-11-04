#import "@preview/coworkingview:0.1.0": rate, rates-table, attribution

#let flex = rate("berlin", "flex_desk")
#let office = rate("Berlin", "private office")
#assert(flex.median == 214)
#assert(flex.currency == "EUR")
#assert(flex.unit == "month")
#assert(flex.sample_size == 72)
#assert(flex.low_confidence == false)
#assert(office.median == 480)
#assert(office.p25 == 399)
#assert(office.p75 == 550)
#assert(office.sample_size == 59)
#assert(attribution().contains("CC BY 4.0"))

= Berlin

Flex desk median: #int(flex.median) #flex.currency/#flex.unit,
sample #int(flex.sample_size).

#rates-table(city: "berlin")
