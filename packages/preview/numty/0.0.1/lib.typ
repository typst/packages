// == boolean helpers ==

#let arrarr(a,b) = (type(a) == array and type(b) == array)
#let arrflt(a,b) = (type(a) == array and type(b) != array)
#let fltarr(a,b) = (type(a) != array and type(b) == array)

// == basic functions ==

#let pow(a, power) = {
  if arrarr(a,power) {
    a.zip(power).map(((a,b)) => a/b)
  } 
  else {
    a.map(r => calc.pow(r,power))
  }
}

#let mult(a,b) = {
  if arrarr(a,b) {
    a.zip(b).map(((a,b)) => a*b)
  } 
  else if (type(a) == array) {
    a.map(a => a*b)
  }
  else {
    mult(b,a)
  }
}

#let div(a,b) = {
  if arrarr(a,b) {
    a.zip(b).map(((a,b)) => a/b)
  } 
  else if (type(a) == array) {
    a.map(a => a/b)
  } 
  else {
    b.map(b => b/a)
  }
}
  
#let add(a, b) = {
  if arrarr(a,b) {
    a.zip(b).map(((a,b)) => a+b)
  }
  else if (type(a) == array) {
    a.map(a => a+b)
  }
  else {
    add(b, a)
  }
}

#let sub(a, b) = {
  if arrarr(a,b) {
    a.zip(b).map(((a,b)) => a-b)
  }
  else if (type(a) == array) {
    a.map(a => a-b)
  }
  else {
    b.map(b => a-b)
  }
}

// == vectorial functions ==

#let norm(a) = { 
  // normalize a vector
  let aux = a.sum()
  a.map(b => b/aux)
} 

// dot product
#let dot(a,b) = mult(a,b).sum()

// == trigonometry ==

#let sin(a) = {
  if (type(a) == array) {
    a.map(a => calc.sin(a))
  }
  else {
    calc.sin(a)
  }
}

#let cos(a) = {
  if (type(a) == array) {
    a.map(a => calc.cos(a))
  }
  else {
    calc.cos(a)
  }
}
