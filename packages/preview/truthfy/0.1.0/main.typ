// Transform a simple math equation to a string
#let _strstack(obj) = obj.body.children.map(subobj => {
    if subobj.has("text") {
        subobj.text
    } else {
        if subobj.fields().len() == 0 {
            " "
        } else {
            _strstack(subobj.fields())
        }
    }
}).flatten().join("")

// Replaces 
#let _replaces = (names, vals, obj) => {
    // Basic operations, they doesn't need a particular approach
    let text = str(obj.replace("∧", "and").replace("∨", "or")).replace("¬", "not")

    // => Approach
    // Please implement the do while :pray:
    while true {
        let pos = text.match(regex("([(]+.*[)]|[a-zA-Z])+[ ]*⇒[ ]*([(]+.*[)]|[a-zA-Z])+"))
        if(pos != none) {
            text = text.replace(pos.text, "not " + pos.text.replace("⇒", "or"))
        } else {break}
    }

    // <=> Approach
    while true {
        let pos = text.match(regex("([(]+.*[)]|[a-zA-Z])+[ ]*⇔[ ]*([(]+.*[)]|[a-zA-Z])+"))
        if(pos != none) {
            text = text.replace(pos.text, "(" + pos.text.replace("⇔", "==") + ")")
        } else {break}
    }

    // ⊕ Approach
    while true {
        let pos = text.match(regex("([(]+.*[)]|[a-zA-Z])+[ ]*⊕[ ]*([(]+.*[)]|[a-zA-Z])+"))
        if(pos != none) {
            text = text.replace(pos.text, "not (" + pos.text.replace("⊕", "==") + ")")
        } else {break}
    }
    
    // Replace names by their values
    for e in range(names.len()) {
        text = text.replace(names.at(e), vals.at(e))
    }
    return text
}

// Extract all 
#let _extract = (..obj) => {
    let single_letters = ();
    for operation in obj.pos(){
        let string_operation = _strstack(operation).split(" ");
        for substring in string_operation {
            let match = substring.match(regex("[a-zA-Z]"));
            if match != none and (match.text not in single_letters) {
                single_letters.push(match.text)
            }
        }
    }
    return single_letters
}

#let generate-empty = (info, data) => {
    let base = _extract(..info)
    let bL = base.len()
    let L = calc.pow(2, bL);
    let iL = info.len()
    let nbBox = (iL + bL) * calc.pow(2, bL)

    if data.len() < nbBox {
        for _ in range(nbBox - data.len()) {
            data.push([])
        }
    } 
    
    table(
        columns: iL + bL,
        ..base, ..info,
        ..(for row in range(L) {
            (
                ..for col in range(1, bL + 1).rev() {
                    let raised = calc.pow(2, col - 1);
                    let value = not calc.even(calc.floor(row / raised))
                    ([#int(value)],)
                }
            )
            (..data.slice(row * iL, count: iL).map((a) => [#a]))
        })
    )
}




#let generate-table = (..inf) => {
    let info = inf.pos()
    let base = _extract(..info)
    let bL = base.len()
    let L = calc.pow(2, bL);
    let iL = info.len()
    let nbBox = (iL + bL) * calc.pow(2, bL)
    let transform = info.map(_strstack)
    
    table(
        columns: iL + bL,
        ..base, ..info,
        ..(for row in range(L) {
            let list = ();
            (
                ..for col in range(1, bL + 1).rev() { // The left side
                    let raised = calc.pow(2, col - 1);
                    let value = not calc.even(calc.floor(row / raised))
                    list.push(value)
                    ([#int(value)],)
                }
            )
            let x = list.map(repr)
            (
                ..for col in range(iL) { // The right side
                    let m = _replaces(base, x, transform.at(col))
                    let k = eval(m);
                    ([#int(k)],)
                }
            )
        })
    )
}

