# Intermediate Representation (IR) Specification

## Purpose

Define a language-agnostic data structure representing UML class diagrams, enabling separation of parsing (grammar-specific) from rendering (grammar-agnostic).

## Requirements

### Requirement: UML Class Structure

The IR SHALL represent a UML class with all necessary visual and semantic information.

#### Scenario: Class with all properties
- **WHEN** creating a class IR
- **THEN** it contains: `name` (string), `type` ("class" | "abstract" | "interface" | "enum"), `level` (int, optional), `order` (int, optional), `members` (array), `package` (string, optional)

#### Scenario: Class type determines stereotype
- **WHEN** class type is "interface"
- **THEN** renderer shows `«interface»` stereotype
- **WHEN** class type is "enum"
- **THEN** renderer shows `«enum»` stereotype
- **WHEN** class type is "abstract"
- **THEN** renderer shows `«abstract»` stereotype

#### Scenario: Level and order for manual layout
- **WHEN** class has `level: 2, order: 1`
- **THEN** layout engine places it at level 2, horizontal position 1

### Requirement: UML Member Structure

The IR SHALL represent class members (fields and methods) with full signature information.

#### Scenario: Field member
- **WHEN** creating a field IR
- **THEN** it contains: `name`, `return-type` (type), `visibility` ("public" | "private" | "protected"), `kind: "field"`, `modifiers` (array: "static", "final", "readonly", etc.)

#### Scenario: Method member
- **WHEN** creating a method IR
- **THEN** it contains: `name`, `return-type`, `visibility`, `kind: "method"`, `params` (array of {name, type}), `modifiers` (array: "static", "abstract", "virtual", "override", etc.)

#### Scenario: Constructor member
- **WHEN** creating a constructor IR
- **THEN** it contains: `name` (matches class), `return-type: none`, `kind: "method"`, `params`, `modifiers`

#### Scenario: Enum value member
- **WHEN** creating an enum value IR
- **THEN** it contains: `name`, `kind: "field"`, `visibility: "public"`, no return-type

### Requirement: UML Relationship Structure

The IR SHALL represent relationships between classes with all UML notation details.

#### Scenario: Inheritance relationship
- **WHEN** creating inheritance IR
- **THEN** it contains: `from` (child class name), `to` (parent class name), `type: "inheritance"`, `label` (optional), `from-card` (optional), `to-card` (optional)

#### Scenario: Implementation relationship
- **WHEN** creating implementation IR
- **THEN** it contains: `from` (implementer), `to` (interface), `type: "implementation"`

#### Scenario: Association relationship
- **WHEN** creating association IR
- **THEN** it contains: `from`, `to`, `type: "association"`, `label` (field name), `from-card`, `to-card`

#### Scenario: Composition relationship
- **WHEN** creating composition IR
- **THEN** it contains: `from`, `to`, `type: "composition"`, `label`, `from-card`, `to-card`

#### Scenario: Aggregation relationship
- **WHEN** creating aggregation IR
- **THEN** it contains: `from`, `to`, `type: "aggregation"`, `label`, `from-card`, `to-card`

#### Scenario: Dependency relationship
- **WHEN** creating dependency IR
- **THEN** it contains: `from`, `to`, `type: "dependency"`, `label` (optional)

### Requirement: UML Diagram Container

The IR SHALL contain a complete diagram with all classes, relationships, and packages.

#### Scenario: Complete diagram IR
- **WHEN** creating a diagram IR
- **THEN** it contains: `classes` (array of class IRs), `relations` (array of relation IRs), `packages` (array of package names)

#### Scenario: Package information
- **WHEN** parser extracts `package com.example;` (Java) or `namespace Com.Example;` (C#)
- **THEN** the package name is included in the diagram IR and class IRs