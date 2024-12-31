#import "elements.typ": package

#let _type-map = (
  "auto": "foundations/auto",
  "none": "foundations/none",
  // foundation
  arguments: "foundations/arguments",
  array: "foundations/array",
  boolean: "foundations/bool",
  bytes: "foundations/bytes",
  content: "foundations/content",
  datetime: "foundations/datetime",
  dictionary: "foundations/dictionary",
  float: "foundations/float",
  function: "foundations/function",
  integer: "foundations/int",
  location: "foundations/location",
  module: "foundations/module",
  plugin: "foundations/plugin",
  regex: "foundations/regex",
  selector: "foundations/selector",
  string: "foundations/str",
  type: "foundations/type",
  label: "foundations/label",
  version: "foundations/version",
  // layout
  alignment: "layout/alignment",
  angle: "layout/angle",
  direction: "layout/direction",
  fraction: "layout/fraction",
  length: "layout/length",
  ratio: "layout/ratio",
  relative: "layout/relative",
  // visualize
  color: "visualize/color",
  gradient: "visualize/gradient",
  stroke: "visualize/stroke",
)

#let _builtin-map = (
  // tutorial
  "set": "../tutorial/formatting/#set-rules",
  "show": "../tutorial/formatting/#show-rules",
  // scripting
  "import": "scripting/#modules",
  // foundations
  "context": "context",
  arguments: "foundations/arguments",
  array: "foundations/array",
  assert: "foundations/assert",
  "auto": "foundations/auto",
  bool: "foundations/bool",
  bytes: "foundations/bytes",
  with: "foundations/function/#definitions-with",
  calc: "foundations/calc",
  clamp: "foundations/calc#functions-clamp",
  abs: "foundations/calc#functions-abs",
  pow: "foundations/calc#functions-pow",
  // TODO: link rest of calc functions
  content: "foundations/content",
  datetime: "foundations/datetime",
  dictionary: "foundations/dictionary",
  duration: "foundations/duration",
  eval: "foundations/eval",
  float: "foundations/float",
  function: "foundations/function",
  int: "foundations/int",
  label: "foundations/label",
  module: "foundations/module",
  "none": "foundations/none",
  panic: "foundations/panic",
  plugin: "foundations/plugin",
  regex: "foundations/regex",
  repr: "foundations/repr",
  selector: "foundations/selector",
  str: "foundations/str",
  // TODO: link rest of str functions
  style: "foundations/style",
  sys: "foundations/sys",
  type: "foundations/type",
  version: "foundations/version",
  // model
  bibliography: "model/bibliography",
  cite: "model/cite",
  document: "model/document",
  figure: "model/figure",
  emph: "model/emph",
  enum: "model/enum",
  list: "model/list",
  numbering: "model/numbering",
  outline: "model/outline",
  par: "model/par",
  parbreak: "model/parbreak",
  quote: "model/quote",
  strong: "model/strong",
  ref: "model/ref",
  table: "model/table",
  terms: "model/terms",
  link: "model/link",
  // text
  raw: "text/raw",
  text: "text/text",
  highlight: "text/highlight",
  linebreak: "text/linebreak",
  lorem: "text/lorem",
  lower: "text/lower",
  upper: "text/upper",
  overline: "text/overline",
  underline: "text/underline",
  smallcaps: "text/smallcaps",
  smartquote: "text/smartquote",
  strike: "text/strike",
  sub: "text/sub",
  super: "text/super",
  // layout
  align: "layout/align",
  alignment: "layout/alignment",
  angle: "layout/angle",
  block: "layout/block",
  box: "layout/box",
  colbreak: "layout/colbreak",
  columns: "layout/columns",
  direction: "layout/direction",
  fraction: "layout/fraction",
  grid: "layout/grid",
  h: "layout/h",
  hide: "layout/hide",
  layout: "layout/layout",
  length: "layout/length",
  measure: "layout/measure",
  move: "layout/move",
  pad: "layout/pad",
  page: "layout/page",
  pagebreak: "layout/pagebreak",
  place: "layout/place",
  ratio: "layout/ratio",
  relative: "layout/relative",
  repeat: "layout/repeat",
  rotate: "layout/rotate",
  scale: "layout/scale",
  stack: "layout/stack",
  v: "layout/v",
  // math
  accent: "math/accent",
  attach: "math/attach",
  cancel: "math/cancel",
  cases: "math/cases",
  class: "math/class",
  equation: "math/equation",
  frac: "math/frac",
  lr: "math/lr",
  mat: "math/mat",
  op: "math/op",
  primes: "math/primes",
  roots: "math/roots",
  sizes: "math/sizes",
  styles: "math/styles",
  underover: "math/underover",
  variants: "math/variants",
  vec: "math/vec",
  // visualize
  circle: "visualize/circle",
  color: "visualize/color",
  ellipse: "visualize/ellipse",
  gradient: "visualize/gradient",
  image: "visualize/image",
  line: "visualize/line",
  path: "visualize/path",
  pattern: "visualize/pattern",
  polygon: "visualize/polygon",
  rect: "visualize/rect",
  square: "visualize/square",
  stroke: "visualize/stroke",
  // instrospection
  counter: "introspection/counter",
  here: "introspection/here",
  locate: "introspection/locate",
  location: "introspection/location",
  metadata: "introspection/metadata",
  query: "introspection/query",
  state: "introspection/state",
  // data-loading
  cbor: "data-loading/cbor",
  csv: "data-loading/csv",
  json: "data-loading/json",
  read: "data-loading/read",
  toml: "data-loading/toml",
  xml: "data-loading/xml",
  yaml: "data-loading/yaml",
)


#let link-docs(..path) = std.link("https://typst.app/docs/reference/" + path.pos().first(), ..path.pos().slice(1))

#let link-dtype(..name) = link-docs(_type-map.at(name.pos().first(), default: ""), ..name.pos().slice(1))

#let link-builtin(..name) = link-docs(_builtin-map.at(name.pos().first(), default: ""), ..name.pos().slice(1))

#let link(..args) = {
  let dest = args.pos().first()
  let body = if args.pos().len() > 1 {
    args.pos().at(1)
  } else {
    dest
  }
  if not args.named().at("footnote", default: true) {
    [#std.link(dest, body)]
  } else {
    [#std.link(dest, body)<mantys:link>]
  }
}

// TODO: Make repo: auto named and load repo url from document
#let github(repo) = {
  if repo.starts-with("https://github.com/") {
    repo = repo.slice(19)
  }
  link("https://github.com/" + repo, repo)
}

#let github-user(name) = {
  link("https://github.com/" + name, sym.at + name)
}

// TODO: Make repo: auto named and load repo name from document
#let github-file(repo, filepath, branch: "main") = {
  if repo.starts-with("https://github.com/") {
    repo = repo.slice(19)
  }
  if filepath.starts-with("/") {
    filepath = filepath.slice(1)
  }
  let url = "https://github.com/" + repo + "/tree/" + branch + "/" + filepath
  link(url, filepath)
}

// TODO: Make repo: auto named and load repo name from document
#let universe(pkg, version: none) = {
  let url = "https://typst.app/universe/package/" + pkg
  if version != none {
    url += "/" + str(version)
  }
  link(url, package(pkg))
}

// TODO: Make repo: auto named and load repo name from document
#let preview(pkg, ver: auto) = {
  if ver == auto {
    let m = pkg.match(regex("\d+\.\d+\.\d+$"))
    if m != none {
      ver = m.text
      pkg = pkg.slice(0, ver.len() + 1)
    } else {
      ver = none
    }
  }
  if type(ver) == str {
    ver = version(..ver.split(".").map(int))
  }
  link(
    "https://github.com/typst/packages/tree/main/packages/preview/"
      + pkg
      + if ver != none {
        "/" + str(ver)
      } else {
        ""
      },
    package(
      pkg
        + if ver != none {
          ":" + str(ver)
        } else {
          ""
        },
    ),
  )
}
