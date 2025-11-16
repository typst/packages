#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3"

#let PlotIntegral(f_x: x => x * x, start-x: 0.2, end-x: 6, inc_x0: true, shadeColor: rgb(100,100,255,50), method:"mid", n-strips:5, includePoints:false, showLabels:true, labelA: "a", labelB:"b", size_x:6,size_y:6) = {
  // Mistaken plot type:
  if (not ("integral","mid","left","right","trapezium").contains(method)) {method = "integral"}
  // Fix incorrect bounds:
  if (start-x > end-x) {(start-x,end-x) = (end-x,start-x)}
  else if (start-x==end-x){end-x = start-x + 1}
  //Create variables
  let min_x = 0
  let max_x = 0
  let min_y = 0
  let max_y = 0
  let h = (end-x - start-x) / n-strips // Strip width, if used.
  if (inc_x0) { //Actually calculate X-min/max
    let width = end-x
    max_x = width * 1.1
    min_x = - width * 0.05 
  } else {
    let width = end-x - start-x
    max_x = end-x + 0.05 * width
    min_x = start-x - 0.05 * width
  }
  //Largest found y-value
  let maxY = calc.max(..range(0,1001).map(x=>f_x(start-x + x*(end-x - start-x)/1000)))
  //values for plot
  let min_y = -0.05 * maxY
  let max_y = 1.1 * maxY
  
  
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: *
    set-style(stroke:2pt)
    plot.plot(size:(size_x,size_y),x-tick-step: none,y-tick-step: none, axis-style:"school-book",
    x-min:min_x,x-max:max_x,y-min:min_y,y-max:max_y,
    {

      plot.add(domain:(min_x,max_x), f_x,style:(stroke:black))
      
      if (method=="integral") {
        plot.add(domain:(start-x,end-x),f_x,fill-type:"axis",fill:true,style:(fill:shadeColor,stroke:3pt))
        plot.add-vline(start-x,min:0,max:f_x(start-x),style:(stroke:1pt+black))
        plot.add-vline(end-x,min:0,max:f_x(end-x),style:(stroke:1pt+black))
        if (includePoints) {
            plot.add(((start-x,f_x(start-x)),(start-x,f_x(start-x))),mark:"*",mark-style:(stroke:black))
            plot.add(((end-x,f_x(end-x)),(end-x,f_x(end-x))),mark:"*",mark-style:(stroke:black))
          }
      } else if (method=="left"){
        let n = 0
        let x = start-x
        while n < n-strips {
          plot.add(domain:(x,x+h),p=>f_x(x),style:(fill:shadeColor,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x),style:(stroke:1pt+black))
          if (includePoints) {
            plot.add(((x,f_x(x)),(x,f_x(x))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
      } else if (method=="right"){
       let n = 0
        let x = start-x
        while n < n-strips {
          plot.add(domain:(x,x+h),p=>f_x(x+h),style:(fill:shadeColor,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x+h),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x+h),style:(stroke:1pt+black))
          if (includePoints) {
            plot.add(((x+h,f_x(x+h)),(x+h,f_x(x+h))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
      } else if (method=="mid") {
        let n = 0
        let x = start-x
        while n < n-strips {
          plot.add(domain:(x,x+h),p=>f_x(x+h/2),style:(fill:shadeColor,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x+h/2),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x+h/2),style:(stroke:1pt+black))
          if (includePoints) {
            plot.add(((x+h/2,f_x(x+h/2)),(x+h/2,f_x(x+h/2))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
      } else if (method=="trapezium"){
        let n = 0
        let x = start-x
        while n < n-strips {
          plot.add(domain:(x,x+h),n=>(n - x)*(f_x(x+h)-f_x(x))/(h)+f_x(x),style:(fill:shadeColor,stroke:1pt+black),fill:true)
          plot.add-vline(x,min:0,max:f_x(x),style:(stroke:1pt+black))
          plot.add-vline(x+h,min:0,max:f_x(x+h),style:(stroke:1pt+black))
          if (includePoints) {
            plot.add(((x,f_x(x)),(x,f_x(x))),mark:"*",mark-style:(stroke:black))
          }
          x += h
          n += 1
        }
        if (includePoints) {plot.add(((x,f_x(x)),(x,f_x(x))),mark:"*",mark-style:(stroke:black))}
      }
      if (showLabels){
        plot.annotate({
          content((start-x,2*min_y),text(font:"New Computer Modern Math",labelA))
          content((end-x,2*min_y),text(font:"New Computer Modern Math",labelB))
        })
      }
    })
  })  
}

#let NM-Integrate-Midpoint(f_x:x=>x*x,
start-x:0,end-x:1,accuracy:12,n:1) = {
  let h = (end-x - start-x) / n
  let total = 0
  for i in range(n) {
    total += h * f_x(h/2 + start-x + h * i)
  }
  return calc.round(total,digits:accuracy)
}
#let NM-Integrate-Trapezium(f_x:x=>x*x,
start-x:0,end-x:1,accuracy:12,n:1) = {
  let h = (end-x - start-x) / n
  let total = 0.5 * (f_x(start-x)+f_x(end-x))
  let strip = 1
  while strip < n {
    total += f_x(start-x + strip * h)
    strip += 1
  }
  return calc.round(h*total,digits:accuracy)
}
#let NM-Integrate-Simpsons(f_x:x=>x*x,
start-x:0,end-x:1,accuracy:12,n:1) = {
  let T_n = NM-Integrate-Trapezium(f_x:f_x,start-x:start-x,end-x:end-x,accuracy:accuracy+5,n:n)
  let T_2n = NM-Integrate-Trapezium(f_x:f_x,start-x:start-x,end-x:end-x,accuracy:accuracy+5,n:2*n)

  let total = (4 * T_2n - T_n) / 3
  
  return calc.round(total,digits:accuracy)
}

#let NM-Differentiate-Forward(f_x:x=>x*x,x0:1,h:1,accuracy:12) = {
  let d = (f_x(x0+h) - f_x(x0)) / h
  return calc.round(d,digits:accuracy)
}
#let NM-Differentiate-Central(f_x:x=>x*x,x0:1,h:1,accuracy:12) = {
  let d = (f_x(x0 + h/2) - f_x(x0 - h/2)) / h
  return calc.round(d,digits:accuracy)
}



#let NM-Iterate-RelaxedFPI(g_x:calc.cos,x0:1,lambda:0.5,nMax:5,accuracy:12,return-all:false) = {
  let n = 0

  if not return-all {
    let x = x0
    while n < nMax {
      x = lambda * g_x(x) + (1 - lambda) * x
      n += 1
    }
    return calc.round(x,digits:accuracy)
  }
  
  let x = ()
  x.push(x0)
  while n < nMax {
    x.push(lambda * g_x(x.last()) + (1 - lambda)*x.last())
    n += 1
  }
  return x.map(n=>calc.round(n,digits:accuracy))
  
}
#let NM-Iterate-FPI(g_x:calc.cos,x0:1,nMax:5,accuracy:12,return-all:false) = {
  let result = NM-Iterate-RelaxedFPI(g_x:g_x,x0:x0,nMax:nMax,lambda:1,accuracy:accuracy,return-all:return-all)
  return result
}
#let NM-Iterate-NRaphson(f_x:calc.cos,x0:1,nMax:5,accuracy:12,return-all:false) = {
  let n = 0

  if not return-all {
    let x = x0
    while n < nMax {
      x = x - (f_x(x)) / (NM-Differentiate-Central(f_x:f_x,
                                            x0:x,
                                            h:0.0000001,
                                            accuracy:15))
      n += 1
    }
    return calc.round(x,digits:accuracy)
  }
  let x = ()
  x.push(x0)
  while n < nMax {
    let xn = x.last()
    x.push(xn - (f_x(xn)) / (NM-Differentiate-Central(f_x:f_x,
                                            x0:xn,
                                            h:0.0000000001,
                                            accuracy:15)))
    n += 1
  }
  return x.map(n=>calc.round(n,digits:accuracy))
}

#let NM-Iterate-Secant(f_x:calc.sin,x0:1,x1:0.5,nRows: 5,accuracy:5,return-all:false) = {
  let n = 0
  if not return-all {
    let (a,b) = (x0,x1)
    while n < nSteps {
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
  while xn.len() < nRows {
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

#let NM-Iterate-FalsePosition(f_x:calc.sin,x0:1,x1:0.5,nSteps: 5,accuracy:5,return-all:false) = {
  if f_x(x0) * f_x(x1) > 0 {return [Error, no change of sign.]}
  let n = 0
  if not return-all {
    let (a,b) = (x0,x1)
    while n < nSteps {
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
  while xn.len() < nSteps {
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
#let NM-Iterate-Bisection(f_x:calc.sin,x0:1,x1:0.5,nSteps: 5,accuracy:5,return-all:false) = {
  if f_x(x0) * f_x(x1) > 0 {return [Error, no change of sign.]}
  let n = 0
  if not return-all {
    let (a,b) = (x0,x1)
    while n < nSteps {
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
  while xn.len() < nSteps {
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

#let NM-Table-Integrate(f_x:calc.sin,start-x:1,end-x:2,start-strips:1,strip-ratio:2,method:"Midpoint", n-rows:5,show-diffs:true,show-ratio:true,accuracy:5) = {
  //method must be from the array. If not, do mid.
  if not ("Midpoint","Trapezium","Simpsons").contains(method) {
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
    integrals = strip-array.map(n=>NM-Integrate-Midpoint(f_x:f_x,start-x:start-x,end-x:end-x,n:n,accuracy:accuracy))
  } else if method=="Trapezium" {
    integrals = strip-array.map(n=>NM-Integrate-Trapezium(f_x:f_x,start-x:start-x,end-x:end-x,n:n,accuracy:accuracy))
    header = $T_n$
  } else {
    integrals = strip-array.map(n=>NM-Integrate-Simpsons(f_x:f_x,start-x:start-x,end-x:end-x,n:n,accuracy:accuracy))
    header = $S_(2n)$
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

  let tableRows = () 
  for i in range(strip-array.len()) {
    tableRows.push([#strip-array.at(i)])
    tableRows.push([#integrals.at(i)])
    if show-diffs {
      tableRows.push([#diffs.at(i)])
      if show-ratio {tableRows.push([#ratios.at(i)])}
    }
  }
  let headers = ($n$,[#header])
  if show-diffs {
    headers.push([Difference])
    if show-ratio {headers.push([Ratio])}
  }
  return table(columns:headers.len(),
              table.header(..headers),
              ..tableRows)
}

#let NM-Table-Differentiate(f_x:x=>calc.ln(x),x0:2,start-h:1,h-ratio:2,n-rows:5,accuracy:5,method:"CD",show-diffs:true,show-ratio:true) = {
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
  
  let differentials = h-array.map(h=>NM-Differentiate-Central(f_x:f_x,x0:x0,h:h,accuracy:accuracy))
  if method == "FD" {
    differentials = h-array.map(h=>NM-Differentiate-Forward(f_x:f_x,x0:x0,h:h,accuracy:accuracy))
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

  let tableRows = () 
  for i in range(h-array.len()) {
    tableRows.push([#h-array.at(i)])
    tableRows.push([#differentials.at(i)])
    if show-diffs {
      tableRows.push([#diffs.at(i)])
      if show-ratio {tableRows.push([#ratios.at(i)])}
    }
  }
  let headers = ($h$,$f'(x)$)
  if show-diffs {
    headers.push([Difference])
    if show-ratio {headers.push([Ratio])}
  }
  return table(columns:headers.len(),
              table.header(..headers),
              ..tableRows)
  
}

#let NM-Table-Iterate(f_x:calc.sin,x0:1,x1:0.5,lambda:0.5,n-rows: 5,accuracy:5,ratio-order:2,method:"FPI",show-diffs:true,show-ratio:true) = {
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
    x-array = NM-Iterate-FPI(g_x:f_x,x0:x0,nMax:n-rows,return-all:true,accuracy:accuracy)
  } else if method=="RFPI" {
    x-array = NM-Iterate-RelaxedFPI(g_x:f_x,x0:x0,nMax:n-rows,return-all:true,accuracy:accuracy,lambda:lambda)
  }else if method == "Secant" {
    x-array = NM-Iterate-Secant(f_x:f_x,x0:x0,x1:x1,nRows:n-rows,return-all:true,accuracy:accuracy)
  } else {
    x-array = NM-Iterate-NRaphson(f_x:f_x,x0:x0,nMax:n-rows,return-all:true,accuracy:accuracy)
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
  
  let tableRows = ()
  for i in range(n-array.len()) {
    tableRows.push([#n-array.at(i)])
    tableRows.push([#x-array.at(i)])
    if show-diffs {
      tableRows.push([#diffs.at(i)])
      if show-ratio {tableRows.push([#ratios.at(i)])}
    }
  }

  return table(columns:headers.len(),
              table.header(..headers),
              ..tableRows)

  
}