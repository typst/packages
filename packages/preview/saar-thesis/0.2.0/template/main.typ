#import "@preview/saar-thesis:0.2.0": *

// Use "de" for German template labels.
#set text(lang: "en")

#show: saar.with(
  title: "Thesis Title",
  author: "Your Name",
  matriculation-number: "Your Matriculation Number",

  degree-program: "b-cs-info",
  // one of "b-cs-info", "b-cyber", "m-cs-info", "m-cyber"

  supervisors: (
    ("Supervisors", "First Supervisor", "Second Supervisor"),
    ("Additional advisor", "Additional Advisor"),
  ),

  date: "Submission Date",

  // mode: "print", // uncomment to obtain printing-friendly page margins

  abstract: [
    Write your abstract here.
  ],

  acknowledgments: [
    Write optional acknowledgments here, or remove this argument.
  ],
)

= Introduction

Start writing your thesis here.

= Background

Lorem ipsum dolor sit amet, consectetur adipiscing elit @musterfrau-1990-book.

#cite(<doe-roe-2020-lorem>, form: "prose") argued that sed do eiusmod tempor incididunt ut labore.

= My Contribution

= Conclusion

#bibliography("custom.bib")
