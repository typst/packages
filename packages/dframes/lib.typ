
#import "@preview/tabut:1.0.1" as _tabut_
#import "@preview/cetz:0.2.1" as _cetz_

#let verify-consistency(df) = {
  let n = -1
  for key in df.keys() {
    if n > 0 {
      assert(n==df.at(key).len(), message: "Columns do not have the same length")
    }
    n = df.at(key).len()
  }
}

#let row(df,i) = {
  let r = (:)
  for (key,values) in df.pairs() {
    r.insert(key,values.at(i))
  }
  r
}
// returns the number of rows of a dataframe
#let nb-rows(df) = {
  let df-keys = df.keys()
  if df-keys.len()==0 {
    return 0
  } else {
    return df.at(df-keys.first()).len()
  }
}

// returns the number of columns of a dataframe
#let nb-cols(df) = {
  df.keys().len()
}

#let size(df) = {
  (nb-rows(df), nb-cols(df))
}

#let to-array(df) = {
  if type(df)==dictionary {
    let keys = df.keys()
    let res = ()
    let n = df.at(keys.at(0)).len()
    for i in range(0,n,step: 1) {
      let elt = (:)
      for key in keys {
        elt.insert(key,df.at(key).at(i))
      }
      res.push(elt)
    }
    res
  } else if type(df)==array {
    df
  } else {
    panic("Cannot convert an object of type "+repr(type(df))+" to array.")
  }
}

#let array-to-dataframe(df) = {
  if type(df)==dictionary {
    return df
  } else if type(df)==array {
    if df.len()==0 {
      return (:)
    }
    let new_df = (:)
    for key in df.at(0).keys() {
      new_df.insert(key, df.map(r=>r.at(key)))
    }
    new_df
  } else {
    panic("Cannot convert an object of type "+repr(type(df))+" to dictionary")
  }
}

#let transpose(df, key-name:"Col") = {
  let new-df = (:)
  new-df.insert(key-name,df.keys())
  let adf = to-array(df)
  for (i,row) in adf.enumerate() {
    new-df.insert(repr(i),row.values())
  }
  new-df
}

#let slice(df, row-start:0, row-end:none, row-count:-1, 
               col-start:0, col-end:none, col-count:-1) = {
  let new_df = (:)
  let df-keys = df.keys()
  if col-count < 0 {col-count=nb-cols(df) - col-start}
  if row-count < 0 {row-count=nb-rows(df) - row-start}
  for key in df-keys.slice(col-start, col-end, count:col-count) {
    new_df.insert(key,df.at(key).slice(row-start,row-end,count:row-count))
  }
  return new_df
}

#let add-cols(df, ..kw) = {
  for (key,values) in kw.named() {
    if type(values)==array {
      df.insert(key,values)
    } else {
      df.insert(key,(values,))
    }
  }
  verify-consistency(df)
  df
}

// equivalent to add-cols
#let hcat = add-cols

#let dataframe(..kw) = {
  if kw.named().len()>0 {
    let df = (:)
    df = add-cols(df, ..kw)
    df
  } else if kw.pos().len()==1 {
    array-to-dataframe(kw.pos().at(0))
  }
}

#let add-rows(df, ..kw, missing:none) = {
  if df == none {
    df = kw.named()
    if df.len()==0 {df = kw.pos()}
    for key in df.keys() {
      if type(df.at(key)) != array {
        df.insert(key,(df.at(key),))
      }
    }
  } else {
    let df-keys = df.keys()
    if kw.named().len()==0 {
      kw=kw.pos()
    } else {
      kw = kw.named()
    }

    kw = array-to-dataframe(kw)
    // transform all elements of kw to an array if it is not
    for key in kw.keys() {
      if type(kw.at(key)) != array {
        kw.insert(key,(kw.at(key),))
      }
    }
    // add missing elements to df for keys in kw which are not in df
    let len-df = df.at(df-keys.first()).len()
    
    for key in kw.keys() {
      if key not in df-keys {
        df-keys.push(key)
        df.insert(key, (missing,) * len-df)
      }
    }
    // add missing elements to kw for keys in df which are not in kw
    let len-kw = kw.at(kw.keys().first()).len()
    for key in df-keys {
      if key not in kw.keys() {
        kw.insert(key, (missing,) * len-kw)
      }
      df.insert(key, df.at(key) + kw.at(key))
    }
  }
  verify-consistency(df)
  df
}

// equivalent to add-rows
#let vcat = add-rows

#let concat(df, other) = {
  let other-keys = other.keys()
  let df-keys = df.keys()
  
  if other-keys.filter(r=>r not in df-keys).len()==0 {
    add-rows(df, ..other)
  } else {
    
    assert(other-keys.filter(r=>r in df-keys).len()==0, message:"Cannot concat this two dataframes. Try add-rows and add-cols separately.")
    add-cols(df, ..other)
  }
}


#let j0 = datetime(year:1970,month:1,day:1, hour:0, minute:0, second:0)
#let j0d = datetime(year:1970,month:1,day:1)

#let datetime_to_julian_date(date) = {
  let f(r) = {
    if r.second()==none {
      return int((r - j0d).seconds())
    } else {
      return int((r - j0).seconds())
    }
  }
  if type(date)==array {
    return date.map(f)
  } else {
    return f(date)
  }
}

#let julian_date_to_datetime(julian_date) = {
  let f(r) = {
    if r.hour()==0 and r.minute()==0 and r.second()==0 {
      datetime(year:r.year(), month:r.month(), day:r.day())
    } else {
      r
    }
  }
  if type(julian_date)==array {
    let res = julian_date.map(r=>j0 + duration(seconds:r))
    return res.map(f)
  } else {
    return f(j0 + duration(seconds:int(julian_date)) )
  }
}

#let tabut-cells(df, ..kw) = _tabut_.tabut-cells(to-array(df), ..kw)

#let auto-type(input) = {
  if type(input)==type("") {
    let date-format = input.match(regex("(\d{4})-(\d{2})-(\d{2})[T| ](\d{2}):(\d{2}):(\d{2})"))
    if date-format != none {
      let year = int(date-format.captures.at(0))
      let month = int(date-format.captures.at(1))
      let day = int(date-format.captures.at(2))
      let hour = int(date-format.captures.at(3))
      let minute = int(date-format.captures.at(4))
      let second = int(date-format.captures.at(5))
      return datetime(year:year, month:month, day:day, hour:hour, minute:minute, second:second)
    }
    let date-format = input.match(regex("(\d{4})-(\d{2})-(\d{2})"))
    if date-format != none {
      let year = int(date-format.captures.at(0))
      let month = int(date-format.captures.at(1))
      let day = int(date-format.captures.at(2))
      return datetime(year:year, month:month, day:day)
    }
  }
  input
}

#let dataframe-from-csv(input) = {
  let data = _tabut_.records-from-csv(input)
  data = data.map( r => {
    let new-record = (:);
    for (k, v) in r.pairs() {
      new-record.insert(k, auto-type(v));
    }
    new-record
  })
  return array-to-dataframe(data)
}

#let select(df, cols:auto, rows:auto) = {
  if rows != auto and df.len()>0 {
    df = to-array(df)
    df = df.filter(rows)
    df = array-to-dataframe(df)
  }
  let new_df = (:)
  if cols==auto {
    cols = df.keys()
  } else if type(cols)==function {
    cols = df.keys().filter(cols)
  } else if type(cols)==type("") {
    cols = (cols,)
  }
  let keys = df.keys()
  for key in cols {
    if key in keys {
      new_df.insert(key, df.at(key))
    }
  }
  
  return new_df
}


// apply the func of a dataframe df with :
// - a scalar: each element of the dataframe apply the func with the scalar
// - an "other" dataframe: 
//        - if the number of columns of other is 1, each
//          columns of df apply the func term by term with other.
//        - if the number of columns of other is equal to the number 
//          of columns of df each column of df apply the func
//          term by term by each column of other.
//        - if df column names are the same asother column names, each
//          columns of df apply the func term by term by the column
//          of other with the same name.
#let apply(df, other, func:(r1,r2)=>(r1+r2)) = {
  if type(other)!=array and type(other)!=dictionary {
    for key in df.keys() {
      df.insert(key, df.at(key).map(r=>func(r,other)))
    }
  } else if type(other)==array {
    assert(other.len()==nb-rows(df), message: "Array should have the same size than dataframe")
    for key in df.keys() {
      df.insert(key, df.at(key).zip(other).map(r=>func(r.at(0),r.at(1))))
    }
  } else if type(other)==dictionary {
    let other-keys = other.keys()
    if other-keys.len() == 1 {
      other = other.at(other-keys.first())
      for key in df.keys() {
        df.insert(key, df.at(key).zip(other).map(r=>func(r.at(0),r.at(1))))
      }
    } else if other-keys.len() == df.keys().len() {
      let df-keys = df.keys()
      for i in range(0,other-keys.len()) {
        let key = df-keys.at(i)
        df.insert(key, df.at(key).zip(other.at(other-keys.at(i))).map(r=>func(r.at(0),r.at(1))))
      }
    } else {
      panic("multiply dataframe with another needs nb-cols==1 or nb-cols==dataframe nb-cols")
    }
  }
  df
}

// returns the product of a dataframe df with :
// - a scalar: each element of df is multiplied by the scalar
// - an "other" dataframe: 
//        - if the number of columns of other is 1, each
//          columns of df is multiplied term by term by other.
//        - if the number of columns of other is equal to the number 
//          of columns of df, each column of df is 
//          multipled term by term by each column of other.
//        - if df column names are the same as other column names, each
//          columns of df is multiplied term by term by the column
//          of other with the same name.
#let mult(df,other) = apply(df,other,func:(r1,r2)=>r1*r2)
#let add(df,other) = apply(df,other,func:(r1,r2)=>r1+r2)
#let div(df,other) = apply(df,other,func:(r1,r2)=>r1 / r2)
#let substract(df,other) = apply(df,other,func:(r1,r2)=>r1 - r2)


// unary operator functions: 
// the unary operator is applied to all elements of dataframe
#let apply-unary(df, func:r=>calc.abs(r)) = {
  for (key,values) in df.pairs() {
    df.insert(key, values.map(func))
  }
  df
}

#let abs(df) = {apply-unary(df)}
#let round(df, digits:0) = {apply-unary(df,func:r=>{
  if type(r)==float {
    calc.round(r, digits: digits)
  } else {
    r
  }
})}
#let ceil(df) = {apply-unary(df,func:r=>calc.ceil(r))}
#let floor(df) = {apply-unary(df,func:r=>calc.floor(r))}
#let exp(df) = {apply-unary(df,func:r=>calc.exp(r))}
#let log(df) = {apply-unary(df,func:r=>calc.log(r))}
#let cos(df) = {apply-unary(df,func:r=>calc.cos(r))}
#let sin(df) = {apply-unary(df,func:r=>calc.sin(r))}

// vector to vector functions
// given a vector, returns a vector of the same size.
// missing elements can appear.

#let vec-func(v, init:0, func:(r1,r2)=>r1+r2) = {
  let s = init
  let new-v = ()
  for i in range(0,v.len()) {
    s = func(s, v.at(i))
    new-v.push(s)
  }
  new-v
}
#let vec-cumsum(v) = vec-func(v)
#let vec-cumprod(v) = vec-func(v, func:(r1,r2)=>r1*r2, init:1)

#let cum-func(df, axis:1, func:vec-cumsum) = {
  if axis==1 {
    for (key,values) in df.pairs() {
      df.insert(key, func(values))
    }
  } else {
    let temp-df = cum-func(slice(transpose(df), col-start:1), axis:1, func:func)
    temp-df = slice(transpose(temp-df), col-start:1)
    for (key,temp-key) in df.keys().zip(temp-df.keys()) {
      df.insert(key, temp-df.at(temp-key))
    }
  }
  df
}
#let cumsum(df,axis:1) = cum-func(df,axis:axis)
#let cumprod(df,axis:1) = cum-func(df, axis:axis, func:vec-cumprod)


#let sorted(df, x, rev:false) = {
  let adf = to-array(df)
  adf = adf.sorted(key:r=>r.at(x))
  if rev {
    adf = adf.rev()
  }
  return array-to-dataframe(adf)
}


// vector to scalar functions: functions which takes a vector as input
// and returns a scalar
#let vec-sum(v) = {v.sum()}
#let vec-product(v) = {v.product()}
#let vec-min(v) = {v.fold(1e99, (r1,r2)=>calc.min(r1,r2))}
#let vec-max(v) = {v.fold(-1e99, (r1,r2)=>calc.max(r1,r2))}
#let vec-mean(v) = {v.sum()/v.len()}

// folding function: folds all items into a single value along the given
// axis using an accumulator function 
#let fold(df, axis:1, func:vec-sum) = {
  if axis==1 {
    let new-df = (:)
    for key in df.keys() {
      new-df.insert(key, func(df.at(key)))
    }
    new-df
  } else {
    let adf = to-array(df)
    adf.map(r=>func(r.values()))
  }
}

#let sum(df, axis:1) = {fold(df,axis:axis)}
#let product(df, axis:1) = {fold(df,axis:axis,func:vec-product)}
#let min(df,axis:1) = {fold(df,axis:axis,func:vec-min)}
#let max(df,axis:1) = {fold(df,axis:axis,func:vec-max)}
#let mean(df,axis:1) = {fold(df,axis:axis, func:vec-mean)}
#let diff(df, axis:1) = {
  let new-row = mult(dataframe(..row(df,0)),0)
  let df1 = concat(new-row,df)
  let df2 = concat(df, new-row)
  slice(substract(df2,df1), row-end:-1)
}

#let tbl(df, ..kw) = {
  let adf = to-array(df)
  let keys = df.keys()
  let cols = ()
  set text(weight: "bold")
  for key in keys {
    if type(df.at(key).at(0))==datetime {
      cols.push((header:align(center, [#set text(weight: "bold")
      #key.replace("_"," ")]), func:r=>align(center,r.at(key).display()) ))
    } else {
      cols.push((header:align(center, [#set text(weight: "bold")
      #key.replace("_"," ")]), func:r=>align(center,[#r.at(key)]) ))
    }
  }
  let tab = _tabut_.tabut(
    adf,
    cols,
    ..kw
  )
  return tab
}

#let curve(data:none, 
            label:"", mark:none, 
            mark-size:0.15, 
            color:blue, 
            thickness:0.5pt, 
            dash:none, 
            ..kw) = {
  _cetz_.plot.add(
    data,
    label:{set text(size:9pt);label},
    mark:mark,
    mark-size:mark-size,
    mark-style:(fill:color, stroke:black+thickness),
    style:(stroke:(dash:dash,paint:color,thickness:thickness), fill:color),
    ..kw
  )
}

#let plot(df, x:none, y:none, 
                  x-label:none, 
                  y-label:none,
                  y2-label:none, 
                  label-text-size:1em,
                  tick-text-size:0.8em,
                  x-tick-step:auto,
                  y-tick-step:auto,
                  y2-tick-step:auto,
                  x-tick-rotate:0deg,
                  x-tick-anchor:"north",
                  y-tick-rotate:0deg,
                  y-tick-anchor:"east",
                  y2-tick-rotate:0deg,
                  y2-tick-anchor:"west",
                  x-minor-tick-step:auto,
                  y-minor-tick-step:auto,
                  y2-minor-tick-step:auto,
                  x-min:none,
                  y-min:none,
                  x-max:none,
                  y-max:none,
                  x-axis-padding:2%,
                  y-axis-padding:2%,
                  axis-style:"scientific",
                  grid:false,
                  width:80%,
                  aspect-ratio:50%,
                  style:(:),
                  legend-default-position:"legend.inner-south-east",
                  legend-padding:0.15,
                  legend-spacing:0.3,
                  legend-item-spacing:0.15,
                  legend-item-preview-height:0.2,
                  legend-item-preview-width:0.6,
                  ..kw) = {
  if y==none {
    y=df.keys()
    if x!= none {
      y = y.filter(r=>r!=x)
    }
  }
  let x-datetime-format = false
  let x-string-format = false
  let orig-x = none

  if x==none or type(df.at(x).first())==type("") {
    if x!=none and type(df.at(x).first())==type("") {
      x-string-format = true
      orig-x = df.at(x)
      x-tick-step=1.0
    }
    x = range(0,df.at(df.keys().at(0)).len())
  } else {
    assert(x in df.keys(), message: "x should be in dataframe column names")
    if x-label == none {
      x-label = x.replace("_"," ")
    }
    x = df.at(x)
    if type(x.at(0))==datetime {
      x = datetime_to_julian_date(x)
      x-datetime-format = true
    }
  }
  
  let curves = ()
  let yM = -1e99
  let ym = 1e99
  let xM = -1e99
  let xm = 1e99
  let i = 0
  for key in y {
    let y_ = df.at(key)
    if type(y_.at(0))==datetime {
      y_ = datetime_to_julian_date(y_)
    }
    let data = x.zip(y_)
    let curve-style = (
            color : _cetz_.palette.rainbow(i).fill,
            thickness : 0.5pt,
            mark : none,
            mark-size : 0.15,
            dash : none,
            label:key.replace("_"," "),
            axes:("x","y")
    )
    curve-style = curve-style + style.at(key,default:(:))
    let c = curve(data:data, ..curve-style).at(0)
    if curve-style.axes.at(1)=="y" {
      let cy_data = c.data.map(r=>r.at(1))
      yM=calc.max(yM,..cy_data)
      ym=calc.min(ym,..cy_data)
    }
    if curve-style.axes.at(0)=="x" {
      let cx_data = c.data.map(r=>r.at(0))
      xM=calc.max(xM,..cx_data)
      xm=calc.min(xm,..cx_data)
    }
    curves.push(c)
    i = i+1
  }
  
  
  if x-min==none {
    x-min = xm - (xM - xm) * x-axis-padding/100%
  }
  if y-min==none {
    y-min = ym - (yM - ym) * y-axis-padding/100%
  }
  if x-max==none {
    x-max = xM + (xM - xm) * x-axis-padding/100%
  }
  if y-max==none {
    y-max = yM + (yM - ym) * y-axis-padding/100%
  }
  let x-format(r) = {

    if x-datetime-format {
      text(size:tick-text-size)[#julian_date_to_datetime(r).display()]
    } else if x-string-format {
      let i=int(r)
      if i>=0 and i < orig-x.len() {
        text(size:tick-text-size)[#orig-x.at(int(r))]
      } else {[]}
    } else {
      text(size:tick-text-size)[#r]
    }
  }
  let y-format(r) = {
    text(size:tick-text-size)[#r]
  }
  let y2-format(r) = {
    text(size:tick-text-size)[#r]
  }
  if type(x-tick-step)==duration {
    x-tick-step = x-tick-step.seconds()
  }
  if type(x-min)==datetime {
    x-min = datetime_to_julian_date(x-min)
  }
  if type(x-max)==datetime {
    x-max = datetime_to_julian_date(x-max)
  }
  
  let pl = _cetz_.plot.plot(
                        size: (10,10*aspect-ratio/100%), 
                        y-tick-step: y-tick-step,
                        y2-tick-step: y2-tick-step,
                        x-tick-step:x-tick-step,
                        x-minor-tick-step:x-minor-tick-step,
                        y-minor-tick-step:y-minor-tick-step,
                        y2-minor-tick-step:y2-minor-tick-step,
                        x-label:{set text(size:label-text-size);x-label},
                        y-label:{set text(size:label-text-size);y-label},
                        y2-label:{set text(size:label-text-size);y2-label},
                        y-max:y-max,
                        y-min:y-min,
                        x-min:x-min,
                        x-max: x-max,
                        x-grid:grid,
                        y-grid:grid,
                        x-format:x-format,
                        y-format:y-format,
                        y2-format:y2-format,
                        axis-style:axis-style,
                        legend:auto,
                        legend-style:(default-position:legend-default-position,
                                      padding:legend-padding,
                                      item:(spacing:legend-item-spacing, 
                                            preview:(height:legend-item-preview-height, 
                                                     width:legend-item-preview-width)),
                                      orientation:ttb,
                                      spacing:legend-spacing
                                    ),
                        curves,
                        ..kw
        )
  // set text(size:tick-text-size)
  
  if type(width)==ratio {
    layout(size=>{_cetz_.canvas(
      {
        _cetz_.draw.set-style(axes: (
                        bottom: (tick:(label:(angle:x-tick-rotate, anchor:x-tick-anchor))),
                        left: (tick:(label:(angle:y-tick-rotate, anchor:y-tick-anchor))),
                        right: (tick:(label:(angle:y2-tick-rotate, anchor:y2-tick-anchor)))
                        ))
        pl
        }, length:size.width/10*width, background:none)})
  } else {
    _cetz_.canvas({
      _cetz_.draw.set-style(axes: (
                bottom: (tick:(label:(angle:x-tick-rotate, anchor:x-tick-anchor))),
                left: (tick:(label:(angle:y-tick-rotate, anchor:y-tick-anchor))),
                right: (tick:(label:(angle:y2-tick-rotate, anchor:y2-tick-anchor)))
                ))
      pl
      }, length:width/10, background:none)
  }
}