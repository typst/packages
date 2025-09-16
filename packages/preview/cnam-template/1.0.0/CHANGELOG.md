# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-15

### Added

#### Core Template System
- **Modular template architecture** with organized library structure in `lib/` directory
- **CNAM branding integration** with official colors and styling
- **Main configuration function** `cnam-typst-template()` for easy document setup
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
- **Package name**: cnam-typst-template
- **Version**: 1.0.0
- **Author**: Tom Planche
- **Repository**: https://github.com/TomPlanche/cnam-typst-template
- **Keywords**: template, cnam, academic, document, styling
- **Categories**: template, academic

[1.0.0]: https://github.com/TomPlanche/cnam-typst-template/releases/tag/v1.0.0
