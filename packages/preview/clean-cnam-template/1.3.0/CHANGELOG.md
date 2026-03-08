# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2025-11-24

### Added

#### New Header System
- **Hydra-based page headers**: Integrated `@preview/hydra:0.6.2` for intelligent section-aware headers
  - Displays current section number and title in the header
  - Decorative line below header with primary color
  - Automatically hides on chapter start pages

#### Enhanced Chapter Styling
- **New level 1 heading design**: Completely redesigned chapter headings
  - Centered layout with "Chapter N" prefix
  - Decorative thin lines above and below the title
  - Automatic page break before each chapter
  - Larger title text (1.5em)

#### Utility Additions
- **`thin-line` utility**: New decorative line element for consistent styling across the document

### Changed
- **Heading numbering system**: Refactored to only display relevant numbers per heading level
  - Level 2 headings now show only their section number (e.g., "I -" instead of "III I -")
  - Level 3 and 4 headings properly display parent-child relationships
  - Cleaner, more readable heading hierarchy

### Fixed
- **Heading number display**: Fixed issue where parent chapter numbers appeared in sub-heading numbering

## [1.2.0] - 2025-10-20

### Added

#### Enhanced Component Customization
- **Blockquote enhancements** with extensive customization options:
  - `border-side` parameter: choose left, right, top, bottom, or all borders
  - `attribution` parameter: add source/author attribution to quotes
  - `attribution-align` parameter: align attribution (left, center, right)
  - `attribution-style` parameter: customize attribution text styling (size, weight, fill, style)
  - `attribution-inset` parameter: control attribution spacing
  - `block-align` parameter: align the entire block (left, center, right)
  - `content-align` parameter: align content inside the block (left, center, right)
  - `width` parameter: control block width (auto, 100%, or custom length)
  - Dynamic radius adjustment based on border side
  - Support for full border styling with all sides

- **my-block component enhancements** with title and alignment support:
  - `title` parameter: optional title at the top of the block
  - `title-align` parameter: align title (left, center, right)
  - `title-style` parameter: customize title styling (size, weight, fill)
  - `title-inset` parameter: control spacing around the title
  - `block-align` parameter: align the entire block (left, center, right)
  - `content-align` parameter: align content inside the block (left, center, right)
  - `width` parameter: control block width (auto, 100%, or custom length)

- **Code component enhancements** with advanced display options:
  - `title` parameter: optional title/caption above the code block
  - `title-align` parameter: align title (left, center, right)
  - `title-style` parameter: customize title styling (size, weight, fill)
  - `title-inset` parameter: control spacing around the title
  - `block-align` parameter: align the entire block (left, center, right)
  - `number-style` parameter: customize line number styling (size, fill, weight)
  - Enhanced text styling with `fill` color support
  - Improved language label positioning with better width handling

- **Math components enhancements**:
  - Full customization support for `definition`, `example`, and `theorem`
  - All parameters now configurable: fill, stroke, radius, inset, numbering, breakable
  - Comprehensive JSDoc documentation with usage examples
  - Consistent theming with extensible color options

#### Documentation Improvements
- **Comprehensive showcase document** in `main.typ` demonstrating:
  - All component customization options
  - Multiple styling examples for each component
  - Real-world usage patterns
  - Color customization examples
  - Layout and alignment options
- **Enhanced JSDoc documentation** with detailed usage examples for all components
- **Parameter descriptions** with default values and type information

### Changed
- **Improved component API consistency** across all components
- **Better default styling** with refined color choices
- **Enhanced type safety** in parameter handling
- **Refined layout calculations** for better responsive behavior
- **Package version** updated to 1.2.0 in `typst.toml`

### Fixed
- **Code block width handling** for proper alignment with title and language label
- **Border radius calculations** now adapt to border-side selection
- **Attribution spacing** in blockquotes for better visual hierarchy
- **Title spacing** in all components for consistent appearance

## [1.1.0] - 2025-10-19

### Added
- **Custom outline support** with `outline-code` parameter in `clean-cnam-template()`
  - Pass `none` (default) for standard outline
  - Pass `false` to disable outline completely
  - Pass custom outline code (e.g., `outline(title: "Table des matières", depth: 2)`) for customization
- **Documentation examples** for outline customization in README.md
- **Usage comments** in main.typ demonstrating all outline options

### Changed
- **Enhanced flexibility** of title page generation to support custom outline configurations

## [1.0.0] - 2024-09-15

### Added

#### Core Template System
- **Modular template architecture** with organized library structure in `lib/` directory
- **CNAM branding integration** with official colors and styling
- **Main configuration function** `clean-cnam-template()` for easy document setup
- **Centralized package entrypoint** in `lib.typ` for clean imports

#### Document Configuration
- **Flexible document configuration** with support for:
  - Title, subtitle, author, and affiliation
  - Custom logo support (CNAM logo included)
  - Configurable primary colors and theming
  - Class/course information and date management
  - Multi-language support (French default)

#### Font Management
- **Centralized font configuration system** with `fonts.typ` module
- **Configurable font families** for body text and code blocks
- **Default font support** for "New Computer Modern Math" and "Zed Plex Mono"
- **Consistent font application** across all components

#### Enhanced Code Blocks
- **Advanced code component** with comprehensive features:
  - Syntax highlighting for multiple programming languages
  - Optional line numbering with customizable alignment
  - Filename display support
  - Language label badges
  - Customizable styling (colors, spacing, borders)
  - Line range selection for partial code display
  - Label support for line referencing

#### UI Components
- **Styled blockquote component** with customizable colors and borders
- **Flexible content blocks** (`my-block`) with configurable styling
- **Professional layout system** with decorative elements
- **Context-aware page headers** with smart header management

#### Mathematical Environments
- **Mathematical definition blocks** with red styling and numbering
- **Example blocks** with blue styling and consistent formatting
- **Theorem blocks** with purple styling and proper numbering
- **Integration with great-theorems package** for enhanced mathematical typesetting
- **Dependent numbering system** for mathematical environments

#### Utility Functions
- **Vector arrows utility** (`ar()`) for mathematical expressions
- **Icon sizing utility** (`icon()`) for proper icon display
- **French date formatting** (`date-format()`) for localized dates

#### Color System
- **Predefined color palette** with CNAM branding colors
- **Semantic color naming** with descriptive names:
  - `theorem-color` for theorem blocks
  - `example-color` for example blocks
  - `definition-color` for definition blocks
- **Color word highlighting** for automatic text coloring

#### Layout and Styling
- **Professional document layout** with responsive design
- **Decorative page elements** for enhanced visual appeal
- **Title page generation** with CNAM branding
- **Consistent spacing and typography** throughout the document

#### Project Structure
- **Organized module system** with logical separation:
  - `config.typ` - Main configuration and document setup
  - `fonts.typ` - Font management and configuration
  - `components.typ` - UI components (blockquote, blocks, code)
  - `headers.typ` - Header management logic
  - `layout.typ` - Document layout and styling
  - `utils.typ` - Utility functions
  - `colors.typ` - Color definitions
  - `math.typ` - Mathematical environments
- **Template directory** with example usage
- **Asset management** for logos and static resources

#### Development Features
- **MIT License** for open-source usage
- **Comprehensive documentation** with usage examples
- **Package configuration** with proper metadata and exclusions
- **Git integration** with appropriate ignore patterns

### Technical Details

#### Dependencies
- **Typst 1.0.0+** minimum version requirement
- **great-theorems 0.1.2** for mathematical environments
- **headcount 0.1.0** for numbering systems

#### Code Quality
- **Consistent naming conventions** using kebab-case for functions
- **Comprehensive documentation** with JSDoc-style comments
- **Modular design** eliminating circular dependencies
- **Clean import structure** with optimized exports

#### Package Information
- **Package name**: clean-cnam-template
- **Version**: 1.0.0
- **Author**: Tom Planche
- **Repository**: https://github.com/TomPlanche/clean-cnam-template
- **Keywords**: template, cnam, academic, document, styling
- **Categories**: template, academic

[1.0.0]: https://github.com/TomPlanche/clean-cnam-template/releases/tag/v1.0.0
