# Relationship Inference Specification

## Purpose

Automatically infer UML relationships from source code structure without requiring explicit diagram annotations.

## Requirements

### Requirement: Inheritance Inference

The system SHALL infer inheritance relationships from `extends` (Java) and `:` (C#) keywords.

#### Scenario: Java extends
- **WHEN** parsing `class Child extends Parent { }`
- **THEN** an inheritance relationship from Child to Parent is created

#### Scenario: C# base class
- **WHEN** parsing `public class Child : Parent { }`
- **THEN** an inheritance relationship from Child to Parent is created

#### Scenario: Multiple inheritance not supported
- **WHEN** parsing Java (single inheritance only)
- **THEN** only one inheritance relationship is created per class

#### Scenario: C# multiple interfaces
- **WHEN** parsing `public class Impl : Base, I1, I2 { }`
- **THEN** one inheritance to Base, two implementations to I1 and I2

### Requirement: Implementation Inference

The system SHALL infer implementation relationships from `implements` (Java) and `:` for interfaces (C#).

#### Scenario: Java implements
- **WHEN** parsing `class Impl implements MyInterface { }`
- **THEN** an implementation relationship from Impl to MyInterface is created

#### Scenario: C# interface implementation
- **WHEN** parsing `public class Impl : IMyInterface { }` where IMyInterface is an interface
- **THEN** an implementation relationship from Impl to IMyInterface is created

### Requirement: Association Inference

The system SHALL infer associations from fields of non-primitive types.

#### Scenario: Simple field association
- **WHEN** parsing `private Bar bar;` (Java) or `private Bar bar;` (C#)
- **THEN** an association from the containing class to Bar with label "bar"

#### Scenario: Generic field association
- **WHEN** parsing `private List<Bar> bars;` or `List<Bar> bars;`
- **THEN** an association from the containing class to Bar (not List) with label "bars"

#### Scenario: Primitive type fields ignored
- **WHEN** parsing fields of type `int`, `String`, `boolean`, `double`, `string`, `bool`, etc.
- **THEN** no relationship is created

#### Scenario: Array field association
- **WHEN** parsing `private Bar[] bars;` or `Bar[] bars;`
- **THEN** an association from the containing class to Bar with label "bars"

### Requirement: Relationship Promotion Hierarchy

The system SHALL promote relationships through a fixed hierarchy: **Association → Composition → Aggregation** (promotion only increases, never decreases).

> Note: This hierarchy differs from standard UML where composition is stronger than aggregation. This tool treats Aggregation as the strongest inferred relationship.

#### Scenario: Association to Composition via `new`
- **WHEN** a class has an association to Bar (via field) AND contains `new Bar()` in any method body
- **THEN** the relationship is promoted from Association to Composition

#### Scenario: Composition to Aggregation via constructor parameter
- **WHEN** a class has a Composition to Bar AND receives Bar in a constructor parameter assigned to the field
- **THEN** the relationship is promoted from Composition to Aggregation

#### Scenario: Association directly to Aggregation via constructor
- **WHEN** a class has an Association to Bar (no `new` detected) AND receives Bar in constructor
- **THEN** the relationship is promoted from Association to Aggregation

#### Scenario: Never demote
- **WHEN** a relationship is already Aggregation
- **THEN** it remains Aggregation regardless of other code patterns

#### Scenario: Java example from manual
- **WHEN** parsing:
  ```java
  class Pedido {
    private List<Item> itens;     // associação Pedido → Item
    public void addItem(String n) {
      itens.add(new Item(n));     // new Item() → promove para composição
    }
  }
  class Nota {
    private Pedido pedido;        // associação Nota → Pedido
    public Nota(Pedido pedido) {  // parâmetro do construtor → agora é agregação
      this.pedido = pedido;
    }
  }
  ```
- **THEN** Pedido→Item is Composition; Nota→Pedido is Aggregation

### Requirement: Dependency Inference

The system SHALL infer dependencies from `throw new ExceptionType()` statements.

#### Scenario: Java throw dependency
- **WHEN** parsing a method containing `throw new MyException()`
- **THEN** a dependency relationship from the class to MyException is created

#### Scenario: C# throw dependency
- **WHEN** parsing a method containing `throw new MyException()`
- **THEN** a dependency relationship from the class to MyException is created

The system SHALL infer dependencies from non-primitive types used by method
parameters, including types nested in generic arguments. Commas inside generic
arguments SHALL NOT be treated as parameter separators. If a type is already
represented by a field relationship, the parser SHALL NOT add a duplicate
dependency for that type.

#### Scenario: Multiple generic method parameter types
- **WHEN** parsing `void import(Map<String, Customer> customers)` or the equivalent C# declaration
- **THEN** a dependency relationship from the containing class to Customer is created and no relationship to a malformed type name is created

#### Scenario: Nested generic method parameter types
- **WHEN** parsing `void process(Map<String, List<Customer>> customers)` or the equivalent C# declaration
- **THEN** a dependency relationship from the containing class to Customer is created

#### Scenario: Multiple custom generic arguments
- **WHEN** parsing `void compare(Pair<Customer, Order> pair)`
- **THEN** dependencies from the containing class to Customer and Order are created

#### Scenario: Parameter type already represented by a field
- **WHEN** a class has a field of type Customer and a method parameter of type Customer
- **THEN** the parser emits the field relationship and does not emit a duplicate dependency to Customer