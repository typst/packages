// Spanish: Rey, Dama, Torre, Alfil, Caballo
#let piece-chars = (
	king: "R",
	queen: "D",
	rook: "T",
	bishop: "A",
	knight: "C",
)

// UI strings: language-aware supplements / outline titles.
#let strings = (
	diagram-supplement: "Diagrama",
	table-supplement: "Tabla",
	diagram-outline-title: "Lista de diagramas",
	table-outline-title: "Lista de tablas",
	fen-caption: (num, turn) => "Posición en la jugada " + num + ", mueven las " + (if turn == "w" { "Blancas" } else { "Negras" }),
	pgn-caption: move => "Posición tras la jugada " + move,
	// Tournament-table column headers.
	tbl-rank: "Pos",
	tbl-player: "Jugador",
	tbl-team: "Equipo",
	tbl-played: "PJ",
	tbl-points: "Pts",
	tbl-round-abbr: "R",
)
