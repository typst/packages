#import "./lib.typ": *
#import "./lib.typ"
#import "@preview/tidy:0.2.0"
#import "@preview/tablex:0.0.8": tablex, colspanx, cellx
#import "./tidy_style.typ"

#set page(
  paper: "a4",
  margin: (
    y: 1em,
    x: 2em,
  ),
)

// shortcut for underlined links
#let l(dest, body) = underline(link(dest, body))

#{
  set align(center)
  heading(level: 1, text(size: 17pt)[tiaoma])
  [A barcode generator for typst that provides type safe API bindings for #l("https://zint.org.uk")[Zint] (#l("https://github.com/zint/zint")[GitHub]) library through a WASM #l("https://typst.app/docs/reference/foundations/plugin/")[plugin].
  ]
}

#v(10pt)

See #l("https://zint.org.uk/manual")[official Zint manual] for a more in-depth description of supported functionality.

= API

Some generators require additional configuration (such as composite codes), this can be achieved by passing #l(<options>)[options] to Zint.

#let ty-links = (:)

#let typst-type(v, doc-links: (:)) = {
  let ty-box(v) = {
    tidy_style.show-type(
      v,
      style-args: (colors: tidy_style.colors),
      docs: ty-links + doc-links,
    )
  }

  for (i, e) in v.split(",").map(ty-box).enumerate() {
    if i > 0 {
      h(2pt)
      text(size: 9pt)[or]
      h(2pt)
    }
    e
  }
}

#let typst-val(v, ty: none) = {
  let content = raw(v)
  let fg = black

  let ty = ty
  if v.starts-with("\"") {
    ty = "str"
  } else if v == "true" or v == "false" {
    ty = "bool"
  } else if v == "none" {
    ty = "none"
  } else if v.starts-with("-") or (
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
  ).contains(v.first()) {
    ty = "float"
  }

  if ty != none {
    fg = tidy_style.colors.at(ty, default: none)
    fg = fg.darken(50%).saturate(70%)
  }

  text(fill: fg, content)
}

#let t-style = (
  auto-vlines: false,
  stroke: gray.lighten(60%),
)
#let reference-table-style(head-rows: 1, key-column: true) = (
  ..t-style,
  fill: (col, row) => if row < head-rows {
    let additional = 10% * (head-rows - 1 - row)
    blue.lighten(80% - additional)
  } else if col == 0 and key-column == true {
    blue.lighten(90%)
  } else {
    none
  },
)

#let docs = tidy.parse-module(
  read("lib.typ"),
  name: "tiaoma",
  scope: (tiaoma: lib, typst-type: typst-type, typst-val: typst-val, l: l),
)

#tidy.show-module(
  docs,
  first-heading-level: 1,
  style: tidy_style,
  show-module-name: false,
  show-outline: false,
)

== Shortcut functions

Most barcodes are supported through #l(<examples>)[shortcut functions].
They accept the same arguments as `barcode` function but don't require `symbology` to be specified.

== Zint configuration <options>

All exported functions support optionally providing the `options` dictionary which is passed to Zint. This provides means to fully configure generated images.

The following values are valid for the `options` dictionary:

#let detailed(dest, content) = link(dest, underline(content))

#tablex(
  columns: (auto, 100pt, 1fr, auto),
  align: (center + horizon, center + horizon, left + horizon, center + horizon),
  ..reference-table-style(),
  [*Field*],
  [*Type*],
  [*Description*],
  [*Default*],
  [height],
  typst-type("float"),
  [Barcode height in X-dimensions (ignored for fixed-width barcodes)],
  typst-val("none"),
  [scale],
  typst-type("float"),
  [Scale factor when printing barcode, i.e. adjusts X-dimension],
  typst-val("1.0"),
  [whitespace-width],
  typst-type("int"),
  [Width in X-dimensions of whitespace to left & right of barcode],
  typst-val("0"),
  [whitespace-height],
  typst-type("int"),
  [Height in X-dimensions of whitespace above & below the barcode],
  typst-val("0"),
  [border-width],
  typst-type("int"),
  [Size of border in X-dimensions],
  typst-val("0"),
  detailed(<output_options>, "output-options"),
  typst-type(
    "int,array,dictionary",
    doc-links: (
      "int": <output_options>,
      "array": <output_options_arr>,
      "dictionary": <output_options_dict>,
    ),
  ),
  [Various output parameters (bind, box etc, see below)],
  typst-val("0"),
  [fg-color],
  typst-type("color"),
  [foreground color],
  typst-val("black"),
  [bg-color],
  typst-type("color"),
  [background color],
  typst-val("white"),
  [primary],
  typst-type("str"),
  [Primary message data (MaxiCode, Composite)],
  typst-val("\"\""),
  [option-1],
  typst-type("int"),
  [Symbol-specific options (see #l("https://zint.org.uk/manual")[manual])],
  typst-val("-1"),
  [option-2],
  typst-type("int"),
  [Symbol-specific options (see #l("https://zint.org.uk/manual")[manual])],
  typst-val("0"),
  detailed(<opt_3>, "option-3"),
  typst-type("int,str"),
  [Symbol-specific options (see #l("https://zint.org.uk/manual")[manual])],
  typst-val("0"),
  [show-hrt],
  typst-type("bool"),
  [Whether to show Human Readable Text (HRT)],
  typst-val("true"),
  detailed(<input_mode>, "input-mode"),
  typst-type(
    "int,string,array,dictionary",
    doc-links: (
      "int": <input_mode>,
      "string": <input_mode_str>,
      "array": <input_mode_arr>,
      "dictionary": <input_mode_dict>,
    ),
  ),
  [Encoding of input data],
  typst-val("0"),
  [eci],
  typst-type("int"),
  [Extended Channel Interpretation.],
  typst-val("0"),
  [dot-size],
  typst-type("float"),
  [Size of dots used in BARCODE_DOTTY_MODE.],
  typst-val("4.0 / 5.0"),
  [text-gap],
  typst-type("float"),
  [Gap between barcode and text (HRT) in X-dimensions.],
  typst-val("1.0"),
  [guard-descent],
  typst-type("float"),
  [Height in X-dimensions that EAN/UPC guard bars descend.],
  typst-val("5.0"),
)

#pagebreak()
=== Input Mode <input_mode>

Input mode options allow specifying how `Zint` should handle input data. `Zint` uses #typst-type("int") bitflags for these, but `tiaoma` allows you to specify them using several other formats as documented below.

The following options are supported:


#tablex(
  columns: (auto, auto, auto, 1fr),
  align: (left + horizon, center + horizon, center + horizon, left + horizon),
  ..reference-table-style(head-rows: 2),
  colspanx(4, cellx(align: center)[*Input format (mutually exclusive)*]),
  (),
  (),
  (),
  [*Constant*],
  typst-type("int"),
  typst-type("str"),
  [*Description*],
  raw("DATA_MODE"),
  typst-val("0"),
  typst-val("\"data\""),
  [Use full 8-bit range interpreted as binary data.],
  raw("UNICODE_MODE"),
  typst-val("1"),
  typst-val("\"unicode\""),
  [Use UTF-8 input.],
  raw("GS1_MODE"),
  typst-val("2"),
  typst-val("\"gs1\""),
  [Encode GS1 data using FNC1 characters.],
)

#tablex(
  columns: (auto, auto, auto, 1fr),
  align: (left + horizon, center + horizon, center + horizon, left + horizon),
  ..reference-table-style(head-rows: 2),
  colspanx(4, cellx(align: center)[*Behavior customization*]),
  (),
  (),
  (),
  [*Constant*],
  typst-type("int"),
  typst-type("str"),
  [*Description*],
  raw("ESCAPE_MODE"),
  typst-val("8"),
  typst-val("\"escape\""),
  [Process input data for escape sequences.],
  raw("GS1PARENS_MODE"),
  typst-val("16"),
  typst-val("\"gs1-parentheses\""),
  [Parentheses (round brackets) used in GS1 data instead of square brackets to delimit Application Identifiers (parentheses must not otherwise occur in the data).],
  raw("GS1NOCHECK_MODE"),
  typst-val("32"),
  typst-val("\"gs1-no-check\""),
  [Do not check GS1 data for validity, i.e. suppress checks for valid AIs and data lengths. Invalid characters (e.g. control characters, extended ASCII characters) are still checked for.],
  raw("HEIGHTPERROW_MODE"),
  typst-val("64"),
  typst-val("\"height-per-row\""),
  [Interpret the `height` variable as per-row rather than as overall height.],
  raw("FAST_MODE"),
  typst-val("128"),
  typst-val("\"fast\""),
  [Use faster if less optimal encodation for symbologies that support it (currently Data Matrix only).],
  raw("EXTRA_ESCAPE_MODE"),
  typst-val("256"),
  typst-val("\"extra-escape\""),
  [Undocumented.],
)


==== String Value <input_mode_str>

`input_mode` of #typst-type("str") type is assumed to be a _input format_ value from the first table.

==== Array Value <input_mode_arr>

`input_mode` of #typst-type("array") type is assumed to be a list of #typst-type("str") values from the above tables; individual constants will be converted to #typst-type("int")s and unioned together.

==== Dictionary Value <input_mode_dict>

`input_mode` of #typst-type("dictionary") type is assumed to be #typst-type("str")-#typst-type("bool") pairs where keys are constants from the above table.

Additionally, _input format_ can be specified as a #typst-type("str") value paired to #typst-val("\"format\"") key.

In other words, columns of the following table are equivalent:
#tablex(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: (
    center + horizon,
    center + horizon,
    center + horizon,
    center + horizon,
  ),
  ..reference-table-style(key-column: false),
  [#typst-type("dictionary")],
  [#typst-type("array")],
  [#typst-type("str")],
  [#typst-type("int")],
  [
    (#typst-val("\"format\""): #typst-val("\"data\""))
  ],
  [(#typst-val("\"data\""))],
  typst-val("\"data\""),
  typst-val("0"),
  [(#typst-val("\"unicode\""): #typst-val("true"))],
  [(#typst-val("\"unicode\""))],
  typst-val("\"unicode\""),
  typst-val("1"),
  [
    (#typst-val("\"gs1\""): #typst-val("true"), #typst-val("\"gs1-no-check\""): #typst-val("true"))
  ],
  [(#typst-val("\"gs1\""), #typst-val("\"gs1-no-check\""))],
  [N/A],
  typst-val("34"),
)


=== Output Options <output_options>

Output options allow specifying how `Zint` should generate the barcode/symbol.

#tablex(
  columns: (auto, auto, auto, 1fr),
  align: (left + horizon, center + horizon, center + horizon, left + horizon),
  ..reference-table-style(),
  [*Constant*], typst-type("int"), typst-type("str"), [*Description*],
  raw("BARCODE_BIND_TOP"), typst-val("1"), typst-val("\"barcode-bind-top\""), [Boundary bar _above_ the symbol and between rows if stacking multiple symbols.],
  raw("BARCODE_BIND"), typst-val("2"), typst-val("\"barcode-bind\""), [Boundary bars _above_ and _below_ the symbol and between rows if stacking multiple symbols.],
  raw("BARCODE_BOX"), typst-val("4"), typst-val("\"barcode-box\""), [Add a box surrounding the symbol and whitespace.],
  //[BARCODE_STDOUT], [8], typst-val("\"barcode-stdout\""), [Output to stdout],
  //[READER_INIT], [16], typst-val("\"reader-init\""), [Reader Initialisation (Programming)],
  raw("SMALL_TEXT"), typst-val("32"), typst-val("\"small-text\""), [Use a smaller font for the Human Readable Text.],
  raw("BOLD_TEXT"), typst-val("64"), typst-val("\"bold-text\""), [Embolden the Human Readable Text.],
  raw("CMYK_COLOUR"), typst-val("128"), typst-val("\"cmyk-color\""), [Select the CMYK colour space option for Encapsulated PostScript and TIF files.],
  raw("BARCODE_DOTTY_MODE"), typst-val("256"), typst-val("\"barcode-dotty-mode\""), [Plot a matrix symbol using dots rather than squares.],
  raw("GS1_GS_SEPARATOR"), typst-val("512"), typst-val("\"gs1-gs-separator\""), [Use GS instead of FNC1 as GS1 separator (Data Matrix only).],
  //[OUT_BUFFER_INTERMEDIATE], [1024], typst-val("\"out-buffer-intermediate\""), [Return ASCII values in bitmap buffer (OUT_BUFFER only)],
  raw("BARCODE_QUIET_ZONES"), typst-val("2048"), typst-val("\"barcode-quiet-zones\""), [Add compliant quiet zones (additional to any specified whitespace).],
  raw("BARCODE_NO_QUIET_ZONES"), typst-val("4096"), typst-val("\"barcode-no-quiet-zones\""), [Disable quiet zones, notably those with defaults.],
  raw("COMPLIANT_HEIGHT"), typst-val("8192"), typst-val("\"compliant-height\""), [Warn if height not compliant and use standard height (if any) as default.],
  raw("EANUPC_GUARD_WHITESPACE"), typst-val("16384"), typst-val("\"ean-upc-guard-whitespace\""), [Add quiet zone indicators ("<" / ">") to HRT whitespace (EAN/UPC)],
  raw("EMBED_VECTOR_FONT"), typst-val("32768"), typst-val("\"embed-vector-font\""), [Embed font in vector output.],
)

==== Array Value <output_options_arr>

`output_options` of #typst-type("array") type assumed to be #typst-type("str") values from the above table.

==== Dictionary Value <output_options_dict>

`output_options` of #typst-type("dictionary") type assumed to be #typst-type("str")-#typst-type("bool") pairs where keys are constants from the above table.

=== Option 3 <opt_3>

As there's constants associated with `option_3` values, this package allows specifying the
value as either an #typst-type("int") or a #typst-type("str").

The following table documents supported values and their #typst-type("str") representations:

#tablex(
  columns: (auto, auto, auto, 1fr),
  align: (left + horizon, center + horizon, center + horizon, left + horizon),
  ..reference-table-style(),
  [*Constant*],
  [#typst-type("int")],
  [#typst-type("str")],
  [*Description*],
  raw("DM_SQUARE"),
  typst-val("100"),
  typst-val("\"square\""),
  [Only consider square versions on automatic symbol size selection],
  raw("DM_DMRE"),
  typst-val("101"),
  typst-val("\"rect\""),
  [Consider DMRE versions on automatic symbol size selection],
  raw("DM_ISO_144"),
  typst-val("128"),
  typst-val("\"iso-144\""),
  [Use ISO instead of "de facto" format for 144x144 (i.e. don't skew ECC)],
  raw("ZINT_FULL_MULTIBYTE"),
  typst-val("200"),
  typst-val("\"full-multibyte\""),
  [Enable Kanji/Hanzi compression for Latin-1 & binary data],
  raw("ULTRA_COMPRESSION"),
  typst-val("128"),
  typst-val("\"compression\""),
  [Enable Ultracode compression *(experimental)*],
)

#pagebreak()
= Examples <examples>

#let entry-height = 4.5em
#let entry-gutter = 1em

#let example-entry(name, code-block, preview, ..extra) = block(
  breakable: true,
  inset: 5pt,
  fill: gray.lighten(90%),
  radius: 5pt,
)[
  #heading(level: 3, name)
  #if extra.pos().len() > 0 {
    stack(dir: ttb, spacing: 5pt, ..extra)
  }

  *Example:*

  #block(
    inset: 5pt,
    fill: white,
    stroke: gray.lighten(60%),
    radius: 2pt,
    width: 100%,
    text(size: 8pt, par(linebreaks: "simple", code-block)),
  )

  *Result:*

  #block(
    height: entry-height,
    width: 100%,
    align(center + horizon, preview),
  )
]

#let example-of-simple(name, func-name, func, data, ..extra) = example-entry(
  name,
  raw(
    "#" + func-name + "(\"" + data + "\")",
    block: true,
    lang: "typ",
  ),
  func(data, fit: "contain"),
  ..extra,
)


// Only works when entire content fits on a single page
#let section(..content) = [
  #v(1em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: entry-gutter,
    row-gutter: 7pt,
    ..content
  )
  #v(2em)
]

#show "<dbar>": [GS1 DataBar]
#show "(chk)": [w/ Check Digit]
#show "(cc)": [Composite Code]
#show "(omni)": [Omnidirectional]
#show "(omn)": [Omnidirectional]
#show "(stk)": [Stacked]
#show "(exp)": [Expanded]
#show "(ltd)": [Limited]

// There's a lot of page breaks here because there's currently no sane way of
// making #section properly layout example blocks without cuting some of them
// off. There's no way of balancing #columns and #grid/#table doesn't want to
// break into the new page when it should consistently.

== EAN (European Article Number)
#section(
example-of-simple("EANX", "eanx", eanx, "1234567890"),
example-of-simple("EAN-14", "ean14", ean14, "1234567890"),
example-of-simple("EAN-13", "eanx", eanx, "6975004310001"),
example-of-simple("EAN-8", "eanx", eanx, "12345564"),
example-of-simple("EAN-5", "eanx", eanx, "12345"),
example-of-simple("EAN-2", "eanx", eanx, "12"),
// example for "EAN (cc)"
)

#pagebreak()
== PDF417
#section(
  example-of-simple("Micro PDF417", "micro-pdf417", micro-pdf417, "1234567890"),
  example-of-simple("PDF417", "pdf417", pdf417, "1234567890"),
  example-of-simple("Compact PDF417", "pdf417-comp", pdf417-comp, "1234567890"),
)

#pagebreak()
== GS1

#section(
example-of-simple("GS1-128", "gs1-128", gs1-128, "[01]98898765432106"),
example-of-simple("<dbar> Omnidirectional", "dbar-omn", dbar-omn, "98898765432106"),
example-of-simple("<dbar> (ltd)", "dbar-ltd", dbar-ltd, "988987654321"),
example-of-simple("<dbar> (exp)", "dbar-exp", dbar-exp, "[01]98898765432106"),
example-of-simple("<dbar> (stk)", "dbar-stk", dbar-stk, "1234567890"),
example-of-simple("<dbar> (stk) (omn)", "dbar-omn-stk", dbar-omn-stk, "1234567890"),
// example for "<dbar> (exp) (stk)"
// example for "<dbar> (omn) (cc)"
// example for "<dbar> (omn) (cc)"
// example for "<dbar> (ltd) (cc)"
// example for "<dbar> (exp) (cc)"
// example for "<dbar> (stk) (cc)"
// example for "<dbar> (omn) (stk) (cc)"
// example for "<dbar> (exp) (stk) (cc)"
)

// TODO: Remove once utilities and above examples are provided
Zint supports (omn), (ltd), (exp), (stk) and (cc) variants of GS1. See #l(<options>)[configuration] section for information on how to use them.

#pagebreak()
== C25

#section(
  example-of-simple("Standard", "c25-standard", c25-standard, "123"),
  example-of-simple("Interleaved", "c25-inter", c25-inter, "1234567890"),
  example-of-simple("IATA", "c25-iata", c25-iata, "1234567890"),
  example-of-simple("Data Logic", "c25-logic", c25-logic, "1234567890"),
  example-of-simple("Industrial", "c25-ind", c25-ind, "1234567890"),
)

#pagebreak()
== UPC (Universal Product Code)

#section(
example-of-simple("UPC-A", "upca", upca, "01234500006"),
example-of-simple("UPC-A (chk)", "upca-chk", upca-chk, "012345000065"),
example-of-simple("UPC-E", "upce", upce, "123456"),
example-of-simple("UPC-E (chk)", "upce-chk", upce-chk, "12345670"),
// example for "UPC-A (cc)"
// example for "UPC-E (cc)"
)

#pagebreak()
== HIBC (Health Industry Barcodes)

#section(
  example-of-simple("Code 128", "hibc-128", hibc-128, "1234567890"),
  example-of-simple("Code 39", "hibc-39", hibc-39, "1234567890"),
  example-of-simple("Data Matrix", "hibc-dm", hibc-dm, "1234567890"),
  example-of-simple("QR", "hibc-qr", hibc-qr, "1234567890"),
  example-of-simple("PDF417", "hibc-pdf", hibc-pdf, "1234567890"),
  example-of-simple("Micro PDF417", "hibc-mic-pdf", hibc-mic-pdf, "1234567890"),
  example-of-simple(
    "Codablock-F",
    "hibc-codablock-f",
    hibc-codablock-f,
    "1234567890",
  ),
  example-of-simple("Aztec", "hibc-aztec", hibc-aztec, "1234567890"),
)

#pagebreak()
== Postal

#section(
  example-of-simple(
    "Australia Post Redirection",
    "aus-redirect",
    aus-redirect,
    "12345678",
  ),
  example-of-simple(
    "Australia Post Reply Paid",
    "aus-reply",
    aus-reply,
    "12345678",
  ),
  example-of-simple(
    "Australia Post Routing",
    "aus-route",
    aus-route,
    "12345678",
  ),
  example-of-simple(
    "Australia Post Standard Customer",
    "aus-post",
    aus-post,
    "12345678",
  ),
  example-of-simple(
    "Brazilian CEPNet Postal Code",
    "cepnet",
    cepnet,
    "1234567890",
  ),
  example-of-simple("DAFT Code", "daft", daft, "DAFTFDATATFDTFAD"),
  example-of-simple(
    "Deutsche Post Identcode",
    "dp-ident",
    dp-ident,
    "1234567890",
  ),
  example-of-simple(
    "Deutsche Post Leitcode",
    "dp-leitcode",
    dp-leitcode,
    "1234567890",
  ),
  example-of-simple(
    "Deutsher Paket Dienst",
    "dpd",
    dpd,
    "0123456789012345678901234567",
  ),
  example-of-simple("Dutch Post KIX Code", "kix", kix, "1234567890"),
)

#section(
  example-of-simple(
    "Japanese Postal Code",
    "japan-post",
    japan-post,
    "1234567890",
  ),
  example-of-simple("Korea Post", "korea-post", korea-post, "123456"),
  example-of-simple("POSTNET", "postnet", postnet, "1234567890"),
  example-entry(
    "Royal Mail 2D Mailmark (CMDM)",
    raw(
      "#mailmark-2d(\n\t32, 32,\n\t\"JGB 011123456712345678CW14NJ1T 0EC2M2QS      REFERENCE1234567890QWERTYUIOPASDFGHJKLZXCVBNM\"\n)",
      block: true,
      lang: "typ",
    ),
    mailmark-2d(
      32,
      32,
      "JGB 011123456712345678CW14NJ1T 0EC2M2QS      REFERENCE1234567890QWERTYUIOPASDFGHJKLZXCVBNM",
    ),
  ),
  example-of-simple(
    "Royal Mail 4-State Customer Code",
    "rm4scc",
    rm4scc,
    "1234567890",
  ),
  example-of-simple(
    "Royal Mail 4-State Mailmark",
    "mailmark-4s",
    mailmark-4s,
    "21B2254800659JW5O9QA6Y",
  ),
  example-of-simple(
    "Universal Postal Union S10",
    "upus10",
    upus10,
    "RR072705659PL",
  ),
  example-of-simple(
    "UPNQR (Univerzalnega Plačilnega Naloga QR)",
    "upnqr",
    upnqr,
    "1234567890",
  ),
  example-of-simple(
    "USPS Intelligent Mail",
    "usps-imail",
    usps-imail,
    "01300123456123456789",
  ),
)

#pagebreak()
== Other Generic Codes

#section(
  example-of-simple("Aztec Code", "aztec", aztec, "1234567890"),
  example-of-simple("Aztec Rune", "azrune", azrune, "122"),
  example-of-simple("Channel Code", "channel", channel, "123456"),
  example-of-simple("Codabar", "codabar", codabar, "A123456789B"),
  example-of-simple("Codablock-F", "codablock-f", codablock-f, "1234567890"),
  example-of-simple("Code 11", "code11", code11, "0123452"),
  example-of-simple("Code 16k", "code16k", code16k, "1234567890"),
  example-of-simple("Code 32", "code32", code32, "12345678"),
  example-of-simple("Code 39", "code39", code39, "1234567890"),
  example-of-simple("Code 49", "code49", code49, "1234567890"),
)
#section(
  example-of-simple("Code 128", "code128", code128, "1234567890"),
  example-of-simple("Code 128 (AB)", "code128ab", code128ab, "1234567890"),
  example-of-simple("Code One", "code-one", code-one, "1234567890"),
  example-of-simple(
    "Data Matrix (ECC200)",
    "data-matrix",
    data-matrix,
    "1234567890",
  ),
  example-of-simple("DotCode", "dotcode", dotcode, "1234567890"),
  example-of-simple("Extended Code 39", "ex-code39", ex-code39, "1234567890"),
  example-of-simple("Grid Matrix", "grid-matrix", grid-matrix, "1234567890"),
  example-of-simple(
    "Han Xin (Chinese Sensible)",
    "hanxin",
    hanxin,
    "abc123全ň全漄",
  ),
  example-of-simple("IBM BC412 (SEMI T1-95)", "bc412", bc412, "1234567890"),
  example-of-simple("ISBN", "isbnx", isbnx, "9789861817286"),
)
#pagebreak()
#section(
  example-of-simple("ITF-14", "itf14", itf14, "1234567890"),
  example-of-simple("LOGMARS", "logmars", logmars, "1234567890"),
  example-of-simple("MaxiCode", "maxicode", maxicode, "1234567890"),
  example-of-simple("Micro QR", "micro-qr", micro-qr, "1234567890"),
  example-of-simple("MSI Plessey", "msi-plessey", msi-plessey, "1234567890"),
  example-of-simple("NVE-18 (SSCC-18)", "nve18", nve18, "1234567890"),
  example-of-simple("Pharmacode One-Track", "pharma", pharma, "123456"),
  example-of-simple(
    "Pharmacode Two-Track",
    "pharma-two",
    pharma-two,
    "12345678",
  ),
  example-of-simple("Pharmazentralnummer", "pzn", pzn, "12345678"),
  example-of-simple("Planet", "planet", planet, "1234567890"),
)
#pagebreak()
#section(
  example-of-simple("Plessey", "plessey", plessey, "1234567890"),
  example-of-simple("QR Code", "qrcode", qrcode, "1234567890"),
  example-of-simple(
    "Rectangular Micro QR Code (rMQR)",
    "rmqr",
    rmqr,
    "1234567890",
  ),
  example-of-simple(
    "Telepen Numeric",
    "telepen-num",
    telepen-num,
    "1234567890",
  ),
  example-of-simple("Telepen", "telepen", telepen, "ABCD12345"),
  example-of-simple("Ultracode", "ultra", ultra, "1234567890"),
  example-of-simple(
    "Vehicle Identification Number",
    "vin",
    vin,
    "2GNFLGE30D6201432",
  ),
  example-of-simple("Facing Identification Mark", "fim", fim, "A"),
  example-of-simple("Flattermarken", "flat", flat, "123")[
    Used for marking book covers to indicate volume order.
  ],
)

= Symbology Values <symbology>

Following symbology values are supported:
#grid(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  gutter: 5pt,
  typst-val("\"Code11\""),
  typst-val("\"C25Standard\""),
  typst-val("\"C25Inter\""),
  typst-val("\"C25IATA\""),
  typst-val("\"C25Logic\""),
  typst-val("\"C25Ind\""),

  typst-val("\"Code39\""),
  typst-val("\"ExCode39\""),
  typst-val("\"EANX\""),
  typst-val("\"EANXChk\""),
  typst-val("\"GS1128\""),
  typst-val("\"Codabar\""),

  typst-val("\"Code128\""),
  typst-val("\"DPLEIT\""),
  typst-val("\"DPIDENT\""),
  typst-val("\"Code16k\""),
  typst-val("\"Code49\""),
  typst-val("\"Code93\""),

  typst-val("\"Flat\""),
  typst-val("\"DBarOmn\""),
  typst-val("\"DBarLtd\""),
  typst-val("\"DBarExp\""),
  typst-val("\"Telepen\""),
  typst-val("\"UPCA\""),

  typst-val("\"UPCAChk\""),
  typst-val("\"UPCE\""),
  typst-val("\"UPCEChk\""),
  typst-val("\"Postnet\""),
  typst-val("\"MSIPlessey\""),
  typst-val("\"FIM\""),

  typst-val("\"Logmars\""),
  typst-val("\"Pharma\""),
  typst-val("\"PZN\""),
  typst-val("\"PharmaTwo\""),
  typst-val("\"CEPNet\""),
  typst-val("\"PDF417\""),

  typst-val("\"PDF417Comp\""),
  typst-val("\"MaxiCode\""),
  typst-val("\"QRCode\""),
  typst-val("\"Code128AB\""),
  typst-val("\"AusPost\""),
  typst-val("\"AusReply\""),

  typst-val("\"AusRoute\""),
  typst-val("\"AusRedirect\""),
  typst-val("\"ISBNX\""),
  typst-val("\"RM4SCC\""),
  typst-val("\"DataMatrix\""),
  typst-val("\"EAN14\""),

  typst-val("\"VIN\""),
  typst-val("\"CodablockF\""),
  typst-val("\"NVE18\""),
  typst-val("\"JapanPost\""),
  typst-val("\"KoreaPost\""),
  typst-val("\"DBarStk\""),

  typst-val("\"DBarOmnStk\""),
  typst-val("\"DBarExpStk\""),
  typst-val("\"Planet\""),
  typst-val("\"MicroPDF417\""),
  typst-val("\"USPSIMail\""),
  typst-val("\"Plessey\""),

  typst-val("\"TelepenNum\""),
  typst-val("\"ITF14\""),
  typst-val("\"KIX\""),
  typst-val("\"Aztec\""),
  typst-val("\"DAFT\""),
  typst-val("\"DPD\""),

  typst-val("\"MicroQR\""),
  typst-val("\"HIBC128\""),
  typst-val("\"HIBC39\""),
  typst-val("\"HIBCDM\""),
  typst-val("\"HIBCQR\""),
  typst-val("\"HIBCPDF\""),

  typst-val("\"HIBCMicPDF\""),
  typst-val("\"HIBCCodablockF\""),
  typst-val("\"HIBCAztec\""),
  typst-val("\"DotCode\""),
  typst-val("\"HanXin\""),
  typst-val("\"Mailmark2D\""),

  typst-val("\"UPUS10\""),
  typst-val("\"Mailmark4S\""),
  typst-val("\"AzRune\""),
  typst-val("\"Code32\""),
  typst-val("\"EANXCC\""),
  typst-val("\"GS1128CC\""),

  typst-val("\"DBarOmnCC\""),
  typst-val("\"DBarLtdCC\""),
  typst-val("\"DBarExpCC\""),
  typst-val("\"UPCACC\""),
  typst-val("\"UPCECC\""),
  typst-val("\"DBarStkCC\""),

  typst-val("\"DBarOmnStkCC\""),
  typst-val("\"DBarExpStkCC\""),
  typst-val("\"Channel\""),
  typst-val("\"CodeOne\""),
  typst-val("\"GridMatrix\""),
  typst-val("\"UPNQR\""),

  typst-val("\"Ultra\""), typst-val("\"RMQR\""), typst-val("\"BC412\""),
)
