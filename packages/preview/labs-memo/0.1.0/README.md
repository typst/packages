# Plastic Labs Memo Template

A professional Typst template for technical memos with elevated visual styling, navigation, and extensive utility components.

## Quick Start

```typst
#import "@preview/labs-memo:0.1.0": memo, key-insight, metric, check, cross, highlight-text, callout, pull-quote, dotted-line

#show: memo.with(
  title: "Your Memo Title",
  subtitle: "A Descriptive Subtitle",
  meta: "Document Type · Organization · Year",
  logo: "assets/your-logo.svg",
  confidential: true,
)

= First Section

Your content here...

#key-insight[This is a key takeaway that stands out.]

#metric("Growth", "142%", subtext: "CMGR")
```

## Template Options

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `title` | string | none | Document title (metadata) |
| `subtitle` | string | none | Displayed below logo |
| `meta` | string | none | Metadata line |
| `logo` | path | none | Path to logo |
| `logo-width` | length | 2in | Logo width |
| `icon` | path | none | Optional icon |
| `confidential` | bool | false | Show "CONFIDENTIAL" in footer |
| `toc-style` | string | "dark" | Table of contents style: "dark" or "light" |
| `font` | string | "Departure Mono" | Base font |

### Color Customization

| Field | Default | Description |
|-------|---------|-------------|
| `accent-color` | #5B9BD5 | Primary accent color |
| `accent-light` | #A8D4FF | Light accent variant |
| `dark-color` | #1a1a1a | Dark backgrounds |
| `bg-color` | #ffffff | Page background |
| `text-color` | #333333 | Primary text |
| `text-secondary` | #666666 | Secondary text |
| `border-color` | #cccccc | Borders and dividers |

### Code Block Theming

| Field | Default | Description |
|-------|---------|-------------|
| `code-bg` | #0d1117 | Code block background |
| `code-header` | #161b22 | Code header bar |
| `code-border` | #30363d | Code border |
| `code-text` | #e6edf3 | Code text color |

### Component Styling

| Field | Default | Description |
|-------|---------|-------------|
| `shadow-intensity` | 70% | Shadow transparency (0-100%) |
| `card-radius` | 4pt | Card corner radius |
| `accent-bar-width` | 3pt | Left accent bar width |

## Utilities

### Emphasis & Callouts
- `highlight-text(body)` - Text in accent color
- `key-insight(body)` - Callout box for key points
- `callout(body, marker: "->")` - General callout with icon
- `pull-quote(body)` - Large centered quote
- `quote-block(body, source: none)` - Citation block

### Metrics & Data
- `metric(label, value, subtext)` - Metric card with accent bar
- `stat(label, value)` - Inline stat
- `stat-row(..items)` - Multiple stats in row
- `inline-bar(value, max, width, color)` - Progress bar

### Separators
- `dotted-line()` - Visible dotted separator
- `ornament-separator()` - Diamond centered separator
- `section-divider()` - Gradient fade divider
- `dot-separator()` - Centered dots
- `flourish()` - Decorative flourish
- `breathe()` - Extra vertical space

### People & Teams
- `founder-card(name, role, body)` - Founder profile
- `team-member(name, role, body)` - Team member
- `team-grid(..members)` - Two-column team layout
- `person(name, role)` - Inline mention

### Terminology
- `term(word, definition)` - Inline term
- `term-card(word, definition)` - Card-style term
- `numbered-term(num, word, definition)` - Numbered with badge
- `term-columns(..items)` - Two-column definitions

### Comparisons
- `competitor(name, body)` - Competitor mention
- `competitor-grid(..items)` - Two-column competitor grid
- `feature-compare(feature, us, them)` - Feature row
- `feature-check(label, has)` - Check/cross feature
- `feature-row(..items)` - Horizontal features

### Badges & Status
- `reasoning-type(label, body)` - Dark badge with label
- `badge(label, color)` - Inline badge
- `status(label, done)` - Status indicator
- `check` / `cross` - Symbols for tables

### Layout
- `two-col(left, right, ratio)` - Two-column layout
- `dark-section(title, body)` - Dark background section
- `content-card(body)` - White card with shadow

## Included Packages

This template integrates:
- `showybox` - Enhanced boxes with shadows
- `fontawesome` - Icons
- `gentle-clues` - Admonitions
- `fletcher` - Diagrams
- `cetz` - Drawing
- `tablex` - Advanced tables
- `lilaq` - Charts
- `umbra` - Gradient shadows
- `fractusist` - Fractal decorations
- `libra` - Text balancing

## License

MIT
