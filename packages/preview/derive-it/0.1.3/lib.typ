/*

`ded-nat` is a function that expects 2 parameters:
- `stcolor`: the stroke color of the indentation guides. Default is `black`.
- `arr`: an array with the shape, it can be provided in two shapes.
    - 4 items: (dependency: text content, indentation: integer starting from 0, formula: text content, rule: text content).
    - 3 items: the same as above, but without the dependency.

*/


// internal function that stringifies a line array (of a natural deduction table)
// this may be removed at any time
#let derive-it-internal-stringify-line(line-arr) = {
  let to-string(cntnt) = {
    if type(cntnt) != content {
      str(cntnt)
    } else if cntnt.has("text") {
      cntnt.text
    } else if cntnt.has("children") {
      cntnt.children.map(to-string).join("")
    } else if cntnt.has("body") {
      to-string(cntnt.body)
    } else if cntnt == [ ] {
      " "
    }
  }

  if type(line-arr) == str or type(line-arr) == int or type(line-arr) == float {
    str(line-arr)
  } else if type(line-arr) == array{
    line-arr.map(to-string).intersperse(", ").sum()  
  } else {
    repr(line-arr)
  }
}

// internal function to validate that each line given by the user is correct, with a descriptive error otherwise
// this may be removed at any time
#let derive-it-internal-validate-line(line, line-num, line-size: none) = {
  let line-text = "[At line: " + str(line-num+1) + "]: "
  let stringified = "'" + derive-it-internal-stringify-line(line) + "'"
  let ty = type(line)
  if ty != array {
    panic(line-text + "Line is a '" + ty + "' instead of an array of 3 or 4 elements: " + stringified)
  } else {
    // if the linesize is not the provided in the arguments or its not 3 or 4
    if (line-size != none) and (line.len() != line-size){
      panic(line-text + "Line (array) has an incorrect number of elements: " + str(line.len()) + ". It should have " + str(line-size) + ": " + stringified)
    } else if line-size == none and (line.len() != 3 and line.len() != 4) {
      panic(line-text + "Line (array) has an incorrect number of elements: " + str(line.len()) + ". It should have 3 or 4 elements: "+ stringified)
    }

    let ruleVal = line.last()
    if type(ruleVal) != str and type(ruleVal) != content {
      panic(line-text + "Line (array) should receive a 'string' or 'content' as the rule, instead it received '" + type(ruleVal) + "': " + stringified)
    }

    let indentVal = if line.len() == 3 {
      line.at(0)
    } else {
      line.at(1)
    }
    if type(indentVal) != int {
      panic( line-text + "Line (array) should receive an 'integer' as the indentation, instead it received '" + type(indentVal) + "': " + stringified)
    }
  }
}


#let ded-nat(stcolor: black,  arr: array) = context {
  let strart = ( top: 0em, right: 0em, bottom: 0em,left: 1pt + stcolor  )
  let strend = ( top: 0em, right: 0em, bottom: 1pt + stcolor, left: 1pt + stcolor )

  // check if the first line's array has 4 items (w/dependencies) or not
  let (hasDependencies, lineSize) = if arr.at(0).len() == 4 {(true, 4)} else {(false, 3)}

  let maxDepWidth = if hasDependencies {
      arr.fold(0pt, (accum, it) => {
      let sz = measure[#it.at(0)].width
      if sz > accum {sz} else {accum}  
    } )
  } else {
    0pt
  }
  
  let maxWidth = 0pt
  let tupArr = ()
  
  for (i, line) in arr.enumerate(start: 0) {
    if i == 0 {
      derive-it-internal-validate-line(line, i+1)
    }

    let (dep, indent, formula, rule) = if hasDependencies {
      line
    } else {
      ("", line.at(0), line.at(1), line.at(2))
    }


    let isLastIndented = (arr.len() > i+1) and ({
      let ix = if hasDependencies {1} else {0}
      let next-line = arr.at(i+1)
      derive-it-internal-validate-line(next-line, i+1, line-size: lineSize)
      next-line.at(ix) 
      } < indent)

    let bl = formula
    
    for i in range(0, indent){
      let inset = if i != 0 {0pt} else {0pt}

      let str = if i == 0 and isLastIndented {
        strend 
      } else{ strart  }

      if indent > 0 and i < indent - 1{
        inset = -5pt
      } 
      
      bl = [#h(1em) #box(inset: inset)[#rect(stroke: str)[#bl]]]
    }
    let index = box(width: 1.5em,)[#(i+1).]

    let tmpWidth = 0pt
    let dependency = ""
    if hasDependencies {
      dependency = text(style: "italic", weight: "regular", box(width: maxDepWidth + 1em)[#dep])
      tmpWidth = measure[#dependency #index #bl].width
    } else {
      tmpWidth = measure[#index #bl].width
    }

    if tmpWidth > maxWidth {
      maxWidth = tmpWidth
    }

    let ins = if indent == 0 {(x: 0pt, y: 0.5em)} else {(x: 0pt, y: 0pt)}
    let numInset = if indent == 0 {(x: 0pt, y: 0.0pt)} else {(x: 0pt, y: 5pt)}

    let line = ""
    if hasDependencies {
      line = box(inset: ins)[#box(inset: numInset)[#dependency #index] #bl]
    } else {
      line = box(inset: ins)[#box(inset: numInset)[#index] #bl]
    }
    
    rule = box(baseline: -0.5em , rule)
    tupArr.push((line, rule))
  }
  tupArr = tupArr.map(a => [#box(width: maxWidth + 0em, a.at(0)) #h(1em) #a.at(1)])

  text(weight: "bold",
    block(
      align(start,
        stack(dir: ttb, spacing: 0em, ..tupArr)
      )
    )
  )
}

/*

`ded-nat-boxed` is a function that expects 4 parameters, and returns the deduction in a `box`:
- `stcolor`: the stroke color of the indentation guides. Default is `black`.
- `premises-and-conclusion`: bool, whether to automatically insert or not the premises and conclusion of the derivation above the lines. Default is `true`.
- `premise-rule-text`: text content, used for finding the premises' formulas when `premises-and-conclusion` is set to `true`. Default is `"PR"`.
- `arr`: an array with the shape, it can be provided in two shapes.
    - 4 items: (dependency: text content, indentation: integer starting from 0, formula: text content, rule: text content).
    - 3 items: the same as above, but without the dependency.

*/
#let ded-nat-boxed(stcolor: black, premises-and-conclusion: true, premise-rule-text: "PR", arr: array) ={
  let premConcText = ""
  if premises-and-conclusion {
    let premises = arr.filter( x => x.last() == premise-rule-text).map(x => x.at(2))
    let conclusion = arr.last().at(2)
    let joinedPremises = [#premises.join([$, $ \ ] )]
    premConcText = [ $\ #joinedPremises \ tack #conclusion$ ]  
  }
  
  box(
    stroke: stcolor, inset: 8pt, radius: 8pt
  )[
   #align(center)[
      #if premises-and-conclusion {
        premConcText
      } #ded-nat(stcolor: stcolor, arr: arr)
    ]
  ]
}

