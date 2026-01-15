# exercise-bank

A comprehensive Typst package for creating and managing exercises with solutions, metadata, filtering, and exercise banks. Perfect for teachers, textbook authors, and educational content creators.

## Gallery

Click on an image to see the source code.

| | | |
|:---:|:---:|:---:|
| [![Basic Exercises](gallery/basic.png)](gallery/basic.typ) | [![With Solutions](gallery/solutions.png)](gallery/solutions.typ) | [![Exercise Bank](gallery/bank.png)](gallery/bank.typ) |
| Basic Exercises | With Solutions | Exercise Bank |
| [![Filtering](gallery/filtering.png)](gallery/filtering.typ) | [![Competencies](gallery/competencies.png)](gallery/competencies.typ) | [![End of Section](gallery/end-section.png)](gallery/end-section.typ) |
| Filtering by Topic | Competency Tags | Solutions at End |

## Features

- **Exercises with solutions** - Create exercises with inline or deferred solutions
- **Multiple solution modes** - Show solutions inline, at end of section/chapter, or hide them
- **Metadata support** - Tag exercises with topic, level, author, and custom fields
- **Exercise banks** - Define exercises once, display them anywhere
- **Powerful filtering** - Select exercises by topic, level, competency, or custom criteria
- **Competency tags** - Tag and display competency indicators
- **Automatic numbering** - Counter resets per section, chapter, or globally
- **Customizable labels** - Change "Exercise" and "Solution" labels (localization support)
- **Exercise IDs** - Unique identifiers for referencing and bank management

## Quick Start

```typst
#import "@preview/exercise-bank:0.2.0": exo

#exo(
  exercise: [
    Solve the equation $2x + 5 = 13$.
  ]
)
```

## Basic Usage

### Simple Exercise

```typst
#import "@preview/exercise-bank:0.2.0": exo

#exo(
  exercise: [
    Calculate $3 + 4 times 2$.
  ]
)
```

### Exercise with Solution

```typst
#import "@preview/exercise-bank:0.2.0": exo

#exo(
  exercise: [
    Calculate $3 + 4 times 2$.
  ],
  solution: [
    $3 + 4 times 2 = 3 + 8 = 11$
  ],
)
```

### Multiple Exercises

```typst
#import "@preview/exercise-bank:0.2.0": exo

#exo(exercise: [Simplify $x^2 + 2x + 1$.])
#exo(exercise: [Factor $x^2 - 4$.])
#exo(exercise: [Solve $2x - 6 = 0$.])
```

## Solution Display Modes

Control how and where solutions appear in your document.

### Inline Solutions (Default)

Solutions appear immediately after each exercise:

```typst
#import "@preview/exercise-bank:0.2.0": exo, exo-setup

#exo-setup(solution-mode: "inline")

#exo(
  exercise: [Solve $2x + 5 = 13$.],
  solution: [The answer is $x = 4$.],
)
```

### No Solutions

Hide all solutions:

```typst
#import "@preview/exercise-bank:0.2.0": exo, exo-setup

#exo-setup(solution-mode: "none")

#exo(
  exercise: [Solve this equation.],
  solution: [Hidden solution],
)
```

### Solutions at End of Section

Collect solutions and display them at section end:

```typst
#import "@preview/exercise-bank:0.2.0": exo, exo-setup, exo-print-solutions

#exo-setup(solution-mode: "end-section")

#exo(exercise: [Exercise 1], solution: [Answer 1])
#exo(exercise: [Exercise 2], solution: [Answer 2])
#exo(exercise: [Exercise 3], solution: [Answer 3])

// Print all collected solutions
#exo-print-solutions()
```

### Solutions at End of Chapter

Similar to end-section, but grouped by chapter:

```typst
#import "@preview/exercise-bank:0.2.0": exo, exo-setup, exo-print-solutions, exo-chapter-start

#exo-setup(solution-mode: "end-chapter")

= Chapter 1
#exo-chapter-start()

#exo(exercise: [Exercise 1.1], solution: [...])
#exo(exercise: [Exercise 1.2], solution: [...])

#exo-print-solutions(title: "Chapter 1 Solutions")

= Chapter 2
#exo-chapter-start()

#exo(exercise: [Exercise 2.1], solution: [...])
```

### Solutions Only

Show only the solutions (useful for answer keys):

```typst
#import "@preview/exercise-bank:0.2.0": exo, exo-setup

#exo-setup(solution-mode: "only")

#exo(exercise: [This exercise text is hidden], solution: [This will be shown])
```

## Metadata and Filtering

### Adding Metadata

Tag exercises with metadata for organization and filtering:

```typst
#import "@preview/exercise-bank:0.2.0": exo

#exo(
  exercise: [Solve $x + 1 = 5$.],
  topic: "algebra",
  level: "easy",
  authors: ("Prof. Smith",),
)

#exo(
  exercise: [Calculate the area of a circle with radius 5.],
  topic: "geometry",
  level: "medium",
  authors: ("Prof. Jones",),
)

#exo(
  exercise: [Solve $x^3 - 6x^2 + 11x - 6 = 0$.],
  topic: "algebra",
  level: "hard",
  authors: ("Prof. Smith",),
)
```

### Filtering Exercises

Display only exercises matching certain criteria:

```typst
#import "@preview/exercise-bank:0.2.0": exo, exo-filter

// First, define exercises (they display normally)
#exo(exercise: [Exercise 1], topic: "algebra")
#exo(exercise: [Exercise 2], topic: "geometry")
#exo(exercise: [Exercise 3], topic: "algebra")

// Later, filter and redisplay specific exercises
#exo-filter(topic: "algebra")  // Shows exercises 1 and 3
```

## Exercise Banks

Define exercises once, use them anywhere. Perfect for creating exercise collections.

### Defining Bank Exercises

```typst
#import "@preview/exercise-bank:0.2.0": exo-define

// These don't display - just registered
#exo-define(
  id: "quad-1",
  exercise: [Solve $x^2 - 5x + 6 = 0$.],
  topic: "quadratics",
  level: "1M",
  solution: [$x = 2$ or $x = 3$],
)

#exo-define(
  id: "quad-2",
  exercise: [State the quadratic formula.],
  topic: "quadratics",
  level: "2M",
  solution: [$x = frac(-b plus.minus sqrt(b^2 - 4a c), 2a)$],
)

#exo-define(
  id: "geom-1",
  exercise: [Find the area of a circle with radius 5.],
  topic: "geometry",
  level: "1M",
  solution: [$A = pi r^2 = 25pi$],
)
```

### Displaying Bank Exercises

```typst
#import "@preview/exercise-bank:0.2.0": exo-show, exo-show-many

// Show a single exercise by ID
#exo-show("quad-1")

// Show multiple exercises
#exo-show-many("quad-1", "geom-1", "quad-2")
```

### Selecting from Bank

Use powerful filtering to select exercises:

```typst
#import "@preview/exercise-bank:0.2.0": exo-select

// All quadratics exercises
#exo-select(topic: "quadratics")

// Level 1M exercises only
#exo-select(level: "1M")

// Multiple topics
#exo-select(topics: ("quadratics", "geometry"))

// Multiple levels
#exo-select(levels: ("1M", "2M"))

// Limit number of exercises
#exo-select(topic: "algebra", max: 5)

// Custom filter function
#exo-select(where: ex => ex.metadata.level == "hard")
```

## Competency Tags

Tag exercises with competencies and display them visually:

```typst
#import "@preview/exercise-bank:0.2.0": exo-define, exo-show, exo-setup

#exo-setup(show-competencies: true)

#exo-define(
  id: "comp-ex-1",
  exercise: [Solve and explain your reasoning.],
  competencies: ("C1.1", "C2.3", "C4.1"),
  solution: [Solution here],
)

#exo-show("comp-ex-1")
```

### Filter by Competency

```typst
#import "@preview/exercise-bank:0.2.0": exo-select

// Exercises with specific competency
#exo-select(competency: "C1.1")

// Exercises with any of these competencies
#exo-select(competencies: ("C1.1", "C2.3"))
```

## Configuration

### Global Setup

```typst
#import "@preview/exercise-bank:0.2.0": exo-setup

#exo-setup(
  solution-mode: "inline",      // "inline", "end-section", "end-chapter", "none", "only"
  solution-label: "Solution",   // Label for solutions
  exercise-label: "Exercise",   // Label for exercises
  counter-reset: "section",     // "section", "chapter", "global"
  show-metadata: false,         // Show metadata in output
  show-id: false,               // Show exercise ID
  show-competencies: false,     // Show competency tags
)
```

### Localization

Change labels for different languages:

```typst
#import "@preview/exercise-bank:0.2.0": exo-setup

// French
#exo-setup(
  exercise-label: "Exercice",
  solution-label: "Solution",
)

// German
#exo-setup(
  exercise-label: "Aufgabe",
  solution-label: "Lösung",
)

// Spanish
#exo-setup(
  exercise-label: "Ejercicio",
  solution-label: "Solución",
)
```

### Counter Reset Options

Control when exercise numbering resets:

```typst
#import "@preview/exercise-bank:0.2.0": exo-setup, exo-section-start, exo-chapter-start

// Reset at each section
#exo-setup(counter-reset: "section")
= Section 1
#exo-section-start()

// Reset at each chapter
#exo-setup(counter-reset: "chapter")
= Chapter 1
#exo-chapter-start()

// Never reset (global numbering)
#exo-setup(counter-reset: "global")
```

### Show Exercise IDs

Display exercise IDs for reference:

```typst
#import "@preview/exercise-bank:0.2.0": exo-setup, exo

#exo-setup(show-id: true)

#exo(
  id: "my-exercise",
  exercise: [
    This exercise shows its ID below the badge.
  ]
)
```

## Utility Functions

### Reset Counter

```typst
#import "@preview/exercise-bank:0.2.0": exo-reset-counter

#exo-reset-counter()  // Reset exercise numbering to 0
```

### Clear Registry

```typst
#import "@preview/exercise-bank:0.2.0": exo-clear-registry

#exo-clear-registry()  // Clear all registered exercises
```

### Count Exercises

```typst
#import "@preview/exercise-bank:0.2.0": exo-count

Total algebra exercises: #exo-count(topic: "algebra")
Level 1M exercises: #exo-count(level: "1M")
```

## Parameters Reference

### `exo` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `exercise` | content | none | Exercise content (named parameter) |
| `solution` | content | none | Solution content |
| `id` | string/auto | auto | Unique exercise ID |
| `topic` | string | none | Topic metadata |
| `level` | string | none | Difficulty level |
| `authors` | array | () | Array of author names |
| `..extra` | named | - | Additional metadata fields |

### `exo-define` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `exercise` | content | none | Exercise content (named parameter) |
| `solution` | content | none | Solution content |
| `id` | string/auto | auto | Unique exercise ID |
| `competencies` | array | () | List of competency tags |
| `topic` | string | none | Topic metadata |
| `level` | string | none | Difficulty level |
| `authors` | array | () | Array of author names |
| `..extra` | named | - | Additional metadata fields |

### `exo-select` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `topic` | string | none | Filter by exact topic |
| `level` | string | none | Filter by exact level |
| `author` | string | none | Filter by exact author |
| `competency` | string | none | Filter by single competency |
| `topics` | array | none | Filter by any of these topics |
| `levels` | array | none | Filter by any of these levels |
| `competencies` | array | none | Filter by any of these competencies |
| `where` | function | none | Custom filter function |
| `show-solutions` | bool/auto | auto | Override solution display |
| `renumber` | bool | true | Renumber exercises sequentially |
| `max` | int | none | Maximum exercises to show |

### `exo-setup` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `solution-mode` | string | "inline" | "inline", "end-section", "end-chapter", "none", "only" |
| `solution-label` | string | "Solution" | Label for solutions |
| `exercise-label` | string | "Exercise" | Label for exercises |
| `counter-reset` | string | "section" | "section", "chapter", "global" |
| `show-metadata` | bool | false | Display metadata |
| `show-id` | bool | false | Display exercise ID |
| `show-competencies` | bool | false | Display competency tags |

## Complete Example

```typst
#import "@preview/exercise-bank:0.2.0": *

// Setup
#exo-setup(
  solution-mode: "end-section",
  show-competencies: true,
)

= Algebra Exercises

// Define exercises in a bank
#exo-define(
  id: "alg-1",
  exercise: [Solve $2x + 5 = 13$.],
  topic: "equations",
  level: "easy",
  competencies: ("C1.1",),
  solution: [$x = 4$],
)

#exo-define(
  id: "alg-2",
  exercise: [Solve $x^2 = 9$.],
  topic: "equations",
  level: "medium",
  competencies: ("C1.1", "C1.2"),
  solution: [$x = 3$ or $x = -3$],
)

#exo-define(
  id: "alg-3",
  exercise: [Solve $3x - 1 > 5$.],
  topic: "inequalities",
  level: "medium",
  competencies: ("C1.3",),
  solution: [$x > 2$],
)

// Display exercises for this section
#exo-select(level: "easy")
#exo-select(level: "medium", max: 2)

// Print solutions at end of section
#exo-print-solutions(title: "Answers")
```

## Dependencies

- [g-exam](https://typst.app/universe/package/g-exam) (v0.4.3+) - Used for exercise and question templates

## License

MIT License - see LICENSE file for details.

## Changelog

All notable changes to exercise-bank are documented here.

### [0.2.0] - 2026-01-15

#### Changed (Breaking)
- **`exo` function**: Content parameter changed from positional to named parameter `exercise:`
  - Old: `#exo[Exercise content]`
  - New: `#exo(exercise: [Exercise content])`
  - Migration: Add `exercise:` before content in all `#exo()` calls
- **`exo-define` function**: Content parameter changed from positional to named parameter `exercise:`
  - Old: `#exo-define(id: "ex-1")[Content]`
  - New: `#exo-define(id: "ex-1", exercise: [Content])`
- **Author metadata**: Changed from single `author` to `authors` array
  - Old: `author: "John Doe"`
  - New: `authors: ("John Doe",)` or `authors: ("John", "Jane")`

#### Why These Changes?
- Named `exercise:` parameter provides better consistency with other named parameters (`solution:`, `id:`, etc.)
- Array `authors` supports multiple contributors per exercise
- More explicit and maintainable API

#### Dependencies
- Requires [g-exam](https://typst.app/universe/package/g-exam) v0.4.3 or higher

### [0.1.0] - 2026-01-13

#### Added
- Initial release with exercise management system
- Multiple solution display modes (inline, end-section, end-chapter, none, only)
- Metadata support (topic, level, author, custom fields)
- Exercise bank system for defining and reusing exercises
- Powerful filtering by topic, level, competency, or custom criteria
- Competency tagging system
- Automatic numbering with section/chapter/global reset options
- Customizable labels for localization
- Exercise ID system for referencing
- Utility functions for counter reset, registry management, and counting
