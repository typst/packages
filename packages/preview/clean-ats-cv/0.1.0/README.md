# clean-ats-cv

A clean, ATS-friendly CV layout for [Typst](https://typst.app) with customizable colors and social icons.

## Features

- Clean, professional layout optimized for ATS (Applicant Tracking Systems)
- Customizable colors (primary, secondary, link colors)
- Social icons included (LinkedIn, GitHub, X/Twitter)
- Flexible header with contact details
- Styled section headings with horizontal rules

## Required Fonts

This package uses the following fonts which must be installed on your system:

- **[Carlito](https://fonts.google.com/specimen/Carlito)** - Main text font (free, Google Fonts)
- **[DejaVu Sans](https://dejavu-fonts.github.io/)** - Math font (free, open source)

### Installing fonts

**macOS:**
```bash
# Using Homebrew
brew install --cask font-carlito font-dejavu
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install fonts-crosextra-carlito fonts-dejavu
```

**Windows:**
Download and install from the links above.

## Installation

### From Typst Universe

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
#import "@preview/clean-ats-cv:0.1.0": conf, date, date-location

#show: conf.with(
  details: (
    name: "Your Name",
    phonenumber: "+1 234 567 890",
    email: "your@email.com",
    address: "City, Country",
    linkedin: "linkedin.com/in/yourprofile",
    linkedin-label: "/in/yourprofile",
    github: "github.com/yourusername",
    github-label: "/yourusername",
  ),
)

= Professional Experience

== Software Engineer #date-location([Company Name], [2020 -- present], [Berlin])
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
  - `linkedin-label` - Display text for LinkedIn link
  - `github` - GitHub URL (without https://)
  - `github-label` - Display text for GitHub link
  - `twitter` - X/Twitter URL (without https://)
  - `twitter-label` - Display text for X link
- `primary-color` - Color for headings (default: `#022359`)
- `secondary-color` - Color for dates/locations (default: `#757575`)
- `link-color` - Color for links (default: `#14A4E6`)
- `font` - Main font (default: `Carlito`)
- `math-font` - Math font (default: `DejaVu Sans`)

### `date-location(company, date, location)`

Format an entry with company, date, and location.

### `date(company, date)`

Format an entry with company and date only.

## Customization

Override default colors:

```typ
#show: conf.with(
  primary-color: rgb("#1a1a2e"),
  secondary-color: rgb("#4a4a4a"),
  link-color: rgb("#0077b5"),
  details: (
    name: "Your Name",
    email: "you@example.com",
  ),
)
```

## License

MIT License - see [LICENSE](LICENSE) for details.

### Icons

The social media icons included in this package are original SVG files created for this project and are released under the same MIT license. These icons visually represent LinkedIn, GitHub, and X (Twitter) brands - please refer to each platform's brand guidelines for trademark usage requirements.
