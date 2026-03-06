// Define the #[] behavior using intextual's flushr
#import "@preview/intextual:0.1.1": flushr, intertext-rule
#let tag(x) = [#flushr[(#x)]]

/* align_raw takes in cont of type raw and lang of string and */
#let polly-style-raw(cont, lang: none) = {
  // without this the code is small for some reason
  set text(1em / 0.8)


  if (lang == none) {
    lang = cont.lang
  }
  
  let base_text = cont.text

  // If you want to add a new symbol add it here
  // Keep in mind you want to avoid anything that would
  // naturally show up in SML (or the lang u are using)
  let symdict = (
    "==>" : $==>$,
    "<==" : $<==$,
    "~=" : $tilde.equiv$,
    "==" : $=$,
    "!~=" : $tilde.equiv.not$,
    "!==" : $!=$,
    "&" : $&$ // controls aligning
  )
  // (i would add !==> and !<== but i can't seem to
  // find those symbols for some reason?)

  // and here
  let pattern = regex("==>|<==|~=|==|\\!~=|\\!==|&|\\\\(.|\n)|#\[([^\]]*)\]|#\$([^\$]*)\$")

  let text = base_text.replace(regex("\s+"), " ")

  let sugar = text.matches(pattern)
  let cont_new = text.split(pattern).map(it => it.trim())

  let proc_sugar = it => {
    // deal with default symbols
    let rep = symdict.at(it, default: false)
    if rep != false {
      return rep
    }

    // deal with symbols with custom behavior
    if it.match(regex("\\\\\s")) != none {
      return $ \ $
    }

    let final_match = it.match(regex("\\\(\S)"))
    if final_match != none {
      return raw(final_match.captures.at(0), lang: lang, block: false)
    }

    let tag_match = it.match(regex("#\[([^\]]*)\]"))
    if tag_match != none {
      return $#tag(eval(tag_match.captures.at(0), mode:"markup"))$
    }

    let math_match = it.match(regex("#\$([^\$]*)\$"))
    if math_match != none {
      return eval(math_match.captures.at(0), mode:"math", scope: dictionary(sym) + ("sym" : dictionary(sym)) + ("flushr": flushr))
    }

    /* if somehow we match but don't match any individual 
    cases, just return the raw cases */
    return it
  }

  let output_base = raw(cont_new.at(0), lang: lang, block: false, )

  let output_lst = ()
  output_lst.push(output_base)

  // loop through the tokens as split by the "sugar" syntax characters
  for i in range(0, sugar.len()) {
    output_lst.push((proc_sugar(sugar.at(i).text)))
    if (cont_new.at(i + 1) != "") {
      output_lst.push(raw(cont_new.at(i + 1), lang: lang, block: false))
    }
  }

  let output = output_lst.remove(0)

  for i in output_lst {
    output += i
  }

  // overall this is just a math block
  show: intertext-rule
  $ output $
}

#let polly-style-rule = it => {
  show raw.where(lang: "polly") : it => polly-style-raw(it, lang: "sml")
  it
}