#import "@preview/cades:0.3.1": qr-code

// A simple dictionary to JSON encoder (only handles the subset needed for OMR key)
#let _se-json-encode(val) = {
  if type(val) == str {
    "\"" + val.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") + "\""
  } else if type(val) == int {
    str(val)
  } else if type(val) == array {
    "[" + val.map(_se-json-encode).join(",") + "]"
  } else if type(val) == dictionary {
    "{" + val.pairs().map(pair => _se-json-encode(pair.at(0)) + ":" + _se-json-encode(pair.at(1))).join(",") + "}"
  } else {
    "null"
  }
}

// A simple base64 encoder
#let _se-base64-encode(s) = {
  let b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let bytes = if type(s) == str { bytes(s) } else { s }
  let len = bytes.len()
  let out = ""
  let i = 0
  while i < len {
    let b1 = bytes.at(i)
    let b2 = if i + 1 < len { bytes.at(i + 1) } else { 0 }
    let b3 = if i + 2 < len { bytes.at(i + 2) } else { 0 }

    let enc1 = calc.quo(b1, 4)
    let enc2 = calc.rem(b1, 4) * 16 + calc.quo(b2, 16)
    let enc3 = calc.rem(b2, 16) * 4 + calc.quo(b3, 64)
    let enc4 = calc.rem(b3, 64)

    out += b64.at(enc1)
    out += b64.at(enc2)

    if i + 1 >= len {
      out += "=="
    } else if i + 2 >= len {
      out += b64.at(enc3) + "="
    } else {
      out += b64.at(enc3)
      out += b64.at(enc4)
    }
    i += 3
  }
  out
}

#let _content-to-str(c) = {
  if type(c) == str {
    c
  } else if type(c) == content and c.has("text") {
    c.text
  } else if type(c) == content and c.has("body") {
    _content-to-str(c.body)
  } else if type(c) == content and c.func() == [].func() {
    c.children.map(_content-to-str).join()
  } else if type(c) == content and c.func() == math.equation {
    _content-to-str(c.body)
  } else {
    ""
  }
}

// Optional strict profiles for the eight bundled OMR forms. Omitting `profile`
// preserves the 1.0.6 QR behavior for documents with arbitrary question counts.
#let sang-omr-profile(name) = {
  let profiles = (
    "12-4-6ngang": (id: "12-4-6ngang", mcq: 12, tf: 4, tln: 6, paper: "a5"),
    "thptqg-toan-2025": (id: "thptqg-toan-2025", mcq: 12, tf: 4, tln: 6, paper: "a4"),
    "ds-12": (id: "ds-12", mcq: 0, tf: 12, tln: 0, paper: "a4"),
    "hybrid-28tn-12ds": (id: "hybrid-28tn-12ds", mcq: 28, tf: 12, tln: 0, paper: "a4"),
    "tln-10": (id: "tln-10", mcq: 0, tf: 0, tln: 10, paper: "a4"),
    "tn-40": (id: "tn-40", mcq: 40, tf: 0, tln: 0, paper: "a4"),
    "tn-50": (id: "tn-50", mcq: 50, tf: 0, tln: 0, paper: "a4"),
    "tn-60": (id: "tn-60", mcq: 60, tf: 0, tln: 0, paper: "a4"),
  )
  if type(name) != str or not (name in profiles) {
    panic("sang-math OMR: unknown profile " + repr(name))
  }
  profiles.at(name)
}

#let sang-omr-qr(ma-de: "0001", paper: auto, width: 3cm, profile: none) = context {
  let mcq-ans = state("se-mcq", ()).final()
  let tf-ans = state("se-tf", ()).final()
  let sh-ans = state("se-sh", ()).final()
  let tl-ans = state("se-tl", ()).final()

  let mcq-len = mcq-ans.len()
  let tf-len = tf-ans.len()
  let sh-len = sh-ans.len()
  let selected = if profile == none { none } else { sang-omr-profile(profile) }
  if selected != none and (mcq-len != selected.mcq or tf-len != selected.tf or sh-len != selected.tln) {
    panic("sang-math OMR: answer counts do not match profile " + profile)
  }
  let sheet-id = if selected == none { "12-4-6ngang" } else { selected.id }
  let sheet-paper = if paper == auto { if selected == none { "a5" } else { selected.paper } } else { paper }

  let mcq-str = mcq-ans.map(x => x.ans).join()
  let tf-start = if tf-len > 0 { mcq-len + 1 } else { 0 }
  let tf-str = tf-ans.map(x => x.ans.join()).join()

  let sh-start = if sh-len > 0 { mcq-len + tf-len + 1 } else { 0 }
  let sh-arr = sh-ans.map(x => _content-to-str(x.ans).trim().replace("−", "-"))

  let payload = (
    z: 1,
    m: (
      source: "ConicTypst",
      made: ma-de,
      omr: (
        id: sheet-id,
        mcq: mcq-len,
        tf: tf-len,
        tln: sh-len,
        paper: sheet-paper
      )
    ),
    k: (
      (ma-de): (
        mcq-str,
        tf-start,
        tf-str,
        sh-start,
        sh-arr
      )
    )
  )

  let json-str = _se-json-encode(payload)
  let b64-str = _se-base64-encode(json-str)
  let final-str = "SMKEY:1:" + b64-str

  box(fill: white, inset: 8pt, radius: 4pt, qr-code(final-str, width: width))
}
