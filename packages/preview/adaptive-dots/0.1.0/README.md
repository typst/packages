# adaptive-dots

[![Build Typst Document](https://github.com/AJB-ajb/adaptive-dots/actions/workflows/build.yml/badge.svg)](https://github.com/AJB-ajb/adaptive-dots/actions/workflows/build.yml)
[![GitHub](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/AJB-ajb/adaptive-dots)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

Automatically adapt ellipsis dots (`…`, `dots`, `...`) to centered or baseline variants based on surrounding operators, similar to LaTeX's `amsmath` `\dots` behavior.

## Usage

```typ
#import "@preview/adaptive-dots:0.1.0": adaptive-dots

#show: adaptive-dots

// Baseline dots (with commas)
$a_1, a_2, ..., a_n$

// Centered dots (with multiplication or addition)
$1 + 2 + ... + n$ // automatically centered
$1 dot.c ... dot.c n$
```

### Explicit Variants

Use `ldots` and `cdots` to override automatic detection:

```typ
#import "@preview/adaptive-dots:0.1.0": adaptive-dots, ldots, cdots

#show: adaptive-dots

// Force baseline dots even with + operators
$1 + 2 + ldots + n$

// Force centered dots even with commas
$a, b, cdots, z$
```

## How It Works

The package inspects the operators surrounding `...` or `dots`:
- Uses `dots.c` (centered dots `⋯`) when adjacent to binary operators like `+`, `−`, `×`, `⋅`, `=`, `<`, `>`, `∪`, `∩`, etc.
- Defaults to baseline `dots` (`…`) for list separators like `,` and `;`

### Supported Operators

The following operators trigger centered dots:

| Category | Operators |
|----------|-----------|
| Arithmetic | `+`, `−`, `-`, `×`, `÷`, `±`, `∓`, `⋅`, `·`, `∗`, `*`, `∘` |
| Direct/Tensor | `⊕`, `⊗`, `⊙`, `⊖`, `⊘` |
| Logical | `∧`, `∨`, `⊻`, `⊼`, `⊽` |
| Set | `∪`, `∩`, `∖`, `△`, `▽` |
| Relations | `=`, `≠`, `≡`, `≈`, `∼`, `<`, `>`, `≤`, `≥`, `≪`, `≫`, etc. |
| Arrows | `→`, `←`, `↔`, `⇒`, `⇐`, `⇔`, etc. |

## Examples

```typ
#import "@preview/adaptive-dots:0.1.0": adaptive-dots

#show: adaptive-dots

// Sequences use baseline dots
$a_1, a_2, ..., a_n$           // → a₁, a₂, …, aₙ

// Sums and products use centered dots  
$1 + 2 + ... + n$              // → 1 + 2 + ⋯ + n
$a × b × ... × z$              // → a × b × ⋯ × z

// Set operations
$A ∪ B ∪ ... ∪ Z$              // → A ∪ B ∪ ⋯ ∪ Z

// Inequalities
$a < b < ... < z$              // → a < b < ⋯ < z
```

## License

This package is licensed under the MIT License.

