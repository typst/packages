#import "./preamble.typ": *

#show: bmim.letter(
  lang: "de",
  subject: [Schreiben zur Wiederkehr des PID-Reglers],
  date: datetime.today(),
  location: "Hall in Tirol",
  recipient: (
    institution: [Maier und Schmidt AG],
    pro: [Herrn Dr.],
    name: [Joe Mustermann],
    address: [Auenweg 3\ 6060 Hall in Tirol],
  ),
  sender: (
    department: none,
    institute: [Institut für Automatisierungs- und Regelungstechnik],
    pos: [Universitätsassistent],
    name: [Dipl.-Ing. Max Doe],
    tel: "+43(0) 50 8648 5678",
    fax: none,
    email: "max.doe@umit-tirol.at",
    signature: image("test_signature.pdf"),
  )
)

Sehr geehrte Damen und Herren,

#v(1em)

#lorem(40)

#lorem(80)

#lorem(20)
