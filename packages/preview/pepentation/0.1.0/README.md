# Pepentation

*Simple slides for your university presentations*

**Pepentation** is a Typst template designed for clean, academic presentations.

**Features:**
- 🎨 **Customizable:** Easy to change color schemes to match your institution.
- 🧭 **Navigation:** Header with bullet-point progress tracker (Beamer-inspired).
- 🔢 **Smart Layout:** Automatic footer with 3-column layout (Authors, Title, Date/Page).
- 🧱 **Pre-defined Blocks:** Styled blocks for definitions, warnings, remarks, and hints.

| Title Slide | Table of Contents | Section Slide | Main Slide |
| - | - | - | - |
| ![Title Slide](screenshots/Thumbnail.png) | ![Section Slide](screenshots/ToC.png) | ![Example-Slide](screenshots/SectionSlide.png) | ![Example-Full-Slide](./screenshots/MainSlide.png) |

## Setup

### Using the Published Package

Simply import the package in your `.typ` file:

```typst
#import "@preview/pepentation:0.1.0": *
```

The package will be automatically downloaded on first use.

### Local Installation (Development)

If you want to install the package locally or modify it:

1.  **Clone or Download** this repository.
2.  **Place it** in your local Typst package directory:
    `{data-dir}/typst/packages/local/pepentation/0.1.0`

    Where `{data-dir}` is:
    - **Linux:** `$XDG_DATA_HOME` or `~/.local/share`
    - **macOS:** `~/Library/Application Support`
    - **Windows:** `%APPDATA%`
3.  **Import it** in your `.typ` file:
    ```typst
    #import "@local/pepentation:0.1.0": *
    ```
    
## Quick Start

Don't want to configure everything from scratch?

Check the **`template/`** folder in this repository. It contains a fully configured `main.typ` file. You can copy this file to your project folder and start editing immediately.

## Usage

Initialize the template at the top of your file using the `setup_presentation` rule:

```typst
#import "@preview/pepentation:0.1.0": *

#show: setup_presentation.with(
  title-slide: (
    enable: true,
    title: "Presentation Title",
    authors: ("Author One", "Author Two"),
    institute: "University of Typst",
  ),
  footer: (
    enable: true,
    title: "Short Title",
    institute: "Short Inst.",
    authors: ("A. One", "A. Two"),
  ),
  table-of-contents: true, // Interactive: click to jump to section
  header: true,
  locale: "EN"
)

// Your content goes here...
```

### Structure
Use standard markdown-like headings to structure your slides:

- **`= Section`** (Level 1): Creates a dedicated **Section Title Slide**.
- **`== Slide Title`** (Level 2): Creates a new **Main Slide**.
- **`== `** (Empty Level 2): Creates a new slide *without* a title (excluded from ToC).
- **`=== Subsection`** (Level 3): Creates a new slide with a title, but *excluded* from the Table of Contents.

```typst
= Introduction

== Motivation
This is the first slide of the introduction.

== 
This slide has no title.

=== Detail View
This slide has a title, but won't appear in the outline.
```

## Content Blocks

The template provides colored blocks for highlighting specific content:

- `#definition[content]` (Gray)
- `#warning[content]` (Red)
- `#remark[content]` (Orange)
- `#hint[content]` (Green)

**Example:**
```typst
#definition[
  *Euclid's Algorithm*
  An efficient method for computing the GCD.
]
```

## Configuration Options

These are the parameters available in the `setup_presentation` function:

| Keyword | Description | Default |
| :--- | :--- | :--- |
| **`title-slide`** | Dictionary configuration for the title slide | `(enable: false)` |
| `title-slide.enable` | Whether to show title slide | `false` |
| `title-slide.title` | Full title displayed on title page | `none` |
| `title-slide.authors` | Array of author names | `()` |
| `title-slide.institute` | Institute name | `none` |
| **`footer`** | Dictionary configuration for the footer | `(enable: false)` |
| `footer.enable` | Whether to show footer | `false` |
| `footer.title` | Short title displayed in center of footer | `none` |
| `footer.authors` | Array of short author names (left side) | `()` |
| `footer.institute` | Short institute name (left side) | `none` |
| `footer.date` | Date displayed (right side) | `Today` |
| **`theme`** | Dictionary for colors | *(See below)* |
| `theme.primary` | Primary brand color (Header/Footer/Title) | `rgb("#003365")` |
| `theme.secondary` | Secondary accents | `rgb("#00649F")` |
| `theme.background` | Slide background color | `rgb("#FFFFFF")` |
| `theme.main-text` | Body text color | `rgb("#000000")` |
| `theme.sub-text` | Text color on dark backgrounds (headers) | `rgb("#FFFFFF")` |
| **`table-of-contents`** | Show the table of contents slide | `false` |
| **`header`** | Show the navigation header | `true` |
| **`locale`** | Language ("EN" or "RU") | `"EN"` |
| **`height`** | Slide height (aspect ratio fixed at 16:10) | `12cm` |
