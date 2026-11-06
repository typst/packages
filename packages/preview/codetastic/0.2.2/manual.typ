
#import "@local/mantys:0.0.3": *
#import "@local/tidy:0.1.0"

#import "bits.typ"
#import "bitfield.typ"
#import "checksum.typ"
#import "ecc.typ"
#import "util.typ"
#import "qrutil.typ"
#import "codetastic.typ"

#show: mantys.with(
  ..toml("typst.toml"),

  title: [C#box(baseline:25%, inset:(x:-.1em), codetastic.qrcode("O", width:1em))detast#box(baseline:10%, inset:(left:-.05em,right:.1em), rotate(90deg, codetastic.ean5("00000", scale:(.8,.5))))c],
  abstract: [
    CODETASTIC draws different kinds of codes in your Typst documents.
    Supported codes include EAN-13 barcodes and QR-Codes.

    The codes are created and drawn in pure Typst.
  ],

  titlepage: titlepage.with(toc: false),
  index: none
)

#let show-module(name, scope: (:)) = {
  tidy-module(
    read(name + ".typ"),
    name: name,
    scope: (bits: bits, util: util, codetastic: codetastic) + scope,
    tidy: tidy
  )
}

= Codes

#show-module("codetastic")

// #show-module("bits")

//#show-module("qrutil", scope:(qrutil: qrutil))

