#import "@preview/letter-pro:3.0.0": letter-simple

#set text(lang: "de")

#show: letter-simple.with(
  sender: (
    name: "Anja Ahlsen",
    address: "Deutschherrenufer 28, 60528 Frankfurt",
    extra: [
      Telefon: #link("tel:+4915228817386")[+49 152 28817386]\
      E-Mail: #link("mailto:aahlsen@example.com")[aahlsen\@example.com]\
    ],
  ),
  
  annotations: [Einschreiben - Rückschein],
  recipient: [
    Finanzamt Frankfurt\
    Einkommenssteuerstelle\
    Gutleutstraße 5\
    60329 Frankfurt
  ],
  
  reference-signs: (
    ([Steuernummer], [333/24692/5775]),
  ),
  
  date: "12. November 2014",
  subject: "Einspruch gegen den ESt-Bescheid",
)

Sehr geehrte Damen und Herren,

die von mir bei den Werbekosten geltend gemachte Abschreibung für den im
vergangenen Jahr angeschafften Fotokopierer wurde von Ihnen nicht berücksichtigt.
Der Fotokopierer steht in meinem Büro und wird von mir ausschließlich zu beruflichen
Zwecken verwendet.

Ich lege deshalb Einspruch gegen den oben genannten Einkommensteuerbescheid ein
und bitte Sie, die Abschreibung anzuerkennen.

Anbei erhalten Sie eine Kopie der Rechnung des Gerätes.

Mit freundlichen Grüßen
#v(1cm)
Anja Ahlsen

#v(1fr)
*Anlagen:*
- Rechnung
