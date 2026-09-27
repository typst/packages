// Italian: Re, Donna, Torre, Alfiere, Cavallo
#let piece-chars = (
	king: "R",
	queen: "D",
	rook: "T",
	bishop: "A",
	knight: "C",
)

// UI strings: language-aware supplements / outline titles.
#let strings = (
	diagram-supplement: "Diagramma",
	table-supplement: "Tabella",
	diagram-outline-title: "Elenco dei diagrammi",
	table-outline-title: "Elenco delle tabelle",
	fen-caption: turn => if turn == "w" { "Muove il Bianco" } else { "Muove il Nero" },
	pgn-caption: move => "Posizione dopo " + move,
	// Tournament-table column headers.
	tbl-rank: "Pos",
	tbl-player: "Giocatore",
	tbl-team: "Squadra",
	tbl-played: "G",
	tbl-points: "Pti",
	tbl-round-abbr: "T",
)
