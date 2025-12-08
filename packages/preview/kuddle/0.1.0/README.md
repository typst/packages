# Kuddle — a KDL parser for typst
A [KDL](https://kdl.dev/) parser for [typst](https://typst.app). It utilizes the official [kdl-rs](https://github.com/kdl-org/kdl-rs) library, being then loaded via a plugin into typst.

## Functionality
The examples directory showcases the differences between the provided functions.

### Basic
The following functions are sorted by completeness.
- `kuddle.parse-kdl : str -> kdl`: The most complete version. It includes type annotations and parses entries as is.
- `kuddle.parse-kdl-typeless : str -> kdl`: Here type annotations are omitted.
- `kuddle.parse-kdl-short : str -> kdl`: This version splits entries to
    - an array of arguments and
    - an dictionary of properties
    Thus, the order of properties, as well as, the order between properties and arguments is discarded. Furthermore, properties cannot be assigned multiple times for a node.

### Typst Typed Versions 
All these functions automatically try to map type annotations to their corresponding typst equivalent. Currently, only `(typst)` and `(typ)` are available. Non mapped annotations are being kept for later usage.

The following functions are again sorted by completeness.
- `kuddle.parse-kdl-typst : str -> kdl`: The typst typed equivalent to `kuddle.parse-kdl`.
- `kuddle.parse-kdl-typst-short : str -> kdl`: The typst typed equivalent to `kuddle.parse-kdl-short`.
- `kuddle.parse-kdl-typst-collapsed : str -> kdl`: Children nodes are mapped via a dictionary.
- `kuddle.parse-kdl-typst-minimal : str -> kdl`: Arguments, properties and children are together mapped via the typst argument type.

> [!WARNING]
> Various functions do not parse KDL strings according to the specifications. Be aware of this and choose the right function for your usecase. The typed and typeless function are correct, though. A list of simplifications:
> - the `(typst-)short` variants discards the order and multiplicity for properties and the order between properties and arguments
> - the `typst-collapse` variant relies on the previous functionality and inherits in incorrectness
> - the `typst-minimal` variant furthermore removes the distinction between nodes and properties and merges them into one dictionary, making it impossible to have multiple same named properties / nodes.

## Packaging
[Typpkg](https://github.com/ludwig-austermann/typpkg) is used to package the repo.

## Roadmap
- [ ] validation via KDL Schema Language
- [ ] querying via KDL Query Language
- [ ] methods on result, to unify functions
- [ ] more automatic specialized typst type conversion