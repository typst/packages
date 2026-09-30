#let piece-chars = (
	king: "K",
	queen: "Q",
	rook: "R",
	bishop: "B",
	knight: "N",
)

// UI strings: language-aware supplements / outline titles, automatic diagram
// captions, and tournament-table column headers.
//
// The two `*-caption` entries are FUNCTIONS, not plain strings, so each language
// owns its own word order and grammar:
//   * fen-caption(turn) -- `turn` is "w" | "b" (side to move). A bare FEN has no
//     move history, so the caption states only whose turn it is.
//   * pgn-caption(move) -- `move` is the already-assembled move reference
//     (e.g. "5. Nf3" / "5... Nf3"); the SAN token itself is left as stored.
#let strings = (
	diagram-supplement: "Diagram",
	table-supplement: "Table",
	diagram-outline-title: "List of Diagrams",
	table-outline-title: "List of Tables",
	fen-caption: turn => if turn == "w" { "White to move" } else { "Black to move" },
	pgn-caption: move => "Position after " + move,
	// Tournament-table column headers.
	tbl-rank: "Pos",
	tbl-player: "Player",
	tbl-team: "Team",
	tbl-played: "Pl",
	tbl-points: "Pts",
	tbl-round-abbr: "R",
)
