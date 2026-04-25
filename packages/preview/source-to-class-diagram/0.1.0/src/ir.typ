// =============================================================================
// source-to-class-diagram — Intermediate Representation (IR)
// =============================================================================
// All grammar parsers produce this IR. The renderer consumes it.
// This decouples parsing from rendering completely.

/// Creates a UML member (attribute or method).
///
/// - name (str): Member name (e.g., "getNome")
/// - return-type (str, none): Type for fields, return type for methods
/// - visibility (str): "public", "private", "protected", "package"
/// - modifiers (array): e.g., ("static",), ("abstract",)
/// - kind (str): "field" or "method"
/// - params (str, none): Parameter text for methods (e.g., "String nome, int idade")
#let uml-member(
  name: "",
  return-type: none,
  visibility: "package",
  modifiers: (),
  kind: "field",
  params: none,
) = (
  name: name,
  return-type: return-type,
  visibility: visibility,
  modifiers: modifiers,
  kind: kind,
  params: params,
)

/// Creates a UML class / interface / enum / abstract class.
///
/// - name (str): Class name
/// - type (str): "class", "abstract", "interface", "enum", "annotation"
/// - stereotype (str, none): e.g., "Singleton"
/// - members (array): Array of uml-member dictionaries
/// - generics (str, none): e.g., "T extends Comparable"
#let uml-class(
  name: "",
  type: "class",
  stereotype: none,
  members: (),
  generics: none,
  level: none,
  order: none,
) = (
  name: name,
  type: type,
  stereotype: stereotype,
  members: members,
  generics: generics,
  level: level,
  order: order,
)

/// Creates a UML relation between two classes.
///
/// - from (str): Source class name
/// - to (str): Target class name
/// - type (str): Relation type — see relation-types below
/// - label (str, none): Label on the relation
/// - from-card (str, none): Cardinality at source (e.g., "1")
/// - to-card (str, none): Cardinality at target (e.g., "*")
#let uml-relation(
  from: "",
  to: "",
  type: "association",
  label: none,
  from-card: none,
  to-card: none,
) = (
  from: from,
  to: to,
  type: type,
  label: label,
  from-card: from-card,
  to-card: to-card,
)

/// Creates a UML package grouping.
///
/// - name (str): Package name
/// - classes (array): Array of class names inside this package
/// - style (str, none): Visual style hint
#let uml-package(
  name: "",
  classes: (),
  style: none,
) = (
  name: name,
  classes: classes,
  style: style,
)

/// Root IR node — represents a complete class diagram.
///
/// - classes (array): Array of uml-class dictionaries
/// - relations (array): Array of uml-relation dictionaries
/// - packages (array): Array of uml-package dictionaries
#let uml-diagram(
  classes: (),
  relations: (),
  packages: (),
) = (
  classes: classes,
  relations: relations,
  packages: packages,
)

// =============================================================================
// Constants
// =============================================================================

/// Valid class types.
#let class-types = ("class", "abstract", "interface", "enum", "annotation")

/// Valid relation types.
#let relation-types = (
  "inheritance",
  "implementation",
  "composition",
  "aggregation",
  "association",
  "dependency",
  "link",
  "dashed-link",
)

/// Valid visibility values.
#let visibilities = ("public", "private", "protected", "package")
