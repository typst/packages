// goban-layout: varios tableros en una disposición, la de sgf-diagrams y sgf-problem (arrange). Los tableros son
// valores (board(...) o una partida); los diagramas de un sgf-diagrams(...) o un sgf-problem(...) se reconocen
// por el metadata que llevan adelante.

#import "options.typ": current, merge
#import "board.typ": board, resolve
#import "arrange.typ": check-layout, board-style, arrange
#import "diagrams.typ": diagram-group
#import "problems.typ": problem-group

// Lo que va en la disposición: (kind: "board", board), o el metadata de sgf-diagrams o sgf-problem.
#let source(item) = {
  if type(item) == dictionary and "goban-board" in item { return (kind: "board", board: item) }
  if type(item) == dictionary and "kind" in item { return (kind: "board", board: board(item)) }
  if type(item) == content and item.func() == [].func() and item.children.len() > 0 {
    let first = item.children.first()
    if first.func() == metadata and first.at("label", default: none) == <goban-cells> { return first.value }
  }
  panic("goban-layout dispone tableros hechos con board(...), partidas, sgf-diagrams(...) y sgf-problem(...)"
    + if type(item) == content { "; un goban(...) ya está dibujado: va board(...)" } else { ": " + repr(item) })
}

// Dispone los tableros (board(...) o partidas) y los diagramas de los sgf-diagrams(...) y sgf-problem(...), en
// el orden en que vienen. Las opciones son las de la rama layout, encima de las globales; las layout de
// sgf-diagrams y sgf-problem no se usan.
#let goban-layout(..args) = {
  let sources = args.pos().map(source)
  let options = args.named()
  layout(size => {
    let global = current()
    let lay = check-layout(merge(global.layout, options, path: ("layout",)))
    let groups = sources.map(s => {
      if s.kind == "board" {
        (style: board-style, items: ((resolved: resolve(s.board, global), caption: none, comments: (), extra: none,
          alone: false),))
      } else if s.kind == "diagrams" { diagram-group(s.game, s.options) }
      else { problem-group(s.games, s.options) }
    })
    arrange(lay, size.width, groups)
  })
}
