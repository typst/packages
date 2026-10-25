#import "./preamble.typ": *

#show: bmim.flyer(
  lang: "de",
  theme: "cd26", // "cd26" (default) or "cd20"
  title: [Tag der offenen Tür: Mechatronik zum Anfassen],
  series: [Informationsveranstaltung],
  details: (
    ([Organisation], [
      Institut für Automatisierungs- und Regelungstechnik \
      UMIT TIROL
    ]),
    ([Termin], [
      // "14." at the start of a line would be an enumeration, escape the dot
      14\. März 2026 von 10.00 bis 16.00 Uhr \
      #text(size: 0.85em)[UMIT TIROL, Eduard-Wallnöfer-Zentrum 1, 6060 Hall in Tirol]
    ]),
    ([Anmeldung], [nicht erforderlich]),
  ),
  background: image("./../assets/background_umit.jpg"),
  back-image: image("./../assets/background_bettelwurf.jpg"),
  qr-code: qr-code(
    quiet-zone: false,
    dark-color: white,
    light-color: bmim.color.blue,
    bmim.build-vcard(
      (
        title: "Dr.-Ing.",
        firstname: "Feedback",
        lastname: "Control",
        role: "Postdoc",
        address: (
            street: "Gain Street 1",
            zip: "1234",
            town: "Stable Valley",
            country: "Pole Islands",
        ),
        telephone: "+123456789",
        email: "feddback@contr.ol",
    )
    ),
    width: 70pt,
  ),
)

// The document body is the back page, designed freely; here the badge is
// placed directly below the first heading.
#bmim.flyer-heading[Was Sie erwartet]

#bmim.flyer-badge[14\. März 2026, 10.00 Uhr]

An unseren Laboren zeigen wir, wie Regelungstechnik und Mechatronik im Alltag
wirken: von Robotern über medizinische Assistenzsysteme bis zu Prüfständen für
Antriebe.

#lorem(50)

- Führungen durch die Labore
- Vorträge zu den Studiengängen
- Gespräche mit Studierenden und Lehrenden

// push the following to the bottom of the page
#v(1fr)

#bmim.flyer-heading(size: 16pt)[Anfahrt und Kontakt]

Die UMIT TIROL erreichen Sie mit der S-Bahn bis Hall in Tirol, von dort sind es
etwa zehn Minuten zu Fuß. Parkplätze stehen am Campus in begrenzter Zahl zur
Verfügung.

#lorem(40)

Bei Fragen erreichen Sie uns unter iace\@umit-tirol.at.
