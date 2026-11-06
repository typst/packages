#import "@preview/parsely:0.1.1"
#import "@preview/pariman:0.2.2": *

#show "Pariman": link("https://github.com/pacaunt/pariman")[Pariman]

= Evaluating dimensionful quantities with Pariman

You can parse equations with Parsely and evaluate them with Pariman by writing a tree post-walk which converts each leaf into a `pariman.quantity` and evaluates nodes using `pariman.calculation` functions.


#let eval-pariman-node((head, args, slots)) = {
  import calculation: *
  if head == "add" { add(..args) }
  else if head == "sub" { sub(..args) }
  else if head == "mul" { mul(..args) }
  else if head == "frac" { div(slots.num, slots.denom) }
  else if head == "pow" { pow(..args) }
  else if head == "group" { slots.expr }
  else if head == "sqrt" { root(slots.radicand, 2) }
  else if head == "root" { root(slots.radicand, slots.index.value) }
  else { panic(head) }
}

#let eval-eqn(eqn, vars) = {
  let (tree, rest) = parsely.parse(eqn, parsely.common.arithmetic)
  parsely.walk(tree, leaf: it => {
    if repr(it.func()) == "symbol" {
      if it.text in vars { vars.at(it.text) }
      else { panic("cannot evaluate symbol", it) }
    } else if it.func() == text {
      if it.text in vars { vars.at(it.text) }
      else { exact(eval(it.text)) } // try to eval as number
    } else { panic("cannot evaluate", it) }
  }, post: eval-pariman-node)
}

#let eval-eqn-and-display(eqn, vars) = {
  let ans = eval-eqn(eqn, vars)
  $ eqn &= ans.method \ &approx ans.display $
}

For example, here is an equation which we first parse then substitute dimensionful quantities into:
#eval-eqn-and-display($1/2 m v^2$, (
  m: quantity(75, "kg"),
  v: quantity(1.5, "m/s"),
))

The following examples use Pariman's _in-text quantity declarations_, letting you define quantities and derived values with normal equation syntax.


// define a named quantity
#let define(name, ..args) = {
  qt.new(name, ..args, displayed: false)
  $ name := qt.display(#name)$
}

// define a named quantity in terms of other named quantities
#let derive(name, eqn) = {
  qt.update(name, q => {
    eval-eqn(eqn, q)
  })
  math.equation($ italic(name) := eqn &= qt.method(name) \ &approx qt.display(name)$, block: eqn.block)
}


== Chemical concentration

I put #define("M", "30.0", "g") of sugar into #define("V", "105", "mL") of water in a cup. After being stirred thoroughly, the sugar solution will have a concentration of:
#derive("c", $ M/V $)
== Terminal velocity

A bowl of petunias of mass #define("m", "1.1", "kg") pops into existence at #define("h", "12000", "m", magnitude-limit: 5) altitude. Taking gravity to be #define("g", "9.81", "m/s^2") (assuming this is still Earth) the petunias have gravitational potential energy:
#derive("U", $ m g h $)

Ignoring air resistance, the petunias smash into the ground at velocity:
#derive("V", $ sqrt(2 g h) $)
