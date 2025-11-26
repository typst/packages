// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "@preview/linguify:0.4.2": *

#import "colors.typ": *
#import "lang.typ": *

#import "libs/tablestyle.typ": *
#import "libs/requirements.typ": *
#import "libs/stringify.typ": *

#let risk(
  asset,
  protection_requirements,
  threat,
  likelihood,
  impact,
  risk_level,
  description,
  evaluation,
  mitigation_measures,
) = {
  show table.header: set text(size: 15pt)
  show figure: set block(breakable: true)
  set block(breakable: true)
  let f(s) = {
    set par(justify: false)
    [*#linguify(s, from: lang-db)*]
  }

  figure(
    caption: asset + ": " + threat,
    supplement: linguify("lib_risk_risk", from: lang-db),
    kind: plain-text(linguify("lib_risk_risk", from: lang-db)),
    numbering: "1",
    box(
      stroke: 2pt,
      radius: 5pt,
      clip: true,
      table(
        columns: (23%, 77%),
        align: left,
        fill: (x, y) => {
          if (y == 0) {
            hm_grey_very_light
          }
        },
        table.header(
          [*#linguify("lib_risk_asset", from: lang-db)*], [*#asset*],
        ),
        [#f("lib_risk_protection-requirements")], [#protection_requirements],
        [#f("lib_risk_threat")], [#threat],
        [#f("lib_risk_likelihood")], [#likelihood],
        [#f("lib_risk_impact")], [#impact],
        [#f("lib_risk_risk_level")], [#risk_level],
        [#f("lib_risk_description")], [#description],
        [#f("lib_risk_evaluation")], [#evaluation],
        [#f("lib_risk_mitigation_measures")], [#mitigation_measures],
      ),
    ),
  )
}
