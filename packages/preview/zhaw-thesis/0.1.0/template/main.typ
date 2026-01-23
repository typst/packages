#import "@preview/zhaw-thesis:0.1.0": *
#import "glossary.typ": myGlossary

#show: zhaw-thesis.with(
  language: languages.en,
  cover: (
    school: "Engineering",
    institute: "Computer Science",
    work-type: "Bachelor thesis",
    title: "ZHAW Thesis Template",
    authors: ("Alice Müller", "Bob Schmidt"),
    supervisors: ("Prof. Dr. Charlie Meier",),
    study-program: "Computer Science B.Sc.",
  ),
  abstract: (
    keywords: ("template", "typst", "zhaw", "thesis"),
    de: "Diese Vorlage dient als Demonstration der Funktionen von Typst und der Struktur einer Abschlussarbeit an der ZHAW. Sie umfasst Beispiele für Querverweise, ein Glossar, ein Literaturverzeichnis, mathematische Gleichungen und Codeausschnitte.",
    en: "This template serves as a demonstration of Typst features and the structure of a thesis at ZHAW. It includes examples of cross-references, a glossary, bibliography, mathematical equations, and code snippets.",
  ),
  declaration-of-originality: (
    location: "Zürich",
  ),
  glossary-entries: myGlossary,
  biblio: (
    file-path: "/template/biblio.bib",
    style: "ieee",
  ),
  appendix: [#include "appendix.typ"],
)

// Below you can write your thesis. It's recommended to create separate files for each chapter and include them here using #include "path/to/chapter.typ".

= Introduction <intro>

This document serves as a demo of both Typst features and the template itself.

== What is Typst?

#link("https://typst.app/", "Typst") is a modern typesetting system that combines the simplicity of Markdown with the power of LaTeX. It allows you to create beautiful documents with ease, keeping styling separate from content.

== Is Typst better than Latex?

That's subjective, but:
- it compiles much faster and provides real-time preview (no compilation delays)
- its syntax is much nicer to write and look at
- it has built-in support for features that require packages in LaTeX (bibliography, cross-references, glossary, code snippets, etc.)
- its web editor works better than Overleaf

= Features showcase <features>

== Glossary, references and labels

Here we have a glossary reference: @iot:long. We can also use the acronym form: @iot:short. See the #link("https://typst.app/universe/package/glossy/", "Glossy") documentation for more details.

Here we refer to a source from our bibliography @garcia2021microservices. The template uses IEEE style by default, but you can change it with the `bibliography-style` option in `zhaw-thesis.with()`.

We can also refer to equations, such as @eq:weights, and figures, such as @tab:results.

Finally, here we refer to a section: @intro.

== Maths

$
  f(x) & = sigma(W_L sigma(W_(L-1) dots sigma(W_1 x + b_1) dots + b_(L-1)) + b_L) \
       & = (sigma dot W_L dot sigma dot W_(L-1) dot dots dot sigma dot W_1)(x, b_1, dots, b_L)
$ <eq:weights>

The equation above (@eq:weights) shows the forward pass of a neural network with $L$ layers, weights $W_i$, biases $b_i$, and activation function $sigma$.

Equations can also be inline: $V_k^* (s) = max_a sum_(s') underbrace(P(s' | s, a), "transition proba") lr((underbrace(r_(t+1), "reward s" arrow "s'") + gamma underbrace(V_(k-1)^* (s'), "precalc. val of s'")), size: #40%)$.

== Figures

Figures allow to wrap images, tables, code snippets, and more in captions and labels that you can refer to.

=== Tables

#figure(
  table(
    columns: 3,
    align: (left, center, right),
    [Metric], [Best Value], [Interpretation],
    [Precision], [1.0], [All predictions are correct],
    [Recall], [1.0], [All targets are found],
    [$F_1$ Score], [1.0], [Perfect balance],
    [False Positive Rate], [0.0], [No false alarms],
  ),
  caption: "Table with custom alignment",
) <tab:metrics>

#figure(
  {
    show table.cell.where(y: 5): strong
    table(
      columns: (2fr, 1fr, 1fr, 1fr, 1fr),
      align: (left, center, center, center, center),
      [Approach], [Speed], [Beauty], [Ease], [Overall],
      [Word], [0.2], [0.3], [0.7], [0.4],
      [LaTeX], [0.3], [0.9], [0.3], [0.5],
      [Markdown], [0.9], [0.4], [0.9], [0.7],
      [Google Docs], [0.7], [0.2], [0.8], [0.6],
      [Typst], [0.95], [0.98], [0.92], [0.95],
    )
  },
  caption: "Table that spans full width",
) <tab:results>

=== Code

@code:detection below shows how code snippets look like. This is handled by the #link("https://typst.app/universe/package/codly/", "Codly") package, which provides many customisation options.

#figure(
  ```python
  import numpy as np
  from sklearn.preprocessing import StandardScaler
  from sklearn.ensemble import IsolationForest

  class Model:
      def __init__(self, temp=1):
          self.scaler = StandardScaler()
          self.excitement = IsolationForest(
              temp=temp,
              random_state=42
          )
  ```,
  caption: "Sample code demonstrating syntax highlighting and professional formatting",
) <code:detection>

#callout(
  "In summary",
)[
  This template showcases:

  + Cross-references to sections, equations, tables, and figures
  + Glossary integration with short (@ML:short) and long (@ntp:long) forms
  + Bibliography citations @garcia2021microservices
  + Mathematical equations with proper labeling
  + Code listings with syntax highlighting
  + Professional tables and figures
]
