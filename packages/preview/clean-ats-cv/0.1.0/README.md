# clean-ats-cv

A clean, ATS-friendly CV layout for [Typst](https://typst.app) with customizable colors and social icons.

## Features

- Clean, professional layout optimized for ATS (Applicant Tracking Systems)
- Customizable colors (primary, secondary, link colors)
- Bundled fonts (Carlito, DejaVu Sans) - no system fonts required
- Social icons included (LinkedIn, GitHub, X/Twitter)
- Flexible header with contact details
- Styled section headings with horizontal rules

## Installation

### From Typst Universe (after publishing)

```typ
#import "@preview/clean-ats-cv:0.1.0": *
```

### Local installation

Clone this repository to your local Typst packages directory:

```bash
# macOS
git clone https://github.com/NicolaiSchmid/clean-ats-cv.git \
  ~/Library/Application\ Support/typst/packages/local/clean-ats-cv/0.1.0

# Linux
git clone https://github.com/NicolaiSchmid/clean-ats-cv.git \
  ~/.local/share/typst/packages/local/clean-ats-cv/0.1.0

# Windows
git clone https://github.com/NicolaiSchmid/clean-ats-cv.git \
  %APPDATA%/typst/packages/local/clean-ats-cv/0.1.0
```

Then import with:

```typ
#import "@local/clean-ats-cv:0.1.0": *
```

## Usage

```typ
#import "@preview/clean-ats-cv:0.1.0": conf, date, dateLocation

#show: doc => conf((
  name: "Your Name",
  phonenumber: "+1 234 567 890",
  email: "your@email.com",
  address: "City, Country",
  linkedin: "linkedin.com/in/yourprofile",
  linkedin_label: "/in/yourprofile",
  github: "github.com/yourusername",
  github_label: "/yourusername",
), doc)

= Professional Experience

== Software Engineer #dateLocation([Company Name], [2020 -- present], [Berlin])
- Built scalable systems serving millions of users
- Led a team of 5 engineers

== Junior Developer #date([Startup Inc.], [2018 -- 2020])
- Full-stack development with React and Node.js
```

## Functions

### `conf(details, doc)`

Main configuration function. Apply with a show rule.

**Parameters:**
- `details` - Dictionary with contact information:
  - `name` (required) - Your full name
  - `email` - Email address
  - `phonenumber` - Phone number
  - `address` - Location/address
  - `linkedin` - LinkedIn URL (without https://)
  - `linkedin_label` - Display text for LinkedIn link
  - `github` - GitHub URL (without https://)
  - `github_label` - Display text for GitHub link
  - `twitter` - X/Twitter URL (without https://)
  - `twitter_label` - Display text for X link
- `primary_color` - Color for headings (default: `#022359`)
- `secondary_color` - Color for dates/locations (default: `#757575`)
- `link_color` - Color for links (default: `#14A4E6`)
- `font` - Main font (default: `Carlito`)
- `math_font` - Math font (default: `DejaVu Sans`)

### `dateLocation(company, date, location)`

Format an entry with company, date, and location.

### `date(company, date)`

Format an entry with company and date only.

## Customization

Override default colors:

```typ
#show: doc => conf(
  primary_color: rgb("#1a1a2e"),
  secondary_color: rgb("#4a4a4a"),
  link_color: rgb("#0077b5"),
  (
    name: "Your Name",
    email: "you@example.com",
  ),
  doc
)
```

## License

MIT License - see [LICENSE](LICENSE) for details.

Bundled fonts are licensed under their respective licenses:
- Carlito: SIL Open Font License
- DejaVu Sans: Bitstream Vera License

## Publishing to Typst Universe

To submit this package to Typst Universe:

1. Fork [typst/packages](https://github.com/typst/packages)
2. Copy this package to `packages/preview/clean-ats-cv/0.1.0/`
3. Open a Pull Request

See the [Typst package submission guidelines](https://github.com/typst/packages/blob/main/docs/README.md) for details.
