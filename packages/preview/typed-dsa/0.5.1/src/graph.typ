// Graph domain facade.
//
// Adjacency state, validation, layout, CeTZ rendering, and algorithm traces are
// implemented in focused internal modules with one-way dependencies.

#import "graph-api.typ": graph as _graph
#import "graph-algorithms.typ": bfs as _bfs, dfs as _dfs, dijkstra as _dijkstra

#let graph = _graph
#let bfs = _bfs
#let dfs = _dfs
#let dijkstra = _dijkstra
