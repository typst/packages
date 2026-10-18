// Russian: Король, Ферзь, Ладья, Слон, Конь
// (King is "Кр" to distinguish it from Knight "К".)
#let piece-chars = (
	king: "Кр",
	queen: "Ф",
	rook: "Л",
	bishop: "С",
	knight: "К",
)

// UI strings: language-aware supplements / outline titles.
#let strings = (
	diagram-supplement: "Диаграмма",
	table-supplement: "Таблица",
	diagram-outline-title: "Список диаграмм",
	table-outline-title: "Список таблиц",
	fen-caption: (num, turn) => "Позиция на " + num + "-м ходу, ход " + (if turn == "w" { "белых" } else { "чёрных" }),
	pgn-caption: move => "Позиция после хода " + move,
	// Tournament-table column headers.
	tbl-rank: "№",
	tbl-player: "Игрок",
	tbl-team: "Команда",
	tbl-played: "И",
	tbl-points: "Очки",
	tbl-round-abbr: "Т",
)
