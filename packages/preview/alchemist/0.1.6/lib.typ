#import "@preview/cetz:0.3.4"
#import "src/default.typ": default
#import "src/utils/utils.typ"
#import "src/drawer.typ"
#import "src/drawer.typ": skeletize, draw-skeleton
#import "src/elements/links.typ": *
#import "src/elements/fragment.typ": *
#import "src/elements/lewis.typ": *

#let transparent = color.rgb(100%, 0, 0, 0)

/// === Fragment function
/// Build a fragment group based on mol
/// Each fragment is represented as an optional count followed by a fragment name
/// starting by a capital letter followed by an optional exponent followed by an optional indice.
/// #example(```
/// #skeletize({
///   fragment("H_2O")
/// })
///```)
/// #example(```
/// #skeletize({
///  	fragment("H^A_EF^5_4")
/// })
/// ```)
/// It is possible to use an equation as a fragment. In this case, the splitting of the equation uses the same rules as in the string case. However, you get some advantages over the string version:
/// - You can use parenthesis to group elements together.
/// - You have no restriction about what you can put in exponent or indice.
/// #example(```
/// #skeletize({
///   fragment($C(C H_3)_3$)
/// })
///```)
/// - name (content): The name of the fragment. It is used as the cetz name of the fragment and to link other fragments to it.
/// - links (dictionary): The links between this fragment and previous fragments or hooks. The key is the name of the fragment or hook and the value is the link function. See @links.
///
/// Note that the atom-sep and angle arguments are ignored
/// - lewis (list): The list of lewis structures to draw around the fragments. See @lewis
/// - mol (string, equation): The string representing the fragment or an equation of the fragment
/// - vertical (boolean): If true, the fragment is drawn vertically
/// #example(```
/// #skeletize({
///   fragment("ABCD", vertical: true)
/// })
///```)
/// - colors (color|list): The color of the fragment. If a list is provided, it colors each group of the fragment with the corresponding color from right to left. If the number of colors is less than the number of groups, the last color is used for the remaining groups. If the number of colors is greater than the number of groups, the extra colors are ignored.
/// #example(```
/// #skeletize({
///   fragment("ABCD", colors: (red, green, blue))
///   single()
///   fragment("EFGH", colors: (orange))
/// })
/// ```)
/// -> drawable
#let fragment(name: none, links: (:), lewis: (), vertical: false, colors: none, mol) = {
  let atoms = if type(mol) == str {
    split-string(mol)
  } else if mol.func() == math.equation {
    split-equation(mol, equation: true)
  } else {
    panic("Invalid fragment content")
  }

  if type(lewis) != array {
    panic("Lewis formulae elements must be in a list")
  }

  (
    (
      type: "fragment",
      name: name,
      atoms: atoms,
      colors: colors,
      links: links,
      lewis: lewis,
      vertical: vertical,
      count: atoms.len(),
    ),
  )
}
#let molecule(name: none, links: (:), lewis: (), vertical: false, mol) = fragment(name: name, links: links, lewis: lewis, vertical: vertical, mol)

/// === Hooks
/// Create a hook in the fragment. It allows to connect links to the place where the hook is.
/// Hooks are placed at the end of links or at the beginning of the fragment.
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
/// Create a branch from the current fragment, the first element
/// of the branch has to be a link.
///
/// You can specify an angle argument like for links. This angle will be then
/// used as the `base-angle` for the branch.
///
/// #example(```
/// #skeletize({
///   fragment("A")
///   branch({
///     single(angle:1)
///     fragment("B")
///   })
///   branch({
///     double(angle: -1)
///     fragment("D")
///   })
///   single()
///   double()
///   single()
///   fragment("C")
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

/// Create a regular cycle of fragments
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
/// - body (drawable): the body of the cycle. It must start and end with a fragment or a link.
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
/// - body (drawable): the body of the parenthesis. It must start and end with a fragment or a link.
/// - l (string): the left parenthesis
/// - r (string): the right parenthesis
/// - align (true): if true, the parenthesis will have the same y position. They will also get sized and aligned according to the body height. If false, they are not aligned and the height argument must be specified.
/// - resonance (boolean): if true, the parenthesis will be drawn in resonance mode. This means that the left and right parenthesis will be placed outside the molecule. Also, the parenthesis will be separated from the previous and next molecule. This can be true only if the parenthesis is the first element of the skeletal formula or if the previous element is an operator. See @resonance for more details.
/// - height (float, length): the height of the parenthesis. If align is true, this argument is optional.
/// - yoffset (float, length, list): the vertical offset of parenthesis. You can also provide a tuple for left and right parenthesis
/// - xoffset (float, length, list): the horizontal offset of parenthesis. You can also provide a tuple for left and right parenthesis
/// - right (string): Sometime, it is not convenient to place the right parenthesis at the end of the body. In this case, you can specify the name of the fragment or link where the right parenthesis should be placed. It is especially useful when the body end by a cycle. See @polySulfide
/// - tr (content): the exponent content of the right parenthesis
/// - br (content): the indice content of the right parenthesis
/// -> drawable
#let parenthesis(body, l: "(", r: ")", align: true, resonance: false, height: none, yoffset: none, xoffset: none, right: none, tr: none, br: none) = {
	if l.len() > 2 {
		panic("Left can be at most 2 characters")
	}
	let l = eval(l, mode: "math")
	if r.len() > 2 {
		panic("Right can be at most 2 characters")
	}
	let r = eval(r, mode: "math")
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
      resonance: resonance,
    ),
  )
}


/// === Operator
/// Create an operator between two fragments. Creating an operator "reset" the placement of the next fragment.
/// This allow to add multiple molecules in the same skeletal formula. Without this, the next fragment would be placed at the end of the previous one.
/// An important point is that you can't use previous hooks to link two molecules separate by an operator.
/// This element is used in resonance structures (@resonance) and in some cases to put multiples molecules in the same skeletal formula (as you can set op to none).
/// 
/// - op (content | string | none): The operator content. It can be a string or a content. A none value won't display anything.
/// #example(```
/// #skeletize({
///  fragment("A")
/// operator($->$, margin: 1em)
/// fragment("B")
/// })
/// ```)
/// See @resonance for more examples.
/// - name (string): The name of the operator.
/// - margin (float, length): The margin between the operator and previous / next molecule.
/// -> drawable
#let operator(name: none, margin: 1em, op) = {
  (
    (
      type: "operator",
      name: name,
      op: op,
      margin: margin,
    ),
  )
}