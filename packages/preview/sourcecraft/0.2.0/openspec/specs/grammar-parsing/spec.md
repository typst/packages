# Grammar Parsing Specification

## Purpose

Provide a pluggable grammar system that parses Java and C# source code into the shared Intermediate Representation (IR). New languages can be added by implementing a parse function and registering it.

## Requirements

### Requirement: Java Grammar Parser

The system SHALL parse Java source code and extract classes, interfaces, enums, fields, methods, and relationships.

#### Scenario: Parse class declaration with extends
- **WHEN** parsing `class Child extends Parent { }`
- **THEN** the IR contains two classes with an inheritance relationship from Child to Parent

#### Scenario: Parse class declaration with implements
- **WHEN** parsing `class Impl implements Interface { }`
- **THEN** the IR contains a class and an interface with an implementation relationship

#### Scenario: Parse field declarations with visibility
- **WHEN** parsing `private String name; public int count;`
- **THEN** the IR contains attributes with correct visibility (private, public, protected)

#### Scenario: Parse method declarations with parameters
- **WHEN** parsing `public void doSomething(String param, int value) { }`
- **THEN** the IR contains an operation with name, return type, visibility, and parameter list

#### Scenario: Parse constructor declarations
- **WHEN** parsing `public MyClass(String name) { this.name = name; }`
- **THEN** the IR contains an operation with name matching class, no return type, and parameters

#### Scenario: Parse @Layout annotations
- **WHEN** parsing `@Layout(level=0, order=1) class Foo { }`
- **THEN** the IR class has level=0 and order=1 for manual positioning

#### Scenario: Detect composition from `new` expressions
- **WHEN** parsing a class containing `new Bar()` in any method body
- **THEN** the IR contains a composition relationship from the class to Bar

#### Scenario: Detect aggregation from constructor parameters
- **WHEN** parsing a constructor taking `Bar bar` and assigning to field
- **THEN** the IR contains an aggregation relationship from the class to Bar

#### Scenario: Detect dependency from throw statements
- **WHEN** parsing a method containing `throw new Exception()`
- **THEN** the IR contains a dependency relationship from the class to Exception

#### Scenario: Handle generic types
- **WHEN** parsing `List<String> items;`
- **THEN** the IR extracts `String` as the target type for relationships (not `List`)

#### Scenario: Handle primitive types
- **WHEN** parsing fields of type `int`, `String`, `boolean`, `double`, etc.
- **THEN** the IR does NOT create relationships for primitive/builtin types

### Requirement: C# Grammar Parser

The system SHALL parse C# source code and extract classes, interfaces, enums, fields, methods, properties, and relationships.

#### Scenario: Parse class declaration with base class and interfaces
- **WHEN** parsing `public class Child : Base, IInterface { }`
- **THEN** the IR contains inheritance to Base and implementation to IInterface

#### Scenario: Parse properties
- **WHEN** parsing `public string Name { get; set; }`
- **THEN** the IR contains an attribute with visibility and type

#### Scenario: Parse methods with parameters
- **WHEN** parsing `public void DoSomething(string param, int value) { }`
- **THEN** the IR contains an operation with name, return type, visibility, and parameters

#### Scenario: Parse constructors
- **WHEN** parsing `public MyClass(string name) { this.name = name; }`
- **THEN** the IR contains an operation with name matching class

#### Scenario: Parse [Layout] attributes
- **WHEN** parsing `[Layout(Level = 0, Order = 1)] public class Foo { }`
- **THEN** the IR class has level=0 and order=1 for manual positioning

#### Scenario: Detect composition from `new` expressions
- **WHEN** parsing a class containing `new Bar()` in any method body
- **THEN** the IR contains a composition relationship from the class to Bar

#### Scenario: Detect aggregation from constructor parameters
- **WHEN** parsing a constructor taking `Bar bar` and assigning to field
- **THEN** the IR contains an aggregation relationship from the class to Bar

#### Scenario: Handle generic types
- **WHEN** parsing `List<string> items;`
- **THEN** the IR extracts `string` as the target type for relationships

#### Scenario: Handle primitive/builtin types
- **WHEN** parsing fields of type `int`, `string`, `bool`, `double`, etc.
- **THEN** the IR does NOT create relationships for primitive/builtin types

### Requirement: Pluggable Grammar Registration

The system SHALL allow registering new grammars by adding a parse function to the grammar registry.

#### Scenario: Register new grammar
- **WHEN** adding a new grammar module to `src/grammars/` and registering in `mod.typ`
- **THEN** the grammar is available via `grammar: "newlang"` in `class-diagram` and as code fence `class-diagram-newlang`

#### Scenario: Resolve grammar by name
- **WHEN** calling `class-diagram` with `grammar: "java"` or `grammar: "csharp"`
- **THEN** the correct parser function is invoked

#### Scenario: Custom grammar function
- **WHEN** passing a custom function as `grammar` parameter
- **THEN** the custom function is used to parse the source