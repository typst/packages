// Copyright 2023 Leedehai
// Use of this code is governed by a MIT license in the LICENSE.txt file.
// Repository: https://github.com/Leedehai/typst-physics
// Please see physica-manual.pdf for user docs.

// Returns whether a Content object is an add/sub sequence, e.g. -a, a+b, a-b.
// The caller is responsible for ensuring the input is a Content object.
#let __is_add_sub_sequence(content) = {
  if not content.has("children") { return false }

  let impl(seq) = {
    // Only check the top level, don't descend into the child, since we don't
    // care if the child is a parenthesis group that contains +/-.
    for child in seq.at("children") {
      if child == [+] or child == [#sym.minus] { return true }
    }
    return false
  }

  // We don't consider math-style: see the reasons in the
  // closed PR https://github.com/typst/typst/pull/3063
  return impl(content)
}

// Returns whether a Content object holds an integer. The caller is responsible
// for ensuring the input is a Content object.
#let __content_holds_number(content) = {
  return content.func() == text and regex("^\d+$") in content.text
}

// Given a Content generated from lr(), return the array of sub Content objects.
// Example: "[1,a_1,(1,1),n+1]" => "1", "a_1", "(1,1)", "n+1"
#let __extract_array_contents(input) = {
  assert(type(input) == content, message: "expecting a content type input")
  if input.func() != math.lr { return none }
  // A Content object made by lr() definitely has a "body" field, and a
  // "children" field underneath it. It holds an array of Content objects,
  // starting with a Content holding "(" and ending with a Content holding ")".
  let children = input.at("body").at("children")

  let result_elements = ()  // array of Content objects

  // Skip the delimiters at the two ends.
  let inner_children = children.slice(1, children.len() - 1)
  // "a_1", "(1,1)" are all recognized as one AST node, respectively,
  // because they are syntactically meaningful in Typst. However, things like
  // "a+b", "a*b" are recognized as 3 nodes, respectively, because in Typst's
  // view they are just plain sequences of symbols. We need to join the symbols.
  let current_element_pieces = ()  // array of Content objects
  for i in range(inner_children.len()) {
    let e = inner_children.at(i)
    if e == [ ] or e == [] { continue; }
    if e != [,] { current_element_pieces.push(e) }
    if e == [,] or (i == inner_children.len() - 1) {
      if current_element_pieces.len() > 0 {
        result_elements.push(current_element_pieces.join())
        current_element_pieces = ()
      }
      continue;
    }
  }

  return result_elements;
}

// A bare-minimum-effort symbolic addition.
#let __bare_minimum_effort_symbolic_add(elements) = {
  assert(type(elements) == array, message: "expecting an array of content")
  let operands = ()  // array
  for e in elements {
    if not e.has("children") {
      operands.push(e)
      continue
    }

    // The elements is like "a+b" where there are multiple operands ("a", "b").
    let current_operand = ()
    let children = e.at("children")
    for i in range(children.len()) {
      let child = children.at(i)
      if child == [+] {
        operands.push(current_operand.join())
        current_operand = ()
        continue;
      }
      current_operand.push(child)
    }
    operands.push(current_operand.join())
  }

  let num_sum = 0
  let map_id_to_sym = (:)  // dictionary, symbol repr to symbol
  let map_id_to_sym_sum = (:)  // dictionary, symbol repr to number
  for e in operands {
    if __content_holds_number(e) {
      num_sum += int(e.text)
      continue
    }
    let is_num_times_sth = (
      e.has("children") and __content_holds_number(e.at("children").at(0)))
    if is_num_times_sth {
      let leading_num = int(e.at("children").at(0).text)
      let sym = e.at("children").slice(1).join()  // join to one symbol
      let sym_id = repr(sym)  // string
      if sym_id in map_id_to_sym {
        let sym_sum_so_far = map_id_to_sym_sum.at(sym_id)  // number
        map_id_to_sym_sum.insert(sym_id, sym_sum_so_far + leading_num)
      } else {
        map_id_to_sym.insert(sym_id, sym)
        map_id_to_sym_sum.insert(sym_id, leading_num)
      }
    } else {
      let sym = e
      let sym_id = repr(sym)  // string
      if repr(e) in map_id_to_sym {
        let sym_sum_so_far = map_id_to_sym_sum.at(sym_id)  // number
        map_id_to_sym_sum.insert(sym_id, sym_sum_so_far + 1)
      } else {
        map_id_to_sym.insert(sym_id, sym)
        map_id_to_sym_sum.insert(sym_id, 1)
      }
    }
  }

  let expr_terms = ()  // array of Content object
  let sorted_sym_ids = map_id_to_sym.keys().sorted()
  for sym_id in sorted_sym_ids {
    let sym = map_id_to_sym.at(sym_id)
    let sym_sum = map_id_to_sym_sum.at(sym_id)  // number
    if sym_sum == 1 {
      expr_terms.push(sym)
    } else if sym_sum != 0 {
      expr_terms.push([#sym_sum #sym])
    }
  }
  if num_sum != 0 {
    expr_terms.push([#num_sum])  // make a Content object holding the number
  }

  return expr_terms.join([+])
}

// == Braces

#let Set(..sink) = {
  let args = sink.pos()  // array
  let expr = args.at(0, default: none)
  let cond = args.at(1, default: none)

  if expr == none {
    if cond == none { ${}$ } else { ${mid(|) #cond}$ }
  } else {
    if cond == none { ${#expr}$ } else { ${#expr mid(|) #cond}$ }
  }
}

#let Order(content) = $cal(O)(content)$
#let order(content) = $cal(o)(content)$

#let evaluated(content) = {
  $lr(zwj#content|)$
}
#let eval = evaluated

#let expectationvalue(..sink) = {
  let args = sink.pos()  // array
  let expr = args.at(0, default: none)
  let func = args.at(1, default: none)

  if func == none {
    $lr(angle.l expr angle.r)$
  } else {
    $lr(angle.l func#h(0pt)mid(|)#h(0pt)expr#h(0pt)mid(|)#h(0pt)func angle.r)$
  }
}
#let expval = expectationvalue

// == Vector notations

#let vecrow(..sink) = {
  let (args, kwargs) = (sink.pos(), sink.named())  // array, dictionary
  let delim = kwargs.at("delim", default:"(")
  let rdelim = if delim == "(" {
    ")"
  } else if delim == "[" {
    "]"
  } else if delim == "{" {
    "}"
  } else if delim == "|" {
    "|"
  } else if delim == "||" {
    "||"
  } else { delim }
  // not math.mat(), because the look would be off: the content
  // appear smaller than the sorrounding delimiter pair.
  $lr(#delim #args.join([,]) #rdelim)$
}

// Prefer using super-T-as-transpose() found below.
//
// Note Unicode U+1D40 (#str.from-unicode(7488)) is kinda ugly, and that
// glyph is in the superscript position already so users could not write
// the habitual "A^TT".
#let TT = $sans(upright(T))$

#let __vector(a, accent, be_bold) = {
  let maybe_bold(e) = if be_bold {
    math.bold(math.italic(e))
  } else {
    math.italic(e)
  }
  let maybe_accent(e) = if accent != none {
    math.accent(maybe_bold(e), accent)
  } else {
    maybe_bold(e)
  }
  if type(a) == content and a.func() == math.attach {
    math.attach(
      maybe_accent(a.base),
      t: if a.has("t") { maybe_bold(a.t) } else { none },
      b: if a.has("b") { maybe_bold(a.b) } else { none },
      tl: if a.has("tl") { maybe_bold(a.tl) } else { none },
      bl: if a.has("bl") { maybe_bold(a.bl) } else { none },
      tr: if a.has("tr") { maybe_bold(a.tr) } else { none },
      br: if a.has("br") { maybe_bold(a.br) } else { none },
    )
  } else {
    maybe_accent(a)
  }
}

#let vectorbold(a) = __vector(a, none, true)
#let vb = vectorbold

#let vectorunit(a) = __vector(a, math.hat, true)
#let vu = vectorunit

// According to "ISO 80000-2:2019 Quantities and units — Part 2: Mathematics"
// the vector notation should be either bold italic or non-bold italic accented
// by a right arrow
#let vectorarrow(a) = __vector(a, math.arrow, false)
#let va = vectorarrow

#let grad = $bold(nabla)$
#let div = $bold(nabla)dot.c$
#let curl = $bold(nabla)times$
#let laplacian = $nabla^2$

#let dotproduct = $dot$
#let dprod = dotproduct
#let crossproduct = $times$
#let cprod = crossproduct

#let innerproduct(u, v) = {
  $lr(angle.l #u, #v angle.r)$
}
#let iprod = innerproduct

// == Matrices

// Display matrix element in display/inline style. The latter vertically
// compresses a tall content (e.g. a fraction) while the former doesn't.
// In Typst and LaTeX, a matrix element is automatically cramped, even if
// the matrix is in a standalone math block.
#let __mate(content, big) = {
  if big {
    math.display(content)
  } else {
    math.inline(content)
  }
}

#let matrixdet(..sink) = {
  math.mat(..sink, delim:"|")
}
#let mdet = matrixdet

#let diagonalmatrix(..sink) = {
  let (args, kwargs) = (sink.pos(), sink.named())  // array, dictionary
  let delim = kwargs.at("delim", default:"(")
  let fill = kwargs.at("fill", default: none)

  let arrays = ()  // array of arrays
  let n = args.len()
  for i in range(n) {
    let array = range(n).map((j) => {
      let e = if j == i { args.at(i) } else { fill }
      return e
    })
    arrays.push(array)
  }
  math.mat(delim: delim, ..arrays)
}
#let dmat = diagonalmatrix

#let antidiagonalmatrix(..sink) = {
  let (args, kwargs) = (sink.pos(), sink.named())  // array, dictionary
  let delim = kwargs.at("delim", default:"(")
  let fill = kwargs.at("fill", default: none)

  let arrays = ()  // array of arrays
  let n = args.len()
  for i in range(n) {
    let array = range(n).map((j) => {
      let complement = n - 1 - i
      let e = if j == complement { args.at(i) } else { fill }
      return e
    })
    arrays.push(array)
  }
  math.mat(delim: delim, ..arrays)
}
#let admat = antidiagonalmatrix

#let identitymatrix(order, delim:"(", fill:none) = {
  let order_num = if type(order) == content and __content_holds_number(order) {
    int(order.text)
  } else if type(order) == int {
    order
  } else {
    panic("imat/identitymatrix: the order shall be an integer, e.g. 2")
  }

  let ones = range(order_num).map((i) => 1)
  diagonalmatrix(..ones, delim: delim, fill: fill)
}
#let imat = identitymatrix

#let zeromatrix(order, delim:"(") = {
  let order_num = if type(order) == content and __content_holds_number(order) {
    int(order.text)
  } else if type(order) == int {
    order
  } else {
    panic("zmat/zeromatrix: the order shall be an integer, e.g. 2")
  }

  let ones = range(order_num).map((i) => 0)
  diagonalmatrix(..ones, delim: delim, fill: 0)
}
#let zmat = zeromatrix

#let jacobianmatrix(fs, xs, delim:"(", big: false) = {
  assert(type(fs) == array, message: "expecting an array of function names")
  assert(type(xs) == array, message: "expecting an array of variable names")
  let arrays = ()  // array of arrays
  for f in fs {
    arrays.push(xs.map((x) => __mate(math.frac($diff#f$, $diff#x$), big)))
  }
  math.mat(delim: delim, ..arrays)
}
#let jmat = jacobianmatrix

#let hessianmatrix(fs, xs, delim:"(", big: false) = {
  assert(type(fs) == array, message: "usage: hessianmatrix(f; x, y...)")
  assert(fs.len() == 1, message: "usage: hessianmatrix(f; x, y...)")
  let f = fs.at(0)
  assert(type(xs) == array, message: "expecting an array of variable names")
  let row_arrays = ()  // array of arrays
  let order = xs.len()
  for r in range(order) {
    let row_array = ()  // array
    let xr = xs.at(r)
    for c in range(order) {
      let xc = xs.at(c)
      row_array.push(__mate(math.frac(
        $diff^2 #f$,
        if xr == xc { $diff #xr^2$ } else { $diff #xr diff #xc$ }
      ), big))
    }
    row_arrays.push(row_array)
  }
  math.mat(delim: delim, ..row_arrays)
}
#let hmat = hessianmatrix

#let xmatrix(m, n, func, delim:"(") = {
  let rows = if type(m) == content and __content_holds_number(m) {
    int(m.text)
  } else if type(m) == int {
    m
  } else {
    panic("xmat/xmatrix: the first argument shall be an integer, e.g. 2")
  }

  let cols = if type(n) == content and __content_holds_number(m) {
    int(n.text)
  } else if type(n) == int {
    n
  } else {
    panic("xmat/xmatrix: the second argument shall be an integer, e.g. 2")
  }

  assert(
    type(func) == function,
    message: "func shall be a function (did you forget to add a preceding '#' before the function name)?"
  )
  let row_arrays = ()  // array of arrays
  for i in range(1, rows + 1) {
    let row_array = ()  // array
    for j in range(1, cols + 1) {
      row_array.push(func(i, j))
    }
    row_arrays.push(row_array)
  }
  math.mat(delim: delim, ..row_arrays)
}
#let xmat = xmatrix

#let rot2mat(theta, delim:"(") = {
  let operand = if type(theta) == content and __is_add_sub_sequence(theta) {
    $(theta)$
  } else { theta }
  $mat(cos operand, -sin operand;
       sin operand, cos operand; delim: delim)$
}

#let rot3xmat(theta, delim:"(") = {
  let operand = if type(theta) == content and __is_add_sub_sequence(theta) {
    $(theta)$
  } else { theta }
  $mat(1, 0,           0;
       0, cos operand, -sin operand;
       0, sin operand, cos operand; delim: delim)$
}

#let rot3ymat(theta, delim:"(") = {
  let operand = if type(theta) == content and __is_add_sub_sequence(theta) {
    $(theta)$
  } else { theta }
  $mat(cos operand,  0, sin operand;
       0,            1, 0;
       -sin operand, 0, cos operand; delim: delim)$
}

#let rot3zmat(theta, delim:"(") = {
  let operand = if type(theta) == content and __is_add_sub_sequence(theta) {
    $(theta)$
  } else { theta }
  $mat(cos operand, -sin operand, 0;
       sin operand, cos operand,  0;
       0,           0,            1; delim: delim)$
}

#let grammat(..sink) = {
  let vs = sink.pos()  // array
  let delim = sink.named().at("delim", default: "(")
  let asnorm = sink.named().at("norm", default: false)

  xmat(vs.len(), vs.len(), (i,j) => {
    if (i == j and (not asnorm)) or i != j {
      iprod(vs.at(i - 1), vs.at(j - 1))
    } else {
      let v = vs.at(i - 1)
      $norm(#v)^2$
    }
  }, delim: delim)
}

// == Dirac braket notations

#let bra(f) = $lr(angle.l #f|)$
#let ket(f) = $lr(|#f angle.r)$

#let braket(..sink) = style(styles => {
  let args = sink.pos()  // array

  let bra = args.at(0, default: none)
  let ket = args.at(-1, default: bra)

  if args.len() <= 2 {
    $ lr(angle.l bra#h(0pt)mid(|)#h(0pt)ket angle.r) $
  } else {
    let middle = args.at(1)
    $ lr(angle.l bra#h(0pt)mid(|)#h(0pt)middle#h(0pt)mid(|)#h(0pt)ket angle.r) $
  }
})

#let ketbra(..sink) = style(styles => {
  let args = sink.pos()  // array
  assert(args.len() == 1 or args.len() == 2, message: "expecting 1 or 2 args")

  let ket = args.at(0)
  let bra = args.at(1, default: ket)

  $ lr(|ket#h(0pt)mid(angle.r#h(0pt)angle.l)#h(0pt)bra|) $
})

#let matrixelement(n, M, m) = style(styles => {
  $ lr(angle.l #n#h(0pt)mid(|)#h(0pt)#M#h(0pt)mid(|)#h(0pt)#m angle.r) $
})

#let mel = matrixelement

// == Math functions

#let sin = math.op("sin")
#let sinh = math.op("sinh")
#let arcsin = math.op("arcsin")
#let asin = math.op("asin")

#let cos = math.op("cos")
#let cosh = math.op("cosh")
#let arccos = math.op("arccos")
#let acos = math.op("acos")

#let tan = math.op("tan")
#let tanh = math.op("tanh")
#let arctan = math.op("arctan")
#let atan = math.op("atan")

#let sec = math.op("sec")
#let sech = math.op("sech")
#let arcsec = math.op("arcsec")
#let asec = math.op("asec")

#let csc = math.op("csc")
#let csch = math.op("csch")
#let arccsc = math.op("arccsc")
#let acsc = math.op("acsc")

#let cot = math.op("cot")
#let coth = math.op("coth")
#let arccot = math.op("arccot")
#let acot = math.op("acot")

#let diag = math.op("diag")

#let trace = math.op("trace")
#let tr = math.op("tr")
#let Trace = math.op("Trace")
#let Tr = math.op("Tr")

#let rank = math.op("rank")
#let erf = math.op("erf")
#let Res = math.op("Res")

#let Re = math.op("Re")
#let Im = math.op("Im")

#let sgn = $op("sgn")$

// == Differentials

#let differential(..sink) = {
  let (args, kwargs) = (sink.pos(), sink.named())  // array, dictionary

  let orders = ()
  let var_num = args.len()
  let default_order = [1]  // a Content holding "1"
  let last = args.at(args.len() - 1)
  if type(last) == content {
    if last.func() == math.lr and last.at("body").at("children").at(0) == [\[] {
      var_num -= 1
      orders = __extract_array_contents(last)  // array
    } else if __content_holds_number(last) {
      var_num -= 1
      default_order = last  // treat as a single element
      orders.push(default_order)
    }
  } else if type(last) == int {
    var_num -= 1
    default_order = [#last]  // make it a Content
    orders.push(default_order)
  }

  let dsym = kwargs.at("d", default: $upright(d)$)
  let compact = kwargs.at("compact", default: false)
  // Why a very thin space is the default joiner: see TeXBook, Chapter 18.
  // math.thin (1/6 em, thinspace in typography) is used to separate the
  // differential with the preceding function, so to keep visual cohesion, the
  // width of this joiner inside the differential shall be smaller.
  let prod = kwargs.at("p", default: if compact { none } else { h(0.09em) })

  let difference = var_num - orders.len()
  while difference > 0 {
    orders.push(default_order)
    difference -= 1
  }

  let arr = ()
  for i in range(var_num) {
    let (var, order) = (args.at(i), orders.at(i))
    if order != [1] {
      arr.push($dsym^#order#var$)
    } else {
      arr.push($dsym#var$)
    }
  }
  // Smart spacing, like Typst's built-in "dif" symbol. See TeXBook, Chapter 18.
  $op(#arr.join(prod))$
}
#let dd = differential

#let variation = dd.with(d: sym.delta)
#let var = variation

// Do not name it "delta", because it will collide with "delta" in math
// expressions (note in math mode "sym.delta" can be written as "delta").
#let difference = dd.with(d: sym.Delta)

#let __combine_var_order(var, order) = {
  let naive_result = math.attach(var, t: order)
  if type(var) != content or var.func() != math.attach {
    return naive_result
  }

  if var.has("b") and (not var.has("t")) {
    // Place the order superscript directly above the subscript, as is
    // the custom is most papers.
    return math.attach(var.base, t: order, b: var.b)
  }

  // Even if var.has("t") is true, we don't take any special action. Let
  // user decide. Say, if they want to wrap var in a "(..)", let they do it.
  return naive_result
}

#let derivative(f, ..sink) = {
  if f == [] { f = none }  // Convert empty content to none

  let (args, kwargs) = (sink.pos(), sink.named())  // array, dictionary
  assert(args.len() > 0, message: "variable name expected")

  let d = kwargs.at("d", default: $upright(d)$)
  let slash = kwargs.at("s", default: none)

  let var = args.at(0)
  assert(args.len() >= 1, message: "expecting at least one argument")

  let display(num, denom, slash) = {
    if slash == none {
      $#num/#denom$
    } else {
      let sep = (sym.zwj, slash, sym.zwj).join()
      $#num#sep#denom$
    }
  }

  if args.len() >= 2 {  // i.e. specified the order
    let order = args.at(1)  // Not necessarily representing a number
    let upper = if f == none { $#d^#order$ } else { $#d^#order#f$ }
    let varorder = __combine_var_order(var, order)
    display(upper, $#d#varorder$, slash)
  } else {  // i.e. no order specified
    let upper = if f == none { $#d$ } else { $#d#f$ }
    display(upper, $#d#var$, slash)
  }
}
#let dv = derivative

#let partialderivative(..sink) = {
  let (args, kwargs) = (sink.pos(), sink.named())  // array, dictionary
  assert(args.len() >= 2, message: "expecting one function name and at least one variable name")

  let f = args.at(0)
  if f == [] { f = none }  // Convert empty content to none
  let var_num = args.len() - 1
  let orders = ()
  let default_order = [1]  // a Content holding "1"

  // The last argument might be the order numbers, let's check.
  let last = args.at(args.len() - 1)
  if type(last) == content {
    if last.func() == math.lr and last.at("body").at("children").at(0) == [\[] {
      var_num -= 1
      orders = __extract_array_contents(last)  // array
    } else if  __content_holds_number(last) {
      var_num -= 1
      default_order = last
      orders.push(default_order)
    }
  } else if type(last) == int {
    var_num -= 1
    default_order = [#last]  // make it a Content
    orders.push(default_order)
  }

  let difference = var_num - orders.len()
  while difference > 0 {
    orders.push(default_order)
    difference -= 1
  }

  let total_order = none  // any type, could be a number
  // Do not use kwargs.at("total", default: ...), so as to avoid unnecessary
  // premature evaluation of the default param.
  total_order = if "total" in kwargs {
    kwargs.at("total")
  } else {
    __bare_minimum_effort_symbolic_add(orders)
  }

  let lowers = ()
  for i in range(var_num) {
    let var = args.at(1 + i)  // 1st element is the function name, skip
    let order = orders.at(i)
    if order == [1] {
      lowers.push($diff#var$)
    } else {
      let varorder = __combine_var_order(var, order)
      lowers.push($diff#varorder$)
    }
  }

  let upper = if total_order != 1 and total_order != [1] {  // number or Content
    if f == none { $diff^#total_order$ } else { $diff^#total_order#f$ }
  } else {
    if f == none { $diff$ } else { $diff #f$ }
  }

  let display(num, denom, slash) = {
    if slash == none {
      math.frac(num, denom)
    } else {
      let sep = (sym.zwj, slash, sym.zwj).join()
      $#num#sep#denom$
    }
  }

  let slash = kwargs.at("s", default: none)
  display(upper, lowers.join(), slash)
}
#let pdv = partialderivative

// == Miscellaneous

// With the default font, the original symbol `planck.reduce` has a slash on the
// letter "h", and it is different from the usual "hbar" symbol, which has a
// horizontal bar on the letter "h".
//
// Here, we manually create a "hbar" symbol by adding the font-independent
// horizontal bar produced by strike() to the current font's Planck symbol, so
// that the new "hbar" symbol and the existing Planck symbol look similar in any
// font (not just "New Computer Modern").
//
// However, strike() causes some side effects in math mode: it shifts the symbol
// downward. This seems like a Typst bug. Therefore, we need to use move() to
// eliminate those side effects so that the symbol behave nicely in math
// expressions.
//
// We also need to use wj (word joiner) to eliminate the unwanted horizontal
// spaces that manifests when using the symbol in math mode.
//
// Credit: Enivex in https://github.com/typst/typst/issues/355 was very helpful.
#let hbar = (sym.wj, move(dy: -0.08em, strike(offset: -0.55em, extent: -0.05em, sym.planck)), sym.wj).join()

// A show rule, should be used like:
//   #show: super-T-as-transpose
//   (A B)^T = B^T A^T
// or in scope:
//   #[
//     #show: super-T-as-transpose
//     (A B)^T = B^T A^T
//   ]
#let super-T-as-transpose(document) = {
  show math.attach: elem => {
    let __eligible(e) = {
      if e.func() == math.limits or e.func() == math.scripts { return false }
      if e.func() == math.lr {
        let last = e.at("body").at("children").at(-1)
        return __eligible(last)
      }
      if e.func() == math.equation {
        return __eligible(e.at("body"))
      }
      ((e != [∫]) and (e != [|]) and (e != [‖])
        and (e != [∑]/*U+2211, not greek Sigma U+03A3*/)
        and (e != [∏]/*U+220F, not greek Pi U+03A0 */))
    }

    if __eligible(elem.base) and elem.at("t", default: none) == [T] {
      $attach(elem.base, t: TT, b: elem.at("b", default: #none))$
    } else {
      elem
    }
  }

  document
}

// A show rule, should be used like:
//   #show: super-plus-as-dagger
//   U^+U = U U^+ = I
// or in scope:
//   #[
//     #show: super-plus-as-dagger
//     U^+U = U U^+ = I
//   ]
#let super-plus-as-dagger(document) = {
  show math.attach: elem => {
    let __eligible(e) = {
      if e.func() == math.limits or e.func() == math.scripts { return false }
      if e.func() == math.lr {
        let last = e.at("body").at("children").at(-1)
        return __eligible(last)
      }
      if e.func() == math.equation {
        return __eligible(e.at("body"))
      }
      true
    }

    if __eligible(elem.base) and elem.at("t", default: none) == [+] {
      $attach(elem.base, t: dagger, b: elem.at("b", default: #none))$
    } else {
      elem
    }
  }

  document
}

#let tensor(T, ..sink) = {
  let args = sink.pos()

  let (uppers, lowers) = ((), ())  // array, array
  let hphantom(s) = { hide($#s$) }  // Like Latex's \hphantom

  for i in range(args.len()) {
    let arg = args.at(i)
    let tuple = if arg.has("children") {
      arg.at("children")
    } else {
      ([+], sym.square)
    }
    assert(type(tuple) == array, message: "shall be array")

    let pos = tuple.at(0)
    let symbol = if tuple.len() >= 2 {
      tuple.slice(1).join()
    } else {
      sym.square
    }
    if pos == [+] {
      let rendering = $#symbol$
      uppers.push(rendering)
      lowers.push(hphantom(rendering))
    } else {  // Curiously, equality with [-] is always false, so we don't do it
      let rendering = $#symbol$
      uppers.push(hphantom(rendering))
      lowers.push(rendering)
    }
  }

  // Do not use "...^..._...", because the lower indices appear to be placed
  // slightly lower than a normal subscript.
  // Use a phantom with zwj (zero-width word joiner) to vertically align the
  // starting points of the upper and lower indices. Also, we put T inside
  // the first argument of attach(), so that the indices' vertical position
  // auto-adjusts with T's height.
  math.attach((T,hphantom(sym.zwj)).join(), t: uppers.join(), b: lowers.join())
}

#let taylorterm(fn, xv, x0, idx) = {
  let maybeparen(expr) = {
    if __is_add_sub_sequence(expr) { $(expr)$ }
    else { expr }
  }

  if idx == [0] or idx == 0 {
    $fn (x0)$
  } else if idx == [1] or idx == 1 {
    $fn^((1)) (x0)(xv - maybeparen(x0))$
  } else {
    $frac(fn^((idx)) (x0), maybeparen(idx) !)(xv - maybeparen(x0))^idx$
  }
}

#let isotope(element, /*atomic mass*/a: none, /*atomic number*/z: none) = {
  $attach(upright(element), tl: #a, bl: #z)$
}

#let __signal_element(e, W, color) = {
  let style = 0.5pt + color
  if e == "&" {
    return rect(width: W, height: 1em, stroke: none)
  } else if e == "n" {
    return rect(width: 1em, height: W, stroke: (left: style, top: style, right: style))
  } else if e == "u" {
    return rect(width: W, height: 1em, stroke: (left: style, bottom: style, right: style))
  } else if (e == "H" or e == "1") {
    return rect(width: W, height: 1em, stroke: (top: style))
  } else if e == "h" {
    return rect(width: W * 50%, height: 1em, stroke: (top: style))
  } else if e == "^" {
    return rect(width: W * 10%, height: 1em, stroke: (top: style))
  } else if (e == "M" or e == "-") {
    return line(start: (0em, 0.5em), end: (W, 0.5em), stroke: style)
  } else if e == "m" {
    return line(start: (0em, 0.5em), end: (W * 0.5, 0.5em), stroke: style)
  } else if (e == "L" or e == "0") {
    return rect(width: W, height: 1em, stroke: (bottom: style))
  } else if e == "l" {
    return rect(width: W * 50%, height: 1em, stroke: (bottom: style))
  } else if e == "v" {
    return rect(width: W * 10%, height: 1em, stroke: (bottom: style))
  } else if e == "=" {
    return rect(width: W, height: 1em, stroke: (top: style, bottom: style))
  } else if e == "#" {
    return path(stroke: style, closed: false,
      (0em, 0em), (W * 50%, 0em), (0em, 1em), (W, 1em),
      (W * 50%, 1em), (W, 0em), (W * 50%, 0em),
    )
  } else if e == "|" {
    return line(start: (0em, 0em), end: (0em, 1em), stroke: style)
  } else if e == "'" {
    return line(start: (0em, 0em), end: (0em, 0.5em), stroke: style)
  } else if e == "," {
    return line(start: (0em, 0.5em), end: (0em, 1em), stroke: style)
  } else if e == "R" {
    return line(start: (0em, 1em), end: (W, 0em), stroke: style)
  } else if e == "F" {
    return line(start: (0em, 0em), end: (W, 1em), stroke: style)
  } else if e == "<" {
    return path(stroke: style, closed: false, (W, 0em), (0em, 0.5em), (W, 1em))
  } else if e == ">" {
    return path(stroke: style, closed: false, (0em, 0em), (W, 0.5em), (0em, 1em))
  } else if e == "C" {
    return path(stroke: style, closed: false, (0em, 1em), ((W, 0em), (-W * 75%, 0.05em)))
  } else if e == "c" {
    return path(stroke: style, closed: false, (0em, 1em), ((W * 50%, 0em), (-W * 38%, 0.05em)))
  } else if e == "D" {
    return path(stroke: style, closed: false, (0em, 0em), ((W, 1em), (-W * 75%, -0.05em)))
  } else if e == "d" {
    return path(stroke: style, closed: false, (0em, 0em), ((W * 50%, 1em), (-W * 38%, -0.05em)))
  } else if e == "X" {
    return path(stroke: style, closed: false,
      (0em, 0em), (W * 50%, 0.5em), (0em, 1em),
      (W, 0em), (W * 50%, 0.5em), (W, 1em),
    )
  } else {
    return "[" + e + "]"
  }
}

#let signals(input, step: 1em, color: black) = {
  assert(type(input) == str, message: "input needs to be a string")

  let elements = ()  // array
  let previous = " "
  for e in input {
    if e == " " { continue; }
    if e == "." {
      elements.push(__signal_element(previous, step, color))
    } else {
      elements.push(__signal_element(e, step, color))
      previous = e
    }
  }

  grid(
    columns: (auto,) * elements.len(),
    column-gutter: 0em,
    ..elements,
  )
}

#let BMEsymadd(content) = {
  let elements = __extract_array_contents(content)
  __bare_minimum_effort_symbolic_add(elements)
}

// Add symbol definitions to the corresponding sections. Do not simply append
// them at the end of file.
