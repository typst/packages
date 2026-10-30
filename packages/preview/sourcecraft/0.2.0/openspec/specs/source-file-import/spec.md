# Source File Import Specification

## Purpose

Enable reading source code files directly from disk using Typst's `read()` function, keeping diagrams in sync with actual codebases.

## Requirements

### Requirement: Read and Concatenate Multiple Files

The system SHALL support reading multiple source files and joining them for a single diagram.

#### Scenario: Read multiple Java files
- **WHEN** user writes:
  ```typst
  #let src = (
    read("src/model/Animal.java"),
    read("src/model/Cachorro.java"),
    read("src/model/Gato.java"),
  ).join("\n\n")
  #source-diagram(src, grammar: "java")
  ```
- **THEN** all three files are parsed together as a single diagram with cross-file relationships

#### Scenario: Read multiple C# files
- **WHEN** user writes:
  ```typst
  #let src = (
    read("src/Models/Animal.cs"),
    read("src/Models/Dog.cs"),
  ).join("\n\n")
  #source-diagram(src, grammar: "csharp")
  ```
- **THEN** both files are parsed together

### Requirement: Inject Layout Annotations Without Modifying Source

The system SHALL allow interleaving layout annotations with file reads without modifying the original source files.

#### Scenario: Inject @Layout for Java
- **WHEN** user writes:
  ```typst
  #let src = (
    "@Layout(level=0, order=0)",
    read("src/model/Animal.java"),
    "@Layout(level=1, order=0)",
    read("src/model/Cachorro.java"),
    "@Layout(level=1, order=1)",
    read("src/model/Gato.java"),
  ).join("\n\n")
  ```
- **THEN** the diagram uses manual positions for these classes while parsing the actual source files

#### Scenario: Inject [Layout] for C#
- **WHEN** user writes:
  ```typst
  #let src = (
    "[Layout(Level = 0, Order = 0)]",
    read("src/Models/Animal.cs"),
    "[Layout(Level = 1, Order = 0)]",
    read("src/Models/Dog.cs"),
  ).join("\n\n")
  ```
- **THEN** the diagram uses manual positions for these classes

### Requirement: Relative Path Resolution

The system SHALL resolve file paths relative to the Typst document location.

#### Scenario: Relative paths work
- **WHEN** document is at `docs/manual.typ` and reads `../exemplos/java/Animal.java`
- **THEN** the file is found and parsed correctly

### Requirement: Encoding Handling

The system SHALL handle UTF-8 encoded source files correctly.

#### Scenario: UTF-8 source files
- **WHEN** reading a Java/C# file with UTF-8 characters (comments, string literals)
- **THEN** the file is parsed without encoding errors