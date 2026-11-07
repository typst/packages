# Diagram Scaling Specification

## Purpose

Automatically scale diagrams to fit within page constraints (width and optional maximum height) while preserving aspect ratio, preventing page breaks.

## Requirements

### Requirement: Fit to Page Width

The system SHALL scale the diagram down proportionally to fit within the available page width.

#### Scenario: Diagram wider than page
- **WHEN** diagram natural width exceeds page width and `fit: true` (default)
- **THEN** diagram is scaled down so its width equals page width

#### Scenario: Diagram narrower than page
- **WHEN** diagram natural width is less than page width and `fit: true`
- **THEN** diagram is rendered at natural size (not scaled up)

#### Scenario: Disable fit to width
- **WHEN** calling `class-diagram` with `fit: false`
- **THEN** diagram renders at natural width even if it exceeds page width

### Requirement: Maximum Height Constraint

The system SHALL optionally constrain diagram height to a maximum value.

#### Scenario: Diagram exceeds max-height
- **WHEN** diagram natural height exceeds `max-height` parameter
- **THEN** diagram is scaled down so its height equals `max-height`

#### Scenario: Diagram within max-height
- **WHEN** diagram natural height is less than `max-height`
- **THEN** diagram renders at natural height (or scaled by fit if applicable)

#### Scenario: Combined fit and max-height
- **WHEN** both `fit: true` and `max-height` are set
- **THEN** the smaller of the two scale factors is applied (preserving aspect ratio)

#### Scenario: Scale factor calculation
- **WHEN** calculating scale factor
- **THEN** `factor = min(width_factor, height_factor)` where:
  - `width_factor = page_width / diagram_width` (if fit and diagram wider)
  - `height_factor = max_height / diagram_height` (if max-height set and diagram taller)

### Requirement: Constrained Box Allocation

The system SHALL allocate exactly the scaled diagram size in the document flow to prevent page breaks.

#### Scenario: Scaled diagram box height
- **WHEN** diagram is scaled down
- **THEN** the allocated box height equals `diagram_height * factor` so content doesn't push to next page

#### Scenario: Unscaled diagram box height
- **WHEN** diagram is not scaled
- **THEN** the allocated box height equals natural diagram height

### Requirement: Global Configuration via Setup

The system SHALL allow setting default `fit` and `max-height` for all diagrams in a document via `setup-sourceuml`.

#### Scenario: Global max-height
- **WHEN** using `#show: setup-sourceuml.with(max-height: 18cm)`
- **THEN** all subsequent code-fence diagrams respect the 18cm max height

#### Scenario: Global fit
- **WHEN** using `#show: setup-sourceuml.with(fit: false)`
- **THEN** all subsequent code-fence diagrams disable fit-to-width