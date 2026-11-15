#import "./preamble.typ": *

// date and time of the event, used for the details, the badge and the QR code
#let start = datetime(year: 2026, month: 11, day: 5, hour: 17, minute: 0, second: 0)
#let end = datetime(year: 2026, month: 11, day: 5, hour: 18, minute: 30, second: 0)
// title on the front page and as heading on the back page
#let title = [Bringing quantum systems under control: From algorithms to hardware]

#show: bmim.flyer(
  lang: "en",
  title: title,
  series: [Mechatronisches Kolloquium],
  details: (
    ([Presenter], [
      Dr.-Ing. Jane Doe \
      University of Somewhere, Institute for Systems Theory and Automatic Control
    ]),
    ([Date], [
      #context bmim.print-date-time(start, end: end.display("[hour]:[minute]")) \
      PR204 \
      #text(size: 0.85em)[UMIT TIROL, Eduard-Wallnöfer-Zentrum 1, 6060 Hall in Tirol]
    ]),
  ),
  // free choice of the images, they cover the area
  background: image("./../assets/background_umit.jpg"),
  back-image: image("./../assets/background_bettelwurf.jpg"),
  qr-code: qr-code(
    quiet-zone: false,
    dark-color: white,
    light-color: bmim.color.blue,
    bmim.build-vcalendar(
      (
        name: "Bringing quantum systems under control",
        location: "UMIT TIROL, PR204, Eduard-Wallnöfer-Zentrum 1, 6060 Hall in Tirol",
        // a datetime without time gives an all-day event
        start: start,
        end: end,
        description: "Mechatronisches Kolloquium"
      )
    ),
    width: 70pt,
  ),
  // second logo next to the UMIT logo, comparable to the title slide
  logo: (
    flyer-left: bmim.institute-logo(institute: "iace", height: 40pt),
  ),
)

// The document body is the back page, designed freely; flyer-heading and
// flyer-badge give headings and the badge in the style of the flyer.
#bmim.flyer-heading(title)

Imagine a system whose state dimension doubles with every component you add,
whose state is irreversibly disturbed the moment you measure it, and which
constantly leaks information into its environment. A control engineer's
nightmare? Welcome to quantum computing.

#lorem(60)

#lorem(50)

// the badge where it is placed, a datetime is shown with date and time
#bmim.flyer-badge(start, end: end)

#v(1em)

// line below the heading as wide as the portrait
#bmim.flyer-heading(size: 16pt, rule: 25%)[Short bio]

#grid(
  columns: (25%, 1fr),
  column-gutter: 1.5em,
  // e.g. image("portrait.jpg", width: 100%)
  rect(width: 100%, height: 9em, fill: white.transparentize(80%), stroke: none)[
    #set align(center + horizon)
    Portrait
  ],
  [
    *Dr.-Ing. Jane Doe,* University of Somewhere, Institute for Systems Theory
    and Automatic Control

    #lorem(80)
  ],
)
