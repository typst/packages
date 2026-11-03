# Changelog

## v0.6.0 (2026-10-13)

### Added

- New `print-billing-info` parameter (default `true`) to control whether `billing-info` is printed on the payment part

### Changed

- **`billing-info` is now printed on the payment part by default.** It was encoded in the QR code but never rendered. Version 2.3 of the Swiss Implementation Guidelines dropped the obligation to print the "Billing information" field on the payment part (see the revision history entry for chapter 4.3.3, in force since 1 January 2024): it may be printed, and is mandatory only when the field contains personal data. The package cannot know whether a given payload carries personal data, so it prints on the safe side. It appears under the "Additional information" heading below `additional-info`, matching the reference images in `tests/muster`. Set `print-billing-info: false` to keep the previous output

### Fixed

- Long billing strings wrap at their `/` separators instead of running out of the payment part
- **The receipt and the payment part now lay out their text in the sections the specification defines.** The receipt used the full 62mm of the receipt as its text width, and the payment part was a 148mm block placed at 68mm, so a long address crossed the perforation into the payment part and the payment part's information column ran 6mm past the right edge of the page. The receipt now uses the 52mm information section, and the payment part the 51mm payment part section plus the 87mm information section, starting at 67mm. On the page, the QR code moves 1mm to the left and the payment part's information column 5mm to the left, from 123mm to 118mm
- "Acceptance point" on the receipt is right-aligned to the edge of the receipt's 52mm section and ends at 57mm. It ended at 59mm, 2mm outside the section
- Addresses are no longer justified when the surrounding document sets `par(justify: true)`, which stretched the spaces of every address line that wraps
- **The blank amount field on the payment part no longer extends into the information section.** On a bill without an amount, the 40 × 15mm field ran from 81mm to 121mm and collided with the "Payable by (name/address)" field. It now spans 76mm to 116mm, inside the payment part section with a 2mm gap to the information section. A currency heading wider than the 9mm left for the currency ("Currency", "Währung", "Monnaie") moves the "Amount" heading right instead of overlapping it
- An empty or whitespace-only `reference` no longer prints a bare "Reference" heading on the receipt and the payment part. The guidelines require the heading of an empty optional element to be omitted, so such a reference is now treated like `reference: none`
- An empty `additional-info` no longer prints a bare "Additional information" heading on the payment part. It is now treated like `additional-info: none`

## v0.5.0 (2026-08-17)

### Added

- **Automatic language detection**: `language` now accepts `auto` and is the new default, resolving the bill language from the document's `text.lang`
- Alt text on the QR code and all layout icons, improving accessibility of the generated output

### Changed

- **Default language is no longer hard-coded to German.** With the new `auto` default, a document that sets `#set text(lang: "fr")` will render a French QR bill where it previously rendered German. Pass `language: "de"` explicitly to keep the old behavior.
- The fallback for an unrecognized language is now German instead of English

## v0.4.1 (2025-11-23)

### Changed

- Replaced dingbat font scissors symbol with official SVG icon from SIX

## v0.4.0 (2025-09-27)

### Added

- Blank fields
- Error handling for invalid amount, IBAN and currencies
- Font selection parameter: New `font` parameter allows using page font or selecting one of the spec-compliant fonts
  - Supports string values for single font or array of strings for font stack
  - Maintains backward compatibility (defaults to `"auto"` with existing behavior)

### Changed

- Correct reference and IBAN formatting
- CH cross is now exactly 7mm x 7mm
- Fixed different headings when debtor is provided or not
- Tweaking margins and paddings to match the standard more (line spacings, content position, etc.)

## v0.3.0 (2025-08-15)

### BREAKING CHANGES

- **Default behavior changed**: QR bills now use floating mode by default instead of forcing a new page
- **API change**: Added `standalone` parameter
  - Set `standalone: true` for old behavior

### Added

- **Floating mode as default**: QR bills are now floating elements that can be positioned anywhere
- **Invoice example**: New `example-invoice.typ` with business invoice layout
- **Flexible positioning**: Full control over QR bill placement using Typst's `place()`, `align()`, etc.

### Migration Guide

**From v0.2.x to v0.3.0:**

```typst
// Old way (v0.2.x)
#swiss-qr-bill(
  // ... parameters
)

// New way (v0.3.0+) to get old standalone behavior:
#swiss-qr-bill(
  standalone: true,  // forces new page
  // ... parameters
)
```

### Notes

- The new default makes custom invoice layouts easier to implement
- Use `standalone: true` only when you want the separate page behavior
- Avoid using `float: true` in `#place()` as it may cause unwanted page breaks

## v0.2.0 (2025-05-19)

### Added

- Multi-language support for all Swiss national languages:
  - German (de)
  - French (fr)
  - Italian (it)
  - English (en)
- New `language` parameter to specify preferred language (defaults to "de")
- Improved font stack with better fallbacks for cross-platform compatibility

### Changed

- Updated examples to demonstrate language options
- Updated documentation

## v0.1.0 (Initial Release)

### Added

- Generate Swiss QR bills with adherence to official specifications
- Support for QR-IBAN and regular IBAN
- Support for structured references (QR reference or Creditor Reference)
- Automatic formatting of currency amounts
- Proper styling according to Swiss QR bill guidelines
- Examples for various use cases
