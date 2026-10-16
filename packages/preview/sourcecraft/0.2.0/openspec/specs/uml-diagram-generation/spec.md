# UML Diagram Generation Specification

## Purpose

Generate UML class diagrams from Java and C# source code by parsing the code into an intermediate representation (IR) and rendering it using the CeTZ drawing engine. The system infers relationships automatically from source code structure.

## Requirements

### Requirement: Parse Source Code to IR

The system SHALL parse Java and C# source code into a language-agnostic Intermediate Representation (IR) containing classes, members, and relationships.

#### Scenario: Parse Java class with fields and methods
- **WHEN** parsing Java source containing a class with private fields and public methods
- **THEN** the IR contains a UML class with corresponding attributes and operations

#### Scenario: Parse C# class with properties
- **WHEN** parsing C# source containing a class with properties and methods
- **THEN** the IR contains a UML class with corresponding attributes and operations

#### Scenario: Parse enums
- **WHEN** parsing Java `enum` or C# `enum`
- **THEN** the IR contains a UML class with type "enum" and values listed as attributes

#### Scenario: Parse interfaces
- **WHEN** parsing Java `interface` or C# `interface`
- **THEN** the IR contains a UML class with type "interface"

#### Scenario: Parse abstract classes
- **WHEN** parsing Java `abstract class` or C# `abstract class`
- **THEN** the IR contains a UML class with type "abstract"

### Requirement: Render IR to CeTZ Diagram

The system SHALL render the IR as a CeTZ-based visual diagram with class boxes, members, and relationship lines.

#### Scenario: Render class box with attributes and methods
- **WHEN** rendering a UML class with fields and methods
- **THEN** the diagram shows a box with class name, stereotype, attributes (with visibility), and operations (with visibility and parameters)

#### Scenario: Render inheritance relationships
- **WHEN** rendering an inheritance relationship (extends/:)
- **THEN** the diagram shows a solid line with hollow triangle arrowhead pointing to parent

#### Scenario: Render implementation relationships
- **WHEN** rendering an implementation relationship (implements/: for interfaces)
- **THEN** the diagram shows a dashed line with hollow triangle arrowhead pointing to interface

#### Scenario: Render association relationships
- **WHEN** rendering an association (field of non-primitive type)
- **THEN** the diagram shows a solid line with field name as label

#### Scenario: Render composition relationships
- **WHEN** rendering a composition (detected by `new Type()` in class body)
- **THEN** the diagram shows a solid line with filled diamond at source end

#### Scenario: Render aggregation relationships
- **WHEN** rendering an aggregation (detected by constructor parameter of the type)
- **THEN** the diagram shows a solid line with hollow diamond at source end

#### Scenario: Render dependency relationships
- **WHEN** rendering a dependency (detected by `throw new Exception()`)
- **THEN** the diagram shows a dashed line with open arrowhead

### Requirement: Support Stereotypes

The system SHALL render UML stereotypes (`«interface»`, `«enum»`, `«abstract»`) above class names.

#### Scenario: Interface stereotype
- **WHEN** rendering a class with type "interface"
- **THEN** the diagram shows `«interface»` above the class name

#### Scenario: Enum stereotype
- **WHEN** rendering a class with type "enum"
- **THEN** the diagram shows `«enum»` above the class name

#### Scenario: Abstract stereotype
- **WHEN** rendering a class with type "abstract"
- **THEN** the diagram shows `«abstract»` above the class name