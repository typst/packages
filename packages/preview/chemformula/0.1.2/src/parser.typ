
#let peek(arr: (), i) = {
  if i >= arr.len() or i < 0 {
    return (type: "None", expr: "@")
  } else {
    arr.at(i)
  }
}
/// Parsing a string using regex rules.
/// The rules determine which is going to be the match, arranging from index and strength of the pattern.
/// Stronger patterns can override the weaker pattern.
#let _parse(arr, rules: ()) = {
  if arr.all(it => type(it) != str) {
    return arr
  } else {
    arr
      .map(case => {
        if type(case) == str {
          let curr = case

          let index = 0
          let results = ()

          // Main Loop
          while curr.len() > 0 {
            let matches = rules.map(r => {
              let (type, rule, strength) = r
              if curr.match(rule) == none { return none } else {
                (type: type, match: curr.match(rule), strength: strength)
              }
            })
            // Arrange from strength, and if same strength is met, arrange from the starting index
            let success = matches.filter(i => i != none).sorted(key: info => (-info.strength, info.match.start))

            if success != () {
              let (type, match) = success.at(0)
              if index <= match.start {
                if index < match.start {
                  results.push(curr.slice(index, match.start))
                }
                results.push((type: type, expr: match.text))
                index = match.end
              }
            }
            curr = curr.slice(index, none)
            index = 0
          }
          _parse(results, rules: rules).flatten()
        } else {
          case
        }
      })
      .flatten()
  }
}

#let EOT = "@"

#let mpp = "\([^)(]*(?:\([^)(]*(?:\([^)(]*(?:\([^)(]*\)[^)(]*)*\)[^)(]*)*\)[^)(]*)*\)" // matching parenthesis patterns

#let parsing-chem(chem) = {
  let rules = (
    ("Above", regex("\^\^[^\s\;\@\_]+|\^\^[^\s\;\@]*[\s\;\@]"), 2),
    ("Below", regex("\_\_[^\s\;\@]+|\_\_[^\;\s\@]*[\s\;\@]|\_\_\([^\)]\)"), 2),
    ("Superscript", regex("\^[^\s\;\@\_]+|\^[^\s\;\@]*[\s\;\@]|\^\([^\)]\)"), 2),
    ("Subscript", regex("\_[^\s\;\@\^]+|\_[^\;\s\@]*[\s\;\@]|\_\([^\)]\)"), 2),
    ("Nucleus", regex("[A-Za-z]+|\[[^\]\\\]*\]+|" + mpp + "|\{[^\}\\\]*\}"), 1),
    ("Digits", regex("\d+"), 1),
    ("Charges", regex("[\-\+]{1}"), 1),
    // ("Signs", regex("\s*[=~][\s\@\;]+"), 2),
    ("Parens", regex("[\\\\(\)\[\]\{\}]+"), 1),
    ("SingleBond", regex("--"), 2),
    ("DoubleBond", regex("=="), 2),
    ("TripleBond", regex("~~"), 2),
    ("None", regex(".*"), 0),
  )

  _parse((chem,), rules: rules)
}

#let parse-arrow(txt) = {
  let rules = (
    ("<=>", regex("<=>")),
    ("<->", regex("<->")),
    ("<-", regex("<-")),
    ("->", regex("->")),
    ("<=", regex("<=")),
    ("=>", regex("=>")),
    ("Args", regex("\[[^\]]*\]")),
  ).map(r => r + (1,))

  _parse((txt,), rules: rules)
}

#let position-chem(chem, mode: "Inline") = {
  let tokens = parsing-chem(chem)
  let results = ()
  let peek = peek.with(arr: tokens)

  for (i, toks) in tokens.enumerate() {
    let (type, expr) = toks
    let out = if type == "Digits" {
      if peek(i - 1).type == "None" {
        if peek(i + 1).type == "None" {
          if peek(i + 2).type != "None" {
            (type: "Digits", expr: expr)
          } else {
            (type: "Digits", expr: expr)
          }
        } else {
          (type: "Digits", expr: expr)
        }
      } else {
        if peek(i - 1).type == "Nucleus" or peek(i - 1).type == "Parens" {
          (type: "Subscript", expr: expr)
        } else {
          (type: "Digits", expr: expr)
        }
      }
    } else if type == "Charges" {
      expr = expr.replace("-", sym.minus).replace(regex("\*|\."), sym.bullet)
      if peek(i - 1).type == "None" or mode == "Scripts" {
        (type: "Elem", expr: expr)
      } else {
        (type: "Superscript", expr: expr)
      }
    } else if type == "Nucleus" {
      (type: "Elem", expr: expr)
    } else {
      toks
    }
    results.push(out)
  }
  results
}



#let parsing-reaction(chem, mode: "Inline") = {
  let rules = (
    ("Arrow", regex("(<=>|<->|<-|->)(\[[^\]]*\]){0,2}"), 3),
    ("Math", regex("\$[^\$]*\$"), 3),
    ("Text", regex("\"[^\"]*\""), 3),
    ("Precipitation", regex("\s+v[\s\@\;]+"), 2),
    ("Gaseous", regex("\s\^[\s\@\;]+"), 3),
    ("Above", regex("\^\^" + mpp + "|\^\^[^\s\;\@\_\(\)]+|\^\^[^\s\;\@]*[\s\;\@]"), 3),
    ("Below", regex("\_\_" + mpp + "|\_\_[^\s\;\@\^\(\)]+|\_\_[^\;\s\@]*[\s\;\@]"), 3),
    ("Superscript", regex("\^" + mpp + "|\^[^\s\;\@\_\(\)]+|\^[^\s\;\@]*[\s\;\@]"), 3),
    ("Subscript", regex("\_" + mpp + "|\_[^\s\;\@\^\(\)]+|\_[^\;\s\@]*[\s\;\@]"), 3),
    ("Symbol", regex("\ [^A-Za-z\d\_\^]+[\s\@\;]"), 1),
    ("Space", regex("\s+"), 2),
    ("Elem", regex("" + mpp + "\d*|\S+"), 1),
    ("None", regex(".*"), 0),
  )
  //chem = split-parens(chem).join(";")
  _parse((chem,), rules: rules)
    .map(it => {
      if it.type == "Elem" {
        position-chem(it.expr, mode: mode)
      } else {
        it
      }
    })
    .flatten()
}
