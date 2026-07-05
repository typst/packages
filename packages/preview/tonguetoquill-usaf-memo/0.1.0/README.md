# tonguetoquill: USAF Memo Template for Typst


[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/SnpM/tonguetoquill-usaf-memo)
[![typst-universe](https://img.shields.io/badge/Typst-Universe-aqua)](https://github.com/snpm/tonguetoquill-usaf-memo)
[![nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/SnpM)

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.

## Features

### Core Formatting
- **Full AFH 33-337 compliance** with "The Tongue and Quill" formatting standards
- **Automatic letterhead generation** with configurable organization title, caption, and seal
- **Pixel-perfect typesetting** for all memorandum components in AFH 33-337
- **Hierarchical paragraph numbering** (1., a., (1), (a)) with proper indentation
- **Comprehensive backmatter** (Attachments, CC, Distribution) with smart formatting
- **Page numbering** starting from page 2 per AFH 33-337 standards
- **Highly Configurable** with numerous parameters for customization
- **Standard and Separate Page Indorsements** with full support for long indorsement chains

## Quick Start

### Typst.app (Easiest)

1. Go to [the package page](https://typst.app/universe/package/tonguetoquill-usaf-memo) and click "Create project in app".

2. Download the [*CopperplateCC-Heavy*](https://github.com/SnpM/tonguetoquill-usaf-memo/blob/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf) font and upload it to your project folder. This is an open-source clone of *Copperplate Gothic Bold*.
    - **Note:** *Times New Roman* is a proprietary Microsoft font that I can't distribute legally. The package will automatically use the built-in *TeX Gyre Termes* font, an open-source clone of *Times New Roman*.

3. Start with one of the template files:
   - `template/usaf-template.typ` for a standard Air Force memo
   - `template/ussf-template.typ` for Space Force
   - `template/stark-industries.typ` for a custom organization example

### Local Installation

1. [Install Typst](https://github.com/typst/typst?tab=readme-ov-file#installation).

2. Initialize template from Typst Universe:
```bash
typst init @preview/tonguetoquill-usaf-memo:0.1.0 my-memo
cd my-memo
```

3. Download the required font:
```bash
# Download CopperplateCC-Heavy font
curl -L -o CopperplateCC-Heavy.otf https://github.com/SnpM/tonguetoquill-usaf-memo/raw/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf
```

4. Compile a template file:
```bash
typst compile --font-path . template/usaf-template.typ my-memo.pdf
```

### Local Development

Clone [the repo](https://github.com/SnpM/tonguetoquill-usaf-memo) and follow [these instructions](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) to install the package locally for development.

```bash
git clone https://github.com/SnpM/tonguetoquill-usaf-memo.git
cd tonguetoquill-usaf-memo
./build.sh  # Compile all template esamples
```

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum, indorsement
```

**Minimal Example:**
```typst
#official-memorandum(
  subject: "Your Subject Here",
)[
Your memorandum content goes here.

- Use plus signs for numbered subparagraphs.
  - Indent with spaces for deeper nesting.

Continue with regular paragraphs.
]
```

See the [API Reference](#api-reference) section below for complete parameter documentation.

### Complete Examples

For comprehensive examples with all parameters, see:
- **Guide**: `template/content-guide.typ` - Comprehensive guide showing all parameters and features with enum-based paragraph system
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

### Core Functions

#### `official-memorandum(...)`

Creates an official memorandum following AFH 33-337 "The Tongue and Quill" standards.

**Required Parameters:**
- `subject`: Memorandum subject line (must be descriptive and in title case)
- `body`: Main memorandum content (use enums for numbered paragraphs)

**Key Parameters:**
```typst
official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",           // Organization title
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",           // Sub-organization
  letterhead-seal: none,                                     // Organization seal image
  date: none,                                                // Date (defaults to today)
  memo-for: ("[OFFICE1]", "[OFFICE2]"),                     // Recipients array
  memo-from: ("[YOUR/SYMBOL]", "[Organization]", "[Address]"), // Sender info array
  subject: "[Your Subject in Title Case - Required]",        // Subject line
  references: ("AFI 123-45", "AFMAN 67-89"),                // Optional references
  signature-block: ("[NAME, Rank, USAF]", "[Title]"),       // Signature lines
  attachments: ("Attachment 1", "Attachment 2"),             // Optional attachments
  cc: ("[OFFICE/SYMBOL]",),                                 // Courtesy copies
  distribution: ("[OFFICE]",),                              // Distribution list
  indorsements: (indorsement(...),),                        // Optional indorsements
  
  // Styling options
  letterhead-font: ("Copperplate CC",),                     // Letterhead fonts
  body-font: ("times new roman", "tex gyre termes"),        // Body fonts
  memo-for-cols: 3,                                         // Recipient columns
  paragraph-block-indent: false,                            // Paragraph indentation
  leading-backmatter-pagebreak: false,                      // Force page break
  
  // Document body content goes here
)[Your memorandum content with enum lists for numbered paragraphs]
```

#### `indorsement(...)`

Creates an indorsement for forwarding or commenting on a memorandum.

```typst
indorsement(
  office-symbol: "ORG/SYMBOL",                              // Sending organization
  memo-for: "RECIPIENT/SYMBOL",                             // Recipient organization
  signature-block: ("[NAME, Rank, USAF]", "[Title]"),      // Signature lines
  attachments: none,                                         // Optional attachments
  cc: none,                                                 // Courtesy copies
  leading-pagebreak: false,                                 // Force page break
  separate-page: false,                                     // Separate page format
  indorsement-date: datetime.today(),                       // Indorsement date
  
  // Indorsement body content
)[Your indorsement content]
```

## Development

### Contributing

Contributions are welcome! Please explore `src/` for core functions and `template/` for the user-facing examples. Feel free to open issues or submit pull requests.

### Project Structure

```
├── src/
│   ├── lib.typ          # Main template functions
│   └── utils.typ        # Utility functions and helpers
├── template/
│   ├── *.typ           # Example template files
│   └── assets/         # Fonts and images
├── pdfs/               # Compiled example outputs
└── README.md           # This documentation
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `dod_seal.gif` is [public domain](https://www.e-publishing.af.mil/Portals/1/Documents/Official%20Memorandum%20Template_10Nov2020.dotx?ver=M7cny_cp1_QDajkyg0xWBw%3D%3D)
- `starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `Copperlate CC` is under [SIL Open Font License](./template/assets/fonts/LICENSE.md) pulled from [here](https://github.com/CowboyCollective/CopperplateCC)
- `TeX Gyre Termes` is under [GUST Font License](https://www.gust.org.pl/projects/e-foundry/tex-gyre/term) pulled from [here](https://www.fontsquirrel.com/fonts/tex-gyre-termes)