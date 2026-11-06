#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(c) = {
  utils.assert_type(c, content)

  /// subtype of content
  let fn = c.func()

  let fields = utils.str_dict()
  fields = c
    .fields()
    .pairs()
    .filter(((k, v)) => {
      not (repr(fn) == "styled" and k == "styles")
    })
    .to-dict()

  // UNSUPPORTED: context serialization is unsupported
  if repr(fn) == "context" {
    panic("Context serialization is unsupported")
  }

  import "function.typ" as func_
  import "dictionary.typ" as dict_
  return generic.raw_serializer(dictionary)((
    func: func_.serializer(fn),
    fields: dict_.serializer(fields),
  ));
}

/// Splits positional arguments from named arguments based on a list of positional argument names.
/// Arguments:
///   pos_args: A tuple of argument names that should be treated as positional.
///   args: The original arguments object containing both positional and named arguments.
/// Returns:
///   A new arguments object with the specified positional arguments moved to the front.
/// Example:
/// ```typst
/// let args = arguments(amount: 5, other: "value")
/// assert(split_positional(("amount",), args) == arguments(5, other: "value"))
/// ```
#let split_positional = (pos_args, args) => {
  let named = args.named()
  let pos = args.pos()
  for key in pos_args {
    if key not in named.keys() {
      continue
    }
    pos.push(named.remove(key))
  }
  return arguments(..pos, ..named)
}

#let FN = (
  "symbol": (..args) => {
    [#symbol(..args)]
  },
  "sequence": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    for child in children {
      [#child]
    }
  },
  "space": () => {
    [ ]
  },
  "h": (..args) => {
    let args = split_positional(("amount",), args)
    h(..args)
  },
  "v": (..args) => {
    let args = split_positional(("amount",), args)
    v(..args)
  },
  "math.root": (..args) => {
    let args = split_positional(("index", "radicand"), args)
    if args.pos().len() == 1 {
      return math.sqrt(..args)
    }
    math.root(..args)
  },
  "math.accent": (..args) => {
    let args = split_positional(("base", "accent"), args)
    math.accent(..args)
  },
  "math.attach": (..args) => {
    let args = split_positional(("base",), args)
    math.attach(..args)
  },
  "math.binom": (..args) => {
    let named = args.named()
    let upper = named.remove("upper")
    let lower = named.remove("lower")
    math.binom(upper, ..lower)
  },
  "math.cases": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    math.cases(..children, ..named)
  },
  "math.frac": (..args) => {
    let args = split_positional(("num", "denom"), args)
    math.frac(..args)
  },
  "math.mat": (..args) => {
    let args = split_positional(("rows",), args)
    let rows = args.pos().at(0)
    math.mat(..rows, ..args.named())
  },
  "math.primes": (..args) => {
    let args = split_positional(("count",), args)
    math.primes(..args)
  },
  "styled": (..args) => {
    args = split_positional(("child",), args)
    math.display(..args)
  },
  "math.vec": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    math.vec(..children, ..named)
  },
  "context": (..args) => {
    panic("context deserialization is unsupported")
  },
  "ref": (..args) => {
    let args = split_positional(("target",), args)
    ref(..args)
  },
  "item": (..args) => {
    for arg in args.pos() {
      [+ #arg]
    }
  },
  "enum": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    enum(..children, ..named)
  },
  "table": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    table(..children, ..named)
  },
  "table.header": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    table.header(..children, ..named)
  },
  "align-point": (..args) => {
    $&$
  },
  "class": (..args) => {
    let named = args.named()
    let relation = named.remove("class")
    math.class(relation, ..args.pos(), ..named)
  },
  "align": (..args) => {
    let args = split_positional(("alignment",), args)
    align(..args)
  },
  "rotate": (..args) => {
    let args = split_positional(("angle",), args)
    rotate(..args)
  },
  "columns": (..args) => {
    let args = split_positional(("count",), args)
    columns(..args)
  },
  "place": (..args) => {
    let args = split_positional(("alignment",), args)
    place(..args)
  },
  "stack": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    stack(..children, ..named)
  },
  "grid": (..args) => {
    let named = args.named()
    let children = named.remove("children")
    grid(..children, ..named)
  },
  "caption": (..args) => {
    let args = split_positional(("body",), args)
    args.pos().at(0)
  },
  "curve": (..args) => {
    let named = args.named()
    let components = named.remove("components")
    curve(..components, ..named)
  },
  "curve.move": (..args) => {
    let args = split_positional(("start",), args)
    curve.move(..args)
  },
  "curve.line": (..args) => {
    let args = split_positional(("end",), args)
    curve.line(..args)
  },
  "curve.cubic": (..args) => {
    let args = split_positional(("control-start", "control-end", "end"), args)
    curve.cubic(..args)
  },
  "image": (..args) => {
    let args = split_positional(("source",), args)
    image(..args)
  },
  "path": (..args) => {
    let named = args.named()
    let vertices = named.remove("vertices")
    path(..vertices, ..named)
  },
  "polygon": (..args) => {
    let named = args.named()
    let vertices = named.remove("vertices")
    polygon(..vertices, ..named)
  },
  "metadata": (..args) => {
    let args = split_positional(("value",), args)
    let named = args.named()
    let metadata = metadata(..args.pos(), ..named)
    if "label" in named {
      let label = named.remove("label")
      metadata = [#metadata #label]
    }
    return metadata;
  },
  "state-update": (..args) => {
    panic("complex sftate update deserialization is not supported")
  },
);


#let deserializer(d) = {
  utils.assert_type(d, dictionary)

  import "dictionary.typ" as dict_
  let args = dict_.deserializer(d.at("fields"))
  let args = split_positional(("body", "text"), arguments(..args))

  import "function.typ" as func_
  let func = if d.func in FN { FN.at(d.func) } else { func_.deserializer(d.func) };
  return func(..args)
}

#let test(cycle) = {
  cycle([123]);
  cycle(strong("Bold Text"));
  cycle($1/2$);
  cycle([abc #auto $root(2+1,3)$]);
};
