# Assignment Template for Typst

A clean, customizable assignment template with themed problem boxes, multi-author support, and configurable typography.

## Quick Start

Initialize a new project from the template:

```bash
typst init @preview/stux-assignment:0.1.0
```

Or import it manually in an existing file:

```typst
#import "@preview/stux-assignment:0.1.0": *

#show: assignment.with(
  title: "Assignment - 1",
  author: "Your Name",
  email: "you@example.com",
  roll: "123456",
  course: "CS 101",
)

#problem()[
  What is $1 + 1$?
]

#solution[
  $1 + 1 = 2$
]
```

Compile with `typst compile main.typ` or use the [Tinymist VS Code extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist).

## Features

### Themes

Five built-in color themes for problem boxes:

| Theme    | Background | Accent   |
| -------- | ---------- | -------- |
| `teal`   | `#e9f2f0`  | `#007070` |
| `purple` | `#f2e9f2`  | `#74007b` |
| `brown`  | `#f2efe9`  | `#7b5700` |
| `red`    | `#f0e5e5`  | `#af0101` |
| `gray`   | `#f1f1f1`  | `#7e7676` |

Set a theme by name:

```typst
#show: assignment.with(
  // ...
  theme: "purple",
)
```

Or pass a custom color dictionary:

```typst
#show: assignment.with(
  // ...
  theme: (bg: rgb("#e6f0ff"), fr: rgb("#0055aa")),
)
```

### Multiple Authors

For group assignments, set `num-of-authors` and pass an `authors` array. The header switches to a centered layout with an author table:

```
          Course: CS 101
    Group Assignment - 1
      Date: Jan 01, 2026
──────────────────────────────────────
   Alice    |    Bob    |    Charlie
  Roll: 101 | Roll: 102 |  Roll: 103
```

```typst
#import "@preview/stux-assignment:0.1.0": *

#show: assignment.with(
  title: "Group Assignment - 1",
  num-of-authors: 3,
  authors: (
    (name: "Alice", email: "alice@example.com", roll: "101"),
    (name: "Bob",   email: "bob@example.com",   roll: "102"),
    (name: "Charlie",   email: "charlie@example.com",   roll: "103"),
  ),
  course: "CS 101",
)
```


When `num-of-authors` is `1` (the default), the single-author shorthand (`author`, `email`, `roll`) is used with the standard side-by-side header.

### Font Customization

Override the default font family and size:

```typst
#show: assignment.with(
  // ...
  font-size: 12pt,
  font-family: "New Computer Modern",
)
```

Defaults are `11pt` and `"Linux Libertine"`.

## All Parameters

| Parameter     | Default                             | Description                                  |
| ------------- | ----------------------------------- | -------------------------------------------- |
| `title`       | `"Assignment"`                      | Assignment title                             |
| `author`      | `"Student Name"`                    | Single author name                           |
| `email`       | `"email@example.com"`               | Single author email                          |
| `roll`        | `"123456"`                          | Single author roll number                    |
| `num-of-authors` | `1`                              | Set > 1 for multi-author table header        |
| `authors`     | `none`                              | Array of `(name, email, roll)` dictionaries  |
| `course`      | `"Course Name"`                     | Course identifier                            |
| `date`        | today's date                        | Display date                                 |
| `theme`       | `"teal"`                            | Theme name or custom `(bg: …, fr: …)` dict   |
| `font-size`   | `11pt`                              | Document font size                           |
| `font-family` | `"Linux Libertine"`                 | Document font family                         |

## Template Functions

- **`#problem(title: none)[…]`** — Numbered problem box styled with the active theme. Optional `title` appears after the number.
- **`#solution[…]`** — Indented solution block with an italic "Solution:" label.


## License

This package is licensed under the [MIT-0 License](LICENSE).
