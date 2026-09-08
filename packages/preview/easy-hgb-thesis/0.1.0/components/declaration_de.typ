#import "i8n.typ": i8n-date-long

#show heading.where(level: 1): set block(spacing: 2em)
= Erklärung

Ich erkläre eidesstattlich, dass ich die vorliegende Arbeit selbstständig und ohne fremde
Hilfe verfasst, andere als die angegebenen Quellen nicht benutzt und die den benutzten
Quellen entnommenen Stellen als solche gekennzeichnet habe. Die Arbeit wurde bisher in
gleicher oder ähnlicher Form keiner anderen Prüfungsbehörde vorgelegt. Die vorliegende,
gedruckte Arbeit ist mit dem elektronisch übermittelten Textdokument identisch.

Hagenberg, am #i8n-date-long(datetime.today(offset: auto))

#context grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  ..document.author.map(author => {
    v(2cm)
    author
  })
)
