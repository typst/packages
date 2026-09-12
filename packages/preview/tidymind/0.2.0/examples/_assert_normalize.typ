#import "../src/tree.typ": normalize
#set page(width: auto, height: auto)

// a plain dictionary keeps its shape
#let a = normalize((content: [R], children: ()))
#assert.eq(a.children.len(), 0)
#assert(a.content == [R])

// a missing `children` becomes an empty list
#let b = normalize((content: [R],))
#assert.eq(b.children.len(), 0)

// raw content becomes a leaf
#let c = normalize([Loose leaf])
#assert.eq(c.children.len(), 0)
#assert(c.content == [Loose leaf])

// recursion: children are normalized too
#let d = normalize((content: [R], children: ((content: [F],),)))
#assert.eq(d.children.len(), 1)
#assert.eq(d.children.at(0).children.len(), 0)

// an empty label never yields a null node
#assert(normalize([]).content == [—])

#[OK]
