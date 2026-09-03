#import "@preview/palimpsest:0.1.0": *

We thank both reviewers, and the editor, for their careful reading of
the manuscript. Below we address each comment in turn, with the
corresponding change cited by page number in the manuscript.

#reviewer(1)[

  #exchange(<r1-1>)[
    "Sign-off" needs an operational definition — in particular, please
    clarify whether a bare emoji reaction counts as one.
  ][
    We have added an explicit definition, following the corpus-based
    taxonomy of Cc and Bcc, which does include bare emoji reactions.

    #pinpoint(<r1-1>, excerpt: true)
  ]

  #exchange(<r1-2>)[
    A simple difference in proportions across sign-off groups does not
    account for confounding — recipient seniority and email length both
    plausibly affect both sign-off choice and reply probability.
  ][
    Agreed. We now use inverse probability weighting, with weights from
    a propensity score model for sign-off choice conditional on
    recipient seniority, email length, and day of week sent.

    #pinpoint(<r1-2>, excerpt: true, mode: "tracked")
  ]

  #exchange(<r1-3>)[
    Please also update the sign-off assignment model itself to match
    the revised analysis.
  ][
    Done; sign-off choice is now modeled explicitly as a logistic
    function of the covariates listed above. #pinpoint(<r1-3>)
  ]

  #exchange(<r1-4>)[
    Were message bodies actually read by the study team, or only
    metadata? This has ethical as well as methodological implications.
  ][
    Only metadata; we have kept this wording, which we believe is
    already explicit on this point.

    #pinpoint(<r1-4>, excerpt: true)
  ]

  #exchange(<r1-5>)[
    Table 1's "recipient is senior" figure for the "merci" group looks
    inconsistent with the number reported in the abstract — please
    reconcile.
  ][
    Thank you for catching this; the table has been corrected.

    #pinpoint(<r1-5>, excerpt: true)
  ]

  #exchange(<r1-6>)[
    The calibration equation appears to duplicate the sign-off
    assignment model once the latter is written on the logit scale —
    is it still needed?
  ][
    Good catch, it is not: once the assignment model is written
    directly on the logit scale, the calibration equation collapses to
    the same closed form, so we have removed it as redundant.

    #pinpoint(<r1-6>, excerpt: true)
  ]

  #exchange(<r1-7>)[
    An analysis of robustness to unmeasured confounding is missing —
    sender urgency in particular seems like an obvious candidate.
  ][
    We agree this was a gap and have added a sensitivity analysis for
    unmeasured caffeine confounding, cited in the manuscript, as a proxy
    for sender urgency. #pinpoint(<r1-7>)
  ]

  #exchange(<r1-8>)[
    The conclusion's framing of the emoji sign-off as "not a costless
    substitute" is memorable but should probably be tied more explicitly
    to the effect estimates — or else softened.
  ][
    We have reviewed this passage and, on balance, prefer to keep the
    wording as originally written.

    #pinpoint(<r1-8>, excerpt: true)
  ]

  #exchange(<r1-9>)[
    Please also report sensitivity to the email client used, in case
    client-side rendering of the emoji affects the outcome.
  ][
    This analysis was performed but, on reflection, is redundant with
    the caffeine-confounding sensitivity analysis and has been removed
    for concision.

    #pinpoint(<r1-9>, excerpt: true)
  ]

  #exchange(<r1-10>)[
    One comment, filed here for convenience even though it concerns two
    separate locations in the manuscript: the operational definition of
    "sign-off," introduced early on, should be explicitly reaffirmed in
    the conclusion.
  ][
    Addressed in both locations: #pinpoint(<r1-10>).

    Shown as two separate excerpts, one per location:

    #pinpoint(<r1-10>, excerpt: true)
  ]

]

#pagebreak()

#reviewer(2)[

  #exchange(<r2-1>)[
    The "Statistical analysis" heading should indicate that the analysis
    plan changed relative to what was originally registered.
  ][
    The heading has been updated accordingly.

    #pinpoint(<r2-1>, excerpt: true)
  ]

  #exchange(<r2-2>)[
    A subgroup analysis (recipient seniority, day sent, CC'd manager,
    email length) would help readers judge how broadly the main finding
    generalizes.
  ][
    A subgroup figure has been added, reporting the requested
    comparisons. #pinpoint(<r2-2>)
  ]

  #exchange(<r2-3>)[
    The "🙏" null-comparator sub-analysis is an unusual choice and,
    frankly, distracts from the paper's main contribution — consider
    removing it given the space constraints.
  ][
    We agree and have removed this sub-analysis in its entirety,
    including its figure and table.

    #pinpoint(<r2-3>, excerpt: true)
  ]

  #exchange(<r2-4>)[
    The discussion's causal language ("causes an increase") is stronger
    than the observational design supports, IPW notwithstanding.
  ][
    We have softened this to an associational claim and flagged residual
    confounding by unmeasured sender urgency, in the same spirit as our
    response to #xcomment(<r1-2>) on accounting for measured confounders.

    #pinpoint(<r2-4>, excerpt: true)
  ]

  #exchange(<r2-5>)[
    Using battery level as an instrument seems like a stretch — please
    justify the exclusion restriction more carefully, or drop this
    analysis.
  ][
    We have added an explicit statement of the exclusion restriction and
    a citation to prior work on battery-level instruments in applied
    econometrics; we believe the assumption, while unusual, is no less
    defensible than in other applications of the design.

    #pinpoint(<r2-5>)
  ]

  #exchange(<r2-6>)[
    The reply-type table should include a "reacted only, no reply"
    category — a thumbs-up reaction with no further text is common
    enough in our experience to warrant its own row.
  ][
    Added, at 7% of threads by the 48-hour mark.

    #pinpoint(<r2-6>, excerpt: true)
  ]

  #exchange(<r2-7>)[
    The reply-latency table duplicates what Figure 1 already shows and
    could be cut for space.
  ][
    Agreed that it's redundant with the figure; removed from the
    submitted manuscript. We've kept it visible in the tracked version
    below, for your convenience in checking it against the figure,
    rather than collapsing it to a bare note.

    #pinpoint(<r2-7>, excerpt: true, mode: "tracked")
  ]

]

#pagebreak()

#editor[

  #exchange(<e1>)[
    Please ensure that every figure and table added or modified in
    response to the reviewers is cited with a page number in this
    letter, per journal policy.
  ][
    Done throughout; see in particular the subgroup figure, referenced
    at #xref(<fig-forest>), and the reply-type table, referenced at
    #xref(<tab-replytype>).
  ]

]

== Author notes

The changes above address every reviewer and editor comment. Two
further, smaller notes are recorded here for transparency, even though
neither answers a specific reviewer comment.

#author("marcus")[

  #note(<marcus-1>)[
    While implementing the change requested in our response to
    #xcomment(<r1-2>), I checked covariate balance after weighting and
    added a note confirming adequate overlap.

    #pinpoint(<marcus-1>, excerpt: true)
  ]

]

#author("constance")[

  #note(<constance-1>)[
    Re-read the sign-off definition after the change above and confirm
    it still matches our extraction procedure.

    #pinpoint(<constance-1>)
  ]

]

== For the reviewers only

The table below summarizes, for the reviewers' convenience only, how
many comments from each reviewer led to an actual textual or figure/
table change in the manuscript, as opposed to a clarification with no
change — consistent with prior work on the sociology of email reply
latency #cite(<latency2018>, form: "prose").

#figure(
  table(
    columns: 3,
    table.header[Reviewer][Comments][Led to a change],
    [Reviewer 1], [10], [8],
    [Reviewer 2], [7], [7],
  ),
  caption: [Summary of comments and resulting changes, for the reviewers' convenience.],
) <tab-summary>

As shown in @tab-summary, the large majority of comments from both
reviewers led directly to a manuscript change, consistent with our own
prior finding that inbox behavior is, if nothing else, a reliable
trigger for further action #cite(<replyall2020>, form: "prose").

#letter-bibliography("/examples/emoji-email/responses.bib")
