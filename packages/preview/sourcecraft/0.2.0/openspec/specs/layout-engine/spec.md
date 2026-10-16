# Layout Engine Specification

## Purpose

Automatically position UML classes in a diagram using a hierarchical layout algorithm based on relationships, with optional manual positioning via `@Layout` / `[Layout]` annotations.

## Requirements

### Requirement: Automatic Hierarchical Layout

The system SHALL automatically arrange classes in vertical levels based on inheritance/implementation hierarchy.

#### Scenario: Place parent classes above children
- **WHEN** rendering a diagram with inheritance relationships
- **THEN** parent classes appear at level 0 (top), children at level 1, grandchildren at level 2, etc.

#### Scenario: Place implemented interfaces above implementers
- **WHEN** rendering a diagram with implementation relationships
- **THEN** interfaces appear above the classes that implement them

#### Scenario: Order siblings horizontally
- **WHEN** multiple classes share the same parent level
- **THEN** they are ordered horizontally (left to right) by declaration order or alphabetically

#### Scenario: Handle multiple inheritance paths
- **WHEN** a class inherits from multiple parents at different levels
- **THEN** the class is placed at the maximum level of its parents + 1

### Requirement: Manual Layout Override

The system SHALL allow manual positioning via `@Layout` (Java) or `[Layout]` (C#) annotations.

#### Scenario: Java @Layout annotation
- **WHEN** source contains `@Layout(level=2, order=0) class Foo { }`
- **THEN** the class is placed at level 2, order 0 regardless of relationships

#### Scenario: C# [Layout] attribute
- **WHEN** source contains `[Layout(Level = 1, Order = 2)] public class Foo { }`
- **THEN** the class is placed at level 1, order 2 regardless of relationships

#### Scenario: Partial manual layout
- **WHEN** only some classes have @Layout annotations
- **THEN** annotated classes use manual positions; others use automatic layout

#### Scenario: Layout level property
- **WHEN** `@Layout(level=N)` is specified
- **THEN** the class is placed in vertical row N (0 = top)

#### Scenario: Layout order property
- **WHEN** `@Layout(order=M)` is specified
- **THEN** the class is placed at horizontal position M within its level (0 = left)

### Requirement: Configurable Spacing

The system SHALL allow configuring horizontal and vertical spacing between class boxes.

#### Scenario: Custom spacing via API
- **WHEN** calling `class-diagram` with `spacing: (x: 6.0, y: 5.0)`
- **THEN** class boxes have a 6.0 CeTZ units horizontal and 5.0 vertical gap between their edges

#### Scenario: Default spacing
- **WHEN** no spacing is specified
- **THEN** default spacing of (x: 2.0, y: 2.0) is used (gap between box edges)