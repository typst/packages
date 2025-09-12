# University of Melbourne Thesis Template Assets

This directory contains official University of Melbourne brand assets and design system components used in the Typst thesis template.

## Directory Structure

```
assets/
├── colors/
│   └── unimelb-colors.typ          # Official color palette definitions
├── fonts/
│   └── [Font files]                # Official typography (Fraunces, Source Sans Pro)
├── logos/
│   ├── unimelb-logo-official.svg   # Official University of Melbourne logo
│   └── unimelb-logo-custom.svg     # Custom logo variant (backup)
└── icons/
    └── [Icon files]                # Official icon set
```

## Official Sources

### Logo

- **Source**: <https://designsystem.web.unimelb.edu.au/components/logo-listing/>
- **File**: `unimelb-logo-official.svg`
- **Usage**: Primary logo for title pages and official documents
- **Note**: University of Melbourne logo should NOT be used in thesis content (per thesis guidelines 3.6)

### Colors

- **Source**: <https://designsystem.web.unimelb.edu.au/style-guide/colour-palette/>
- **File**: `unimelb-colors.typ`
- **Primary Brand Color**: Traditional Heritage Blue (#000F46)
- **Usage Guidelines**: See comments in color file

### Fonts

- **Primary Font**: Fraunces (display/headings)
- **Secondary Font**: Source Sans Pro (body text)
- **Source**: Google Fonts (Fraunces), Adobe (Source Sans Pro)
- **Fallback**: System fonts when official fonts unavailable

### Icons

- **Source**: <https://designsystem.web.unimelb.edu.au/style-guide/icons/>
- **Usage**: Consistent iconography across University materials

## Usage in Template

```typst
// Import colors
#import "../assets/colors/unimelb-colors.typ": *

// Use official logo (only on title page, not in content)
#image("../assets/logos/unimelb-logo-official.svg", width: 200pt)

// Apply brand colors
#set text(fill: traditional-heritage-100)
#box(fill: magpie-light-25, inset: 1em)[Content]
```

## Compliance Notes

- **Thesis Guidelines**: Logo usage restricted per University policy
- **Brand Consistency**: All colors and assets follow Gen 3 Design System
- **Accessibility**: Color combinations tested for WCAG compliance
- **Cross-platform**: Font fallbacks ensure consistent rendering

## Version History

- **2025-09-11**: Initial asset collection from Gen 3 Design System
- Colors, logo, and documentation updated to current standards
- Fonts sourced from official Google Fonts and Adobe repositories
