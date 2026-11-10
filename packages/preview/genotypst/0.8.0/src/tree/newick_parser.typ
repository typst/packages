#import "./tree_backend.typ": _tree-parse-newick

/// Parses a Newick string into a tree structure.
///
/// Parses a string containing Newick-formatted phylogenetic tree data
/// into a dictionary structure suitable for rendering.
///
/// - data (str): A string containing the Newick data.
/// -> dictionary with keys:
///   - children (array, none): Child node dictionaries, or none for leaf nodes.
///   - name (str, none): Optional node label.
///   - length (int, float, none): Optional branch length.
///   - rooted (bool): Root-only rootedness flag.
/// Child nodes use the same fields except `rooted`.
#let parse-newick = _tree-parse-newick
