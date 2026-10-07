# Theme System Specification

## Purpose

Provide a theming system for customizing the visual appearance of generated UML diagrams including colors, fonts, line styles, and class box styling.

## Requirements

### Requirement: Built-in Default Theme

The system SHALL provide a built-in default theme that produces clean, readable diagrams.

#### Scenario: Default theme colors
- **WHEN** rendering with default theme
- **THEN** class boxes have light fill, dark borders, black text

#### Scenario: Default theme line styles
- **WHEN** rendering relationships with default theme
- **THEN** inheritance uses solid lines, implementation uses dashed lines, composition/aggregation use diamond markers

#### Scenario: Default theme fonts
- **WHEN** rendering text with default theme
- **THEN** class names use bold, members use regular weight

### Requirement: Custom Theme Override

The system SHALL allow overriding theme properties via a theme dictionary passed to the API.

#### Scenario: Override class box fill color
- **WHEN** passing `theme: (class-fill: rgb("#f0f0ff"))` to `class-diagram`
- **THEN** class boxes use the custom fill color

#### Scenario: Override border color
- **WHEN** passing `theme: (class-stroke: blue)` to `class-diagram`
- **THEN** class box borders are blue

#### Scenario: Override relationship line colors
- **WHEN** passing `theme: (relation-stroke: red)` to `class-diagram`
- **THEN** all relationship lines are red

#### Scenario: Override font family
- **WHEN** passing `theme: (font: "Helvetica")` to `class-diagram`
- **THEN** all diagram text uses Helvetica

#### Scenario: Partial theme override
- **WHEN** passing a theme with only some properties
- **THEN** specified properties override defaults; others use built-in values

### Requirement: Theme Properties

The system SHALL support the following theme properties for customizing diagram appearance:

#### Scenario: Override class box fill
- **WHEN** passing `theme: (class-fill: rgb("#f0f0ff"))`
- **THEN** class boxes use the custom fill color (default: light gray)

#### Scenario: Override class box border
- **WHEN** passing `theme: (class-stroke: blue, class-stroke-width: 2pt)`
- **THEN** class boxes have blue 2pt borders (default: dark gray, 1pt)

#### Scenario: Override header fill
- **WHEN** passing `theme: (header-fill: rgb("#e0e0ff"))`
- **THEN** class header section uses custom fill (default: slightly darker than class-fill)

#### Scenario: Override member section fill
- **WHEN** passing `theme: (member-fill: white)`
- **THEN** member section uses white background (default: white)

#### Scenario: Override font family
- **WHEN** passing `theme: (font: "Helvetica")`
- **THEN** all diagram text uses Helvetica (default: system default)

#### Scenario: Override font sizes
- **WHEN** passing `theme: (font-size: 11pt, header-font-size: 14pt)`
- **THEN** base text uses 11pt, class names use 14pt (defaults: 10pt, 12pt)

#### Scenario: Override relationship line style
- **WHEN** passing `theme: (relation-stroke: red, relation-stroke-width: 1.5pt)`
- **THEN** relationship lines are red 1.5pt (defaults: dark gray, 1pt)

#### Scenario: Override arrowhead size
- **WHEN** passing `theme: (arrow-size: 10pt)`
- **THEN** inheritance/implementation arrowheads are 10pt (default: 8pt)

#### Scenario: Override diamond size
- **WHEN** passing `theme: (diamond-size: 8pt)`
- **THEN** composition/aggregation diamonds are 8pt (default: 6pt)

#### Scenario: Theme property defaults
- **WHEN** rendering with default theme (no overrides)
- **THEN** all properties use their documented default values