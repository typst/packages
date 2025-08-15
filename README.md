# axiomst

a clean, elegant template for academic problem sets and homework assignments in [typst](https://typst.app/).

## Features
- Professional-looking problem set layout with title page
- Automatic problem numbering
- Customizable problem boxes with titles
- Support for collaborator attribution
- Page headers and footers with automatic page numbering
- Clean, academic aesthetic with customizable accent colors

## Quick Start
The easiest way to get started is through the Typst web app,
```
typst init @preview/axiomst:0.1.0
```

Or click "Create from template" in the Typst web app and search for "axiomst".

## Usage
Here's a basic example of how to use the template,

```typst
#import "@preview/axiomst:0.1.0": *

#show: homework.with(
  title: "Problem Set 1",
  author: "Your Name",
  course: "MATH 101: Advanced Linear Algebra",
  email: "name@uni.com",
  date: datetime.today(),
  due-date: "April 30, 2025",
  collaborators: ["Alice Smith", "Bob Johnson"],
)

#problem(title: "Vector Spaces")[
  Let $V$ be a vector space over a field $F$. Prove the following properties:

  1. The zero vector $0_V$ is unique.
  2. For each $v in V$, the additive inverse $-v$ is unique.
  3. If $a in F$ and $a cdot v = 0_V$ for some $v in V$, then either $a = 0$ or $v = 0_V$.
]

// Your solution here...
```

## Configuration Options
### Homework Template
The main `homework()` function accepts the following parameters:

- `title`: The title of the assignment
- `author`: Your name
- `course`: Course code or name
- `email`: Your email address
- `date`: Date of submission (defaults to today)
- `due-date`: When the assignment is due (optional)
- `collaborators`: List of people you worked with (optional)

### Problem Function
Individual problems can be created with the `problem()` function:

- `title`: Title of the problem
- `color`: Color theme for this specific problem box
- `numbered`: Whether to include automatic problem numbering (default: true)

## Customization
The template is designed to be easily customizable. Here are some common adjustments:

```typst
// Change the enumeration style for lists
#set enum(numbering: "a)")

// Use LaTeX-like font
#set text(font: "New Computer Modern")

// Enable equation numbering
#set math.equation(numbering: "(1)")
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
