# Strath MAE Interimst
Unofficial Typst Template for MAE courseworks at Strathclyde

# Usage

This example should (almost) replicate the template seen on MyPlace:

```
#import "@local/strath-mae-interimst:0.1.0": *

#show: body => report(
  class: [ME420: Individual Project (Aerospace)],
  title: [Title of Interim Report],
  author: [Joe Bloggs],
  number: [202512345],
  supervisor: [Dr. Jane Smith],
  date: [#datetime.today().display("[day]/[month]/[year]")],
  abstract: [#lorem(100)],
  body
)

= Introduction

== Sub-section

=== Sub-sub-section

= Literature Review

= Methodology

#figure(
  table(
    columns: 3,
    [],[Step],[Comment],
    [1],[Add a `caption` argument to `#figure`],[The `show` rule sets the caption position],
    [2],[Add the caption text in square brackets],[Add a `<tag>` after the figure to reference it later]
    
  ), caption: [How to insert a caption]
) <tableexample>

= Results
#figure(
image("MSWord.png"),
caption: [The Caption pop out window from the References Tab in Microsoft Word @source]
) <screenshot>

= Discussion

= Conclusion

#pagebreak()
#show bibliography: set heading(numbering: "1.1.")
#bibliography("bib.yml", title: [References], )
```