// French: Roi, Dame, Tour, Fou, Cavalier
#let piece-chars = (
	king: "R",
	queen: "D",
	rook: "T",
	bishop: "F",
	knight: "C",
)

// UI strings: language-aware supplements / outline titles.
#let strings = (
	diagram-supplement: "Diagramme",
	table-supplement: "Tableau",
	diagram-outline-title: "Liste des diagrammes",
	table-outline-title: "Liste des tableaux",
	fen-caption: (num, turn) => "Position au coup " + num + ", trait aux " + (if turn == "w" { "Blancs" } else { "Noirs" }),
	pgn-caption: move => "Position après le coup " + move,
	// Tournament-table column headers.
	tbl-rank: "Pl.",
	tbl-player: "Joueur",
	tbl-team: "Équipe",
	tbl-played: "J",
	tbl-points: "Pts",
	tbl-round-abbr: "R",
)
