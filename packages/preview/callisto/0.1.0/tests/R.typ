#import "/src/callisto.typ" as callisto: *

#let render = callisto.render.with(nb: "/tests/notebooks/R.ipynb")

= First cell, choosing plain text
#render(0, format: "text/plain")
= First cell, preferring latex over markdown
#render(0, format: ("image/svg+xml", "image/png", "text/latex", "text/markdown"))
= Whole notebook, default config
(Markdown is used for the first cell but the Markdown code for the table is wrong.)

#render()


