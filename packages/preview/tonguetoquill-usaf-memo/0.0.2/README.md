

# tonguetoquill: USAF Memo Template for Typst


[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/SnpM/tonguetoquill-usaf-memo)
[![Nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/SnpM)

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
typst init @preview/tonguetoquill-usaf-memo:0.0.2
```

3. Compile a `.typ` template file of your choice:
```bash
typst compile --root . template/starkindustries.typ pdfs/starkindustries.pdf
```

### Local Development

For working with the library files, you can clone this repository directly. See [build.sh](build.sh) for example commands to build the template files. For local development, [install the package locally](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages).

#### Fonts

`usaf-template.typ` and `ussf-template.typ` use Copperplate CC for the letterhead which is an open-source clone of Copperhead Gothic Bold. If you cloned the repository, Typst can recursively discover `template/assets/fonts/CopperplateCC-Bold.otf` like so:

```bash
typst compile --root . --font-path . template/usaf-template.typ pdfs/usaf-template.pdf
```

If you are using the Typst web app or local Typst Universe package, you can download [the `.otf` file](https://github.com/SnpM/tonguetoquill-usaf-memo/blob/main/template/assets/fonts/CopperplateCC-Bold.otf) and upload it to the root folder in your project.

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:0.0.2": official-memorandum, indorsement
```

See [`template/usaf-template.typ`](template/content-guide.typ) for a complete example of creating an `official-memorandum()` with `indorsement` sections.

### Complete Examples

For comprehensive examples with all parameters, see:
- **Guide**: `template/content-guide.typ` - Comprehensive guide showing all parameters and features with enum-based paragraph system
- **Standard Air Force memo**: `template/usaf-template.typ` - Shows proper formatting with references, attachments, cc, distribution, and indorsements
- **Space Force memo**: `template/ussf-template.typ` - Space Force memorandum variant with proper formatting
- **Custom organization memo**: `template/starkindustries.typ` - Demonstrates custom letterhead and extensive use of all optional parameters

## Paragraph Numbering

The template provides automatic hierarchical paragraph numbering following AFH 33-337 standards using Typst's native numbered list syntax:

```typst
Base paragraph numbered as 1., 2., etc.

+ Level 1 subparagraph lettered as a., b., etc.

  + Level 2 subparagraph numbered as (1), (2), etc.
    
    + Level 3 subparagraph lettered as (a), (b), etc.

This returns to base paragraph numbering as 2.
```

### Key Features

- **Natural Typst syntax** - Uses standard enum formatting familiar to Typst users
- **Automatic numbering** with proper hierarchical indentation
- **Smart spacing management** between paragraphs and sections
- **Tab-aligned indentation** - Subparagraphs align with proper tab spacing
- **Progressive indentation** - Use increasing spaces before `+` for deeper levels
- **Flexible structure** - supports multiple levels of nested paragraphs
- **AFH 33-337 compliance** - follows official formatting standards automatically

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

## Examples

The `template/` directory contains sample memorandums demonstrating various use cases:

- **usaf-template.typ**: Standard Air Force memorandum template
- **ussf-template.typ**: Space Force memorandum variant  
- **starkindustries.typ**: Pepper notifies Tony about regulatory issues for Iron Man suits.
- **content-guide.typ**: Comprehensive guide for using the official-memorandum template with enum-based paragraph system

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to the [GitHub repository](https://github.com/SnpM/tonguetoquill-usaf-memo).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `template/assets/dod_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Seal_of_the_United_States_Department_of_Defense_(2001%E2%80%932022).svg).
- `template/assets/starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `template/assets/fonts/Copperplate-Heavy.otf` is [SIL Open Font License](./template/assets/fonts/LICENSE.md) pulled from [here](https://github.com/CowboyCollective/CopperplateCC)