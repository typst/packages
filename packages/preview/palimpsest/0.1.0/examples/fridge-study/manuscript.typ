#import "@preview/palimpsest:0.1.0": *
#import "@preview/unequivocal-ams:0.1.2": theorem, proof
#import "@preview/lilaq:0.6.0" as lq

// Numbered display equations — unnumbered by default under this
// template, but a numbered model equation is common enough in a real
// paper to be worth demonstrating, and it's what lets the equation
// pinpoint(<r1-3>, excerpt: true) quotes below show a real number to
// match against.
#set math.equation(numbering: "(1)")

// The two co-authors, so they can leave their own notes below alongside
// the reviewers' — Ivana with an explicit color, Tupper with just a
// display name (still gets an automatic, distinct color).
#set-revisions(authors: (
  ivana: (name: "Ivana Snackwell", color: rgb("#0f766e")),
  tupper: "Tupper Ware",
))

// Shown only in manuscript-tracked.pdf (change-list() auto-hides in
// clean, see §7.3) — a table of every marked passage, for checking off
// against the reviewers' letter one by one.
#change-list()

= Introduction

Refrigerators are widely believed to be static containers whose contents
change only through the deliberate actions of their owners. This
assumption has rarely been tested directly. In this study, we
investigate whether the frequency with which a refrigerator door is
opened — a behavior we term fridge-checking — is associated with the
subjective probability that its owner reports finding something new
inside, independent of whether anything was actually added to the
refrigerator during the observation period.

#passage(<r1-1>)[
  We define fridge-checking #add[, following the terminology introduced
  by @midnightsnackers2019,] as any refrigerator-door-opening event that
  is not immediately followed by either the removal or the addition of a
  food item.
]

#touched(<ivana-1>)[
  We re-read this definition after the change above and confirm it
  still matches how fridge-checking events were actually coded during
  data collection.
]

#passage(<r1-10>)[
  #add[This comment from the first reviewer required a correction in two
  places in the manuscript — this sentence, in the introduction, and a
  matching one in the conclusion —] applies equally to both instances.
]

Anecdotally, household members report opening the refrigerator
repeatedly over short periods despite reporting no expectation that its
contents have changed. We refer to this informally as the "hope springs
eternal" hypothesis, a fridge-specific corollary of general optimism
bias. This preliminary report builds on our earlier observational work
#cite(<snackwell2020>) by formally quantifying the relationship between
opening frequency and discovery probability across a larger and more
diverse sample of households.

#lorem(90)

= Methods

== Study population and design

We recruited 42 households across three cities to participate in a
30-day prospective observational study. Eligible households were
required to own at least one refrigerator, have at least one adult
member willing to complete a daily fridge-opening log, and report no
professional catering experience, to exclude expert fridge-checkers, who
were assumed to behave differently.

#touched(<r1-4>)[
  Households were recruited via flyers posted in laundromats, grocery
  stores, and one particularly well-trafficked gym.
]

#lorem(60)

#passage(<r1-5>)[
  #figure(
    placement: auto,
    table(
      columns: 4,
      table.header[][*Low tertile*][*Medium tertile*][*High tertile*],
      [Household size, mean], [1.8], [2.4], [#rep[2.6][3.1]],
      [Owns a pet, %], [12], [19], [31],
      [Fridge magnets, median], [3], [5], [9],
      [Snacks after 10pm, %], [21], [38], [64],
    ),
    caption: [Household characteristics by tertile of daily fridge-opening frequency.],
  ) <tab-baseline>
]

As shown in @tab-baseline, households in the high-opening tertile
reported markedly more fridge magnets and a higher prevalence of
after-hours snacking.

== #passage(<r2-1>)[Statistical analysis #add[(updated)]]

#passage(<r1-2>)[
  #rep[The association between opening frequency and discovery
  probability was assessed using ordinary logistic regression, with one
  observation per household.][The association between opening frequency
  and discovery probability was assessed using generalized estimating
  equations with an exchangeable working correlation structure
  #cite(<geemodel2017>), to account for the repeated, within-household
  structure of the daily opening logs.]
]

#passage(<r1-3>)[
  The primary model
  #rep[
    $ P("discovery") = beta_0 + beta_1 dot "openings" $
  ][
    $ "logit"(P("discovery")) = beta_0 + beta_1 dot "openings" + u_"household" $ <eq-model>
  ]
  #rep[is a naive linear probability model.][, where $u_"household"$ is a
  household-level random effect absorbing unmeasured, time-invariant
  fridge-checking tendencies.]
]

#passage(<tupper-1>)[
  #add[While implementing the change above, we also noted that the
  estimated household-level random effect variance, $hat(sigma)^2_u =
  0.42$, is worth reporting explicitly: it indicates non-trivial
  between-household heterogeneity in fridge-checking tendencies beyond
  what opening frequency alone explains.]
]

#lorem(70)

#deleted(<r1-6>, summary: [the closed-form calibration equation, which
  became algebraically identical to the model equation above once it was
  refit with a logit link])[
  For completeness, calibrated discovery probabilities were also
  computed directly as
  $ hat(p) = "expit"(hat(beta)_0 + hat(beta)_1 dot "openings") $
]

#lorem(50)

#theorem[
  For any household refrigerator observed for a sufficiently long time,
  there exists at least one food item whose provenance cannot be
  established by any current member of the household.
]

#passage(<r2-5>)[
  #add[We propose to call this the Second Law of Fridge Thermodynamics.]
]

#proof[
  Suppose, for contradiction, that every item in the refrigerator has a
  known provenance at every point in time. Then no item could ever
  transition from "recently purchased" to "mystery item" without an
  intervening act of forgetting. But forgetting is, empirically,
  unavoidable over a sufficiently long observation window
  #cite(<snackwell2020>). This contradicts the assumption, and the claim
  follows.
]

= Results

#lorem(60)

#figure(
  placement: auto,
  lq.diagram(
    width: 8cm,
    height: 5cm,
    xlabel: [Daily fridge openings],
    ylabel: [Discovery probability (%)],
    yaxis: (lim: (0, 85)),
    xaxis: (ticks: ((1, "1–2"), (2, "3–5"), (3, "6–10"), (4, "11–20"), (5, ">20"))),
    lq.bar(
      (1, 2, 3, 4, 5),
      (14, 27, 41, 58, 73),
      fill: rgb("#7a9e7e"),
      width: 70%,
    ),
  ),
  caption: [Reported probability of finding something new inside the
  refrigerator, by daily opening frequency (openings per day).],
) <fig-dose-response>

#touched(<e1>)[
  @fig-dose-response shows an apparent dose-response relationship
  between opening frequency and discovery probability, despite grocery
  deliveries being held constant across groups by design.
]

#lorem(70)

#passage(<r2-2>)[
  #add[
    #figure(
      placement: auto,
      lq.diagram(
        width: 7.5cm,
        height: 4.2cm,
        xlabel: [Odds ratio (95% CI)],
        xlim: (0, 3),
        yaxis: (
          ticks: (
            (1, "Owns a fridge\norganizer"),
            (2, "Weekend vs.\nweekday"),
            (3, "Lives alone"),
            (4, "Owns a pet"),
          ),
          lim: (0.5, 4.5),
        ),
        lq.vlines(1, stroke: (paint: gray, dash: "dashed")),
        lq.plot(
          (0.8, 2.0, 1.1, 1.6),
          (1, 2, 3, 4),
          xerr: ((p: 0.3, m: 0.3), (p: 0.7, m: 0.6), (p: 0.6, m: 0.5), (p: 0.5, m: 0.4)),
          stroke: none,
          mark: "o",
        ),
      ),
      caption: [Subgroup odds ratios for the association between
      opening frequency and discovery probability.],
    ) <fig-forest>
  ]
]

#lorem(90)

#deleted(<r2-7>, summary: [the day-of-week discovery-rate chart, redundant with @fig-dose-response])[
  #figure(
    lq.diagram(
      width: 6.5cm,
      height: 3.6cm,
      xlabel: [Day of week],
      ylabel: [Discovery rate (%)],
      xaxis: (ticks: ((1, "Mon"), (2, "Tue"), (3, "Wed"), (4, "Thu"), (5, "Fri"), (6, "Sat"), (7, "Sun"))),
      yaxis: (lim: (0, 60)),
      lq.plot(
        (1, 2, 3, 4, 5, 6, 7),
        (38, 40, 37, 41, 39, 44, 42),
        stroke: rgb("#7a9e7e"),
        mark: "o",
      ),
    ),
    caption: [Discovery rate by day of week.],
  )
]

#lorem(60)

#suppressed(
  <r2-3>,
  [Sub-analysis removed: the sock-drawer control group, including its
  summary figure and table],
  summary: [the sock-drawer control group sub-analysis, including its
  figure and table],
)

#lorem(80)

#passage(<r2-6>)[
  #figure(
    placement: auto,
    table(
      columns: 3,
      table.header[Category][Day 1][Day 30],
      [Forgotten leftovers], [61%], [58%],
      [Mystery Tupperware], [24%], [22%],
      [Something green], [9%], [7%],
      [Actually edible food], [6%], [13%],
      // An ADDED row stays in both compiles (add[...] alone handles the
      // clean-vs-tracked styling) — no `if mode() == "clean" { () }
      // else {...}` gating, that pattern is for a row genuinely
      // absent from the submitted manuscript (a DELETED row, see
      // tests/marks-figures.typ), not an accepted addition. An earlier
      // version of this table wrongly hid this row from manuscript.pdf
      // entirely (see CLAUDE.md) — a real defect, since the row is
      // actually part of what's submitted, added in response to R2-6.
      add[Unidentified frozen object], add[--], add[3%],
    ),
    caption: [Fridge discovery categories, day 1 versus day 30 of observation.],
  ) <tab-discovery>
]

As shown in @tab-discovery, the proportion of discoveries classified as
"actually edible food" more than doubled over the observation period.

#suppressed(
  <r1-9>,
  [Sensitivity analysis removed: results by handle-contamination threshold],
  summary: [the sensitivity analysis by handle-contamination threshold],
)

#lorem(60)

#passage(<r1-7>)[
  #add[A sensitivity analysis was conducted to assess robustness to
  unmeasured hunger confounding, following @confoundcheese2022.]
]

#lorem(100)

= Discussion

#lorem(80)

#passage(<r2-4>)[
  #rep[These results suggest that fridge-checking behavior causes an
  increase in perceived discovery probability.][These results are
  consistent with an association between fridge-checking behavior and
  perceived discovery probability, though the observational design and
  the absence of a formal blinding procedure for refrigerator contents
  limit causal interpretation.]
]

#lorem(90)

= Conclusion

#touched(<r1-8>)[
  Taken together, these findings suggest that the refrigerator door
  itself may function as an intermittent-reinforcement device, rewarding
  repeated checking with an occasional, genuinely novel discovery.
]

#passage(<r1-10>)[
  #add[As already noted in the introduction, this conclusion applies
  equally to the paired instance of the same reviewer comment discussed
  there.]
]
