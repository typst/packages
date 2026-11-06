#import "@preview/cetz:0.2.2"
#import "src/default.typ": default
#import "src/utils.typ"
#import "src/drawer.typ"
#import "src/drawer.typ" : skeletize, draw-skeleton
#import "src/links.typ" : *
#import "src/molecule.typ" : *

#let transparent = color.rgb(100%,0,0,0)

/// === Molecule function
/// Build a molecule group based on mol
/// Each molecule is represented as an optional count followed by a molecule name
/// starting by a capital letter followed by an optional indice
/// #example(```
/// #skeletize({
///   molecule("H_2O")
/// })
///```)
/// It is possible to use an equation as a molecule. In this case, the spliting of the equation uses the same rules as in the string case. However, you can use parenthesis to group elements together.
/// #example(```
/// #skeletize({
///   molecule($C(C H_3)_3$)
/// })
///```)
/// - name (content): The name of the molecule. It is used as the cetz name of the molecule and to link other molecules to it.
/// - links (dictionary): The links between this molecule and previous molecules or hooks. The key is the name of the molecule or hook and the value is the link function.
///
/// Note that the antom-sep and angle arguments are ignored
/// - mol (string, equation): The string representing the molecule or an equation of the molecule
/// - vertical (boolean): If true, the molecule is drawn vertically
/// #example(```
/// #skeletize({
///   molecule("ABCD", vertical: true)
/// })
///```)
/// -> drawable
#let molecule(name: none, links: (:), vertical: false, mol) = {
  let atoms = if type(mol) == str {
		split-string(mol)
	} else if mol.func() == math.equation {
		split-equation(mol, equation: true)
	} else {
		panic("Invalid molecule content")
	}
  (
    (
      type: "molecule",
      name: name,
      atoms: atoms,
      links: links,
			vertical: vertical,
      count: atoms.len(),
    ),
  )
}

/// === Hooks
/// Create a hook in the molecule. It allows tu connect links to the place where the hook is.
/// Hooks are placed at the end of links or at the beginning of the molecule.
/// - name (string): The name of the hook
/// -> drawable
#let hook(name) = {
	(
		(
			type: "hook",
			name: name,
		),
	)
}

/// === Branch and cycles
/// Create a branch from the current molecule, the first element
/// of the branch has to be a link.
/// 
/// You can specify an angle argument like for links. This angle will be then
/// used as the `base-angle` for the branch.
///
/// #example(```
/// #skeletize({
///   molecule("A")
///   branch({
///     single(angle:1)
///     molecule("B")
///   })
///   branch({
///     double(angle: -1)
///     molecule("D")
///   })
///   single()
///   double()
///   single()
///   molecule("C")
/// })
///```)
#let branch(..args) = {
	if args.pos().len() != 1 {
		panic("Branch takes one positional argument: the body of the branch")
	}
  ((type: "branch", draw: args.pos().at(0), args: args.named()),)
}

/// Create a regular cycle of molecules
/// You can specify an angle argument like for links. This angle will be then
/// the angle of the first link of the cycle.
///
/// The argument `align` can be used to force align the cycle according to the
/// relative angle of the previous link.
///
/// #example(```
/// #skeletize({
///   cycle(5, {
///     single()
///     double()
///     single()
///     double()
///     single()
///   })
/// })
///```)
#let cycle(..args) = {
  if args.pos().len() != 2 {
    panic("Cycle takes two positional arguments: number of faces and body")
  }
	let faces = args.pos().at(0)
	if faces < 3 {
		panic("A cycle must have at least 3 faces")
	}
  (
    (
      type: "cycle",
      faces: faces,
      draw: args.pos().at(1),
      args: args.named(),
    ),
  )
}
