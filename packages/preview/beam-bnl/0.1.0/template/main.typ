#import "@preview/beam-bnl:0.1.0": bnl-letter

#show: bnl-letter.with(
  department: [Your department],
  address: [Building XXX\
    P.O. Box 5000\
    Upton, NY 11973-5000\
    Phone: your phone number\
    your.name\@bnl.gov],
  info: [Your name\
    Your title\
    Your group\
    Brookhaven National Laboratory],
  comment: [Subject: Your subject],
  // Fixed example date keeps the gallery thumbnail reproducible.
  // Omit this argument to use today's date.
  date: datetime(year: 2026, month: 1, day: 15),
  // Supply the logo yourself: https://www.bnl.gov/brandcenter/logo.php
  // Download the horizontal RGB SVG and save it beside this file as bnl-logo.svg.
  // In the web app, upload it to this project. Then uncomment the next line:
  // logo: image("bnl-logo.svg", width: 2.13in),
  // signature: image("my-signature.svg", width: 1in),
  // references: bibliography("references.bib",
  //   style: "american-physics-society", title: "References"),
)

Dear recipient,

Please replace this text with your letter. Customize the department, address,
and sender information above before sending it.

This community template provides a Brookhaven letter layout. To add the logo,
download the horizontal RGB SVG from https://www.bnl.gov/brandcenter/logo.php,
add it to your project as bnl-logo.svg, and enable the logo option above.
Follow Brookhaven's Brand Center guidance when using the letterhead.

Sincerely yours,

