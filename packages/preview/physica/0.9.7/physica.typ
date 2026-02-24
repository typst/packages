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
      if child == [#math.plus] or child == [#sym.minus] { return true }
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

  let result_elements = () // array of Content objects

  // Skip the delimiters at the two ends.
  let inner_children = children.slice(1, children.len() - 1)
  // "a_1", "(1,1)" are all recognized as one AST node, respectively,
  // because they are syntactically meaningful in Typst. However, things like
  // "a+b", "a*b" are recognized as 3 nodes, respectively, because in Typst's
  // view they are just plain sequences of symbols. We need to join the symbols.
  let current_element_pieces = () // array of Content objects
  for i in range(inner_children.len()) {
    let e = inner_children.at(i)
    if e == [ ] or e == [] { continue }
    if e != [#math.comma] { current_element_pieces.push(e) }
    if e == [#math.comma] or (i == inner_children.len() - 1) {
      if current_element_pieces.len() > 0 {
        result_elements.push(current_element_pieces.join())
        current_element_pieces = ()
      }
      continue
    }
  }

  return result_elements
}

// A bare-minimum-effort symbolic addition.
#let __bare_minimum_effort_symbolic_add(elements) = {
  assert(type(elements) == array, message: "expecting an array of content")
  let operands = () // array
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
      if child == [#math.plus] {
        operands.push(current_operand.join())
        current_operand = ()
        continue
      }
      current_operand.push(child)
    }
    operands.push(current_operand.join())
  }

  let num_sum = 0
  let map_id_to_sym = (:) // dictionary, symbol repr to symbol
  let map_id_to_sym_sum = (:) // dictionary, symbol repr to number
  for e in operands {
    if __content_holds_number(e) {
      num_sum += int(e.text)
      continue
    }
    let is_num_times_sth = (
      e.has("children") and __content_holds_number(e.at("children").at(0))
    )
    if is_num_times_sth {
      let leading_num = int(e.at("children").at(0).text)
      let sym = e.at("children").slice(1).join() // join to one symbol
      let sym_id = repr(sym) // string
      if sym_id in map_id_to_sym {
        let sym_sum_so_far = map_id_to_sym_sum.at(sym_id) // number
        map_id_to_sym_sum.insert(sym_id, sym_sum_so_far + leading_num)
      } else {
        map_id_to_sym.insert(sym_id, sym)
        map_id_to_sym_sum.insert(sym_id, leading_num)
      }
    } else {
      let sym = e
      let sym_id = repr(sym) // string
      if repr(e) in map_id_to_sym {
        let sym_sum_so_far = map_id_to_sym_sum.at(sym_id) // number
        map_id_to_sym_sum.insert(sym_id, sym_sum_so_far + 1)
      } else {
        map_id_to_sym.insert(sym_id, sym)
        map_id_to_sym_sum.insert(sym_id, 1)
      }
    }
  }

  let expr_terms = () // array of Content object
  let sorted_sym_ids = map_id_to_sym.keys().sorted()
  for sym_id in sorted_sym_ids {
    let sym = map_id_to_sym.at(sym_id)
    let sym_sum = map_id_to_sym_sum.at(sym_id) // number
    if sym_sum == 1 {
      expr_terms.push(sym)
    } else if sym_sum != 0 {
      expr_terms.push([#sym_sum #sym])
    }
  }
  if num_sum != 0 {
    expr_terms.push([#num_sum]) // make a Content object holding the number
  }

  return expr_terms.join([#math.plus])
}

// == Braces

// Use a semicolon to delimit the expression and condition,
// e.g. Set(a_n), Set(a_i; forall i), Set(vec(1,n); forall n, n|2)
#let Set(..args) = {
  let expr = args.pos().at(0, default: none)
  let cond = args.pos().at(1, default: none)

  if type(expr) == array {
    expr = $#expr.join($,$)$
  }
  if type(cond) == array {
    cond = $#cond.join($,$)$
  }

  if expr == none {
    if cond == none { ${}$ } else { ${mid(|) #cond}$ }
  } else {
    if cond == none { ${#expr}$ } else { ${#expr mid(|) #cond}$ }
  }
}

#let Order(expr) = $cal(O)(expr)$
#let order(expr) = $cal(o)(expr)$

#let evaluated(expr) = {
  $lr(zws#expr|)$
}

#let expectationvalue(..args) = {
  let expr = args.pos().at(0, default: none)
  let func = args.pos().at(1, default: none)

  if func == none {
    $lr(chevron.l expr chevron.r)$
  } else {
    $lr(chevron.l func#h(0pt)mid(|)#h(0pt)expr#h(0pt)mid(|)#h(0pt)func chevron.r)$
  }
}
#let expval = expectationvalue

// == Vector notations

#let vecrow(..args, delim: "(") = {
  let (ldelim, rdelim) = if delim == "(" {
    (math.paren.l, math.paren.r)
  } else if delim == "[" {
    (math.bracket.l, math.bracket.r)
  } else if delim == "{" {
    (math.brace.l, math.brace.r)
  } else if delim == "|" {
    (math.bar.v, math.bar.v)
  } else if delim == "||" {
    (math.bar.v.double, math.bar.v.double)
  } else {
    (delim, delim)
  }
  // not math.mat(), because the look would be off: the content
  // appear smaller than the sorrounding delimiter pair.
  $lr(#ldelim #args.pos().join([#math.comma]) #rdelim)$
}

// Prefer using super-T-as-transpose() found below.
//
// Note Unicode U+1D40 (#str.from-unicode(7488)) is kinda ugly, and that
// glyph is in the superscript position already so users could not write
// the habitual "A^TT".
#let TT = $sans(upright(T))$

#let __vector(symbol, accent, bold) = {
  let maybe_bold(e) = if bold {
    math.bold(math.italic(e))
  } else {
    math.italic(e)
  }
  let maybe_accent(e) = if accent != none {
    math.accent(maybe_bold(e), accent)
  } else {
    maybe_bold(e)
  }
  if type(symbol) == content and symbol.func() == math.attach {
    math.attach(
      maybe_accent(symbol.base),
      t: if symbol.has("t") { maybe_bold(symbol.t) } else { none },
      b: if symbol.has("b") { maybe_bold(symbol.b) } else { none },
      tl: if symbol.has("tl") { maybe_bold(symbol.tl) } else { none },
      bl: if symbol.has("bl") { maybe_bold(symbol.bl) } else { none },
      tr: if symbol.has("tr") { maybe_bold(symbol.tr) } else { none },
      br: if symbol.has("br") { maybe_bold(symbol.br) } else { none },
    )
  } else {
    maybe_accent(symbol)
  }
}

#let vectorbold(symbol) = __vector(symbol, none, true)
#let vb = vectorbold

#let vectorunit(symbol) = __vector(symbol, math.hat, true)
#let vu = vectorunit

// According to "ISO 80000-2:2019 Quantities and units — Part 2: Mathematics"
// the vector notation should be either bold italic or non-bold italic accented
// by a right arrow
#let vectorarrow(symbol) = __vector(symbol, math.arrow, false)
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
  $lr(chevron.l #u, #v chevron.r)$
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

#let matrixdet(..content) = {
  math.mat(..content, delim: "|")
}
#let mdet = matrixdet

#let diagonalmatrix(..args, delim: "(", fill: none) = {
  let arrays = () // array of arrays
  let n = args.pos().len()
  for i in range(n) {
    let array = range(n).map(j => {
      let e = if j == i { args.pos().at(i) } else { fill }
      return e
    })
    arrays.push(array)
  }
  math.mat(delim: delim, ..arrays)
}
#let dmat = diagonalmatrix

#let antidiagonalmatrix(..args, delim: "(", fill: none) = {
  let arrays = () // array of arrays
  let n = args.pos().len()
  for i in range(n) {
    let array = range(n).map(j => {
      let complement = n - 1 - i
      let e = if j == complement { args.pos().at(i) } else { fill }
      return e
    })
    arrays.push(array)
  }
  math.mat(delim: delim, ..arrays)
}
#let admat = antidiagonalmatrix

#let identitymatrix(order, delim: "(", fill: none) = {
  let order_num = if type(order) == content and __content_holds_number(order) {
    int(order.text)
  } else if type(order) == int {
    order
  } else {
    panic("imat/identitymatrix: the order shall be an integer, e.g. 2")
  }

  let ones = range(order_num).map(i => 1)
  diagonalmatrix(..ones, delim: delim, fill: fill)
}
#let imat = identitymatrix

#let zeromatrix(order, delim: "(") = {
  let order_num = if type(order) == content and __content_holds_number(order) {
    int(order.text)
  } else if type(order) == int {
    order
  } else {
    panic("zmat/zeromatrix: the order shall be an integer, e.g. 2")
  }

  let ones = range(order_num).map(i => 0)
  diagonalmatrix(..ones, delim: delim, fill: 0)
}
#let zmat = zeromatrix

#let jacobianmatrix(funcs, args, delim: "(", big: false) = {
  assert(type(funcs) == array, message: "expecting an array of function names")
  assert(type(args) == array, message: "expecting an array of variable names")
  let arrays = () // array of arrays
  for f in funcs {
    arrays.push(args.map(x => __mate(math.frac($partial#f$, $partial#x$), big)))
  }
  math.mat(delim: delim, ..arrays)
}
#let jmat = jacobianmatrix

#let hessianmatrix(func, args, delim: "(", big: false) = {
  assert(type(func) == array, message: "usage: hessianmatrix(f; x, y...)")
  assert(func.len() == 1, message: "usage: hessianmatrix(f; x, y...)")
  let f = func.at(0)
  assert(type(args) == array, message: "expecting an array of variable names")
  let row_arrays = () // array of arrays
  let order = args.len()
  for r in range(order) {
    let row_array = () // array
    let xr = args.at(r)
    for c in range(order) {
      let xc = args.at(c)
      row_array.push(__mate(
        math.frac(
          $partial^2 #f$,
          if xr == xc { $partial #xr^2$ } else { $partial #xr partial #xc$ },
        ),
        big,
      ))
    }
    row_arrays.push(row_array)
  }
  math.mat(delim: delim, ..row_arrays)
}
#let hmat = hessianmatrix

#let xmatrix(row, col, func, delim: "(") = {
  let row_count = if type(row) == content and __content_holds_number(row) {
    int(row.text)
  } else if type(row) == int {
    row
  } else {
    panic("xmat/xmatrix: the first argument shall be an integer, e.g. 2")
  }

  let col_count = if type(col) == content and __content_holds_number(col) {
    int(col.text)
  } else if type(col) == int {
    col
  } else {
    panic("xmat/xmatrix: the second argument shall be an integer, e.g. 2")
  }

  assert(
    type(func) == function,
    message: "func shall be a function (did you forget to add a preceding '#' before the function name)?",
  )
  let row_arrays = () // array of arrays
  for i in range(1, row_count + 1) {
    let row_array = () // array
    for j in range(1, col_count + 1) {
      row_array.push(func(i, j))
    }
    row_arrays.push(row_array)
  }
  math.mat(delim: delim, ..row_arrays)
}
#let xmat = xmatrix

#let rot2mat(angle, delim: "(") = {
  let operand = if type(angle) == content and __is_add_sub_sequence(angle) {
    $(angle)$
  } else { angle }
  $mat(
    cos operand, -sin operand;
    sin operand, cos operand; delim: delim
  )$
}

#let rot3xmat(angle, delim: "(") = {
  let operand = if type(angle) == content and __is_add_sub_sequence(angle) {
    $(angle)$
  } else { angle }
  $mat(
    1, 0, 0;
    0, cos operand, -sin operand;
    0, sin operand, cos operand; delim: delim
  )$
}

#let rot3ymat(angle, delim: "(") = {
  let operand = if type(angle) == content and __is_add_sub_sequence(angle) {
    $(angle)$
  } else { angle }
  $mat(
    cos operand, 0, sin operand;
    0, 1, 0;
    -sin operand, 0, cos operand; delim: delim
  )$
}

#let rot3zmat(angle, delim: "(") = {
  let operand = if type(angle) == content and __is_add_sub_sequence(angle) {
    $(angle)$
  } else { angle }
  $mat(
    cos operand, -sin operand, 0;
    sin operand, cos operand, 0;
    0, 0, 1; delim: delim
  )$
}

#let grammat(..args, delim: "(", norm: false) = {
  xmat(
    args.pos().len(),
    args.pos().len(),
    (i, j) => {
      if (i == j and (not norm)) or i != j {
        iprod(args.pos().at(i - 1), args.pos().at(j - 1))
      } else {
        let v = args.pos().at(i - 1)
        $#math.norm(v)^2$
      }
    },
    delim: delim,
  )
}

// == Dirac braket notations

#let bra(content) = $lr(chevron.l #content|)$
#let ket(content) = $lr(|#content chevron.r)$

#let braket(..args) = {
  let bra = args.pos().at(0, default: none)
  let ket = args.pos().at(-1, default: bra)

  if args.pos().len() <= 2 {
    $ lr(chevron.l bra#h(0pt)mid(|)#h(0pt)ket chevron.r) $
  } else {
    let middle = args.pos().at(1)
    $ lr(chevron.l bra#h(0pt)mid(|)#h(0pt)middle#h(0pt)mid(|)#h(0pt)ket chevron.r) $
  }
}

#let ketbra(..args) = {
  assert(args.pos().len() == 1 or args.pos().len() == 2, message: "expecting 1 or 2 args")

  let ket = args.pos().at(0)
  let bra = args.pos().at(1, default: ket)

  $ lr(|ket#h(0pt)mid(chevron.r#h(0pt)chevron.l)#h(0pt)bra|) $
}

#let matrixelement(n, M, m) = {
  $ lr(chevron.l #n#h(0pt)mid(|)#h(0pt)#M#h(0pt)mid(|)#h(0pt)#m chevron.r) $
}

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

#let sgn = math.op("sgn")

#let lb = math.op("lb")

// == Differentials

#let differential(..args, d: none, prod: none, compact: false) = {
  let orders = ()
  let var_num = args.pos().len()
  let default_order = [1] // a Content holding "1"
  let last = args.pos().at(args.pos().len() - 1)
  if type(last) == content {
    if last.func() == math.lr and last.at("body").at("children").at(0) == [\[] {
      var_num -= 1
      orders = __extract_array_contents(last) // array
    } else if __content_holds_number(last) {
      var_num -= 1
      default_order = last // treat as a single element
      orders.push(default_order)
    }
  } else if type(last) == int {
    var_num -= 1
    default_order = [#last] // make it a Content
    orders.push(default_order)
  }

  let d = if d == none { $upright(d)$ } else { d }
  // Why a very thin space is the default joiner: see TeXBook, Chapter 18.
  // math.thin (1/6 em, thinspace in typography) is used to separate the
  // differential with the preceding function, so to keep visual cohesion, the
  // width of this joiner inside the differential shall be smaller.
  let prod = if prod == none {
    if compact { none } else { h(0.09em, weak: true) }
  } else { prod }

  let difference = var_num - orders.len()
  while difference > 0 {
    orders.push(default_order)
    difference -= 1
  }

  let arr = ()
  for i in range(var_num) {
    let (var, order) = (args.pos().at(i), orders.at(i))
    if order != [1] {
      arr.push($#d^#order#var$)
    } else {
      arr.push($#d#var$)
    }
  }
  // Smart spacing, like Typst's built-in "dif" symbol. See TeXBook, Chapter 18.
  // The width is math.thin (1/6 em, thinspace in typography).
  // $#arr.join(prodsym)$
  $#h(0.16em, weak: true)#arr.join(prod)$
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

#let __derivative_display(upper, func, denom, style) = context {
  if style == none {
    let num = $#upper#func$
    math.frac(num, denom)
  } else if style == "large" {
    let operator = $#upper/#denom$
    /* Measure in math block mode for correct height
     * (See eg. https://github.com/ssotoen/gridlock/issues/2) */
    let size_op = measure($ #operator $).height
    let size_func = measure($ #func $).height
    let bestsize = calc.max(size_op, size_func)
    $#operator lr(#func, size: #bestsize)$
  } else if style == "horizontal" or style == sym.slash {
    let num = $#upper#func$
    math.frac(num, denom, style: "horizontal")
  } else if style == "skewed" {
    let num = $#upper#func$
    math.frac(num, denom, style: style)
  }
}

// Ordinary derivative.
#let derivative(f, ..args, d: none, style: none) = {
  if f == [] { f = none } // Convert empty content to none
  assert(args.pos().len() >= 1, message: "expecting at least one argument")
  let d = if d == none { $upright(d)$ } else { d }
  let var = args.at(0)

  if args.pos().len() >= 2 {
    // i.e. specified the order
    let order = args.pos().at(1) // Not necessarily representing a number
    let upper = $#d^#order$
    let varorder = __combine_var_order(var, order)
    __derivative_display(upper, f, $#d#varorder$, style)
  } else {
    // i.e. no order specified
    let upper = $#d$
    __derivative_display(upper, f, $#d#var$, style)
  }
}
#let dv = derivative

// Partial derivative, with automatic order summation.
#let partialderivative(f, ..args, total: none, d: none, style: none) = {
  if f == [] { f = none } // Convert empty content to none
  let args = args.pos()
  assert(args.len() >= 1, message: "expecting at least one variable name")
  let d = if d == none { sym.partial } else { d }

  let var_num = args.len()
  let orders = ()
  let default_order = [1] // a Content holding "1"

  // The last argument might be the order numbers, let's check.
  let last = args.at(args.len() - 1)
  if type(last) == content {
    if last.func() == math.lr and last.at("body").at("children").at(0) == [\[] {
      var_num -= 1
      orders = __extract_array_contents(last) // array
    } else if __content_holds_number(last) {
      var_num -= 1
      default_order = last
      orders.push(default_order)
    }
  } else if type(last) == int {
    var_num -= 1
    default_order = [#last] // make it a Content
    orders.push(default_order)
  }

  let difference = var_num - orders.len()
  while difference > 0 {
    orders.push(default_order)
    difference -= 1
  }

  // The total order. It could be any type, could be a number
  let total = if total == none {
    __bare_minimum_effort_symbolic_add(orders)
  } else {
    total
  }

  let lowers = ()
  for i in range(var_num) {
    let var = args.at(i)
    let order = orders.at(i)
    if order == [1] {
      lowers.push($#d#var$)
    } else {
      let varorder = __combine_var_order(var, order)
      lowers.push($#d#varorder$)
    }
  }

  let upper = if total != 1 and total != [1] {
    // number or Content
    $#d^#total$
  } else {
    $#d$
  }

  __derivative_display(upper, f, lowers.join(), style)
}
#let pdv = partialderivative

// == Miscellaneous

// With the default font, the original symbol `planck` has a slash on the
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
#let hbar = (sym.wj, strike(offset: -0.55em, extent: -0.05em, "ℎ"), sym.wj).join()

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
      (
        (e != $∫$.body)
          and (e != $|$.body)
          and (e != $‖$.body)
          and (e != $∑$.body /*U+2211, not greek Sigma U+03A3*/)
          and (e != $∏$.body /*U+220F, not greek Pi U+03A0 */)
      )
    }

    if __eligible(elem.base) and elem.at("t", default: none) == $T$.body {
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

    if __eligible(elem.base) and elem.at("t", default: none) == [#math.plus] {
      $attach(elem.base, t: dagger, b: elem.at("b", default: #none))$
    } else {
      elem
    }
  }

  document
}

#let tensor(symbol, ..args) = {
  let (uppers, lowers) = ((), ()) // array, array
  let hphantom(s) = { hide($#s$) } // Like Latex's \hphantom

  for i in range(args.pos().len()) {
    let arg = args.pos().at(i)
    let tuple = if type(arg) == content and arg.has("children") {
      if arg.children.at(0) in ([+], [#math.plus], [-], [#sym.minus]) {
        arg.children
      } else {
        ([#math.plus], ..arg.children)
      }
    } else {
      ([#math.plus], arg)
    }
    assert(type(tuple) == array, message: "shall be array")

    let pos = tuple.at(0)
    let index = tuple.slice(1).join()

    if pos == [#math.plus] {
      let rendering = $#index$
      uppers.push(rendering)
      lowers.push(hphantom(rendering))
    } else {
      let rendering = $#index$
      uppers.push(hphantom(rendering))
      lowers.push(rendering)
    }
  }

  // Do not use "...^..._...", because the lower indices appear to be placed
  // slightly lower than a normal subscript.
  // Use a phantom with zws (zero-width space) to vertically align the
  // starting points of the upper and lower indices. Also, we put T inside
  // the first argument of attach(), so that the indices' vertical position
  // auto-adjusts with the tenosr symbol's height.
  math.attach((symbol, hphantom(sym.zws)).join(), t: uppers.join(), b: lowers.join())
}

#let taylorterm(func, x, x0, idx) = {
  let maybeparen(expr) = {
    if __is_add_sub_sequence(expr) { $(expr)$ } else { expr }
  }

  if idx == [0] or idx == 0 {
    $func (x0)$
  } else if idx == [1] or idx == 1 {
    $func^((1)) (x0)(#x - maybeparen(x0))$
  } else {
    $frac(func^((idx)) (x0), maybeparen(idx) !)(#x - maybeparen(x0))^idx$
  }
}

// Proud to document that Typst merged the author Leedehai's pull request
// https://github.com/typst/typst/pull/825, a feature to make this function
// appropriately, without a ton of acrobatics.
#let isotope(element, /*atomic mass*/ a: none, /*atomic number*/ z: none) = {
  let a_content = if type(a) == int { [#a] } else { a }
  let z_content = if type(z) == int { [#z] } else { z }
  $attach(upright(element), tl: #a_content, bl: #z_content)$
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
    return curve(
      stroke: style,
      curve.move((0em, 0em)),
      curve.line((W * 50%, 0em)),
      curve.line((0em, 1em)),
      curve.line((W, 1em)),
      curve.line((W * 50%, 1em)),
      curve.line((W, 0em)),
      curve.line((W * 50%, 0em)),
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
    return curve(stroke: style, curve.move((W, 0em)), curve.line((0em, 0.5em)), curve.line((W, 1em)))
  } else if e == ">" {
    return curve(stroke: style, curve.move((0em, 0em)), curve.line((W, 0.5em)), curve.line((0em, 1em)))
  } else if e == "C" {
    return curve(stroke: style, curve.move((0em, 1em)), curve.quad((W * 20%, 0.2em), (W, 0em)))
  } else if e == "D" {
    return curve(stroke: style, curve.move((0em, 0em)), curve.quad((W * 20%, 0.8em), (W, 1em)))
  } else if e == "X" {
    return curve(
      stroke: style,
      curve.move((0em, 0em)),
      curve.line((W, 1em)),
      curve.line((W * 50%, 0.5em)),
      curve.line((W, 0em)),
      curve.line((0em, 1em)),
    )
  } else if e == "r" {
    return box(width: 0pt, curve(
      stroke: style,
      fill: color,
      curve.move((0em + 1pt, 0.4em)),
      curve.line((-0.1em + 1pt, 0.6em)),
      curve.line((0.1em + 1pt, 0.6em)),

      curve.close(),
      curve.move((0em + 1pt, 0em)),
      curve.line((0em + 1pt, 1em)),
    ))
  } else if e == "f" {
    return box(width: 0pt, curve(
      stroke: style,
      fill: color,
      curve.move((0em + 1pt, 0.6em)),
      curve.line((-0.1em + 1pt, 0.4em)),
      curve.line((0.1em + 1pt, 0.4em)),

      curve.close(),
      curve.move((0em + 1pt, 0em)),
      curve.line((0em + 1pt, 1em)),
    ))
  } else {
    return "[" + e + "]"
  }
}

// NOTE this is in maintainence mode: no new feature accepted, but bug fixes
// are still welcome. I believe a standalone package for signal sequence
// diagrams is the best route going forward.
#let signals(input, step: 1em, color: black) = {
  assert(type(input) == str, message: "input needs to be a string")

  let elements = () // array
  let previous = " "
  for e in input {
    if e == " " { continue }
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
