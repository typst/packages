#import "@preview/tud-letter:0.1.0": *
// #import "../src/lib.typ": *

#show: tud-letter.with(
  // lang: "nl",
  from: (
    name: "Jan Smit",
    phone: "+31 (0)15 27 12345",
    email: "j.smit@tudelft.nl",
  ),
  to: [
    Gerard Joling \
    Singer of the year \  
  ],
  date: datetime.today().display(),
  subject: "A very important letter",
  // faculty: (
  //   name: "Faculteit Bouwkunde",
  //   address: (
  //     (
  //       what: "bezoek",
  //       value: [Julianalaan 134 \ Delft 2628BL],
  //     ),
  //     (
  //       what: "correspondentie",
  //       value: [Postbus 5043 \ 2600 GA Delft],
  //     ),
  //   ),
  // ),
)

Dear Gerard, 

#lorem(60)

#lorem(100)

#v(1cm)
Best regards, 
#v(3mm)
Dr Jan Smit \
Head of an important department
