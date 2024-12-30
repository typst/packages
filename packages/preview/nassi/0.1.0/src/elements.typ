
#let TYPES = (
  EMPTY: 0,
  PROCESS: 1,
  BRANCH: 2,
  SWITCH: 3,
  LOOP: 4,
  LOOP_2: 5,
  PARALLEL: 6,
  FUNCTION: 7,
  CALL: 8
)

#let element( type, text, ..args ) = (
  (
    type: type,
    text: text,
    pos: (0,0),
    width: auto,
    height: auto,
    inset: auto,
    grow: 0,
    fill: auto,
    stroke: auto,
    name: auto,
    ..args.named()
  ),
)

#let empty = element.with(TYPES.EMPTY, sym.emptyset)

#let function( text, elements, ..args ) = element(TYPES.FUNCTION,
  text,
  elements: elements,
  ..args.named()
)

#let process = element.with(TYPES.PROCESS)

#let assign( var, expression, symbol:sym.arrow.l, ..args ) = element(TYPES.PROCESS,
  var + " " + symbol + " " + expression,
  symbol: symbol,
  ..args.named()
)

#let call = element.with(TYPES.CALL)

#let loop( text, elements, ..args ) = element(TYPES.LOOP,
  text,
  elements: elements,
  ..args.named()
)

#let branch( text, left, right, column-split:50%, labels:(), ..args ) = element(TYPES.BRANCH,
  text,
  left: left,
  right: right,
  column-split: column-split / 100%,
  labels: labels,
  ..args.named()
)

#let switch( text, ..branches-args ) = element(TYPES.SWITCH,
  text,
  brnaches: branches-args.pos(),
  ..branches-args.named()
)

#let parallel( text, ..branches-args ) = element(TYPES.PARALLEL,
  text,
  brnaches: branches-args.pos(),
  ..branches-args.named()
)
