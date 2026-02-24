#import "@preview/cetz:0.3.1"
#import "src/default.typ": default
#import "src/utils/utils.typ"
#import "src/drawer.typ"
#import "src/drawer.typ": skeletize, draw-skeleton
#import "src/elements/links.typ": *
#import "src/elements/molecule.typ": *
#import "src/elements/lewis.typ": *

#let transparent = color.rgb(100%, 0, 0, 0)

/// === Molecule function
/// Build a molecule group based on mol
/// Each molecule is represented as an optional count followed by a molecule name
/// starting by a capital letter followed by an optional exponent followed by an optional indice.
/// #example(```
/// #skeletize({
///   molecule("H_2O")
/// })
///```)
/// #example(```
/// #skeletize({
///  	molecule("H^A_EF^5_4")
/// })
/// ```)
/// It is possible to use an equation as a molecule. In this case, the splitting of the equation uses the same rules as in the string case. However, you get some advantages over the string version:
/// - You can use parenthesis to group elements together.
/// - You have no restriction about what you can put in exponent or indice.
/// #example(```
/// #skeletize({
///   molecule($C(C H_3)_3$)
/// })
///```)
/// - name (content): The name of the molecule. It is used as the cetz name of the molecule and to link other molecules to it.
/// - links (dictionary): The links between this molecule and previous molecules or hooks. The key is the name of the molecule or hook and the value is the link function. See @links.
///
/// Note that the atom-sep and angle arguments are ignored
/// - lewis (list): The list of lewis structures to draw around the molecules. See @lewis
/// - mol (string, equation): The string representing the molecule or an equation of the molecule
/// - vertical (boolean): If true, the molecule is drawn vertically
/// #example(```
/// #skeletize({
///   molecule("ABCD", vertical: true)
/// })
///```)
/// -> drawable
#let molecule(name: none, links: (:), lewis: (), vertical: false, mol) = {
  let atoms = if type(mol) == str {
    split-string(mol)
  } else if mol.func() == math.equation {
    split-equation(mol, equation: true)
  } else {
    panic("Invalid molecule content")
  }

  if type(lewis) != array {
    panic("Lewis formulae elements must be in a list")
  }

  (
    (
      type: "molecule",
      name: name,
      atoms: atoms,
      links: links,
      lewis: lewis,
      vertical: vertical,
      count: atoms.len(),
    ),
  )
}

/// === Hooks
/// Create a hook in the molecule. It allows to connect links to the place where the hook is.
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
/// - body (drawable): the body of the branch. It must start with a link.
/// -> drawable
#let branch(body, ..args) = {
  if args.pos().len() != 0 {
    panic("Branch takes one positional argument: the body of the branch")
  }
  ((type: "branch", body: body, args: args.named()),)
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
/// - faces (int): the number of faces of the cycle
/// - body (drawable): the body of the cycle. It must start and end with a molecule or a link.
/// -> drawable
#let cycle(faces, body, ..args) = {
  if args.pos().len() != 0 {
    panic("Cycle takes two positional arguments: number of faces and body")
  }
  if faces < 3 {
    panic("A cycle must have at least 3 faces")
  }
  (
    (
      type: "cycle",
      faces: faces,
      body: body,
      args: args.named(),
    ),
  )
}

/// === Parenthesis
/// Encapsulate a drawable between two parenthesis. The left parenthesis is placed at the left of the first element of the body and by default the right parenthesis is placed at the right of the last element of the body.
///
/// #example(```
/// #skeletize(
///   config: (
/// 		angle-increment: 30deg
/// 	), {
/// 	parenthesis(
/// 		l:"[", r:"]",
/// 		br: $n$, {
/// 		single(angle: 1)
/// 		single(angle: -1)
/// 		single(angle: 1)
/// 	})
/// })
/// ```)
/// For more examples, see @examples
///
/// - body (drawable): the body of the parenthesis. It must start and end with a molecule or a link.
/// - l (string): the left parenthesis
/// - r (string): the right parenthesis
/// - align (true): if true, the parenthesis will have the same y position. They will also get sized and aligned according to the body height. If false, they are not aligned and the height argument must be specified.
///
/// - height (float, length): the height of the parenthesis. If align is true, this argument is optional.
/// - yoffset (float, length, list): the vertical offset of parenthesis. You can also provide a tuple for left and right parenthesis
/// - xoffset (float, length, list): the horizontal offset of parenthesis. You can also provide a tuple for left and right parenthesis
/// - right (string): Sometime, it is not convenient to place the right parenthesis at the end of the body. In this case, you can specify the name of the molecule or link where the right parenthesis should be placed. It is especially useful when the body end by a cycle. See @polySulfide
/// - tr (content): the exponent content of the right parenthesis
/// - br (content): the indice content of the right parenthesis
/// -> drawable
#let parenthesis(body, l: "(", r: ")", align: true, height: none, yoffset: none, xoffset: none, right: none, tr: none, br: none) = {
  (
    (
      type: "parenthesis",
      body: body,
      calc: calc,
      l: l,
      r: r,
      align: align,
      tr: tr,
      br: br,
      height: height,
      xoffset: xoffset,
			yoffset: yoffset,
			right: right,
    ),
  )
}
