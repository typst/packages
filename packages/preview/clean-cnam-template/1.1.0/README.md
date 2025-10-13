# CNAM TYPST Template

A modular and organized TYPST template for creating professional documents using CNAM branding and styling.

Originally based on [hzkonor's bubble-template](https://github.com/hzkonor/bubble-template) and uses [CNAM](https://www.cnam.fr/)'s logo and colors.

## Project Structure

```text
├── lib/               # Template library files
│   ├── config.typ     # Main configuration and document setup
│   ├── fonts.typ      # Centralized font configuration
│   ├── components.typ # UI components (blockquote, my-block, code)
│   ├── headers.typ    # Header management logic
│   ├── layout.typ     # Document layout and styling
│   ├── utils.typ      # Utility functions
│   ├── colors.typ     # Color definitions
│   └── math.typ       # Mathematical environments
├── assets/            # Static assets (logos, images, fonts)
├── main.typ           # Main document file
├── lib.typ            # Main package entrypoint
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

1. Import the template in your document:
```typst
#import "lib.typ": *
```

2. Configure your document:
```typst
#show: clean-cnam-template.with(
  title: "Your Title",
  author: "Your Name",
  class: "Course Name",
  subtitle: "Subtitle",
  logo: image("assets/cnam_logo.svg"),
  start-date: datetime(day: 4, month: 9, year: 2024),
  main-color: "#C4122E",
  default-font: "New Computer Modern Math",
  code-font: "Zed Plex Mono",
)
```

3. Write your content using the available components and styling.

## Font Configuration

The template includes centralized font management that allows you to set consistent fonts across your document:

```typst
#show: conf.with(
  default-font: "Inter",           // Sets body text font
  code-font: "JetBrains Mono",     // Sets code block font
  // ... other parameters
)
```

All code blocks and monospace text will automatically use the configured `code-font`, while body text uses the `default-font`.

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

The template provides enhanced code blocks with multiple features:

### Basic Usage
```typst
#code(lang: "Python", ```python
def hello_world():
    print("Hello, World!")
```)
```

### With Filename
```typst
#code(
  filename: "main.py",
  lang: "Python",
  ```python
def hello_world():
    print("Hello, World!")
```)
```


## Components

### UI Components
- `blockquote()`: Styled quote blocks with customizable colors and borders
- `my-block()`: Custom content blocks with configurable styling
- `code()`: Enhanced code blocks with line numbers, syntax highlighting, and filename labels

### Math Components
- `definition()`: Mathematical definitions with red styling
- `example()`: Examples with blue styling
- `theorem()`: Theorem blocks with purple styling

### Utilities
- `ar()`: Vector arrows in math mode
- `icon()`: Properly sized icons
- `date-format()`: French date formatting

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
