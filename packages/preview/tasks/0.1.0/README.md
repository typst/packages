# tasks

A Typst package for creating horizontal columned lists, similar to LaTeX's `tasks` package. Perfect for exercises, multiple-choice questions, and any content that benefits from a compact columned layout.

## Gallery

Click on an image to see the source code.

| | | |
|:---:|:---:|:---:|
| [![Basic Tasks](gallery/basic.png)](gallery/basic.typ) | [![Math Exercises](gallery/math.png)](gallery/math.typ) | [![Custom Labels](gallery/labels.png)](gallery/labels.typ) |
| Basic Tasks | Math Exercises | Custom Labels |
| [![Vertical Flow](gallery/vertical.png)](gallery/vertical.typ) | [![Resume Numbering](gallery/resume.png)](gallery/resume.typ) | [![Styled](gallery/styled.png)](gallery/styled.typ) |
| Vertical Flow | Resume Numbering | Styled Tasks |

## Features

- **Horizontal flow layout** - Items flow left-to-right across columns (like LaTeX's tasks)
- **Flexible column counts** - 2, 3, 4 or any number of columns
- **Multiple label formats** - Alphabetic (`a)`, `A)`), numeric (`1)`, `(1)`), roman (`i)`, `I)`), bullets, or custom
- **Resume numbering** - Continue numbering across multiple task blocks
- **Two flow directions** - Horizontal (a b | c d) or vertical (a c | b d)
- **Global configuration** - Set defaults for all tasks in your document
- **Shorthand functions** - `tasks2`, `tasks3`, `tasks4` for quick column setup

## Quick Start

```typst
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks

#tasks[
  + $2 + 3 = ?$
  + $5 - 2 = ?$
  + $4 times 3 = ?$
  + $8 div 2 = ?$
]
```

### Three-Column Layout

```typst
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks2, tasks3, tasks4

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
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks, tasks-reset

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
#import "@preview/tasks:0.1.0": tasks

#tasks(start: 5)[
  + This is item 5
  + This is item 6
  + This is item 7
]
```

## Global Configuration

Set defaults for all tasks in your document:

```typst
#import "@preview/tasks:0.1.0": tasks, tasks-setup

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
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks

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
#import "@preview/tasks:0.1.0": tasks

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

## License

MIT License - see LICENSE file for details.
