// La disposición de los diagramas: la usan sgf-diagrams, sgf-problem y goban-layout. Cada diagrama es una celda.
// Con columns: auto, las celdas van en el párrafo, una al lado de la otra, y pasan a la línea siguiente cuando
// no entran; con un número, van en una grilla de columnas del mismo ancho (con width: auto, el del diagrama más
// ancho), alineadas arriba.

#import "options.typ": merge, caption-defaults, comments-defaults
#import "draw/goban.typ": draw, record
#import "game.typ": notes-text

// Comprueba la disposición lay.
#let check-layout(lay) = {
  if lay.columns != auto and (type(lay.columns) != int or lay.columns < 1) {
    panic("layout.columns es auto o un número: " + repr(lay.columns))
  }
  if lay.width != auto and type(lay.width) not in (length, ratio, relative) {
    panic("layout.width es auto, una longitud o una fracción del ancho: " + repr(lay.width))
  }
  for key in ("column-sep", "row-sep") {
    if type(lay.at(key)) != length { panic("layout." + key + " es una longitud: " + repr(lay.at(key))) }
  }
  if type(lay.fit) != bool { panic("layout.fit es true o false: " + repr(lay.fit)) }
  if lay.halign not in (left, center, right) { panic("layout.halign es left, center o right: " + repr(lay.halign)) }
  if lay.valign not in (top, bottom) { panic("layout.valign es top o bottom: " + repr(lay.valign)) }
  if type(lay.align-captions) != bool { panic("layout.align-captions es true o false: " + repr(lay.align-captions)) }
  if lay.per-page != none and (type(lay.per-page) != int or lay.per-page < 1) {
    panic("layout.per-page es none o un número desde 1: " + repr(lay.per-page))
  }
  if lay.fit and lay.columns != auto and lay.width == auto {
    panic("layout.fit no sirve con width: auto: las columnas toman el ancho de los diagramas")
  }
  lay
}

// La disposición de la rama name: su layout encima del de todos, comprobada.
#let layout-options(tree, name) = {
  let own = tree.at(name).layout
  for key in own.keys() {
    if key not in tree.layout { panic("opción desconocida: " + name + ".layout." + key) }
  }
  check-layout(merge(tree.layout, own, path: ("layout",)))
}

// Una longitud o una fracción del ancho disponible, como longitud.
#let absolute(value, available) = {
  if type(value) == ratio { value * available }
  else if type(value) == relative { value.ratio * available + value.length.to-absolute() }
  else { value.to-absolute() }
}

// Las piezas de body, para cortarlo entre palabras: las palabras y los espacios de sus textos (también dentro de
// strong y emph) y los demás elementos enteros, cada una con space: true si es un espacio, un salto de línea o
// de párrafo.
#let pieces(body) = {
  let f = body.func()
  if f == [].func() { return body.children.map(pieces).flatten() }
  if f == text and body.fields().keys() == ("text",) {
    return body.text.matches(regex("\s+|\S+")).map(m => (body: text(m.text), space: m.text.trim() == ""))
  }
  if f in (strong, emph) and body.fields().keys() == ("body",) {
    return pieces(body.body).map(p => (body: f(p.body), space: p.space))
  }
  ((body: body, space: f in ([ ].func(), linebreak, parbreak)),)
}

// Corta body entre palabras: lo que entra en height, según measure-height (la altura de un contenido), y el
// resto, sin los espacios de las puntas; none donde no queda nada.
#let split(body, height, measure-height) = {
  let p = pieces(body)
  let trim(list) = {
    let (a, b) = (0, list.len())
    while a < b and list.at(a).space { a += 1 }
    while b > a and list.at(b - 1).space { b -= 1 }
    list.slice(a, b)
  }
  let join(list) = if list.len() > 0 { list.map(x => x.body).join() }
  let fits(k) = {
    let top = join(trim(p.slice(0, k)))
    top == none or measure-height(top) <= height
  }
  if fits(p.len()) { return (body, none) }
  // fits(low) y no fits(high).
  let (low, high) = (0, p.len())
  while high - low > 1 {
    let middle = calc.quo(low + high, 2)
    if fits(middle) { low = middle } else { high = middle }
  }
  (join(trim(p.slice(0, low))), join(trim(p.slice(low))))
}

// La escala con la que el tablero resuelto ocupa target de ancho. Las etiquetas no se escalan: se ajusta
// varias veces.
#let fit-scale(resolved, target) = {
  let resolved = resolved
  let s = resolved.tree.scale
  for _ in range(4) {
    resolved.tree.scale = s
    s = s * target / measure(draw(resolved).body).width
  }
  s
}

// El texto de un contenido, sin formato (para medir sus palabras).
#let flat(body) = {
  if type(body) == str { body }
  else if type(body) != content { "" }
  else if body.has("text") { body.text }
  else if body.has("children") { body.children.map(flat).join() }
  else if body.has("body") { flat(body.body) }
  else if body.func() == [ ].func() { " " }
  else { "" }
}

// Los anchos de un diagrama fuera de la grilla de ancho fijo: el del diagrama (diagram, el del tablero o el del
// epígrafe, si es más ancho) y el de lo que va debajo del tablero (text). Un epígrafe más ancho que su tablero se
// corta en las líneas que le hacen falta a ese ancho (pero no a menos de min-width); después se angosta, aunque
// quede más angosto que el tablero, hasta donde esas líneas siguen entrando, para que queden parejas. Nunca es más
// angosto que la palabra más larga del epígrafe.
#let caption-width(caption, caption-text, board-width, min-width) = {
  let plain = (diagram: board-width, text: board-width)
  if caption == none { return plain }
  let one-line = measure(text(..caption-text, caption)).width
  if one-line <= board-width { return plain }
  let least = measure(text(..caption-text, box(width: min-width))).width
  let words = flat(caption).split(" ").filter(w => w != "")
  let widest = calc.max(0pt, ..words.map(w => measure(text(..caption-text, w)).width))
  let target = calc.max(board-width, widest, calc.min(one-line, least))
  if target >= one-line { return (diagram: one-line, text: one-line) }
  let height(w) = measure(block(width: w, text(..caption-text, caption))).height
  let lines = height(target)
  let (low, high) = (widest, target)
  for _ in range(12) {
    let middle = (low + high) / 2
    if height(middle) <= lines { high = middle } else { low = middle }
  }
  (diagram: target, text: high)
}

// Las opciones de un tablero suelto de goban-layout: sin epígrafe, notas ni comentarios.
#let board-style = (notes: false, caption: caption-defaults, comments: comments-defaults + (on: false))

// Dispone en available (el ancho disponible), con la disposición lay, los diagramas de groups. Cada grupo tiene
// sus opciones (style: las de diagrams o problems, comprobadas, o board-style) y sus diagramas (items); con
// fit, todos los de un grupo usan la escala que llena la columna con el primero. Cada item tiene su tablero
// resuelto (resolved), su epígrafe (caption, none sin epígrafe), sus comentarios (comments, cada uno con su
// número delante), una línea más debajo de las notas (extra, none si no hay) y alone (va solo en su fila). Las
// notas del último quedan como las del último goban.
#let arrange(lay, available, groups) = {
  // Sin un ancho disponible (al medir los diagramas sin límite), la grilla toma el ancho de los diagramas.
  let lay = lay
  if available.pt().is-infinite() and lay.columns != auto { lay.width = auto; lay.fit = false }
  let grid-mode = lay.columns != auto
  let natural = grid-mode and lay.width == auto
  // Con width: auto, hasta medir los diagramas vale el ancho disponible (lo usan los comentarios al costado).
  let width = if lay.width == auto { available } else { absolute(lay.width, available) }
  let column-sep = lay.column-sep.to-absolute()
  let cell = if grid-mode { (width - (lay.columns - 1) * column-sep) / lay.columns }
  let text-align = if grid-mode { lay.halign } else { center }

  let after = ()
  let cells = ()
  let last = none
  for group in groups {
    let d = group.style
    let c = d.comments
    let caption-text = d.caption.text
    let comment-text = caption-text + c.text
    let comments-block(body) = block(width: 100%, {
      set par(justify: c.justify)
      set align(c.align)
      text(..comment-text, body)
    })
    // Debajo del epígrafe o al costado.
    let comments-box(body) = {
      set par(spacing: 0.65em, first-line-indent: 0pt)
      comments-block(body)
    }
    let side = c.on and c.position in (left, right)
    let sep = c.sep.to-absolute()
    // El ancho de la columna del tablero en la grilla: con los comentarios al costado, la celda menos width o,
    // con fit, la mitad de la celda; none, el del tablero (también con width: auto).
    let board-column = if not grid-mode or natural { none } else if not side { cell } else if c.width != auto {
      cell - sep - c.width.to-absolute()
    } else if lay.fit { (cell - sep) / 2 } else { none }
    let scale = if lay.fit and board-column != none and group.items.len() > 0 {
      fit-scale(group.items.first().resolved, board-column)
    }

    for item in group.items {
      let resolved = item.resolved
      if scale != none { resolved.tree.scale = scale }
      let drawn = draw(resolved)
      // Un tablero más ancho que el primero no entra con esa escala: solo ese se achica.
      if scale != none and measure(drawn.body).width > board-column + 0.1pt {
        resolved.tree.scale = fit-scale(resolved, board-column)
        drawn = draw(resolved)
      }
      let board-width = measure(drawn.body).width
      let parts = if c.on { item.comments } else { () }
      let body = if parts.len() > 0 { parts.join(c.separator) }
      if c.position == "after" and body != none { after.push((item.caption, body, comment-text, comments-block)) }
      // El ancho del diagrama fuera de la grilla de ancho fijo: el del tablero; un epígrafe más ancho se corta a
      // ese ancho, pero no a menos de caption.min-width (si entra en una línea, no se corta).
      let widths = if board-column != none { (diagram: board-column, text: board-column) } else {
        caption-width(item.caption, caption-text, board-width, d.caption.min-width)
      }
      let diagram-width = widths.diagram
      // Con width: auto, los comentarios al costado sin width ocupan lo que queda de la celda de siempre.
      let side-width = if c.width != auto { c.width.to-absolute() }
        else { (if grid-mode { cell } else { width }) - diagram-width - sep }
      // Con height, lo que no entra va después de los diagramas, con el epígrafe.
      if body != none and c.height != none and c.position != "after" {
        let comments-width = if c.position == bottom { diagram-width } else { side-width }
        let (top, rest) = split(body, c.height.to-absolute(),
          x => measure(block(width: comments-width, comments-box(x))).height)
        if rest != none { after.push((item.caption, rest, comment-text, comments-block)) }
        body = top
      }
      let lines = (
        item.caption,
        if d.notes and drawn.notes.len() > 0 { notes-text(resolved.tree, drawn.notes) },
        item.extra,
      ).filter(x => x != none)
      let below = {
        set par(spacing: 0.65em, first-line-indent: 0pt, justify: false)
        set block(spacing: 0.65em)
        if lines.len() > 0 {
          align(text-align, block(width: widths.text, align(text-align, text(..caption-text, lines.join(parbreak())))))
        }
        if c.position == bottom and body != none { comments-box(body) }
      }
      // En la grilla, el tablero va en el alto tallest (el del más alto de su fila, o none): abajo con valign:
      // bottom, arriba con align-captions (así, lo de debajo empieza en la misma línea en toda la fila).
      let board-height = measure(drawn.body).height
      let board-align = if grid-mode { lay.halign } else { center }
      let main(tallest) = {
        let placed = if tallest == none { align(board-align, drawn.body) }
          else { block(height: tallest, align(board-align + if lay.valign == bottom { bottom } else { top }, drawn.body)) }
        // El destino de un enlace (sgf-problem con links), al principio del diagrama.
        let target = item.at("anchor", default: none)
        block(width: diagram-width, {
          if target != none [#metadata(none)#target]
          stack(spacing: 0.3em, placed, below)
        })
      }
      let content(tallest) = if side {
        let rest = if c.width != auto { c.width } else if natural { side-width } else { 1fr }
        let notes = if body != none { comments-box(body) }
        let columns = if c.position == right { (diagram-width, rest) } else { (rest, diagram-width) }
        let main = main(tallest)
        grid(columns: columns, column-gutter: sep, ..if c.position == right { (main, notes) } else { (notes, main) })
      } else { main(tallest) }
      if grid-mode or side {
        cells.push((content: content, height: board-height, alone: item.alone, line: side))
      } else {
        // En el párrafo, el tablero queda sobre la línea de base: los de una línea quedan alineados arriba.
        let under = measure(block(width: diagram-width, below)).height + 0.3em.to-absolute()
        cells.push((content: _ => box(baseline: under, content(none)), height: board-height, alone: item.alone,
          line: false))
      }
      last = (resolved, drawn.notes)
    }
  }

  // Las celdas de un grupo de per-page. En la grilla, una fila incompleta deja vacías las últimas columnas; con
  // width: auto, las columnas tienen el ancho de la celda más ancha (las que van solas no cuentan) y la grilla,
  // el de tantas columnas como celdas, si son menos. En el párrafo, las celdas con los comentarios al costado
  // van cada una en su línea. La grilla o el párrafo se centran en la línea.
  let render(chunk) = {
    let body = if grid-mode {
      // Las filas de la grilla (una celda que va sola es una fila) y, con valign: bottom o align-captions, el alto
      // del tablero más alto de cada una.
      let n = lay.columns
      let (rows, row) = ((), ())
      for x in chunk {
        if x.alone {
          if row.len() > 0 { rows.push(row) }
          rows.push((x,))
          row = ()
        } else {
          row.push(x)
          if row.len() == n { rows.push(row); row = () }
        }
      }
      if row.len() > 0 { rows.push(row) }
      let even = lay.valign == bottom or lay.align-captions
      let chunk = rows.map(row => {
        let tallest = if even and not row.first().alone { calc.max(..row.map(x => x.height)) }
        row.map(x => x + (content: (x.content)(tallest)))
      }).flatten()
      let (columns, total) = if natural {
        let widths = chunk.filter(x => not x.alone).map(x => measure(x.content).width)
        let n = calc.max(1, calc.min(widths.len(), lay.columns))
        let column = calc.max(0pt, ..widths)
        let total = calc.max(column * n + column-sep * (n - 1), ..chunk.filter(x => x.alone).map(x => measure(x.content).width))
        ((column,) * n, total)
      } else { ((1fr,) * lay.columns, width) }
      // Una celda que va sola termina la fila: la completan celdas vacías.
      let (list, used) = ((), 0)
      for x in chunk {
        if x.alone {
          if used > 0 { list += ([],) * (columns.len() - used) }
          list.push(grid.cell(colspan: columns.len(), align: center + top, x.content))
          used = 0
        } else {
          list.push(x.content)
          used = calc.rem(used + 1, columns.len())
        }
      }
      block(width: total, grid(columns: columns, column-gutter: column-sep, row-gutter: lay.row-sep,
        align: lay.halign + top, ..list))
    } else {
      let chunk = chunk.map(x => x + (content: (x.content)(none)))
      // Uno al lado del otro; los que van solos, en su línea.
      let paragraph(run) = {
        set par(leading: lay.row-sep)
        set align(lay.halign)
        for (i, x) in run.enumerate() {
          if i > 0 { if x.alone or run.at(i - 1).alone { linebreak() } else { h(column-sep) } }
          x.content
        }
      }
      let (parts, run) = ((), ())
      for x in chunk {
        if x.line {
          if run.len() > 0 { parts.push(paragraph(run)) }
          run = ()
          parts.push(x.content)
        } else {
          run.push(x)
        }
      }
      if run.len() > 0 { parts.push(paragraph(run)) }
      block(width: width, if parts.len() == 1 { parts.first() } else { stack(spacing: lay.row-sep, ..parts) })
    }
    align(center, {
      set par(first-line-indent: 0pt, justify: false)
      body
    })
  }
  // Cada per-page celdas, la página siguiente (con varias columnas, la columna siguiente).
  let per = if lay.per-page == none { calc.max(cells.len(), 1) } else { lay.per-page }
  range(0, cells.len(), step: per).map(i => render(cells.slice(i, calc.min(i + per, cells.len())))).join(colbreak())
  if after.len() > 0 {
    v(lay.row-sep)
    for (head, body, comment-text, comments-block) in after {
      if head != none { block(below: 0.65em, text(..comment-text, strong(head))) }
      comments-block(body)
    }
  }
  if last != none { record(..last) }
}
