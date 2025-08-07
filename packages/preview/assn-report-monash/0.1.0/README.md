# Typst Report Template - Monash University Edition

A professional Typst package for Monash University student reports, featuring Monash's official brand colors and modern design elements.

## Acknowledgments

This project is based on the excellent [typst-polytechnique](https://github.com/remigerme/typst-polytechnique) template by [@remigerme](https://github.com/remigerme). The Monash University edition extends this work with Monash-specific branding, colors, and styles.

## Features

- **Professional Monash Branding**: Official Monash University colors and logo integration
- **Modern Cover Page**: Customizable cover with gradient background and watermark logo
- **Academic Metadata**: Support for student ID, course codes, tutor names, and word counts
- **Responsive Typography**: Professional formatting with Monash brand colors
- **Header & Footer**: Automatic page headers with course info and Monash logo
- **Modern Styling**: Enhanced functions for quotes, code blocks, tables, and figures
- **Theorem Environments**: Professional theorem, lemma, and proof environments using thmbox package
- **Multiple Document Types**: Support for assignments, theses, and research papers
- **Typst Attribution**: Optional "Made with Typst" badge

## Monash Color Scheme

This template uses Monash University's official brand colors:

- **Monash Blue** (#005DA6) - Primary brand color for main headings and cover text
- **Bright Blue** (#0066CC) - Secondary color for H2 headings
- **Monash Navy** (#00539C) - Medium contrast for H3 headings
- **Monash Yellow** (#FFD100) - Available as accent color
- **Deep Blue** (#003366) - Dark variant for backgrounds
- **Light Blue** (#E6F2FF) - Light variant for highlights

## Quick Start

### Basic Usage

```typ
#import "template/main.typ": *

#monash-report(
  "Machine Learning Applications in Healthcare",
  "Alex Johnson",
  subtitle: "A Comprehensive Analysis",
  student-id: "12345678",
  course-code: "FIT3080",
  course-name: "Introduction to AI",
  assignment-type: "Research Report",
  tutor-name: "Dr. Sarah Chen",
  date: datetime(year: 2025, month: 07, day: 30),
  word-count: 2500,
  show-typst-attribution: true
)[
  // Your content here
  = Introduction
  
  This is where your report content begins...
]
```

### Parameters

#### Required
- `title: str` - Report title (string)
- `author: str` - Author name (string)

#### Optional
- `subtitle: str | none` - Report subtitle (string or none, default: none)
- `student-id: str | none` - Student ID number (string or none, default: none)
- `course-code: str | none` - Course code (string or none, default: none)
- `course-name: str | none` - Full course name (string or none, default: none)
- `assignment-type: str` - Type of document (string, default: "Assignment")
- `tutor-name: str | none` - Tutor or supervisor name (string or none, default: none)
- `date: datetime | none` - Submission date (datetime or none, default: none)
- `word-count: int | none` - Word count for the report (integer or none, default: none)
- `despair-mode: bool` - Enable larger margins (boolean, default: false)
- `show-typst-attribution: bool` - Show "Made with Typst" badge (boolean, default: true)
- `show-outline: bool` - Show table of contents (boolean, default: true)
- `body: content` - Report content (content block)

### Function Signature

```typ
#let monash-report(
  title: str,
  author: str,
  subtitle: str | none = none,
  student-id: str | none = none,
  course-code: str | none = none,
  course-name: str | none = none,
  assignment-type: str = "Assignment",
  tutor-name: str | none = none,
  date: datetime | none = none,
  word-count: int | none = none,
  despair-mode: bool = false,
  show-typst-attribution: bool = true,
  show-outline: bool = true,
  body: content
) = content
```

## Advanced Features

### Theorem Environments

The template includes theorem environments powered by the `thmbox` package:

```typ
// Basic theorem
#theorem[thm name][
  Let $f: R -> R$ be a continuous function on the closed interval $[a, b]$. 
  Then $f$ attains its maximum and minimum values on $[a, b]$.
]

// Proof environment
#proof[
  Since $f$ is continuous on the closed and bounded interval $[a, b]$, 
  by the extreme value theorem, $f$ must attain both its maximum and 
  minimum values on this interval.
]

// Lemma
#lemma[lemma title][
  If a function $f$ is differentiable at a point $c$, then $f$ is continuous at $c$.
]
```
This templates overrides predefined theorem environments in thmbox with Monash-specific color schemes, so you may see all available theorem environments [here](https://github.com/s15n/typst-thmbox). 
The thmbox should be enough to cover most theorem environments you need, but you may also use the `#thmbox` function to create custom theorem boxes of your own.

Below are some other recommeded packages that you may find useful when using this template(there could be multiple packages available, yet I only recommend the ones I prefer):
- plotting & data visualization: 
  - https://typst.app/universe/package/lilaq
  - https://typst.app/universe/package/cetz
- pseudo-code: https://typst.app/universe/package/lovelace
- code listing: https://typst.app/universe/package/codly
- text-image formatting: https://typst.app/universe/package/wrap-it
- math shorthands: https://typst.app/universe/package/quick-maths
- :)for those who are taking FIT2014(good luck): 
  -https://typst.app/universe/package/finite
  -https://typst.app/universe/package/curryst 
- For FIT1047: 
  - https://typst.app/universe/package/k-mapper
  - https://typst.app/universe/package/circuiteria
- FIT2099: https://typst.app/universe/package/pintorita
- Note-taking: https://typst.app/universe/package/gentle-clues

## Using the Template

### Local Development
If you want to use this template locally, you can clone the repository and just work with it directly. 
1. Clone the repository:
```bash
git clone https://github.com/Eryc123Y/assn-report-monash.git
cd assn-report-monash
```

2. Ensure you have the "New Computer Modern Sans" font installed

3. Use the template by importing from your local copy

### Via Typst Package Manager

The package is available on the Typst package manager as `assn-report-monash
`.

## Project Structure

```
typst-report-monash/
├── template/
│   ├── main.typ          # Main template entry point
│   └── main.pdf          # Compiled example
├── monash-template/
│   └── report/
│       ├── cover.typ     # Cover page design
│       ├── heading.typ   # Heading styles
│       ├── page.typ      # Page setup and headers/footers
│       └── monash-colors.typ # Color definitions and styling
├── assets/
│   ├── Monash_University_logo_page.svg
│   ├── Monash_University-04.svg
│   ├── monash-university-logo-cover.svg
│   ├── filet-court.svg   # Decorative elements
│   ├── filet-long.svg    # Decorative elements
│   ├── thumbnail.png     # Package thumbnail
│   ├── typst.png         # Typst attribution logo
│   └── example.bib      # Example bibliography
├── example/
│   ├── example.typ       # Complete usage example
│   └── example.pdf       # Compiled example output
├── typst.toml           # Package configuration
├── README.md            # This documentation
├── LICENSE              # MIT License
└── CONTRIBUTING.md      # Contribution guidelines
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Examples

Check the `example/` directory for a complete sample report demonstrating all features. The example includes:
- Professional cover page
- Multiple heading levels
- Bibliography integration
- Table of contents
- Various styling elements

## Support

For issues and questions:
- Check the [existing issues](https://github.com/Eryc123Y/assn-report-monash/issues)
- Create a new issue if needed
- Review the example files for usage patterns
