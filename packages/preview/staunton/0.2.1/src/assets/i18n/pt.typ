// Portuguese: Rei, Dama, Torre, Bispo, Cavalo
#let piece-chars = (
	king: "R",
	queen: "D",
	rook: "T",
	bishop: "B",
	knight: "C",
)

// UI strings: language-aware supplements / outline titles.
#let strings = (
	diagram-supplement: "Diagrama",
	table-supplement: "Tabela",
	diagram-outline-title: "Lista de diagramas",
	table-outline-title: "Lista de tabelas",
	fen-caption: (num, turn) => "Posição no lance " + num + ", jogam as " + (if turn == "w" { "Brancas" } else { "Pretas" }),
	pgn-caption: move => "Posição após o lance " + move,
	// Tournament-table column headers.
	tbl-rank: "Pos",
	tbl-player: "Jogador",
	tbl-team: "Equipe",
	tbl-played: "J",
	tbl-points: "Pts",
	tbl-round-abbr: "R",
)
