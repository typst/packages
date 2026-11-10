# Ape for Typst

Tired of documents that look like they were formatted by a troop of baboons? Try Ape for Typst!

**Ape** is a Typst package designed to help you structure and style academic documents, such as course notes, reports, and theses. It offers a set of pre-configured layouts and utilities to make your documents look professional with minimal effort.

> **Note:** This package is primarily designed with French conventions in mind (e.g., specific shortcuts and default text in some functions), but it can be used for documents in other languages as well.

## Getting Started

To use **Ape**, initialize your document using the `doc` function:
```typst
#import "@preview/ape:0.4.4": *
#show: doc.with(
  title: "My Course Title",
  authors: ("Author Name",),
  lang: "en", // Defaults to "fr"
  style: "numbered",
  title-page: true,
  outline: true,
)

= Introduction
Your content goes here...
```

*Exemple :*
![Exemple 1](exemples/Exemple1.png)


## Configuration

The `doc` function accepts several parameters to customize your document:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `string` | `"Titre"` | The main title of the document. |
| `authors` | `array` | `()` | A list of author names. |
| `lang` | `string` | `"fr"` | The document language (e.g., "en", "fr"). |
| `style` | `string` | `"numbered"` | Global style of the document (see below). |
| `maths-style` | `string` | `"normal"` | Style for math environments (`"normal"` or `"colored"`). |
| `title-page` | `boolean` | `false` | Whether to generate a dedicated title page. |
| `outline` | `boolean` | `false` | Whether to generate a table of contents. |
| `smallcaps` | `boolean` | `true` | Whether to use small caps in headers/titles. |

### Available Styles
- **`numbered`**: A structured layout with numbered sections, suitable for reports and books.
- **`colored`**: A colorful design often used for course notes.
- **`plain`**: A simple, minimalist layout.
- **`presentation`**: A layout optimized for slides/presentations.

## Features

### Formatting Tools

*   **`para(name, content)`**: Creates a labeled paragraph.
    ```typst
    #para("Note", [This is a side note.])
    ```
*   **`arrow-list(..items)`**: Creates a list with arrow bullets.
    ```typst
    #arrow-list[First item][Second item]
    ```
*   **`inbox(content)`**: Creates a simple boxed container.
    *   Variants: `inbox2`, `inbox3`, `inbox4` offer different border and background styles.

### Math Environments

Ape provides environments for common mathematical structures. Their appearance changes based on the `maths-style` configuration.

*   `def(title, content)`: Definition
*   `prop(title, content)`: Property
*   `theorem(title, content)`: Theorem
*   `lemme(title, content)`: Lemma
*   `corollaire(title, content)`: Corollary
*   `remarque(title, content)`: Remark
*   `exemple(title, content)`: Example
*   `exercice(title, content)`: Exercise
*   `demo(content)`: Proof (Démonstration)

```typst
#def("Linear Algebra")[ 
  A vector space is...
]
```

### Shortcuts & Utilities

*   **Physics Notations**:
    *   `dt`, `dx`, `dtheta`
    *   `grad` 
    *   `ar(x)` -> $vec{x}$ (Arrow)
    *   `nar(x)` -> $||vec{x}||$ (Norm of arrow)

*   **Math Sets & Operators**:
    *   `Im`, `Ker`, `Vect`, `dim`, `card`
    *   `GL` (General Linear Group), `SO` (Special Orthogonal Group)
    *   `Union`, `Inter` (Big union/intersection)

### Plotting & Figures

Ape integrates with `cetz` for drawing and plotting.

*   **`plotting(functions, ...)`**: A high-level wrapper to plot functions easily.
    ```typst
    #plotting(
      (
        (fn: x => x * x, domain: (-2, 2), stroke: blue),
      ),
      axis-style: "school-book"
    )
    ```
*   **Drawing Utilities**:
    *   `point(coordinates)`
    *   `spring(start, end, ...)`
    *   `base(origin, name1, name2, angle)`
