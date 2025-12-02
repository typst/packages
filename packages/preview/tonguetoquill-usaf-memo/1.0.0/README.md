# tonguetoquill: USAF Memo Template for Typst


[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/nibsbin/tonguetoquill-usaf-memo)
[![typst-universe](https://img.shields.io/badge/Typst-Universe-aqua)](https://github.com/nibsbin/tonguetoquill-usaf-memo)
[![nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/nibsbin)

> Less formatting. More lethality.

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards. 

Maintained by [tonguetoquill.com](https://www.tonguetoquill.com).

## Features

### Core Formatting
- **Full AFH 33-337 compliance** with "The Tongue and Quill" formatting standards
- **Automatic letterhead generation** with configurable organization title, caption, and seal
- **Pixel-perfect typesetting** for all memorandum components in AFH 33-337
- **Hierarchical paragraph numbering** (1., a., (1), (a)) with proper indentation
- **Comprehensive backmatter** (Attachments, CC, Distribution) with smart formatting
- **Page numbering** starting from page 2 per AFH 33-337 standards
- **Highly Configurable** with numerous parameters for customization
- **Standard and New Page Indorsements** with full support for long indorsement chains

## Quick Start

### Typst.app (Easiest)

1. Go to [the package page](https://typst.app/universe/package/tonguetoquill-usaf-memo) and click "Create project in app".

2. Download the [*CopperplateCC-Heavy*](https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/CopperplateCC/CopperplateCC-Heavy.otf) font and upload it to your project folder. This is an open-source clone of *Copperplate Gothic Bold*.
    - **Note:** *Times New Roman* is a proprietary Microsoft font that I can't distribute legally. The package will automatically use the built-in *NimbusRomNo9L* font, an open-source clone of *Times New Roman*.

3. Start with one of the template files:
   - `template/usaf-template.typ` for a standard Air Force memo
   - `template/ussf-template.typ` for Space Force
   - `template/stark-industries.typ` for a custom organization example

### Local Installation

1. [Install Typst](https://github.com/typst/typst?tab=readme-ov-file#installation).

2. Initialize template from Typst Universe:
```bash
typst init @preview/tonguetoquill-usaf-memo:0.2.0 my-memo
cd my-memo
```

3. Download the required font:
```bash
# Download CopperplateCC-Heavy font
curl -L -o CopperplateCC-Heavy.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/CopperplateCC/CopperplateCC-Heavy.otf
```

4. Compile a template file:
```bash
typst compile --font-path . template/usaf-template.typ my-memo.pdf
```

### Local Development

Clone [the repo](https://github.com/nibsbin/tonguetoquill-usaf-memo) and follow [these instructions](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) to install the package locally for development.

```bash
git clone https://github.com/nibsbin/tonguetoquill-usaf-memo.git
cd tonguetoquill-usaf-memo
./build.sh  # Compile all template examples
```

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:1.0.0": frontmatter, mainmatter, backmatter, indorsement
```

**Minimal Example:**
```typst
#show: frontmatter.with(
  subject: "Your Subject Here",
  memo_for: ("OFFICE/SYMBOL",),
  memo_from: ("YOUR/SYMBOL",),
)

#show: mainmatter

Your memorandum content goes here.

- Use plus signs for numbered subparagraphs.
  - Indent with spaces for deeper nesting.

Continue with regular paragraphs.

#backmatter(
  signature_block: ("NAME, Rank, USAF", "Title"),
)
```

See the [API Reference](#api-reference) section below for complete parameter documentation.

### Complete Examples

For comprehensive examples with all parameters, see:
- **Standard Air Force memo**: `template/usaf-template.typ` - Shows proper formatting with references, attachments, cc, distribution, and indorsements
- **Space Force memo**: `template/ussf-template.typ` - Space Force memorandum variant with proper formatting
- **Custom organization memo**: `template/starkindustries.typ` - Demonstrates custom letterhead and extensive use of all optional parameters

## Additional usage details

### Paragraph numbering

AFH 33-337–compliant hierarchical numbering using Typst's native enum lists.

```typst
Base paragraph numbered as 1., 2., etc.

- Level 1 subparagraph lettered as a., b., etc.
  - Level 2 subparagraph numbered as (1), (2), etc.
    - Level 3 subparagraph lettered as (a), (b), etc.

This returns to base paragraph numbering as 2.
```

### Sentence spacing

The project includes GitHub Copilot prompts in `.github/prompts/` to help with sentence spacing formatting:

- **double-space-sentence.prompt.md**: Converts single spaces after sentences to double spaces (`~ `) within memo content
- **single-space-sentence.prompt.md**: Converts double spaces back to single spaces within memo content

These prompts help ensure consistent spacing formatting in your memorandums according to your organization's preferred style.

### Smart page break handling

The template automatically manages page breaks for closing sections according to AFH 33-337 standards:

- **Attachments**: "Do not divide attachment listings between two pages"
- **Distribution**: "Do not divide distribution lists between two pages"
- **CC sections**: Consistent handling with other sections

## API Reference

The template uses a **composable show rules architecture** where you apply each section in order: frontmatter → mainmatter → backmatter → indorsements.

### Core Functions

#### `frontmatter(...)`

Configures the memorandum header and establishes document-wide settings. Applied as a show rule.

**Required Parameters:**
- `subject`: Memorandum subject line (must be descriptive and in title case)
- `memo_for`: Recipients (string or array of office symbols)
- `memo_from`: Sender information (string or array with office symbol, organization, address)

**Key Parameters:**
```typst
#show: frontmatter.with(
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",           // Organization title
  letterhead_caption: "[YOUR SQUADRON/UNIT NAME]",           // Sub-organization
  letterhead_seal: none,                                     // Organization seal image
  date: none,                                                // Date (defaults to today)
  memo_for: ("[OFFICE1]", "[OFFICE2]"),                     // Recipients array
  memo_from: ("[YOUR/SYMBOL]", "[Organization]", "[Address]"), // Sender info array
  subject: "[Your Subject in Title Case - Required]",        // Subject line
  references: ("AFI 123-45", "AFMAN 67-89"),                // Optional references

  // Styling options
  letterhead_font: ("Copperplate CC",),                     // Letterhead fonts
  body_font: ("times new roman", "NimbusRomNo9L"),          // Body fonts
  memo_for_cols: 3,                                         // Recipient columns
)
```

**Responsibilities:**
- Sets page layout with 1-inch margins
- Renders letterhead with optional seal
- Renders date, MEMORANDUM FOR, FROM, SUBJECT, and references sections
- Establishes typography and spacing rules
- Stores configuration for downstream sections

#### `mainmatter`

Processes the memorandum body content with automatic paragraph numbering. Applied as a show rule with no parameters.

```typst
#show: mainmatter
```

**Responsibilities:**
- Applies AFH 33-337 hierarchical paragraph numbering (1., a., (1), (a))
- Handles proper indentation and spacing
- Auto-detects single vs. multiple paragraphs
- Inherits configuration from frontmatter

#### `backmatter(...)`

Renders the closing section including signature block and optional attachments/cc/distribution. Called as a function (not a show rule).

**Key Parameters:**
```typst
#backmatter(
  signature_block: ("[NAME, Rank, USAF]", "[Title]"),      // Signature lines (required)
  signature_blank_lines: 4,                                // Blank lines above signature
  attachments: ("Attachment 1", "Attachment 2"),            // Optional attachments
  cc: ("[OFFICE/SYMBOL]",),                                // Courtesy copies
  distribution: ("[OFFICE]",),                             // Distribution list
  leading_pagebreak: false,                                // Force page break before backmatter
)
```

**Responsibilities:**
- Renders signature block with orphan prevention
- Renders attachments section with smart page breaks
- Renders cc section
- Renders distribution list

#### `indorsement(...)`

Creates an indorsement for forwarding or commenting on a memorandum. Called as a function with content body.

```typst
#indorsement(
  from: "ORG/SYMBOL",                                       // Sending organization
  to: "RECIPIENT/SYMBOL",                                   // Recipient organization
  signature_block: ("[NAME, Rank, USAF]", "[Title]"),      // Signature lines
  signature_blank_lines: 4,                                // Blank lines above signature
  attachments: none,                                        // Optional attachments
  cc: none,                                                 // Courtesy copies
  leading_pagebreak: false,                                // Force page break before indorsement
  new_page: false,                                         // New page format
  date: datetime.today(),                                  // Indorsement date
)[
  Your indorsement content here.
]
```

**Responsibilities:**
- Auto-numbers indorsements (1st Ind, 2d Ind, 3d Ind, etc.)
- Renders indorsement header with from/to
- Processes indorsement body content
- Renders signature block and backmatter sections
- References original memo metadata

## Development

### Contributing

Contributions are welcome! Please explore `src/` for core functions and `template/` for the user-facing examples. Feel free to open issues or submit pull requests.

### Project Structure

```
├── src/                     # Core implementation
│   ├── lib.typ              # Public API exports
│   ├── config.typ           # Configuration constants
│   ├── frontmatter.typ      # Header section show rule
│   ├── mainmatter.typ       # Body content show rule
│   ├── backmatter.typ       # Closing section rendering
│   ├── indorsement.typ      # Indorsement rendering
│   ├── primitives.typ       # Reusable rendering functions
│   └── utils.typ            # Utility functions and helpers
├── template/                # Example templates
│   ├── usaf-template.typ    # Standard Air Force memo
│   ├── ussf-template.typ    # Space Force variant
│   ├── starkindustries.typ  # Custom organization example
│   └── assets/              # Fonts and images
├── prose/                   # Design documentation
│   ├── designs/             # Active design documents
│   ├── plans/               # Implementation plans
│   └── archive/             # Archived designs and analyses
├── pdfs/                    # Compiled example outputs
└── README.md                # This documentation
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `dow_seal.png` is [public domain](https://www.e-publishing.af.mil/Portals/1/Documents/Official%20Memorandum%20Template_10Nov2020.dotx?ver=M7cny_cp1_QDajkyg0xWBw%3D%3D)
- `starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `Copperplate CC` is under [SIL Open Font License](./fonts/CopperplateCC/LICENSE.md) pulled from [here](https://github.com/CowboyCollective/CopperplateCC)
- `NimbusRomNo9L` is under [GPL](./fonts/NimbusRomanNo9L/GNU%20General%20Public%20License.txt) pulled from URW++ foundry