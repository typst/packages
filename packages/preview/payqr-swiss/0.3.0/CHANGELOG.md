# Changelog

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
