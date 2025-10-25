# Aspirationally
A clean and minimal template for academic research statements, teaching statements, or cover letters

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the
dashboard and searching for `aspirationally`.

Alternatively, you can use the CLI to kick this project off using the command

```sh
typst init @preview/aspirationally
```

Typst will create a new directory with all the files needed to get you started.

If you already have a typst file, you can add the following to the top:

```typst
#import "@preview/aspirationally:0.1.0": aspirationally

#show: aspirationally.with(
  name: [Laurenz Typsetterson],
  title: [Research Statement],
  current-department: [Department of Literary Studies],
  has-references: false,
  logo: image("school-logo.png", height: 0.6in),
)
```

Once you have specified that you want to show all typst content via the `aspirationally` function, you can write your document using standard Typst markup. The template will automatically format your document with:

- A professional header with your institution's logo on the first page
- Your name, document title, and department information
- Clean, academic styling throughout
- Optional bibliography section

Refer to [the template](./template/main.typ) for a complete example.

## Configuration

This template exports the `aspirationally` function with the following named arguments:

| Argument | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `content` | Your name | `[Laurenz Typsetterson]` |
| `title` | `content` | Document title (e.g., "Research Statement", "Teaching Statement") | `[Research Statement]` |
| `current-department` | `content` | Your department or affiliation | `[Department of Literary Studies]` |
| `has-references` | `boolean` | Whether to include a bibliography section | `false` |
| `bib-references` | `string` | Path to your bibliography file | `"./references.bib"` |
| `bib-style` | `string` | Path to CSL style file | `"style.csl"` |
| `logo` | `content` | Institution logo (use `image()` function) | `image("school-logo.png", height: 0.6in)` |
| `leader` | `content` | Optional content to appear before the main body | `[]` |

## Features

- **Professional headers**: First page displays your logo and full information; subsequent pages show a compact header with your name and document title in small caps
- **Clean typography**: Optimized spacing and formatting for academic documents
- **Clickable links**: All links are automatically styled in blue
- **Bibliography support**: Optional bibliography section with clickable URLs (uses the `blinky` package)
- **Customizable styling**: 1-inch margins, 12pt headings, and refined paragraph spacing

