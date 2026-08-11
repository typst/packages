#import "@preview/ratsch-bmim:0.3.0" as bmim

#show: bmim.letter(
  lang: "de",
  // lang: "en",
  subject: [Schreiben zur Wiederkehr des PID-Reglers],
  date: datetime.today(),
  location: "Hall in Tirol",
  recipient-institution: [Maier und Schmidt AG],
  recipient-pro: [Herrn Dr.],
  recipient-name: [Joe Mustermann],
  recipient-address: [Auenweg 3\ 6060 Hall in Tirol],
  sender-department: none,
  sender-institute: [Institut für Automatisierungs- und Regelungstechnik],
  sender-pos: [Universitätsassistent],
  sender-name: [Dipl.-Ing. Max Doe],
  sender-tel: "+43(0) 50 8648 5678",
  sender-fax: none,
  sender-email: "max.doe@umit-tirol.at",
  sender-signature: image("test_signature.pdf"),
)

Sehr geehrte Damen und Herren,

#v(1em)

#lorem(40)

#lorem(80)

#lorem(20)
