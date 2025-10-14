# CNAM TYPST Template

A modular and organized TYPST template for creating professional documents using CNAM branding and styling.

Originally based on [hzkonor's bubble-template](https://github.com/hzkonor/bubble-template) and uses [CNAM](https://www.cnam.fr/)'s logo and colors.

## Dependencies

This template uses the following external packages:
- `@preview/great-theorems:0.1.2` - Mathematical theorem environments
- `@preview/headcount:0.1.0` - Counter management
- `@preview/i-figured:0.2.4` - Figure and equation numbering

## Project Structure

```text
├── src/
│   ├── lib/               # Template library files
│   │   ├── config.typ     # Main configuration and document setup
│   │   ├── fonts.typ      # Centralized font configuration
│   │   ├── components.typ # UI components (blockquote, my-block, code)
│   │   ├── headers.typ    # Header management logic
│   │   ├── layout.typ     # Document layout and styling
│   │   ├── utils.typ      # Utility functions
│   │   ├── colors.typ     # Color definitions
│   │   └── math.typ       # Mathematical environments
│   └── lib.typ            # Main package entrypoint (local import)
├── template/
│   └── assets/            # Static assets (logos, images, fonts)
│       └── cnam_logo.svg
├── main.typ               # Example document using the published package
└── README.md
```

## Features

- **Modular Design**: Template split into logical, maintainable modules
- **CNAM Branding**: Official CNAM colors and styling
- **Centralized Font Configuration**: Global font settings for consistency
- **Enhanced Code Blocks**: Syntax highlighting, line numbers, filename labels
- **Rich Components**: Custom blockquotes, styled content blocks
- **Math Support**: Mathematical definitions, theorems, examples
- **Smart Headers**: Context-aware page headers
- **Responsive Layout**: Professional document layout with decorative elements

## Usage

### Basic Usage

1. Import the template in your document:

   - Using the published package (as in `main.typ`):
   ```typst
   #import "@preview/clean-cnam-template:1.1.0": *
   ```

   - Using this repository locally (from `src/`):
   ```text
   #import "src/lib.typ": *
   ```

2. Configure your document with basic parameters:
```typst
#show: clean-cnam-template.with(
  title: "Your Title",
  author: "Your Name",
  class: "Course Name",
  subtitle: "Subtitle",
  // If using the package, point to your own copy of the logo
  // If using this repo locally, you can use the provided logo path
  logo: image("template/assets/cnam_logo.svg"),
  start-date: datetime(day: 4, month: 9, year: 2024),
  main-color: "#C4122E",
  default-font: "New Computer Modern Math",
  code-font: "Zed Plex Mono",
)
```

3. Write your content using the available components and styling.

### Complete Parameter Reference

The `clean-cnam-template` function accepts the following parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | string | `""` | Document title |
| `subtitle` | string | `""` | Document subtitle |
| `author` | string | `""` | Author name |
| `affiliation` | string | `""` | Author's affiliation/institution |
| `year` | int | current year | Year for school year calculation |
| `class` | string/none | `none` | Class/course name |
| `start-date` | datetime | today | Document start date |
| `last-updated-date` | datetime | today | Last updated date |
| `logo` | image/none | `none` | Logo image to display |
| `main-color` | string | `"E94845"` | Primary color (hex string) |
| `color-words` | array | `()` | Words to highlight with primary color |
| `default-font` | string | `"New Computer Modern Math"` | Body text font |
| `code-font` | string | `"Zed Plex Mono"` | Code block font |
| `show-secondary-header` | bool | `true` | Show secondary headers |
| `outline-code` | content/bool/none | `none` | Custom outline configuration |

## Advanced Configuration

### Font Configuration

The template includes centralized font management that allows you to set consistent fonts across your document:

```typst
#show: clean-cnam-template.with(
  default-font: "Inter",           // Sets body text font
  code-font: "JetBrains Mono",     // Sets code block font
  // ... other parameters
)
```

All code blocks and monospace text will automatically use the configured `code-font`, while body text uses the `default-font`.

### Color Highlighting

You can automatically highlight specific words throughout your document with the primary color:

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  color-words: ("important", "CNAM", "theorem"),
  main-color: "#C4122E",
)
```

Any occurrence of the specified words will be rendered in the `main-color`.

### Header Configuration

Control the display of secondary headers (sub-headings in page headers):

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  show-secondary-header: false,  // Only show main section in headers
)
```

### Date Range Display

The template automatically formats date ranges. If `start-date` and `last-updated-date` are the same, only one date is shown. Otherwise, both dates are displayed as a range:

```typst
#show: clean-cnam-template.with(
  start-date: datetime(day: 1, month: 9, year: 2024),
  last-updated-date: datetime(day: 15, month: 12, year: 2024),
  // Displays: 01/09/2024 - 15/12/2024
)
```

## Custom Outline

The template allows you to customize or disable the table of contents (outline) on the title page:

### Default Outline
```typst
#show: clean-cnam-template.with(
  // ... other parameters
  // outline-code: none,  // This is the default - standard outline
)
```

### Custom Outline
You can provide your own outline configuration:
```typst
#show: clean-cnam-template.with(
  // ... other parameters
  outline-code: outline(
    title: "Table des matières",
    depth: 2,
    indent: auto,
  ),
)
```

### Disable Outline
To disable the outline completely:
```typst
#show: clean-cnam-template.with(
  // ... other parameters
  outline-code: false,
)
```

## Code Blocks

The template provides enhanced code blocks with multiple features including syntax highlighting, line numbers, and filename labels.

### Basic Usage
```text
#code(lang: "Python", ```python
def hello_world():
    print("Hello, World!")
```)
```

### With Filename
```text
#code(
  filename: "main.py",
  lang: "Python",
  ```python
def hello_world():
    print("Hello, World!")
```)
```

### Advanced Options

The `code()` function supports many customization options:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `lang` | string/none | `none` | Programming language for syntax highlighting |
| `filename` | string/none | `none` | Optional filename to display |
| `numbering` | bool | `true` | Whether to show line numbers |
| `line-spacing` | length | `5pt` | Vertical spacing between lines |
| `fill` | color | `luma(250)` | Background color |
| `stroke` | stroke | `1pt + luma(180)` | Border style |
| `radius` | length | `3pt` | Border radius |
| `width` | length/% | `100%` | Block width |
| `lines` | range/auto | `auto` | Line range to display |
| `number-align` | alignment | `right` | Line number alignment |
| `text-style` | dict | `(size: 8pt)` | Text styling options |

Example with custom styling:
```text
#code(
  numbering: false,
  fill: rgb("#f8f8f8"),
  stroke: 2pt + rgb("#e0e0e0"),
  radius: 5pt,
  lang: "Rust",
  ```rust
  fn main() {
      println!("Hello, world!");
  }
  ```
)
```


## Components

### UI Components

#### `blockquote()`
Styled quote blocks with customizable colors and borders.

**Parameters:**
- `color`: Stroke color (default: `luma(170)`)
- `fill`: Background color (default: `luma(230)`)
- `inset`: Padding (default: custom spacing)
- `radius`: Border radius (default: rounded right side)
- `stroke`: Stroke configuration (default: left border only)

**Example:**
```typst
#blockquote[
  This is an important quote that needs highlighting.
]
```

#### `my-block()`
Custom content blocks with configurable styling.

**Parameters:**
- `fill`: Background color (default: `luma(230)`)
- `inset`: Padding (default: `15pt`)
- `radius`: Border radius (default: `4pt`)
- `outline`: Border stroke (default: `none`)
- `alignment`: Block alignment (default: `center`)

**Example:**
```typst
#my-block(fill: rgb("#e3f2fd"))[
  Important note or callout content.
]
```

#### `code()`
Enhanced code blocks with line numbers, syntax highlighting, and filename labels. See the [Code Blocks](#code-blocks) section for detailed documentation.

### Math Components

#### `definition()`
Mathematical definition blocks with red styling.

**Example:**
```typst
#definition(title: "Derivative")[
  The derivative of a function $f$ at point $a$ is defined as...
]
```

#### `example()`
Example blocks with blue styling.

**Example:**
```typst
#example(title: "Computing a limit")[
  Calculate: $lim_(x -> 0) sin(x)/x = 1$
]
```

#### `theorem()`
Theorem blocks with purple styling.

**Example:**
```typst
#theorem(title: "Pythagorean Theorem")[
  For a right triangle: $a^2 + b^2 = c^2$
]
```

### Utilities

#### `ar(name)`
Creates vector arrow notation in math mode.

**Example:**
```typst
$ar(v) = (x, y, z)$
```

#### `icon(codepoint)`
Displays an icon with proper sizing and spacing for inline use.

**Example:**
```typst
#icon("path/to/icon.svg") Inline text with icon
```

#### `date-format(date)`
Formats a datetime object to French format (DD/MM/YYYY).

**Example:**
```typst
#date-format(datetime(day: 4, month: 9, year: 2024))
// Outputs: 04/09/2024
```

## Recent Updates

### Code Refactoring and Cleanup (Latest)
- **Removed unused code**: Eliminated unused `demonstration()` function and `alpha` parameter
- **Descriptive color naming**: Renamed `color1`, `color2`, `color5` to `theorem-color`, `example-color`, `definition-color`
- **Consistent naming conventions**: Updated all functions to use kebab-case (`get-header`, `build-main-header`, etc.)
- **Improved documentation**: Enhanced function documentation with better descriptions and examples
- **Cleaner imports**: Optimized import statements and removed circular dependencies
- **Better code organization**: Consolidated related functionality and improved modularity

## Previous Updates

### Font Configuration System
- Added centralized font management with `default-font` and `code-font` parameters
- Created separate `fonts.typ` module to avoid circular dependencies
- All components now use consistent font configuration

### Enhanced Code Blocks
- Added optional `filename` parameter for code blocks
- Language labels now appear above code blocks instead of inline
- Improved visual connection between filename/language labels and code content
- Fixed font inheritance issues with proper context handling

### Improved Modularity
- Restructured imports to eliminate circular dependencies
- Added `lib.typ` as main package entrypoint
- Better separation of concerns across modules

## Author

- **Tom Planche**

## License

MIT
