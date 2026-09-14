#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3"

#let plot-integral(f_x: x => x / calc.ln(calc.abs(x)),
                  x0: 1.2,
                  x1: 6,
                  inc-0: true,
                  shade-color: rgb(100,100,255,50),
                  method:"mid",
                  n-strips:4,
                  show-points:false,
                  show-labels:true,
                  label-a: "a",
                  label-b:"b",
                  size-x:6,size-y:6
) = {
  // Mistaken plot type:
  if (not ("integral","mid","left","right","trapezium","simpsons","simpsons-38").contains(method)) {method = "integral"}
  // Fix incorrect bounds:
  if (x0 > x1) {(x0,x1) = (x1,x0)}
  else if (x0==x1){x1 = x0 + 1}
  //Create variables
  let min-x = 0
  let max-x = 0
  let min-y = 0
  let max-y = 0
  let h = (x1 - x0) / n-strips // Strip width, if used.
  if (inc-0) { //Actually calculate X-min/max
    let width = x1
    max-x = width * 1.1
    min-x = - width * 0.05 
  } else {
    let width = x1 - x0
    max-x = x1 + 0.05 * width
    min-x = x0 - 0.05 * width
  }
  //Largest found y-value
  let f-max = calc.max(..range(0,1001).map(x=>f_x(x0 + x*(x1 - x0)/1000)))
  //values for plot
  let min-y = -0.05 * f-max
  let max-y = 1.1 * f-max
  
  
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: *
    set-style(stroke:2pt)
    plot.plot(size:(size-x,size-y),x-tick-step: none,y-tick-step: none, axis-style:"school-book",
    x-min:min-x,x-max:max-x,y-min:min-y,y-max:max-y,
    {

      plot.add(domain:(min-x,max-x), f_x,style:(stroke:black))
      
      if (method=="integral") {
        plot.add(domain:(x0,x1),f_x,fill-type:"axis",fill:true,style:(fill:shade-color,stroke:3pt))
        plot.add-vline(x0,min:0,max:f_x(x0),style:(stroke:1pt+black))
        plot.add-vline(x1,min:0,max:f_x(x1),style:(stroke:1pt+black))
        if (show-points) {
            plot.add(((x0,f_x(x0)),(x0,f_x(x0))),mark:"*",mark-style:(stroke:black))
            plot.add(((x1,f_x(x1)),(x1,f_x(x1))),mark:"*",mark-style:(stroke:black))
          }
      } else if (method=="left"){
        let n = 0
        let x = x0
        while n < n-strips {
          plot.add(domain:(x,x+h),p=>f_x(x),style:(fill:shade-color,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x),style:(stroke:1pt+black))
          if (show-points) {
            plot.add(((x,f_x(x)),(x,f_x(x))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
      } else if (method=="right"){
       let n = 0
        let x = x0
        while n < n-strips {
          plot.add(domain:(x,x+h),p=>f_x(x+h),style:(fill:shade-color,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x+h),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x+h),style:(stroke:1pt+black))
          if (show-points) {
            plot.add(((x+h,f_x(x+h)),(x+h,f_x(x+h))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
      } else if (method=="mid") {
        let n = 0
        let x = x0
        while n < n-strips {
          plot.add(domain:(x,x+h),p=>f_x(x+h/2),style:(fill:shade-color,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x+h/2),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x+h/2),style:(stroke:1pt+black))
          if (show-points) {
            plot.add(((x+h/2,f_x(x+h/2)),(x+h/2,f_x(x+h/2))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
      } else if (method=="trapezium"){
        let n = 0
        let x = x0
        while n < n-strips {
          plot.add(domain:(x,x+h),n=>(n - x)*(f_x(x+h)-f_x(x))/(h)+f_x(x),style:(fill:shade-color,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x+h),style:(stroke:1pt+black))
          if (show-points) {
            plot.add(((x,f_x(x)),(x,f_x(x))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
        if (show-points) {plot.add(((x,f_x(x)),(x,f_x(x))),mark:"*",mark-style:(stroke:black))}
      } else if (method == "simpsons") {
        let h = (x1 - x0)/(2*n-strips)
        let n = 0
        let x-0 = x0
        while n < n-strips {
          let x-1 = x-0 + h
          let x-2 = x-1 + h
          let (y-0, y-1, y-2) = (f_x(x-0), f_x(x-1), f_x(x-2))
          plot.add(x=> y-0 
              + (x - x-0)*(y-1 - y-0)/h 
              + (x - x-0)*(x - x-1)*(y-2 - 2*y-1 + y-0)/(2*h*h),
            domain:(x-0,x-0+2*h),style: (stroke: 0.8pt + black))
          plot.add-fill-between(
            x=>0,
            x=> y-0 
              + (x - x-0)*(y-1 - y-0)/h 
              + (x - x-0)*(x - x-1)*(y-2 - 2*y-1 + y-0)/(2*h*h),
            domain:(x-0,x-0+2*h),
            style: (stroke: none, fill: shade-color)
          )
          plot.add-vline(x-0,min:0,max:y-0,style:(stroke:1pt+black))
          plot.add-vline(x-1,min:0,max:y-1,style:(stroke:(thickness:1pt, paint:black,dash:"dashed")))
          plot.add-vline(x-2,min:0,max:y-2,style:(stroke:1pt+black))

          if (show-points) {
            plot.add(((x-0,f_x(x-0)),(x-0,f_x(x-0))),mark:"*",mark-style:(stroke:black))
            plot.add(((x-1,f_x(x-1)),(x-1,f_x(x-1))),mark:"*",mark-style:(stroke:black))
            plot.add(((x-2,f_x(x-2)),(x-2,f_x(x-2))),mark:"*",mark-style:(stroke:black))
          }
          
          x-0 += 2*h
          n += 1
        }
        
      } else if (method == "simpsons-38") {
        let h = (x1 - x0)/(3*n-strips)
        let n = 0
        let x-0 = x0
        while n < n-strips {
          let x-1 = x-0 + h
          let x-2 = x-1 + h
          let x-3 = x-2 + h
          let (y-0, y-1, y-2, y-3) = (f_x(x-0), f_x(x-1), f_x(x-2), f_x(x-3))
          plot.add(x=> y-0 
              + (x - x-0)*(y-1 - y-0)/h 
              + (x - x-0)*(x - x-1)*(y-2 - 2*y-1 + y-0)/(2*h*h)
              + (x - x-0)*(x - x-1)*(x - x-2)*(y-3 - 3*y-2 + 3*y-1 - y-0)/(6*h*h*h),
            domain:(x-0,x-0+3*h),style: (stroke: 0.8pt + black))
          plot.add-fill-between(
            x=>0,
            x=> y-0 
              + (x - x-0)*(y-1 - y-0)/h 
              + (x - x-0)*(x - x-1)*(y-2 - 2*y-1 + y-0)/(2*h*h)
              + (x - x-0)*(x - x-1)*(x - x-2)*(y-3 - 3*y-2 + 3*y-1 - y-0)/(6*h*h*h),
            domain:(x-0,x-0+3*h),
            style: (stroke: none, fill: shade-color)
          )
          plot.add-vline(x-0,min:0,max:y-0,style:(stroke:1pt+black))
          plot.add-vline(x-1,min:0,max:y-1,style:(stroke:(thickness:1pt, paint:black,dash:"dashed")))
          plot.add-vline(x-2,min:0,max:y-2,style:(stroke:(thickness:1pt, paint:black,dash:"dashed")))
          plot.add-vline(x-3,min:0,max:y-3,style:(stroke:1pt+black))

          if (show-points) {
            plot.add(((x-0,f_x(x-0)),(x-0,f_x(x-0))),mark:"*",mark-style:(stroke:black))
            plot.add(((x-1,f_x(x-1)),(x-1,f_x(x-1))),mark:"*",mark-style:(stroke:black))
            plot.add(((x-2,f_x(x-2)),(x-2,f_x(x-2))),mark:"*",mark-style:(stroke:black))
          }
          
          x-0 += 3*h
          n += 1
        }
      }
      
      if (show-labels){
        plot.annotate({
          content((x0,2*min-y),text(font:"New Computer Modern Math",[$#label-a$]))
          content((x1,2*min-y),text(font:"New Computer Modern Math",[$#label-b$]))
        })
      }
    })
  })  
}

#let nm-integrate-midpoint(f_x:x=>x*x,
x0:0,x1:1,accuracy:12,n:1) = {
  let h = (x1 - x0) / n
  let total = 0
  for i in range(n) {
    total += h * f_x(h/2 + x0 + h * i)
  }
  return calc.round(total,digits:accuracy)
}
#let nm-integrate-trapezium(f_x:x=>x*x,
x0:0,x1:1,accuracy:12,n:1) = {
  let h = (x1 - x0) / n
  let total = 0.5 * (f_x(x0)+f_x(x1))
  let strip = 1
  while strip < n {
    total += f_x(x0 + strip * h)
    strip += 1
  }
  return calc.round(h*total,digits:accuracy)
}
#let nm-integrate-simpsons(f_x:x=>x*x,
x0:0,x1:1,accuracy:12,n:1) = {
  let T_n = nm-integrate-trapezium(f_x:f_x,x0:x0,x1:x1,accuracy:accuracy+5,n:n)
  let T_2n = nm-integrate-trapezium(f_x:f_x,x0:x0,x1:x1,accuracy:accuracy+5,n:2*n)

  let total = (4 * T_2n - T_n) / 3
  
  return calc.round(total,digits:accuracy)
}

#let nm-integrate-simpsons-38(f_x:x=>x*x,
x0:0,x1:1,accuracy:12,n:1) = {
  let i-max = 3 * n
  //Simpsons for S_3n
  //3h/8 [ f(x0) + 3f(x1) + 3f(x2) + 2f(x3) + ... + f(x_n-max)]
  //For i = 1 to i = n
  let h = (x1 - x0) / i-max
  let x_i = range(0,i-max).map(i => x0 + h*i)
  let total = f_x(x_i.at(0)) + f_x(x_i.last())
  let strip = 1
  while strip < i-max {
    let val = f_x(x_i.at(strip))
    if calc.rem(strip, 3) == 0 {
      total += 2 * val
    } else {
      total += 3 * val
    }
    strip += 1
  }
  total *= h * 3 / 8
  return calc.round(total,digits:accuracy)
}

#let nm-differentiate-forward(f_x:x=>x*x,x0:1,h:1,accuracy:12) = {
  let d = (f_x(x0+h) - f_x(x0)) / h
  return calc.round(d,digits:accuracy)
}
#let nm-differentiate-central(f_x:x=>x*x,x0:1,h:1,accuracy:12) = {
  let d = (f_x(x0 + h/2) - f_x(x0 - h/2)) / h
  return calc.round(d,digits:accuracy)
}



#let nm-iterate-relaxed-FPI(g_x:calc.cos,x0:1,lambda:0.5,n-max:5,accuracy:12,return-all:false) = {
  let n = 0

  if not return-all {
    let x = x0
    while n < n-max {
      x = lambda * g_x(x) + (1 - lambda) * x
      n += 1
    }
    return calc.round(x,digits:accuracy)
  }
  
  let x = ()
  x.push(x0)
  while n < n-max {
    x.push(lambda * g_x(x.last()) + (1 - lambda)*x.last())
    n += 1
  }
  return x.map(n=>calc.round(n,digits:accuracy))
  
}
#let nm-iterate-FPI(g_x:calc.cos,x0:1,n-max:5,accuracy:12,return-all:false) = {
  let result = nm-iterate-relaxed-FPI(g_x:g_x,x0:x0,n-max:n-max,lambda:1,accuracy:accuracy,return-all:return-all)
  return result
}
#let nm-iterate-newton-raphson(f_x:calc.cos,x0:1,n-max:5,accuracy:12,return-all:false) = {
  let n = 0

  if not return-all {
    let x = x0
    while n < n-max {
      x = x - (f_x(x)) / (nm-differentiate-central(f_x:f_x,
                                            x0:x,
                                            h:0.0000001,
                                            accuracy:15))
      n += 1
    }
    return calc.round(x,digits:accuracy)
  }
  let x = ()
  x.push(x0)
  while n < n-max {
    let xn = x.last()
    x.push(xn - (f_x(xn)) / (nm-differentiate-central(f_x:f_x,
                                            x0:xn,
                                            h:0.0000000001,
                                            accuracy:15)))
    n += 1
  }
  return x.map(n=>calc.round(n,digits:accuracy))
}

#let nm-iterate-secant(f_x:calc.sin,x0:1,x1:0.5,n-max: 5,accuracy:5,return-all:false) = {
  let n = 0
  if not return-all {
    let (a,b) = (x0,x1)
    while n < n-max {
      let next = (a * f_x(b) - b * f_x(a))/(f_x(b) - f_x(a))
      a = b
      b = next
      n += 1
    }
    return calc.round(b,digits:accuracy)
  }
  let xn = ()
  xn.push(x0)
  xn.push(x1)
  while xn.len() < n-max {
    let (a,b) = (xn.at(xn.len()-2),xn.last())
    if (f_x(b) - f_x(a))==0 {
      xn.push(0)
    } else {
    let next = (a * f_x(b) - b * f_x(a))/(f_x(b) - f_x(a))
    xn.push(next)
    }
  }
  return xn.map(n=>calc.round(n,digits:accuracy))
}

#let nm-iterate-false-position(f_x:calc.sin,x0:1,x1:0.5,n-max: 5,accuracy:5,return-all:false) = {
  if f_x(x0) * f_x(x1) > 0 {panic("Error, no change of sign.")}
  let n = 0
  if not return-all {
    let (a,b) = (x0,x1)
    while n < n-max {
      let next = (a * f_x(b) - b * f_x(a))/(f_x(b) - f_x(a))
      if f_x(a)*f_x(next) > 0 { //Same sign, so replace b
        b = next
      } else {a = next}
      n += 1
    }
    return (calc.round(a, digits: accuracy), 
            calc.round(b, digits: accuracy))
  }

  let xn = ()
  xn.push((x0,x1))
  while xn.len() < n-max {
    let (a,b) = xn.last()
    let next = (a * f_x(b) - b * f_x(a))/(f_x(b) - f_x(a))
    if f_x(a)*f_x(next) > 0 { //Same sign, so replace b
        xn.push((a,next))
      } else {xn.push((next,b))}
    n += 1
  }
  return xn.map(n=>(calc.round(n.at(0), digits: accuracy),
                        calc.round(n.at(1), digits: accuracy)))
}
#let nm-iterate-bisection(f_x:calc.sin,x0:1,x1:0.5,n-max: 5,accuracy:5,return-all:false) = {
  if f_x(x0) * f_x(x1) > 0 {panic("Error, no change of sign.")}
  let n = 0
  if not return-all {
    let (a,b) = (x0,x1)
    while n < n-max {
      let next = (a+b)/2
      if (f_x(next)==0) {
      xn.push((a,next))
      break
    }
      if f_x(a)*f_x(next) > 0 { //Same sign, so replace b
        b = next
      } else {a = next}
      n += 1
    }
    return (calc.round(a, digits: accuracy), 
            calc.round(b, digits: accuracy))
  }

  let xn = ()
  xn.push((x0,x1))
  while xn.len() < n-max {
    let (a,b) = xn.last()
    let next = (a+b)/2
    if (f_x(next)==0) {
      xn.push((a,next))
      break
    }
    if f_x(a)*f_x(next) > 0 { //Same sign, so replace b
        xn.push((a,next))
      } else {xn.push((next,b))}
    n += 1
  }
  return xn.map(n=>(calc.round(n.at(0), digits: accuracy),
                        calc.round(n.at(1), digits: accuracy)))
}

#let nm-table-integrate(f_x:calc.sin,x0:1,x1:2,start-strips:1,strip-ratio:2,method:"Midpoint", n-rows:5,show-diffs:true,show-ratio:true,accuracy:5) = {
  //method must be from the array. If not, do mid.
  if not ("Midpoint","Trapezium","Simpsons","Simpsons-38").contains(method) {
    method = "Midpoint"
  }
  let strip-array = ()
  strip-array.push(start-strips)
  while strip-array.len() < n-rows {
    strip-array.push(strip-array.last() * strip-ratio)
  }

  let integrals = ()
  let header = $M_n$
  if method == "Midpoint" {
    integrals = strip-array.map(n=>nm-integrate-midpoint(f_x:f_x,x0:x0,x1:x1,n:n,accuracy:accuracy))
  } else if method=="Trapezium" {
    integrals = strip-array.map(n=>nm-integrate-trapezium(f_x:f_x,x0:x0,x1:x1,n:n,accuracy:accuracy))
    header = $T_n$
  } else if method == "Simpsons" {
    integrals = strip-array.map(n=>nm-integrate-simpsons(f_x:f_x,x0:x0,x1:x1,n:n,accuracy:accuracy))
    header = $S_(2n)$
  } else {
    integrals = strip-array.map(n=>nm-integrate-simpsons-38(f_x:f_x,x0:x0,x1:x1,n:n,accuracy:accuracy))
    header = $S_(3n)$
  }
  let diffs = ()
  diffs.push([])
  for i in range(integrals.len()-1) {
    diffs.push(calc.round(integrals.at(i+1) - integrals.at(i),digits:accuracy))
  }
  let ratios = ([],[])
  for i in range(diffs.len()-2) {
    ratios.push(calc.round(diffs.at(i+2) / diffs.at(i+1),digits:accuracy))
  }

  let table-rows = () 
  for i in range(strip-array.len()) {
    table-rows.push([#strip-array.at(i)])
    table-rows.push([#integrals.at(i)])
    if show-diffs {
      table-rows.push([#diffs.at(i)])
      if show-ratio {table-rows.push([#ratios.at(i)])}
    }
  }
  let headers = ($n$,[#header])
  if show-diffs {
    headers.push([Difference])
    if show-ratio {headers.push([Ratio])}
  }
  return table(columns:headers.len(),
              table.header(..headers),
              ..table-rows)
}

#let nm-table-differentiate(f_x:x=>calc.ln(x),x0:2,start-h:1,h-ratio:2,n-rows:5,accuracy:5,method:"CD",show-diffs:true,show-ratio:true) = {
  //Default to Central Difference if bad name
  if not ("CD","FD").contains(method) {
    method = "CD"
  }

  let differentials = ()

  let h-array = ()
  h-array.push(start-h)
  while h-array.len() < n-rows {
    h-array.push(calc.round(h-array.last() / h-ratio,digits:8)) 
    //Rounds due to floating point division
  }
  
  let differentials = h-array.map(h=>nm-differentiate-central(f_x:f_x,x0:x0,h:h,accuracy:accuracy))
  if method == "FD" {
    differentials = h-array.map(h=>nm-differentiate-forward(f_x:f_x,x0:x0,h:h,accuracy:accuracy))
  }

  let diffs = ()
  diffs.push([])
  for i in range(differentials.len()-1) {
    diffs.push(calc.round(differentials.at(i+1) - differentials.at(i),digits:accuracy))
  }
  let ratios = ([],[])
  for i in range(diffs.len()-2) {
    ratios.push(calc.round(diffs.at(i+2) / diffs.at(i+1),digits:accuracy))
  }

  let table-rows = () 
  for i in range(h-array.len()) {
    table-rows.push([#h-array.at(i)])
    table-rows.push([#differentials.at(i)])
    if show-diffs {
      table-rows.push([#diffs.at(i)])
      if show-ratio {table-rows.push([#ratios.at(i)])}
    }
  }
  let headers = ($h$,$f'(x)$)
  if show-diffs {
    headers.push([Difference])
    if show-ratio {headers.push([Ratio])}
  }
  return table(columns:headers.len(),
              table.header(..headers),
              ..table-rows)
  
}

#let nm-table-iterate(f_x:calc.sin,x0:1,x1:0.5,lambda:0.5,n-rows: 5,accuracy:5,ratio-order:2,method:"FPI",show-diffs:true,show-ratio:true) = {
  //Default to NRaphson
  if not ("FPI","RFPI","Secant","Newton-Raphson").contains(method) {
    method = "Newton-Raphson"
  }

  let n-array = range(n-rows).map(n=>n+1) //Start at 1.

  let headers = ($n$,$x_n$)
  if show-diffs {
    headers.push([Difference])
    if show-ratio {
      headers.push([Ratio])
    }
  }
  let x-array = ()
  if method=="FPI" {
    x-array = nm-iterate-FPI(g_x:f_x,x0:x0,n-max:n-rows,return-all:true,accuracy:accuracy)
  } else if method=="RFPI" {
    x-array = nm-iterate-relaxed-FPI(g_x:f_x,x0:x0,n-max:n-rows,return-all:true,accuracy:accuracy,lambda:lambda)
  }else if method == "Secant" {
    x-array = nm-iterate-secant(f_x:f_x,x0:x0,x1:x1,n-max:n-rows,return-all:true,accuracy:accuracy)
  } else {
    x-array = nm-iterate-newton-raphson(f_x:f_x,x0:x0,n-max:n-rows,return-all:true,accuracy:accuracy)
  }
  let diffs = ()
  diffs.push([])
  for i in range(x-array.len()-1) {
    diffs.push(calc.round(x-array.at(i+1) - x-array.at(i),digits:accuracy))
  }
  let ratios = ([],[])
  for i in range(diffs.len()-2) {
    ratios.push(calc.round(calc.abs(diffs.at(i+2)) / calc.pow(calc.abs(diffs.at(i+1)),ratio-order),digits:accuracy))
  }
  
  let table-rows = ()
  for i in range(n-array.len()) {
    table-rows.push([#n-array.at(i)])
    table-rows.push([#x-array.at(i)])
    if show-diffs {
      table-rows.push([#diffs.at(i)])
      if show-ratio {table-rows.push([#ratios.at(i)])}
    }
  }

  return table(columns:headers.len(),
              table.header(..headers),
              ..table-rows)
}