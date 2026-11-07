# Public API Specification

## Purpose

Provide two complementary APIs for generating UML diagrams: a show-rule based code-fence API for inline diagrams, and a function API for programmatic control.

## Requirements

### Requirement: Show-Rule API (Code Fences)

The system SHALL provide a `setup-sourceuml` function that enables diagram rendering via Typst code fences.

#### Scenario: Enable code fence rendering
- **WHEN** user writes `#show: setup-sourceuml` in their document
- **THEN** code fences with languages `source-diagram-java` and `source-diagram-csharp` are intercepted and rendered as diagrams

#### Scenario: Configure global options
- **WHEN** user writes `#show: setup-sourceuml.with(max-height: 15cm, fit: false)`
- **THEN** all code-fence diagrams in the document use those settings

#### Scenario: Render Java code fence
- **WHEN** document contains:
  ````typst
  ```source-diagram-java
  class Foo { private Bar bar; }
  ```
  ````
- **THEN** a UML diagram of class Foo with association to Bar is rendered

#### Scenario: Render C# code fence
- **WHEN** document contains:
  ````typst
  ```source-diagram-csharp
  public class Foo { private Bar bar; }
  ```
  ````
- **THEN** a UML diagram of class Foo with association to Bar is rendered

#### Scenario: Pass theme to setup
- **WHEN** user writes `#show: setup-sourceuml.with(theme: (class-fill: blue))`
- **THEN** all code-fence diagrams use the custom theme

### Requirement: Function API (Programmatic)

The system SHALL provide a `source-diagram` function for direct diagram generation with per-diagram control.

#### Scenario: Basic function usage
- **WHEN** user writes `#source-diagram("class Foo { }", grammar: "java")`
- **THEN** a UML diagram of class Foo is rendered at that location

#### Scenario: Override grammar per call
- **WHEN** calling `source-diagram(source, grammar: "csharp")`
- **THEN** the source is parsed as C#

#### Scenario: Pass custom theme per call
- **WHEN** calling `source-diagram(source, grammar: "java", theme: (class-fill: red))`
- **THEN** only that diagram uses the custom theme

#### Scenario: Control fit per call
- **WHEN** calling `source-diagram(source, grammar: "java", fit: false)`
- **THEN** that diagram does not scale to page width

#### Scenario: Control max-height per call
- **WHEN** calling `source-diagram(source, grammar: "java", max-height: 10cm)`
- **THEN** that diagram is constrained to 10cm height

#### Scenario: Control spacing per call
- **WHEN** calling `source-diagram(source, grammar: "java", spacing: (x: 6.0, y: 4.0))`
- **THEN** that diagram uses custom spacing

### Requirement: Advanced IR API

The system SHALL re-export IR constructors and renderer for advanced users who want to build diagrams programmatically without parsing.

#### Scenario: Create class programmatically
- **WHEN** user calls `create-class(name: "Foo", type: "class")`
- **THEN** a UML class IR object is returned

#### Scenario: Create member programmatically
- **WHEN** user calls `create-member(name: "bar", return-type: "Bar", visibility: "private", kind: "field")`
- **THEN** a UML member IR object is returned

#### Scenario: Create relationship programmatically
- **WHEN** user calls `create-relation(from: "Foo", to: "Bar", type: "composition")`
- **THEN** a UML relation IR object is returned

#### Scenario: Create diagram from IR programmatically
- **WHEN** user calls `create-diagram(classes: ..., relations: ..., packages: ...)`
- **THEN** a complete UML diagram IR is returned

#### Scenario: Render IR directly
- **WHEN** user calls `render-ir(diagram-ir, theme: ..., spacing: ...)`
- **THEN** the IR is rendered to a CeTZ diagram without parsing

### Requirement: Custom Grammar Registration API

The system SHALL expose `register-grammar` for users to add new language support.

#### Scenario: Register custom grammar
- **WHEN** user calls `register-grammar("kotlin", kotlin-parse-function)`
- **THEN** `grammar: "kotlin"` works in `source-diagram` and `source-diagram-kotlin` code fence works