// == types ==

#let arrarr(a,b) = (type(a) == array and type(b) == array)
#let arrflt(a,b) = (type(a) == array and type(b) != array)
#let fltarr(a,b) = (type(a) != array and type(b) == array)
#let fltflt(a,b) = (type(a) != array and type(b) != array)
#let arr(a) = (type(a) == array)

// == boolean ==

#let isna(v) = {
  if arr(v){
    v.map(i => if (type(i)==float){i.is-nan()} else {false})
  }
  else{
    if (type(v)==float){v.is-nan()} else {false} 
  }
}

#let all(v) ={
  // easily fooled if wrong array type
  if (v == true or v == 1){
    return true
  }
  else if (v == false or v == 0){
    return false
  }
  else { // is array
    v = v.map(i => if (i==1 or i==true){true} else {false})
    not v.contains(false) 
  }
}

#let _eq(i,j, equal-nan) ={
  i==j or (all(isna((i,j))) and equal-nan)
}

#let eq(u,v, equal-nan: false) = {
  // Checks for equality element wise
  // eq((1,2,3), (1,2,3)) = (true, true, true)
  // eq((1,2,3), 1) = (true, false, false)
  if arrarr(u,v) {
    u.zip(v).map(((i,j)) => (_eq(i,j, equal-nan)))
  } 
  else if arrflt(u,v) {
    u.map(i => _eq(i,v,equal-nan))
  }
  else if fltarr(u,v) {
    v.map(i => _eq(i,u,equal-nan))
  }
  else if fltflt(u,v) {
     _eq(u,v,equal-nan)
  }
}

#let any(v) ={
  v = v.map(i => if (i==1 or i==true){true} else {false})
  v.contains(true) 
}


#let all-eq(u,v) = all(eq(u,v))

// == Operators ==

#let add(a,b) = {
  if arrarr(a,b) {
    a.zip(b).map(((i,j)) => i+j)
  }
  else if arrflt(a,b) {
    a.map(a => a+b)
  }
  else if fltarr(a,b) {
    b.map(b => a+b)
  }
  else {
    a+b
  }
}

#let sub(u, v) = {
  if arrarr(u, v) {
    u.zip(v).map(((u, v)) => u - v)
  }
  else if arrflt(u, v) {
    u.map(i => i - v)
  }
  else if fltarr(u, v) {
    v.map(j => u - j)
  }
  else {
    u - v
  }
}

#let mult(u, v) = {
  if arrarr(u, v) {
    u.zip(v).map(((i,j)) => i*j)
  } 
  else if arrflt(u,v) {
    u.map(i => i*v)
  }
  else if fltarr(u,v) {
     v.map(i => i*u)
  }
  else {
    u*v
  }
}

#let div(u, v) = {
  if arrarr(u, v) {
    u.zip(v).map(((i,j)) => if (j!=0) {i/j} else {float.nan})
  } 
  else if arrflt(u,v) {
    u.map(i => i/v)
  } 
  else if fltarr(u,v) {
    v.map(j => u/j)
  }
  else {
    u/v
  }
}

#let pow(u, v) = {
  if arrarr(u, v) {
    u.zip(v).map(((i,j)) => calc.pow(i,j))
  } 
  else if arrflt(u,v) {
    u.map(i => calc.pow(i,v))
  } 
  else if fltarr(u,v) {
    v.map(j =>  calc.pow(u,j))
  }
  else {
    calc.pow(u,v)
  }
}

// == vectorial ==

#let normalize(a, l:2) = { 
  // normalize a vector
  if l==1{
    let aux = a.sum()
    a.map(b => b/aux)
  }
  else {
    panic("Only supported L1 normalization")
  }
} 

#let norm(a) = { 
  // deprecate
  let aux = a.sum()
  a.map(b => b/aux)
} 

// dot product

#let dot(a,b) = mult(a,b).sum()

// == Algebra, trigonometry ==

#let sin(a) = {
  if arr(a) {
    a.map(a => calc.sin(a))
  }
  else {
    calc.sin(a)
  }
}

#let cos(a) = {
  if arr(a) {
    a.map(a => calc.cos(a))
  }
  else {
    calc.cos(a)
  }
}

#let tan(a) = {
  if arr(a) {
    a.map(a => calc.tan(a))
  }
  else {
    calc.tan(a)
  }
}

#let log(a) = {
  if arr(a) {
    a.map(a => if (a>0) {calc.log(a)} else {float.nan})
  }
  else {
    calc.log(a)
  }
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