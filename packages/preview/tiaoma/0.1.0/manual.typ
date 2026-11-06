#import "./lib.typ": *

#show link: underline

#{
  set align(center)
  text(17pt)[tiaoma]
  par(justify: false)[
    A barcode generator for typst. Using #link("https://github.com/zint/zint")[zint] as backend.
  ]
}
#let barcode-height = 5em
#let left-right(..args) = grid(columns: (1fr, auto), gutter: 1%, ..args)

This package provides shortcut for commonly used barcode types. It also supports all barcode types supported by zint. All additional arguments will be passed to `image.decode` function. Therefore you may customize the barcode image by passing additional arguments.

#left-right[
  ```typ
  #ean("6975004310001", width: 10em)
  ```
][
  #align(right)[#ean("6975004310001", width: 10em)]
]

For more examples, please refer to the following sections.

#line(length: 100%)

#show: doc => columns(2, doc)


= EAN
== EAN-13
#left-right[
  ```typ
  #ean("6975004310001")
  ```
][
  #align(right)[#ean("6975004310001", height: barcode-height)]
]

== EAN-8

#left-right[
  ```typ
  #ean("12345564")
  ```
][
  #align(right)[#ean("12345564", height: barcode-height)]
]

== EAN-5

#left-right[
  ```typ
  #ean("12345")
  ```
][
  #align(right)[#ean("12345", height: barcode-height)]
]

== EAN-2

#left-right[
  ```typ
  #ean("12")
  ```
][
  #align(right)[#ean("12", height: barcode-height)]
]

= Code 128

#left-right[
  ```typ
  #code128("1234567890")
  ```
][
  #align(right)[#code128("1234567890", height: barcode-height)]
]

= Code 39

#left-right[
  ```typ
  #code39("ABCD")
  ```
][
  #align(right)[#code39("ABCD", height: barcode-height)]
]

= UPCA

#left-right[
  ```typ
  #upca("123456789012")
  ```
][
  #align(right)[#upca("123456789012", height: barcode-height)]
]

= Data Matrix

#left-right[
  ```typ
  #data-matrix("1234567890")
  ```
][
  #align(right)[#data-matrix("1234567890", height: barcode-height)]
]

= QR Code

#left-right[
  ```typ
  #qrcode("1234567890")
  ```
][
  #align(right)[#qrcode("1234567890", height: barcode-height)]
]

= Channel Code

#left-right[
  ```typ
  #channel("1234567")
  ```
][
  #align(right)[#channel("1234567", height: barcode-height)]
]

= MSI Plessey

#left-right[
  ```typ
  #msi-plessey("1234567")
  ```
][
  #align(right)[#msi-plessey("1234567", width: 7em)]
]

= Micro PDF417

#left-right[
  ```typ
  #micro-pdf417("1234")
  ```
][
  #align(right)[#micro-pdf417("1234", height: barcode-height)]
]

= Aztec Code

#left-right[
  ```typ
  #aztec("1234567890")
  ```
][
  #align(right)[#aztec("1234567890", height: barcode-height)]
]

= Code 16k

#left-right[
  ```typ
  #code16k("1234567890")
  ```
][
  #align(right)[#code16k("1234567890", width: 7em)]
]

= MaxiCode

#left-right[
  ```typ
  #maxicode("1234567890")
  ```
][
  #align(right)[#maxicode("1234567890", height: barcode-height)]
]

= Planet Code

#left-right[
  ```typ
  #planet("1234567890")
  ```
][
  #align(right)[#planet("1234567890", width: 9em)]
]

= Others

This package supports many other barcode types thanks to zint. You can find the full list in here:

+ Code11
+ C25Standard
+ C25Matrix
+ C25Inter
+ C25IATA
+ C25Logic
+ C25Ind
+ Code39
+ ExCode39
+ EANX
+ EANXChk
+ GS1128
+ EAN128
+ Codabar
+ Code128
+ DPLEIT
+ DPIDENT
+ Code16k
+ Code49
+ Code93
+ Flat
+ DBarOmn
+ RSS14
+ DBarLtd
+ RSSLtd
+ DBarExp
+ RSSExp
+ Telepen
+ UPCA
+ UPCAChk
+ UPCE
+ UPCEChk
+ Postnet
+ MSIPlessey
+ FIM
+ Logmars
+ Pharma
+ PZN
+ PharmaTwo
+ CEPNet
+ PDF417
+ PDF417Comp
+ PDF417Trunc
+ MaxiCode
+ QRCode
+ Code128AB
+ Code128B
+ AusPost
+ AusReply
+ AusRoute
+ AusRedirect
+ ISBNX
+ RM4SCC
+ DataMatrix
+ EAN14
+ VIN
+ CodablockF
+ NVE18
+ JapanPost
+ KoreaPost
+ DBarStk
+ RSS14Stack
+ DBarOmnStk
+ RSS14StackOmni
+ DBarExpStk
+ RSSExpStack
+ Planet
+ MicroPDF417
+ USPSIMail
+ OneCode
+ Plessey
+ TelepenNum
+ ITF14
+ KIX
+ Aztec
+ DAFT
+ DPD
+ MicroQR
+ HIBC128
+ HIBC39
+ HIBCDM
+ HIBCQR
+ HIBCPDF
+ HIBCMicPDF
+ HIBCCodablockF
+ HIBCAztec
+ DotCode
+ HanXin
+ Mailmark2D
+ UPUS10
+ Mailmark4S
+ Mailmark
+ AzRune
+ Code32
+ EANXCC
+ GS1128CC
+ EAN128CC
+ DBarOmnCC
+ RSS14CC
+ DBarLtdCC
+ RSSLtdCC
+ DBarExpCC
+ RSSExpCC
+ UPCACC
+ UPCECC
+ DBarStkCC
+ RSS14StackCC
+ DBarOmnStkCC
+ RSS14OmniCC
+ DBarExpStkCC
+ RSSExpStackCC
+ Channel
+ CodeOne
+ GridMatrix
+ UPNQR
+ Ultra
+ RMQR
+ BC412

There are some examples:

== C25Standard

#left-right[
  ```typ
  #barcode("123", "C25Standard")
  ```
][
  #align(right)[#barcode("123", "C25Standard", height: barcode-height)]
]

== UPCE

#left-right[
  ```typ
  #barcode("1234567", "UPCEChk")
  ```
][
  #align(right)[#barcode("1234567", "UPCEChk", width: barcode-height)]
]

== MicroQR

#left-right[
  ```typ
  #barcode("1234567890", "MicroQR")
  ```
][
  #align(right)[#barcode("1234567890", "MicroQR", width: 3em)]
]

== Aztec Runes

#left-right[
  ```typ
  #barcode("1234567890", "AzRune")
  ```
][
  #align(right)[#barcode("122", "AzRune", height: 3em)]
]

== Australia Post

#left-right[
  ```typ
  #barcode("1234567890", "AusPost")
  ```
][
  #align(right)[#barcode("12345678", "AusPost", width: 9em)]
]

== DotCode

#left-right[
  ```typ
  #barcode("1234567890", "DotCode")
  ```
][
  #align(right)[#barcode("1234567890", "DotCode", width: 3em)]
]

== CodeOne

#left-right[
  ```typ
  #barcode("1234567890", "CodeOne")
  ```
][
  #align(right)[#barcode("1234567890", "CodeOne", height: 3em)]
]

== Grid Matrix

#left-right[
  ```typ
  #barcode("1234567890", "GridMatrix")
  ```
][
  #align(right)[#barcode("1234567890", "GridMatrix", width: 2em)]
]

== Han Xin Code

#left-right[
  ```typ
  #barcode("1234567890", "HanXin")
  ```
][
  #align(right)[#barcode("1234567890", "HanXin", width: 3em)]
]

== Code128B

#left-right[
  ```typ
  #barcode("1234567890", "Code128B")
  ```
][
  #align(right)[#barcode("1234567890", "Code128B", height: 3em)]
]

== ISBN

#left-right[
  ```typ
  #barcode("9789861817286", "ISBNX")
  ```
][
#align(right)[#barcode("9789861817286", "ISBNX", height: 4em)]
]

== PharmaTwo

#left-right[
  ```typ
  #barcode("1234567890", "PharmaTwo")
  ```
][
  #align(right)[#barcode("12345678", "PharmaTwo", width: 3em)]
]
