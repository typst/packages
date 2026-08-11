#import "/src/exercise.typ": project, subtask, task
#import "/src/elements.typ": definition, example, hint, notice

#show: project.with(
    type: [Color Demo],
    no: 1,
    title: [Custom Color Demonstration],
    author: [Grape Suite],
    date: datetime.today(),

    // Custom color scheme - University branding example
    colors-primary: rgb("#1a472a"), // Cool shade of green that I like
    colors-accent: rgb("#2e8b57"), // Sea green
    colors-highlight: rgb("#ff6347"), // Tomato red
    colors-warning: rgb("#ffa500"), // Orange
    colors-warning-dark: rgb("#d2691e"), // Chocolate

    show-hints: false,
    show-solutions: false,
)

= Introduction

This document demonstrates the *color customization feature* of Grape Suite. Notice how all colors match the custom theme defined in the template setup.

The heading above uses the `colors-primary` parameter. Links like #link("https://example.com")[this one] also use the primary color.

== Color Parameters Overview

The following color parameters are available:
- `colors-primary`: Headings, links, lines
- `colors-accent`: Task boxes
- `colors-highlight`: Definitions and notices
- `colors-warning`: Hints and examples

= Task Demonstrations

#task(
    title: [Task Box Colors],
    [Solve the following problem.],
)[
    Task boxes use the accent color for borders and the primary color for the title text.

    #subtask(points: 5)[
        Part A: Notice the accent-light color in the background.
    ]

    #subtask(points: 5)[
        Part B: The points distribution uses these colors too.
    ]
]

#task(
    points: 5,
    title: [Another Task],
    [Complete this exercise.],
)[
    All task-related elements maintain visual consistency with your chosen color scheme.
]

= Element Boxes

#definition[
    *Definition boxes* use the `colors-highlight` parameter for their border and title, with a lighter shade for the background.

    This makes important definitions stand out visually.
]

#notice[
    *Notice boxes* also use the highlight color scheme but with a dotted border to differentiate them from definitions.
]

#hint[
    *Hint boxes* use the `colors-warning` parameter (orange tones by default) to indicate helpful information without being as prominent as definitions.
]

#example[
    *Example boxes* use the warning color scheme with a dotted border, making them visually distinct from hints.

    $ f(x) = x^2 + 2x + 1 $
]

= Color Consistency

Notice how all visual elements work together:
- Headers and footers use the primary color
- The separator lines use the primary color
- All box elements coordinate with the chosen palette
- The overall design remains cohesive and professional

== Subheading Example

Even nested headings maintain the color theme, with heading numbers displayed in a lighter shade of the primary color.

= Conclusion

The color customization feature allows you to:

1. Match institutional branding requirements
2. Create visually distinct document types
3. Maintain accessibility with your color choices
4. Keep consistent styling across all document elements

All while preserving the clean, professional design of Grape Suite templates.
