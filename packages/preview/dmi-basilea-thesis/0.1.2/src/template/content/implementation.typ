#import "@preview/dmi-basilea-thesis:0.1.2": *

// Or for local development
// #import "../../main.typ": *

= Implementation <implementation>

== Text Formatting

=== Basic Formatting
You can use *bold text* for emphasis, _italic text_ for titles or foreign words, and `inline code` for technical terms. The template also supports #smallcaps[small capitals] for certain stylistic choices.

Footnotes are created using the `#footnote` function#footnote[This is an example footnote. Footnotes are automatically numbered and appear at the bottom of the page.]. You can add them anywhere in your text#footnote[Multiple footnotes on the same page are handled automatically.].

For URLs, you have several options:
- Direct URL: https://www.unibas.ch
- Linked text: #link("https://www.unibas.ch")[University of Basel]

=== Lists and Enumerations
Bullet points are created naturally:
- First item
- Second item with sub-items:
  - Sub-item A
  - Sub-item B
- Third item

Numbered lists work similarly:
1. First step
2. Second step
3. Final step

== Code Listings

Code blocks are beautifully formatted with syntax highlighting:

```python
def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

For inline code, simply use backticks: `let x = 42`.

== Mathematical Formulas

Typst excels at mathematical typesetting. Here's the famous Euler's identity:

$ e^(i pi) + 1 = 0 $

More complex equations can be displayed prominently:

$ integral_0^infinity e^(-x^2) d x = sqrt(pi)/2 $

You can also create aligned equations:

$ sum_(k=1)^n k &= 1 + 2 + 3 + ... + n \
                &= (n(n+1))/2 $

== Figures and Tables
Figures can be inserted with captions and labels for cross-referencing:

#figure(
  image("../img/typst.png", width:80%),
  caption: [Example figure showing the template's figure environment]
) <fig:example>

As shown in @fig:example, figures are automatically numbered and can be referenced throughout the document.

Tables are equally straightforward:

#figure(
  table(
    columns: 3,
    align: (left, center, right),
    [*Language*], [*Type System*], [*Performance*],
    [Typst], [Static], [Fast],
    [LaTeX], [Macro-based], [Slow],
    [Markdown], [None], [Very Fast],
  ),
  caption: [Comparison of different markup languages]
) <tab:comparison>

@tab:comparison demonstrates the three-column table format with different alignments.

== Custom Environments

The template provides several custom environments for academic writing:

#definition(title: "Definition 1")[
  A *markup language* is a text-encoding system consisting of a set of symbols inserted in a text document to control its structure, formatting, or the relationship between its parts.
]

#theorem(title: "Theorem 1")[
  For any typesetting system $T$, if $T$ is both powerful and user-friendly, then $T$ will eventually replace less user-friendly alternatives.
]

== Multi-Column Layout

#columns(2)[
  Sometimes you need to present content in multiple columns. This is particularly useful for:

  - Comparing two approaches
  - Presenting definitions side by side
  - Creating compact layouts for listings

  #colbreak()

  The column break command `#colbreak()` allows you to manually control where the column break occurs, giving you precise control over the layout.
]

== Algorithms

#algorithm(
  caption: [Binary search algorithm]
)[
```
function binarySearch(arr, target):
    left = 0
    right = length(arr) - 1

    while left <= right:
        mid = (left + right) / 2
        if arr[mid] == target:
            return mid
        else if arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1

    return -1
```
]

== Citations and References

Citations are handled naturally using the \@ symbol: @turing1950 for single citations or @goodfellow2016 @vaswani2017 for multiple. The bibliography style can be customized in the main document.

== Draft Features

#context {
  if thesis-draft-state.get() [
    The template includes helpful TODO markers for draft versions:

    #todo[Add more examples here]
    #todo-missing[Include performance benchmarks]
    #todo-check[Verify this equation]
    #todo-revise[Improve this explanation]
    #todo-citation[Add proper reference]
    #todo-language[Check grammar]
    #todo-question[Is this the best approach?]
    #todo-note[Remember to update this section]
  ] else [
    TODO markers are only visible in draft mode. Set `draft: false` in your document configuration to hide them in the final version.
  ]
}

== Cross-References

The template supports automatic cross-referencing for all numbered elements. You can reference:
- Chapters: @methodology
- Sections: @background
- Figures: @fig:example
- Tables: @tab:comparison
- Equations: $ F = m a $ <eq:newton>
- Custom labels: @eq:newton

== Highlighting

Use the #important[important] function to highlight crucial information. In colored mode, this appears as highlighted text; in non-colored mode, it becomes italicized.

== Page Layout Features

The template automatically handles:
- Chapter pages without headers
- Consistent margins and spacing
- Proper page numbering
- Language-specific formatting (English/German)

All these features work together to create a professional, consistent document that meets academic standards while being easy to write and maintain.
