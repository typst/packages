#import "@preview/palimpsest:0.1.0": *
#import "@preview/lilaq:0.6.0" as lq

// The two co-authors, so they can leave their own notes below alongside
// the reviewers' — Constance with an explicit color, Marcus with just a
// display name (still gets an automatic, distinct color).
#set-revisions(authors: (
  constance: (name: "Constance Reply-All", color: rgb("#0f766e")),
  marcus: "Marcus Cc",
))

// Shown only in manuscript-tracked.pdf (change-list() auto-hides in
// clean, see §7.3).
#change-list()

= Introduction

Professional email correspondence conventionally closes with a written
sign-off — "Best," "Regards," "Thank you" — that varies by sender,
recipient, and, increasingly, by whether the sender simply taps an
emoji instead of typing anything at all. Whether this choice has any
causal bearing on downstream communication outcomes has not, to our
knowledge, been formally evaluated.

#passage(<r1-1>)[
  We define a sign-off #add[, following the corpus-based taxonomy of
  @signoffnorms2021,] as any content appended after the substantive body
  of an email and before the sender's name, including a bare emoji
  reaction sent as the entirety of a reply.
]

#touched(<constance-1>)[
  We re-read this definition after the change above and confirm it
  still matches how sign-offs were actually coded during data
  extraction.
]

#passage(<r1-10>)[
  #add[This comment required a correction in two places in the
  manuscript — this sentence, in the introduction, and a matching one in
  the conclusion —] applies equally to both instances.
]

In this study, we estimate the causal effect of replying with a single
"👍" emoji, versus the written word "merci," on the probability of
receiving a further reply within 48 hours, using observational email
metadata and propensity score methods. Related work has examined
inbox behavior more broadly #cite(<replyall2020>), but has not isolated
the sign-off itself as a treatment.

#lorem(90)

= Methods

== Data source and study population

We analyzed metadata from 1,204 professional email threads across
six organizations, in which the final message before a 30-day
observation window ended with either a lone "👍" emoji, the word
"merci," or no sign-off at all (control). Threads involving fewer than
two participants, or in which the sender was on parental leave, were
excluded.

#touched(<r1-4>)[
  Metadata were extracted automatically from email headers and
  timestamps; message bodies were not read by the study team.
]

#lorem(60)

#passage(<r1-5>)[
  #figure(
    placement: auto,
    table(
      columns: 4,
      table.header[][*"👍"*][*"merci"*][*Control*],
      [Recipient is senior, %], [31], [#rep[42][47]], [38],
      [Email length, mean words], [58], [64], [61],
      [Sent on Friday, %], [22], [19], [24],
      [Sender battery level, mean %], [34], [71], [68],
    ),
    caption: [Baseline characteristics by sign-off group.],
  ) <tab-baseline>
]

As shown in @tab-baseline, senders who closed with a lone "👍" reported a
markedly lower average battery level at the time of sending than
senders who wrote "merci" or used no sign-off.

== #passage(<r2-1>)[Statistical analysis #add[(updated)]]

#passage(<r1-2>)[
  #rep[The reply rate was compared across sign-off groups using a simple
  difference in proportions.][The reply rate was compared across
  sign-off groups using inverse probability weighting
  #cite(<ipwmethod2019>), with weights derived from a propensity score
  model for sign-off choice conditional on recipient seniority, email
  length, and day of week sent.]
]

#passage(<r1-3>)[
  Sign-off choice
  #rep[was modeled directly as a function of recipient seniority.][was
  modeled as
  $ P("sign-off" = "👍" | X) \
    = "logit"^(-1)(beta_0 + beta_1 X_"sr" + beta_2 X_"len" + beta_3 X_"fri") $
  with $X$ the vector of measured covariates listed above.]
]

#passage(<marcus-1>)[
  #add[While implementing the change above, we also checked covariate
  balance across sign-off groups after weighting and found adequate
  overlap, with no standardized mean difference exceeding 0.1.]
]

#lorem(70)

#deleted(<r1-6>, summary: [the closed-form calibration equation, which
  became redundant once sign-off choice was modeled directly on the
  logit scale above])[
  For completeness, calibrated assignment probabilities were also
  computed directly as
  $ hat(p) = "expit"(hat(beta)_0 + hat(beta)_1 X_"senior") $
]

#lorem(50)

#passage(<r2-5>)[
  #add[As an instrumental-variable robustness check, we additionally
  used the sender's battery level at the time of sending as an
  instrument for sign-off choice, under the exclusion restriction that
  battery level affects reply probability only through its effect on
  sign-off choice #cite(<ivexclusion2020>).]
]

= Results

#lorem(60)

#figure(
  placement: auto,
  lq.diagram(
    width: 8cm,
    height: 5cm,
    xlabel: [Sign-off used],
    ylabel: [Reply within 48h (%)],
    yaxis: (lim: (0, 70)),
    xaxis: (ticks: ((1, "\"👍\""), (2, "\"merci\""), (3, "Control"))),
    lq.bar(
      (1, 2, 3),
      (41, 53, 35),
      fill: rgb("#6c8ebf"),
      width: 60%,
    ),
  ),
  caption: [Reply-within-48-hours rate, by sign-off used.],
) <fig-reply-rate>

#touched(<e1>)[
  @fig-reply-rate shows a higher raw reply rate for "merci" than for
  either "👍" or no sign-off, before any adjustment for confounding.
]

#lorem(70)

#passage(<r2-2>)[
  #add[
    #figure(
      placement: auto,
      lq.diagram(
        width: 7.5cm,
        height: 4.2cm,
        xlabel: [Odds ratio, "👍" vs. "merci" (95% CI)],
        xlim: (0, 3),
        yaxis: (
          ticks: (
            (1, "CC includes\nmanager"),
            (2, "Email length\n> 100 words"),
            (3, "Sent on\nFriday"),
            (4, "Recipient is\nsenior"),
          ),
          lim: (0.5, 4.5),
        ),
        lq.vlines(1, stroke: (paint: gray, dash: "dashed")),
        lq.plot(
          (0.6, 1.9, 0.9, 1.4),
          (1, 2, 3, 4),
          xerr: ((p: 0.3, m: 0.2), (p: 0.8, m: 0.6), (p: 0.5, m: 0.4), (p: 0.6, m: 0.5)),
          stroke: none,
          mark: "o",
        ),
      ),
      caption: [Subgroup odds ratios for the association between
      sign-off choice and reply within 48 hours.],
    ) <fig-forest>
  ]
]

#lorem(90)

#suppressed(
  <r2-3>,
  [Sub-analysis removed: the "🙏" sign-off as a null comparator,
  including its summary figure and table],
  summary: [the "🙏" null-comparator sub-analysis, including its figure
  and table],
)

#lorem(80)

#passage(<r2-6>)[
  #figure(
    placement: auto,
    table(
      columns: 3,
      table.header[Reply type][By 24h][By 48h],
      [Full-text reply], [29%], [38%],
      [One-word reply], [11%], [14%],
      [Emoji-only reply], [6%], [9%],
      // An ADDED row stays in both compiles (add[...] alone handles the
      // clean-vs-tracked styling) — no `if mode() == "clean" { () }
      // else {...}` gating, that pattern is for a row genuinely
      // absent from the submitted manuscript (a DELETED row, see
      // tests/marks-figures.typ), not an accepted addition. An earlier
      // version of this table wrongly hid this row from manuscript.pdf
      // entirely (see CLAUDE.md) — a real defect, since the row is
      // actually part of what's submitted, added in response to R2-6.
      add[Reacted only (no reply)], add[--], add[7%],
    ),
    caption: [Reply type breakdown, by 24 and 48 hours after the final message.],
  ) <tab-replytype>
]

As shown in @tab-replytype, the proportion of threads receiving a full-text
reply increased between the 24-hour and 48-hour marks.

#lorem(40)

#deleted(<r2-7>, summary: [the reply-latency table, redundant with @fig-reply-rate])[
  #figure(
    table(
      columns: 3,
      table.header[Sign-off][Median latency][IQR],
      [👍], [4.2h], [1.8--9.1h],
      [merci], [3.8h], [1.6--8.4h],
      [Control], [5.1h], [2.0--11.3h],
    ),
    caption: [Reply latency by sign-off group (median, IQR).],
  )
]

#lorem(40)

#suppressed(
  <r1-9>,
  [Sensitivity analysis removed: results by email client (Gmail, Outlook, Apple Mail)],
  summary: [the sensitivity analysis by email client],
)

#lorem(60)

#passage(<r1-7>)[
  #add[A sensitivity analysis was conducted to assess robustness to
  unmeasured caffeine confounding, following @caffeineconfound2023.]
]

#lorem(100)

= Discussion

#lorem(80)

#passage(<r2-4>)[
  #rep[These results suggest that replying "merci" causes an increase in
  the probability of a further reply, relative to a "👍"
  emoji.][These results are consistent with an association between
  sign-off choice and the probability of a further reply, though
  residual confounding by unmeasured aspects of sender urgency cannot be
  ruled out.]
]

#lorem(90)

= Conclusion

#touched(<r1-8>)[
  Taken together, these findings suggest that a lone "👍" emoji, while
  efficient, may not be a costless substitute for a written sign-off in
  professional correspondence.
]

#passage(<r1-10>)[
  #add[As already noted in the introduction, this conclusion applies
  equally to the paired instance of the same reviewer comment discussed
  there.]
]
