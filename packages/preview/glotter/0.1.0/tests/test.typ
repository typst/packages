#import "../lib.typ": detect-info, supported-languages, supported-language-count, is-supported-language
#import "probes.typ": all-language-probes

#set page(width: 240mm, height: auto, margin: 12mm)
#set text(size: 8pt)

#let fmt-percent(x) = {
  if x == none {
    "-"
  } else {
    str(calc.round(x * 100, digits: 2)) + "%"
  }
}

#let fmt-bool(x) = {
  if x { "true" } else { "false" }
}

#let pred-langs(info) = {
  info.at("predictions").map(p => p.at("lang"))
}

#let eval-case(c, k: 5, min-margin: 0.12) = {
  let info = detect-info(
    c.at("text"),
    k: k,
    min-margin: min-margin,
    fallback: "und",
  )

  let langs = pred-langs(info)
  let expected = c.at("expected")

  (
    name: c.at("name"),
    text: c.at("text"),
    expected: expected,
    top1: info.at("detected-lang"),
    final: info.at("lang"),
    probability: info.at("probability"),
    margin: info.at("margin"),
    ambiguous: info.at("ambiguous"),
    topk: langs,
    top1-pass: info.at("detected-lang") == expected,
    topk-pass: langs.contains(expected),
    supported: is-supported-language(expected),
  )
}

#let render-coverage(cases, title: "All-language probes", k: 5, min-margin: 0.12) = {
  let results = cases.map(c => eval-case(c, k: k, min-margin: min-margin))
  let total = results.len()
  let top1-passed = results.filter(r => r.at("top1-pass")).len()
  let topk-passed = results.filter(r => r.at("topk-pass")).len()
  let ambiguous = results.filter(r => r.at("ambiguous")).len()
  let unsupported = results.filter(r => not r.at("supported")).len()

  [
    = #title

    #table(
      columns: (auto, auto),
      inset: 5pt,
      [supported languages in package], [#supported-language-count],
      [test cases], [#total],
      [top-1 coverage], [#top1-passed / #total (#fmt-percent(top1-passed / total))],
      [top-#k coverage], [#topk-passed / #total (#fmt-percent(topk-passed / total))],
      [ambiguous], [#ambiguous],
      [unsupported expected codes], [#unsupported],
    )

    #v(1em)

    #table(
      columns: (auto, auto, auto, auto, auto, auto, auto, 1fr),
      align: (center, center, center, center, right, right, center, left),
      inset: 4pt,
      [status], [expected], [top-1], [final], [prob], [margin], [ambig], [top-#k],

      ..results.map(r => (
        [#if r.at("top1-pass") { "PASS" } else if r.at("topk-pass") { "TOPK" } else { "FAIL" }],
        [#raw(r.at("expected"))],
        [#raw(r.at("top1"))],
        [#raw(r.at("final"))],
        [#fmt-percent(r.at("probability"))],
        [#fmt-percent(r.at("margin"))],
        [#fmt-bool(r.at("ambiguous"))],
        [#r.at("topk").map(raw).join(", ")],
      )).flatten()
    )

    #v(1em)

    == Non-top-1 cases

    #let weak = results.filter(r => not r.at("top1-pass"))

    #if weak.len() == 0 [
      #strong[No non-top-1 cases.]
    ] else {
      table(
        columns: (auto, auto, auto, auto, 1fr, 2fr),
        align: (center, center, center, right, left, left),
        inset: 4pt,
        [expected], [top-1], [final], [margin], [top-#k], [input],

        ..weak.map(r => (
          [#raw(r.at("expected"))],
          [#raw(r.at("top1"))],
          [#raw(r.at("final"))],
          [#fmt-percent(r.at("margin"))],
          [#r.at("topk").map(raw).join(", ")],
          [#r.at("text")],
        )).flatten()
      )
    }
  ]
}

#let missing-from-supported-list = (
  all-language-probes
    .map(c => c.at("expected"))
    .filter(code => not supported-languages.contains(code))
)

#render-coverage(
  all-language-probes,
  title: "All-language probes for fastText lid.176.ftz labels",
  k: 5,
  min-margin: 0.12,
)

#pagebreak()

= Supported-code consistency

#table(
  columns: (auto, 1fr),
  inset: 5pt,
  [missing expected codes], [
    #if missing-from-supported-list.len() == 0 {
      [none]
    } else {
      missing-from-supported-list.map(raw).join(", ")
    }
  ],
)
