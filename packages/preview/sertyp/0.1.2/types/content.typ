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
  let dict = (
    func: func_.serializer(fn),
  )
  if fields.len() > 0 {
    dict = (
      ..dict,
      fields: dict_.serializer(fields)
    )
  }

  return generic.raw_serializer(dictionary)(dict)
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
    let sequence = [a + b].func()
    sequence(children)
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
  "math.styled": (..args) => {
    args = split_positional(("child",), args)
    // This is unstable and does not deserialize into the exact serialized content.
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
  "math.class": (..args) => {
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
    let metadata = metadata(..args.pos())
    if "label" in named {
      let label = named.remove("label")
      metadata = [#metadata #label].fields().children.at(0)
    }
    return metadata
  },
  "state-update": (..args) => {
    panic("complex state update deserialization is not supported")
  },
);


#let deserializer(d) = {
  utils.assert_type(d, dictionary)

  import "dictionary.typ" as dict_
  let args = if "fields" in d { 
    dict_.deserializer(d.at("fields"))
  } else { 
    utils.str_dict() 
  }
  let args = split_positional(("body", "text"), arguments(..args))

  import "function.typ" as func_
  let func = if d.func in FN { FN.at(d.func) } else { func_.deserializer(d.func) }
  return func(..args)
}

#let test(cycle) = {
  cycle([123]);
  cycle(strong("Bold Text"))
  cycle($1/2$)
  cycle([abc #auto $root(2+1, 3) alpha$])

  // math.accent
  cycle($accent(a, b)$)
  // cycle($hat(dotless: #false, i)$)
  cycle($dash(A, size: #150%)$)

  // math.attach
  cycle($a_b$)
  cycle($attach(
    Pi, t: alpha, b: beta,
    tl: 1, tr: 2+3, bl: 4+5, br: 6,
  )$)
  
  // math.binom
  cycle($binom(n, k, k_2)$)


  // math.cancel
  cycle($cancel(x+y)$)
  cycle($cancel(1/(1+x), angle: #90deg)$)
  cycle($cancel(1/x, angle: #auto, cross: #false, inverted: #false, length: #100%, stroke: #stroke(2pt))$)

  // math.cases
  cycle($cases(x+1 = 2, x = 1)$)
  cycle($cases(x+1 = 3, x_2=4, delim: #symbol("["), gap: #2%, reverse: #false)$)


  // math.class
  cycle($class("relation", a+b=c)$)

  // math.equation
  cycle($a+d => e$)
  cycle(math.equation($a + b = c$, number-align: left, numbering: "1.1.1", supplement: auto))

  //math.frac
  cycle($frac(1, 2)$)
  // cycle($ frac(x, y, style: "horizontal") $);

  // math.lr
  cycle($math.floor(a+b+c)$)
  cycle($lr(a, size: #10%)$)

  // math.mat
  cycle($mat(1,2;2)$);
  cycle($mat(
    (a, b), (c, d),
    delim: #symbol("|"),
    align: #center,
    augment: #2,
    gap: #5%,
    row-gap: #10pt,
    column-gap: #15pt,
  )$);

  // math.op
  cycle($sin(4)$)
  cycle($op(a+b, limits: #true)$)

  // math.primes
  cycle($primes(#3)$)

  // math.root
  cycle($sqrt(2), root(3,2)$)

  // match.stretch
  cycle($stretch(=>)$)
  cycle(math.stretch($a+b+c$, size: 150%))

  // math.styled
  cycle(math.display($a$, cramped: true))
  cycle(math.inline($b$))
  cycle(math.script($c$, cramped: true))
  cycle(math.sscript($c$, cramped: true))

  // math.vec
  cycle($vec(a, b, c)$)
  cycle($vec(a, b, c, delim: #symbol("["), gap: #2%, align: #center)$)

  // h
  cycle(h(10pt))
  cycle(h(5pt, weak: true))

  // v
  cycle(v(10pt))
  cycle(v(5%, weak: true))

  // metadata
  cycle(metadata("Test Metadata"))
  // cycle(metadata("Test with Label", label: "meta1"))
  cycle([#metadata("Test with Label") <meta1>])

  // raw
  // panic(generic.serializer(raw("Raw content test")))
  cycle(raw("Raw content test"))
  cycle(raw("Raw content test", align: center, lang: "en", block: true, syntaxes: (), tab-size: 4, theme: auto))

  // space
  cycle([ ])

  // stack
  cycle(stack(
    [first],
    [second],
    dir: ttb,
    spacing: 5pt,
  ))

  // strong
  cycle(strong("Bold Text"))
  cycle(strong("Bold Text", delta: 800))

  // symbol
  cycle($#alpha$)

  // text
  cycle(text("Sample Text"))
  cycle(text("Sample Text", 
    alternates: true, 
    baseline: 2pt,
    bottom-edge: "baseline",
    cjk-latin-spacing: auto,
    spacing: 5pt,
    costs: (:),
    dir: ltr,
    discretionary-ligatures: true,
    fallback: true,
    fill: black,
    font: "Roboto",
    hyphenate: true,
    kerning: true,
    lang: "en",
    ligatures: true,
    number-type: "lining",
    number-width: "proportional",
    overhang: false,
    size: 12pt,
    slashed-zero: false,
    stretch: 100%,
    style: "normal",
    tracking: 0em,
    weight: 400,
  ))  
};
