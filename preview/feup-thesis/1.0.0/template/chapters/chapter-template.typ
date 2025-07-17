// Chapter template for FEUP thesis
// Copy this template to create new chapters

// Import chapter utilities (adjust path as needed)
//#import "@preview/feup-thesis:1.0.0" as feup

// For local development, use:
#import "@preview/feup-thesis:1.0.0" as feup

// Example chapter content
#heading(level: 1)[Your Chapter Title]

This is your chapter content. You can now use all the template utilities:

== Section Title

Regular content here.

=== Subsection

You can include figures:

//#figure(
//  image("../figures/your-image.png", width: 80%),
//  caption: [Your figure caption],
//) <fig:example>

You can use code blocks:

#feup.code-block(
```python
def example_function():
    return "Hello, world!"
```,
caption: "Example Python code"
)

You can create algorithms:

#feup.algorithm("Example Algorithm")[
  1. Initialize variables
  2. *for* each item *do*
     3. Process item
  4. *end for*
]

You can add epigraphs:

#feup.epigraph(
  "The best way to predict the future is to invent it.",
  "Alan Kay"
)

== References in Chapters

You can cite references like this: @reference-key

The bibliography will be included in the main document, not in individual chapters.
