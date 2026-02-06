#import "@preview/classicthesis:0.1.0": *

#show: classicthesis.with(
  title: "Your Book Title",
  subtitle: "A Subtitle for Your Work",
  author: "Your Name",
  date: "2025",
  // Optional: dedication and abstract
  // dedication: [To those who seek elegant typography.],
  // abstract: [This is the abstract of your work...],
)

// ============================================================================
// Part I
// ============================================================================

#part(
  "Getting Started",
  preamble: [
    This part introduces the fundamentals. You can add a preamble
    to each part that appears on the part title page.
  ]
)

= Introduction

This is your first chapter. ClassicThesis uses spaced small caps for
chapter and section headings, following the typographic principles
outlined in Robert Bringhurst's _The Elements of Typographic Style_.

== Your First Section

Here's some example text. Notice how the section heading uses
elegant spaced small caps.

=== A Subsection

Subsections use italic text for a subtle hierarchy.

#definition(title: "Important Concept")[
  A definition block with a distinctive left border. Use this to
  define key terms in your work.
]

#theorem(title: "Main Result")[
  A theorem block for stating important results. The numbering
  is automatic.
]

#example(title: "Practical Application")[
  An example block with a subtle gray background. Use this to
  illustrate concepts with concrete examples.
]

#remark()[
  A remark block for additional observations or notes that don't
  fit the formal structure of theorems and definitions.
]

== Code Examples

Inline code looks like `this`, and code blocks are formatted cleanly:

```python
def hello_world():
    """A simple function."""
    print("Hello, ClassicThesis!")
```

== Tables and Figures

#figure(
  table(
    columns: (auto, auto, auto),
    table.header([*Item*], [*Description*], [*Value*]),
    [Alpha], [First item], [100],
    [Beta], [Second item], [200],
    [Gamma], [Third item], [300],
  ),
  caption: [A sample table with clean styling.],
)

// ============================================================================
// Part II
// ============================================================================

#part("Advanced Topics")

= Another Chapter

Continue your document with more chapters. Each chapter starts
on a new page with the elegant ClassicThesis heading style.

== References and Citations

Add your bibliography and citations as needed.

= Conclusion

Wrap up your work with a conclusion chapter.
