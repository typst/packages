# Calmly - Touying Presentation Theme

A modern, minimalist presentation theme for [Touying](https://github.com/touying-typ/touying). Calm, approachable, and intelligent—designed to let your content shine.

[![Typst Universe](https://img.shields.io/badge/Typst_Universe-calmly--touying-blue)](https://typst.app/universe/package/calmly-touying)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Typst](https://img.shields.io/badge/typst-0.12+-blue.svg)
![Touying](https://img.shields.io/badge/touying-0.6.1-orange.svg)

## Installation

### From [Typst Universe](https://typst.app/universe/package/calmly-touying)

Use the template directly:

```bash
# Create a new presentation from template
typst init @preview/calmly-touying:0.2.0 my-presentation
cd my-presentation
typst compile main.typ
```

Or import it in an existing project:

```typst
#import "@preview/calmly-touying:0.2.0": *
```

### Local Development

For local development or contributing, see the [GitHub repository](https://github.com/YHan228/calmly-touying).

## Features

- **Four Color Themes**: Tomorrow, Warm Amber, Paper, and Dracula palettes
- **Light/Dark Variants**: Adapt to different venues and preferences
- **Moloch-Inspired Design**: Clean headers, progress bars, and academic styling
- **Multiple Slide Types**: Title, content, focus, standout, section, figure, equation, and more
- **Rich Components**: Highlight boxes, alert/example boxes, algorithm containers, citation gadgets
- **Progressive Reveals**: `#only()` and `#pause` for animations
- **Golden Ratio Spacing**: Mathematically pleasing proportions
- **Bibliography Integration**: Styled citations and reference slides

## Quick Start

```typst
#import "@preview/calmly-touying:0.2.0": *

#show: calmly.with(
  config-info(
    title: [Your Presentation Title],
    subtitle: [Event or Context],
    author: [Your Name],
    date: datetime.today(),
    institution: [Your Institution],
  ),
)

#title-slide()

== First Slide

Your content here...

- Bullet points are styled automatically
- *Emphasis* and **strong text** work as expected

#focus-slide[
  Key Takeaway Message
]

#ending-slide(
  contact: ("email@example.com", "github.com/username"),
)
```

## Configuration Options

The theme supports extensive customization through configuration options:

```typst
#show: calmly.with(
  config-info(
    title: [Your Title],
    author: [Your Name],
  ),
  variant: "light",           // "light" | "dark"
  colortheme: "tomorrow",     // "tomorrow" | "warm-amber" | "paper" | "dracula"
  progressbar: "foot",        // "foot" | "head" | "frametitle" | "none"
  header-style: "moloch",     // "moloch" | "minimal"
  title-layout: "moloch",     // "moloch" | "centered" | "split"
)
```

| Option | Values | Description |
|--------|--------|-------------|
| `variant` | `"light"`, `"dark"` | Color mode for the presentation |
| `colortheme` | `"tomorrow"`, `"warm-amber"`, `"paper"`, `"dracula"` | Color palette (tomorrow is default) |
| `progressbar` | `"foot"`, `"head"`, `"frametitle"`, `"none"` | Progress bar position |
| `header-style` | `"moloch"`, `"minimal"` | Slide header style (colored bar vs underline) |
| `title-layout` | `"moloch"`, `"centered"`, `"split"` | Title slide layout variant |

### Color Themes

- **Tomorrow** (default): Programmer-friendly palette based on Tomorrow theme. Balanced colors.
- **Warm Amber**: Soft, warm tones with amber accents. Premium, modern feel.
- **Paper**: High contrast black/white with blue accents. Academic style.
- **Dracula**: Purple and pink accents.

## Slide Types

### Title Slide
```typst
#title-slide()
#title-slide(layout: "centered")  // Alternative layouts
#title-slide(layout: "split")
```

### Content Slides
Standard slides are created automatically with level-2 headings:
```typst
== Slide Title

Content goes here...
```

### Focus Slide
Full-bleed accent gradient background for emphasis:
```typst
#focus-slide[
  Important statement or takeaway
]
```

### Standout Slide
High-contrast background for maximum emphasis:
```typst
#standout-slide[
  Key Message
]
```

### Section Slide
Clean section dividers with optional progress:
```typst
#section-slide[Methods]
#section-slide(show-progress: true)[Results]
```

### Figure Slide
Centered figure with optional caption:
```typst
#figure-slide(
  image("figure.svg"),
  title: [Figure Title],
  caption: [Description of the figure],
)
```

### Split Figure Slide
Two figures side-by-side:
```typst
#figure-slide-split(
  image("left.svg"),
  image("right.svg"),
  title: [Comparison],
  caption-left: [Before],
  caption-right: [After],
)
```

### Equation Slide
Centered equation with definition box and optional citation:
```typst
#equation-slide(
  $E = m c^2$,
  title: [Mass-Energy Equivalence],
  subtitle: [Einstein's famous equation],
  definitions: [
    $E$ — Energy \
    $m$ — Mass \
    $c$ — Speed of light
  ],
  citation: (bib-key: "einstein1905", label: "Einstein 1905"),
)
```

### Bibliography Slide
```typst
#bibliography-slide(bib-content: bibliography("refs.bib", title: none, style: "apa"))
```

### Acknowledgement Slide
```typst
#acknowledgement-slide(
  subtitle: [We thank the following],
  people: (
    (name: "Prof. Smith", role: "Supervisor"),
    (name: "Dr. Jones", role: "Advisor"),
  ),
  institutions: ("University A", "Lab B"),
  extra: [Special thanks to all contributors.],
)
```

### Ending Slide
```typst
#ending-slide(
  title: [Thank You],
  subtitle: [Questions?],
  contact: ("email@example.com", "github.com/username"),
)
```

## Components

### Box Components

```typst
// Key concepts and summaries
#highlight-box(title: "Key Point")[
  Important information here.
]

// Warnings and critical notes
#alert-box(title: "Warning")[
  Critical information.
]

// Examples and demonstrations
#example-box(title: "Example")[
  Illustrative content.
]

// Generic themed container
#themed-block(title: "Block Title")[
  General content.
]
#themed-block(title: "Filled", fill-mode: "fill")[Filled background.]
```

### Algorithm Box
```typst
#algorithm-box(title: "Algorithm 1: Example")[
  *Input:* Data $X$ \
  *Output:* Result $Y$ \
  1: Process data \
  2: Return result
]
```

### Text Helpers
```typst
This is #alert[important] information.     // Accent colored
This is #muted[secondary] information.     // Muted grey
This is #subtle[tertiary] information.     // Light subtle
```

### Citations

**Inline Citations** (grey-boxed):
```typst
Recent work has shown improvements @smith2023.
```
Renders with a subtle grey background pill.

**Citation Box** (positioned in corners):
```typst
#cite-box("key", display-label: "Author 2023", position: "bottom-right")

// Multiple citations
#cite-box(
  ("key1", "key2"),
  display-label: "Author1; Author2",
  position: "top-right"
)
```
Positions: `"top-right"`, `"bottom-left"`, `"bottom-right"`

### Multi-Column Layouts
```typst
#two-col(
  [Left column content],
  [Right column content],
)

#three-col([A], [B], [C])
```

## Progressive Reveals

### Using `#only(n)[...]`
Show content only on specific sub-slides:
```typst
== Building Concepts

#only(1)[Step 1: Introduction]
#only(2)[Step 2: Details]
#only(3)[Step 3: Conclusion]
```

### Using `#pause`
Reveal content progressively:
```typst
== Points

- First point
#pause
- Second point (appears after click)
#pause
- Third point
```

## Spacing Utilities

### Flexible Spacing
```typst
#v(1fr)          // Flexible vertical space
#v(spacing-md)   // Fixed spacing (16pt)
```

### Vertical Centering
```typst
#v(1fr)
#align(center)[Centered content]
#v(1fr)
```

### Spacing Constants
| Constant | Size |
|----------|------|
| `spacing-xs` | 6pt |
| `spacing-sm` | 10pt |
| `spacing-md` | 16pt |
| `spacing-lg` | 24pt |
| `spacing-xl` | 36pt |
| `spacing-2xl` | 48pt |

### Typography Constants
| Constant | Size |
|----------|------|
| `size-display` | 42pt |
| `size-title` | 34pt |
| `size-slide-title` | 26pt |
| `size-body` | 17pt |
| `size-small` | 15pt |
| `size-caption` | 13pt |

### Golden Ratio Utilities
| Constant | Description |
|----------|-------------|
| `phi` | 1.618... golden ratio constant |
| `golden-major` | ~0.618 proportion |
| `golden-minor` | ~0.382 proportion |
| `golden-center(body)` | Vertically center with golden ratio offset |

## Customization

### Colors
Edit `theme/colors.typ` to customize the color palette. Each theme defines:
- Accent colors (primary, secondary, subtle)
- Background hierarchy (base, elevated, muted, surface)
- Text hierarchy (primary, secondary, muted)
- Functional colors (alert, example, focus)

### Typography
Edit `theme/typography.typ` for font settings:

```typst
#let font-heading = ("Source Sans Pro", "Noto Sans", "sans-serif")
#let font-body = ("Source Sans Pro", "Noto Sans", "sans-serif")
#let font-mono = ("JetBrains Mono", "Fira Code", "monospace")
```

### Recommended Fonts
For best results, install:
- [Source Sans Pro](https://fonts.google.com/specimen/Source+Sans+3)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- [STIX Two Math](https://github.com/stipub/stixfonts)

The theme will gracefully fall back to system fonts if these aren't available.

## Examples

The `examples/` directory contains several templates:

| File | Description |
|------|-------------|
| `feature-showcase.typ` | Complete feature demonstration |
| `academic-talk.typ` | Realistic research presentation |
| `dark-variant.typ` | Dark mode example |
| `paper-theme.typ` | Paper color theme |
| `dracula-theme.typ` | Dracula color theme |
| `centered-title.typ` | Centered title layout |

## File Structure

```text
calmly-touying/
├── typst.toml              # Package manifest
├── lib.typ                 # Package entrypoint
├── LICENSE                 # MIT License
├── README.md
├── thumbnail.png           # Package thumbnail (for Universe listing)
├── theme/
│   ├── theme.typ           # Main theme configuration
│   ├── colors.typ          # Color palettes (4 themes × 2 variants)
│   ├── typography.typ      # Font settings and spacing
│   ├── components.typ      # Reusable components (30+)
│   ├── slides.typ          # Slide type definitions
│   └── syntax-themes/      # .tmTheme files for code syntax highlighting
├── template/               # Starter template (for typst init)
│   └── main.typ            # Template entry point
└── examples/               # Example presentations
```

## Building

```bash
typst compile main.typ
```

Or use `typst watch main.typ` for live preview.

## License

MIT License - feel free to use and modify for your presentations.

## Credits & References

- Built on [Touying](https://github.com/touying-typ/touying) presentation framework by OrangeX4
- Layout inspired by [Moloch](https://github.com/jolars/moloch) (Beamer theme) by Johan Larsson, itself based on [Metropolis](https://github.com/matze/mtheme) by Matthias Vogelgesang
- Color palette based on [Tailwind CSS](https://tailwindcss.com/docs/colors) Stone and Amber scales

---

## Function Reference

### Modified from Touying

These functions wrap or extend Touying's base functionality:

| Function | Description |
|----------|-------------|
| `slide()` | Enhanced slide with Moloch headers and progress bars |
| `title-slide()` | Router for title layout variants |
| `title-slide-moloch()` | Left-aligned title with separator line |
| `title-slide-centered()` | Centered title with accent underline |
| `title-slide-split()` | Two-column title with vertical separator |
| `focus-slide()` | Gradient background emphasis slide |
| `standout-slide()` | High-contrast emphasis slide |
| `section-slide()` | Section divider with optional progress |
| `figure-slide()` | Single centered figure display |
| `figure-slide-split()` | Side-by-side figure comparison |
| `equation-slide()` | Equation with definitions and citation |
| `acknowledgement-slide()` | People and institution cards |
| `ending-slide()` | Thank you / closing slide |
| `bibliography-slide()` | Styled references slide |

### Created for This Theme

**Layout Helpers** (`components.typ`):
| Function | Description |
|----------|-------------|
| `two-col()` | Two-column grid layout |
| `three-col()` | Three-column grid layout |
| `spacer()` | Vertical spacing helper |

**Box Components** (`components.typ`):
| Function | Description |
|----------|-------------|
| `highlight-box()` | Left-accent gradient box with title |
| `alert-box()` | Red-accented warning box |
| `example-box()` | Green-accented example box |
| `themed-block()` | Generic themed container |
| `algorithm-box()` | Code/algorithm container with header |
| `quote-block()` | Blockquote with attribution |
| `code-block()` | Styled code display |
| `soft-shadow-box()` | Elevated box with subtle stroke |

**Text Helpers** (`components.typ`):
| Function | Description |
|----------|-------------|
| `alert()` | Accent-colored inline text |
| `muted()` | Grey muted text |
| `subtle()` | Light subtle text |
| `fig-caption()` | Italic figure caption |

**Visual Elements** (`components.typ`):
| Function | Description |
|----------|-------------|
| `cite-box()` | Corner-positioned citation gadget |
| `accent-line()` | Gradient accent line |
| `soft-divider()` | Subtle horizontal divider |
| `pill()` | Rounded tag/label |
| `bullet-circle()` | Level 1 bullet marker |
| `bullet-square()` | Level 2 bullet marker |
| `bullet-dash()` | Level 3 bullet marker |

**Card Components** (`components.typ`):
| Function | Description |
|----------|-------------|
| `person-card()` | Person display with optional image |
| `institution-card()` | Institution logo/name display |
| `contact-item()` | Contact info helper |

**Color System** (`colors.typ`):
| Function | Description |
|----------|-------------|
| `get-theme-colors()` | Get color palette by theme/variant |
| `make-gradients()` | Generate gradient definitions |
| `resolve-theme-colors()` | Resolve colors from param or state |
| `get-color-from()` | Safe dictionary access with fallback |

**Golden Ratio** (`typography.typ`):
| Function | Description |
|----------|-------------|
| `phi` | Golden ratio constant (1.618...) |
| `golden-center()` | Golden-ratio vertical centering |
| `golden-major` | ~0.618 proportion |
| `golden-minor` | ~0.382 proportion |
| `golden-split-left` | ~38.2% width for layouts |
| `golden-split-right` | ~61.8% width for layouts |

**Theme Entry** (`theme.typ`):
| Function | Description |
|----------|-------------|
| `calmly()` | Main theme configuration function |
| `warm-amber-theme` | Backward compatibility alias |
| `thesis-theme` | Alias for calmly |
| `moloch-style-theme` | Preconfigured Moloch settings |
| `minimal-style-theme` | Preconfigured minimal settings |
| `dark-theme` | Preconfigured dark variant |
