#import "@preview/cardinal-su-thesis:0.1.0": *

#chapter-title(short: [Writing a chapter])[Chapter 2]
= Writing a chapter with figures, tables, and mathematics

This chapter passes `short:` to `chapter-title`. The running head at the top of
subsequent pages therefore reads "Chapter 2. Writing a chapter" instead of
repeating the full title, which would otherwise overflow the line.

== Figures with separate legends

A dissertation figure usually needs a short title for the List of Figures and a
much longer legend beneath the figure itself. Putting the whole legend in
`caption:` would drag all of it into the List of Figures, so the template splits
the two: `caption:` holds the short title, and `fig-legend` immediately after
the figure holds the description. The caption prints the title above the legend,
so the legend does not repeat it.

#figure(
  image("../figures/figure-1.jpg", width: 100%),
  caption: [Three panels demonstrating the figure and legend pattern],
) <fig-example-one>
#fig-legend[
  *(a)* A scatter of simulated observations against the predicted trend.
  *(b)* Group means for six representative conditions. *(c)* Two fitted response
  curves, offset to show the effect of the shift parameter. All values are
  synthetic and exist only to populate the example ($n = 90$ points per panel).
]

Panel markers inside a legend are written plainly as `*(a)*`, since the caption
directly above already carries the figure number. To point at a panel from
running text, where the number is needed, use `figpanel`:
`figpanel(<fig-example-one>, [a])` renders as #figpanel(<fig-example-one>, [a]),
which stays correct even if the chapter is reordered and the figure renumbers.

Figures are numbered per chapter, so this is @fig-example-one rather than
"Figure 1". The counter resets at every level-1 heading, and appendix figures
switch to letter prefixes automatically.

#figure(
  image("../figures/figure-2.jpg", width: 90%),
  caption: [A two-panel figure at reduced width],
) <fig-example-two>
#fig-legend[
  *(a)* Fitted curves. *(b)* Residual scatter. Passing `width: 90%` to `image`
  scales the figure to a fraction of the text width; absolute lengths such as
  `12cm` also work.
]

Use JPEG for figures in the submitted file. The Registrar asks for JPEG or EPS
at 150 dpi, and notes that GIF and PNG are not preferred formats. Typst cannot
read EPS, so JPEG is the practical choice. PNG and SVG are fine while you are
drafting, and SVG in particular stays vector-sharp, but convert before you
submit if you want to follow the requirement exactly.

== Tables

Tables get their own counter and their own optional list in the preliminary
pages. Keep the caption above the table, as below.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    stroke: 0.5pt,
    table.header([*Condition*], [*Observations*], [*Mean*]),
    [Baseline], [120], [0.41],
    [Treatment A], [118], [0.63],
    [Treatment B], [121], [0.58],
    [Combined], [359], [0.54],
  ),
  caption: [Summary statistics for the example conditions],
) <tab-summary>

@tab-summary is referenced the same way as a figure. Single spacing is
acceptable inside tables even though the body text is one-and-a-half spaced.

== Mathematics

Inline mathematics such as $y = beta_0 + beta_1 x + epsilon$ sits in running
text. Display equations are set on their own line and can be numbered:

$ hat(beta) = (X^T X)^(-1) X^T y $ <eq-ols>

@eq-ols is the ordinary least squares estimator. Multi-line derivations align on
a marker:

$ cal(L)(theta) &= product_(i=1)^n p(x_i | theta) \
  log cal(L)(theta) &= sum_(i=1)^n log p(x_i | theta) $

If you use a mathematical font other than Symbol, the Registrar requires it to
be embedded in the submitted PDF. Typst embeds fonts automatically, so this is
handled for you.

== Code and verbatim text

Raw blocks are useful for commands, configuration, and short listings:

```python
def running_mean(values, window):
    """Return the trailing mean over a fixed window."""
    out = []
    for i in range(len(values)):
        lo = max(0, i - window + 1)
        out.append(sum(values[lo:i + 1]) / (i - lo + 1))
    return out
```

Inline raw text such as `--threshold 0.5` uses single backticks.

== Spelling out URLs

Clickable links are allowed, but the Registrar asks that you spell each URL out
in full rather than hiding it behind link text, so that a reader of the printed
page can still follow it: https://www.stanford.edu

== Pointing at supplementary material

Long methods, supporting notes, and large data tables belong in an appendix.
Refer to them from the main text by label: the parameter listing is
@supp-tab-parameters, the discussion of naming conventions is
@supp-note-conventions, and the procedure is described in @method-preparation.
