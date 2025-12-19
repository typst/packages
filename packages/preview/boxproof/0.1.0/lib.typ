#let pf(..lines) = {
  counter => {
    let result = array(())

    for line in lines.pos() {
      if (type(line) == array) {
        let (stmt, reason) = line
        result.push(
          grid(
            columns: (auto, auto, auto, 1fr),
            align: (left, left, left, right),
            $counter$, h(5%), stmt, reason,
          ),
        )
        counter += 1
      } else {
        assert.eq(type(line), function)
        let (counter_, x) = line(counter)
        result.push(x)
        counter = counter_
      }
    }
    (counter, grid(rows: result.len(), inset: 2pt, align: top, ..result))
  }
}

#let pfbox(..lines) = {
  i => {
    let (counter_, x) = pf(..lines)(i)
    (
      counter_,
      box(
        x,
        stroke: black,
      ),
    )
  }
}

#let cases(..boxes) = {
  i => {
    let result = array(())
    let counter = i

    for line in boxes.pos() {
      assert.eq(type(line), function)
      let (counter_, x) = line(counter)
      result.push(align(left + top, x))
      counter = counter_
    }

    (
      counter,
      table(
        columns: result.len(),
        align: top,
        ..result.map(col => [#col])
      ),
    )
  }
}
#let start(f) = {
  assert.eq(type(f), function)
  f(1).at(1)
}

#let andi(l1, l2) = $and#h(0em)I(#l1, #l2)$
#let impi(l1, l2) = $->#h(0em)I(#l1, #l2)$
#let ori(l) = $or#h(0em)I(#l)$
#let noti(l1, l2) = $not I(#l1, #l2)$
#let dni(l) = $not not I(#l)$
#let fi(l1, l2) = $bot I(#l1, #l2)$
#let ti = $top I$
#let iffi(l1, l2) = $<->#h(0em)I(#l1, #l2)$
#let exi(l) = $exists I(#l)$
#let fai(l1, l2) = $forall I(#l1, #l2)$

#let ande(l) = $and#h(0em)E(#l)$
#let impe(l1, l2) = $->#h(0em)E(#l1, #l2)$
#let ore(l1, l2, l3, l4, l5) = $or#h(0em)E(#l1, #l2 - #l3, #l4 - #l5)$
#let note(l1, l2) = $not E(#l1, #l2)$
#let dne(l) = $not not E(#l)$
#let fe(l) = $bot E(#l)$
#let iffe(l1, l2) = $<->#h(0em)E(#l1, #l2)$
#let exe(l1, l2, l3, l4) = $exists E(#l1, #l2, #l3, #l4)$
#let fae(l) = $forall E(#l)$
#let faie(l1, l2) = $forall #h(0em) -> #h(0em) E(#l1, #l2)$

#let lem = [*LEM*]
#let mt = [*MT*]
#let pc = [*PC*]
#let refl = [*refl*]
#let eqsub(l1, l2) = [*=sub*(#l1, #l2)]
#let symm(l) = [*sym*(#l)]
#let fic = [$forall I$ *const*]
#let given = [*given*]
#let premise = [*premise*]
#let ass = [*ass*]
#let tick(l) = $#sym.checkmark (#l)$
