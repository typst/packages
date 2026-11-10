#import "@preview/primeone:1.0.0": *

#show: article.with(
  title: "PrimeOne Template",
  subtitle: "Component Showcase & Demo",
  authors: (
    (name: "Jane Doe", affiliation: "University of Example", email: "jane@example.com"),
    (name: "John Smith", affiliation: "Institute of Design", email: "john@example.com"),
  ),
  date: "May 2, 2026",
  abstract: "This document demonstrates all available components and styling options of the PrimeOne Typst template.",
  abstract-title: "Abstract",
  titlepage: true,
  toc: true,
  toc-title: "Table of Contents",
  toc-depth: 2,
  theme: theme-lara-green
)

= Typography

== Headings

PrimeOne uses a three-level heading hierarchy. Each level has a distinct size, weight, and color to create clear visual structure throughout the document.

=== Level 3 Heading

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

== Body Text & Paragraphs

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper.

Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui.

= Code Blocks

== Syntax-Highlighted Code

Below is an example Python code block:

```python
import random

def number_guessing_game():
    print("Welcome to the Number Guessing Game!")
    print("I am thinking of a number between 1 and 100.")

    # The computer chooses a random number between 1 and 100
    secret_number = random.randint(1, 100)
    attempts = 0

    while True:
        try:
            # Ask for user input
            user_input = input("Please enter your guess: ")
            guess = int(user_input)
            attempts += 1

            # Check the guess
            if guess < 1 or guess > 100:
                print("Please stay within the range of 1 to 100!")
            elif guess < secret_number:
                print("Too low! Try again.")
            elif guess > secret_number:
                print("Too high! Try again.")
            else:
                print(f"Congratulations! You guessed the number {secret_number} in {attempts} attempts.")
                break # Exits the loop when the number is guessed

        except ValueError:
            # If the user enters something that isn't a valid number (e.g., letters)
            print("That was not a valid number. Please try again.")

# Start the program
if __name__ == "__main__":
    number_guessing_game()
```

== Inline Code

You can reference inline code such as `mean(x)` or variable names like `df_cleaned` within a sentence without breaking the reading flow.

= Tables

== Basic Table

#table(
  columns: 3,
  [*Name*], [*Role*], [*Location*],
  [Jane Doe], [Lead Researcher], [Vienna, AT],
  [John Smith], [Data Analyst], [Berlin, DE],
  [Maria Garcia], [Statistician], [Madrid, ES],
  [Luca Rossi], [Visualisation], [Milan, IT],
)

== Numeric Table

#table(
  columns: 4,
  [*Quarter*], [*Revenue*], [*Expenses*], [*Net*],
  [Q1 2025], [\$124,000], [\$98,000], [\$26,000],
  [Q2 2025], [\$138,500], [\$104,200], [\$34,300],
  [Q3 2025], [\$152,000], [\$111,800], [\$40,200],
  [Q4 2025], [\$179,300], [\$119,600], [\$59,700],
)

= Components

== Badges

Badges are small inline labels useful for status indicators, tags, or labels:

#badge("Info", severity: "info") #h(0.5em)
#badge("Success", severity: "success") #h(0.5em)
#badge("Warning", severity: "warning") #h(0.5em)
#badge("Error", severity: "error") #h(0.5em)
#badge("Neutral", severity: "neutral")

#v(1em)

Badges can also appear inline within text — for example, this feature is #badge("New", severity: "success") and this one is #badge("Deprecated", severity: "warning").

== Messages

The `message` component is a compact single-line alert:

#v(0.5em)
#message(severity: "info")[This is an informational message with useful context.]
#v(0.5em)
#message(severity: "success")[The operation completed successfully.]
#v(0.5em)
#message(severity: "warn")[Please review the settings before continuing.]
#v(0.5em)
#message(severity: "error")[An error occurred. Please check your input and try again.]
#v(0.5em)
#message(severity: "neutral")[This step is optional and can be skipped.]

== Messages (Block)

The `messages` component is a full-width block alert with an optional title and a left accent bar:

#v(0.5em)
#messages(severity: "info", title: "Information")[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
]
#v(0.5em)
#messages(severity: "success", title: "Success")[
  Your document has been saved. All changes are up to date and have been backed up automatically.
]
#v(0.5em)
#messages(severity: "warn", title: "Warning")[
  This action will overwrite existing data. Please make sure you have a backup before proceeding.
]
#v(0.5em)
#messages(severity: "error", title: "Error")[
  The connection to the server could not be established. Please check your network settings and try again.
]

== Cards

Cards are versatile containers for structured content:

#v(0.5em)
#card(
  title: "Research Summary",
  subtitle: "Preliminary Findings — Q1 2025",
  footer: "Last updated: May 2, 2026",
)[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante.
]

#v(1em)

Cards can also be placed side by side using a grid:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  card(title: "Dataset A")[
    Collected from 320 participants across three sites. Data cleaned and normalised prior to analysis.
  ],
  card(title: "Dataset B")[
    Secondary dataset sourced from public records. Merged with Dataset A using participant ID.
  ],
)

== Panels

Panels are simpler bordered containers, useful for grouped content or side notes:

#v(0.5em)
#panel(title: "Note")[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
]

#v(1em)

#panel()[
  A panel without a title is a plain bordered container — useful for callouts or highlighted sections.
]

== Checkboxes

Checkboxes can be used for checklists, requirements lists, or feature comparisons:

#v(0.5em)
#checkbox(label: "Data collection complete", checked: true)
#v(0.25em)
#checkbox(label: "Preprocessing pipeline verified", checked: true)
#v(0.25em)
#checkbox(label: "Model training complete", checked: false)
#v(0.25em)
#checkbox(label: "Results reviewed by co-authors", checked: false)
#v(0.25em)
#checkbox(label: "This step is not applicable", checked: false, disabled: true)

= Color Themes

The template ships with seven built-in color themes. Switch the active theme by changing one line at the top of `typst-template.typ`:

#table(
  columns: 2,
  [*Variable*], [*Primary Color*],
  [`theme-lara-cyan`], [#text(fill: rgb("#06b6d4"))[■] #h(0.25em) \#06b6d4],
  [`theme-lara-purple`], [#text(fill: rgb("#8b5cf6"))[■] #h(0.25em) \#8b5cf6],
  [`theme-lara-green`], [#text(fill: rgb("#10b981"))[■] #h(0.25em) \#10b981],
  [`theme-lara-blue`], [#text(fill: rgb("#3b82f6"))[■] #h(0.25em) \#3b82f6],
  [`theme-lara-teal`], [#text(fill: rgb("#14b8a6"))[■] #h(0.25em) \#14b8a6],
  [`theme-lara-indigo`], [#text(fill: rgb("#6366f1"))[■] #h(0.25em) \#6366f1],
  [`theme-lara-pink`], [#text(fill: rgb("#ec4899"))[■] #h(0.25em) \#ec4899],
)
