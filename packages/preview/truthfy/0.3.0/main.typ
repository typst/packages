#let (generate-empty, generate-table, truth-table, truth-table-empty,  NAND, NOR, nand, nor) = {
    let symboles-conv(a) = {
        if (a) {
            "1"
        } else { "0" }
    }

    // Transform a simple math equation to a string
    let _strstack(obj) = if obj.body.has("b") {
        obj.body.base.text + "_" + obj.body.b.text;
    } else if not obj.body.has("children") {
        " "
    } else { obj.body.children.map(subobj => {
        if subobj.has("text") {
            subobj.text
        } else {
            if subobj.fields().len() == 0 {
                " "
            } else {
                if (subobj.has("b")) {
                    subobj.base.text + "_" + subobj.b.text;
                } else {
                    _strstack(subobj.fields())
                }

            }
        }
    }).flatten().join("")}

    // Replaces names with their values (true or false)
    let _replaces(names, vals, obj) = {
        // Replace names by their values
        let text = obj
        for e in range(names.len()) {
            let reg = regex("\b(?:\(?\s?)(" + names.at(e) + ")(?:\s?\W?\)?)?\b");
            for f in text.matches(reg) {
                text = text.replace(reg, vals.at(e))
            }

        }

        // Basic operations, they doesn't need a particular approach
        text = str(text.replace("∧", "and").replace("∨", "or")).replace("¬", "not")

        // => Approach
        // Please implement the do while :pray:
        while true {
            let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*⇒[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+")) // regex hell
            if(pos != none) {
                text = text.replace(pos.text, "not " + pos.text.replace("⇒", "or"))
            } else {break}
        }

        // ↑ Approach
        while true {
            let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*↑[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+")) 
            if(pos != none) {
                text = text.replace(pos.text, "not(" + pos.text.replace("↑", "and") + ")")
            } else {break}
        }

        // ↓ Approach
        while true {
            let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*↓[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+")) 
            if(pos != none) {
                text = text.replace(pos.text, "not(" + pos.text.replace("↓", "or") + ")")
            } else {break}
        }

        // <=> Approach
        while true {
            let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*⇔[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
            if(pos != none) {
                text = text.replace(pos.text, "(" + pos.text.replace("⇔", "==") + ")")
            } else {break}
        }

        // a ? b : c Approach
        while true {
            let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*\?[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*\:[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
            if(pos != none) {
                text = text.replace(pos.text, " if (" + pos.text.replace("?", "){ ").replace(":", " } else { ") + " }")
            } else {break}
        }

        // ⊕ Approach
        while true {
            let pos = text.match(regex("([(]+.*[)]|[a-zA-Z](_\d+)?)+[ ]*⊕[ ]*([(]+.*[)]|[a-zA-Z](_\d+)?)+"))
            if(pos != none) {
                text = text.replace(pos.text, "not (" + pos.text.replace("⊕", "==") + ")")
            } else {break}
        }

        return text
    }

    // Extract all propositions
    let _extract(..obj) = {
        let single_letters = ();
        for operation in obj.pos(){
            let string_operation = _strstack(operation).split(" ");
            for substring in string_operation {
                let match = substring.match(regex("[a-zA-Z](_\d+)?"));
                if match != none and (match.text not in single_letters) {
                    single_letters.push(match.text)
                }
            }
        }
        return single_letters
    }

    let _gen-nb-left-empty-truth(sc: symboles-conv, bL, row) = {
        for col in range(1, bL + 1).rev() {
            let raised = calc.pow(2, col - 1);
            let value = not calc.even(calc.floor(row / raised))
            ([#sc(value)],)
        }
    }

    let _mathed(obj) = eval(obj, mode: "math")

    let truth-table-empty(sc: symboles-conv , info, data) = {
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
            ..base.map(_mathed), ..info,
            ..(for row in range(L) {
                (.._gen-nb-left-empty-truth(sc: sc, bL, row))
                (..data.slice(row * iL, count: iL).map((a) => [#if type(a) != "content" {sc(a)} else {a}]))
            })
        )
    }

    


    let truth-table(sc: symboles-conv ,..inf) = {
        let info = inf.pos()
        let base = _extract(..info)
        let bL = base.len()
        let L = calc.pow(2, bL);
        let iL = info.len()
        let nbBox = (iL + bL) * calc.pow(2, bL)
        let transform = info.map(_strstack)

        table(
            columns: iL + bL,
            ..base.map(_mathed), ..info,
            ..(for row in range(L) {
                let list = ();
                (
                    ..for col in range(1, bL + 1).rev() { // The left side
                        let raised = calc.pow(2, col - 1);
                        let value = not calc.even(calc.floor(row / raised))
                        list.push(value)
                        ([#sc(value)],)
                    }
                )
                let x = list.map(repr)
                if x != none and x.len() != 0 {
                (
                    ..for col in range(iL) { // The right side
                        let m = _replaces(base, x, transform.at(col));
                        //([#m],) // Debug
                        let k = eval(m);
                        ([#sc(k)],)
                    }
                )}
            })
        )
    }
    
    let generate-table = truth-table; // DEPRECATED
    let generate-empty = truth-table-empty ; // DEPRECATED

    

    // For simplified writing
    let NAND = "↑";
    let NOR = "↓"
    let nand = "↑"
    let nor = "↓"

 (generate-empty, generate-table, truth-table, truth-table-empty, NAND, NOR, nand, nor)
}

