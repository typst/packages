
[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/SnpM/typst-usaf-memo)

# tonguetoquill: USAF Memo Template for Typst

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.

## Features

- **Automatic formatting compliance** with AFH 33-337 standards
- **Hierarchical paragraph numbering** (1., a., (1), (a)) with proper indentation
- **Smart page break handling** for backmatter sections with continuation formatting
- **Professional typography** with Times New Roman font and proper spacing
- **Complete letterhead automation** including DoD seal placement and scaling
- **Flexible content management** for various memo types
- **Proper signature block positioning** and closing elements
- **Intelligent space management** prevents orphaned headers and improper splits

## Quick Start

### Installation

1. [Install Typst](*https://github.com/typst/typst?tab=readme-ov-file#installation).

2. Initialize template from Typst Universe
```bash
typst init @preview/tonguetoquill-usaf-memo:0.0.1
```

### Local Development

For working with the library files, you can clone this repository directly. See [build.sh](build.sh) for example commands to build the template files. For local development, [install the package locally](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages).

#### Fonts

`usaf-template.typ` and `ussf-template.typ` use Copperplate CC for the letterhead which is an open-source clone of Copperhead Gothic Bold. If you cloned the repository, Typst can recursively discover `template/assets/fonts/CopperplateCC-Bold.otf` like so:

```bash
typst compile --root . --font-path . template/usaf-template.typ pdfs/usaf-template.pdf
```

If you are using the Typst web app or local Typst Universe package, you can download [the `.otf` file](https://github.com/SnpM/typst-usaf-memo/blob/main/template/assets/fonts/CopperplateCC-Bold.otf) and upload it to the root folder in your project.

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:0.0.1": official-memorandum, indorsement, SET_LEVEL
```

See [`template/usaf-template.typ`](template/content-guide.typ) for a complete example of creating a memorandum with `official-memorandum()`.

## official-memorandum Parameters

### Core Parameters

- **letterhead-title** (string): Primary organization title (default: `"DEPARTMENT OF THE AIR FORCE"`)
- **letterhead-caption** (string): Sub-organization name (default: `"AIR FORCE EDUCATION COMMAND"`)
- **letterhead-seal** (string): Image for letterhead seal (default: `"image(template/assets/dod_seal.png)"`)
- **memo-for** (string | array): Recipient designation(s) (default: `("ORG/SYMBOL",)`). Can be:
  - Single recipient: `"ORG/SYMBOL"`
  - Multiple recipients: `("ORG1/SYMBOL", "ORG2/SYMBOL")`
  - Grid layout: `(("ORG1", "ORG2"), ("ORG3", "ORG4"))`
- **from-block** (array): Sender information (default: `("ORG/SYMBOL", "Organization", "Street Address", "City ST 80841-2024")`)
- **subject** (string): Memorandum subject line (default: `"Format for the Official Memorandum"`)
- **signature-block** (array): Signature lines (default: `("FIRST M. LAST, Rank, USAF", "AFIT Masters Student, Carnegie Mellon University", "Organization (if not on letterhead)")`)
- **references** (array): Reference documents (default: `none`)
- **attachments** (array): Attachment descriptions (default: `none`)
- **cc** (array): Courtesy copy recipients (default: `none`)
- **distribution** (array): Distribution list (default: `none`)
- **indorsements** (array): Indorsement objects (default: `none`)
- **body** (content): Main memorandum content (required, no default)

### Style Parameters

- **letterhead-font** (string): Letterhead font (default: `"Arial"`)
- **body-font** (string): Body font - must be Times New Roman (default: `"Times New Roman"`)
- **paragraph-block-indent** (boolean): Enable block indentation (default: `false`)
- **leading-backmatter-pagebreak** (boolean): Force page break before backmatter (default: `false`)

## Indorsement Parameters

The `indorsement()` function creates indorsement objects that can be passed to the `indorsements` parameter of `official-memorandum()`. Indorsements follow AFH 33-337 formatting standards for memorandum endorsements.

### Core Parameters

- **office-symbol** (string): Sending organization symbol (default: `"ORG/SYMBOL"`)
- **memo-for** (string): Recipient organization symbol (default: `"ORG/SYMBOL"`)
- **signature-block** (array): Array of signature lines (default: `("FIRST M. LAST, Rank, USAF", "Duty Title", "Organization (if not on letterhead)")`)
- **body** (content): Indorsement body content (required, no default)

### Optional Parameters

- **attachments** (array): Array of attachment descriptions (default: `none`)
- **cc** (array): Array of courtesy copy recipients (default: `none`)
- **leading-pagebreak** (boolean): Whether to force page break before indorsement (default: `false`)
- **separate-page** (boolean): Whether to use separate-page indorsement format per AFH 33-337 (default: `false`)

### Separate-Page Format Parameters

When `separate-page` is `true`, these parameters control the separate-page indorsement format:

- **original-office** (string): Original memo's office symbol (default: `none`)
- **original-date** (string): Original memo's date (default: `none`)
- **original-subject** (string): Original memo's subject (default: `none`)

### Complete Examples

For comprehensive examples with all parameters, see:
- **Guide**: `template/content-guide.typ` - Comprehensive guide showing all parameters and features with new paragraph level system
- **Standard Air Force memo**: `template/usaf-template.typ` - Shows proper formatting with references, attachments, cc, distribution, and indorsements
- **Space Force memo**: `template/ussf-template.typ` - Space Force memorandum variant with proper formatting
- **Custom organization memo**: `template/starkindustries.typ` - Demonstrates custom letterhead and extensive use of all optional parameters

## Paragraph Numbering

The template provides automatic hierarchical paragraph numbering following AFH 33-337 standards using a level-based system:

### Level-Based Paragraph System

Use `#SET_LEVEL(level)` to set the current paragraph level, then write content directly:

```typst
Your base paragraph content here.

Another base paragraph.

#SET_LEVEL(1)  // First-level subparagraphs: a., b., c., etc.

Your first subparagraph content.

Another first-level subparagraph.

#SET_LEVEL(2)  // Second-level subparagraphs: (1), (2), (3), etc.

Your second-level subparagraph content.

#SET_LEVEL(0)  // Return to base level
```

### Paragraph Hierarchy

- **Level 0** (Base paragraphs): 1., 2., 3., etc.
- **Level 1** (First-level subparagraphs): a., b., c., etc.
- **Level 2** (Second-level subparagraphs): (1), (2), (3), etc.
- **Level 3** (Third-level subparagraphs): (a), (b), (c), etc.
- **Level 4+** (Additional levels): Underlined numbering for complex structures

### Key Features

- **Automatic numbering** with proper hierarchical indentation
- **Smart spacing management** between paragraphs and sections
- **Level persistence** - once set, the level remains active until changed
- **Flexible structure** - supports up to five levels of nested paragraphs
- **AFH 33-337 compliance** - follows official formatting standards

## Sentence Spacing

The project includes GitHub Copilot prompts in `.github/prompts/` to help with sentence spacing formatting:

- **double-space-sentence.prompt.md**: Converts single spaces after sentences to double spaces (`~ `) within memo content
- **single-space-sentence.prompt.md**: Converts double spaces back to single spaces within memo content

These prompts help ensure consistent spacing formatting in your memorandums according to your organization's preferred style.

## Smart Page Break Handling

The template automatically manages page breaks for closing sections according to AFH 33-337 standards:

- **Attachments**: "Do not divide attachment listings between two pages"
- **Distribution**: "Do not divide distribution lists between two pages"
- **CC sections**: Consistent handling with other sections

### How It Works

1. **Content measurement**: Calculates if section fits on current page
2. **Automatic continuation**: Shows "(listed on next page)" when needed
3. **Clean breaks**: Moves entire sections to avoid orphaned headers
4. **Compliant formatting**: Follows exact AFH 33-337 continuation requirements

## Document Structure

The template automatically handles:

1. **Page setup**: US Letter size with 1-inch margins
2. **Typography**: 12pt Times New Roman font with proper line spacing
3. **Header elements**: DoD seal (scaled to 1in × 2in), letterhead, and date positioning
4. **Body formatting**: Justified text with proper paragraph spacing and numbering
5. **Signature block**: Positioned 4.5 inches from left edge
6. **Backmatter elements**: Attachments, cc, and distribution lists with smart page breaks
7. **Page numbering**: Starts on page 2, positioned 0.5" from top, flush right
8. **Continuation handling**: Proper "(listed on next page)" formatting for long sections

## Examples

The `template/` directory contains sample memorandums demonstrating various use cases:

- **usaf-template.typ**: Standard Air Force memorandum template
- **ussf-template.typ**: Space Force memorandum variant  
- **starkindustries.typ**: Pepper notifies Tony about regulatory issues for Iron Man suits.
- **content-guide.typ**: Comprehensive guide for using the official-memorandum template with new paragraph level system

## Compilation

When compiling templates that reference files from the root directory (such as the main library file `lib.typ`), you must use the `--root .` flag to tell Typst to treat the current directory as the root for resolving file imports.

## Requirements

- **Typst**: Version 0.13.0 or higher (enforced by template)
- **Assets**: The `template/assets/dod_seal.png` file must be accessible for the DoD seal
- **Fonts**: Times New Roman font (required for AFH 33-337 compliance)
- **Compliance**: All memorandums are automatically validated against AFH 33-337 standards

## Compliance Features

The template enforces strict AFH 33-337 compliance through:

- **Automatic validation** of required parameters and formatting with comprehensive error messages
- **Font enforcement** - only Times New Roman allowed for body text per regulations
- **Version checking** - requires Typst 0.13.0+ for proper functionality and modern features
- **Parameter validation** - ensures all mandatory elements are present before compilation
- **Signature block validation** - enforces proper format requirements per AFH 33-337
- **Enhanced spacing constants** - implements precise spacing requirements for professional formatting
- **Improved backmatter handling** - renamed from "closing" for better terminology alignment

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to the [GitHub repository](https://github.com/SnpM/typst-usaf-memo).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `template/assets/dod_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Seal_of_the_United_States_Department_of_Defense_(2001%E2%80%932022).svg).
- `template/assets/starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `template/assets/fonts/CopperplateCC-Bold.otf` is [SIL Open Font License](./template/assets/fonts/LICENSE.md)

## Author

Created by [Nibs](https://github.com/snpm)