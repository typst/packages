#import "./preamble.typ": *

// Flyer with own images: background of the front page, image of the back
// page, an image in place of the QR code (bottom left, in its own size) and
// own logos at the bottom right.
#show: bmim.flyer(
  lang: "en",
  theme: "cd26",
  // body text of the back page
  size: 12pt,
  // font sizes of the front page, the badge and the headings of the back page
  // (defaults: series 11pt, title 25pt, details 16pt, badge 11pt, heading 20pt)
  sizes: (title: 28pt, details: 14pt, badge: 12pt),
  title: [Summer School on Robotics and Control],
  series: [Summer School],
  details: (
    ([Organisation], [
      Institute of Automation and Control Engineering, UMIT TIROL \
      Department of Mechatronics, University of Innsbruck
    ]),
    ([Date], [
      #context bmim.print-date-time(
        datetime(year: 2027, month: 7, day: 12),
        end: datetime(year: 2027, month: 7, day: 16),
      ) \
      #text(size: 0.85em)[UMIT TIROL, Eduard-Wallnöfer-Zentrum 1, 6060 Hall in Tirol]
    ]),
    // a row without label (none or []) has no colon
    (none, [Free participation, registration until 30th June 2027]),
  ),
  // front page: any image, it covers the whole page
  background: image("./../assets/background_umit.jpg"),
  // back page: image at the top
  back-image: image("./../assets/background_bettelwurf.jpg"),
  // bottom left: any content in its own size, here an image instead of a QR code
  qr-code: image("./../assets/logo_lfui_color_invert.png", height: 36pt),
  logo: (
    // second logo, left of the right logo
    flyer-left: bmim.institute-logo(institute: "iace", height: 40pt),
    // replaces the UMIT logo
    flyer-right: bmim.umit-logo(subtitle: false, height: 36pt),
  ),
)

// The document body is the back page.
#bmim.flyer-heading[One week of robotics and control]

#bmim.flyer-badge(
  datetime(year: 2027, month: 7, day: 12),
  end: datetime(year: 2027, month: 7, day: 16),
)

#lorem(60)

- Lectures on modelling and control
- Hands-on sessions in the labs
- Excursion to the Alps

#v(1em)

#bmim.flyer-heading(size: 16pt)[Organisation]

#lorem(40)
