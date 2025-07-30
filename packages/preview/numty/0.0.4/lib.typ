// == types ==

#let arrarr(a,b) = (type(a) == array and type(b) == array)
#let arrflt(a,b) = (type(a) == array and type(b) != array)
#let fltarr(a,b) = (type(a) != array and type(b) == array)
#let fltflt(a,b) = (type(a) != array and type(b) != array)
#let is-arr(a) = (type(a) == array)
#let is-mat(m)  = (is-arr(m) and is-arr(m.at(0)))
#let matmat(m,n) = is-mat(m) and is-mat(n)
#let matflt(m,n) = is-mat(m) and type(n) != array
#let fltmat(m,n) = is-mat(n) and type(m) != array

// == boolean ==

#let isna(v) = {
  if is-arr(v){
    v.map(i => if (type(i)==float){i.is-nan()} else {false})
  }
  else{
    if (type(v)==float){v.is-nan()} else {false} 
  }
}

#let all(v) ={
  if is-arr(v){
    v.flatten().all(a => a == true or a ==1)
  }
  else{
    v == true or v == 1
  }
}

#let op(a,b, fun) ={
  // generic operator with broacasting
  if matmat(a,b) {
    a.zip(b).map(((a,b)) => op(a,b, fun))
  }
  else if matflt(a,b){ // supports n-dim matrices
    a.map(v=> op(v,b, fun))
  }
  else if fltmat(a,b){
    b.map(v=> op(a,v, fun))
  }
  else if arrarr(a,b) {
    a.zip(b).map(((i,j)) => fun(i,j))
  }
  else if arrflt(a,b) {
    a.map(a => fun(a,b))
  }
  else if fltarr(a,b) {
    b.map(i => fun(a,i))
  }
  else {
    fun(a,b)
  }
}

#let _eq(i,j, equal-nan) ={
  i==j or (all(isna((i,j))) and equal-nan)
}

#let eq(u,v, equal-nan: false) = {
  // Checks for equality element wise
  // eq((1,2,3), (1,2,3)) = (true, true, true)
  // eq((1,2,3), 1) = (true, false, false)
  let _eqf(i,j)={_eq(i,j, equal-nan)}
  op(u,v, _eqf)
}


#let any(v) ={
  // check if any item is true after iterating everything
  if is-arr(v){
    v.flatten().any(a => a == true or a ==1)
  }
  else{
    v == true or v == 1
  }
}

#let all-eq(u,v) = all(eq(u,v))

#let apply(a, fun) ={
  // vectorize
  // consider returnding a function of a instead?
  if is-arr(a){ //recursion exploted for n-dim
    a.map(v=>apply(v, fun))
  }
  else{
    fun(a)
  }
} 

#let abs(a)= apply(a, calc.abs)

// == Operators ==

#let _add(a,b)=(a + b)
#let _sub(a,b)=(a - b)
#let _mul(a,b)=(a * b)
#let _div(a,b)= if (b!=0) {a/b} else {float.nan}



#let add(u,v) = op(u,v, _add)
#let sub(u, v) = op(u,v, _sub)
#let mult(u, v) = op(u,v, _mul)
#let div(u, v) = op(u,v, _div)
#let pow(u, v) = op(u,v, calc.pow)

// == vectorial ==

#let normalize(a, l:2) = { 
  // normalize a vector, defaults to L2 normalization
  let aux = pow(pow(abs(a),l).sum(),1/l)
  a.map(b => b/aux)
} 

// dot product

#let dot(a,b) = mult(a,b).sum()

// == Algebra, trigonometry ==


#let sin(a) = apply(a,calc.sin)
#let cos(a) = apply(a,calc.cos)
#let tan(a) = apply(a,calc.tan)
#let log(a) = apply(a, j => if (j>0) {calc.log(j)} else {float.nan} )

// matrix

#let transpose(m) = {
    // Get dimensions of the matrix
    let rows = m.len()
    let cols = m.at(0).len()
    range(0, cols).map(c => range(0, rows).map(r => m.at(r).at(c)))
  }

#let matmul(a,b) = {
  let bt = transpose(b)
  a.map(a_row => bt.map(b_col => dot(a_row,b_col)))
}

// others:

#let linspace = (start, stop, num) => {
  // mimics numpy linspace
  let step = (stop - start) / (num - 1)
  range(0, num).map(v => start + v * step)
}

#let logspace = (start, stop, num, base: 10) => {
  // mimics numpy logspace
  let step = (stop - start) / (num - 1)
  range(0, num).map(v => calc.pow(base, (start + v * step)))
}

#let geomspace = (start, stop, num) => {
  // mimics numpy geomspace
  let step = calc.pow( stop / start, 1 / (num - 1))
  range(0, num).map(v => start * calc.pow(step,v))
}

#let to-str(a) = {
  if (type(a) == bool){
    if(a){
      "value1"
    } 
    else {
      "value2"
    } 
  } 
  else{
    str(a)
  }
}

#let print(m) = {
  if is-mat(m) {
   eval("$ mat(" + m.map(v => v.map(j=>to-str(j)).join(",")).join(";")+ ") $")
  }
  else if is-arr(m){
    eval("$ vec(" + m.map(v => str(v)).join(",")+ ") $")
  }
  else{
    eval(" $"+str(M)+"$ ")
  }
}



#let p(m) = {
  let scope = (value1: "true", value2: "false")
  if is-mat(m) {
   eval("$mat(" + m.map(v => v.map(j=>to-str(j)).join(",")).join(";")+ ")$", scope: scope)
  }
  else if is-arr(m){
    eval("$vec(" + m.map(v => str(v)).join(",")+ ")$")
  }
  else{
    eval("$"+str(M)+"$")
  }
}

