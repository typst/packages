#import "@preview/olaii-upn-qr:0.0.2": olaii-upn-qr

#let debug = true

// Page setup
#set page(
  paper: "a4",
  margin: 0pt,
)

// Font
#set text(
  font: "Arial",
  size: 8pt,
  fill: black,
)

// 3 on one page
#set par(spacing: 0pt)

#block(
  height: 198mm,
  inset: 2cm,
  lorem(200)
)

#olaii-upn-qr(
  ime-placnika: "Poljubno podjetje d.o.o.",
  naslov-placnika: "Lepa cesta 10",
  kraj-placnika: "2000 Maribor",
  iban-placnika: "SI56 0203 6025 3863 406",
  referenca-placnika-1: "SI00",
  referenca-placnika-2: "1234-12345-123",
  namen-placila: "Plačilo računa",
  rok-placila: "10.12.2025",
  koda-namena: "CPYR",
  datum-placila: none,
  nujno: true,
  ime-prejemnika: "Olaii d.o.o.",
  naslov-prejemnika: "Litostrojska cesta 44a",
  kraj-prejemnika: "1000 Ljubljana",
  iban-prejemnika: "SI56 1010 0005 2910 391",
  referenca-prejemnika-1: "SI00",
  referenca-prejemnika-2: "1234",
  znesek: "***100,00",
  qr-content: "This is a test",
  debug: debug,
  debug-with-background: false
)