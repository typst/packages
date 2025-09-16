

# tonguetoquill: USAF Memo Template for Typst


[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/SnpM/tonguetoquill-usaf-memo)
[![Nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/SnpM)

[![typst-universe](https://img.shields.io/badge/Typst-Universe-aqua)](
https://github.com/snpm/tonguetoquill-usaf-memo)

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

### Typst.app (Easiest)

1. Go to [the package page](https://typst.app/universe/package/tonguetoquill-usaf-memo) and click "Create project in app".

3. Download the [*CopperplateCC-Heavy*](https://github.com/SnpM/tonguetoquill-usaf-memo/blob/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf) font and upload it to your project folder. This is an open-source clone of *Copperplate Gothic Bold*.
    - **Note:** *Times New Roman* is a proprietary Microsoft font that I can't distribute legally. The package will automatically use the built-in *TeX Gyre Termes* font, an open-source clone of *Times New Roman*.

### Local Installation

1. [Install Typst](https://github.com/typst/typst?tab=readme-ov-file#installation).

2. Initialize template from Typst Universe
```bash
typst init @preview/tonguetoquill-usaf-memo:0.1.0
```

3. Compile a `.typ` template file of your choice:
```bash
typst compile --root . --font-path . template/starkindustries.typ pdfs/starkindustries.pdf
```

### Local Development

Clone [the repo](https://github.com/SnpM/tonguetoquill-usaf-memo). Follow [these instructions](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) to install the package locally. 

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum, indorsement
```

See `template/content-guide.typ` for a complete example of creating an `official-memorandum()` with `indorsement` sections. For a concise, standard memo, see `template/usaf-template.typ`.

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

+ Level 1 subparagraph lettered as a., b., etc.
  + Level 2 subparagraph numbered as (1), (2), etc.
    + Level 3 subparagraph lettered as (a), (b), etc.

This returns to base paragraph numbering as 2.
```

### Tips
- Base-level paragraphs are plain text lines; do not prefix them with `+`.
- Increase depth by adding leading spaces before `+` (two spaces per level works well).
- Keep items contiguous—an empty line ends the list and returns to the base level.
- Indentation and alignment are handled for you; subparagraphs align with proper tab stops.
- Numbering and spacing are automatic and AFH 33-337 compliant.

### Common pitfalls
- Using `-` or `*` instead of `+` creates a bullet list, not a numbered enum.
- Misaligned nesting: ensure nested `+` items are indented more than their parent.

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

## Examples

The `template/` directory contains sample memorandums demonstrating various use cases:

- [**usaf-template.typ**](template/usaf-template.typ): Standard Air Force memorandum template
- [**ussf-template.typ**](template/ussf-template.typ): Space Force memorandum variant
- [**starkindustries.typ**](template/starkindustries.typ): Pepper notifies Tony about regulatory issues for Iron Man suits.
- [**content-guide.typ**](template/content-guide.typ): Comprehensive guide for using the official-memorandum template with enum-based paragraph system

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to the [GitHub repository](https://github.com/SnpM/tonguetoquill-usaf-memo).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `dod_seal.gif` is [public domain](https://www.e-publishing.af.mil/Portals/1/Documents/Official%20Memorandum%20Template_10Nov2020.dotx?ver=M7cny_cp1_QDajkyg0xWBw%3D%3D)
- `starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `Copperlate CC` is under [SIL Open Font License](./template/assets/fonts/LICENSE.md) pulled from [here](https://github.com/CowboyCollective/CopperplateCC)
- `TeX Gyre Termes` is under [GUST Font License](https://www.gust.org.pl/projects/e-foundry/tex-gyre/term) pulled from [here](https://www.fontsquirrel.com/fonts/tex-gyre-termes)