# taskize

A Typst package for creating horizontal columned lists, similar to LaTeX's `tasks` package. Perfect for exercises, multiple-choice questions, and any content that benefits from a compact columned layout.

## Gallery

Click on an image to see the source code.

| | | | |
|:---:|:---:|:---:|:---:|
| [![Basic Tasks](gallery/basic.png)](gallery/basic.typ) | [![Math Exercises](gallery/math.png)](gallery/math.typ) | [![Custom Labels](gallery/labels.png)](gallery/labels.typ) | [![Styled Layout](gallery/styled.png)](gallery/styled.typ) |
| Basic Tasks | Math Exercises | Custom Labels | Styled Layout |
| [![Vertical Flow](gallery/vertical.png)](gallery/vertical.typ) | [![Column Spanning](gallery/span.png)](gallery/span.typ) | [![Bold Labels](gallery/bold.png)](gallery/bold.typ) | [![Resume Numbering](gallery/resume.png)](gallery/resume.typ) |
| Vertical Flow | Column Spanning | Bold Labels | Resume Numbering |

## Features

- **Indentation-independent parsing** - Output is completely independent of source code indentation
- **Horizontal flow layout** - Items flow left-to-right across columns (like LaTeX's tasks)
- **Flexible column counts** - 2, 3, 4 or any number of columns
- **Column spanning** - Items can span multiple columns using `(N)` syntax
- **Multiple label formats** - Alphabetic (`a)`, `A)`), numeric (`1)`, `(1)`), roman (`i)`, `I)`), bullets, or custom
- **Bold labels** - Make labels stand out with bold weight
- **Resume numbering** - Continue numbering across multiple task blocks
- **Two flow directions** - Horizontal (a b | c d) or vertical (a c | b d)
- **Global configuration** - Set defaults for all tasks in your document
- **Shorthand functions** - `tasks2`, `tasks3`, `tasks4` for quick column setup
- **Spacing & alignment controls** - Fine-grained gutters, label alignment, baselines, and block spacing

## Manual

A full manual is available in `docs/manual.pdf`, with a Typst source version in `docs/manual.typ`.

## Quick Start

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks[
  + First item
  + Second item
  + Third item
  + Fourth item
]
```

## Basic Usage

### Simple Two-Column Layout

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks[
  + $2 + 3 = ?$
  + $5 - 2 = ?$
  + $4 times 3 = ?$
  + $8 div 2 = ?$
]
```

### Three-Column Layout

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks(columns: 3)[
  + Option A
  + Option B
  + Option C
  + Option D
  + Option E
  + Option F
]
```

### Shorthand Functions

```typst
#import "@preview/taskize:0.2.6": tasks2, tasks3, tasks4

// Two columns
#tasks2[
  + Item 1
  + Item 2
]

// Three columns
#tasks3[
  + Item 1
  + Item 2
  + Item 3
]

// Four columns
#tasks4[
  + A
  + B
  + C
  + D
]
```

## Label Formats

### Built-in Formats

```typst
#import "@preview/taskize:0.2.6": tasks

// Lowercase letters with parenthesis (default)
#tasks(label: "a)")[+ One  + Two  + Three]

// Uppercase letters
#tasks(label: "A)")[+ One  + Two  + Three]

// Numbers with parenthesis
#tasks(label: "1)")[+ One  + Two  + Three]

// Numbers in parentheses
#tasks(label: "(1)")[+ One  + Two  + Three]

// Lowercase roman numerals
#tasks(label: "i)")[+ One  + Two  + Three]

// Uppercase roman numerals
#tasks(label: "I)")[+ One  + Two  + Three]

// Bullet points
#tasks(label: "*")[+ One  + Two  + Three]

// Dashes
#tasks(label: "-")[+ One  + Two  + Three]

// No labels
#tasks(label: none)[+ One  + Two  + Three]
```

### Custom Label Function

```typst
#import "@preview/taskize:0.2.6": tasks

// Custom emoji labels
#tasks(label: n => "Q" + str(n) + ":")[
  + What is 2+2?
  + What is the capital of France?
  + What color is the sky?
]
```

## Flow Direction

### Horizontal Flow (Default)

Items fill rows first: `a b | c d | e f`

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks(columns: 2, flow: "horizontal")[
  + a
  + b
  + c
  + d
  + e
  + f
]
// Layout:
// a)  b)
// c)  d)
// e)  f)
```

### Vertical Flow

Items fill columns first: `a c e | b d f`

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks(columns: 2, flow: "vertical")[
  + a
  + b
  + c
  + d
  + e
  + f
]
// Layout:
// a)  d)
// b)  e)
// c)  f)
```

## Resuming Numbering

```typst
#import "@preview/taskize:0.2.6": tasks, tasks-reset

#tasks[
  + First
  + Second
  + Third
]

Some text between task blocks...

// Continue numbering from where we left off
#tasks(resume: true)[
  + Fourth
  + Fifth
  + Sixth
]

// Reset counter to start fresh
#tasks-reset()

#tasks[
  + Back to one
  + Two again
]
```

## Starting from a Specific Number

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks(start: 5)[
  + This is item 5
  + This is item 6
  + This is item 7
]
```

## Global Configuration

Set defaults for all tasks in your document:

```typst
#import "@preview/taskize:0.2.6": tasks, tasks-setup

// Configure global defaults
#tasks-setup(
  columns: 3,
  label-format: "1)",
  column-gutter: 1.5em,
  row-gutter: 0.8em,
)

// All subsequent tasks use these defaults
#tasks[
  + Item 1
  + Item 2
  + Item 3
]

// Override specific settings per-call
#tasks(columns: 2, label: "a)")[
  + Override A
  + Override B
]
```

## Advanced Features

### Label Baseline Alignment

Control the vertical alignment of labels relative to content:

```typst
#import "@preview/taskize:0.2.6": tasks

// Center alignment (default)
#tasks(label-baseline: "center")[
  + Short item
  + Multi-line item\
    with more text
]

// Top alignment
#tasks(label-baseline: "top")[
  + Item aligned at top
  + Another item
]

// Bottom alignment
#tasks(label-baseline: "bottom")[
  + Item aligned at bottom
  + Another item
]
```

### Bold Labels

Make labels stand out by using bold weight:

```typst
#import "@preview/taskize:0.2.6": tasks

// Bold labels for emphasis
#tasks(label-weight: "bold")[
  + Important task
  + Critical item
  + Key point
]

// Regular labels (default)
#tasks(label-weight: "regular")[
  + Normal item
  + Standard task
]
```

### Column Spanning

Items can span multiple columns using the `+()` or `+(N)` syntax (no space after `+`). This is similar to LaTeX's `\task*` command:

```typst
#import "@preview/taskize:0.2.6": tasks

#tasks(columns: 3)[
  + Short
  + Short
  + Short
  +(2) This item spans 2 columns
  + Short
  +() This item spans all columns (full width)
  + Normal
  + Normal
]

// Practical example: Multiple choice with explanation
#tasks(columns: 2, label: "A)")[
  + Paris
  + London
  + Berlin
  + Madrid
  +() The capital of France is Paris, known for the Eiffel Tower.
]
```

**Syntax:**
- `+ Content` - Normal item (spans 1 column)
- `+(2) Content` - Spans 2 columns (no space after +)
- `+(3) Content` - Spans 3 columns
- `+() Content` - Spans all columns (full width)

**Notes:**
- **Important:** No space between `+` and `()` or `(N)`
- If an item with span doesn't fit in the current row, it wraps to the next row
- Column spans are clamped to the total number of columns
- Great for adding explanations, headings, or long content within lists

## Parameters Reference

### `tasks` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `columns` | int | 2 | Number of columns |
| `label` | string/function | `"a)"` | Label format (shorthand for `label-format`) |
| `label-format` | string/function | `"a)"` | Label format |
| `start` | int | 1 | Starting number for labels |
| `resume` | bool | false | Continue numbering from previous block |
| `column-gutter` | length | 1em | Space between columns |
| `row-gutter` | length | 0.6em | Space between rows |
| `label-width` | auto/length | auto | Width reserved for labels |
| `label-align` | alignment | right | Label alignment |
| `label-baseline` | string/length | `"center"` | Label vertical alignment: `"center"`, `"top"`, `"bottom"`, or length |
| `label-weight` | string | `"regular"` | Label font weight: `"regular"` or `"bold"` |
| `indent-after-label` | length | 0.4em | Space between label and content |
| `indent` | length | 0pt | Left indentation of entire block |
| `above` | length | 0.5em | Space before block |
| `below` | length | 0.5em | Space after block |
| `flow` | string | `"horizontal"` | Flow direction: `"horizontal"` or `"vertical"` |

### Label Format Options

| Format | Example | Description |
|--------|---------|-------------|
| `"a)"` | a) b) c) | Lowercase letters with closing paren |
| `"a."` | a. b. c. | Lowercase letters with period |
| `"(a)"` | (a) (b) (c) | Lowercase letters in parentheses |
| `"A)"` | A) B) C) | Uppercase letters with closing paren |
| `"A."` | A. B. C. | Uppercase letters with period |
| `"1)"` | 1) 2) 3) | Numbers with closing paren |
| `"1."` | 1. 2. 3. | Numbers with period |
| `"(1)"` | (1) (2) (3) | Numbers in parentheses |
| `"i)"` | i) ii) iii) | Lowercase roman numerals |
| `"I)"` | I) II) III) | Uppercase roman numerals |
| `"*"` | bullet | Bullet points |
| `"-"` | dash | En-dashes |
| `none` | (none) | No labels |
| function | custom | Custom function `n => content` |

## Examples

### Math Exercise Sheet

```typst
#import "@preview/taskize:0.2.6": tasks

= Algebra Practice

Simplify the following expressions:

#tasks(columns: 2)[
  + $x^2 + 2x + 1$
  + $(a + b)^2$
  + $3x - 5 + 2x + 8$
  + $frac(x^2 - 4, x - 2)$
]

Solve for $x$:

#tasks(columns: 2, label: "1)")[
  + $2x + 5 = 13$
  + $x^2 = 16$
  + $3(x - 2) = 15$
  + $frac(x, 4) = 7$
]
```

### Multiple Choice Questions

```typst
#import "@preview/taskize:0.2.6": tasks

*Question 1:* What is the capital of France?

#tasks(columns: 2, label: "A)")[
  + London
  + Paris
  + Berlin
  + Madrid
]

*Question 2:* Which planet is closest to the Sun?

#tasks(columns: 2, label: "A)")[
  + Venus
  + Mercury
  + Mars
  + Earth
]
```

### Vocabulary List

```typst
#import "@preview/taskize:0.2.6": tasks

= French Vocabulary

#tasks(columns: 3, label: none)[
  + *bonjour* - hello
  + *merci* - thank you
  + *oui* - yes
  + *non* - no
  + *s'il vous plait* - please
  + *au revoir* - goodbye
]
```

## When to Use taskize

**taskize** is specifically designed for **horizontal columned layouts** where items flow left-to-right across multiple columns, perfect for exercises, multiple-choice questions, and compact lists. Choose taskize when you need:

- **Horizontal flow layout** - Items arranged in rows across columns (a b | c d | e f)
- **Compact exercise sheets** - Mathematical exercises, vocabulary lists, multiple-choice questions
- **Flexible column control** - Easy 2, 3, 4+ column layouts with shorthand functions
- **Resume numbering** - Continue numbering across multiple task blocks
- **LaTeX tasks compatibility** - Familiar syntax for users migrating from LaTeX's tasks package

### Comparison with itemize

**[itemize](https://typst.app/universe/package/itemize)** is an excellent, feature-rich package for **vertical list styling** with advanced customization capabilities. Use itemize when you need:

- **Vertical lists** with advanced styling (colors, custom markers, spacing)
- **Nested lists** with sophisticated formatting
- **Rich marker customization** (emojis, custom content, per-item markers)
- **Advanced typography** control over list appearance
- **Complex list hierarchies** with fine-grained control

**In summary**: Use taskize for horizontal multi-column layouts (exercises, quizzes, compact lists), and use itemize for feature-rich vertical lists with advanced styling. They complement each other well for different layout needs.

## License

MIT License - see LICENSE file for details.

## Changelog

All notable changes to taskize are documented here.

### [0.2.6] - 2026-01-23

#### Added
- Full manual (`docs/manual.typ` + `docs/manual.pdf`) with structured examples
- Expanded gallery with styled configuration and resume numbering examples

#### Changed
- README gallery layout refreshed and feature list expanded
- Documentation updated for the new manual and examples

### [0.2.5] - 2026-01-20

#### Fixed
- **Indentation-independent parsing** - Tasks now render identically regardless of source code indentation
  - All `+` items at any indentation level in the same `tasks[]` block are automatically flattened to the same level
  - Inconsistent indentation no longer creates nested enums with different numbering
  - Moving one character in the source no longer breaks the layout
- **Column spanning support** - Fixed `+(2)` and `+()` syntax to work correctly with the new parser
  - Handles both `enum.item` nodes and text nodes starting with "+"

#### Changed
- Internal parser completely rewritten to recursively extract and flatten all enum items
- Parent items with nested enums (from indentation) have enum nodes stripped from their content

### [0.2.0] - 2026-01-15

#### Added
- **Column spanning** - Items can span multiple columns using `(N)` syntax (e.g., `+ (2) Content` or `+ () Full width`)
- `label-baseline` parameter for controlling vertical alignment of labels (`"center"`, `"top"`, `"bottom"`, or custom length)
- `label-weight` parameter for bold labels (`"regular"` or `"bold"`)
- Advanced Features section in documentation with examples
- Gallery examples for column spanning and bold labels

#### Changed
- Repository URL updated to GitLab: `https://gitlab.com/nathan-ed/typst-package-taskize`
- Description enhanced to mention "Horizontal and vertical" flow directions

### [0.1.0] - 2026-01-14

#### Added
- Initial release with horizontal columned list layout
- Flexible column counts (2, 3, 4, or custom)
- Multiple label formats (alphabetic, numeric, roman, bullets, custom)
- Resume numbering across multiple task blocks
- Two flow directions: horizontal (a b | c d) and vertical (a c | b d)
- Global configuration system with `tasks-setup()`
- Shorthand functions `tasks2`, `tasks3`, `tasks4`
- Comprehensive parameter customization
- Full documentation with examples and parameter reference
