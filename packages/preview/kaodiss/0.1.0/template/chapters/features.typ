#import "@preview/kaodiss:0.1.0": *

= Code and Other Elements <ch:features>

== Code Listings

Code blocks are set in a small monospaced font with line numbers and the
colours of the Pygments default style, framed by two rules. In a figure, the
caption is set in the margin next to the first line (@lst:wordcount).

#figure(
  ```python
  # wordcount.py
  from collections import Counter
  from pathlib import Path

  def word_count(path: Path) -> Counter:
      """Count the words in a text file."""
      words = path.read_text(encoding="utf-8").split()
      return Counter(w.strip(".,;:!?").lower() for w in words)

  if __name__ == "__main__":
      print(word_count(Path("chapter.typ")).most_common(10))
  ```,
  caption: [A small Python script that counts the words of a chapter.],
) <lst:wordcount>

Inline code such as `word_count` is slightly smaller than the text.

== Notes in the Margin

Besides numbered sidenotes, `#marginnote` puts unnumbered notes into the
margin.#marginnote[An unnumbered margin note. Notes never overlap: if two notes
would collide, the second one is moved down.] During writing, `#todo` marks
open points in red.#todo[Check the numbers in this section.]

== Cross-References

References to chapters, sections, figures, tables, listings and equations use
Typst's `@label` syntax: @ch:introduction, @sec:writing, @fig:example,
@tab:example, @lst:wordcount and @eq:gauss.

== Draft Mode

With `draft: true` the template shows the text block and the margin column as
thin frames. #lorem(80)
