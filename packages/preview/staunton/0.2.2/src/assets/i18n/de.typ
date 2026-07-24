// German: König, Dame, Turm, Läufer, Springer
#let piece-chars = (
	king: "K",
	queen: "D",
	rook: "T",
	bishop: "L",
	knight: "S",
)

// UI strings: language-aware supplements / outline titles.
#let strings = (
	diagram-supplement: "Diagramm",
	table-supplement: "Tabelle",
	diagram-outline-title: "Diagrammverzeichnis",
	table-outline-title: "Tabellenverzeichnis",
	fen-caption: turn => if turn == "w" { "Weiß am Zug" } else { "Schwarz am Zug" },
	pgn-caption: move => "Stellung nach " + move,
	// Tournament-table column headers.
	tbl-rank: "Pl.",
	tbl-player: "Spieler",
	tbl-team: "Mannschaft",
	tbl-played: "Sp",
	tbl-points: "Pkt",
	tbl-round-abbr: "R",
)
