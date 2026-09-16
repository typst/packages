// Rendered through the template's `appendix` slot: this appears after the
// references, with letter-numbered headings (A, A.1, ...).

= Supplementary material

Use the appendix for material that supports the thesis but would interrupt the
main text: extended tables, additional figures, derivations, questionnaires, or
notes on where to find your code and data. Appendix headings are lettered
(A, A.1, A.2, ...) so they are clearly distinct from the numbered chapters.

== Code and data availability

If your work involves software or data, state clearly where a reader can find
it. A short, direct pointer is usually enough:

#align(center)[
  #link("https://github.com/your-handle/your-project")
]

== Reproducing an analysis

You can also record the exact commands used to produce a result, so it can be
reproduced. Longer listings render in a shaded code block:

```sh
# Example: regenerate the processed dataset from the raw input
python scripts/build_dataset.py \
    --input data/raw.tsv \
    --threshold 0.80 \
    --output data/processed.tsv
```

Add as many appendix sections as you need; each new level-one heading in this
file becomes the next lettered appendix (B, C, ...).
