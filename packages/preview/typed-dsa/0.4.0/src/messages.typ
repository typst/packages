// Centralized localization for every user-visible diagram caption.
//
// A catalog is a flat dictionary keyed by a semantic `"group.key"` string, for
// example `"tree.insert"` or `"graph.relax"`. Each value is either static
// content (`[extract]`) or a function returning content when the caption needs
// interpolation (`key => [insert #key]`). Structure modules never assemble a
// caption from translated fragments; they request a whole semantic key from the
// resolved catalog so word order and grammar can differ freely across
// languages.
//
// Three layers resolve a caption, highest priority last:
//
//   English/default catalog → selected language catalog → messages: overrides
//   → step-label: override
//
// `step-label:` stays in the individual operation functions; this module owns
// the first three layers. `resolve-catalog(language:, messages:)` merges the
// first three into one flat catalog that a builder threads through its
// operations and its chained `.result` objects, so the language and any
// overrides persist for the lifetime of an object.

#let supported-languages = ("en", "de", "es")

// ── English catalog (source of truth) ────────────────────────────────────────
//
// Every key the package can ever request must exist here. The German and
// Spanish catalogs mirror this key set exactly; `resolve-catalog` validates
// override keys against the selected catalog, so a missing key surfaces as a
// clear error instead of a silent blank caption.

#let catalog-en = (
  // Trees
  "tree.insert": key => [insert #key],
  "tree.delete": key => [delete #key],
  "tree.search": key => [search #key],
  "tree.rotate-left": pivot => [rotate left at #pivot],
  "tree.rotate-right": pivot => [rotate right at #pivot],

  // Heaps
  "heap.insert": key => [insert #key],
  "heap.extract": [extract],

  // Linked lists and doubly linked lists
  "list.insert": v => [insert #v],
  "list.insert-at": (v, i) => [insert #v at #i],
  "list.prepend": v => [prepend #v],
  "list.delete": v => [delete #v],
  "list.delete-at": i => [delete index #i],
  "list.search": v => [search #v],
  "list.head": [Head],

  // Stack
  "stack.push": v => [push #v],
  "stack.pop": [pop],
  "stack.top": [top],

  // Queue
  "queue.enqueue": v => [enqueue #v],
  "queue.dequeue": [dequeue],
  "queue.enqueue-label": [Enqueue],
  "queue.dequeue-label": [Dequeue],
  "queue.front": [Front],
  "queue.rear": [Rear],

  // Skip list
  "skip.search": key => [search #key],
  "skip.insert": v => [insert #v],
  "skip.delete": v => [delete #v],

  // Hash table
  "hash.insert": key => [insert #key],
  "hash.delete": key => [delete #key],
  "hash.search": key => [search #key],

  // Graph algorithm traces
  "graph.queue": node => [queue #node],
  "graph.stack": node => [stack #node],
  "graph.visit": node => [visit #node],
  "graph.inspect": (from, to) => [inspect #from → #to],
  "graph.finish": node => [finish #node],
  "graph.reached": node => [reached #node],
  "graph.settle": node => [settle #node],
  "graph.relax": (from, to) => [relax #from → #to],
  "graph.distance-init": node => [distance(#node) = 0],
  "graph.shortest-path": node => [shortest path to #node found],
  "graph.distance": value => [d = #value],

  // Sorting — structural captions
  "sort.original": [original array],
  "sort.sorted-array": [sorted array],
  "sort.divide": [divide],
  "sort.divide-phase": [Divide],
  "sort.merge": [merge],
  "sort.merge-phase": [Merge],
  "sort.partition-phase": [Partition],
  "sort.left": [left],
  "sort.right": [right],
  "sort.result": [result],
  "sort.start": [start],
  "sort.sorted": [sorted],
  // Sorting — generated descriptions
  "sort.compare": (a, b) => [compare #a and #b],
  "sort.swap": (a, b) => [swap #a and #b],
  "sort.settled": v => [#v settled],
  "sort.start-merge": [start merge],
  "sort.merged": [merged],
  "sort.take": v => [take #v],
  "sort.take-remaining": v => [take remaining #v],
  "sort.compare-pivot": (a, pivot) => [compare #a and pivot #pivot],
  "sort.select-pivot": v => [select pivot #v],
  "sort.select-last-pivot": v => [select last pivot #v],
  "sort.place-pivot": v => [place pivot #v],
  "sort.advance-i": i => [advance i to #i],
  "sort.partitioned": [partitioned],
  "sort.partition-pivot": v => [partition pivot #v],
  "sort.partition-around": v => [partition around pivot #v],
  "sort.pivot-info": (value, index, i, j) => [pivot: #value at #index; i: #i; j: #j],
  "sort.i-satisfies": v => [i #v satisfies the pivot test],
  "sort.j-satisfies": v => [j #v satisfies the pivot test],
  "sort.selection-status": (pos, min, item) => [position #pos, minimum #min, item #item],
)

// ── German catalog ───────────────────────────────────────────────────────────

#let catalog-de = (
  "tree.insert": key => [#key einfügen],
  "tree.delete": key => [#key löschen],
  "tree.search": key => [#key suchen],
  "tree.rotate-left": pivot => [Linksrotation bei #pivot],
  "tree.rotate-right": pivot => [Rechtsrotation bei #pivot],

  "heap.insert": key => [#key einfügen],
  "heap.extract": [entnehmen],

  "list.insert": v => [#v einfügen],
  "list.insert-at": (v, i) => [#v an Position #i einfügen],
  "list.prepend": v => [#v voranstellen],
  "list.delete": v => [#v löschen],
  "list.delete-at": i => [Index #i löschen],
  "list.search": v => [#v suchen],
  "list.head": [Kopf],

  "stack.push": v => [#v ablegen],
  "stack.pop": [entnehmen],
  "stack.top": [oben],

  "queue.enqueue": v => [#v einreihen],
  "queue.dequeue": [ausreihen],
  "queue.enqueue-label": [Einreihen],
  "queue.dequeue-label": [Ausreihen],
  "queue.front": [Vorne],
  "queue.rear": [Hinten],

  "skip.search": key => [#key suchen],
  "skip.insert": v => [#v einfügen],
  "skip.delete": v => [#v löschen],

  "hash.insert": key => [#key einfügen],
  "hash.delete": key => [#key löschen],
  "hash.search": key => [#key suchen],

  "graph.queue": node => [#node einreihen],
  "graph.stack": node => [#node stapeln],
  "graph.visit": node => [#node besuchen],
  "graph.inspect": (from, to) => [#from → #to prüfen],
  "graph.finish": node => [#node abschließen],
  "graph.reached": node => [#node erreicht],
  "graph.settle": node => [#node festlegen],
  "graph.relax": (from, to) => [#from → #to relaxieren],
  "graph.distance-init": node => [Distanz(#node) = 0],
  "graph.shortest-path": node => [kürzester Weg zu #node gefunden],
  "graph.distance": value => [d = #value],

  "sort.original": [ursprüngliches Array],
  "sort.sorted-array": [sortiertes Array],
  "sort.divide": [teilen],
  "sort.divide-phase": [Teilen],
  "sort.merge": [verschmelzen],
  "sort.merge-phase": [Verschmelzen],
  "sort.partition-phase": [Partitionieren],
  "sort.left": [links],
  "sort.right": [rechts],
  "sort.result": [Ergebnis],
  "sort.start": [Start],
  "sort.sorted": [sortiert],
  "sort.compare": (a, b) => [#a und #b vergleichen],
  "sort.swap": (a, b) => [#a und #b tauschen],
  "sort.settled": v => [#v steht fest],
  "sort.start-merge": [Verschmelzen starten],
  "sort.merged": [verschmolzen],
  "sort.take": v => [#v übernehmen],
  "sort.take-remaining": v => [verbleibende #v übernehmen],
  "sort.compare-pivot": (a, pivot) => [#a mit Pivot #pivot vergleichen],
  "sort.select-pivot": v => [Pivot #v wählen],
  "sort.select-last-pivot": v => [letzten Pivot #v wählen],
  "sort.place-pivot": v => [Pivot #v platzieren],
  "sort.advance-i": i => [i auf #i vorrücken],
  "sort.partitioned": [partitioniert],
  "sort.partition-pivot": v => [um Pivot #v partitionieren],
  "sort.partition-around": v => [um Pivot #v partitionieren],
  "sort.pivot-info": (value, index, i, j) => [Pivot: #value bei #index; i: #i; j: #j],
  "sort.i-satisfies": v => [i #v erfüllt die Pivot-Bedingung],
  "sort.j-satisfies": v => [j #v erfüllt die Pivot-Bedingung],
  "sort.selection-status": (pos, min, item) => [Position #pos, Minimum #min, Element #item],
)

// ── Spanish catalog ──────────────────────────────────────────────────────────

#let catalog-es = (
  "tree.insert": key => [insertar #key],
  "tree.delete": key => [eliminar #key],
  "tree.search": key => [buscar #key],
  "tree.rotate-left": pivot => [rotación izquierda en #pivot],
  "tree.rotate-right": pivot => [rotación derecha en #pivot],

  "heap.insert": key => [insertar #key],
  "heap.extract": [extraer],

  "list.insert": v => [insertar #v],
  "list.insert-at": (v, i) => [insertar #v en #i],
  "list.prepend": v => [anteponer #v],
  "list.delete": v => [eliminar #v],
  "list.delete-at": i => [eliminar índice #i],
  "list.search": v => [buscar #v],
  "list.head": [Cabeza],

  "stack.push": v => [apilar #v],
  "stack.pop": [desapilar],
  "stack.top": [cima],

  "queue.enqueue": v => [encolar #v],
  "queue.dequeue": [desencolar],
  "queue.enqueue-label": [Encolar],
  "queue.dequeue-label": [Desencolar],
  "queue.front": [Frente],
  "queue.rear": [Final],

  "skip.search": key => [buscar #key],
  "skip.insert": v => [insertar #v],
  "skip.delete": v => [eliminar #v],

  "hash.insert": key => [insertar #key],
  "hash.delete": key => [eliminar #key],
  "hash.search": key => [buscar #key],

  "graph.queue": node => [encolar #node],
  "graph.stack": node => [apilar #node],
  "graph.visit": node => [visitar #node],
  "graph.inspect": (from, to) => [inspeccionar #from → #to],
  "graph.finish": node => [finalizar #node],
  "graph.reached": node => [alcanzado #node],
  "graph.settle": node => [fijar #node],
  "graph.relax": (from, to) => [relajar #from → #to],
  "graph.distance-init": node => [distancia(#node) = 0],
  "graph.shortest-path": node => [camino más corto a #node encontrado],
  "graph.distance": value => [d = #value],

  "sort.original": [lista original],
  "sort.sorted-array": [lista ordenada],
  "sort.divide": [dividir],
  "sort.divide-phase": [Dividir],
  "sort.merge": [fusionar],
  "sort.merge-phase": [Fusionar],
  "sort.partition-phase": [Partición],
  "sort.left": [izquierda],
  "sort.right": [derecha],
  "sort.result": [resultado],
  "sort.start": [inicio],
  "sort.sorted": [ordenado],
  "sort.compare": (a, b) => [comparar #a y #b],
  "sort.swap": (a, b) => [intercambiar #a y #b],
  "sort.settled": v => [#v fijado],
  "sort.start-merge": [iniciar fusión],
  "sort.merged": [fusionado],
  "sort.take": v => [tomar #v],
  "sort.take-remaining": v => [tomar restante #v],
  "sort.compare-pivot": (a, pivot) => [comparar #a con pivote #pivot],
  "sort.select-pivot": v => [elegir pivote #v],
  "sort.select-last-pivot": v => [elegir último pivote #v],
  "sort.place-pivot": v => [colocar pivote #v],
  "sort.advance-i": i => [avanzar i a #i],
  "sort.partitioned": [particionado],
  "sort.partition-pivot": v => [particionar con pivote #v],
  "sort.partition-around": v => [particionar alrededor del pivote #v],
  "sort.pivot-info": (value, index, i, j) => [pivote: #value en #index; i: #i; j: #j],
  "sort.i-satisfies": v => [i #v cumple la condición del pivote],
  "sort.j-satisfies": v => [j #v cumple la condición del pivote],
  "sort.selection-status": (pos, min, item) => [posición #pos, mínimo #min, elemento #item],
)

#let catalogs = (en: catalog-en, de: catalog-de, es: catalog-es)

// The English catalog is the default every operation function falls back to
// when it is used standalone without a resolved catalog threaded in.
#let default-catalog = catalog-en

// ── Public override helper ───────────────────────────────────────────────────

// Build a reusable overrides dictionary from structure-grouped definitions:
//
//   #let spanish = messages(
//     tree: (insert: key => [insertar #key]),
//     graph: (visit: node => [visitar #node]),
//   )
//
// Returns a flat dictionary keyed by `"group.key"`, ready to pass to any
// builder's `messages:` argument. Each value is content or a callback, exactly
// like a catalog entry.
#let messages(..groups) = {
  assert(groups.pos().len() == 0, message: "typed-dsa messages() takes only named groups, e.g. messages(tree: (...))")
  let flat = (:)
  for (group, entries) in groups.named() {
    assert(type(entries) == dictionary, message: "typed-dsa messages() group \"" + group + "\" must be a dictionary of key: value entries")
    for (key, value) in entries {
      flat.insert(group + "." + key, value)
    }
  }
  flat
}

// Accept either the flat output of `messages(...)` or a raw grouped dictionary,
// and return a flat `"group.key"` dictionary either way. A grouped entry is a
// bare group name mapping to a sub-dictionary of key/value pairs; a flat entry
// is already a dotted key. Message values are always content or functions, so a
// dictionary value can only mean a group.
#let _normalize-overrides(overrides) = {
  if overrides == none { return (:) }
  assert(type(overrides) == dictionary, message: "typed-dsa messages: must be a dictionary (build one with messages(...))")
  let flat = (:)
  for (key, value) in overrides {
    if type(value) == dictionary and not key.contains(".") {
      for (sub, sub-value) in value {
        flat.insert(key + "." + sub, sub-value)
      }
    } else {
      flat.insert(key, value)
    }
  }
  flat
}

// ── Resolution and lookup ────────────────────────────────────────────────────

// Merge the default/selected catalog with the user's overrides into one flat
// catalog. `language` selects the base; `messages` layers on top. Unknown
// languages and unknown override keys both fail with a clear message.
#let resolve-catalog(language: "en", messages: (:)) = {
  assert(
    language in supported-languages,
    message: "typed-dsa language must be one of " + supported-languages.map(l => "\"" + l + "\"").join(", ") + ", got \"" + str(language) + "\"",
  )
  let base = catalogs.at(language)
  let overrides = _normalize-overrides(messages)
  for (key, _) in overrides {
    assert(key in base, message: "typed-dsa messages: unknown message key \"" + key + "\" (see the message-key reference in the documentation)")
  }
  base + overrides
}

// Look up `key` in a resolved catalog and produce its caption content. When the
// entry is a function it is applied to `args`; otherwise the static content is
// returned as-is. Callbacks receive whatever Typst values the caller passes —
// integers, strings, math, or arbitrary content — untouched.
#let msg(catalog, key, ..args) = {
  assert(key in catalog, message: "typed-dsa: unknown message key \"" + key + "\"")
  let value = catalog.at(key)
  if type(value) == function { value(..args.pos()) } else { value }
}
