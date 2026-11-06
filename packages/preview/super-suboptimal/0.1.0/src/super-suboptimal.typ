// Element function for sequences
#let sequence = $a b$.body.func()
#let space = $a b$.body.children.at(1).func()
#let text-func = $a b$.body.children.at(0).func()

// Convert content to an array of its children
#let to-children(content) = {
  if type(content) == str {
    content.clusters().map(char => [#char])
  } else if content.has("children") {
    content.children
  } else if content.has("text") {
    to-children(content.text)
  } else if content.func() == math.equation {
    to-children(content.body)
  }
}

#let super-dict = ("⁰":"0", "¹":"1", "²":"2", "³":"3", "⁴":"4", "⁵":"5", "⁶":"6", "⁷":"7", "⁸":"8", "⁹":"9", "⁺":"+", "⁻":"−", "⁼":"=", "⁽":"(", "⁾":")", "ᴬ":"A", "ᴮ":"B", "ᴰ":"D", "ᴱ":"E", "ᴳ":"G", "ᴴ":"H", "ᴵ":"I", "ᴶ":"J", "ᴷ":"K", "ᴸ":"L", "ᴹ":"M", "ᴺ":"N", "ᴼ":"O", "ᴾ":"P", "ᴿ":"R", "ᵀ":"T", "ᵁ":"U", "ⱽ":"V", "ᵂ":"W", "ᵃ":"a", "ᵇ":"b", "ᶜ":"c", "ᵈ":"d", "ᵉ":"e", "ᶠ":"f", "ᵍ":"g", "ʰ":"h", "ⁱ":"i", "ʲ":"j", "ᵏ":"k", "ˡ":"l", "ᵐ":"m", "ⁿ":"n", "ᵒ":"o", "ᵖ":"p", "ʳ":"r", "ˢ":"s", "ᵗ":"t", "ᵘ":"u", "ᵛ":"v", "ʷ":"w", "ˣ":"x", "ʸ":"y", "ᶻ":"z", "ᵝ":"β", "ᵞ":"γ", "ᵟ":"δ", "ᵠ":"ψ", "ᵡ":"χ", "ᶿ":"θ", "꙳":"∗")
#let sub-dict = ("₀":"0", "₁":"1", "₂":"2", "₃":"3", "₄":"4", "₅":"5", "₆":"6", "₇":"7", "₈":"8", "₉":"9", "₊":"+", "₋":"−", "₌":"=", "₍":"(", "₎":")", "ₐ":"a", "ₑ":"e", "ₕ":"h", "ᵢ":"i", "ⱼ":"j", "ₖ":"k", "ₗ":"l", "ₘ":"m", "ₙ":"n", "ₒ":"o", "ₚ":"p", "ᵣ":"r", "ₛ":"s", "ₜ":"t", "ᵤ":"u", "ᵥ":"v", "ₓ":"x", "ᵦ":"β", "ᵧ":"γ", "ᵨ":"ρ", "ᵩ":"ψ", "ᵪ":"χ", )

#let super-dict-keys = super-dict.keys()
#let sub-dict-keys = sub-dict.keys()
#let super-sub-keys = super-dict-keys + sub-dict-keys
// To save on performance, we pre-compile all
// the regexes.
#let super-regex = regex(super-dict-keys.join("|"))
#let sub-regex = regex(sub-dict-keys.join("|"))
#let exactly-one-super-or-sub-regex = regex("[" + super-sub-keys.join("") + "]")
#let at-least-one-super-or-sub-regex = regex("[" + super-sub-keys.join("") + "]+")

#let to-baseline(str) = {
  // Converts superscript- or subscript-char
  // to a sequence:
  // (str, dict, str, dict, str, …)
  // where `dict` is
  // - (t: [super-baseline-string],
  //    b: [sub-baseline-string]  )
  // super-baseline-string and sub-baseline-string are
  // the superscript- and subscript-baseline-strings
  // for consecutive sequence of characters
  // that are superscript or subscript.
  // So to-baseline(1²₃⁴56⁷8) =
  // (1, (t: 24, b: 3), 56, (t: 7), 8)
  // 
  // Note that the first and last string of the array may be empty.
  //
  // Returns `none` if str contains no
  // superscript- or subscript-char.

  // .matches uses byte-indices.
  let matches = str.matches(at-least-one-super-or-sub-regex)
  if matches==none { return none }

  let result = ()
  let prev-match-end = 0
  for match in matches {
    // .slice uses byte-indices.
    result.push(str.slice(prev-match-end, match.start))
    let text = match.text
    let subs = text.replace(super-regex, "").clusters().map(x => sub-dict.at(x)).join("")
    let supers = text.replace(sub-regex, "").clusters().map(x => super-dict.at(x)).join("")
    result.push((
      t: [#supers],
      b: [#subs]
    ))
    prev-match-end = match.end
  }
  result.push(str.slice(prev-match-end))
  return result
}

#let clean-baseline(baseline) = {
  if (baseline.at("t", default:none)!=none and baseline.t==[]) {
    baseline.remove("t")
  }
  if (baseline.at("b", default:none)!=none and baseline.b==[]) {
    baseline.remove("b")
  }
  return baseline
}


#let attachy(base-str, unclean-baseline-dict) = {
  // unclean-baseline-dict has format
  // (b: [content], t: [content]),
  // where both contents may possibly be
  // empty. Also, neither key needs be
  // present.
  let clean-baseline-dict = clean-baseline(unclean-baseline-dict)
  return math.attach([#base-str], ..clean-baseline-dict)
}

#let process-prev-child-and-text-child(prev-child, child) = {
  // Returns `none` if `child` contains no
  // super-/subscript chars.
  // Otherwise, returns a new sequence, to
  // be intervowen with the children-array.
  // If prev-child==none, we either don't
  // care, or return the attachment to
  // the empty string.
  
  let text = child.text
  let baseline-arr = to-baseline(text)
  if baseline-arr==none {
    // Didn't find any super-/subscript chars.
    return none
  } else {
    // If the head-string of baseline
    // is empty, we have to move
    // the first set of super-/subscripts
    // over to the previous-child:
    let head-str = baseline-arr.at(0)
    if head-str.len()==0 {
      // If there is no previous child,
      // there's nothing much we can do,
      // so uhh the next section will
      // attach the super- and subscripts
      // to the empty string, I suppose.
      if prev-child==none {
        prev-child = []
      } else {
        // Otherwise, remove the head:
        baseline-arr.remove(0)
        let head-baseline = baseline-arr.remove(0)

        // Depending on what the prev-child
        // is, we either want to add
        // the new super and subscripts
        // to it (if it's `attach`), or
        // take it as a base to attach
        // our super and subscripts to.
        if prev-child.func()==math.attach {
          let prev-fields = prev-child.fields()
          let prev-base = prev-fields.remove("base")
          let prev-t = prev-fields.remove("t", default: [])
          let prev-b = prev-fields.remove("b", default: [])
          let new-t = prev-t + head-baseline.t
          let new-b = prev-b + head-baseline.b
          if (new-t!=[]) {prev-fields.insert("t", new-t)}
          if (new-b!=[]) {prev-fields.insert("b", new-b)}
          
          prev-child = math.attach(prev-base, ..prev-fields)
        } else {
          // The previous content is not math.attach,
          // so create a new attachment with the
          // previous content as a base.
          
          head-baseline = clean-baseline(head-baseline)
          prev-child = math.attach(prev-child, ..head-baseline)
        }
      }
    }

    // What's left over now is an array
    // we want to join over:
    // Baseline could still have length 1, even
    // if it had matches, because the first match
    // might have been absorbed into the
    // previous content.
    if (baseline-arr.len()<=1) {
      // prev-child is now guaranteed to
      // not be `none`
      let final-str = baseline-arr.at(0)
      if (final-str.len()>0) {
        return (prev-child, [#final-str])
      } else {
        return (prev-child,)
      }
    }
    
    // Initial setup, because arrays can't
    // be empty (?), so we have to
    // distinguish the cases between
    // prev-child being `none` or not.
    let result-arr
    let new-attach0 = attachy(
        baseline-arr.at(0),
        baseline-arr.at(1)
      )
    if (prev-child!=none) {
      result-arr = (prev-child,new-attach0)
    } else {
      result-arr = (new-attach0,)
    }
    
    let baseline-ix = 2
    let iter-max = baseline-arr.len()-1
    while baseline-ix < iter-max {
      let new-attach = attachy(
        baseline-arr.at(baseline-ix),
        baseline-arr.at(baseline-ix+1)
      )
      result-arr.push(new-attach)
      baseline-ix += 2
      
    }
    // At last, take care of the
    // final string:
    let final-str = baseline-arr.at(baseline-ix)
    if final-str.len()>0 {
      result-arr.push([#final-str])
    }
    return result-arr
  }
}

// The function to convert a given sequence.
#let convert-sequence(seq) = {
  let is-sequence = type(seq) == content and seq.func() == sequence
  if not is-sequence { return seq }

  let children = seq.children
  if children.len() == 0 {
    return seq
  }

  let children-ix = 0
  while children-ix < children.len() {
    let child = children.at(children-ix)
    if (child.func()!=text) {
      children-ix += 1
    } else {
      // Look backwards for the first
      // content that's not a space
      // and assign that to prev-child.
      // Assign `none` if there is none.
      let prev-child-ix = children-ix - 1
      while (prev-child-ix>=0 and children.at(prev-child-ix).func() == space) {
        prev-child-ix -= 1
      }
      let prev-child
      if (prev-child-ix>=0) { prev-child = children.at(prev-child-ix) }
      else { prev-child = none }

      if prev-child!=none {let ugh = prev-child.func()}
      
      let new-sequence = process-prev-child-and-text-child(prev-child, child)

      if (new-sequence==none) {
        children-ix += 1
      } else {
        let init = children.slice(0, calc.max(0,prev-child-ix))
        let tail = children.slice(children-ix+1)
        children = init + new-sequence + tail
        children-ix = init.len() + new-sequence.len()
      }
    }
  }

  return children.join()
}

// Define the `eq`-function, which works
// just like math.equation, except
// it inserts a space before every
// super- or subscript-character, to
// avoid "unknown variable" errors.
#let whitespace-regex = regex("\\s+")
#let eq-string(string, ..args) = {
  let replaced-string = string.replace(
    exactly-one-super-or-sub-regex,
    match=> " " + match.text
  ).trim(whitespace-regex)
  let mathy = eval(replaced-string, mode: "math") // yuck
  return math.equation(mathy.body, ..args)
}
#let eq(raw, ..args) = {
  assert(type(raw)!=content or raw.func()!=raw, message: "eq needs to be passed `raw` content")
  if raw.block {
    return eq-string(raw.text, block: true, ..args)
  } else {
    return eq-string(raw.text, block: false, ..args)
  }
}

#let super-subscripts(body) = {
  show raw.where(lang: "eq"): raw => {
    set text(size: 1.25em)
    eq(raw)
  }
  
  show math.equation: eq => {
    show sequence: seq => {
      let new = convert-sequence(seq)
      if seq!=new { new } else { seq }
    }
    if (type(eq.body)!=content or eq.body.func()!=text) {
      eq
    } else {
      // This is a crude patch to allow at
      // least $35²²$ to render like $35^22$.
      let fields = eq.fields()
      let body = fields.remove("body")
      let new-body = process-prev-child-and-text-child(none, body)
      math.equation(sequence(new-body), ..fields)
    }
  }

  body
}
