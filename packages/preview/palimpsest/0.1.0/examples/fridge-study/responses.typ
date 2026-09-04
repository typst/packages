#import "@preview/palimpsest:0.1.0": *

We thank both reviewers, and the editor, for their careful reading of
the manuscript. Below we address each comment in turn, with the
corresponding change cited by page number in the manuscript.

#reviewer(1)[

  #exchange(<r1-1>)[
    "Fridge-checking" needs an operational definition, not just an
    intuitive label — otherwise readers cannot tell it apart from
    ordinary refrigerator use.
  ][
    We have added an explicit definition, following the Delphi consensus
    terminology of Ware and Crumb.

    #pinpoint(<r1-1>, excerpt: true)
  ]

  #exchange(<r1-2>)[
    A single logistic regression with one observation per household
    seems to discard information — weren't opening events logged daily
    over 30 days per household?
  ][
    Correct, and thank you for catching this. We now use generalized
    estimating equations to account for the repeated, within-household
    structure of the data, rather than collapsing to one observation per
    household.

    #pinpoint(<r1-2>, excerpt: true, mode: "tracked")
  ]

  #exchange(<r1-3>)[
    Please also update the model equation itself to match the revised
    analysis — a linear probability model for a probability outcome is
    not appropriate here.
  ][
    Done; the model is now written on the logit scale, with an added
    household-level random effect, numbered (1) in the manuscript:

    #pinpoint(<r1-3>, excerpt: true)
  ]

  #exchange(<r1-4>)[
    How were households actually recruited? "Flyers" alone is a bit
    vague for a methods section.
  ][
    We have kept this wording, which we believe is already sufficiently
    specific once the recruitment venues are listed.

    #pinpoint(<r1-4>, excerpt: true)
  ]

  #exchange(<r1-5>)[
    Table 1's household-size figure for the high tertile looks
    inconsistent with the number reported in the abstract — please
    reconcile.
  ][
    Thank you for catching this; the table has been corrected.

    #pinpoint(<r1-5>, excerpt: true)
  ]

  #exchange(<r1-6>)[
    The calibration equation appears to duplicate the main model
    equation once the model is refit on the logit scale — is it still
    needed?
  ][
    Good catch, it is not: once refit with a logit link, the calibration
    equation collapses to the same closed form as the model equation
    above, so we have removed it as redundant.

    #pinpoint(<r1-6>, excerpt: true)
  ]

  #exchange(<r1-7>)[
    An analysis of robustness to unmeasured confounding — hunger, in
    particular, given the subject matter — is missing.
  ][
    We agree this was a gap and have added a sensitivity analysis for
    unmeasured hunger confounding, cited in the manuscript.
    #pinpoint(<r1-7>)
  ]

  #exchange(<r1-8>)[
    The conclusion's "intermittent-reinforcement device" framing is
    memorable but should probably be tied more explicitly to the
    behavioral literature — or else softened.
  ][
    We have reviewed this passage and, on balance, prefer to keep the
    wording as originally written; we believe the framing is
    self-explanatory in context.

    #pinpoint(<r1-8>, excerpt: true)
  ]

  #exchange(<r1-9>)[
    Please also report sensitivity to the door-handle contamination
    threshold used to define a "genuine" opening event.
  ][
    This analysis was performed but, on reflection, is redundant with
    the hunger-confounding sensitivity analysis and has been removed for
    concision.

    #pinpoint(<r1-9>, excerpt: true)
  ]

  #exchange(<r1-10>)[
    One comment, filed here for convenience even though it concerns two
    separate locations in the manuscript: the operational definition of
    fridge-checking, introduced early on, should be explicitly
    reaffirmed in the conclusion, so that a reader who skips straight to
    the conclusion isn't left guessing what was actually measured.
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
    A subgroup analysis (pet ownership, household size, weekday versus
    weekend) would help readers judge how broadly the main finding
    generalizes.
  ][
    A subgroup figure has been added, reporting the requested
    comparisons. #pinpoint(<r2-2>)
  ]

  #exchange(<r2-3>)[
    The sock-drawer control group is an unusual choice and, frankly,
    distracts from the paper's main contribution — consider removing it
    given the space constraints.
  ][
    We agree and have removed this sub-analysis in its entirety,
    including its figure and table.

    #pinpoint(<r2-3>, excerpt: true)
  ]

  #exchange(<r2-4>)[
    The discussion's causal language ("causes an increase") is stronger
    than the observational design supports.
  ][
    We have softened this to an associational claim and noted the
    absence of a formal blinding procedure for refrigerator contents, in
    the same spirit as our response to #xcomment(<r1-2>) on accounting
    properly for the repeated-measures structure of the data.

    #pinpoint(<r2-4>, excerpt: true)
  ]

  #exchange(<r2-5>)[
    Theorem 1 is charming, but if it is to remain in a revised
    manuscript it should at least be given a name, so it can be cited by
    future work.
  ][
    We have named it the Second Law of Fridge Thermodynamics.
    #pinpoint(<r2-5>)
  ]

  #exchange(<r2-6>)[
    Table 2 (fridge discovery categories) should include an
    "unidentified frozen object" category — in our experience this is
    the single most common terminal state of a forgotten leftover.
  ][
    Added, at 3% of day-30 discoveries.

    #pinpoint(<r2-6>, excerpt: true)
  ]

  #exchange(<r2-7>)[
    The day-of-week discovery-rate chart doesn't add much beyond
    Figure 1's opening-frequency trend and could be cut for space.
  ][
    Agreed and removed from the submitted manuscript; still visible in
    the tracked version for reference. #pinpoint(<r2-7>)
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
    at #xref(<fig-forest>), and the discovery-categories table,
    referenced at #xref(<tab-discovery>).
  ]

]

== Author notes

The changes above address every reviewer and editor comment. Two
further, smaller changes were made on our own initiative during
revision, noted here for transparency even though neither answers a
specific reviewer comment.

#author("tupper")[

  #note(<tupper-1>)[
    While implementing the change requested in our response to
    #xcomment(<r1-2>), I noticed the household-level random effect
    variance was worth reporting explicitly, so I added it.

    #pinpoint(<tupper-1>, excerpt: true)
  ]

]

#author("ivana")[

  #note(<ivana-1>)[
    Re-read the fridge-checking definition after the change above and
    confirm it still matches our coding procedure.

    #pinpoint(<ivana-1>)
  ]

]

== For the reviewers only

The table below summarizes, for the reviewers' convenience only, how
many comments from each reviewer led to an actual textual or figure/
table change in the manuscript, as opposed to a clarification with no
change — consistent with the general observation that peer review of
a self-monitoring behavior tends to attract more critical attention
than the behavior itself #cite(<peek2015>, form: "prose").

// Captioned "Table R3", not "Table R1", even though this is the only
// table the letter adds on its own — the two tables quoted above
// (<r1-5>, <r2-6>, both pinpoint(excerpt: true)) now show the
// manuscript's own real numbers ("Table 1"/"Table 2") rather than "R"
// ones, but they still occupy the first two slots of the letter's own
// counter; only the *displayed* number changed, not how many slots a
// quoted table consumes. See docs/manual.typ, "Letter numbering".
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
prior finding that fridge-checking behavior is, if nothing else, a
reliable trigger for further action #cite(<snackwell2020>, form: "prose").

#letter-bibliography("/examples/fridge-study/responses.bib")
